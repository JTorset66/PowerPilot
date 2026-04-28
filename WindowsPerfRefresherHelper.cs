using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Diagnostics;
using System.IO;
using System.Management;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

internal static class WindowsPerfRefresherHelper
{
    private sealed class RefresherContext
    {
        public dynamic Refresher;
        public dynamic MemoryItem;
        public string[] GpuDevices;
        public int GpuDeviceRefreshTick;
        public int CaptureCount;

        public void Dispose()
        {
            ReleaseComObjectQuietly((object)MemoryItem);
            ReleaseComObjectQuietly((object)Refresher);
            MemoryItem = null;
            Refresher = null;
            GpuDevices = null;
        }
    }

    private sealed class Sample
    {
        public bool GpuMemorySeen;
        public string GpuMemorySensor = "Windows WMI performance / GPU Adapter Memory";
        public double GpuMemoryMb;
        public int GpuMemoryPriority = -1;
        public bool GpuSharedMemorySeen;
        public string GpuSharedMemorySensor = "Windows WMI performance / GPU Adapter Memory / Shared Usage";
        public double GpuSharedMemoryMb;
        public readonly List<string> GpuDevices = new List<string>();
    }

    private static readonly CultureInfo Invariant = CultureInfo.InvariantCulture;
    private const int CrSuccess = 0;
    private const int CrBufferSmall = 26;
    private const int GpuDeviceRefreshIntervalMs = 60000;
    private const int MaxParentDepth = 12;
    private const int ContextRecycleSamples = 120;
    private const long ContextRecyclePrivateBytes = 128L * 1024L * 1024L;

    [StructLayout(LayoutKind.Sequential)]
    private struct DevPropKey
    {
        public Guid fmtid;
        public uint pid;

        public DevPropKey(string fmtidText, uint propertyId)
        {
            fmtid = new Guid(fmtidText);
            pid = propertyId;
        }
    }

    [DllImport("cfgmgr32.dll", CharSet = CharSet.Unicode)]
    private static extern int CM_Locate_DevNodeW(out uint devInst, string deviceId, int flags);

    [DllImport("cfgmgr32.dll", CharSet = CharSet.Unicode)]
    private static extern int CM_Get_Parent(out uint parentDevInst, uint devInst, int flags);

    [DllImport("cfgmgr32.dll", CharSet = CharSet.Unicode)]
    private static extern int CM_Get_Device_ID_Size(out int length, uint devInst, int flags);

    [DllImport("cfgmgr32.dll", CharSet = CharSet.Unicode)]
    private static extern int CM_Get_Device_IDW(uint devInst, StringBuilder buffer, int bufferLength, int flags);

    [DllImport("cfgmgr32.dll", CharSet = CharSet.Unicode)]
    private static extern int CM_Get_DevNode_PropertyW(uint devInst, ref DevPropKey propertyKey, out uint propertyType, byte[] buffer, ref uint bufferSize, int flags);

    private static readonly DevPropKey DevPropName = new DevPropKey("b725f130-47ef-101a-a5f1-02608c9eebac", 10);
    private static readonly DevPropKey DevPropDeviceDesc = new DevPropKey("a45c254e-df1c-4efd-8020-67d146a850e0", 2);
    private static readonly DevPropKey DevPropFriendlyName = new DevPropKey("a45c254e-df1c-4efd-8020-67d146a850e0", 14);
    private static readonly DevPropKey DevPropLocationInfo = new DevPropKey("a45c254e-df1c-4efd-8020-67d146a850e0", 15);
    private static readonly DevPropKey DevPropLocationPaths = new DevPropKey("a45c254e-df1c-4efd-8020-67d146a850e0", 37);

    private static bool HasArg(string[] args, string expected)
    {
        if (args == null)
            return false;

        foreach (var arg in args)
        {
            if (string.Equals(arg, expected, StringComparison.OrdinalIgnoreCase))
                return true;
        }

        return false;
    }

    private static int ParseIntervalMs(string[] args)
    {
        int intervalMs;

        if (args == null)
            return 1000;

        for (int i = 0; i < args.Length; i++)
        {
            if (!string.Equals(args[i], "--interval-ms", StringComparison.OrdinalIgnoreCase) || i + 1 >= args.Length)
                continue;

            if (int.TryParse(args[i + 1], NumberStyles.Integer, Invariant, out intervalMs))
                return Math.Max(250, Math.Min(intervalMs, 10000));
        }

        return 1000;
    }

