#COLOR=YELLOW
#Requires -Version 1
# Here is an example where working against a collection
# of items is really powerful
## Example from "PowerShell In Action" Book
$au=$du=$su=0
#COLOR=RED
switch -regex -file c:\windows\Windowsupdate.log
#COLOR=
{
'START.*Finding updates.*AutomaticUpdates' {$au++}
'START.*Finding updates.*Defender'         {$du++}
'START.*Finding updates.*SMS'              {$su++}
}

"Automatic:$au   Defender:$du    SMS:$su"
