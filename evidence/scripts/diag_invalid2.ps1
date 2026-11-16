$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Drawing

$src = @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public static class W16
{
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    public delegate bool EnumProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc proc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int max);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
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
}
"@
Add-Type -TypeDefinition $src

$root = "C:\Users\12807\Desktop\3240704204_王志远_实验4"
$exe = "$root\src\Lab4_3240704204\bin\Release\实验4_3240704204.exe"
$shots = "$root\evidence\screenshots"
$AE = [System.Windows.Automation.AutomationElement]
$scope = [System.Windows.Automation.TreeScope]
Get-Process -Name "实验4_3240704204" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 300
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 17
$hwnd = [W16]::Find([uint32]$p.Id, "简易浏览器")
[W16]::BringToFront($hwnd)
$el = $AE::FromHandle($hwnd)
$addr = $null
foreach ($e in $el.FindAll($scope::Descendants, [System.Windows.Automation.Condition]::TrueCondition)) {
    if ($e.Current.ClassName -like "*COMBOBOX*" -and $e.Current.Name -like "*地址*") { $addr = $e; break }
}
"addr found: $($addr -ne $null)"
if ($addr -ne $null) {
    $wr = [W16]::Rect($hwnd)
    $uw = $el.Current.BoundingRectangle
    $r = $addr.Current.BoundingRectangle
    $sx = ($wr.Right - $wr.Left) / $uw.Width
    $sy = ($wr.Bottom - $wr.Top) / $uw.Height
    $x = $wr.Left + ($r.X + $r.Width / 2 - $uw.X) * $sx
    $y = $wr.Top + ($r.Y + $r.Height / 2 - $uw.Y) * $sy
    "click addr at $x,$y"
    [W16]::ClickAt([int]$x, [int]$y)
    Start-Sleep -Milliseconds 400
}
[System.Windows.Forms.SendKeys]::SendWait("^a")
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::SendWait("https://no-such-host-3240704204.invalid")
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -Seconds 4
$focused = $AE::FocusedElement
"focused: $($focused.Current.ClassName) | $($focused.Current.Name)"
$msg = [W16]::Find([uint32]$p.Id, "加载失败")
"msg=$msg"
$b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($b.X, $b.Y, 0, 0, $b.Size)
$bmp.Save("$shots\_diag_invalid.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
