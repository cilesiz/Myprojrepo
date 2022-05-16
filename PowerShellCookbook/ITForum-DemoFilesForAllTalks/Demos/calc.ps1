#Requires -Version 1
#####################################################################
#
# Xaml calculator in PowerShell
#
#####################################################################

#
# Load the necessary assemblies...
#
[void] [reflection.assembly]::LoadWithPartialName("PresentationCore")
[void] [reflection.assembly]::LoadWithPartialName("PresentationFramework")
[void] [reflection.assembly]::LoadWithPartialName("WindowsBase")

#
# This is the XML that defines the user interface...
#
$X=[XML](CAT CC:\demoDay\2Scripting\calc.xaml)
$XAML = $X.Window.Get_InnerXML()
#$xaml = get-content calc3.xaml | OUT-STRING

#
# Compile the XAML into a document object...
$f = [System.xml.xmlreader]::Create([System.IO.StringReader] $xaml)
$document = [system.windows.markup.xamlreader]::load($f)

#
# Utility to walk the XAML tree...
function Walk($tree) { $tree
    if ($tree.Children) { @($tree.Children) | %{ Walk $_ } }
    elseif ($tree.Child) { @($tree.Child) | %{ Walk $_ } }
    elseif ($tree.Content) { @($tree.Content) | %{ Walk $_ } }
}

#
# Create the top-level window...
#
$window = new-object System.Windows.Window
$window.Title = "Xaml PowerShell Calculator"
$window.Content = $document

#
# Build the result display box by hand instead of in XAML
#
$display = new-object System.Windows.Controls.TextBox
[System.Windows.Controls.Grid]::SetRow($display, 0);
[System.Windows.Controls.Grid]::SetColumn($display, 0);
[System.Windows.Controls.Grid]::SetColumnSpan($display, 9);
$display.Margin = new-object System.Windows.Thickness 3.0,1.0,1.0,1.0
$display.Height = 25;

#
# And build the paper tape box
#
$paper = new-object System.Windows.Controls.ListBox
[System.Windows.Controls.Grid]::SetRow($paper, 1);
[System.Windows.Controls.Grid]::SetColumn($paper, 0);
[System.Windows.Controls.Grid]::SetColumnSpan($paper, 3);
[System.Windows.Controls.Grid]::SetRowSpan($paper, 5);
$paper.Margin = new-object System.Windows.Thickness 3.0,1.0,1.0,1.0
$paper.IsSynchronizedWithCurrentItem=$true

$oct = [System.Collections.ObjectModel.ObservableCollection``1]
$oc = $oct.MakeGenericType(@([string]))
$results = [activator]::CreateInstance($oc)
$paper.DataContext = $results

#
# walk the control tree binding behaviours as we go...
#
foreach ($control in  walk $document)
{
    # find the grid control...
    switch -regex ($control.name)
    {
        'MyGrid'  {$MyGrid = $control; continue}
        '^B[0-9]$'{$control.add_Click({$display.Text += $this.Content }); continue}
        '^BC$'    {$control.add_Click({$display.Text = "" }); continue}
        '^B(Plus|Minus|Devide|Multiply|Period)$' {
                $control.add_Click({$display.Text += $this.Content })
                continue
        }
        '^BEqual' {
            $control.add_Click({
                $result = invoke-expression $display.Text
                $paper.Items.Add($display.Text + " = $result")
                $display.Text = $result
            })
            continue
        }
    }
}

#
# Add the two explicitly created controls...
$MyGrid.Children.Add($display);
$MyGrid.Children.Add($paper)

$window.Height = 400
$window.Width = 600
$window.Title = "PowerShell XAML Calculator"
$window.ShowDialog()
