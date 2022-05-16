Remove-PSSnapin WASP

$rtd = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
set-alias installutil (resolve-path (join-path $rtd installutil.exe))

installutil /u (Join-Path (Split-Path $MyInvocation.MyCommand.Path) WASP.dll)