    private static int ParseParentPid(string[] args)
    {
        int parentPid;

        if (args == null)
            return 0;

        for (int i = 0; i < args.Length; i++)
        {
            if (!string.Equals(args[i], "--parent-pid", StringComparison.OrdinalIgnoreCase) || i + 1 >= args.Length)
                continue;

            if (int.TryParse(args[i + 1], NumberStyles.Integer, Invariant, out parentPid))
                return Math.Max(0, parentPid);
        }

        return 0;
    }

    private static bool ParentStillRunning(int parentPid)
    {
        if (parentPid <= 0)
            return true;

        try
        {
            using (var process = Process.GetProcessById(parentPid))
                return !process.HasExited;
        }
        catch
        {
            return false;
        }
    }

    private static void ReleaseComObjectQuietly(object value)
    {
        if (value == null)
            return;

        try
        {
            if (Marshal.IsComObject(value))
                Marshal.FinalReleaseComObject(value);
        }
        catch
        {
        }
    }

    private static void CollectGarbageAfterComRelease()
    {
        GC.Collect();
        GC.WaitForPendingFinalizers();
        GC.Collect();
    }

    private static string Sanitize(string text)
    {
        return (text ?? string.Empty).Replace("|", "/").Replace("\r", " ").Replace("\n", " ").Trim();
    }

    private static string TrimNulls(string text)
    {
        return (text ?? string.Empty).TrimEnd('\0', ' ');
    }

    private static string ReadString(dynamic obj, string propertyName)
    {
        try
        {
            var value = obj.GetType().InvokeMember(propertyName, System.Reflection.BindingFlags.GetProperty, null, obj, null);
            return Convert.ToString(value, Invariant) ?? string.Empty;
        }
        catch
        {
            return string.Empty;
        }
    }

    private static double ReadDouble(dynamic obj, string propertyName)
    {
        try
        {
            var value = obj.GetType().InvokeMember(propertyName, System.Reflection.BindingFlags.GetProperty, null, obj, null);
            if (value == null)
                return 0.0;
            return Convert.ToDouble(value, Invariant);
        }
        catch
        {
            return 0.0;
        }
    }

    private static string ReadManagementString(ManagementObject obj, string propertyName)
    {
        try
        {
            var value = obj[propertyName];
            return Convert.ToString(value, Invariant) ?? string.Empty;
        }
        catch
        {
            return string.Empty;
        }
    }

    private static bool ReadManagementBool(ManagementObject obj, string propertyName, bool defaultValue)
    {
        try
        {
            var value = obj[propertyName];
            if (value == null)
                return defaultValue;

            return Convert.ToBoolean(value);
        }
        catch
        {
            return defaultValue;
        }
    }

    private static string ReadDevNodeStringProperty(uint devInst, DevPropKey propertyKey)
    {
        byte[] buffer = new byte[512];
        uint bufferSize = (uint)buffer.Length;
        uint propertyType;
        int result = CM_Get_DevNode_PropertyW(devInst, ref propertyKey, out propertyType, buffer, ref bufferSize, 0);

        if (result == CrBufferSmall && bufferSize > 0)
        {
            buffer = new byte[bufferSize];
            result = CM_Get_DevNode_PropertyW(devInst, ref propertyKey, out propertyType, buffer, ref bufferSize, 0);
        }

        if (result != CrSuccess || bufferSize < 2)
            return string.Empty;

        return Sanitize(TrimNulls(Encoding.Unicode.GetString(buffer, 0, (int)bufferSize)));
    }

    private static string[] ReadDevNodeStringListProperty(uint devInst, DevPropKey propertyKey)
    {
        byte[] buffer = new byte[1024];
        uint bufferSize = (uint)buffer.Length;
        uint propertyType;
        int result = CM_Get_DevNode_PropertyW(devInst, ref propertyKey, out propertyType, buffer, ref bufferSize, 0);

        if (result == CrBufferSmall && bufferSize > 0)
        {
            buffer = new byte[bufferSize];
            result = CM_Get_DevNode_PropertyW(devInst, ref propertyKey, out propertyType, buffer, ref bufferSize, 0);
        }

        if (result != CrSuccess || bufferSize < 4)
            return new string[0];

        var combined = TrimNulls(Encoding.Unicode.GetString(buffer, 0, (int)bufferSize));
        var parts = combined.Split(new[] { '\0' }, StringSplitOptions.RemoveEmptyEntries);
        for (int i = 0; i < parts.Length; i++)
            parts[i] = Sanitize(parts[i]);
        return parts;
    }

