$computerNames = Get-Content ".\TestLocal.txt"
foreach ($computerName in $computerNames) {
    if ( -not(Test-Connection $computerName -Quiet -Count 1 -ErrorAction Continue )) {
        Write-Host "Could not connect to computer $computerName - Skipping this computer..." -ForegroundColor Red }
    Else { Write-Host "Computer $computerName is online" -ForegroundColor Green
          $localGroupName = "Administrators"

          $group = [ADSI]("WinNT://$computerName/$localGroupName,group")
          $group.Members() |
             foreach {
                       $AdsPath = $_.GetType().InvokeMember('Adspath', 'GetProperty', $null, $_, $null)
                       $a = $AdsPath.split('/',[StringSplitOptions]::RemoveEmptyEntries)
                       $names = $a[-1] 
                       $domain = $a[-2]

                       foreach ($name in $names) {
                         Write-Host "Verifying the local admin users on computer $computerName" 
                         $Admins = Get-Content ".\TestUsers.txt"
                            foreach ($Admin in $Admins) {
                               if ($name -eq $Admin) {
                                   Write-Host "User $Admin found on computer $computerName ... " -NoNewline -ForegroundColor Cyan
                                   $group.Remove("WinNT://$computerName/$domain/$name")
                                   Write-Host "Removed" -ForegroundColor Cyan }
                                              }
                                          }
                                      }
                                  }
                              }