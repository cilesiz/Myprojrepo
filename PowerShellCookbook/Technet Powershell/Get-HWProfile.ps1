Param(
[cmdletbinding()]
    [Parameter(position=0,mandatory=$false)]
    [string]$Computer,
[cmdletbinding()]        
    [Parameter(position=0,mandatory=$false)]
    [string]$List
        )

# This function runs when the -List switch is used.
function HWInput()  {
#$filename = (read-host [Name of input file?])
$computers = (import-csv -Header "computer" $List).computer
$date = get-date -Format yyyyMMdd-hhmm
$queryresults = @()

foreach ($server in $computers){
$server = $server.ToUpper()

write-host "Working on $server..." -NoNewline

$newobject= New-Object System.Object
    $newobject | Add-Member -type NoteProperty -Name "ComputerName" -Value $server

# Manufactor
$systeminfo = Get-WmiObject Win32_computersystem -computername $server
$newobject | Add-Member -type NoteProperty -Name "Manufacturer" -Value $systeminfo.manufacturer
$newobject | Add-Member -type NoteProperty -Name "Model" -Value $systeminfo.model

# Serial
$serial = (Get-WmiObject -class Win32_bios -computername $server).serialnumber
$newobject | Add-Member -type NoteProperty -Name "SerialNumber" -Value $serial

# Operating System

$OS = Get-WmiObject Win32_operatingsystem -ComputerName $server
$OSver = $OS.caption                                
$OSver = $OSver.trimstart("Microsoft ")                                
$newobject | Add-Member -type NoteProperty -Name "Operating System" -Value $OSver

# OS Install
$OsInstall = $OS.installdate
    # Formatting VoodDoo
    $OsInstall = $OSinstall.substring(0,12)
    $OsInstall = $OSinstall.insert(4,"-")
    $OsInstall = $OSinstall.insert(7,"-")
    $OsInstall = $OSinstall.insert(10," @ ")
$newobject | Add-Member -type NoteProperty -Name "OS Install" -Value $OsInstall

# Last Boot Time
$BootTime = $OS.lastbootuptime
    # Formatting VoodDoo
    $BootTime = $BootTime.substring(0,12)
    $BootTime = $BootTime.insert(4,"-")
    $BootTime = $BootTime.insert(7,"-")
    $BootTime = $BootTime.insert(10," @ ")
$newobject | Add-Member -type NoteProperty -Name "LastBootTime" -Value $BootTime


# RAM
$installed = ($systeminfo).totalphysicalmemory
$installed = $installed/1GB
$installed = "{0:N0}" -f $installed
$newobject | Add-Member -type NoteProperty -Name "Installed RAM" -Value "$installed GB"

# Processors
$totalcores = 0
$totalprocs = 0
$procs = Get-WmiObject Win32_processor -ComputerName $server | measure-object
$procs = ($procs).count
$cores = Get-WmiObject Win32_processor -ComputerName $server | % ({
    $eachcore = $_.numberofcores
    $eachproc = $_.numberoflogicalprocessors
    $totalcores = $totalcores+$eachcore
    $totalprocs = $totalprocs+$eachproc
                                                                     })
$newobject | Add-Member -type NoteProperty -Name "# of Processors" -Value $procs
$newobject | Add-Member -type NoteProperty -Name "Cores" -Value $totalcores
$newobject | Add-Member -type NoteProperty -Name "Logical Processors" -Value $totalprocs
                                                                   
# Hardrives
$HDDCount = 0
$data = Get-WmiObject -Class Win32_logicaldisk -filter "drivetype=3" -computer $server | % ({
    $HDDCount++
    $driveletter = $_.deviceid
    $drivefree = $_.freespace
    $drivesize = $_.size

    #adjust output
    $drivefree = $drivefree/1GB
    $drivefree = "{0:N2}" -f $drivefree
    $drivesize = $drivesize/1GB
    $drivesize = "{0:N2}" -f $drivesize
    $driveused = ($drivesize-$drivefree)
    $driveused = "{0:N2}" -f $driveused
    $percentused = ((($drivesize-$drivefree)/$drivesize)*100)
    $percentused = "{0:N1}" -f $percentused

$newobject | Add-Member -type NoteProperty -Name "Drive-$HDDCount" -Value $driveletter
$newobject | Add-Member -type NoteProperty -Name "Drive-$HDDCount Free Space GB" -Value "$drivefree"
$newobject | Add-Member -type NoteProperty -Name "Drive-$HDDCount Used Space GB" -Value "$driveused"
$newobject | Add-Member -type NoteProperty -Name "Drive-$HDDCount Drive Size GB" -Value "$drivesize"
$newobject | Add-Member -type NoteProperty -Name "Drive-$HDDCount Percent Used %" -Value "$percentused"
                                                                                                })

write-host "Done!"
$queryresults += $newobject
                         }

$queryresults | export-csv "$date-HWResults.csv" -NoTypeInformation
                                }

