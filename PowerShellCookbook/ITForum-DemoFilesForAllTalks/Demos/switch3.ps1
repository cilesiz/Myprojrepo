#COLOR=YELLOW
#Requires -Version 1
# When a match occurs, patterns continue to be evaluated.
# All that match are run.
#COLOR=
foreach ($Ticker in "MSFT")
{
    switch ($Ticker)
    {
#COLOR=RED
        "MSFT"  {"Microsoft Corporation"}    
        "MSFT"  {"Microsoft is an awesome company"}
        "MSFT"  {"Microsoft funded the invention of PowerShell"}
        "MSFT"  {"I could go on and on about how I love Microsoft"}
#COLOR=
        "IBM"   {"International Business Machines"}
        "GE"    {"General Electric Company"}
        default {"<UNKNOWN>"}
    }
}