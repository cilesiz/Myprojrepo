#COLOR=YELLOW
#Requires -Version 1
# Here is an example where working against a collection
# of items is really powerful
## Example from "PowerShell In Action" Book
$ps1=$txt=$xml=0
#COLOR=RED
switch -wildcard (dir .)
#COLOR=
{
    *.ps1   {$PS1++}
    *.txt   {$txt++}
    *xml    {$xml++}
}

"PS1: $ps1   TXT: $txt   XML: $xml"
