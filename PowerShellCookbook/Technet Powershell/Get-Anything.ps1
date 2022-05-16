$host.ui.RawUI.WindowTitle = "Get Anything"

# Begin
do {
Write ""
Write-Host "--- Find Basic System Information on Remote Machines ---" -ForegroundColor Yellow
Write ""
Write ""
$me = $env:USERPROFILE
$local = "localhost"
$compname = (Read-Host "Enter the computer name you would like to query")
if (($compname -eq "local") -or ($compname -eq "127.0.0.1"))
	{
	$compname = $local
	}

# If the PC name is NOT localhost, then ping the remote PC to see if it's online.
if ($compname -ne "localhost")
    {
	Write ""
	Write-Host "   ----   Testing connection to " -ForegroundColor Cyan -NoNewLine
	Write-Host $compname -ForegroundColor White -NoNewLine
	Write-Host '...   ----     ' -ForegroundColor Cyan
    $ping = Test-Connection -ComputerName $compname -Count 3 -Quiet
    }

# If the remote PC responds or is named "localhost", begin the script.
# Or else the script will start over and ask for a different PC name.
if (($compname -eq $local) -or ($ping -eq "True"))
    {
	Clear-Host
	Write ""
	Write-Host "   ----   Connection to " -ForegroundColor Green -NoNewLine
	Write-Host $compname -ForegroundColor White -NoNewLine
	Write-Host " successfully established!   ----   " -ForegroundColor Green
	
	# Begin the Queries Loop
    do {
		Write ""
		# Queries Menu
		Write ""
		Write-Host "Valid WMI Queries:" -ForegroundColor Green
		Write ""
		Write-Host -----------------  1. Computer Manufacturer/Model	
		Write-Host -----------------  2. Current Logged on User			# Requires the script to have been run by a user with Active Directory "Read" priviledges
		Write-Host -----------------  3. Running Processes				# Sorts by name and group multiples together
		Write-Host -----------------  4. Total Physical Memory			# Displays the total memory available and gives details about each memory module installed
		Write-Host -----------------  5. Active Storage Drives			# Lists the "physical" drives attached to the remote PC with total available capacity
		Write-Host -----------------  6. CPU Information				# Displays the CPU, speed, L2 & L3 cache size, and core structure
		Write-Host -----------------  7. System Graphics				# Details about what type of graphics the OS is using (not installed).
		Write ""
		Write-Host ' *TIP* - If you add ">" to the end of the number, it will create' -ForegroundColor Blue
		Write-Host ' a text file on your desktop instead of displaying on the Host.' -ForegroundColor Blue		# e.g. ("7>")
		Write ""
		
		Write-Host 'Pick a number for the target class for WMI to query: ' -ForegroundColor Cyan -NoNewLine
		$wmi = Read-Host
		
		# 1. Computer Model Query
		if ($wmi -like "1*")
			{
			$query = $null
			$query = Get-WmiObject Win32_ComputerSystem -ComputerName $compname | Select Manufacturer,Model | Fl
			if ($wmi -eq "1>")
				{
				$query | Out-File "$me\Desktop\Computer Info ($compname).txt"
				Write ""
				}
			else
				{
				$query
				}
			}
		
		# 2. Current Logged On User Query
		elseif ($wmi -like "2*")
			{
			$pn = $username = $query = $null
			Import-Module ActiveDirectory
			$query = @(
				$pn = 'msDS-PrincipalName'
				$username = (Get-WmiObject Win32_ComputerSystem -ComputerName $compname).Username
				Get-ADUser -Filter * -Property $pn | ?{$_.$pn -eq $username} | Select SamAccountName,Name,SID | Fl
				)
			if ($wmi -eq "2>")
				{
				$query | Out-File "$me\Desktop\User ($compname).txt"
				Write ""
				}
			else
				{
				$query
				}
			}	
		
		# 3. Running Processes Query
		elseif ($wmi -like "3*")
			{
			$query = $null
			$query = Get-WmiObject Win32_Process -ComputerName $compname | Group Name | Select Name,Count | Sort Name | Fl
			if ($wmi -eq "3>")
				{
				$query | Out-File "$me\Desktop\Processes ($compname).txt"
				Write ""
				}
			else
				{
				$query
				}
			}
	
		# 4. Total Physical Memory Query
		elseif ($wmi -like "4*")
            {
			$mem = $captot = $query = $res = $memory = $bank = $mess = $null
            Write ""
            $memory = Get-WmiObject Win32_PhysicalMemory -ComputerName $compname
	        $captot = $memory | Measure-Object -Property Capacity -Sum | ForEach-Object {[math]::Round(($_.Sum/1GB),2)}
            $gb = "GB"
            $query = @(
                $res = ForEach($mem in $memory)
                    {
                    $bank = $mem.BankLabel
                    if (($bank -eq $null) -or ($bank -eq ""))
                        {
                        $bank = "N/A"
                        }
                    New-Object -TypeName PSObject -Property @{
                        'Bank Label' = $bank
                        'Size (in MB)' = ForEach-Object {[math]::Round(($mem.Capacity/1MB),2)}
                        'Speed (in MHz)' = $mem.Speed
                        }
                    }
                 $res | Select 'Bank Label','Size (in MB)','Speed (in MHz)' | ft -AutoSize
                 )
            if ($wmi -eq "4>")
                {
                $mess = @()
                $mess += ''
                $mess += 'Total Physical Memory = '+$captot+$gb
                $mess += $query
                $mess | out-File "$me\Desktop\RAM ($compname).txt"
                }
            else
                {
                $mess = @()
                $mess += ''
                $mess += Write-Host "Total Physical Memory = $captot$gb" -ForegroundColor Yellow
                $mess += $query
                $mess
                }
	        }
	
		# 5. Active Storage Query
		elseif ($wmi -like "5*")
			{
			$query = $storage = $drive = $res = $null
			$storage = Get-WmiObject Win32_DiskDrive -ComputerName $compname
			$query = @(
				$res = ForEach($drive in $storage)
					{
					New-Object -TypeName PSObject -Property @{
						'Disk Drive' = $drive.Caption
						'Size (in GB)' = ForEach-Object {[math]::Round(($drive.Size/1GB),2)}
						}
					}
				$res | Select 'Disk Drive','Size (in GB)' | Ft -AutoSize
				)
			if ($wmi -eq "5>")
				{
				$query | Out-File "$me\Desktop\Storage ($compname).txt"
				Write ""
				}
			else
				{
				$query
				}
			}
			
		# 6. CPU Information Query
		elseif ($wmi -like "6*")
			{
			$query = $cpu = $speed = $cq = $lcq = $lcq2 = $cores = $res = $null
			$cpu = Get-WmiObject -Class Win32_Processor -ComputerName $compname
			$speed = $cpu.MaxClockSpeed
			$cq = $cpu.NumberOfCores
			$lcq = $cpu.NumberOfLogicalProcessors
			$lcq2 = $cq
			$lcq2 *= 2
			
			if ($cq -eq "1")
				{
				if ($lcq2 -eq $lcq)
					{
					$cores = "Single-Core w/ Hyperthreading"
					}
				else
					{
					$cores = "Single-Core"
					}
				}
			elseif ($cq -eq "2")
				{
				if ($lgc2 -eq $lcq)
					{
					$cores = "Dual-Core w/ Hyperthreading"
					}
				else
					{
					$cores = "Dual-Core"
					}
				}
			elseif ($cq -eq "4")
				{
				if ($lcq2 -eq $lcq)
					{
					$cores = "Quad-Core w/ Hyperthreading"
					}
				else
					{
					$cores = "Quad-Core"
					}
				}
			elseif ($cq -eq "6")
				{
				if ($lcq2 -eq $lcq)
					{
					$cores = "Hex-Core w/ Hyperthreading"
					}
				else
					{
					$cores = "Hex-Core"
					}
				}
			$query = @(
				$res = New-Object -TypeName PSObject -Property @{
					Name = $cpu.Name
					'Core Type' = $cores
					'Max Clock Speed (in GHz)' = ForEach-Object {[math]::Round(($speed/1000),3)}
					'L2 Cache Size (in KB)' = $cpu.L2CacheSize
					'L3 Cache Size (in KB)' = $cpu.L3CacheSize
					}
				$res | Select Name,'Core Type','Max Clock Speed (in GHz)','L2 Cache Size (in KB)','L3 Cache Size (in KB)' | Format-List
				)
			if ($wmi -eq "6>")
				{
				$query | Out-File "$me\Desktop\CPU ($compname).txt"
				Write ""
				}
			else
				{
				$query
				}
			}
	
		# 7. System Graphics Query
		elseif ($wmi -like "7*")
			{
			$gpu = $gpus = $name = $gpuram = $query = $res = $null
			$gpus = Get-WmiObject Win32_VideoController -ComputerName $compname
			$query = @(
				$res = ForEach($gpu in $gpus)
					{
					$name = $gpu.Name
					$gpuram = $gpu.AdapterRAM
					New-Object -TypeName PSObject -Property @{
						'GPU Name' = $name
						'VRAM (in MB)' = ForEach-Object {[math]::Round(($gpuram/1MB),2)}
						}
					}
				$res | Select 'GPU Name','VRAM (in MB)' | Ft -AutoSize
				)
			if ($wmi -eq "7>")
				{
				$query | Out-File "$me\Desktop\GPU ($compname).txt"
				Write ""
				}
			else
				{
				$query
				}
			}
		
		# End of Queries
		Write-Host 'Press "Enter" to query the computer again, or Type "x" to go to the menu: ' -ForegroundColor Green -NoNewLine
		$again = Read-Host
		Clear-Host
	} until (($again -like "*x*") -and ($again -ne "export"))
	}
else
	{
	Write ""
	Write-Host "   ----   Failed to establish a connection!   ----   " -ForegroundColor Red
	}
	
Write ""
Write-Host 'Hit "Enter" to query a different computer, or Type "x" to exit the session: ' -ForegroundColor Yellow -NoNewLine
$exit = Read-Host
Clear-Host
} until ($exit -eq "x")