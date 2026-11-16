$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$root = "C:\Users\12807\Desktop\3240704204_王志远_实验4"
$exe = "$root\src\Lab4_3240704204\bin\Release\实验4_3240704204.exe"
Get-Process -Name "实验4_3240704204" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 300
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 9
$helper = Start-Process -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList @("-NoProfile","-ExecutionPolicy","Bypass","-File","$root\evidence\scripts\click_timer.ps1","-TargetPid",$p.Id) -PassThru
Start-Sleep -Seconds 3

$AE = [System.Windows.Automation.AutomationElement]
$scope = [System.Windows.Automation.TreeScope]
$rootEl = $AE::RootElement
$pidCond = New-Object System.Windows.Automation.PropertyCondition($AE::ProcessIdProperty, $p.Id)
$wins = $rootEl.FindAll($scope::Children, $pidCond)
$timer = $null
foreach ($w in $wins) { if ($w.Current.Name -like "*定时访问*") { $timer = $w } }
if ($timer -eq $null) { throw "timer window not found" }

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("WINDOW: " + $timer.Current.Name)
$all = $timer.FindAll($scope::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
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
