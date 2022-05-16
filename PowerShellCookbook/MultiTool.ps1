################################################################ info

$title = "MultiTool.ps1"
$desc = "The Remote Support MultiTool"
$Rev = "v1.7 8/06/14"
$By = "Written by Andy Niel"
$info = "This is a simple utility I created with Powershell that gathers some common support tools together into a single graphical interface.`r`n`r`n***USAGE***`r`n`r`nSearch (by hostname or IP) - In the text box enter the system you wish to manage and click the checkmark or press Enter.`r`n`r`nSearch (by user name) - Click Find and in the search box type the users first or last name. When the search completes double-click the system you wish to manage.`r`n`r`nIf the name cant be resolved you will receive an error, otherwise you will be prompted to select a remote tool from the menu.`r`n`r`nPressing Escape or clicking the X quits the script"
$tools = "***TOOLS***`r`n`r`nRemote Assistance - Sends a Microsoft Remote Assistance invitation to the target system.`r`n`r`nRemote Desktop - Creates a Remote Desktop connection to the target system without prompting for authentication (you must run the Update Credentials tool first to store your credentials)`r`n`r`nRun PsExec - Accesses CMD console on target system, Note: must have PsTools installed (http://technet.microsoft.com/en-us/sysinternals/bb897553.aspx)`r`n`r`nRegistry - Opens Registry on the target system`r`n`r`nServices - Opens Services on the target system`r`n`r`nComputer Management - Opens Computer Management for the target system`r`n`r`nEvent Viewer - Opens Event Viewer on the target system`r`n`r`nPrint Management - Opens Print Management for the target system`r`n`r`nUpdate Credentials - Creates or updates an encrypted credential file stored at location stored in $credpath variable (default: c:\)`r`n`r`nUNC Path - Opens a UNC path to c:\ on the target system`r`n`r`nAbout Remote Support Multitool... - Opens this help file =)"

################################################################ sets variables

$ErrorActionPreference = "silentlycontinue"
$script:credpath = "C:\"
$u = $env:username
$script:message = "Enter a Hostname or IP Address:"
$script:message2 = "Enter Name to Search..."
$script:comp = " "
$script:output = $null
$user = $null
$pc = $null

################################################################ hides console

Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
function Hide-Console {
$consolePtr = [Console.Window]::GetConsoleWindow()
#0 hide
[Console.Window]::ShowWindow($consolePtr, 0)
}

hide-console

################################################################ sets credentials

function setcred {
$output = "Enter Domain\Username & Pass:"
$output | out-string
$outputBox.text=$output
$credential = Get-Credential $env:userdomain\$env:username
$credential.Password | ConvertFrom-SecureString | Set-Content $credpath\$u.txt
$output = "Credential saved to $credpath" | out-string
$outputBox.text=$output
start-sleep 4
$message | out-string
$outputBox.text=$message
}

################################################################ gets credentials

function getcred {
$script:pass = cat $credpath\$u.txt | convertto-securestring
$script:credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $u, $pass
$script:p = $credential.GetNetworkCredential().password
}

################################################################ starts unc path

function uncpath {
ii \\$comp\c$
}

################################################################ starts computer management

function compmgmt {
compmgmt.msc /computer=$comp
}

################################################################ starts event viewer

function eventvwr {
eventvwr.msc /computer:\\$comp
}

################################################################ starts remote assistance

function msra {
msra.exe /offerra $comp
}

################################################################ starts psexec

function psexec {
cmd.exe /c start cmd /k psexec \\$comp cmd
}

################################################################ starts print management

