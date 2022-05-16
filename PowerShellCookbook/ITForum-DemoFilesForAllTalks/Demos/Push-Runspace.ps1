#Push-Runspace function.


Function PrintUsage
{
	Write-Host "Please pass a valid Runspace object."
	Write-Host "Usage:"
	Write-Host "Push-Runspace `$runspace"
}


function Push-Runspace ($r) {
	#New-Runspace $r

	if ($r -eq $null)
	{
		PrintUsage
		return
	}
	elseif ($r.GetType().Name -ne "RemoteRunspaceInfo")
	{
		PrintUsage
		return
	}

	while ($r)
		{
			$compName=$r.ComputerName
                        $Myprompt = Invoke-Expression -Runspace $r -command 'get-Location'
			write-debug $Myprompt 
			$Provider = $Myprompt.Provider.Name
			$Location = $Myprompt.Path
			$PrintedPrompt = $compName + ":\" + $Provider + " | " + $Location 
			write-debug $PrintedPrompt 
			Write-host -For Green $PrintedPrompt -NoNewline:$true
			write-host -For Red ">" -NoNewLine:$false
			write-host -For Green "PS" -NoNewLine:$true
			write-host -For Red ">" -NoNewLine:$true
			$command=Read-Host

			If (($command -eq "Pop-Runspace") -or ($command -eq "exit"))
				{
					return
				}
			elseif ($command.Length -eq 0)
				{
					#do nothing
				}
			else
				{
					Invoke-Expression -ev ieerror -ea silentlycontinue  -runspace $r -Command $command | Out-String -stream
					if ($ieerror.count -gt 0)
						{							
							Write-Host -For Red $ieerror
							remove-variable ieerror
						}
				}

		}


}


