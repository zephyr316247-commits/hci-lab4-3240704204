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
using System.Text;
public static class W9
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
    [DllImport("user32.dll")] public static extern int GetSystemMetrics(int index);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);
    public static void ClickAt(int x, int y) { SetCursorPos(x, y); System.Threading.Thread.Sleep(150); mouse_event(0x0002,0,0,0,UIntPtr.Zero); System.Threading.Thread.Sleep(80); mouse_event(0x0004,0,0,0,UIntPtr.Zero); }

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

    public static IntPtr FindAny(string titlePart)
    {
        IntPtr found = IntPtr.Zero;
        EnumWindows(delegate(IntPtr h, IntPtr l) {
            if (!IsWindowVisible(h)) return true;
            var t = new StringBuilder(512); GetWindowText(h, t, t.Capacity);
            if (t.ToString().Contains(titlePart)) { found = h; return false; }
            return true;
        }, IntPtr.Zero);
        return found;
    }

    public static RECT Rect(IntPtr h) { RECT r; GetWindowRect(h, out r); return r; }
    public static void BringToFront(IntPtr h)
    {
        SetWindowPos(h, new IntPtr(-1), 0, 0, 0, 0, 0x0001 | 0x0002 | 0x0040);
        SetForegroundWindow(h);
        System.Threading.Thread.Sleep(350);
    }

    public static void Capture(IntPtr h, string path)
    {
        RECT r; int hr = DwmGetWindowAttribute(h, 9, out r, Marshal.SizeOf(typeof(RECT)));
        if (hr != 0 || r.Right <= r.Left) GetWindowRect(h, out r);
        using (var bmp = new Bitmap(r.Right - r.Left, r.Bottom - r.Top))
        using (var g = Graphics.FromImage(bmp)) { g.CopyFromScreen(r.Left, r.Top, 0, 0, bmp.Size); bmp.Save(path, ImageFormat.Png); }
    }

    public static void CaptureScreenJpg(string path)
    {
        int w = GetSystemMetrics(0);
        int h = GetSystemMetrics(1);
        using (var bmp = new Bitmap(w, h))
        using (var g = Graphics.FromImage(bmp))
        {
            g.CopyFromScreen(0, 0, 0, 0, new Size(w, h));
            bmp.Save(path, ImageFormat.Jpeg);
        }
    }
}
"@
Add-Type -TypeDefinition $src -ReferencedAssemblies System.Drawing

$root = "C:\Users\12807\Desktop\3240704204_王志远_实验4"
$exe = "$root\src\Lab4_3240704204\bin\Release\实验4_3240704204.exe"
$shots = "$root\evidence\screenshots"
$frames = "$root\evidence\recording\frames"
$helperPath = "$root\evidence\scripts\click_timer.ps1"
New-Item -ItemType Directory -Force -Path $shots | Out-Null
Remove-Item $frames -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $frames | Out-Null
Get-Process -Name "实验4_3240704204" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 300

$AE = [System.Windows.Automation.AutomationElement]
$scope = [System.Windows.Automation.TreeScope]
$trueCond = [System.Windows.Automation.Condition]::TrueCondition

function Get-Desc($rootEl) { return $rootEl.FindAll($scope::Descendants, $trueCond) }
function Find-Name($rootEl, $name) {
    $cond = New-Object System.Windows.Automation.PropertyCondition($AE::NameProperty, $name)
    return $rootEl.FindFirst($scope::Descendants, $cond)
}
function Find-Combo($rootEl, $namePart) {
    foreach ($e in (Get-Desc $rootEl)) {
        if ($e.Current.ClassName -like "*COMBOBOX*" -and $e.Current.Name -like "*$namePart*") { return $e }
    }
    return $null
}
function Find-Edit($rootEl, $textPart) {
    foreach ($e in (Get-Desc $rootEl)) {
        if ($e.Current.ClassName -like "*EDIT*" -and $e.Current.Name -like "*$textPart*") { return $e }
    }
    return $null
}
function Invoke-El($el) { $el.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke() }
function Wait-Status($rootEl, $text, $seconds) {
    $end = (Get-Date).AddSeconds($seconds)
    while ((Get-Date) -lt $end) {
        $hit = Find-Name $rootEl $text
        if ($hit -ne $null) { return $true }
        Start-Sleep -Milliseconds 500
    }
    return $false
}

