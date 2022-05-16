<#
.Synopsis
Function Find System Hardware Information local or remote computer is required Powershell Version 4
.EXAMPLE
Get-SystemInfo
Get-SystemInfo -Name Computername
Get-SystemInfo -Name Computer1,Computer2 -Cpu -Motheboard -Video -Memory -Monitor -HDD
Get-SystemInfo -Name Computer1 -Hdd -Properties CPUName,MboardModel
Get-SystemInfo -Hdd -Properties CPUName,MboardModel -ExportCsv -CsvPath d:\Systeminfo.csv
.EXAMPLE
Get-ADComputer -filter * | Get-SystemInfo -Cpu -Properties HddModel | Format-Table
Get-ADComputer -filter * | Get-SystemInfo -Cpu -Properties HddModel | where {$_.AvailableMemGb -ge "1,5"}
###########################################################################################

Gavrilyuk Sergey
12/02/2015
Email: sergey_abakan@bk.ru

#>
function Get-SystemInfo
{
    [CmdletBinding()]
    param(
            [parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,Position=0)]
            [Alias('CN','Computername','DnsHostname')]
            [string[]]$Name=$env:COMPUTERNAME,          
            [switch]$Cpu,
            [switch]$Motheboard,
            [switch]$Memory,
            [switch]$HDD,
            [switch]$Video,
            [switch]$Monitor,
            [ValidateSet("OsVersion","Speed","OsInstallDate","AvailableMemGb","FreeMemGb","MemSpeed","MemType","MemSlotUsed","MemModulesGb",
            "MemMaxInsGb","MemSlots","ECCType","SysDFreeSpaceGb","Mboard","MboardModel","DevModel","Cdrom","CdromMediatype","HddModel",
            "HddSizeGb","VideoModel","VideoRamMb","VideoProcessor","CPUName","CPUSocket","MaxClockSpeed","CPUCores","CPULogicalCore","MonManuf",
            "MonPCode","MonSN","MonName","MonYear")] 
            $Properties,
            [switch]$ExportCsv,
            [string]$CsvPath
            )

    Begin
    {
Write-Verbose "Begin"
$Propertys=@()
if ($Cpu.IsPresent)
    {
    $propertycpu="CPUName","CPUSocket","MaxClockSpeed","CPUCores","CPULogicalCore"
    $Propertys=$Propertys+$propertycpu
    }
if ($Motheboard.IsPresent)
    {
    $propertymotheboard="Mboard","MboardModel","DevModel"
    $Propertys=$Propertys+$propertymotheboard
    }
if ($Memory.IsPresent)
    {
    $PropertyMemory ="AvailableMemGb","FreeMemGb","MemModulesGb","MemSpeed","MemType","MemMaxInsGb","MemSlots"
    $Propertys=$Propertys+$PropertyMemory
    }
if ($HDD.IsPresent)
    {
    $prophdd="HddModel","HddSizeGb"
    $Propertys=$Propertys+$PropHdd
    }
if ($Video.IsPresent)
    {
    $propvideo="VideoModel","VideoRamMb","VideoProcessor"
    $Propertys=$Propertys+$propvideo
    }
if ($Monitor.IsPresent)
    {
    $propmon="MonManuf","MonName","MonPCode","MonSN","MonYear"
    $Propertys=$Propertys+$propmon
    }
if ($Properties -ne $null -and $Propertys.Count -ne $null)
    {
    $Propertys=$Propertys+$Properties
    }
    elseif($Propertys.Count -eq 0)
    {
    $propertys="OsVersion","CPUName","MboardModel","AvailableMemGb","HddSizeGb","VideoModel","MonName","Cdrom"
    }

#Хэш таблица классов ключ свойство значение класс
########################################################################################
$HashtableClass=@{
                          'OsVersion'='Win32_OperatingSystem';
                          'OsInstallDate'='Win32_OperatingSystem';
                          'AvailableMemGb'='Win32_OperatingSystem';
                          'FreeMemGb'='Win32_OperatingSystem'; 
                          'MemSpeed'='Win32_PhysicalMemory';
                          'MemType'='Win32_PhysicalMemory';
                          'MemSlotUsed'='Win32_PhysicalMemory'; 
                          'MemModulesGb'='Win32_PhysicalMemory'; 
                          'MemMaxInsGb'='Win32_PhysicalMemoryArray';
                          'MemSlots'='Win32_PhysicalMemoryArray'; 
                          'ECCType'='Win32_PhysicalMemoryArray';
                           'SysDFreeSpaceGb'='Win32_LogicalDisk'
                          'Mboard'='Win32_BaseBoard';
                           'MboardModel'='Win32_BaseBoard';
                           'DevModel'='Win32_Computersystem';
                          'Cdrom'='Win32_CDROMDrive';
                          'CdromMediatype'='Win32_CDROMDrive';
                          'HddModel'='Win32_DiskDrive';
                          'HddSizeGb'='Win32_DiskDrive';
                          "VideoModel"="Win32_VideoController"
                          "VideoRamMb"="Win32_VideoController"
                          "VideoProcessor"="Win32_VideoController"
                          "CPUName"="Win32_Processor";
                          "CPUSocket"="Win32_Processor";
                          "MaxClockSpeed"="Win32_Processor";
                          "CPUCores"="Win32_Processor";
                          "CPULogicalCore"="Win32_Processor";
                          "MonManuf"="wmiMonitorID";
                          "MonPCode"="wmiMonitorID";
                          "MonSN"="wmiMonitorID";
                          "MonName"="wmiMonitorID";
                          "MonYear"="wmiMonitorID"
                    }
$HashtableNamespace=@{
                        'OsVersion'="root\CIMV2";
                          'OsInstallDate'="root\CIMV2";
                          'AvailableMemGb'="root\CIMV2";
                          'FreeMemGb'="root\CIMV2"; 
                          'MemSpeed'="root\CIMV2";
                          'MemType'="root\CIMV2";
                          'MemSlotUsed'="root\CIMV2"; 
                          'MemModulesGb'="root\CIMV2"; 
                          'MemMaxInsGb'="root\CIMV2";
                          'MemSlots'="root\CIMV2"; 
                          'ECCType'="root\CIMV2";
                           'SysDFreeSpaceGb'="root\CIMV2";
                          'Mboard'="root\CIMV2";
                           'MboardModel'="root\CIMV2";
                           'DevModel'="root\CIMV2";
                          'Cdrom'="root\CIMV2";
                          'CdromMediatype'="root\CIMV2";
                          'HddModel'="root\CIMV2";
                          'HddSizeGb'="root\CIMV2";
                          "VideoModel"="root\CIMV2";
                          "VideoRamMb"="root\CIMV2";
                          "VideoProcessor"="root\CIMV2";
                          "CPUName"="root\CIMV2";
                          "CPUSocket"="root\CIMV2";
                          "MaxClockSpeed"="root\CIMV2";
                          "CPUCores"="root\CIMV2";
                          "CPULogicalCore"="root\CIMV2";
                          "MonManuf"="Root\wmi";
                          "MonPCode"="Root\wmi";
                          "MonSN"="Root\wmi";
                          "MonName"="Root\wmi";
                          "MonYear"="Root\wmi"

                            }
#########################################################################################
$MemoryTypeArray=@{'0'='Unknown or DDR3';'1'='Other';'2'='DRAM';'4' ="Cache DRAM";'5'='EDO';'6'='EDRAM';'7'='VRAM';'8'='SRAM';'9'='RAM';'10'='ROM';'11'='Flash';'12'='EEPROM';'13'='FEPROM';'14'='EPROM';'15'='CDRAM';'16'='3DRAM';'17'='SDRAM';'18'='SGRAM';'19'='RDRAM';'20'='DDR';'21'='DDR-2'}
$MemoryEccArray=@{'0'='Reserved';'1'='Other';'2'='Unknown';'3'='None';'4'='Parity';'5'='Single-bit ECC';'6'='Multi-bit ECC';'7'='CRC'}
##############
function sysobj ($computername, $Propertys)
    {
    
    <#$Finduserobj=Find-ADUsers $computername -Properties Lastlogon
    if ($Finduserobj.count -le 1)
        {
        $userfio=$Finduserobj.fio
        }
        else
            {
            $findobjusrfirstlogon=$Finduserobj | Sort-Object -Property lastlogon -Descending
            $userfio=($findobjusrfirstlogon[0]).fio
            }#> 
    $SysObject = New-Object System.Management.Automation.PSObject
    if ($userfio -ne $null)
    {
    $SysObject | Add-Member NoteProperty 'FIO' ($userfio)
    } 
    $SysObject | Add-Member NoteProperty 'Computername' ($computername) 
    $propertys | foreach{
    $class=$HashtableClass[$_]
    $namespace=$HashtableNamespace[$_]
    if ((Get-Variable -Name $class -ValueOnly 2>$null) -eq $null -and $ReqStatus -ne $false)
        {
        $GWmi=Get-WmiObject -class $class -Namespace $namespace -computername $computername 2>$null
                if ($?)
                    {
                    New-Variable -Name $class -Value $GWmi -Force
                   
                    #$w32req=Get-Variable -Name $w32class -ValueOnly 2>$null
                    
                    $ReqStatus=$True
                      
                    Write-Verbose -Message "Запрос $class $namespace выполнен!"
                    
                    }
                    else
                    {
                    Write-Verbose -Message "Запрос $class $namespace не выполнен!"
                    if($ReqStatus -eq $null)
                        {
                        $ReqStatus=$false
                        }
                    }
        
        }
        else
        {
        Write-Verbose "Запрос $class, $namespace отклонен"
        }
##################################################
#Результаты выполнения запросов
if ($Win32_OperatingSystem -ne $null)
    {
    $ver=$Win32_OperatingSystem.Version
    $osinstalldate=[Management.ManagementDateTimeConverter]::ToDateTime($Win32_OperatingSystem.installdate)
    $avmem=($Win32_OperatingSystem.TotalVisibleMemorySize / 1mb).ToString('F01')
    $frmem=($Win32_OperatingSystem.FreePhysicalMemory/1mb).ToString('F01')
    }
if ($Win32_PhysicalMemory -ne $null)
    {
    $sp=$Win32_PhysicalMemory | foreach {$_.Speed}
    $mt=$Win32_PhysicalMemory | foreach {$MemoryTypeArray[[string]$_.MemoryType]}
    $mu=$Win32_PhysicalMemory | foreach {$_.DeviceLocator}
    $mm=$Win32_PhysicalMemory | foreach {($_.Capacity/1gb).ToString('F01')}
    }

if ($Win32_PhysicalMemoryArray -ne $null)
    {
    $mmi=$Win32_PhysicalMemoryArray | foreach {($_.MaxCapacity/1mb).ToString('F01')}
    $ms=$Win32_PhysicalMemoryArray | foreach {$_.memorydevices}
    $ecct=$Win32_PhysicalMemoryArray| foreach{$MemoryEccArray[[string]$_.MemoryErrorCorrection]}
    }
if ($Win32_LogicalDisk -ne $null)
    {
    $sdfs=($Win32_LogicalDisk.freespace/1gb).ToString('F01')
    }
if ($Win32_DiskDrive -ne $null)
    {
    $hddm=$Win32_DiskDrive | foreach{$_.model};
    $hddsgb=$Win32_DiskDrive | foreach {($_.size/1gb).ToString('F01')}
    }
if ($Win32_VideoController -ne $null)
    {
    $Win32_VideoController | foreach {if ($_.name -notmatch "Radmin.+" -and $_.name -notmatch "DameWare.+")
                {
                $VName=$_.name
                $VRam=($_.AdapterRAM/1mb).ToString('F01')
                $VPr=$_.VideoProcessor
                } 
        }
    }
if ($wmiMonitorID -ne $null)
    {
            $dispmanuf = $null
            $dispproduct = $null
            $dispserial = $null
            $dispname  = $null
            $year = $null
            
            $wmiMonitorID.ManufacturerName | foreach {$dispmanuf += [char]$_}
            $wmiMonitorID.ProductCodeID | foreach {$dispproduct += [char]$_}
            $wmiMonitorID.SerialNumberID | foreach {$dispserial += [char]$_}
            $wmiMonitorID.UserFriendlyName | foreach {$dispname += [char]$_}
    }

$hashtableproperty=@{
            'OsVersion'=$Win32_OperatingSystem.Version;
            'OsInstallDate'=$osinstalldate;
            'AvailableMemGb'=$avmem;
            'FreeMemGb'=$frmem; 
            'MemSpeed'=$sp;
            'MemType'=$mt;
            'MemSlotUsed'=$mu;
            'MemModulesGb'=$mm;
            'MemMaxInsGb'=$mmi;
            'MemSlots'=$ms;
            'ECCType'=$ecct;
            'SysDFreeSpaceGb'=$sdfs;
            'Mboard'=$Win32_BaseBoard.Manufacturer;
            'MboardModel'=$Win32_BaseBoard.Product;
            'DevModel'=$Win32_Computersystem.model;
            'Cdrom'=$Win32_CDROMDrive.Caption;
            'CdromMediatype'=$Win32_CDROMDrive.MediaType;
            'HddModel'=$hddm;
            'HddSizeGb'=$hddsgb;
            'VideoModel'=$VName;
            'VideoRamMb'=$VRam;
            'VideoProcessor'=$VPr;
             'CPUName'=$Win32_Processor.Name;
            'CPUSocket'=$Win32_Processor.SocketDesignation;
            'MaxClockSpeed'=$Win32_Processor.MaxClockSpeed;
            'CPUCores'=$Win32_Processor.NumberOfCores;
            'CPULogicalCore'=$Win32_Processor.NumberOfLogicalProcessors;
            "MonManuf"=$dispmanuf;
            "MonPCode"=$dispproduct;
            "MonSN"=$dispserial;
            "MonName"=$dispname
            "MonYear"=$wmiMonitorID.YearOfManufacture
            }
$SysObject | Add-Member NoteProperty $_  ($hashtableproperty[$_])  
    }
$SysObject | Add-Member NoteProperty 'Status'  ($ReqStatus)
if ($ExportCsv.IsPresent)
    {
    Write-Verbose "Экспорт объекта в Csv"
    $SysObject | Export-Csv -Delimiter ";" -Encoding Default -Append -Path $CsvPath
    }
$SysObject
    }
    
$computers=@()
    }
Process
    {
Write-Verbose "Process"
    if ($Name -ne $null)
        {
        $computers=$computers+$Name
        }
    }
End
    {
Write-Verbose "End"
$computers | foreach {
    if (Test-Connection $_ -Count 1 -Quiet)
        {
        Write-Verbose "Вызов функции SysObj c параметрами $_, $propertys"
        sysobj $_ $propertys
        }
        else
        {
        Write-Verbose "$_ Недоступен!"
        $userfio=(Find-ADUsers $_ -UserLaterLogin).fio
        $SysObject = New-Object System.Management.Automation.PSObject
        if ($userfio -ne $null)
            {
            $SysObject | Add-Member NoteProperty 'FIO' ($userfio)
            } 
        $SysObject | Add-Member NoteProperty 'Computername' ($_) 
        $propertys | foreach {$SysObject | Add-Member NoteProperty $_ ($null)}
        $SysObject | Add-Member NoteProperty 'Status' ($false)
        $SysObject 
        }
    }
    
    }
}