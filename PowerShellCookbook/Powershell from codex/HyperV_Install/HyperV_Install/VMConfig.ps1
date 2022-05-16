  
Function Add-VMKVP
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        $VM="%", 
        
        [parameter(Mandatory = $true)]
        [String]$Key,
        
        [parameter(Mandatory = $true)]
        [String]$Value,
        
        [string]$Server = ".", 
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)  {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($VM -is [String]) {$VM = (Get-VM -Name $VM -server $Server)}
        if ($VM.count -gt 1 )  {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Add-KVP  -VM $_ @PSBoundParameters}} 
        if ($VM -is [System.Management.ManagementObject]) {
            $KvpItem = ([wmiclass]"\\$($vm.__server)\root\virtualization:Msvm_KvpExchangeDataItem").createinstance()
            $null=$KvpItem.psobject.properties #Without this the command will fail on Powershell V1 
            $KvpItem.Name = $key 
            $KvpItem.Data = $Value 
            $KvpItem.Source = 0 
            $VSMgtSvc = (Get-WmiObject -computerName $vm.__server -NameSpace  $HyperVNamespace -Class "MsVM_virtualSystemManagementService") 
            if ($force -or $psc.shouldProcess(($lStr_VirtualMachineName -f $vm.elementName ), ($lstr_KVPSet -f $key,$value))) {
                $result=$VSMgtSvc.AddKvpItems($VM, @($KvpItem.GetText([System.Management.TextFormat]::WmiDtd20)))     
                if     ($result.returnValue -eq 4096){test-wmijob $result.job -wait -Description $lstr_KVP_Waiting -StatusOnly } 
                elseif ($result.returnValue -eq 0)   {$lstr_KVPSetSucess -f $key,$Value,$vm.elementName  } else {write-error ($lstr_KVPSetFailure -f $key,$Value,$vm.elementName,$result )}
            }
        }
   }     
}      



function Add-VMRASD 
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true)]
        [System.Management.ManagementObject]$VM ,
        [parameter(Mandatory = $true)]
        [System.Management.ManagementObject]$RASD ,
        $PSC, 
        [switch]$force
    )
        if ($psc -eq $null) { $psc = $pscmdlet }
        $VSMgtSvc = Get-WmiObject -ComputerName $rasd.__Server -Namespace $HyperVNamespace -Class "MSVM_VirtualSystemManagementService"
        if ($force -or $psc.shouldProcess(($lStr_VirtualMachineName -f $vm.elementName ), ($lstr_CreateHW -f $Rasd.ElementName))) {
            $result = $VSMgtSvc.AddVirtualSystemResources($VM.__Path, @($Rasd.GetText([System.Management.TextFormat]::WmiDtd20)) )
            if ( ($result | Test-wmiResult -wait:$wait -JobWaitText ($lstr_CreateHW -f $Rasd.ElementName)`
                                           -SuccessText ($lstr_CreateHWSuccess -f $Rasd.ElementName, $VM.elementname) `
                                           -failText ($lstr_CreateHWFailure -f $Rasd.ElementName, $vm.elementname) ) -eq [returnCode]::ok) {
                                      IF ((Get-Module FailoverClusters) -and (Get-vmclusterGroup $VM)) {Sync-VMClusterConfig $vm | out-null }
                                      [wmi]$Result.NewResources[0] | Add-Member -passthru -name "VMElementName" -MemberType noteproperty -value $($vm.elementName) 
            }
    }
}


Function Get-VMCPUCount
{# .ExternalHelp  MAML-VMConfig.XML
    param(
        [parameter(ValueFromPipeLine = $true)]
        $VM="%",  
        
        [parameter()][ValidateNotNullOrEmpty()]
        $Server = "."        #May need to look for VM(s) on Multiple servers
        )
     Process {
         Foreach ($v in (Get-vmSettingData -vm $vm -server $server) ) {
             $v.getRelated("MsVM_ProcessorSettingData") |  Add-Member -passthru -name "VMElementName" -MemberType noteproperty   -value $($v.elementName) 
         }
     } 
}
Function Get-VMIntegrationComponent
{# .ExternalHelp  MAML-VMConfig.XML
    param(
        [parameter(ValueFromPipeline = $true)]
        $VM="%",
        
        [parameter()][ValidateNotNullOrEmpty()]
        $Server="."         #May need to look for VM(s) on Multiple servers
    )
    process {
        if ($VM -is [String]) {$VM=(Get-VM -Name $VM -Server $Server) }
        if ($vm.__CLASS -eq 'Msvm_ComputerSystem') { 
            (Get-vmSettingData -vm $vm -Server $Vm.__server).getRelated()  | where {$_.allocationUnits -eq "integration Components"}  |
               Add-Member -PassThru -Name "VMElementName" -MemberType NoteProperty -Value  $vm.elementName
        }
    }
} 
$LHash_suites=@{1="Small Business";2="Enterprise";4="BackOffice";8="Communications";16="Terminal";32="Small Business Restricted";64="Embedded NT";128="Data Center";256="Single User";512="Personal";1024="Blade"}

