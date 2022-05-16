Get-Process -FileVersionInfo -ErrorAction SilentlyContinue
Get-Process -FileVersionInfo -ea 0 | Out-GridView
Get-Process | Select-Object * | Out-GridView
Get-Process | Select-Object Name, NPM, PM, VM, WS | Out-GridView
Get-Process | Select-Object | Get-Member
Get-Process | Select-Object Name, Description, Company, MainWindowTitle | Select-Object -First 20
Get-Process | Group-Object ProcessName | ForEach-Object { $_ | Select-Object -ExcludeProperty group } | Select-Object -First 5
Get-Process | Where-Object { $_.MainWindowTitle -ne '' } | Select-Object Description, MainWindowTitle, Name, Comments

Get-Process | Where-Object { $_.st -gt (Get-Date).AddMinutes(-180)}
@(Get-Process notepad -ea 0).Count
Get-Process | Measure-Object -Average -Maximum -Minimum -Property PagedSystemMemorySize

Get-Process notepad | ForEach-Object {$_.PriorityClass = "BelowNormal"}