    private static string ReadDevNodeId(uint devInst)
    {
        int length;
        if (CM_Get_Device_ID_Size(out length, devInst, 0) != CrSuccess || length < 0)
            return string.Empty;

        var buffer = new StringBuilder(length + 2);
        if (CM_Get_Device_IDW(devInst, buffer, buffer.Capacity, 0) != CrSuccess)
            return string.Empty;

        return Sanitize(buffer.ToString());
    }

    private static string ReadDevNodeName(uint devInst)
    {
        var name = ReadDevNodeStringProperty(devInst, DevPropFriendlyName);
        if (string.IsNullOrWhiteSpace(name))
            name = ReadDevNodeStringProperty(devInst, DevPropName);
        if (string.IsNullOrWhiteSpace(name))
            name = ReadDevNodeStringProperty(devInst, DevPropDeviceDesc);

        var separator = name.LastIndexOf(';');
        if (separator >= 0 && separator + 1 < name.Length)
            name = name.Substring(separator + 1).Trim();

        return Sanitize(name);
    }

    private static bool ContainsAny(string text, params string[] needles)
    {
        if (string.IsNullOrWhiteSpace(text) || needles == null)
            return false;

        foreach (var needle in needles)
        {
            if (!string.IsNullOrWhiteSpace(needle) && text.IndexOf(needle, StringComparison.OrdinalIgnoreCase) >= 0)
                return true;
        }

        return false;
    }

    private static void CollectTransportHints(string text, ref bool sawUsb4, ref bool sawThunderbolt, ref bool sawOculink, ref bool sawGenericExternal)
    {
        if (string.IsNullOrWhiteSpace(text))
            return;

        if (ContainsAny(text, "usb4", "usb 4", "usb4_ms_cm", "root_device_router"))
            sawUsb4 = true;
        if (ContainsAny(text, "thunderbolt", "tapex creek", "goshen ridge", "maple ridge", "bartlett lake"))
            sawThunderbolt = true;
        if (ContainsAny(text, "oculink", "ocu link", "external pcie", "external pci express"))
            sawOculink = true;
        if (ContainsAny(text, "egpu", "external gpu", "external graphics", "external display adapter", "egfx"))
            sawGenericExternal = true;
    }

    private static string DetectExternalTransport(string instanceId)
    {
        uint current;

        if (string.IsNullOrWhiteSpace(instanceId) || CM_Locate_DevNodeW(out current, instanceId, 0) != CrSuccess)
            return string.Empty;

        bool sawUsb4 = false;
        bool sawThunderbolt = false;
        bool sawOculink = false;
        bool sawGenericExternal = false;

        for (int depth = 0; depth < MaxParentDepth; depth++)
        {
            CollectTransportHints(ReadDevNodeId(current), ref sawUsb4, ref sawThunderbolt, ref sawOculink, ref sawGenericExternal);
            CollectTransportHints(ReadDevNodeName(current), ref sawUsb4, ref sawThunderbolt, ref sawOculink, ref sawGenericExternal);
            CollectTransportHints(ReadDevNodeStringProperty(current, DevPropLocationInfo), ref sawUsb4, ref sawThunderbolt, ref sawOculink, ref sawGenericExternal);

            var locationPaths = ReadDevNodeStringListProperty(current, DevPropLocationPaths);
            foreach (var locationPath in locationPaths)
                CollectTransportHints(locationPath, ref sawUsb4, ref sawThunderbolt, ref sawOculink, ref sawGenericExternal);

            uint parent;
            if (CM_Get_Parent(out parent, current, 0) != CrSuccess || parent == 0 || parent == current)
                break;

            current = parent;
        }

        if (sawOculink)
            return "OCuLink";
        if (sawUsb4)
            return "USB4";
        if (sawThunderbolt)
            return "Thunderbolt";
        if (sawGenericExternal)
            return "eGPU";

        return string.Empty;
    }

