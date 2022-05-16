#COLOR=YELLOW
#Requires -Version 1
# One of the cool things about PowerShell's switch is that it can work 
# against a collection of objects
#COLOR=RED
switch ("MSFT", "MSFt","MSft", "Msft", "msft")
#COLOR=
{
    "MSFT"  {"Microsoft Corporation"}
    "IBM"   {"International Business Machines"}
    "GE"    {"General Electric Company"}
    default {"<UNKNOWN>"}
}
