#Requires -Version 2
cmdlet
param(
    [MANDATORY]
    [POSITION(0)]
    [ValidateNotNullOrEmpty]
    [Alias("Name","path")]
    [ValidatePattern(".ps1")]
    [ValueFromPipeline]
    [String]$Fullname = "test.ps1",
    [Int]$Width = 80
)
process
{
    Write-Verbose "$FullName"
    $file =  Get-Content ($FullName)
    for ($i = 0; $i -lt $File.Count; $i++)
    {
        if ($File[$i].Length -gt $Width)
        {
            $error = @{}
            $error.Width = $File[$i].Length
            $error.FileName = $FullName
            $error.LineNumber = $i
            $error.Line = $File[$i]
            Write-Output $error
        }
    }
}