    private static string DecorateGpuDeviceName(string name, string instanceId)
    {
        var cleanedName = Sanitize(name);
        if (string.IsNullOrWhiteSpace(cleanedName))
            return string.Empty;

        var transport = DetectExternalTransport(instanceId);
        if (!string.IsNullOrWhiteSpace(transport) && cleanedName.IndexOf(transport, StringComparison.OrdinalIgnoreCase) < 0)
            cleanedName += " (" + transport + ")";

        return cleanedName;
    }

    private static void AddGpuDevice(Dictionary<string, string> devices, List<string> deviceOrder, string name, string instanceId)
    {
        var decoratedName = DecorateGpuDeviceName(name, instanceId);
        if (string.IsNullOrWhiteSpace(decoratedName))
            return;

        var key = Sanitize(instanceId);
        if (string.IsNullOrWhiteSpace(key))
            key = decoratedName;

        string existing;
        if (!devices.TryGetValue(key, out existing))
        {
            devices[key] = decoratedName;
            deviceOrder.Add(key);
            return;
        }

        if (existing.Length < decoratedName.Length)
            devices[key] = decoratedName;
    }

    private static RefresherContext CreateContext()
    {
        var refresherType = Type.GetTypeFromProgID("WbemScripting.SWbemRefresher");
        if (refresherType == null)
            return null;

        dynamic refresher = Activator.CreateInstance(refresherType);
        try
        {
            refresher.AutoReconnect = true;
        }
        catch
        {
        }

        dynamic services = Marshal.BindToMoniker(@"winmgmts:{impersonationLevel=impersonate,authenticationLevel=pktPrivacy}!\\.\root\cimv2");
        dynamic memoryItem = refresher.AddEnum(services, "Win32_PerfFormattedData_GPUPerformanceCounters_GPUAdapterMemory");

        refresher.Refresh();
        refresher.Refresh();

        return new RefresherContext
        {
            Refresher = refresher,
            MemoryItem = memoryItem,
            GpuDevices = new string[0],
            GpuDeviceRefreshTick = 0
        };
    }

    private static string[] ReadGpuDevices()
    {
        var devices = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        var deviceOrder = new List<string>();
        var names = new List<string>();
        var seenNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        try
        {
            using (var searcher = new ManagementObjectSearcher("SELECT Name, PNPDeviceID FROM Win32_VideoController"))
            using (var results = searcher.Get())
            {
                foreach (ManagementObject controller in results)
                {
                    AddGpuDevice(devices, deviceOrder, ReadManagementString(controller, "Name"), ReadManagementString(controller, "PNPDeviceID"));
                }
            }
        }
        catch
        {
        }

        try
        {
            using (var searcher = new ManagementObjectSearcher("SELECT Name, DeviceID, Present FROM Win32_PnPEntity WHERE PNPClass = 'Display'"))
            using (var results = searcher.Get())
            {
                foreach (ManagementObject device in results)
                {
                    if (!ReadManagementBool(device, "Present", true))
                        continue;

                    AddGpuDevice(devices, deviceOrder, ReadManagementString(device, "Name"), ReadManagementString(device, "DeviceID"));
                }
            }
        }
        catch
        {
        }

        foreach (var key in deviceOrder)
        {
            string name;
            if (!devices.TryGetValue(key, out name))
                continue;

            if (seenNames.Add(name))
                names.Add(name);
        }

        return names.ToArray();
    }

    private static string[] GetGpuDevices(RefresherContext context)
    {
        int nowTick = Environment.TickCount;

        if (context.GpuDevices == null || context.GpuDevices.Length == 0 || unchecked(nowTick - context.GpuDeviceRefreshTick) >= GpuDeviceRefreshIntervalMs)
        {
            context.GpuDevices = ReadGpuDevices();
            context.GpuDeviceRefreshTick = nowTick;
        }

        return context.GpuDevices ?? new string[0];
    }

    private static void ConsiderMemory(Sample sample, string sensor, double usageBytes, int priority)
    {
        if (usageBytes <= 0.0)
            return;

        var usageMb = usageBytes / (1024.0 * 1024.0);
        if (priority < sample.GpuMemoryPriority)
            return;

        if (priority == sample.GpuMemoryPriority && usageMb < sample.GpuMemoryMb)
            return;

        sample.GpuMemoryPriority = priority;
        sample.GpuMemoryMb = usageMb;
        sample.GpuMemorySensor = sensor;
    }

