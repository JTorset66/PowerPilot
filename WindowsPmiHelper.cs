using System;
using System.Globalization;
using System.Management;
using System.Security;

internal static class WindowsPmiHelper
{
    private sealed class Candidate
    {
        public bool Valid;
        public int Score = int.MinValue;
        public double Watts;
        public string Sensor = "";
    }

    private static bool ContainsInsensitive(string text, string needle)
    {
        return text != null && text.IndexOf(needle, StringComparison.OrdinalIgnoreCase) >= 0;
    }

    private static int ScoreCpu(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return -1;

        if (text.Equals("RAPL_Package0_PKG", StringComparison.OrdinalIgnoreCase)) return 5000;
        if (text.Equals("Current Socket Power", StringComparison.OrdinalIgnoreCase)) return 4500;
        if (text.Equals("Apu Power", StringComparison.OrdinalIgnoreCase)) return 4200;
        if (ContainsInsensitive(text, "cpu")) return 3900;
        if (ContainsInsensitive(text, "socket")) return 3800;
        if (ContainsInsensitive(text, "package")) return 3600;
        if (ContainsInsensitive(text, "ppt")) return 3200;
        if (ContainsInsensitive(text, "stapm")) return 3100;
        if (ContainsInsensitive(text, "pkg")) return 2500;
        return -1;
    }

    private static int ScoreApu(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return -1;

        if (text.Equals("Apu Power", StringComparison.OrdinalIgnoreCase)) return 8000;
        if (ContainsInsensitive(text, "apu")) return 7000;
        return -1;
    }

    private static int ScoreGpu(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return -1;

        if (text.Equals("VDDGFX Power", StringComparison.OrdinalIgnoreCase)) return 7000;
        if (text.Equals("VDDCR_GFX Power", StringComparison.OrdinalIgnoreCase)) return 6900;
        if (ContainsInsensitive(text, "gfx")) return 6600;
        if (ContainsInsensitive(text, "gpu")) return 6300;
        if (ContainsInsensitive(text, "graphics")) return 6100;
        if (text.Equals("VDDCR_SOC Power", StringComparison.OrdinalIgnoreCase)) return 4200;
        if (ContainsInsensitive(text, "soc")) return 3200;
        return -1;
    }

    private static void Consider(Candidate candidate, int score, double watts, string label)
    {
        if (candidate == null || score < 0 || watts <= 0.05)
            return;

        if (candidate.Valid && score < candidate.Score)
            return;

        candidate.Valid = true;
        candidate.Score = score;
        candidate.Watts = watts;
        candidate.Sensor = "Windows PMI power reading / " + label;
    }

    private static string MeterLabel(ManagementBaseObject obj)
    {
        var name = Convert.ToString(obj["Name"], CultureInfo.InvariantCulture) ?? "";
        var description = Convert.ToString(obj["Description"], CultureInfo.InvariantCulture) ?? "";
        var caption = Convert.ToString(obj["Caption"], CultureInfo.InvariantCulture) ?? "";
        var deviceId = Convert.ToString(obj["DeviceID"], CultureInfo.InvariantCulture) ?? "";

        if (!string.IsNullOrWhiteSpace(name))
            return name;
        if (!string.IsNullOrWhiteSpace(description))
            return description;
        if (!string.IsNullOrWhiteSpace(caption))
            return caption;
        if (!string.IsNullOrWhiteSpace(deviceId))
            return deviceId;
        return "PMI Meter";
    }

    private static double ComputeWatts(ManagementBaseObject obj)
    {
        var reading = Convert.ToDouble(obj["CurrentReading"], CultureInfo.InvariantCulture);
        var unitModifier = -3;

        if (obj["UnitModifier"] != null)
            unitModifier = Convert.ToInt32(obj["UnitModifier"], CultureInfo.InvariantCulture);

        return reading * Math.Pow(10.0, unitModifier);
    }

    public static int Main()
    {
        var cpu = new Candidate();
        var apu = new Candidate();
        var gpu = new Candidate();

        try
        {
            var options = new ConnectionOptions
            {
                EnablePrivileges = true,
                Impersonation = ImpersonationLevel.Impersonate,
                Authentication = AuthenticationLevel.PacketPrivacy
            };

            var scope = new ManagementScope(@"\\.\root\CIMV2\power", options);
            scope.Connect();

            using (var searcher = new ManagementObjectSearcher(scope, new ObjectQuery("SELECT Name, Description, Caption, DeviceID, BaseUnits, UnitModifier, CurrentReading FROM Win32_PowerMeter")))
            using (var results = searcher.Get())
            {
                foreach (ManagementObject obj in results)
                {
                    if (obj["CurrentReading"] == null)
                        continue;

                    var label = MeterLabel(obj);
                    var watts = ComputeWatts(obj);

                    Consider(cpu, ScoreCpu(label), watts, label);
                    Consider(apu, ScoreApu(label), watts, label);
                    Consider(gpu, ScoreGpu(label), watts, label);
                }
            }
        }
        catch (UnauthorizedAccessException)
        {
            return 1;
        }
        catch (SecurityException)
        {
            return 1;
        }
        catch
        {
            return 1;
        }

        if (cpu.Valid)
            Console.WriteLine("WINDOWSCPUPOWER|{0}|{1}", cpu.Sensor, cpu.Watts.ToString("0.00", CultureInfo.InvariantCulture));
        if (apu.Valid)
            Console.WriteLine("WINDOWSAPUPOWER|{0}|{1}", apu.Sensor, apu.Watts.ToString("0.00", CultureInfo.InvariantCulture));
        if (gpu.Valid)
            Console.WriteLine("WINDOWSGPUPOWER|{0}|{1}", gpu.Sensor, gpu.Watts.ToString("0.00", CultureInfo.InvariantCulture));

        return (cpu.Valid || apu.Valid || gpu.Valid) ? 0 : 1;
    }
}
