#Requires -Version 2
$s = [ScriptBlock]{
#COLOR=Yellow
# Scriptblocks can be as long or as complicated as you like
# This looks for things whose name begins with "A" or whose
# handles start with a "9" or whose namelength is equal to 3
#COLOR=

  if ($_.Name -match "^a")
  {   return $TRUE
  }
  
  
  if ($_.handles.ToString().StartsWith("9"))
  {   return $TRUE
  }

  if ($_.Processname.Length -eq 3)
  {   return $TRUE
  }

  return $FALSE
}
