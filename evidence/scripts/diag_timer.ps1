$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$src = @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
public static class WE
{
    public delegate bool EnumProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc proc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int max);
    [DllImport("user32.dll")] public static extern int GetClassName(IntPtr hWnd, StringBuilder name, int max);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    public static List<string> List(uint targetPid)
    {
        List<string> result = new List<string>();
        EnumWindows(delegate(IntPtr h, IntPtr l) {
            uint pid; GetWindowThreadProcessId(h, out pid);
            if (pid != targetPid) return true;
            var t = new StringBuilder(512); GetWindowText(h, t, t.Capacity);
            var c = new StringBuilder(256); GetClassName(h, c, c.Capacity);
            result.Add(h.ToInt64() + " | visible=" + IsWindowVisible(h) + " | " + c + " | " + t);
            return true;
        }, IntPtr.Zero);
        return result;
    }
}
"@
Add-Type -TypeDefinition $src

$root = "C:\Users\12807\Desktop\3240704204_王志远_实验4"
$exe = "$root\src\Lab4_3240704204\bin\Release\实验4_3240704204.exe"
Get-Process -Name "实验4_3240704204" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 300
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 9
$outFile = "$root\evidence\scripts\click_helper_out.txt"
$errFile = "$root\evidence\scripts\click_helper_err.txt"
$helper = Start-Process -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-File","$root\evidence\scripts\click_timer.ps1","-TargetPid",$p.Id) -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile
Start-Sleep -Seconds 5
"=== windows of app ==="
[WE]::List([uint32]$p.Id)
"=== helper exited: $($helper.HasExited) code=$($helper.ExitCode) ==="
if (Test-Path $errFile) { "--- err ---"; Get-Content $errFile -Encoding UTF8 }
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
Stop-Process -Id $helper.Id -Force -ErrorAction SilentlyContinue
