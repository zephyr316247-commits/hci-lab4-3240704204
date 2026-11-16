$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms
$src = @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
public static class W15
{
    public delegate bool EnumProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc proc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int max);
    [DllImport("user32.dll")] public static extern int GetClassName(IntPtr hWnd, StringBuilder name, int max);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    public static IntPtr Find(uint pid, string part)
    {
        IntPtr found = IntPtr.Zero;
        EnumWindows(delegate(IntPtr h, IntPtr l) {
            uint p; GetWindowThreadProcessId(h, out p);
            if (p != pid || !IsWindowVisible(h)) return true;
            var t = new StringBuilder(512); GetWindowText(h, t, t.Capacity);
            if (t.ToString().Contains(part)) { found = h; return false; }
            return true;
        }, IntPtr.Zero);
        return found;
    }
    public static List<string> List(uint pid)
    {
        List<string> r = new List<string>();
        EnumWindows(delegate(IntPtr h, IntPtr l) {
            uint p; GetWindowThreadProcessId(h, out p);
            if (p != pid || !IsWindowVisible(h)) return true;
            var t = new StringBuilder(512); GetWindowText(h, t, t.Capacity);
            var c = new StringBuilder(256); GetClassName(h, c, c.Capacity);
            r.Add(c.ToString() + " | " + t.ToString());
            return true;
        }, IntPtr.Zero);
        return r;
    }
}
"@
Add-Type -TypeDefinition $src
$root = "C:\Users\12807\Desktop\3240704204_王志远_实验4"
$exe = "$root\src\Lab4_3240704204\bin\Release\实验4_3240704204.exe"
Get-Process -Name "实验4_3240704204" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 300
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 17
$hwnd = [W15]::Find([uint32]$p.Id, "简易浏览器")
Write-Output "main=$hwnd"
[System.Windows.Forms.SendKeys]::SendWait("^l")
Start-Sleep -Milliseconds 400
[System.Windows.Forms.SendKeys]::SendWait("https://no-such-host-3240704204.invalid")
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
for ($i = 0; $i -lt 15; $i++) {
    Start-Sleep -Seconds 2
    "--- t=$($i*2+2)s ---"
    [W15]::List([uint32]$p.Id)
}
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
