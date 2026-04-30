// PowerPilot AMD ADLX helper.
//
// This helper is intentionally separate from the PureBasic controller.  It
// loads ADLX through AMD's helper code when the ADLX SDK is available at build
// time, but it never ships or copies AMD runtime DLLs.

#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>

#include <algorithm>
#include <cctype>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#ifdef POWERPILOT_ENABLE_ADLX_SDK
#include "SDK/ADLXHelper/Windows/Cpp/ADLXHelper.h"
#include "SDK/Include/IGPUManualGFXTuning.h"
#include "SDK/Include/IGPUManualPowerTuning.h"
#include "SDK/Include/IGPUPresetTuning.h"
#include "SDK/Include/IGPUTuning.h"
#include "SDK/Include/IPerformanceMonitoring3.h"
#include "SDK/Include/IPowerTuning1.h"
#include "SDK/Include/ISystem3.h"
#endif

namespace
{
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
                std::snprintf(buffer, sizeof(buffer), "\\u%04x", c);
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

int ToInt(const char* text, int fallback)
{
    if (!text || !*text)
        return fallback;
    char* end = nullptr;
    long value = std::strtol(text, &end, 10);
    if (!end || *end != '\0')
        return fallback;
    if (value < -1000000)
        value = -1000000;
    if (value > 1000000)
        value = 1000000;
    return static_cast<int>(value);
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

bool LocalAmdRuntimeDllPresent()
{
    std::string dir = ExeDirectory();
    return FileExists(dir + "\\amdadlx64.dll") || FileExists(dir + "\\amdadlx32.dll");
}

std::string LoadedAmdRuntimePath()
{
    HMODULE module = GetModuleHandleA("amdadlx64.dll");
    if (!module)
        module = GetModuleHandleA("amdadlx32.dll");
    if (!module)
        return "";

    char path[MAX_PATH] = {};
    DWORD len = GetModuleFileNameA(module, path, static_cast<DWORD>(sizeof(path)));
    if (len == 0 || len >= sizeof(path))
        return "";
    return path;
}

std::string AppDataPath()
{
    char* appData = nullptr;
    size_t len = 0;
    std::string root;
    if (_dupenv_s(&appData, &len, "APPDATA") == 0 && appData && *appData)
        root = appData;
    if (appData)
        free(appData);
    if (root.empty())
        root = ExeDirectory();

    std::string dir = root + "\\PowerPilot";
    CreateDirectoryA(dir.c_str(), nullptr);
    return dir + "\\amd_adlx_state.ini";
}

struct SavedState
{
    bool gfxSaved = false;
    int gfxMax = 0;

    bool powerSaved = false;
    int powerLimit = 0;

    bool tdcSaved = false;
    int tdcLimit = 0;
};

bool ReadBool(const std::string& value)
{
    std::string v = Lower(value);
    return v == "1" || v == "true" || v == "yes";
}

void LoadState(SavedState& state)
{
    std::ifstream in(AppDataPath());
    std::string line;
    while (std::getline(in, line))
    {
        size_t eq = line.find('=');
        if (eq == std::string::npos)
            continue;
        std::string key = line.substr(0, eq);
        std::string value = line.substr(eq + 1);
        int number = ToInt(value.c_str(), 0);

        if (key == "gfx_saved") state.gfxSaved = ReadBool(value);
        else if (key == "gfx_max") state.gfxMax = number;
        else if (key == "power_saved") state.powerSaved = ReadBool(value);
        else if (key == "power_limit") state.powerLimit = number;
        else if (key == "tdc_saved") state.tdcSaved = ReadBool(value);
        else if (key == "tdc_limit") state.tdcLimit = number;
    }
}

bool SaveState(const SavedState& state)
{
    std::ofstream out(AppDataPath(), std::ios::trunc);
    if (!out)
        return false;
    out << "gfx_saved=" << (state.gfxSaved ? 1 : 0) << "\n";
    out << "gfx_max=" << state.gfxMax << "\n";
    out << "power_saved=" << (state.powerSaved ? 1 : 0) << "\n";
    out << "power_limit=" << state.powerLimit << "\n";
    out << "tdc_saved=" << (state.tdcSaved ? 1 : 0) << "\n";
    out << "tdc_limit=" << state.tdcLimit << "\n";
    return static_cast<bool>(out);
}

void ClearState()
{
    DeleteFileA(AppDataPath().c_str());
}

std::string BaseJson(const std::string& command, bool ok, const std::string& error = "")
{
    std::ostringstream os;
    os << "{\"schema\":\"powerpilot.amd_adlx.v1\",\"command\":\"" << JsonEscape(command)
       << "\",\"ok\":" << (ok ? "true" : "false");
    if (!error.empty())
        os << ",\"error\":\"" << JsonEscape(error) << "\"";
    return os.str();
}

void PrintUnavailable(const std::string& command, const std::string& reason)
{
    std::cout << BaseJson(command, false, reason)
              << ",\"available\":false,\"sdk_compiled\":false,\"amd_gpu_present\":false,"
                 "\"features\":{\"metrics\":false,\"gfx_max\":false,"
                 "\"power_limit\":false,\"tdc_limit\":false}}"
              << std::endl;
}

#ifdef POWERPILOT_ENABLE_ADLX_SDK
using namespace adlx;

static ADLXHelper g_ADLXHelp;

struct AdlxContext
{
    bool initialized = false;
    std::string initMode;
    std::string runtimePath;
    IADLXGPUPtr gpu;
    IADLXGPUListPtr gpus;
    IADLXPerformanceMonitoringServicesPtr perf;
    IADLXGPUTuningServicesPtr tuning;
    IADLXPowerTuningServicesPtr powerTuning;

    ~AdlxContext()
    {
        powerTuning = nullptr;
        tuning = nullptr;
        perf = nullptr;
        gpu = nullptr;
        gpus = nullptr;
        if (initialized)
            g_ADLXHelp.Terminate();
    }
};

void ReleaseAdlx(AdlxContext& ctx)
{
    ctx.tuning = nullptr;
    ctx.powerTuning = nullptr;
    ctx.perf = nullptr;
    ctx.gpu = nullptr;
    ctx.gpus = nullptr;
    ctx.initMode.clear();
    ctx.runtimePath.clear();
    g_ADLXHelp.Terminate();
    ctx.initialized = false;
}

bool BindFirstGpu(AdlxContext& ctx, std::string& error)
{
    if (!g_ADLXHelp.GetSystemServices())
    {
        error = "ADLX system services unavailable.";
        return false;
    }

    ADLX_RESULT res = g_ADLXHelp.GetSystemServices()->GetGPUs(&ctx.gpus);
    if (ADLX_FAILED(res))
    {
        error = "ADLX GetGPUs failed: " + std::to_string(res);
        return false;
    }
    if (!ctx.gpus || ctx.gpus->Empty())
    {
        error = "No AMD GPU/APU exposed by ADLX.";
        return false;
    }

    res = ctx.gpus->At(0, &ctx.gpu);
    if (ADLX_FAILED(res) || !ctx.gpu)
    {
        error = "Failed to open first ADLX GPU: " + std::to_string(res);
        return false;
    }

    g_ADLXHelp.GetSystemServices()->GetPerformanceMonitoringServices(&ctx.perf);
    g_ADLXHelp.GetSystemServices()->GetGPUTuningServices(&ctx.tuning);
    IADLXSystem1Ptr system1;
    if (ADLX_SUCCEEDED(g_ADLXHelp.GetSystemServices()->QueryInterface(IADLXSystem1::IID(), reinterpret_cast<void**>(&system1))) && system1)
        system1->GetPowerTuningServices(&ctx.powerTuning);
    return true;
}

bool TryInitializeAdlx(AdlxContext& ctx, bool incompatibleDriver, std::string& detail)
{
    ADLX_RESULT res = incompatibleDriver
        ? g_ADLXHelp.InitializeWithIncompatibleDriver()
        : g_ADLXHelp.Initialize();
    if (ADLX_FAILED(res))
    {
        detail = std::string(incompatibleDriver ? "incompatible-driver" : "normal")
            + " initialization failed: " + std::to_string(res);
        g_ADLXHelp.Terminate();
        return false;
    }

    ctx.initialized = true;
    ctx.initMode = incompatibleDriver ? "incompatible_driver" : "normal";
    ctx.runtimePath = LoadedAmdRuntimePath();

    if (BindFirstGpu(ctx, detail))
        return true;

    if (!ctx.runtimePath.empty())
        detail += " Runtime: " + ctx.runtimePath;
    return false;
}

bool InitAdlx(AdlxContext& ctx, std::string& error)
{
    if (LocalAmdRuntimeDllPresent())
    {
        error = "Refusing to load local ADLX runtime DLL beside helper.";
        return false;
    }
    SetDllDirectoryA("");

    std::string normalDetail;
    if (TryInitializeAdlx(ctx, false, normalDetail))
        return true;

    ReleaseAdlx(ctx);

    std::string incompatibleDetail;
    if (TryInitializeAdlx(ctx, true, incompatibleDetail))
        return true;

    ReleaseAdlx(ctx);
    error = "ADLX unavailable. normal: " + normalDetail
        + "; incompatible_driver: " + incompatibleDetail;
    return false;
}

std::string GpuName(const IADLXGPUPtr& gpu)
{
    const char* name = nullptr;
    if (gpu && ADLX_SUCCEEDED(gpu->Name(&name)) && name)
        return name;
    return "";
}

std::string GpuVendor(const IADLXGPUPtr& gpu)
{
    const char* vendor = nullptr;
    if (gpu && ADLX_SUCCEEDED(gpu->VendorId(&vendor)) && vendor)
        return vendor;
    return "";
}

bool GetManualGfx(const AdlxContext& ctx, IADLXManualGraphicsTuning2Ptr& gfx)
{
    if (!ctx.tuning || !ctx.gpu)
        return false;

    adlx_bool supported = false;
    if (ADLX_FAILED(ctx.tuning->IsSupportedManualGFXTuning(ctx.gpu, &supported)) || !supported)
        return false;

    IADLXInterfacePtr raw;
    if (ADLX_FAILED(ctx.tuning->GetManualGFXTuning(ctx.gpu, &raw)) || !raw)
        return false;

    gfx = IADLXManualGraphicsTuning2Ptr(raw);
    return static_cast<bool>(gfx);
}

bool GetManualPower(const AdlxContext& ctx, IADLXManualPowerTuningPtr& power)
{
    if (!ctx.tuning || !ctx.gpu)
        return false;

    adlx_bool supported = false;
    if (ADLX_FAILED(ctx.tuning->IsSupportedManualPowerTuning(ctx.gpu, &supported)) || !supported)
        return false;

    IADLXInterfacePtr raw;
    if (ADLX_FAILED(ctx.tuning->GetManualPowerTuning(ctx.gpu, &raw)) || !raw)
        return false;

    power = IADLXManualPowerTuningPtr(raw);
    return static_cast<bool>(power);
}

bool GetPresetTuning(const AdlxContext& ctx, IADLXGPUPresetTuningPtr& preset)
{
    if (!ctx.tuning || !ctx.gpu)
        return false;

    adlx_bool supported = false;
    if (ADLX_FAILED(ctx.tuning->IsSupportedPresetTuning(ctx.gpu, &supported)) || !supported)
        return false;

    IADLXInterfacePtr raw;
    if (ADLX_FAILED(ctx.tuning->GetPresetTuning(ctx.gpu, &raw)) || !raw)
        return false;

    preset = IADLXGPUPresetTuningPtr(raw);
    return static_cast<bool>(preset);
}

struct FeatureSet
{
    bool metrics = false;
    bool gfxMax = false;
    bool powerLimit = false;
    bool tdcLimit = false;
    bool presetPowerSaver = false;
    bool presetQuiet = false;
    bool presetBalanced = false;
    bool smartShiftMax = false;
    bool smartShiftEco = false;
};

FeatureSet QueryFeatures(const AdlxContext& ctx)
{
    FeatureSet f;

    if (ctx.perf && ctx.gpu)
    {
        IADLXGPUMetricsSupportPtr support;
        f.metrics = ADLX_SUCCEEDED(ctx.perf->GetSupportedGPUMetrics(ctx.gpu, &support)) && support;
    }

    IADLXManualGraphicsTuning2Ptr gfx;
    if (GetManualGfx(ctx, gfx))
    {
        ADLX_IntRange range = {};
        f.gfxMax = ADLX_SUCCEEDED(gfx->GetGPUMaxFrequencyRange(&range));
    }

    IADLXManualPowerTuningPtr power;
    if (GetManualPower(ctx, power))
    {
        ADLX_IntRange range = {};
        f.powerLimit = ADLX_SUCCEEDED(power->GetPowerLimitRange(&range));
        adlx_bool supportedTdc = false;
        f.tdcLimit = ADLX_SUCCEEDED(power->IsSupportedTDCLimit(&supportedTdc)) && supportedTdc;
    }

    if (ctx.powerTuning)
    {
        IADLXSmartShiftMaxPtr ssm;
        adlx_bool supported = false;
        if (ADLX_SUCCEEDED(ctx.powerTuning->GetSmartShiftMax(&ssm)) && ssm)
            f.smartShiftMax = ADLX_SUCCEEDED(ssm->IsSupported(&supported)) && supported;

        IADLXPowerTuningServices1Ptr powerTuning1;
        if (ADLX_SUCCEEDED(ctx.powerTuning->QueryInterface(IADLXPowerTuningServices1::IID(), reinterpret_cast<void**>(&powerTuning1))) && powerTuning1)
        {
            IADLXSmartShiftEcoPtr eco;
            supported = false;
            if (ADLX_SUCCEEDED(powerTuning1->GetSmartShiftEco(&eco)) && eco)
                f.smartShiftEco = ADLX_SUCCEEDED(eco->IsSupported(&supported)) && supported;
        }
    }

    IADLXGPUPresetTuningPtr preset;
    if (GetPresetTuning(ctx, preset))
    {
        adlx_bool supported = false;
        f.presetPowerSaver = ADLX_SUCCEEDED(preset->IsSupportedPowerSaver(&supported)) && supported;
        supported = false;
        f.presetQuiet = ADLX_SUCCEEDED(preset->IsSupportedQuiet(&supported)) && supported;
        supported = false;
        f.presetBalanced = ADLX_SUCCEEDED(preset->IsSupportedBalanced(&supported)) && supported;
    }

    return f;
}

void AppendFeatures(std::ostringstream& os, const FeatureSet& f)
{
    os << "\"features\":{\"metrics\":" << (f.metrics ? "true" : "false")
       << ",\"gfx_max\":" << (f.gfxMax ? "true" : "false")
       << ",\"power_limit\":" << (f.powerLimit ? "true" : "false")
       << ",\"tdc_limit\":" << (f.tdcLimit ? "true" : "false")
       << ",\"preset_power_saver\":" << (f.presetPowerSaver ? "true" : "false")
       << ",\"preset_quiet\":" << (f.presetQuiet ? "true" : "false")
       << ",\"preset_balanced\":" << (f.presetBalanced ? "true" : "false")
       << ",\"smartshift_max\":" << (f.smartShiftMax ? "true" : "false")
       << ",\"smartshift_eco\":" << (f.smartShiftEco ? "true" : "false") << "}";
}

int Probe(const std::string& command)
{
    AdlxContext ctx;
    std::string error;
    if (!InitAdlx(ctx, error))
    {
        std::cout << BaseJson(command, false, error)
                  << ",\"available\":false,\"sdk_compiled\":true,\"amd_gpu_present\":false}" << std::endl;
        return 2;
    }

    FeatureSet f = QueryFeatures(ctx);
    std::ostringstream os;
    os << BaseJson(command, true)
       << ",\"available\":true,\"sdk_compiled\":true,\"amd_gpu_present\":true"
       << ",\"init_mode\":\"" << JsonEscape(ctx.initMode) << "\""
       << ",\"runtime_path\":\"" << JsonEscape(ctx.runtimePath) << "\""
       << ",\"gpu\":{\"index\":0,\"name\":\"" << JsonEscape(GpuName(ctx.gpu))
       << "\",\"vendor_id\":\"" << JsonEscape(GpuVendor(ctx.gpu)) << "\"},";
    AppendFeatures(os, f);
    os << "}";
    std::cout << os.str() << std::endl;
    return 0;
}

int Metrics(const std::string& command)
{
    AdlxContext ctx;
    std::string error;
    if (!InitAdlx(ctx, error))
    {
        std::cout << BaseJson(command, false, error) << ",\"available\":false}" << std::endl;
        return 2;
    }
    if (!ctx.perf)
    {
        std::cout << BaseJson(command, false, "Performance monitoring service unavailable.")
                  << ",\"available\":true}" << std::endl;
        return 2;
    }

    IADLXGPUMetricsSupportPtr support;
    IADLXGPUMetricsPtr metrics;
    ADLX_RESULT supportRes = ctx.perf->GetSupportedGPUMetrics(ctx.gpu, &support);
    ADLX_RESULT metricRes = ctx.perf->GetCurrentGPUMetrics(ctx.gpu, &metrics);
    if (ADLX_FAILED(supportRes) || ADLX_FAILED(metricRes) || !support || !metrics)
    {
        std::cout << BaseJson(command, false, "GPU metrics are unavailable.")
                  << ",\"available\":true}" << std::endl;
        return 2;
    }

    bool usageValid = false, clockValid = false, powerValid = false, tempValid = false;
    adlx_double usage = 0.0, power = 0.0, temp = 0.0;
    adlx_int clock = 0;
    adlx_bool supported = false;

    if (ADLX_SUCCEEDED(support->IsSupportedGPUUsage(&supported)) && supported)
        usageValid = ADLX_SUCCEEDED(metrics->GPUUsage(&usage));
    if (ADLX_SUCCEEDED(support->IsSupportedGPUClockSpeed(&supported)) && supported)
        clockValid = ADLX_SUCCEEDED(metrics->GPUClockSpeed(&clock));
    if (ADLX_SUCCEEDED(support->IsSupportedGPUPower(&supported)) && supported)
        powerValid = ADLX_SUCCEEDED(metrics->GPUPower(&power));
    if (ADLX_SUCCEEDED(support->IsSupportedGPUTemperature(&supported)) && supported)
        tempValid = ADLX_SUCCEEDED(metrics->GPUTemperature(&temp));

    std::ostringstream os;
    os << BaseJson(command, true) << ",\"available\":true,\"gpu\":{\"index\":0,\"name\":\""
       << JsonEscape(GpuName(ctx.gpu)) << "\"},\"metrics\":{"
       << "\"usage_valid\":" << (usageValid ? "true" : "false") << ",\"usage_percent\":" << usage
       << ",\"clock_valid\":" << (clockValid ? "true" : "false") << ",\"clock_mhz\":" << clock
       << ",\"power_valid\":" << (powerValid ? "true" : "false") << ",\"power_w\":" << power
       << ",\"temperature_valid\":" << (tempValid ? "true" : "false") << ",\"temperature_c\":" << temp
       << "}}";
    std::cout << os.str() << std::endl;
    return 0;
}

int GfxGet(const std::string& command)
{
    AdlxContext ctx;
    std::string error;
    if (!InitAdlx(ctx, error))
    {
        std::cout << BaseJson(command, false, error) << ",\"available\":false}" << std::endl;
        return 2;
    }
    IADLXManualGraphicsTuning2Ptr gfx;
    if (!GetManualGfx(ctx, gfx))
    {
        std::cout << BaseJson(command, false, "Manual graphics tuning is not supported.")
                  << ",\"available\":true,\"supported\":false}" << std::endl;
        return 2;
    }
    adlx_int maxFreq = 0;
    ADLX_IntRange range = {};
    gfx->GetGPUMaxFrequency(&maxFreq);
    gfx->GetGPUMaxFrequencyRange(&range);
    std::cout << BaseJson(command, true) << ",\"available\":true,\"supported\":true,\"max_mhz\":"
              << maxFreq << ",\"range\":{\"min\":" << range.minValue << ",\"max\":"
              << range.maxValue << ",\"step\":" << range.step << "}}" << std::endl;
    return 0;
}

int GfxSetMax(const std::string& command, int mhz)
{
    AdlxContext ctx;
    std::string error;
    if (!InitAdlx(ctx, error))
    {
        std::cout << BaseJson(command, false, error) << ",\"available\":false}" << std::endl;
        return 2;
    }
    IADLXManualGraphicsTuning2Ptr gfx;
    if (!GetManualGfx(ctx, gfx))
    {
        std::cout << BaseJson(command, false, "Manual graphics tuning is not supported.")
                  << ",\"available\":true,\"supported\":false}" << std::endl;
        return 2;
    }

    ADLX_IntRange range = {};
    gfx->GetGPUMaxFrequencyRange(&range);
    mhz = std::max(range.minValue, std::min(mhz, range.maxValue));

    SavedState state;
    LoadState(state);
    if (!state.gfxSaved)
    {
        adlx_int oldMax = 0;
        gfx->GetGPUMaxFrequency(&oldMax);
        state.gfxSaved = true;
        state.gfxMax = oldMax;
        if (!SaveState(state))
        {
            std::cout << BaseJson(command, false, "Unable to save previous GPU max-frequency setting; refusing to change AMD driver settings.")
                      << ",\"available\":true,\"supported\":true,\"changed\":false}" << std::endl;
            return 3;
        }
    }

    ADLX_RESULT res = gfx->SetGPUMaxFrequency(mhz);
    std::cout << BaseJson(command, ADLX_SUCCEEDED(res), ADLX_FAILED(res) ? "Failed to set GPU max frequency." : "")
              << ",\"available\":true,\"supported\":true,\"changed\":" << (ADLX_SUCCEEDED(res) ? "true" : "false")
              << ",\"max_mhz\":" << mhz << "}" << std::endl;
    return ADLX_SUCCEEDED(res) ? 0 : 3;
}

int PowerGet(const std::string& command)
{
    AdlxContext ctx;
    std::string error;
    if (!InitAdlx(ctx, error))
    {
        std::cout << BaseJson(command, false, error) << ",\"available\":false}" << std::endl;
        return 2;
    }
    IADLXManualPowerTuningPtr power;
    if (!GetManualPower(ctx, power))
    {
        std::cout << BaseJson(command, false, "Manual power tuning is not supported.")
                  << ",\"available\":true,\"supported\":false}" << std::endl;
        return 2;
    }
    adlx_int limit = 0;
    ADLX_IntRange range = {};
    power->GetPowerLimit(&limit);
    power->GetPowerLimitRange(&range);
    std::cout << BaseJson(command, true) << ",\"available\":true,\"supported\":true,\"power_limit\":"
              << limit << ",\"range\":{\"min\":" << range.minValue << ",\"max\":"
              << range.maxValue << ",\"step\":" << range.step << "}}" << std::endl;
    return 0;
}

int PowerSet(const std::string& command, int limit)
{
    AdlxContext ctx;
    std::string error;
    if (!InitAdlx(ctx, error))
    {
        std::cout << BaseJson(command, false, error) << ",\"available\":false}" << std::endl;
        return 2;
    }
    IADLXManualPowerTuningPtr power;
    if (!GetManualPower(ctx, power))
    {
        std::cout << BaseJson(command, false, "Manual power tuning is not supported.")
                  << ",\"available\":true,\"supported\":false}" << std::endl;
        return 2;
    }

    ADLX_IntRange range = {};
    power->GetPowerLimitRange(&range);
    limit = std::max(range.minValue, std::min(limit, range.maxValue));

    SavedState state;
    LoadState(state);
    if (!state.powerSaved)
    {
        adlx_int oldLimit = 0;
        power->GetPowerLimit(&oldLimit);
        state.powerSaved = true;
        state.powerLimit = oldLimit;
        if (!SaveState(state))
        {
            std::cout << BaseJson(command, false, "Unable to save previous GPU power-limit setting; refusing to change AMD driver settings.")
                      << ",\"available\":true,\"supported\":true,\"changed\":false}" << std::endl;
            return 3;
        }
    }

    ADLX_RESULT res = power->SetPowerLimit(limit);
    std::cout << BaseJson(command, ADLX_SUCCEEDED(res), ADLX_FAILED(res) ? "Failed to set GPU power limit." : "")
              << ",\"available\":true,\"supported\":true,\"changed\":" << (ADLX_SUCCEEDED(res) ? "true" : "false")
              << ",\"power_limit\":" << limit << "}" << std::endl;
    return ADLX_SUCCEEDED(res) ? 0 : 3;
}

int SmartShiftGet(const std::string& command)
{
    AdlxContext ctx;
    std::string error;
    if (!InitAdlx(ctx, error))
    {
        std::cout << BaseJson(command, false, error) << ",\"available\":false}" << std::endl;
        return 2;
    }
    if (!ctx.powerTuning)
    {
        std::cout << BaseJson(command, false, "Power tuning service unavailable.")
                  << ",\"available\":true,\"supported\":false}" << std::endl;
        return 2;
    }

    IADLXSmartShiftMaxPtr ssm;
    adlx_bool ssmSupported = false;
    adlx_bool ecoSupported = false;
    adlx_bool ecoEnabled = false;
    adlx_bool ecoInactive = false;
    ADLX_SSM_BIAS_MODE mode = SSM_BIAS_AUTO;
    ADLX_SMARTSHIFT_ECO_INACTIVE_REASON ecoReason = INACTIVE_REASON_UNKNOWN;
    ADLX_IntRange biasRange = {};
    adlx_int bias = 0;

    bool ssmIface = ADLX_SUCCEEDED(ctx.powerTuning->GetSmartShiftMax(&ssm)) && ssm;
    bool ssmModeValid = false;
    bool ssmRangeValid = false;
    bool ssmBiasValid = false;
    if (ssmIface)
    {
        ssm->IsSupported(&ssmSupported);
        ssmModeValid = ADLX_SUCCEEDED(ssm->GetBiasMode(&mode));
        ssmRangeValid = ADLX_SUCCEEDED(ssm->GetBiasRange(&biasRange));
        ssmBiasValid = ADLX_SUCCEEDED(ssm->GetBias(&bias));
    }

    bool ecoIface = false;
    bool ecoEnabledValid = false;
    bool ecoInactiveValid = false;
    bool ecoReasonValid = false;
    IADLXPowerTuningServices1Ptr powerTuning1;
    if (ADLX_SUCCEEDED(ctx.powerTuning->QueryInterface(IADLXPowerTuningServices1::IID(), reinterpret_cast<void**>(&powerTuning1))) && powerTuning1)
    {
        IADLXSmartShiftEcoPtr eco;
        ecoIface = ADLX_SUCCEEDED(powerTuning1->GetSmartShiftEco(&eco)) && eco;
        if (ecoIface)
        {
            eco->IsSupported(&ecoSupported);
            ecoEnabledValid = ADLX_SUCCEEDED(eco->IsEnabled(&ecoEnabled));
            ecoInactiveValid = ADLX_SUCCEEDED(eco->IsInactive(&ecoInactive));
            ecoReasonValid = ADLX_SUCCEEDED(eco->GetInactiveReason(&ecoReason));
        }
    }

    std::ostringstream os;
    os << BaseJson(command, true)
       << ",\"available\":true"
       << ",\"smartshift_max\":{\"interface\":" << (ssmIface ? "true" : "false")
       << ",\"supported\":" << (ssmSupported ? "true" : "false")
       << ",\"mode_valid\":" << (ssmModeValid ? "true" : "false")
       << ",\"mode\":" << static_cast<int>(mode)
       << ",\"bias_valid\":" << (ssmBiasValid ? "true" : "false")
       << ",\"bias\":" << bias
       << ",\"range_valid\":" << (ssmRangeValid ? "true" : "false")
       << ",\"range\":{\"min\":" << biasRange.minValue << ",\"max\":" << biasRange.maxValue
       << ",\"step\":" << biasRange.step << "}}"
       << ",\"smartshift_eco\":{\"interface\":" << (ecoIface ? "true" : "false")
       << ",\"supported\":" << (ecoSupported ? "true" : "false")
       << ",\"enabled_valid\":" << (ecoEnabledValid ? "true" : "false")
       << ",\"enabled\":" << (ecoEnabled ? "true" : "false")
       << ",\"inactive_valid\":" << (ecoInactiveValid ? "true" : "false")
       << ",\"inactive\":" << (ecoInactive ? "true" : "false")
       << ",\"inactive_reason_valid\":" << (ecoReasonValid ? "true" : "false")
       << ",\"inactive_reason\":" << static_cast<int>(ecoReason) << "}}";
    std::cout << os.str() << std::endl;
    return 0;
}

int PresetGet(const std::string& command)
{
    AdlxContext ctx;
    std::string error;
    if (!InitAdlx(ctx, error))
    {
        std::cout << BaseJson(command, false, error) << ",\"available\":false}" << std::endl;
        return 2;
    }

    IADLXGPUPresetTuningPtr preset;
    if (!GetPresetTuning(ctx, preset))
    {
        std::cout << BaseJson(command, false, "GPU preset tuning is not supported.")
                  << ",\"available\":true,\"supported\":false}" << std::endl;
        return 2;
    }

    adlx_bool supportedPowerSaver = false;
    adlx_bool supportedQuiet = false;
    adlx_bool supportedBalanced = false;
    adlx_bool currentPowerSaver = false;
    adlx_bool currentQuiet = false;
    adlx_bool currentBalanced = false;

    preset->IsSupportedPowerSaver(&supportedPowerSaver);
    preset->IsSupportedQuiet(&supportedQuiet);
    preset->IsSupportedBalanced(&supportedBalanced);
    preset->IsCurrentPowerSaver(&currentPowerSaver);
    preset->IsCurrentQuiet(&currentQuiet);
    preset->IsCurrentBalanced(&currentBalanced);

    std::ostringstream os;
    os << BaseJson(command, true)
       << ",\"available\":true,\"supported\":true"
       << ",\"power_saver\":{\"supported\":" << (supportedPowerSaver ? "true" : "false")
       << ",\"current\":" << (currentPowerSaver ? "true" : "false") << "}"
       << ",\"quiet\":{\"supported\":" << (supportedQuiet ? "true" : "false")
       << ",\"current\":" << (currentQuiet ? "true" : "false") << "}"
       << ",\"balanced\":{\"supported\":" << (supportedBalanced ? "true" : "false")
       << ",\"current\":" << (currentBalanced ? "true" : "false") << "}}";
    std::cout << os.str() << std::endl;
    return 0;
}

int Restore(const std::string& command)
{
    AdlxContext ctx;
    std::string error;
    if (!InitAdlx(ctx, error))
    {
        std::cout << BaseJson(command, false, error) << ",\"available\":false}" << std::endl;
        return 2;
    }

    SavedState state;
    LoadState(state);
    bool any = false;
    bool ok = true;

    if (state.gfxSaved)
    {
        IADLXManualGraphicsTuning2Ptr gfx;
        if (GetManualGfx(ctx, gfx))
        {
            ADLX_RESULT res = gfx->SetGPUMaxFrequency(state.gfxMax);
            ok = ok && ADLX_SUCCEEDED(res);
            any = true;
        }
    }

    if (state.powerSaved)
    {
        IADLXManualPowerTuningPtr power;
        if (GetManualPower(ctx, power))
        {
            ADLX_RESULT res = power->SetPowerLimit(state.powerLimit);
            ok = ok && ADLX_SUCCEEDED(res);
            any = true;
        }
    }

    if (ok)
        ClearState();

    std::cout << BaseJson(command, ok, ok ? "" : "One or more restore operations failed.")
              << ",\"available\":true,\"restored\":" << (any ? "true" : "false")
              << ",\"state_cleared\":" << (ok ? "true" : "false") << "}" << std::endl;
    return ok ? 0 : 3;
}
#endif

void PrintHelp()
{
    std::cout
        << "{\"schema\":\"powerpilot.amd_adlx.v1\",\"command\":\"help\",\"ok\":true,"
           "\"commands\":[\"probe\",\"metrics\",\"gfx_get\",\"gfx_set_max <mhz>\","
           "\"power_get\",\"power_set <value>\",\"preset_get\",\"smartshift_get\",\"restore\"]}" << std::endl;
}
}

int main(int argc, char** argv)
{
    std::string command = argc > 1 ? Lower(argv[1]) : "help";

#ifndef POWERPILOT_ENABLE_ADLX_SDK
    if (command == "help")
    {
        PrintHelp();
        return 0;
    }
    PrintUnavailable(command, "Helper was built without the AMD ADLX SDK. Set ADLX_SDK_DIR and rebuild to enable ADLX calls.");
    return 2;
#else
    if (command == "help")
    {
        PrintHelp();
        return 0;
    }
    if (command == "probe")
        return Probe(command);
    if (command == "metrics")
        return Metrics(command);
    if (command == "gfx_get")
        return GfxGet(command);
    if (command == "gfx_set_max")
        return GfxSetMax(command, argc > 2 ? ToInt(argv[2], 800) : 800);
    if (command == "power_get")
        return PowerGet(command);
    if (command == "power_set")
        return PowerSet(command, argc > 2 ? ToInt(argv[2], 0) : 0);
    if (command == "preset_get")
        return PresetGet(command);
    if (command == "smartshift_get")
        return SmartShiftGet(command);
    if (command == "restore")
        return Restore(command);

    std::cout << BaseJson(command, false, "Unknown command.") << "}" << std::endl;
    return 1;
#endif
}
