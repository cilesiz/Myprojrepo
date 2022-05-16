#COLOR=YELLOW
#Requires -Version 1
# When a match occurs, patterns continue to be evaluated.
# You can stop evaluation by using a BREAK
#COLOR=
foreach ($Ticker in "MSFT")
{
    switch ($Ticker)
    {
        "MSFT"  {"Microsoft Corporation";
#COLOR=RED
                 break}                 
#COLOR=
        "MSFT"  {"Microsoft is an awesome company"} 
        "MSFT"  {"Microsoft funded the invention of PowerShell"}
        "MSFT"  {"I could go on and on about how I love Microsoft"}
        "IBM"   {"International Business Machines"}
        "GE"    {"General Electric Company"}
        default {"<UNKNOWN>"}
    }
}