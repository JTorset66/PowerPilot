// PowerPilot AMD ADL probe helper.
//
// Probe-only helper for AMD's legacy ADL runtime.  It dynamically loads the
// AMD-driver-installed atiadlxx.dll from System32 and never writes tuning
// settings.  ADLX remains the preferred control path; this helper exists only
// to discover whether ADL exposes additional supported actuators on a system.

#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

namespace
{
constexpr int ADL_OK = 0;
constexpr int ADL_MAX_PATH = 256;
constexpr int ADL_PMLOG_MAX_SUPPORTED_SENSORS = 256;

using ADL_CONTEXT_HANDLE = void*;
using ADL_MAIN_MALLOC_CALLBACK = void* (*)(int);

struct AdapterInfo
{
    int iSize;
    int iAdapterIndex;
    char strUDID[ADL_MAX_PATH];
    int iBusNumber;
    int iDeviceNumber;
    int iFunctionNumber;
    int iVendorID;
    char strAdapterName[ADL_MAX_PATH];
    char strDisplayName[ADL_MAX_PATH];
    int iPresent;
    int iExist;
    char strDriverPath[ADL_MAX_PATH];
    char strDriverPathExt[ADL_MAX_PATH];
    char strPNPString[ADL_MAX_PATH];
    int iOSDisplayIndex;
};

struct ADLODNPowerLimitSetting
{
    int iMode;
    int iTDPLimit;
    int iMaxOperatingTemperature;
};

struct ADLOD8SingleInitSetting
{
    int featureID;
    int minValue;
    int maxValue;
    int defaultValue;
};

struct ADLPMLogSupportInfo
{
    unsigned short usSensors[ADL_PMLOG_MAX_SUPPORTED_SENSORS];
    int ulReserved[16];
};

using ADL2_Main_Control_Create_t = int (*)(ADL_MAIN_MALLOC_CALLBACK, int, ADL_CONTEXT_HANDLE*);
using ADL2_Main_Control_Destroy_t = int (*)(ADL_CONTEXT_HANDLE);
using ADL2_Adapter_NumberOfAdapters_Get_t = int (*)(ADL_CONTEXT_HANDLE, int*);
using ADL2_Adapter_AdapterInfo_Get_t = int (*)(ADL_CONTEXT_HANDLE, int, AdapterInfo*);
using ADL2_Adapter_AdapterInfoX2_Get_t = int (*)(ADL_CONTEXT_HANDLE, AdapterInfo**);
using ADL2_Adapter_Active_Get_t = int (*)(ADL_CONTEXT_HANDLE, int, int*);
using ADL2_Adapter_ObservedClockInfo_Get_t = int (*)(ADL_CONTEXT_HANDLE, int, int*, int*);
using ADL2_Overdrive_Caps_t = int (*)(ADL_CONTEXT_HANDLE, int, int*, int*, int*);
using ADL2_OverdriveN_PowerLimit_Get_t = int (*)(ADL_CONTEXT_HANDLE, int, ADLODNPowerLimitSetting*);
using ADL2_Overdrive8_Init_SettingX2_Get_t = int (*)(ADL_CONTEXT_HANDLE, int, int*, int*, ADLOD8SingleInitSetting**);
using ADL2_Overdrive8_Current_SettingX2_Get_t = int (*)(ADL_CONTEXT_HANDLE, int, int*, int**);
using ADL2_Adapter_PMLog_Support_Get_t = int (*)(ADL_CONTEXT_HANDLE, int, ADLPMLogSupportInfo*);
using ADL2_Overdrive8_PMLog_ShareMemory_Support_t = int (*)(ADL_CONTEXT_HANDLE, int, int*, int);
using ADL2_Overdrive8_PMLogSenorType_Support_Get_t = int (*)(ADL_CONTEXT_HANDLE, int, int*, int**);

struct AdlApi
{
    HMODULE dll = nullptr;
    std::string runtimePath;

