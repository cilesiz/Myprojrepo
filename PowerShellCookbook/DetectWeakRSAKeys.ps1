#************************************************
# DetectWeakRSAKeys.ps1
# Version 1.1
# Date: 08/01/2012 
# Author: Tim Springston [MSFT]
# Description:  Detects certificates in the My stores which have keys less than 1024 length.
#************************************************
cls

$Now = Get-Date
$ErrorString = "This certificate has a weak key.  If services or applications rely on this certificate they would fail with default security settings which disallow use of weak RSA keys."
$Certindex = 0
$DetectedCertList = @()
$CheckStores = @("My", "CA", "Root")

#Look through the MY, CA, and ROOT stores for certificates with keys smaller than 1024 and the RSA OID value.  Don't look in "empty" containers, the Root Agency certificate in the CA store, and don't return expired or not yet valid certificates.
get-childitem -path cert:\ -recurse | Where-Object {($_.PSParentPath -ne $null) -and ($_.PublicKey.Key.Keysize -le 1023) -and ($_.PublicKey.Oid.Value -eq '1.2.840.113549.1.1.1') -and ($CheckStores -contains (Split-Path ($_.PSParentPath) -Leaf)) -and ($_.IssuerName.Name -ne "CN=Root Agency") -and (-not($_.NotAfter -lt $Now)) -and (-not($_.NotBefore -gt $Now)) } | % {
	$Store = (Split-Path ($_.PSParentPath) -Leaf)
	$InformationCollected = new-object PSObject
	$StoreWorkingContext = $Store
	$StoreContext = Split-Path $_.PSParentPath.Split("::")[-1] -Leaf
	$Certindex += 1
	
	#Place helpful information about the certificate in a PSObject.
	
	#Certificates don't have to have Friendly Names, so only show one if its there. Show NONE if not.
	if ($_.FriendlyName.length -gt 0)
	{
		add-member -inputobject $InformationCollected -membertype noteproperty -name "Friendly Name" -value $_.FriendlyName
	}
	else
	{
		add-member -inputobject $InformationCollected -membertype noteproperty -name "Friendly Name" -value '[None]'
	}
	add-member -inputobject $InformationCollected -membertype noteproperty -name "Path" -value $StoreContext
	add-member -inputobject $InformationCollected -membertype noteproperty -name "Store" -value $Store
	add-member -inputobject $InformationCollected -membertype noteproperty -name "Has Private Key" -value $_.HasPrivateKey
	add-member -inputobject $InformationCollected -membertype noteproperty -name "Serial Number" -value $_.SerialNumber
	add-member -inputobject $InformationCollected -membertype noteproperty -name "Thumbprint" -value $_.Thumbprint
	add-member -inputobject $InformationCollected -membertype noteproperty -name "Issuer" -value $_.IssuerName.Name
	add-member -inputobject $InformationCollected -membertype noteproperty -name "Not Before" -value $_.NotBefore
	add-member -inputobject $InformationCollected -membertype noteproperty -name "Not After" -value $_.NotAfter
	add-member -inputobject $InformationCollected -membertype noteproperty -name "Subject Name" -value $_.SubjectName.Name
	add-member -inputobject $InformationCollected -membertype noteproperty -name "Public Key Name" -value $_.PublicKey.Oid.FriendlyName
	add-member -inputobject $InformationCollected -membertype noteproperty -name "Public Key OID" -value $_.PublicKey.Oid.Value
	add-member -inputobject $InformationCollected -membertype noteproperty -name "Public Key Size" -value $_.PublicKey.Key.Keysize
	
	#Certificates don't have to have SANs, so only show one if its there. Show NONE if not.
	$SubjectAlternativeName = ($_.Extensions | Where-Object {$_.Oid.FriendlyName -match "subject alternative name"})
	if ($SubjectAlternativeName -ne $null)
	{
		add-member -inputobject $InformationCollected -membertype noteproperty -name "Subject Alternative Name" -value $SubjectAlternativeName.Format(1)
	}
	else
	{
		add-member -inputobject $InformationCollected -membertype noteproperty -name "Subject Alternative Name" -value "[None]"
	}
	
	#Certificates don't have to have Key Usage, so only show them if its there. Show NONE if not.
	$KeyUsage = ($_.Extensions | Where-Object {$_.Oid.FriendlyName -like "Key Usage"})
	 if ($KeyUsage -ne $null) 
	{
		add-member -inputobject $InformationCollected -membertype noteproperty -name "Key Usage" -value $KeyUsage.Format(1)
	}
	else
	{
		add-member -inputobject $InformationCollected -membertype noteproperty -name "Key Usage" -value "[None]"
	}
	
	#Certificates don't have to have Enhanced Key Usage, so only show them if its there. Show NONE if not.
	$EnhancedKeyUsage = ($_.Extensions | Where-Object {$_.Oid.FriendlyName -like "Enhanced Key Usage"})
	if ($EnhancedKeyUsage -ne $null)
	{
		add-member -inputobject $InformationCollected -membertype noteproperty -name "Enhanced Key Usage" -value $EnhancedKeyUsage.Format(1)
	}
	else
	{
		add-member -inputobject $InformationCollected -membertype noteproperty -name "Enhanced Key Usage" -value "[None]"
	}
	
	#Certificates don't have to have been issued from a CA or template, so only show one if its there. Show NONE if not.
	$CertificateTemplateInformation = ($_.Extensions | Where-Object {$_.Oid.FriendlyName -match "Certificate Template Information"})
	if ($CertificateTemplateInformation -ne $null)
	{
		add-member -inputobject $InformationCollected -membertype noteproperty -name "Certificate Template Information" -value $CertificateTemplateInformation.Format(1)
	}
	else
	{
		add-member -inputobject $InformationCollected -membertype noteproperty -name "Certificate Template Information" -value "[None]"
	}
	
	#Return the error message to the PS console.
	Write-Warning -Message $ErrorString 
	
	#Return the certificate information to the PS console.
	$InformationCollected 
	
	#Clear the PSObject for the next certificate which matches the criteria if there is one.
	$InformationCollected = $null
}
