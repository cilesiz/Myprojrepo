function Get-LHSOSInfo 
{
<#
.SYNOPSIS
    Gets information about the operating system on local or remote Computers

.DESCRIPTION
    Retrieves operating system information using WMI

.PARAMETER ComputerName
    Specifies one or more computer names to query. Accepts pipeline input.

.EXAMPLE
    Get-LHSOSInfo -computername Pc1

	ComputerName     : PC1
	OS               : Microsoft Windows 7 Professional 
	Version          : 6.1.7601
	BuildNumber      : 7601
	ServicePack      : Service Pack 1
	OSArchitecture   : 64-Bit
	MUILanguages     : de-DE
	OSLanguage       : 1031
	BootDevice       : \Device\HarddiskVolume2
	SystemDevice     : \Device\HarddiskVolume2
	WindowsDirectory : C:\Windows
	InstallDate      : 10.02.2014 12:28:36
	LastBootUptime   : 24.09.2014 12:26:00

.EXAMPLE
    Get-Content names.txt | Get-LHSOSInfo

.INPUTS
    You can pipe ComputerNames to this Function 
    
.OUTPUTS
    custom PSObject 
		
.Notes 
    AUTHOR: Pasquale Lantella 
    LASTEDIT: 24.9.2014 
    KEYWORDS: OS, Uptime, LastBootUpTime

#Requires -Version 2.0
#>

[CmdletBinding()]
[OutputType('System.PSObject')] 

param (
	[Parameter(Position=0,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,
        HelpMessage='An array of computer names. The default is the local computer.')]
    [alias("CN")]
	[string[]]$ComputerName = $ENV:ComputerName
)

BEGIN {

    Set-StrictMode -Version Latest
    ${CmdletName} = $Pscmdlet.MyInvocation.MyCommand.Name

    Function Get-OSArchitecture {

    param (
        [string]$ComputerName
    )
    
    $OSarc = (Get-WMIObject win32_computersystem -ComputerName $ComputerName).SystemType 
    If ( $OSarc -match '86') { return "32-Bit"}
    ElseIF ( $OSarc -match '64' ){ return "64-Bit" }
    Else { return $Null }

    } # end Function Get-OSArchitecture


function Get-Language 
{
    ## Helper Function
    ## for language and locale settings see
    ## http://msdn.microsoft.com/en-us/goglobal/bb964664.aspx
    ##
    param(
	    [int]$type
    )
    $lang = DATA {
    ConvertFrom-StringData -StringData @'
1078 = Afrikaans - South Africa
1052 = Albanian - Albania
1118 = Amharic - Ethiopia
1025 = Arabic - Saudi Arabia
5121 = Arabic - Algeria
15361 = Arabic - Bahrain
3073 = Arabic - Egypt
2049 = Arabic - Iraq
11265 = Arabic - Jordan
13313 = Arabic - Kuwait
12289 =	Arabic - Lebanon
4097 = Arabic - Libya
6145 = Arabic - Morocco
8193 = Arabic - Oman
16385 = Arabic - Qatar
10241 = Arabic - Syria
7169 = Arabic - Tunisia
14337 = Arabic - U.A.E.
9217 = Arabic - Yemen
1067 = Armenian - Armenia
1101 = Assamese
2092 = Azeri (Cyrillic)
1068 = Azeri (Latin)
1069 = Basque
1059 = Belarusian
1093 = Bengali (India)
2117 = Bengali (Bangladesh)
5146 = Bosnian (Bosnia/Herzegovina)
1026 = Bulgarian
1109 = Burmese
1027 = Catalan
1116 = Cherokee - United States
2052 = Chinese - People's Republic of China
4100 = Chinese - Singapore
1028 = Chinese - Taiwan
3076 = Chinese - Hong Kong SAR
5124 = Chinese - Macao SAR
1050 = Croatian
4122 = Croatian (Bosnia/Herzegovina)
1029 = Czech
1030 = Danish
1125 = Divehi
1043 = Dutch - Netherlands
2067 = Dutch - Belgium
1126 = Edo
1033 = English - United States
2057 = English - United Kingdom
3081 = English - Australia
10249 = English - Belize
4105 = English - Canada
9225 = English - Caribbean
15369 = English - Hong Kong SAR
16393 = English - India
14345 = English - Indonesia
6153 = English - Ireland
8201 = English - Jamaica
17417 = English - Malaysia
5129 = English - New Zealand
13321 = English - Philippines
18441 = English - Singapore
7177 = English - South Africa
11273 = English - Trinidad
12297 = English - Zimbabwe
1061 = Estonian
1080 = Faroese
1065 = Farsi
1124 = Filipino
1035 = Finnish
1036 = French - France
2060 = French - Belgium
11276 = French - Cameroon
3084 = French - Canada
9228 = French - Democratic Rep. of Congo
12300 = French - Cote d'Ivoire
15372 = French - Haiti
5132 = French - Luxembourg
13324 = French - Mali
6156 = French - Monaco
14348 = French - Morocco
58380 = French - North Africa
8204 = French - Reunion
10252 = French - Senegal
4108 = French - Switzerland
7180 = French - West Indies
1122 = Frisian - Netherlands
1127 = Fulfulde - Nigeria
1071 = FYRO Macedonian
2108 = Gaelic (Ireland)
1084 = Gaelic (Scotland)
1110 = Galician
1079 = Georgian
1031 = German - Germany
3079 = German - Austria
5127 = German - Liechtenstein
4103 = German - Luxembourg
2055 = German - Switzerland
1032 = Greek
1140 = Guarani - Paraguay
1095 = Gujarati
1128 = Hausa - Nigeria
1141 = Hawaiian - United States
1037 = Hebrew
1081 = Hindi
1038 = Hungarian
1129 = Ibibio - Nigeria
1039 = Icelandic
1136 = Igbo - Nigeria
1057 = Indonesian
1117 = Inuktitut
1040 = Italian - Italy
2064 = Italian - Switzerland
1041 = Japanese
1099 = Kannada
1137 = Kanuri - Nigeria
2144 = Kashmiri
1120 = Kashmiri (Arabic)
1087 = Kazakh
1107 = Khmer
1111 = Konkani
1042 = Korean
1088 = Kyrgyz (Cyrillic)
1108 = Lao
1142 = Latin
1062 = Latvian
1063 = Lithuanian
1086 = Malay - Malaysia
2110 = Malay - Brunei Darussalam
1100 = Malayalam
1082 = Maltese
1112 = Manipuri
1153 = Maori - New Zealand
1102 = Marathi
1104 = Mongolian (Cyrillic)
2128 = Mongolian (Mongolian)
1121 = Nepali
2145 = Nepali - India
1044 = Norwegian (Bokmål)
2068 = Norwegian (Nynorsk)
1096 = Oriya
1138 = Oromo
1145 = Papiamentu
1123 = Pashto
1045 = Polish
1046 = Portuguese - Brazil
2070 = Portuguese - Portugal
1094 = Punjabi
2118 = Punjabi (Pakistan)
1131 = Quecha - Bolivia
2155 = Quecha - Ecuador
3179 = Quecha - Peru
1047 = Rhaeto-Romanic
1048 = Romanian
2072 = Romanian - Moldava
1049 = Russian
2073 = Russian - Moldava
1083 = Sami (Lappish)
1103 = Sanskrit
1132 = Sepedi
3098 = Serbian (Cyrillic)
2074 = Serbian (Latin)
1113 = Sindhi - India
2137 = Sindhi - Pakistan
1115 = Sinhalese - Sri Lanka
1051 = Slovak
1060 = Slovenian
1143 = Somali
1070 = Sorbian
3082 = Spanish - Spain (Modern Sort)
1034 = Spanish - Spain (Traditional Sort)
11274 = Spanish - Argentina
16394 = Spanish - Bolivia
13322 = Spanish - Chile
9226 = Spanish - Colombia
5130 = Spanish - Costa Rica
7178 = Spanish - Dominican Republic
12298 = Spanish - Ecuador
17418 = Spanish - El Salvador
4106 = Spanish - Guatemala
18442 = Spanish - Honduras
22538 = Spanish - Latin America
2058 = Spanish - Mexico
19466 = Spanish - Nicaragua
6154 = Spanish - Panama
15370 = Spanish - Paraguay
10250 = Spanish - Peru
20490 = Spanish - Puerto Rico
21514 = Spanish - United States
14346 = Spanish - Uruguay
8202 = Spanish - Venezuela
1072 = Sutu
1089 = Swahili
1053 = Swedish
2077 = Swedish - Finland
1114 = Syriac
1064 = Tajik
1119 = Tamazight (Arabic)
2143 = Tamazight (Latin)
1097 = Tamil
1092 = Tatar
1098 = Telugu
1054 = Thai
2129 = Tibetan - Bhutan
1105 = Tibetan - People's Republic of China
2163 = Tigrigna - Eritrea
1139 = Tigrigna - Ethiopia
1073 = Tsonga
1074 = Tswana
1055 = Turkish
1090 = Turkmen
1152 = Uighur - China
1058 = Ukrainian
1056 = Urdu
2080 = Urdu - India
2115 = Uzbek (Cyrillic)
1091 = Uzbek (Latin)
1075 = Venda
1066 = Vietnamese
1106 = Welsh
1076 = Xhosa
1144 = Yi
1085 = Yiddish
1130 = Yoruba
1077 = Zulu
1279 = HID (Human Interface Device)
'@
    }
    $lang["$($type)"]
}  # end Function Get-Language


} # end BEGIN


PROCESS {

    foreach ($Computer in $computername) {
        IF (Test-Connection -ComputerName $Computer -count 2 -quiet) {    
            try {
                Write-Verbose "Attempting WMI call"
                $OS = get-WMIObject win32_operatingsystem -computername $Computer -ea Stop | 
	               Select-Object -property CSName, Caption, BuildNumber, CSDVersion, Version, OSLanguage, MUILanguages, OSArchitecture, 
                    BootDevice, SystemDevice, WindowsDirectory,
                    @{Name="InstallDate";Expression={ $_.ConvertToDateTime( $_.InstallDate) }},
                    @{Name="LastBootUptime";Expression={ $_.ConvertToDateTime( $_.Lastbootuptime) }}
                   
                New-Object PSObject -Property @{
                    ComputerName = $Computer
                    OS = $OS.Caption
                    BuildNumber = $OS.BuildNumber
                    ServicePack = $OS.CSDVersion
                    Version = $OS.Version
                    InstallDate = $OS.InstallDate
                    LastBootUptime = $OS.LastBootUptime
                    OSLanguage = $OS.OSLanguage
                    BootDevice = $OS.BootDevice
                    SystemDevice = $OS.SystemDevice
                    WindowsDirectory = $OS.WindowsDirectory
                    MUILanguages = If (-not($($OS.MUILanguages))) { Get-Language $($OS.OSLanguage) } Else { $OS.MUILanguages }
                    OSArchitecture = If (-not($($OS.OSArchitecture))) { Get-OSArchitecture $Computer } Else { $OS.OSArchitecture }
                } | Select ComputerName,OS,Version,BuildNumber,ServicePack,OSArchitecture,MUILanguages,OSLanguage,BootDevice,SystemDevice,WindowsDirectory,InstallDate,LastBootUptime              
            
                                    
            } catch {
                Write-Error "WMI call failed on \\$Computer" 
                
            }
        } Else { Write-Warning "\\$Computer computer DO NOT reply to ping" }                           
	}
} #End Process
END {Write-Verbose "Function ${CmdletName} finished."}
} # End Function Get-LHSOSInfo


