#COLOR=YELLOW
#Requires -Version 1
# Simple switch statement
#COLOR=
foreach ($Ticker in "MSFT", "GE", "IBM", "Cisco")
{
    switch ($Ticker)
    {
        "MSFT"  {"Microsoft Corporation"}
        "IBM"   {"International Business Machines"}
        "GE"    {"General Electric Company"}
        default {"<UNKNOWN>"}
    }
}