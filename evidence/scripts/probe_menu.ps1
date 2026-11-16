$ErrorActionPreference = "Stop"
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Windows.Forms

$root = "C:\Users\12807\Desktop\3240704204_王志远_实验4"
$exe = "$root\src\Lab4_3240704204\bin\Release\实验4_3240704204.exe"
Get-Process -Name "实验4_3240704204" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 300
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 9

$AE = [System.Windows.Automation.AutomationElement]
$scope = [System.Windows.Automation.TreeScope]
$rootEl = $AE::RootElement
$pidCond = New-Object System.Windows.Automation.PropertyCondition($AE::ProcessIdProperty, $p.Id)
$wins = $rootEl.FindAll($scope::Children, $pidCond)
$main = $null
foreach ($w in $wins) { if ($w.Current.Name -like "*简易浏览器*") { $main = $w } }
if ($main -eq $null) { throw "main window not found" }

# 尝试用 WScript.Shell 激活
$shell = New-Object -ComObject WScript.Shell
$shell.AppActivate($p.Id) | Out-Null
Start-Sleep -Milliseconds 500

# 通过 UIA 展开“工具”菜单
$ctCond = New-Object System.Windows.Automation.PropertyCondition($AE::ControlTypeProperty, [System.Windows.Automation.ControlType]::MenuItem)
$items = $main.FindAll($scope::Descendants, $ctCond)
$lines = New-Object System.Collections.Generic.List[string]
foreach ($it in $items) { $lines.Add("menu before: " + $it.Current.Name) }
$tools = $null
foreach ($it in $items) { if ($it.Current.Name -like "*工具*") { $tools = $it } }
if ($tools -ne $null) {
    $ec = $tools.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)
    $ec.Expand()
    Start-Sleep -Milliseconds 800
}
$items2 = $main.FindAll($scope::Descendants, $ctCond)
foreach ($it in $items2) { $lines.Add("menu after: " + $it.Current.Name) }
# 全根窗口列表
foreach ($w in $rootEl.FindAll($scope::Children, [System.Windows.Automation.Condition]::TrueCondition)) {
    if ($w.Current.ProcessId -eq $p.Id) { $lines.Add("window: " + $w.Current.Name + " | " + $w.Current.ClassName) }
}
$lines | Set-Content "$root\evidence\scripts\menu_probe.txt" -Encoding UTF8
Write-Output "done"
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
