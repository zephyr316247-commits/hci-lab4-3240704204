$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$src = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class W5
{
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
    [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr hwnd, int attr, out RECT rect, int size);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr after, int x, int y, int cx, int cy, uint flags);
    public static void BringToFront(IntPtr h) { SetWindowPos(h, new IntPtr(-1), 0,0,0,0, 0x0001|0x0002|0x0040); SetForegroundWindow(h); System.Threading.Thread.Sleep(400); }
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
Start-Sleep -Seconds 10

$rootEl = [System.Windows.Automation.AutomationElement]::RootElement
$cond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ProcessIdProperty, $p.Id)
$wins = $rootEl.FindAll([System.Windows.Automation.TreeScope]::Children, $cond)
$main = $wins[0]
foreach ($w in $wins) { if ($w.Current.Name -like "*简易浏览器*") { $main = $w } }
[W5]::BringToFront([IntPtr]$main.Current.NativeWindowHandle)
Start-Sleep -Milliseconds 800
[System.Windows.Forms.SendKeys]::SendWait("%t")
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -Seconds 2

$wins = $rootEl.FindAll([System.Windows.Automation.TreeScope]::Children, $cond)
$timer = $null
foreach ($w in $wins) { if ($w.Current.Name -like "*定时访问*") { $timer = $w } }
if ($timer -eq $null) { throw "定时访问窗口未出现" }
[W5]::BringToFront([IntPtr]$timer.Current.NativeWindowHandle)
Start-Sleep -Milliseconds 800
[W5]::Capture([IntPtr]$timer.Current.NativeWindowHandle, "$shots\05_timer_default.png")

$all = $timer.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
$lines = New-Object System.Collections.Generic.List[string]
foreach ($e in $all) {
    $ct = $e.Current.ControlType.ProgrammaticName
    $name = $e.Current.Name
    $id = $e.Current.AutomationId
    $cls = $e.Current.ClassName
    $patterns = ($e.GetSupportedPatterns() | ForEach-Object { $_.ProgrammaticName }) -join ","
    $lines.Add("$ct | name=$name | id=$id | class=$cls | patterns=$patterns | enabled=$($e.Current.IsEnabled)")
}
$lines | Set-Content "$root\evidence\scripts\uia_timer.txt" -Encoding UTF8
Write-Output "timer elements: $($all.Count)"
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