function prtmgmt {
add-type -assemblyname microsoft.visualbasic
add-type -assemblyname system.windows.forms
start-process printmanagement.msc
$a = Get-Process | Where-Object {$_.Name -like "printmanagement"}
[Microsoft.VisualBasic.Interaction]::AppActivate($a)
start-sleep 2
[System.Windows.Forms.SendKeys]::SendWait("{LEFT 10}")
start-sleep 1
[System.Windows.Forms.SendKeys]::SendWait("%(a)")
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
[Microsoft.VisualBasic.Interaction]::AppActivate($a)
start-sleep 1
[System.Windows.Forms.SendKeys]::SendWait($comp)
start-sleep .5
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
[Microsoft.VisualBasic.Interaction]::AppActivate($a)
[System.Windows.Forms.SendKeys]::SendWait("{TAB 4}")
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
[System.Windows.Forms.SendKeys]::SendWait("{DOWN}{DOWN}")
}

################################################################ starts remote desktop

function script:rdpc {
getcred
cmdkey /generic:TERMSRV/$comp /user:$u /pass:$p
mstsc /v:$comp
}

################################################################ tests for credentials

function creds {
if (test-path $credpath\$u.txt) {
rdpc
}
else {
setcred
rdpc
}
}

################################################################ starts registry editor

function reged {
add-type -assemblyname microsoft.visualbasic
add-type -assemblyname system.windows.forms
start-process regedit.exe
$a = Get-Process | Where-Object {$_.Name -like "regedit"}
[Microsoft.VisualBasic.Interaction]::AppActivate($a)
start-sleep 1
[System.Windows.Forms.SendKeys]::SendWait("%(f)")
[System.Windows.Forms.SendKeys]::SendWait("c")
[Microsoft.VisualBasic.Interaction]::AppActivate($a)
start-sleep 1
[System.Windows.Forms.SendKeys]::SendWait($comp)
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}

################################################################ starts services

function servcs {
services.msc /computer=$comp
}

################################################################ checks if exists

function script:getcomp {
$script:comp=$textfield.text
if (Test-Connection -count 1 -computername $Comp -quiet) {
$output = "Select a Remote Tool..." | out-string
$outputBox.text=$output
}
else {
write-host `a
$output = "Not Found! Verify Hostname/IP" | out-string
$outputBox.text=$output
start-sleep 4
$message | out-string
$outputBox.text=$message
}
}

################################################################ finds user pc

function finduser {
import-module activedirectory
$script:user=$textfield2.text
$user = "*" + $user + "*"
$var = Get-ADComputer -Filter {Description -Like $user} -property *
if ($var -eq $null) {
write-host `a
$output = "Not Found! Verify Spelling..." | out-string
$OutputBox2.text=$output
start-sleep 4
$message2 | out-string
$OutputBox2.text=$message2
}
else {
$listview.items.Clear()
foreach ($pc in $var) {
$row = New-Object System.Windows.Forms.ListViewItem($pc.name)
$row.SubItems.Add($pc.description)
$row.SubItems.Add($pc.ipv4address)
$Listview.Items.Add($row)
}
$output = "Select User PC..." | out-string
$OutputBox2.text=$output
}
}

################################################################ copy selected

function copycomp {
$comp = $listview.SelectedItems[0].text
$comp | out-string
$textfield.text=$comp
getcomp
}

################################################################ setup GUI