# 1. 启动并等待主页加载
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 6
$hwnd = [W9]::Find([uint32]$p.Id, "简易浏览器")
if ($hwnd -eq [IntPtr]::Zero) { throw "浏览器窗口未出现" }
[W9]::BringToFront($hwnd)
$browser = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
Wait-Status $browser "加载完成" 25 | Out-Null
Start-Sleep -Seconds 4
[W9]::Capture($hwnd, "$shots\01_browser_home.png")

# 2. 历史下拉（P8②）
$addr = Find-Combo $browser "地址"
if ($addr -ne $null) {
    $ec = $addr.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)
    $ec.Expand()
    Start-Sleep -Milliseconds 900
    [W9]::Capture($hwnd, "$shots\02_history_dropdown.png")
    $ec.Collapse()
    Start-Sleep -Milliseconds 400
}

# 3. 页面缩放（P8①）：聚焦缩放框，Home 后按四次下箭头到 150%
$zoom = Find-Combo $browser "缩放"
if ($zoom -ne $null) {
    $zoom.SetFocus()
    Start-Sleep -Milliseconds 300
    [System.Windows.Forms.SendKeys]::SendWait("{HOME}")
    Start-Sleep -Milliseconds 200
    [System.Windows.Forms.SendKeys]::SendWait("{DOWN}{DOWN}{DOWN}{DOWN}")
    Start-Sleep -Milliseconds 1500
    [W9]::Capture($hwnd, "$shots\03_zoom_title.png")
    # 恢复 100%
    [System.Windows.Forms.SendKeys]::SendWait("{HOME}{DOWN}{DOWN}")
    Start-Sleep -Milliseconds 800
}

# 4. 打开学校主页后再连续后退 10 次，验证按钮禁用（4-3）
[System.Windows.Forms.SendKeys]::SendWait("^l")
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("https://www.ahpu.edu.cn")
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -Seconds 8
$back = Find-Name $browser "后退"
if ($back -ne $null) {
    for ($i = 0; $i -lt 10; $i++) {
        if ($back.Current.IsEnabled) { Invoke-El $back }
        Start-Sleep -Milliseconds 500
    }
    Start-Sleep -Milliseconds 800
    [W9]::Capture($hwnd, "$shots\04_back_disabled.png")
}
# 回主页
$homeBtn = Find-Name $browser "主页"
if ($homeBtn -ne $null) { Invoke-El $homeBtn }
Start-Sleep -Seconds 8

Write-Output "browser screenshots done"