Function Get-VMKVP
{# .ExternalHelp  MAML-VMConfig.XML
    param(
        [parameter(ValueFromPipeline = $true)]
        $VM="%",
        
        [parameter()][ValidateNotNullOrEmpty()] 
        $Server = "."  #May need to look for VM(s) on Multiple servers
    )
    Process {
         if ($VM -is [String]) {$VM=(Get-VM -Name $VM -Server $Server) }
         if ($VM.count -gt 1 ) {$VM | foreach-Object {get-VMKVP -VM $_ -Server $Server} }
         if ($vm.__CLASS -eq 'Msvm_ComputerSystem') { 
             $KVPComponent=(Get-WmiObject -computername $VM.__Server -Namespace $HyperVNamespace -query "select * from Msvm_KvpExchangeComponent where systemName = '$($vm.name)'")
             if ($KVPComponent.GuestIntrinsicExchangeItems  ) {
                 ($KVPComponent.GuestIntrinsicExchangeItems + $KVPComponent.GuestExchangeItems ) | forEach-object `
                     -begin {$KVPObj = New-Object -TypeName System.Object 
                             Add-Member -inputObject $KvpObj -MemberType NoteProperty -Name "VMElementName" -Value $vm.elementName
                     } `
                     -process {([xml]$_).SelectNodes("/INSTANCE/PROPERTY") | forEach -process {if ($_.name -eq "Name") {$propName=$_.value}; if  ($_.name -eq "Data") {$Propdata=$_.value} } `
                                                                                     -end     {Add-Member -inputObject $KvpObj -MemberType NoteProperty -Name $PropName -Value $PropData}
                     }  `
                     -end {[string[]]$Descriptions=@()
                           if ($KvpObj.ProcessorArchitecture -eq 0)  {$descriptions += "x86" }
                           if ($KvpObj.ProcessorArchitecture -eq 9)  {$descriptions += "x64" }
                           if ($KvpObj.ProductType -eq 1 )           {$descriptions += "Workstation" }
                           if ($KvpObj.ProductType -eq 2 )           {$descriptions += "Domain Controller" }
                           if ($KvpObj.ProductType -eq 3 )           {$descriptions += "Server" } 
                           foreach  ($Key in $LHash_suites.keys) {
                                  if ($KvpObj.suiteMask -band $key)  {$descriptions += $suites.$key}
                           }
                           Add-Member -inputObject $KvpObj -MemberType NoteProperty -Name "Descriptions"  -Value $descriptions
                           $KvpObj
                     } 
             }
         }
    }
}

Function Get-VMMemory
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeLine = $true)]
        $VM="%", 
        
        [parameter()][ValidateNotNullOrEmpty()]
        $Server = "."
    )
    Process {
         Foreach ($v in (Get-vmSettingData -vm $vm -server $server) ) {
             $v.getRelated("MSVM_MemorySettingData") |  Add-Member -passthru -name "VMElementName" -MemberType noteproperty   -value $($v.elementName) 
         }
    }     
}
function Get-VMProcessor
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeLine = $true)]
        $VM="%", 
        
        [parameter()][ValidateNotNullOrEmpty()]
        $Server = "."         #May need to look for VM(s) on Multiple servers
    )
    process {
        if ($VM -is [String])  {$VM = Get-VM -Name $VM -Server $Server }
        if ($VM.count -gt 1 )   {$VM | foreach-Object { Get-VMProcessor -VM $_ -Server $Server} }    
        if ($vm.__CLASS -eq 'Msvm_ComputerSystem')   {
            Get-WmiObject -ComputerName $vm.__server -namespace $HyperVNamespace -Query "associators of {$($vm.__Path)} where resultclass=MSVM_Processor" |
                Add-Member -passthru -name "VMElementName" -MemberType noteproperty -value $($vm.elementName)  } 
    }
}

