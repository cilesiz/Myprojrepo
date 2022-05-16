#Requires -Version 1
Function Should-Process ($Operation, $Target, [REF]$AllAnswer, $Warning = "", [Switch]$Verbose, [Switch]$Confirm, [Switch]$Whatif)
{
   # Check to see if "YES to All" or "NO to all" has previously been selected
   # Note that this technique requires the [REF] attribute on the variable.
   if ($AllAnswer.Value -eq $false)
   {  return $false
   }elseif ($AllAnswer.Value -eq $true)
   {  return $true
   }



   if ($Whatif)
   {  Write-Host "What if: Performing operation `"$Operation`" on Target `"$Target`""
      return $false
   }
   if ($Confirm)
   {
      $ConfirmText = @"
Confirm
Are you sure you want to perform this action?
Performing operation "$Operation" on Target "$Target". $Warning
"@
      Write-Host $ConfirmText
      while ($True)
      {
         $answer = Read-Host @"
[Y] Yes  [A] Yes to All  [N] No  [L] No to all  [S] Suspend  [?] Help (default is "Y")
"@
         switch ($Answer)
         {
           "Y"   { return $true}
           ""    { return $true}
           "A"   { $AllAnswer.Value = $true; return $true }
           "N"   { return $false }
           "L"   { $AllAnswer.Value = $false; return $false }
           "S"   { $host.EnterNestedPrompt(); Write-Host $ConfirmText }
           "?"   { Write-Host @"
Y - Continue with only the next step of the operation.
A - Continue with all the steps of the operation.
N - Skip this operation and proceed with the next operation.
L - Skip this operation and all subsequent operations.
S - Pause the current pipeline and return to the command prompt. Type "exit" to resume the pipeline.
"@
                 }
         }
      }
   }
   if ($verbose)
   {
     Write-Verbose "Performing `"$Operation`" on Target `"$Target`"."
   }

   return $true
}


#COLOR=YELLOW
# The PowerShell Team blog provides the Should-Process function above which allows you 
# to support -Whatif -Verbose -Debug
# http://blogs.msdn.com/powershell/archive/2007/02/25/supporting-whatif-confirm-verbose-in-scripts.aspx
#COLOR=


#COLOR=RED
function Stop-Calc ([Switch]$Verbose, [Switch]$Confirm, [Switch]$Whatif)
#COLOR=
{
    $AllAnswer = $null
    foreach ($p in Get-Process calc)
#COLOR=RED
    {   if (Should-Process Stop-Calc $p.Id ([REF]$AllAnswer) "`n***Are you crazy?" -Verbose:$Verbose -Confirm:$Confirm -Whatif:$Whatif)
#COLOR=
        {  Stop-Process $p.Id
        }
    }
}

#COLOR=Yellow
############ RUN IT #########################
#COLOR=
$VerbosePreference="Continue"
    calc;calc;calc
Stop-Calc -Whatif
    "`n"
Stop-Calc -Confirm
    "`n"
Start-sleep 1
Stop-Calc -Verbose