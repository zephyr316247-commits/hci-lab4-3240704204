param([int]$TargetPid)
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
$AE = [System.Windows.Automation.AutomationElement]
$scope = [System.Windows.Automation.TreeScope]
$rootEl = $AE::RootElement
$pidCond = New-Object System.Windows.Automation.PropertyCondition($AE::ProcessIdProperty, $TargetPid)
$wins = $rootEl.FindAll($scope::Children, $pidCond)
$main = $null
foreach ($w in $wins) { if ($w.Current.Name -like "*简易浏览器*") { $main = $w } }
if ($main -eq $null) { throw "main not found" }
$nameCond = New-Object System.Windows.Automation.PropertyCondition($AE::NameProperty, "定时访问")
$btn = $main.FindFirst($scope::Descendants, $nameCond)
if ($btn -eq $null) { throw "button not found" }
$ip = $btn.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
$ip.Invoke()   # 会一直阻塞到定时窗体关闭
