#define _WIN32_WINNT 0x0A00
#define NTDDI_VERSION 0x06030000

#include <windows.h>
#include <setupapi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <emi.h>

#ifndef ARRAYSIZE
#define ARRAYSIZE(a) (sizeof(a) / sizeof((a)[0]))
#endif

static const GUID POWERPILOT_GUID_DEVICE_ENERGY_METER =
    {0x45bd8344, 0x7ed6, 0x49cf, {0xa4, 0x40, 0xc2, 0x76, 0xc9, 0x33, 0xb0, 0x53}};

typedef struct Candidate
{
    int valid;
    int score;
    double watts;
    char sensor[256];
} Candidate;

static void SafeCopy(char* dest, size_t destSize, const char* source)
{
    if (!dest || destSize == 0)
        return;

    if (!source)
        source = "";

    strncpy(dest, source, destSize - 1);
    dest[destSize - 1] = '\0';
}

static int ContainsInsensitive(const char* haystack, const char* needle)
{
    size_t needleLen;
    size_t i;

    if (!haystack || !needle || !*needle)
        return 0;

    needleLen = strlen(needle);
    for (i = 0; haystack[i] != '\0'; ++i)
    {
        size_t j = 0;
        while (j < needleLen &&
               haystack[i + j] != '\0' &&
               tolower((unsigned char)haystack[i + j]) == tolower((unsigned char)needle[j]))
        {
            ++j;
        }

        if (j == needleLen)
            return 1;
    }

    return 0;
}

static void WideToAnsi(const WCHAR* source, char* dest, size_t destSize)
{
    int converted;

    if (!dest || destSize == 0)
        return;

    dest[0] = '\0';
    if (!source || !*source)
        return;

    converted = WideCharToMultiByte(CP_ACP, 0, source, -1, dest, (int)destSize, NULL, NULL);
    if (converted <= 0)
        SafeCopy(dest, destSize, "");
}

static double ComputeAverageWatts(const EMI_CHANNEL_MEASUREMENT_DATA* first, const EMI_CHANNEL_MEASUREMENT_DATA* second)
{
    ULONGLONG deltaEnergy;
    ULONGLONG deltaTime;

    if (!first || !second)
        return 0.0;

    if (second->AbsoluteTime <= first->AbsoluteTime || second->AbsoluteEnergy <= first->AbsoluteEnergy)
        return 0.0;

    deltaEnergy = second->AbsoluteEnergy - first->AbsoluteEnergy;
    deltaTime = second->AbsoluteTime - first->AbsoluteTime;

    return ((double)deltaEnergy * 0.036) / (double)deltaTime;
}

static int ScoreCpuChannel(const char* channelName)
{
    if (!channelName || !*channelName)
        return -1;

    if (_stricmp(channelName, "rapl_package0_pkg") == 0) return 5000;
    if (_stricmp(channelName, "current socket power") == 0) return 4500;
    if (_stricmp(channelName, "apu power") == 0) return 4200;
    if (ContainsInsensitive(channelName, "cpu")) return 3900;
    if (ContainsInsensitive(channelName, "socket")) return 3800;
    if (ContainsInsensitive(channelName, "package")) return 3600;
    if (ContainsInsensitive(channelName, "power") && !ContainsInsensitive(channelName, "gpu")) return 3400;
    if (ContainsInsensitive(channelName, "ppt")) return 3200;
    if (ContainsInsensitive(channelName, "stapm")) return 3100;
    if (ContainsInsensitive(channelName, "pkg")) return 2500;

    return -1;
}

static int ScoreGpuChannel(const char* channelName)
{
    if (!channelName || !*channelName)
        return -1;

    if (_stricmp(channelName, "vddgfx power") == 0) return 7000;
    if (_stricmp(channelName, "vddcr_gfx power") == 0) return 6900;
    if (ContainsInsensitive(channelName, "gfx")) return 6600;
    if (ContainsInsensitive(channelName, "gpu")) return 6300;
    if (ContainsInsensitive(channelName, "graphics")) return 6100;
    if (_stricmp(channelName, "vddcr_soc power") == 0) return 4200;
    if (ContainsInsensitive(channelName, "soc")) return 3200;

    return -1;
}

static int ScoreApuChannel(const char* channelName)
{
    if (!channelName || !*channelName)
        return -1;

    if (_stricmp(channelName, "apu power") == 0) return 8000;
    if (ContainsInsensitive(channelName, "apu")) return 7000;

    return -1;
}

static void ConsiderCandidate(Candidate* candidate, int score, double watts, const char* channelName)
{
    char sensor[256];

    if (!candidate || !channelName)
        return;

    if (score < 0 || watts <= 0.05)
        return;

    if (candidate->valid && score < candidate->score)
        return;

    snprintf(sensor, sizeof(sensor), "Windows power reading / EMI %s", channelName);
    candidate->valid = 1;
    candidate->score = score;
    candidate->watts = watts;
    SafeCopy(candidate->sensor, sizeof(candidate->sensor), sensor);
}