[void] [reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")

function about {
$form2.controls.add($label2)
$form2.controls.add($label3)
$form2.controls.add($label4)
$form2.controls.add($label5)
$form2.controls.add($label6)
$form2.controls.add($label7)
$form2.ShowDialog()
}

function search {
$form3.controls.add($textfield2)
$Form3.Controls.Add($outputBox2) 
$form3.Controls.Add($GOButton2)
$Form3.controls.add($listview)
$form3.ShowDialog()
}

$form= New-Object Windows.Forms.Form
$Form.FormBorderStyle=[System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.Size = New-Object Drawing.Point 344,527
$form.Font = New-Object System.Drawing.Font("Verdana",11,[System.Drawing.FontStyle]::regular)
$Form.ForeColor = "White"
$form.BackColor = "Black" 
$Form.MinimizeBox = $False
$Form.MaximizeBox = $False
$Form.SizeGripStyle = "Hide"
$Form.WindowState = "Normal"
$form.text = "The Remote Support MultiTool!"
$Form.KeyPreview = $True
$Form.Add_KeyDown({if ($_.KeyCode -eq "Enter"){getcomp}})
$Form.Add_KeyDown({if ($_.KeyCode -eq "Escape"){$Form.Close()}})

$form2= New-Object Windows.Forms.Form
$Form2.AutoSize = $True
$Form2.AutoSizeMode = "GrowAndShrink"
$Form2.MinimizeBox = $False
$Form2.MaximizeBox = $False
$Form2.SizeGripStyle = "Hide"
$Form2.StartPosition = "WindowsDefaultLocation"
$Form2.WindowState = "Normal"
$Form2.BackColor = "Black"
$Form2.ForeColor = "Chartreuse"
$form2.text = "About..."
$Form2.KeyPreview = $True
$Form2.Add_KeyDown({if ($_.KeyCode -eq "Escape"){$Form2.Close()}})

$form3= New-Object Windows.Forms.Form
$Form3.AutoSize = $True
$Form3.AutoSizeMode = "GrowAndShrink"
$Form3.MinimizeBox = $False
$Form3.MaximizeBox = $False
$Form3.SizeGripStyle = "Hide"
$Form3.StartPosition = "WindowsDefaultLocation"
$Form3.WindowState = "Normal"
$Form3.BackColor = "Black"
$Form3.ForeColor = "Chartreuse"
$form3.text = "Search for User PC..."
$Form3.KeyPreview = $True
$Form3.Add_KeyDown({if ($_.KeyCode -eq "Enter"){finduser}})
$Form3.Add_KeyDown({if ($_.KeyCode -eq "Escape"){$Form3.Close()}})

$label = New-Object Windows.Forms.Label
$label.Location = New-Object Drawing.Point 18,18
$label.Size = New-Object Drawing.Point 300,24
$label.Font = New-Object System.Drawing.Font("Verdana",12,[System.Drawing.FontStyle]::bold)
$Label.BackColor = "Transparent"
$label.text = "The Remote Support MultiTool!"

$label2 = New-Object Windows.Forms.Label
$label2.Location = New-Object Drawing.Point 15,15
$label2.Size = New-Object Drawing.Point 200,20
$label2.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::bold)
$label2.ForeColor = "White"
$label2.text = $title

$label3 = New-Object Windows.Forms.Label
$label3.Location = New-Object Drawing.Point 15,44
$label3.Size = New-Object Drawing.Point 220,20
$label3.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::regular)
$label3.text = $desc

$label4 = New-Object Windows.Forms.Label
$label4.Location = New-Object Drawing.Point 15,64
$label4.Size = New-Object Drawing.Point 200,20
$label4.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::regular)
$label4.text = $rev

$label5 = New-Object Windows.Forms.Label
$label5.Location = New-Object Drawing.Point 15,84
$label5.Size = New-Object Drawing.Point 200,20
$label5.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::italic)
$label5.text = $by

$label6 = New-Object Windows.Forms.Label
$label6.Location = New-Object Drawing.Point 15,110
$label6.Size = New-Object Drawing.Point 600,210
$Label6.MaximumSize = new Size(400,0)
$label6.Font = New-Object System.Drawing.Font("Verdana",8,[System.Drawing.FontStyle]::regular)
$label6.text = $info

$label7 = New-Object Windows.Forms.Label
$label7.Location = New-Object Drawing.Point 15,330
$label7.Size = New-Object Drawing.Point 600,380
$Label7.MaximumSize = new Size(400,0)
$label7.Font = New-Object System.Drawing.Font("Verdana",8,[System.Drawing.FontStyle]::regular)
$label7.text = $tools

$textfield = New-Object Windows.Forms.TextBox
$textfield.BackColor = "White"
$textfield.ForeColor = "Black"
$textfield.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::bold)
$textfield.Location = New-Object Drawing.Point 20,56
$textfield.Size = New-Object Drawing.Point 202,0

