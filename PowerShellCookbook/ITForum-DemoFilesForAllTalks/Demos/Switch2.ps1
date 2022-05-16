#COLOR=YELLOW
#Requires -Version 1
# By Default, matching is case-insensitive
#COLOR=RED
foreach ($Ticker in "MSFT", "MSFt","MSft", "Msft", "msft")
#COLOR=
{
    switch ($Ticker)
    {
        "MSFT"  {"Microsoft Corporation"}
        "IBM"   {"International Business Machines"}
        "GE"    {"General Electric Company"}
        default {"<UNKNOWN>"}
    }
}