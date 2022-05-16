$UserProperty = @{n="User";e={(New-Object System.Security.Principal.SecurityIdentifier $_.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])}}
$TypeProperty = @{n="Action";e={if($_.EventID -eq 7001) {"Logged on"} else {"Logged off"}}}
$TimeProeprty = @{n="Time";e={$_.TimeGenerated}}

$event = Get-EventLog System -Source Microsoft-Windows-Winlogon | select $UserProperty,$TypeProperty,$TimeProeprty -First 1 | fl | Out-String 
$MailSecurePass = Get-Content d:\securepass\Credential\SecurePasswordFile.PW | ConvertTo-SecureString
#Replace your User name here!
$MailUserName = "contoso\username" 
$MailCred = New-Object System.Management.Automation.PsCredential($MailUserName,$MailSecurePass)
$Body1 = "$event On $env:COMPUTERNAME"  | Out-String
$date = Get-Date
#Replace your service accoount , Destination email address , SMTP Server
Send-MailMessage -From Service@contoso.com -To admin@contoso.com -Subject "$env:computername $date"   -body $body1 -SmtpServer CAS.Contoso.com  -Credential $MailCred