Function Get-VMSerialPort
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding()]
     param(
        [parameter(ValueFromPipeline = $true)]
        $VM="%", 
        
        [Alias("PortNo")]
        $PortNumber ,
        
        [parameter()][ValidateNotNullOrEmpty()]
        $Server = "."       #May need to look for VM(s) on Multiple servers
    )
    process {Foreach ($v in (Get-vmSettingData -vm $vm -server $server) ) {
                 $v.getRelated("MSVM_ResourceAllocationSettingData") | 
                   Where-Object {($_.ResourceSubType -eq "Microsoft Serial Port") -and ($_.Caption -like "*$PortNumber")}  |
                      Add-Member -passthru -name "VMElementName" -MemberType noteproperty   -value $($v.elementName) 
                } 
   }
}
Function Get-VMSettingData
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeLine = $true)]
        $VM="%", 
        
        [parameter()][ValidateNotNullOrEmpty()]        
        $Server = "."
    )
    process {
        if ($VM -is [String])  { $vm = Get-VM -Name $VM -Server $Server }
        if ($VM.count -gt 1 )   { $VM | ForEach-object { Get-VMSettingData -VM $_ -Server $Server} }
        if ($vm.__Class -eq "Msvm_VirtualSystemSettingData") { $VM }
        if ($vm.__Class -eq "Msvm_ComputerSystem")           {
            Get-WmiObject -ComputerName $vm.__server -namespace $HyperVNamespace -Query "associators of {$($vm.__Path)} where resultclass=MSVM_VirtualSystemSettingData" |
                 where-object {$_.instanceID -eq "Microsoft:$($vm.name)"} | Add-Member -passthru -name "VMElementName" -MemberType noteproperty   -value $($vm.elementName)                                                                
        }
    }
}
Function New-VMRASD
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
        [int]$ResType,   # The integers here are defined in the enum resourcetype.
                         # Needed as [int] below, and never passed as strings. 
        
        [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
        [string]$ResSubType, 
        
        [parameter()][ValidateNotNullOrEmpty()]
        [string]$Server = "."  #Only create resource allocation settings data objects on one server
    )
    
    $ac = ((Get-WmiObject -ComputerName $Server -Namespace $HyperVNamespace `
        -Query "SELECT * FROM MSVM_AllocationCapabilities WHERE ResourceType = $ResType AND ResourceSubType = '$ResSubType'").__Path).Replace("\", "\\")
    
    New-Object System.Management.ManagementObject((Get-WmiObject -ComputerName $Server -Namespace $HyperVNamespace `
        -Query "SELECT * FROM MSVM_SettingsDefineCapabilities WHERE ValueRange=0 AND GroupComponent = '$ac'").PartComponent)
}

Function Remove-VMKVP
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        $VM="%", 
        
        [parameter(Mandatory = $true)]
        [String]$Key,
        
        [parameter()][ValidateNotNullOrEmpty()]    
        $Server = ".",        #May need to look for VM(s) on Multiple servers
        
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)   {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($VM -is [String]) {$VM = (Get-VM -Name $VM -server $Server)}
        if ($VM.count -gt 1 )  {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Remove-VMKVP  -VM $_ @PSBoundParameters}} 
        if ($vm.__CLASS -eq 'Msvm_ComputerSystem') {
            $KvpItem = ([wmiclass]"\\$($VM.__Server)\root\virtualization:Msvm_KvpExchangeDataItem").createinstance()
            $null=$KvpItem.psobject.properties #Without this the command will fail on Powershell V1 
            $KvpItem.Name = $key 
            $KvpItem.Data = ""
            $KvpItem.Source = 0
            $VSMgtSvc = (Get-WmiObject -computerName $vm.__server -NameSpace  $HyperVNamespace -Class "MsVM_virtualSystemManagementService") 
            if ($force -or $psc.shouldProcess(($lStr_VirtualMachineName -f $vm.elementName ), ($lstrRemove  -f $key ))) {
               $result=$VSMgtSvc.RemoveKvpItems($VM, @($KvpItem.GetText([System.Management.TextFormat]::WmiDtd20)) )   
               if     ($result.returnValue -eq 4096){test-wmijob $Result.job -wait -Description $lstr_KVP_Waiting -StatusOnly } 
               elseif ($result.returnValue -eq 0)   {$lstr_KVPRemoveSucess -f $key,$vm.elementName} else {$lstr_KVPRemoveFailure -f $key,$vm.elementName,$result}
            }   
       }
    }   
}




