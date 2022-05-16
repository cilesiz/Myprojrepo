$query = "ASSOCIATORS OF {Win32_Account.Name='hhradile',Domain='sa1.ford.com'} WHERE ResultRole=GroupComponent ResultClass=Win32_Account"
Get-WMIObject -Query $query | Select Name