$GOButton = New-Object System.Windows.Forms.Button
$GOButton.Location = New-Object System.Drawing.Size(223,56)
$GOButton.Size = New-Object System.Drawing.Size(28,28)
$GOButton.ForeColor = "Chartreuse"
$GOButton.BackColor = "DimGray" 
$GOButton.Font = New-Object System.Drawing.Font("Webdings",22,[System.Drawing.FontStyle]::bold)
$GOButton.Text = "a"
$GOButton.Add_Click({getcomp})

$FindButton = New-Object System.Windows.Forms.Button
$FindButton.Location = New-Object System.Drawing.Size(252,56)
$FindButton.Size = New-Object System.Drawing.Size(59,28)
$FindButton.ForeColor = "Chartreuse"
$FindButton.BackColor = "DimGray" 
$FindButton.Font = New-Object System.Drawing.Font("Verdana",11,[System.Drawing.FontStyle]::bold)
$FindButton.Text = "Find"
$FindButton.Add_Click({search})

$outputBox = New-Object System.Windows.Forms.TextBox 
$outputBox.Location = New-Object System.Drawing.Size 20,84 
$outputBox.Size = New-Object System.Drawing.Size 289,20 
$outputbox.Font = New-Object System.Drawing.Font("Verdana",13,[System.Drawing.FontStyle]::regular)
$OutputBox.ReadOnly = "true"
$OutputBox.BackColor = "Black"
$OutputBox.ForeColor = "Chartreuse"
$OutputBox.Text = $script:message

$textfield2 = New-Object Windows.Forms.TextBox
$textfield2.BackColor = "White"
$textfield2.ForeColor = "Black"
$textfield2.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::bold)
$textfield2.Location = New-Object Drawing.Point 3,3
$textfield2.Size = New-Object Drawing.Point 431,0

$GOButton2 = New-Object System.Windows.Forms.Button
$GOButton2.Location = New-Object System.Drawing.Size(436,3)
$GOButton2.Size = New-Object System.Drawing.Size(28,28)
$GOButton2.ForeColor = "Chartreuse"
$GOButton2.BackColor = "DimGray" 
$GOButton2.Font = New-Object System.Drawing.Font("Webdings",22,[System.Drawing.FontStyle]::bold)
$GOButton2.Text = "a"
$GOButton2.Add_Click({finduser})

$outputBox2 = New-Object System.Windows.Forms.TextBox 
$outputBox2.Location = New-Object System.Drawing.Size 3,31 
$outputBox2.Size = New-Object System.Drawing.Size 460,20 
$outputbox2.Font = New-Object System.Drawing.Font("Verdana",13,[System.Drawing.FontStyle]::regular)
$OutputBox2.ReadOnly = "true"
$OutputBox2.BackColor = "Black"
$OutputBox2.ForeColor = "Chartreuse"
$OutputBox2.Text = $script:message2

$listView = New-Object System.Windows.Forms.ListView
$listView.View = 'Details'
$ListView.Location = New-Object System.Drawing.Size(3,62)
$listview.Font = New-Object System.Drawing.Font("arial",11,[System.Drawing.FontStyle]::regular)
$listview.Add_DoubleClick({$form3.Close();copycomp})
$listView.Width = 460
$listView.Height = 120

$colPC = $listView.Columns.Add('Hostname')
$coluser = $listView.Columns.Add('User')
$colip = $listView.Columns.Add('IP Address')
$colpc.width = 160
$coluser.width = 163
$colip.width = 133

$button = New-Object Windows.Forms.Button
$button.Location = New-Object System.Drawing.Size(20,135) 
$button.Size = New-Object Drawing.Point 140,50
$Button.ForeColor = "White"
$Button.BackColor = "Crimson" 
$button.text = "Remote Assistance"
$button.add_click({msra})

