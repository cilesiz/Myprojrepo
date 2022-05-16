$env:Path += ";C:\Users\rorgo\bin;C:\Users\rorgo\bin\mpv"

Import-Module posh-git

$console = $host.UI.RawUI
$buffer = $console.BufferSize
$buffer.Width = 90
$buffer.Height = 2000
$console.BufferSize = $buffer
$size = $console.WindowSize
$size.Width = 90
$size.Height = 26
$console.WindowSize = $size
Clear-Host

Set-Alias grep Select-String
Set-Alias touch New-Item

function global:prompt {
    # Print current dir
    Write-Host ("[") -nonewline -foregroundcolor DarkGray
    Write-Host ($PWD) -nonewline -foregroundcolor Gray
    Write-Host ("]") -nonewline -foregroundcolor DarkGray

    #Git Status/Integration
    Write-VcsStatus

    # Print prompt symbol:
    Write-Host ("`n>>") -nonewline -foregroundcolor Green
return " ";
}
