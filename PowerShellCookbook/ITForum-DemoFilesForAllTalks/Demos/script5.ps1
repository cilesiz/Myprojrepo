
#COLOR=YELLOW
#Requires -Version 1
# switch can work against single elements or collections
#COLOR=
$Ticker="MSFT","MSFt","Msft","msft"
    switch ($Ticker)
    {
        "MSFT"  {"Microsoft Corporation"}    
        "MSFT"  {"Microsoft is an awesome company"; 
#COLOR=RED
                 Continue}                 
#COLOR=
        "MSFT"  {"Microsoft funded the invention of PowerShell"}
        "MSFT"  {"I could go on and on about how I love Microsoft"}
        "IBM"   {"International Business Machines"}
        "GE"    {"General Electric Company"}
        default {"<UNKNOWN>"}
    }
