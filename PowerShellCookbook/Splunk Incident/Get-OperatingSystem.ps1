Param($ComputerName = "LocalHost")
Get-WmiObject -ComputerName $ComputerName -Class Win32_OperatingSystem