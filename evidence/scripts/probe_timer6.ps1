$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$src = @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.Drawing;
using System.Drawing.Imaging;
public static class WF
{
    public delegate bool EnumProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc proc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int max);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
    [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr hwnd, int attr, out RECT rect, int size);
    public static IntPtr Find(uint pid, string titlePart)
    {
        IntPtr found = IntPtr.Zero;
        EnumWindows(delegate(IntPtr h, IntPtr l) {
            uint p; GetWindowThreadProcessId(h, out p);
            if (p != pid || !IsWindowVisible(h)) return true;
            var t = new StringBuilder(512); GetWindowText(h, t, t.Capacity);
            if (t.ToString().Contains(titlePart)) { found = h; return false; }
            return true;
        }, IntPtr.Zero);
        return found;
    }
    public static void Capture(IntPtr h, string path)
    {
        RECT r; int hr = DwmGetWindowAttribute(h, 9, out r, Marshal.SizeOf(typeof(RECT)));
        if (hr != 0 || r.Right <= r.Left) GetWindowRect(h, out r);
        using (var bmp = new Bitmap(r.Right - r.Left, r.Bottom - r.Top))
        using (var g = Graphics.FromImage(bmp)) { g.CopyFromScreen(r.Left, r.Top, 0, 0, bmp.Size); bmp.Save(path, ImageFormat.Png); }
    }
}
"@
Add-Type -TypeDefinition $src -ReferencedAssemblies System.Drawing

$root = "C:\Users\12807\Desktop\3240704204_王志远_实验4"
$exe = "$root\src\Lab4_3240704204\bin\Release\实验4_3240704204.exe"
$shots = "$root\evidence\screenshots"
Get-Process -Name "实验4_3240704204" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 300
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 9
$helper = Start-Process -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-File","$root\evidence\scripts\click_timer.ps1","-TargetPid",$p.Id) -PassThru
Start-Sleep -Seconds 3
$hwnd = [WF]::Find([uint32]$p.Id, "定时访问")
if ($hwnd -eq [IntPtr]::Zero) { throw "timer hwnd not found" }
[WF]::Capture($hwnd, "$shots\05_timer_default.png")
$timer = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$lines = New-Object System.Collections.Generic.List[string]
$all = $timer.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
foreach ($e in $all) {
    $ct = $e.Current.ControlType.ProgrammaticName
    $patterns = ($e.GetSupportedPatterns() | ForEach-Object { $_.ProgrammaticName }) -join ","
    $r = $e.Current.BoundingRectangle
    $lines.Add("$ct | name=$($e.Current.Name) | id=$($e.Current.AutomationId) | class=$($e.Current.ClassName) | patterns=$patterns | enabled=$($e.Current.IsEnabled) | rect=$($r.X),$($r.Y),$($r.Width),$($r.Height)")
}
$lines | Set-Content "$root\evidence\scripts\uia_timer.txt" -Encoding UTF8
Write-Output "timer elements: $($all.Count)"
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
Stop-Process -Id $helper.Id -Force -ErrorAction SilentlyContinue
