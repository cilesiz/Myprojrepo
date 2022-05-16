$forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
"you are connected to the {0} forest" -f $forest.name