# This function runs when the -Computer switch is used.
function HWServer()  {
$server = $Computer.ToUpper()
$queryresults = @()

write-host "Working on $server..." -NoNewline

$newobject = New-Object System.Object
    $newobject | Add-Member -type NoteProperty -Name "ComputerName" -Value $server

# Manufactor
$systeminfo = Get-WmiObject Win32_computersystem -computername $server
$newobject | Add-Member -type NoteProperty -Name "Manufacturer" -Value $systeminfo.manufacturer
$newobject | Add-Member -type NoteProperty -Name "Model" -Value $systeminfo.model

# Serial
$serial = (Get-WmiObject -class Win32_bios -computername $server).serialnumber
$newobject | Add-Member -type NoteProperty -Name "SerialNumber" -Value $serial

# Operating System

$OS = Get-WmiObject Win32_operatingsystem -ComputerName $server
$OSver = $OS.caption                                
$OSver = $OSver.trimstart("Microsoft ")                                
$newobject | Add-Member -type NoteProperty -Name "Operating System" -Value $OSver

# OS Install
$OsInstall = $OS.installdate
    # Formatting VoodDoo
    $OsInstall = $OSinstall.substring(0,12)
    $OsInstall = $OSinstall.insert(4,"-")
    $OsInstall = $OSinstall.insert(7,"-")
    $OsInstall = $OSinstall.insert(10," @ ")
$newobject | Add-Member -type NoteProperty -Name "OS Install" -Value $OsInstall

# Last Boot Time
$BootTime = $OS.lastbootuptime
    # Formatting VoodDoo
    $BootTime = $BootTime.substring(0,12)
    $BootTime = $BootTime.insert(4,"-")
    $BootTime = $BootTime.insert(7,"-")
    $BootTime = $BootTime.insert(10," @ ")
$newobject | Add-Member -type NoteProperty -Name "LastBootTime" -Value $BootTime

# RAM
$installed = ($systeminfo).totalphysicalmemory
$installed = $installed/1GB
$installed = "{0:N0}" -f $installed
$newobject | Add-Member -type NoteProperty -Name "Installed RAM" -Value "$installed GB"

# Processors
$totalcores = 0
$totalprocs = 0
$procs = Get-WmiObject Win32_processor -ComputerName $server | measure-object
$procs = ($procs).count
$cores = Get-WmiObject Win32_processor -ComputerName $server | %({
    $eachcore = $_.numberofcores
    $eachproc = $_.numberoflogicalprocessors
    $totalcores = $totalcores+$eachcore
    $totalprocs = $totalprocs+$eachproc
                                                                })

$newobject | Add-Member -type NoteProperty -Name "# of Processors" -Value $procs
$newobject | Add-Member -type NoteProperty -Name "Cores" -Value $totalcores
$newobject | Add-Member -type NoteProperty -Name "Logical Processors" -Value $totalprocs

# Hardrives
$HDDCount = 0
$data = Get-WmiObject -Class Win32_logicaldisk -filter "drivetype=3" -computer $server | % ({
    $HDDCount++
    $driveletter = $_.deviceid
    $drivefree = $_.freespace
    $drivesize = $_.size

    #adjust output
    $drivefree = $drivefree/1GB
    $drivefree = "{0:N2}" -f $drivefree
    $drivesize = $drivesize/1GB
    $drivesize = "{0:N2}" -f $drivesize
    $driveused = ($drivesize-$drivefree)
    $driveused = "{0:N2}" -f $driveused
    $percentused = ((($drivesize-$drivefree)/$drivesize)*100)
    $percentused = "{0:N1}" -f $percentused

$newobject | Add-Member -type NoteProperty -Name "Drive-$HDDCount" -Value $driveletter
$newobject | Add-Member -type NoteProperty -Name "Drive-$HDDCount Free Space" -Value "$drivefree GB"
$newobject | Add-Member -type NoteProperty -Name "Drive-$HDDCount Used Space" -Value "$driveused GB"
$newobject | Add-Member -type NoteProperty -Name "Drive-$HDDCount Drive Size" -Value "$drivesize GB"
$newobject | Add-Member -type NoteProperty -Name "Drive-$HDDCount Percent Used" -Value "$percentused %"

                         }) 
                         
write-host "Done!"

$queryresults += $newobject                               
$queryresults | FL
                                }

# Text for Errors
function displayhelp() {
$HelpMsg = @"


        To use this script, please run it with one of the following parameters:

          -  For Single Computer Use:
                HWScript.ps1 -Computer <computername>

          -  For Using a List of Computers:
                HWScript.ps1 -List <filename.csv>
                 **Please note that the input file must have a column header of 'Computer'


        Thank you for using my Hardware Discovery Script!
                                    - Christopher Ream


"@
write-host $HelpMsg

                        }

# Function determination
if ($List -ne "") {HWInput $List}
if ($Computer -ne "") {HWServer $Computer}
if ($Computer -eq "" -and $List -eq "") {displayhelp}
else{}