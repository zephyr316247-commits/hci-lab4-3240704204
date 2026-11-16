$ErrorActionPreference = "Stop"
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Drawing

$src = @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public static class W10
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
Get-Process -Name "实验4_3240704204" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 300
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 9
$hwnd = [W10]::Find([uint32]$p.Id, "简易浏览器")
if ($hwnd -eq [IntPtr]::Zero) { throw "no window" }
$wr = [W10]::Rect($hwnd)
$ae = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$uw = $ae.Current.BoundingRectangle
$cond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, "定时访问")
$btn = $ae.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $cond)
if ($btn -eq $null) { throw "no button" }
$br = $btn.Current.BoundingRectangle
$sx = ($wr.Right - $wr.Left) / $uw.Width
$sy = ($wr.Bottom - $wr.Top) / $uw.Height
$cx = $wr.Left + ($br.X + $br.Width / 2 - $uw.X) * $sx
$cy = $wr.Top + ($br.Y + $br.Height / 2 - $uw.Y) * $sy
"win=($($wr.Left),$($wr.Top),$($wr.Right),$($wr.Bottom)) uia=($($uw.X),$($uw.Y),$($uw.Width),$($uw.Height)) scale=($sx,$sy)"
"btn=($($br.X),$($br.Y),$($br.Width),$($br.Height)) click=($cx,$cy)"
[W10]::BringToFront($hwnd)
[W10]::ClickAt([int]$cx, [int]$cy)
Start-Sleep -Seconds 3
$timerHwnd = [W10]::Find([uint32]$p.Id, "定时访问")
"timerHwnd=$timerHwnd"
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
