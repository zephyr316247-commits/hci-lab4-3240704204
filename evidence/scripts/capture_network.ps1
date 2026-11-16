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
public static class W14
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
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int cmd);
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
    public static IntPtr FindAny(string part)
    {
        IntPtr found = IntPtr.Zero;
        EnumWindows(delegate(IntPtr h, IntPtr l) {
            if (!IsWindowVisible(h)) return true;
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

function Capture-Screen([string]$path) {
    $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($b.X, $b.Y, 0, 0, $b.Size)
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
}

$root = "C:\Users\12807\Desktop\3240704204_王志远_实验4"
$exe = "$root\src\Lab4_3240704204\bin\Release\实验4_3240704204.exe"
$shots = "$root\evidence\screenshots"
$network = "$root\evidence\network"
$AE = [System.Windows.Automation.AutomationElement]
$scope = [System.Windows.Automation.TreeScope]

Get-Process -Name "实验4_3240704204" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 300

# ---------- 1. 加载失败提示（4-2） ----------
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 17
$hwnd = [W14]::Find([uint32]$p.Id, "简易浏览器")
[W14]::BringToFront($hwnd)
Start-Sleep -Milliseconds 600
$browserEl = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$addrBox = $null
foreach ($e in $browserEl.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)) {
    if ($e.Current.ClassName -like "*COMBOBOX*" -and $e.Current.Name -like "*地址*") { $addrBox = $e; break }
}
if ($addrBox -ne $null) { $addrBox.SetFocus() }
Start-Sleep -Milliseconds 400
[System.Windows.Forms.SendKeys]::SendWait("^a")
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::SendWait("https://no-such-host-3240704204.invalid")
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -Seconds 15
$msg = [W14]::Find([uint32]$p.Id, "加载失败")
if ($msg -eq [IntPtr]::Zero) { $msg = [W14]::FindAny("加载失败") }
if ($msg -ne [IntPtr]::Zero) {
    [W14]::BringToFront($msg)
    [W14]::Capture($msg, "$shots\10_network_error.png")
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Start-Sleep -Milliseconds 800
}
# 文件菜单截图
[W14]::BringToFront($hwnd)
$el = $AE::FromHandle($hwnd)
$cond = New-Object System.Windows.Automation.PropertyCondition($AE::NameProperty, "文件(F)")
$fileMenu = $el.FindFirst($scope::Descendants, $cond)
$ec = $fileMenu.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)
$ec.Expand()
Start-Sleep -Milliseconds 800
[W14]::Capture($hwnd, "$shots\11_file_menu.png")
[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue

# ---------- 2. 网络请求记录 ----------
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 16
$hwnd = [W14]::Find([uint32]$p.Id, "简易浏览器")
[W14]::BringToFront($hwnd)

$dns = (Resolve-DnsName jwc.ahpu.edu.cn -ErrorAction SilentlyContinue | Format-Table -AutoSize | Out-String)
$tcp = (Get-NetTCPConnection -State Established -RemotePort 443 -ErrorAction SilentlyContinue | Select-Object RemoteAddress,RemotePort,OwningProcess | Format-Table -AutoSize | Out-String)
$procInfo = (Get-Process -Name "实验4_3240704204" -ErrorAction SilentlyContinue | Select-Object Id,ProcessName | Format-Table -AutoSize | Out-String)
$text = "DNS:`r`n$dns`r`nTCP 443:`r`n$tcp`r`nProcess:`r`n$procInfo"
$text | Out-File "$network\network_request.txt" -Encoding utf8

$bat = "$network\show_network.bat"
$batText = @"
@echo off
title 网络请求记录
echo ==== DNS 解析 jwc.ahpu.edu.cn ====
nslookup jwc.ahpu.edu.cn
echo.
echo ==== 与 443 端口已建立的连接 ====
powershell -NoProfile -Command "Get-NetTCPConnection -State Established -RemotePort 443 | Select-Object RemoteAddress,RemotePort,OwningProcess | Format-Table -AutoSize"
echo.
echo ==== 程序进程 ====
tasklist /fi "imagename eq 实验4_3240704204.exe"
pause
"@
[System.IO.File]::WriteAllText($bat, $batText, [System.Text.Encoding]::GetEncoding(936))

$cmd = Start-Process -FilePath "cmd.exe" -ArgumentList @("/k", "`"$bat`"") -PassThru
Start-Sleep -Seconds 6
$console = [W14]::FindAny("网络请求记录")
if ($console -ne [IntPtr]::Zero) {
    [W14]::ShowWindow($console, 3) | Out-Null
    [W14]::BringToFront($console)
    Start-Sleep -Milliseconds 800
    [W14]::Capture($console, "$shots\12_network_request.png")
} else {
    Capture-Screen "$shots\12_network_request.png"
}
Start-Sleep -Milliseconds 500
Stop-Process -Id $cmd.Id -Force -ErrorAction SilentlyContinue
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
Write-Output "done"