    private static void ConsiderSharedMemory(Sample sample, string sensor, double usageBytes)
    {
        if (usageBytes <= 0.0)
            return;

        var usageMb = usageBytes / (1024.0 * 1024.0);
        if (sample.GpuSharedMemorySeen && usageMb < sample.GpuSharedMemoryMb)
            return;

        sample.GpuSharedMemorySeen = true;
        sample.GpuSharedMemoryMb = usageMb;
        sample.GpuSharedMemorySensor = sensor;
    }

    private static void CaptureGpuMemory(RefresherContext context, Sample sample)
    {
        object objectSet = null;

        try
        {
            objectSet = context.MemoryItem.ObjectSet;
            foreach (object adapter in (IEnumerable)objectSet)
            {
                try
                {
                    var name = Sanitize(ReadString(adapter, "Name"));
                    var dedicatedUsage = ReadDouble(adapter, "DedicatedUsage");
                    var sharedUsage = ReadDouble(adapter, "SharedUsage");

                    sample.GpuMemorySeen = true;
                    ConsiderMemory(sample, "Windows WMI performance / " + name + " / Dedicated Usage", dedicatedUsage, 2);
                    ConsiderMemory(sample, "Windows WMI performance / " + name + " / Shared Usage", sharedUsage, 1);
                    ConsiderSharedMemory(sample, "Windows WMI performance / " + name + " / Shared Usage", sharedUsage);
                }
                finally
                {
                    ReleaseComObjectQuietly(adapter);
                }
            }
        }
        finally
        {
            ReleaseComObjectQuietly(objectSet);
        }
    }

    private static Sample CaptureSample(RefresherContext context)
    {
        context.Refresher.Refresh();

        var sample = new Sample();
        CaptureGpuMemory(context, sample);
        sample.GpuDevices.AddRange(GetGpuDevices(context));
        return sample;
    }

    private static void EmitBlock(Sample sample)
    {
        Console.WriteLine("WINDOWSPERFBEGIN");

        if (sample.GpuMemorySeen)
            Console.WriteLine("WINDOWSGPUMEM|{0}|{1}", Sanitize(sample.GpuMemorySensor), sample.GpuMemoryMb.ToString("0.00", Invariant));

        if (sample.GpuSharedMemorySeen)
            Console.WriteLine("WINDOWSGPUMEMSHARED|{0}|{1}", Sanitize(sample.GpuSharedMemorySensor), sample.GpuSharedMemoryMb.ToString("0.00", Invariant));

        foreach (var device in sample.GpuDevices)
            Console.WriteLine("WINDOWSGPUDEVICE|{0}|0", Sanitize(device));

        Console.WriteLine("WINDOWSPERFEND");
        Console.Out.Flush();
    }

    private static int RunOnce()
    {
        var context = CreateContext();
        if (context == null)
            return 1;

        var sample = CaptureSample(context);
        EmitBlock(sample);
        return sample.GpuMemorySeen ? 0 : 1;
    }

    private static bool ShouldRecycleContext(RefresherContext context)
    {
        if (context == null)
            return false;

        if (context.CaptureCount >= ContextRecycleSamples)
            return true;

        try
        {
            using (var process = Process.GetCurrentProcess())
                return process.PrivateMemorySize64 >= ContextRecyclePrivateBytes;
        }
        catch
        {
            return false;
        }
    }

    private static void DisposeContext(ref RefresherContext context)
    {
        if (context != null)
        {
            context.Dispose();
            context = null;
        }

        CollectGarbageAfterComRelease();
    }

    private static int RunStream(int intervalMs, int parentPid)
    {
        RefresherContext context = null;

        while (true)
        {
            try
            {
                if (!ParentStillRunning(parentPid))
                    return 0;

                if (context == null)
                    context = CreateContext();

                if (context != null)
                {
                    EmitBlock(CaptureSample(context));
                    context.CaptureCount++;
                    if (ShouldRecycleContext(context))
                        DisposeContext(ref context);
                }

                Thread.Sleep(intervalMs);
            }
            catch (IOException)
            {
                return 0;
            }
            catch
            {
                DisposeContext(ref context);
                Thread.Sleep(Math.Min(intervalMs, 1000));
            }
        }
    }

    [STAThread]
    private static int Main(string[] args)
    {
        var intervalMs = ParseIntervalMs(args);
        var parentPid = ParseParentPid(args);
        if (HasArg(args, "--stream"))
            return RunStream(intervalMs, parentPid);

        try
        {
            return RunOnce();
        }
        catch
        {
            return 1;
        }
    }
}
