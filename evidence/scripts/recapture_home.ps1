$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
$src = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Text;
public static class W12
{
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    public delegate bool EnumProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc proc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int max);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
    [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr hwnd, int attr, out RECT rect, int size);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr after, int x, int y, int cx, int cy, uint flags);
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
Start-Sleep -Seconds 18
$hwnd = [W12]::Find([uint32]$p.Id, "简易浏览器")
$uiaEl = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$uw = $uiaEl.Current.BoundingRectangle
Write-Output ("uia rect: {0},{1} {2}x{3}" -f $uw.X, $uw.Y, $uw.Width, $uw.Height)
[W12]::BringToFront($hwnd)
Start-Sleep -Milliseconds 600
[W12]::Capture($hwnd, "$shots\01_browser_home.png")

$AE = [System.Windows.Automation.AutomationElement]
$el = $AE::FromHandle($hwnd)
$lines = New-Object System.Collections.Generic.List[string]
foreach ($e in $el.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)) {
    if ($e.Current.ControlType -eq [System.Windows.Automation.ControlType]::Text -or $e.Current.ControlType -eq [System.Windows.Automation.ControlType]::StatusBar) {
        $lines.Add($e.Current.ControlType.ProgrammaticName + " | " + $e.Current.Name)
    }
}
$lines | Set-Content "$root\evidence\scripts\status_after.png.txt" -Encoding UTF8
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
Write-Output "recaptured"
