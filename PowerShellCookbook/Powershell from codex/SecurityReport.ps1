function Get-SPUserEffectivePermissions(
    [object[]]$users, 
    [Microsoft.SharePoint.SPSecurableObject]$InputObject) {
    
    begin { }
    process {
        $so = $InputObject
        if ($so -eq $null) { $so = $_ }
        
        if ($so -isnot [Microsoft.SharePoint.SPSecurableObject]) {
            throw "A valid SPWeb, SPList, or SPListItem must be provided."
        }
        
        foreach ($user in $users) {
            # Set the users login name
            $loginName = $user
            if ($user -is [Microsoft.SharePoint.SPUser] -or $user -is [PSCustomObject]) {
                $loginName = $user.LoginName
            }
            if ($loginName -eq $null) {
                throw "The provided user is null or empty. Specify a valid SPUser object or login name."
            }
            
            # Get the users permission details.
            $permInfo = $so.GetUserEffectivePermissionInfo($loginName)
            
            # Determine the URL to the securable object being evaluated
            $resource = $null
            if ($so -is [Microsoft.SharePoint.SPWeb]) {
                $resource = $so.Url
            } elseif ($so -is [Microsoft.SharePoint.SPList]) {
                $resource = $so.ParentWeb.Site.MakeFullUrl($so.RootFolder.ServerRelativeUrl)
            } elseif ($so -is [Microsoft.SharePoint.SPListItem]) {
                $resource = $so.ParentList.ParentWeb.Site.MakeFullUrl($so.Url)
            }

            # Get the role assignments and iterate through them
            $roleAssignments = $permInfo.RoleAssignments
            if ($roleAssignments.Count -gt 0) {
                foreach ($roleAssignment in $roleAssignments) {
                    $member = $roleAssignment.Member
                    
                    # Build a string array of all the permission level names
                    $permName = @()
                    foreach ($definition in $roleAssignment.RoleDefinitionBindings) {
                        $permName += $definition.Name
                    }
                    
                    # Determine how the users permissions were assigned
                    $assignment = "Direct Assignment"
                    if ($member -is [Microsoft.SharePoint.SPGroup]) {
                        $assignment = $member.Name
                    } else {
                        if ($member.IsDomainGroup -and ($member.LoginName -ne $loginName)) {
                            $assignment = $member.LoginName
                        }
                    }
                    
                    # Create a hash table with all the data
                    $hash = @{
                        Resource = $resource
                        "Resource Type" = $so.GetType().Name
                        User = $loginName
                        Permission = $permName -join ", "
                        "Granted By" = $assignment
                    }
                    
                    # Convert the hash to an object and output to the pipeline
                    New-Object PSObject -Property $hash
                }
            }
        }
    }
    end {}
}