    ADL2_Main_Control_Create_t MainCreate = nullptr;
    ADL2_Main_Control_Destroy_t MainDestroy = nullptr;
    ADL2_Adapter_NumberOfAdapters_Get_t AdapterCount = nullptr;
    ADL2_Adapter_AdapterInfo_Get_t AdapterInfoGet = nullptr;
    ADL2_Adapter_AdapterInfoX2_Get_t AdapterInfoX2Get = nullptr;
    ADL2_Adapter_Active_Get_t AdapterActiveGet = nullptr;
    ADL2_Adapter_ObservedClockInfo_Get_t ObservedClockGet = nullptr;
    ADL2_Overdrive_Caps_t OverdriveCaps = nullptr;
    ADL2_OverdriveN_PowerLimit_Get_t OverdriveNPowerLimitGet = nullptr;
    ADL2_Overdrive8_Init_SettingX2_Get_t Overdrive8InitX2Get = nullptr;
    ADL2_Overdrive8_Current_SettingX2_Get_t Overdrive8CurrentX2Get = nullptr;
    ADL2_Adapter_PMLog_Support_Get_t PMLogSupportGet = nullptr;
    ADL2_Overdrive8_PMLog_ShareMemory_Support_t PMLogShareMemorySupport = nullptr;
    ADL2_Overdrive8_PMLogSenorType_Support_Get_t PMLogSensorTypeSupportGet = nullptr;
};

struct AdlContext
{
    ADL_CONTEXT_HANDLE handle = nullptr;
};

void* __stdcall AdlAlloc(int bytes)
{
    if (bytes <= 0)
        return nullptr;
    return std::calloc(1, static_cast<size_t>(bytes));
}

void AdlFree(void* ptr)
{
    std::free(ptr);
}

std::string JsonEscape(const std::string& value)
{
    std::string out;
    out.reserve(value.size() + 8);
    for (char c : value)
    {
        switch (c)
        {
        case '\\': out += "\\\\"; break;
        case '"': out += "\\\""; break;
        case '\b': out += "\\b"; break;
        case '\f': out += "\\f"; break;
        case '\n': out += "\\n"; break;
        case '\r': out += "\\r"; break;
        case '\t': out += "\\t"; break;
        default:
            if (static_cast<unsigned char>(c) < 0x20)
            {
                char buffer[8];
                std::snprintf(buffer, sizeof(buffer), "\\u%04x", static_cast<unsigned char>(c));
                out += buffer;
            }
            else
            {
                out += c;
            }
            break;
        }
    }
    return out;
}

std::string Lower(std::string value)
{
    std::transform(value.begin(), value.end(), value.begin(), [](unsigned char c) {
        return static_cast<char>(std::tolower(c));
    });
    return value;
}

std::string ExeDirectory()
{
    char path[MAX_PATH] = {};
    DWORD len = GetModuleFileNameA(nullptr, path, static_cast<DWORD>(sizeof(path)));
    if (len == 0 || len >= sizeof(path))
        return ".";

    std::string full(path);
    size_t pos = full.find_last_of("\\/");
    if (pos == std::string::npos)
        return ".";
    return full.substr(0, pos);
}

bool FileExists(const std::string& path)
{
    DWORD attr = GetFileAttributesA(path.c_str());
    return attr != INVALID_FILE_ATTRIBUTES && (attr & FILE_ATTRIBUTE_DIRECTORY) == 0;
}

bool LocalAdlRuntimeDllPresent()
{
    std::string dir = ExeDirectory();
    return FileExists(dir + "\\atiadlxx.dll") || FileExists(dir + "\\atiadlxy.dll");
}

std::string System32AdlPath()
{
    char dir[MAX_PATH] = {};
    UINT len = GetSystemDirectoryA(dir, static_cast<UINT>(sizeof(dir)));
    if (len == 0 || len >= sizeof(dir))
        return "C:\\Windows\\System32\\atiadlxx.dll";
    return std::string(dir) + "\\atiadlxx.dll";
}

template <typename T>
void Bind(HMODULE dll, const char* name, T& fn)
{
    fn = reinterpret_cast<T>(GetProcAddress(dll, name));
}

std::string BaseJson(const std::string& command, bool ok, const std::string& error = "")
{
    std::ostringstream os;
    os << "{\"schema\":\"powerpilot.amd_adl.v1\",\"command\":\"" << JsonEscape(command)
       << "\",\"ok\":" << (ok ? "true" : "false");
    if (!error.empty())
        os << ",\"error\":\"" << JsonEscape(error) << "\"";
    return os.str();
}

bool LoadAdl(AdlApi& api, std::string& error)
{
    if (LocalAdlRuntimeDllPresent())
    {
        error = "Refusing to load local ADL runtime DLL beside helper.";
        return false;
    }

    SetDllDirectoryA("");
    api.runtimePath = System32AdlPath();
    api.dll = LoadLibraryExA(api.runtimePath.c_str(), nullptr, LOAD_LIBRARY_SEARCH_SYSTEM32);
    if (!api.dll)
    {
        error = "atiadlxx.dll was not found in System32 or could not be loaded.";
        return false;
    }

    Bind(api.dll, "ADL2_Main_Control_Create", api.MainCreate);
    Bind(api.dll, "ADL2_Main_Control_Destroy", api.MainDestroy);
    Bind(api.dll, "ADL2_Adapter_NumberOfAdapters_Get", api.AdapterCount);
    Bind(api.dll, "ADL2_Adapter_AdapterInfo_Get", api.AdapterInfoGet);
    Bind(api.dll, "ADL2_Adapter_AdapterInfoX2_Get", api.AdapterInfoX2Get);
    Bind(api.dll, "ADL2_Adapter_Active_Get", api.AdapterActiveGet);
    Bind(api.dll, "ADL2_Adapter_ObservedClockInfo_Get", api.ObservedClockGet);
    Bind(api.dll, "ADL2_Overdrive_Caps", api.OverdriveCaps);
    Bind(api.dll, "ADL2_OverdriveN_PowerLimit_Get", api.OverdriveNPowerLimitGet);
    Bind(api.dll, "ADL2_Overdrive8_Init_SettingX2_Get", api.Overdrive8InitX2Get);
    Bind(api.dll, "ADL2_Overdrive8_Current_SettingX2_Get", api.Overdrive8CurrentX2Get);
    Bind(api.dll, "ADL2_Adapter_PMLog_Support_Get", api.PMLogSupportGet);
    Bind(api.dll, "ADL2_Overdrive8_PMLog_ShareMemory_Support", api.PMLogShareMemorySupport);
    Bind(api.dll, "ADL2_Overdrive8_PMLogSenorType_Support_Get", api.PMLogSensorTypeSupportGet);

    if (!api.MainCreate || !api.MainDestroy || !api.AdapterCount)
    {
        error = "Required ADL2 entry points are missing.";
        return false;
    }

    return true;
}

void UnloadAdl(AdlApi& api)
{
    if (api.dll)
    {
        FreeLibrary(api.dll);
        api.dll = nullptr;
    }
}

bool CreateContext(const AdlApi& api, AdlContext& ctx, std::string& error)
{
    int result = api.MainCreate(&AdlAlloc, 1, &ctx.handle);
    if (result != ADL_OK || !ctx.handle)
    {
        error = "ADL2_Main_Control_Create failed: " + std::to_string(result);
        return false;
    }
    return true;
}

void DestroyContext(const AdlApi& api, AdlContext& ctx)
{
    if (ctx.handle && api.MainDestroy)
    {
        api.MainDestroy(ctx.handle);
        ctx.handle = nullptr;
    }
}

std::vector<AdapterInfo> GetAdapters(const AdlApi& api, const AdlContext& ctx)
{
    std::vector<AdapterInfo> adapters;
    int count = 0;
    if (!api.AdapterCount || api.AdapterCount(ctx.handle, &count) != ADL_OK || count <= 0)
        return adapters;

    if (api.AdapterInfoX2Get)
    {
        AdapterInfo* allocated = nullptr;
        if (api.AdapterInfoX2Get(ctx.handle, &allocated) == ADL_OK && allocated)
        {
            for (int i = 0; i < count; ++i)
                adapters.push_back(allocated[i]);
            AdlFree(allocated);
            return adapters;
        }
    }

    if (api.AdapterInfoGet)
    {
        adapters.resize(static_cast<size_t>(count));
        for (auto& adapter : adapters)
            adapter.iSize = sizeof(AdapterInfo);
        if (api.AdapterInfoGet(ctx.handle, sizeof(AdapterInfo) * count, adapters.data()) != ADL_OK)
            adapters.clear();
    }

    return adapters;
}

int CountPMLogSensors(const ADLPMLogSupportInfo& info)
{
    int count = 0;
    for (unsigned short sensor : info.usSensors)
    {
        if (sensor != 0)
            ++count;
    }
    return count;
}

void AppendFunctionAvailability(std::ostringstream& os, const AdlApi& api)
{
    os << "\"entry_points\":{"
       << "\"overdrive_caps\":" << (api.OverdriveCaps ? "true" : "false")
       << ",\"overdrive_n_power_limit_get\":" << (api.OverdriveNPowerLimitGet ? "true" : "false")
       << ",\"overdrive8_init_x2_get\":" << (api.Overdrive8InitX2Get ? "true" : "false")
       << ",\"overdrive8_current_x2_get\":" << (api.Overdrive8CurrentX2Get ? "true" : "false")
       << ",\"pmlog_support_get\":" << (api.PMLogSupportGet ? "true" : "false")
       << ",\"pmlog_shared_memory_support\":" << (api.PMLogShareMemorySupport ? "true" : "false")
       << ",\"pmlog_sensor_type_support_get\":" << (api.PMLogSensorTypeSupportGet ? "true" : "false")
       << "}";
}

int Probe()
{
    AdlApi api;
    AdlContext ctx;
    std::string error;

    if (!LoadAdl(api, error))
    {
        std::cout << BaseJson("probe", false, error)
                  << ",\"available\":false,\"runtime_path\":\"" << JsonEscape(api.runtimePath) << "\"}" << std::endl;
        UnloadAdl(api);
        return 2;
    }

    if (!CreateContext(api, ctx, error))
    {
        std::cout << BaseJson("probe", false, error)
                  << ",\"available\":true,\"runtime_path\":\"" << JsonEscape(api.runtimePath) << "\"}" << std::endl;
        UnloadAdl(api);
        return 2;
    }

    std::vector<AdapterInfo> adapters = GetAdapters(api, ctx);
    std::ostringstream os;
    os << BaseJson("probe", true)
       << ",\"available\":true,\"runtime_path\":\"" << JsonEscape(api.runtimePath) << "\",";
    AppendFunctionAvailability(os, api);
    os << ",\"adapter_count\":" << adapters.size() << ",\"adapters\":[";

    bool first = true;
    for (const auto& adapter : adapters)
    {
        if (!first)
            os << ",";
        first = false;

        int active = 0;
        bool activeValid = api.AdapterActiveGet && api.AdapterActiveGet(ctx.handle, adapter.iAdapterIndex, &active) == ADL_OK;

        int coreClock = 0;
        int memoryClock = 0;
        bool clockValid = api.ObservedClockGet &&
            api.ObservedClockGet(ctx.handle, adapter.iAdapterIndex, &coreClock, &memoryClock) == ADL_OK;

        int odSupported = 0;
        int odEnabled = 0;
        int odVersion = 0;
        bool odCapsValid = api.OverdriveCaps &&
            api.OverdriveCaps(ctx.handle, adapter.iAdapterIndex, &odSupported, &odEnabled, &odVersion) == ADL_OK;

        ADLODNPowerLimitSetting powerLimit = {};
        bool odnPowerValid = api.OverdriveNPowerLimitGet &&
            api.OverdriveNPowerLimitGet(ctx.handle, adapter.iAdapterIndex, &powerLimit) == ADL_OK;

        int od8Caps = 0;
        int od8InitFeatureCount = 0;
        ADLOD8SingleInitSetting* od8InitList = nullptr;
        bool od8InitValid = api.Overdrive8InitX2Get &&
            api.Overdrive8InitX2Get(ctx.handle, adapter.iAdapterIndex, &od8Caps, &od8InitFeatureCount, &od8InitList) == ADL_OK;
        if (od8InitList)
            AdlFree(od8InitList);

        int od8CurrentFeatureCount = 0;
        int* od8CurrentList = nullptr;
        bool od8CurrentValid = api.Overdrive8CurrentX2Get &&
            api.Overdrive8CurrentX2Get(ctx.handle, adapter.iAdapterIndex, &od8CurrentFeatureCount, &od8CurrentList) == ADL_OK;
        if (od8CurrentList)
            AdlFree(od8CurrentList);

        ADLPMLogSupportInfo pmLog = {};
        bool pmLogValid = api.PMLogSupportGet &&
            api.PMLogSupportGet(ctx.handle, adapter.iAdapterIndex, &pmLog) == ADL_OK;

        int pmShared = 0;
        bool pmSharedValid = api.PMLogShareMemorySupport &&
            api.PMLogShareMemorySupport(ctx.handle, adapter.iAdapterIndex, &pmShared, 0) == ADL_OK;

        int pmSensorTypeCount = 0;
        int* pmSensorTypes = nullptr;
        bool pmSensorTypesValid = api.PMLogSensorTypeSupportGet &&
            api.PMLogSensorTypeSupportGet(ctx.handle, adapter.iAdapterIndex, &pmSensorTypeCount, &pmSensorTypes) == ADL_OK;
        if (pmSensorTypes)
            AdlFree(pmSensorTypes);

        os << "{"
           << "\"index\":" << adapter.iAdapterIndex
           << ",\"name\":\"" << JsonEscape(adapter.strAdapterName) << "\""
           << ",\"display\":\"" << JsonEscape(adapter.strDisplayName) << "\""
           << ",\"vendor_id\":" << adapter.iVendorID
           << ",\"present\":" << adapter.iPresent
           << ",\"exist\":" << adapter.iExist
           << ",\"active_valid\":" << (activeValid ? "true" : "false")
           << ",\"active\":" << active
           << ",\"clock_valid\":" << (clockValid ? "true" : "false")
           << ",\"core_clock_10khz\":" << coreClock
           << ",\"memory_clock_10khz\":" << memoryClock
           << ",\"overdrive\":{\"caps_valid\":" << (odCapsValid ? "true" : "false")
           << ",\"supported\":" << odSupported
           << ",\"enabled\":" << odEnabled
           << ",\"version\":" << odVersion << "}"
           << ",\"overdrive_n_power\":{\"get_valid\":" << (odnPowerValid ? "true" : "false")
           << ",\"mode\":" << powerLimit.iMode
           << ",\"tdp_limit\":" << powerLimit.iTDPLimit
           << ",\"max_operating_temperature\":" << powerLimit.iMaxOperatingTemperature << "}"
           << ",\"overdrive8\":{\"init_valid\":" << (od8InitValid ? "true" : "false")
           << ",\"capabilities\":" << od8Caps
           << ",\"init_feature_count\":" << od8InitFeatureCount
           << ",\"current_valid\":" << (od8CurrentValid ? "true" : "false")
           << ",\"current_feature_count\":" << od8CurrentFeatureCount << "}"
           << ",\"pmlog\":{\"support_valid\":" << (pmLogValid ? "true" : "false")
           << ",\"sensor_count\":" << (pmLogValid ? CountPMLogSensors(pmLog) : 0)
           << ",\"shared_memory_valid\":" << (pmSharedValid ? "true" : "false")
           << ",\"shared_memory_supported\":" << pmShared
           << ",\"sensor_type_valid\":" << (pmSensorTypesValid ? "true" : "false")
           << ",\"sensor_type_count\":" << pmSensorTypeCount << "}"
           << "}";
    }

    os << "]}";
    std::cout << os.str() << std::endl;

    DestroyContext(api, ctx);
    UnloadAdl(api);
    return 0;
}

void PrintHelp()
{
    std::cout << "{\"schema\":\"powerpilot.amd_adl.v1\",\"command\":\"help\",\"ok\":true,"
                 "\"commands\":[\"probe\"]}" << std::endl;
}
}

int main(int argc, char** argv)
{
    std::string command = argc > 1 ? Lower(argv[1]) : "help";
    if (command == "help")
    {
        PrintHelp();
        return 0;
    }
    if (command == "probe")
        return Probe();

    std::cout << BaseJson(command, false, "Unknown command. Use 'help'.") << "}" << std::endl;
    return 1;
}
