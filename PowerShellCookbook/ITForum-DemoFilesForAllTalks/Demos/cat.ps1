#Requires -Version 2
param ($file)
$line = 0
$color = ""
Write-Host ""
Get-Content $file | % {
if ($_ -match "^#COLOR=")
{
   $x,$color = $_.Split("=")
}else
{
   if ($color)
   {
       Write-Host -ForegroundColor $Color ("{0,2} {1}" -f $line++, $_)
   }else
   {
       Write-Host ("{0,2} {1}" -f $line++, $_)
   }
}
}