Function Remove-VMRASD
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true)]
        $RASD ,
        
        $VM ,   # VM is discovered in the funtion, may be passed for backwards comapatibility
        $PSC, 
        [switch]$Force
    )
    if ($psc -eq $null) { $psc = $pscmdlet }
    $HWLabel  = $Rasd.elementName
    $VM  = Get-VM $rasd 
    $VSMgtSvc = Get-WmiObject -ComputerName $rasd.__Server -Namespace $HyperVNamespace -Class "MSVM_VirtualSystemManagementService"
    if ($force -or $psc.shouldProcess(($lStr_VirtualMachineName -f $vm.elementName ), ($lstr_RemoveHW -f $HWlabel))) {
         $result=$VSMgtSvc.RemoveVirtualSystemResources($VM.__Path, @( $Rasd.__Path )) 
         if     ( $result.returnValue -eq [returnCode]::OK)         {  IF ((Get-Module FailoverClusters) -and (Get-vmclusterGroup $VM)) {Sync-VMClusterConfig $vm | out-null }
                                                                       [returncode]::ok
                                                                       write-verbose ($lstr_RemoveHWSuccess -f $Hwlabel, $vm.elementname)
         }  
         elseif ( $result.returnValue -eq [returnCode]::JobStarted) {
             $job = Test-WMIJob -Wait -Job $result.job
             if     ($job.jobstate -eq [JobState]::completed )      { IF ((Get-Module FailoverClusters) -and (Get-vmclusterGroup $VM)) {Sync-VMClusterConfig $vm | out-null }
                                                                      [returncode]::ok
                                                                      write-verbose ($lstr_RemoveHWSuccess -f $Hwlabel, $vm.elementname)
             }  
             else                                                   { write-error   ($lstr_RemoveHWFailure -f $Hwlabel, $vm.elementname , $job.ErrorDescription ) }    
         }
         else                                                       { write-error   ($lstr_RemoveHWFailure -f $Hwlabel, $vm.elementname , [resultCode]$Result.returnValue) }
    }
}

Function Set-VMCPUCount
{# .ExternalHelp  MAML-VMConfig.XML
   [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        $VM,     
        
        [parameter()][ValidateRange(1,4)]
        $CPUCount , 
        
        $Limit, 
        $Reservation,
        $Weight,
        
        [parameter()][ValidateNotNullOrEmpty()]
        $Server = ".",       #May need to look for VM(s) on Multiple servers
        
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)  {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($psc -eq $null) { $psc = $pscmdlet ;  $PSBoundParameters.add("psc",$psc) }
        if ($VM -is [String]) {$VM=(Get-VM -Name $VM -server $server) }
        if ($VM.count -gt 1 )  {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Set-VMCPUCount -VM $_  @PSBoundParameters}}
        if ($vm.__CLASS -eq 'Msvm_ComputerSystem') {
            $procsSettingData=Get-VMCpuCount $VM 
            if ((($reservation -gt 0 -and $reservation -lt 100)) -or (($limit -gt 0) -and ($limit -lt 100))) {write-warning $LStr_CPUScalesWarning}
            if ($CPUCount    -ne $null) {$procsSettingData.VirtualQuantity=$CPUCount}
            if ($Reservation -ne $null) {$procsSettingData.Reservation = $Reservation}
            if ($Limit       -ne $null) {$procsSettingData.Limit = $Limit}
            if ($Weight      -ne $null) {$procsSettingData.weight = $Weight}
            Set-VMRASD -vm  $vm -rasd $procsSettingData -psc $psc             
        }
    }
 
}


Function Set-VMIntegrationComponent
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(ValueFromPipeline = $true)]
        $VM="%",
        
        [String[]]$ComponentName="*",
        
        [vmstate]$State,
        
        [parameter()][ValidateNotNullOrEmpty()]
        $Server=".",      #May need to look for VM(s) on Multiple servers
        $PSC, 
        [switch]$force
    )
    process {
        if ($psc -eq $null)   {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
            foreach ($c in $componentName)  {(get-vmSettingData -vm $vm -server $server) | foreach-object {$_.getRelated() |          #get-wmiobject  -computername $vm.__SERVER -namespace $HyperVNamespace  -Query "associators of {$vmsd}" | 
                                              where {($_.allocationUnits -eq "integration Components") -and ($_.elementName -like "$c*")} | 
                                                  foreach-object {If (-not $state) {$_.enabledState = ($_.enabledState -bxor 1)} 
                                                                  else             {$_.enabledState = [int]$state}
                                                                  Set-VMRASD  -rasd $_ -PSC $psc -force:$force                                             
                                                  }                  
                                        }
        }
   }
} 


