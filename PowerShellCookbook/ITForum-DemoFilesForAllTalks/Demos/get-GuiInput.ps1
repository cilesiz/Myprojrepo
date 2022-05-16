#Requires -Version 1
param ( $pstring = "Name?", [regex]$validationString = ".*" )
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")


###############################
# Create the form
$form = New-Object System.Windows.Forms.Form
$form.add_shown({$form.Activate()})
$form.Text = "PowerShell GUI Input"
$form.height = 110


###############################
# Create the label
$label = New-Object System.Windows.Forms.Label
$label.Text = $pstring
$label.dock = "top"


###############################
# Create the textbox for input
$textbox = new-object system.windows.forms.textbox
$textbox.dock = "top"
$textbox.add_KeyUp({
    if ( $textbox.text -Notmatch $validationString )
    {  $textbox.BackColor = "RED"
    }else
    {  $textbox.BackColor = "white"
    }
})


###############################
# Create the OK button and when the OK button is clicked hide the form
$OK = new-object system.windows.forms.button 
$OK.Text = "OK"
$OK.dock = "bottom"
$OK.Add_Click({
    $form.hide()
    })

###############################
# add the controls to the form
$form.Controls.AddRange(@($textbox,$label,$OK))


###############################
# show the form
$results = $form.showdialog()
# show the results
$textbox.Text
$form.dispose()