# 打开定时访问窗体：点击窗体后 F10 菜单导航
function Open-Timer {
    [W9]::BringToFront($hwnd)
    $wr = [W9]::Rect($hwnd)
    [W9]::ClickAt([int](($wr.Left + $wr.Right) / 2), [int]($wr.Top + 120))
    Start-Sleep -Milliseconds 400
    [System.Windows.Forms.SendKeys]::SendWait("{F10}")
    Start-Sleep -Milliseconds 250
    [System.Windows.Forms.SendKeys]::SendWait("{RIGHT}{RIGHT}")
    Start-Sleep -Milliseconds 250
    [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
    Start-Sleep -Milliseconds 250
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Start-Sleep -Seconds 2
    return [W9]::Find([uint32]$p.Id, "定时访问")
}
function Get-Edits($timerEl) {
    $list = New-Object System.Collections.ArrayList
    foreach ($e in $timerEl.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)) {
        if ($e.Current.ClassName -like "*EDIT*") { [void]$list.Add($e) }
    }
    $sorted = $list | Sort-Object { $_.Current.BoundingRectangle.Y }, { $_.Current.BoundingRectangle.X }
    return @($sorted)
}
function Click-Uia($hwndTimer, $timerEl, $el) {
    $wr = [W9]::Rect($hwndTimer)
    $uw = $timerEl.Current.BoundingRectangle
    $r = $el.Current.BoundingRectangle
    $sx = ($wr.Right - $wr.Left) / $uw.Width
    $sy = ($wr.Bottom - $wr.Top) / $uw.Height
    $x = $wr.Left + ($r.X + $r.Width / 2 - $uw.X) * $sx
    $y = $wr.Top + ($r.Y + $r.Height / 2 - $uw.Y) * $sy
    [W9]::ClickAt([int]$x, [int]$y)
}
function Set-Num($hwndTimer, $timerEl, $editEl, $value) {
    Click-Uia $hwndTimer $timerEl $editEl
    Start-Sleep -Milliseconds 250
    [System.Windows.Forms.SendKeys]::SendWait("^a")
    [System.Windows.Forms.SendKeys]::SendWait($value)
    [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
    Start-Sleep -Milliseconds 200
}

# 5. 秒 59→60 进位（4-4）
$timerHwnd = Open-Timer
[W9]::BringToFront($timerHwnd)
$timerEl = [System.Windows.Automation.AutomationElement]::FromHandle($timerHwnd)
[W9]::Capture($timerHwnd, "$shots\05_timer_default.png")
$edits = Get-Edits $timerEl
Set-Num $timerHwnd $timerEl $edits[3] "60"
Start-Sleep -Milliseconds 900
[W9]::Capture($timerHwnd, "$shots\06_carry.png")
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("%{F4}")
Start-Sleep -Milliseconds 800

# 6. 非法时刻（4-6）
$timerHwnd = Open-Timer
[W9]::BringToFront($timerHwnd)
$timerEl = [System.Windows.Automation.AutomationElement]::FromHandle($timerHwnd)
$edits = Get-Edits $timerEl
Set-Num $timerHwnd $timerEl $edits[1] "0"
Set-Num $timerHwnd $timerEl $edits[2] "0"
Set-Num $timerHwnd $timerEl $edits[3] "0"
$startBtn = Find-Name $timerEl "启动(S)"
Click-Uia $timerHwnd $timerEl $startBtn
Start-Sleep -Milliseconds 1200
$msgHwnd = [W9]::Find([uint32]$p.Id, "时刻不合法")
if ($msgHwnd -eq [IntPtr]::Zero) { $msgHwnd = [W9]::FindAny("时刻不合法") }
if ($msgHwnd -ne [IntPtr]::Zero) {
    [W9]::BringToFront($msgHwnd)
    [W9]::Capture($msgHwnd, "$shots\07_timer_invalid.png")
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}
Start-Sleep -Milliseconds 700
[System.Windows.Forms.SendKeys]::SendWait("%{F4}")
Start-Sleep -Milliseconds 700

# 7. 合法定时：默认 +30 秒，启动并录屏（4-5）
$timerHwnd = Open-Timer
[W9]::BringToFront($timerHwnd)
$timerEl = [System.Windows.Automation.AutomationElement]::FromHandle($timerHwnd)
$startBtn = Find-Name $timerEl "启动(S)"
Click-Uia $timerHwnd $timerEl $startBtn
Start-Sleep -Milliseconds 1200
[W9]::Capture($timerHwnd, "$shots\08_timer_running.png")

$frame = 0
$end = (Get-Date).AddSeconds(40)
while ((Get-Date) -lt $end) {
    $frame++
    $name = "{0:D4}.jpg" -f $frame
    [W9]::CaptureScreenJpg((Join-Path $frames $name))
    Start-Sleep -Milliseconds 500
}
[W9]::CaptureScreenJpg("$shots\09_triggered.jpg")
Write-Output "frames: $frame"