Function Set-VMMemory
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        $VM, 
        
        [parameter(Mandatory = $true)][Alias("MemoryInBytes")]
        [long]$Memory, 
        
        $Server = ".",       #May need to look for VM(s) on Multiple servers
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)  {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($VM -is [String]) { $VM = Get-VM -Name $VM -Server $Server}
        if ($VM.count -gt 1 )  {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Set-VMMemory -VM $_ @PSBoundParameters}}
        if ($vm.__CLASS -eq 'Msvm_ComputerSystem') {
	       # The API takes the amount of memory in MB, in multiples of 2MB. 
           # Assume that anything less than 2097152 is in aready MB (we aren't assigning 2TB to the VM). If user enters "1024MB" or 0.5GB divide by 1MB  
           if (-not ($memory % 2mb))  {$memory /=  1mb}
           $SettingData      = Get-VMMemory -VM $VM
           $SettingData.Limit = $SettingData.Reservation =  $SettingData.VirtualQuantity = $Memory 
           Set-VMRASD -vm  $vm -rasd $SettingData -psc $psc  
        }
    }
}


function Set-VMRASD 
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [System.Management.ManagementObject]$VM , #VM no longer needed but kept for compatibility
        [parameter(Mandatory = $true)]
        $RASD ,
        $PSC, 
        [switch]$Force
    )
        if ($psc -eq $null) { $psc = $pscmdlet }
        $VSMgtSvc = Get-WmiObject -ComputerName $rasd.__Server -Namespace $HyperVNamespace -Class "MSVM_VirtualSystemManagementService"
        $VM  = Get-VM $rasd 
        if ($force -or $psc.shouldProcess(($lStr_VirtualMachineName -f $vm.elementName ), ($lstr_ModifyHW   -f $Rasd.ElementName))) {
             if ( ($VSMgtSvc.ModifyVirtualSystemResources($VM.__Path, @($Rasd.GetText([System.Management.TextFormat]::WmiDtd20)) ) |
                     Test-wmiResult -wait:$wait -JobWaitText ($lstr_ModifyHW -f $Rasd.ElementName)`
                                    -SuccessText ($lstr_ModifyHWSuccess -f $Rasd.ElementName, $VM.elementname) `
                                    -failText    ($lstr_ModifyHWFailure -f $Rasd.ElementName, $vm.elementname) ) -eq [returnCode]::ok) { 
                                    IF ((Get-Module FailoverClusters) -and (Get-vmclusterGroup $VM)) {Sync-VMClusterConfig $vm | out-null }
                                    $rasd.get() ;  $rasd
             }                       
        }
}


Function Set-VMSerialPort
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $VM, 
        
        [parameter()][Alias("PortNo")][ValidateNotNullOrEmpty()][ValidateRange(1,2)]
        [int]$PortNumber = 1, 
        

        [String]$Connection,   #need to allow empty string
        
        [parameter()][ValidateNotNullOrEmpty()]
        $Server = ".",         #May need to look for VM(s) on Multiple servers
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)  {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($VM -is [String]) { $VM = Get-VM -Name $VM -Server $Server }
        if ($VM.count -gt 1 ) {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Set-VMSerialPort -VM $_  @PSBoundParameters}}
        if ($vm.__CLASS -eq 'Msvm_ComputerSystem') {
            $comPortRASD = Get-VMSerialPort -VM $VM -PortNumber $PortNumber      
            $comPortRASD.Connection = $Connection
            Set-VMRASD -vm $vm -rasd $ComPortRASD -psc $psc
        }
    }
}

Function Sync-VMClusterConfig {
# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(ValueFromPipeLine = $true)]
        $VM="%",
        
        [parameter()][ValidateNotNullOrEmpty()]
        $Server = ".",
        $PSC,
        [switch]$Force
    )
    process {
        if (-not (get-command -Name Move-ClusterVirtualMachineRole -ErrorAction "SilentlyContinue")) {Write-warning $lstr_noCluster ; return}
        if ($psc -eq $null)   {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($VM -is [String]) {$VM=(Get-VM -Name $VM -server $server) }
        if ($VM.count -gt 1 )  {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Move-VM -VM $_  @PSBoundParameters}}
        if (($vm.__CLASS -eq 'Msvm_ComputerSystem') -and ($force -or $psc.shouldProcess(($lStr_VirtualMachineName -f $vm.elementName ), $lstr_syncConfig))) {
            Write-Progress -Activity $lstr_syncConfig -Status $vm.ElementName 
            Get-vmClusterGroup -vm $vm | Get-ClusterResource | where {($_.resourceType -like "Virtual Machine Configuration")}  | Update-ClusterVirtualMachineConfiguration
            Write-Progress -Activity $lstr_syncConfig -Status $vm.ElementName  -Completed
        }
    }
 }
 
