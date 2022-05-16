<#
Written by Ryan Ephgrave for ConfigMgr 2012 Right Click Tools
http://myitforum.com/myitforumwp/author/ryan2065/
#>

$ResourceID = $args[0]
$strServer = $args[1]
$strNamespace = $args[2]

$strQuery = "select * from SMS_FullCollectionMembership inner join SMS_Collection on SMS_Collection.CollectionID = SMS_FullCollectionMembership.CollectionID where SMS_FullCollectionMembership.ResourceID like '" + $ResourceID + "'"
Get-WmiObject -Namespace $strNamespace -ComputerName $strServer -Query $strQuery | ForEach-Object {
	$strQuery = "select * from SMS_ObjectContainerItem inner join SMS_ObjectContainerNode on SMS_ObjectContainerNode.ContainerNodeID = SMS_ObjectContainerItem.ContainerNodeID where SMS_ObjectContainerItem.InstanceKey like '" + $_.SMS_Collection.CollectionID + "'"
	$objWMISearch = Get-WmiObject -Namespace $strNamespace -ComputerName $strServer -Query $strQuery
	$ContainerID = 1
	$ContainerName = "Root"
	foreach ($instance in $objWMISearch){
		$ContainerName = $instance.SMS_ObjectContainerNode.Name
		$ContainerID = $instance.SMS_ObjectContainerNode.ContainerNodeID
	}
	$CompName = $_.SMS_FullCollectionMembership.Name
	$ColArray += ,@($_.SMS_Collection.Name,$ContainerName,$ContainerID)
}

$ColArray = $ColArray | Sort-Object @{Expression={$_[0]}; Ascending=$true}
foreach ($instance in $ColArray){
	$CheckNum = 0
	foreach ($inst in $ColIDArray){if ($inst -eq $instance[2]){$CheckNum = 1}}
	if ($CheckNum -eq 0){$ColIDArray += ,@($instance[1],$instance[2])}
}

foreach ($instance in $ColIDArray){
	$OutputArray += @($instance[0] + "`n")
	foreach ($inst in $ColArray){
		if ($inst[2] -eq $instance[1]){$OutputArray += @("---" + $inst[0] + "`n")}
	}
}

$Popup = New-Object -ComObject wscript.shell
$Popup.popup($OutputArray,0,"$CompName",0)