static int ReadMeasurement(HANDLE deviceHandle, void* buffer, DWORD bufferSize)
{
    DWORD bytesReturned = 0;

    return DeviceIoControl(deviceHandle,
                           IOCTL_EMI_GET_MEASUREMENT,
                           NULL,
                           0,
                           buffer,
                           bufferSize,
                           &bytesReturned,
                           NULL);
}

static void ProcessV1Device(HANDLE deviceHandle, Candidate* cpu, Candidate* apu, Candidate* gpu)
{
    EMI_METADATA_SIZE metadataSize;
    DWORD bytesReturned = 0;
    EMI_METADATA_V1* metadata = NULL;
    EMI_MEASUREMENT_DATA_V1 first;
    EMI_MEASUREMENT_DATA_V1 second;
    char channelName[128];
    double watts;

    ZeroMemory(&metadataSize, sizeof(metadataSize));
    if (!DeviceIoControl(deviceHandle, IOCTL_EMI_GET_METADATA_SIZE, NULL, 0, &metadataSize, sizeof(metadataSize), &bytesReturned, NULL))
        return;

    if (metadataSize.MetadataSize < sizeof(EMI_METADATA_V1))
        return;

    metadata = (EMI_METADATA_V1*)malloc(metadataSize.MetadataSize);
    if (!metadata)
        return;

    if (!DeviceIoControl(deviceHandle, IOCTL_EMI_GET_METADATA, NULL, 0, metadata, metadataSize.MetadataSize, &bytesReturned, NULL))
    {
        free(metadata);
        return;
    }

    if (metadata->MeasurementUnit != EmiMeasurementUnitPicowattHours)
    {
        free(metadata);
        return;
    }

    ZeroMemory(&first, sizeof(first));
    ZeroMemory(&second, sizeof(second));
    if (!ReadMeasurement(deviceHandle, &first, sizeof(first)))
    {
        free(metadata);
        return;
    }

    Sleep(180);

    if (!ReadMeasurement(deviceHandle, &second, sizeof(second)))
    {
        free(metadata);
        return;
    }

    WideToAnsi(metadata->MeteredHardwareName, channelName, sizeof(channelName));
    if (!channelName[0])
        SafeCopy(channelName, sizeof(channelName), "EMI Meter");

    watts = ComputeAverageWatts(&first, &second);
    ConsiderCandidate(cpu, ScoreCpuChannel(channelName), watts, channelName);
    ConsiderCandidate(apu, ScoreApuChannel(channelName), watts, channelName);
    ConsiderCandidate(gpu, ScoreGpuChannel(channelName), watts, channelName);

    free(metadata);
}

static void ProcessV2Device(HANDLE deviceHandle, Candidate* cpu, Candidate* apu, Candidate* gpu)
{
    EMI_METADATA_SIZE metadataSize;
    DWORD bytesReturned = 0;
    EMI_METADATA_V2* metadata = NULL;
    EMI_MEASUREMENT_DATA_V2* first = NULL;
    EMI_MEASUREMENT_DATA_V2* second = NULL;
    EMI_CHANNEL_V2* channel = NULL;
    DWORD measurementSize = 0;
    USHORT channelIndex = 0;

    ZeroMemory(&metadataSize, sizeof(metadataSize));
    if (!DeviceIoControl(deviceHandle, IOCTL_EMI_GET_METADATA_SIZE, NULL, 0, &metadataSize, sizeof(metadataSize), &bytesReturned, NULL))
        return;

    if (metadataSize.MetadataSize < sizeof(EMI_METADATA_V2))
        return;

    metadata = (EMI_METADATA_V2*)malloc(metadataSize.MetadataSize);
    if (!metadata)
        return;

    if (!DeviceIoControl(deviceHandle, IOCTL_EMI_GET_METADATA, NULL, 0, metadata, metadataSize.MetadataSize, &bytesReturned, NULL))
    {
        free(metadata);
        return;
    }

    measurementSize = FIELD_OFFSET(EMI_MEASUREMENT_DATA_V2, ChannelData[metadata->ChannelCount]);
    if (measurementSize < sizeof(EMI_MEASUREMENT_DATA_V2) || metadata->ChannelCount == 0)
    {
        free(metadata);
        return;
    }

    first = (EMI_MEASUREMENT_DATA_V2*)malloc(measurementSize);
    second = (EMI_MEASUREMENT_DATA_V2*)malloc(measurementSize);
    if (!first || !second)
        goto cleanup;

    ZeroMemory(first, measurementSize);
    ZeroMemory(second, measurementSize);
    if (!ReadMeasurement(deviceHandle, first, measurementSize))
        goto cleanup;

    Sleep(180);

    if (!ReadMeasurement(deviceHandle, second, measurementSize))
        goto cleanup;

    channel = &metadata->Channels[0];
    for (channelIndex = 0; channelIndex < metadata->ChannelCount; ++channelIndex)
    {
        char channelName[128];
        double watts;

        if (channel->MeasurementUnit != EmiMeasurementUnitPicowattHours)
        {
            channel = EMI_CHANNEL_V2_NEXT_CHANNEL(channel);
            continue;
        }

        WideToAnsi(channel->ChannelName, channelName, sizeof(channelName));
        watts = ComputeAverageWatts(&first->ChannelData[channelIndex], &second->ChannelData[channelIndex]);
        ConsiderCandidate(cpu, ScoreCpuChannel(channelName), watts, channelName);
        ConsiderCandidate(apu, ScoreApuChannel(channelName), watts, channelName);
        ConsiderCandidate(gpu, ScoreGpuChannel(channelName), watts, channelName);

        channel = EMI_CHANNEL_V2_NEXT_CHANNEL(channel);
    }

cleanup:
    if (first)
        free(first);
    if (second)
        free(second);
    free(metadata);
}

