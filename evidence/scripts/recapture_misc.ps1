$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Drawing

$src = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Text;
public static class W18
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
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);
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
    public static RECT Rect(IntPtr h) { RECT r; GetWindowRect(h, out r); return r; }
    public static void BringToFront(IntPtr h) { SetWindowPos(h, new IntPtr(-1), 0,0,0,0, 0x0001|0x0002|0x0040); SetForegroundWindow(h); System.Threading.Thread.Sleep(400); }
    public static void ClickAt(int x, int y) { SetCursorPos(x, y); System.Threading.Thread.Sleep(150); mouse_event(0x0002,0,0,0,UIntPtr.Zero); System.Threading.Thread.Sleep(80); mouse_event(0x0004,0,0,0,UIntPtr.Zero); }
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
$AE = [System.Windows.Automation.AutomationElement]
$scope = [System.Windows.Automation.TreeScope]

function Find-NameEl($rootEl, $name) {
    $cond = New-Object System.Windows.Automation.PropertyCondition($AE::NameProperty, $name)
    return $rootEl.FindFirst($scope::Descendants, $cond)
}
function Invoke-El($el) { $el.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke() }
function Click-WindowCenter($hwnd) {
    $r = [W18]::Rect($hwnd)
    [W18]::ClickAt([int](($r.Left + $r.Right) / 2), [int]($r.Top + 120))
}

# ---------- 4-2 加载失败提示 ----------
Get-Process -Name "实验4_3240704204" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 300
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 17
$hwnd = [W18]::Find([uint32]$p.Id, "简易浏览器")
[W18]::BringToFront($hwnd)
Click-WindowCenter $hwnd
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("^l")
Start-Sleep -Milliseconds 400
[System.Windows.Forms.SendKeys]::SendWait("^a")
[System.Windows.Forms.SendKeys]::SendWait("https://no-such-host-3240704204.invalid")
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -Seconds 5
$msg = [W18]::Find([uint32]$p.Id, "加载失败")
Write-Output "invalid msg hwnd=$msg"
if ($msg -ne [IntPtr]::Zero) {
    [W18]::BringToFront($msg)
    [W18]::Capture($msg, "$shots\10_network_error.png")
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}
Start-Sleep -Milliseconds 600
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue

# ---------- 4-3 连续后退 10 次 ----------
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 17
$hwnd = [W18]::Find([uint32]$p.Id, "简易浏览器")
[W18]::BringToFront($hwnd)
Click-WindowCenter $hwnd
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("^l")
Start-Sleep -Milliseconds 400
[System.Windows.Forms.SendKeys]::SendWait("^a")
[System.Windows.Forms.SendKeys]::SendWait("https://www.ahpu.edu.cn")
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -Seconds 12
[W18]::BringToFront($hwnd)
$el = $AE::FromHandle($hwnd)
$homeBtn = Find-NameEl $el "主页"
if ($homeBtn -ne $null) { Invoke-El $homeBtn; Start-Sleep -Seconds 12 }
[W18]::BringToFront($hwnd)
$el = $AE::FromHandle($hwnd)
$back = Find-NameEl $el "后退"
for ($i = 0; $i -lt 10; $i++) {
    if ($back -ne $null -and $back.Current.IsEnabled) { Invoke-El $back }
    Start-Sleep -Milliseconds 600
}
Start-Sleep -Seconds 1
[W18]::BringToFront($hwnd)
[W18]::Capture($hwnd, "$shots\04_back_disabled.png")
Write-Output ("back enabled=" + $back.Current.IsEnabled)
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
Write-Output "done"