$button2 = New-Object Windows.Forms.Button
$Button2.Location = New-Object System.Drawing.Size(20,195)
$button2.Size = New-Object Drawing.Point 140,50
$Button2.ForeColor = "White"
$Button2.BackColor = "DarkCyan" 
$button2.text = "Run PsExec"
$button2.add_click({psexec})

$button3 = New-Object Windows.Forms.Button
$Button3.Location = New-Object System.Drawing.Size(20,255)
$button3.Size = New-Object Drawing.Point 140,50
$Button3.ForeColor = "White"
$Button3.BackColor = "Green" 
$button3.text = "Services"
$button3.add_click({servcs})

$button4 = New-Object Windows.Forms.Button
$Button4.Location = New-Object System.Drawing.Size(20,315)
$button4.Size = New-Object Drawing.Point 140,50
$Button4.ForeColor = "White"
$Button4.BackColor = "DarkOrange" 
$button4.text = "Event Viewer"
$button4.add_click({eventvwr})

$button5 = New-Object Windows.Forms.Button
$button5.Location = New-Object System.Drawing.Size(20,375) 
$button5.Size = New-Object Drawing.Point 140,50
$Button5.ForeColor = "White"
$Button5.BackColor = "Indigo" 
$button5.text = "Update Credentials"
$button5.add_click({setcred})

$button6 = New-Object Windows.Forms.Button
$Button6.Location = New-Object System.Drawing.Size(170,135)
$button6.Size = New-Object Drawing.Point 140,50
$Button6.ForeColor = "White"
$Button6.BackColor = "RoyalBlue"  
$button6.text = "Remote Desktop"
$button6.add_click({rdpc})

$button7 = New-Object Windows.Forms.Button
$Button7.Location = New-Object System.Drawing.Size(170,195)
$button7.Size = New-Object Drawing.Point 140,50
$Button7.ForeColor = "White"
$Button7.BackColor = "OrangeRed" 
$button7.text = "Registry"
$button7.add_click({reged})

$button8 = New-Object Windows.Forms.Button
$Button8.Location = New-Object System.Drawing.Size(170,255)
$button8.Size = New-Object Drawing.Point 140,50
$Button8.ForeColor = "White"
$Button8.BackColor = "DarkSlateBlue" 
$button8.text = "Computer Management"
$button8.add_click({compmgmt})

$button9 = New-Object Windows.Forms.Button
$Button9.Location = New-Object System.Drawing.Size(170,315)
$button9.Size = New-Object Drawing.Point 140,50
$Button9.ForeColor = "White"
$Button9.BackColor = "MediumVioletRed" 
$button9.text = "Print Management"
$button9.add_click({prtmgmt})

$button10 = New-Object Windows.Forms.Button
$button10.Location = New-Object System.Drawing.Size(170,375) 
$button10.Size = New-Object Drawing.Point 140,50
$Button10.ForeColor = "White"
$Button10.BackColor = "OliveDrab" 
$button10.text = "UNC Path"
$button10.add_click({uncpath})

$button11 = New-Object Windows.Forms.Button
$Button11.Location = New-Object System.Drawing.Size(20,445)
$button11.Size = New-Object Drawing.Point 290,25
$Button11.ForeColor = "White"
$Button11.BackColor = "DimGray" 
$button11.text = "About Remote Support MultiTool..."
$button11.add_click({about})

$form.controls.add($label)
$form.controls.add($textfield)
$Form.Controls.Add($outputBox) 
$form.Controls.Add($GOButton)
$form.Controls.Add($findButton)
$form.controls.add($button)
$form.controls.add($button2)
$form.controls.add($button3)
$form.controls.add($button4)
$form.controls.add($button5)
$form.controls.add($button6)
$form.controls.add($button7)
$form.controls.add($button8)
$form.controls.add($button9)
$form.controls.add($button10)
$form.controls.add($button11)
$form.ShowDialog()