int main(void)
{
    HDEVINFO deviceInfoSet;
    SP_DEVICE_INTERFACE_DATA interfaceData;
    DWORD index = 0;
    Candidate cpu = {0};
    Candidate apu = {0};
    Candidate gpu = {0};

    deviceInfoSet = SetupDiGetClassDevs(&POWERPILOT_GUID_DEVICE_ENERGY_METER, NULL, NULL, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
    if (deviceInfoSet == INVALID_HANDLE_VALUE)
        return 1;

    ZeroMemory(&interfaceData, sizeof(interfaceData));
    interfaceData.cbSize = sizeof(interfaceData);

    while (SetupDiEnumDeviceInterfaces(deviceInfoSet, NULL, &POWERPILOT_GUID_DEVICE_ENERGY_METER, index, &interfaceData))
    {
        DWORD requiredSize = 0;
        PSP_DEVICE_INTERFACE_DETAIL_DATA detailData = NULL;
        HANDLE deviceHandle = INVALID_HANDLE_VALUE;
        EMI_VERSION version;
        DWORD bytesReturned = 0;

        ++index;

        SetupDiGetDeviceInterfaceDetail(deviceInfoSet, &interfaceData, NULL, 0, &requiredSize, NULL);
        if (requiredSize == 0)
            continue;

        detailData = (PSP_DEVICE_INTERFACE_DETAIL_DATA)malloc(requiredSize);
        if (!detailData)
            continue;

        detailData->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA);
        if (!SetupDiGetDeviceInterfaceDetail(deviceInfoSet, &interfaceData, detailData, requiredSize, NULL, NULL))
        {
            free(detailData);
            continue;
        }

        deviceHandle = CreateFile(detailData->DevicePath,
                                  GENERIC_READ,
                                  FILE_SHARE_READ | FILE_SHARE_WRITE,
                                  NULL,
                                  OPEN_EXISTING,
                                  FILE_ATTRIBUTE_NORMAL,
                                  NULL);
        free(detailData);
        if (deviceHandle == INVALID_HANDLE_VALUE)
            continue;

        ZeroMemory(&version, sizeof(version));
        if (!DeviceIoControl(deviceHandle, IOCTL_EMI_GET_VERSION, NULL, 0, &version, sizeof(version), &bytesReturned, NULL))
        {
            CloseHandle(deviceHandle);
            continue;
        }

        if (version.EmiVersion >= EMI_VERSION_V2)
            ProcessV2Device(deviceHandle, &cpu, &apu, &gpu);
        else if (version.EmiVersion >= EMI_VERSION_V1)
            ProcessV1Device(deviceHandle, &cpu, &apu, &gpu);

        CloseHandle(deviceHandle);
        ZeroMemory(&interfaceData, sizeof(interfaceData));
        interfaceData.cbSize = sizeof(interfaceData);
    }

    SetupDiDestroyDeviceInfoList(deviceInfoSet);

    if (cpu.valid)
        printf("WINDOWSCPUPOWER|%s|%.2f\n", cpu.sensor, cpu.watts);
    if (apu.valid)
        printf("WINDOWSAPUPOWER|%s|%.2f\n", apu.sensor, apu.watts);
    if (gpu.valid)
        printf("WINDOWSGPUPOWER|%s|%.2f\n", gpu.sensor, gpu.watts);

    return (cpu.valid || apu.valid || gpu.valid) ? 0 : 1;
}
