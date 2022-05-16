function Get-PhoneCall
{
    <#
    .Synopsis
        Gets information about phone calls
    .Description
        Gets information about phone calls sent to or from any Twilio Number
    .Example
        Get-PhoneCall
    #>
    param(
    # The call identifier   
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('Sid')] 
    [string]
    $CallSid, 

    # The Twilio credential 
    [Management.Automation.PSCredential]
    $Credential,
    
    
    # The status of the phone call
    [ValidateSet("queued", "ringing", "in-progress", "completed", "failed", "busy", "no-answer")]    
    [string]$Status,
    
    # The number the phone call was sent to
    [string]$To,
    
    # The number the phone call came from
    [string]$From,
        
    # Twilio connection settings
    [Parameter(ValueFromPipelineByPropertyName=$true)]       
    [string[]]
    $Setting = @("TwilioAccountKey", "TwilioAccountSecret"),

    
    [Switch]$IncludeRecording,
    
    [Switch]$IncludeTranscript

    )
    
    process {
        if (-not $Credential -and $Setting) {
            if ($setting.Count -eq 1) {

                $userName = Get-WebConfigurationSetting -Setting "${Setting}_UserName"
                $password = Get-WebConfigurationSetting -Setting "${Setting}_Password"
            } elseif ($setting.Count -eq 2)  {
                $userName = Get-secureSetting -Name $Setting[0] -ValueOnly
                $password= Get-secureSetting -Name $Setting[1] -ValueOnly
            }

            if ($userName -and $password) {                
                $password = ConvertTo-SecureString -AsPlainText -Force $password
                $credential  = New-Object Management.Automation.PSCredential $username, $password 
            } elseif ((Get-SecureSetting -Name "$Setting" -ValueOnly | Select-Object -First 1)) {
                $credential = (Get-SecureSetting -Name "$Setting" -ValueOnly | Select-Object -First 1)
            }
            
            
        }

        if (-not $Credential) {
            Write-Error "No Twilio Credential provided.  Use -Credential or Add-SecureSetting TwilioAccountDefault -Credential (Get-Credential) first"               
            return
        }


        
        $getWebParams = @{
            WebCredential=$Credential
            Url="https://api.twilio.com/2010-04-01/Accounts/$($Credential.GetNetworkCredential().Username.Trim())/Calls/?"           
            AsXml =$true                        
            UseWebRequest = $true
        }
        
        if ($psBoundParameters.Status) {
            $getWebParams.Url += "&Status=$status"
        }
        
        if ($psBoundParameters.To) {
            $getWebParams.Url += "&To=$to"
        }
        
        if ($psBoundParameters.From) {
            $getWebParams.Url += "&From=$from"
        }                
        
        if ($callSid) {
            $getWebParams.Url = 
                "https://api.twilio.com/2010-04-01/Accounts/$($Credential.GetNetworkCredential().Username.Trim())/Calls/$CallSid"           
        }         
        
        do {

            $twiResponse = Get-Web @getwebParams |            
                Select-Object -ExpandProperty TwilioResponse 
            
            $twiResponse | 
                Select-Object -ExpandProperty Calls | 
                Select-Object -ExpandProperty Call |
                ForEach-Object {
                    $item = $_
                    $_.pstypenames.clear()
                    $_.pstypenames.add('Twilio.PhoneCall')
                    if ($includeRecording) {
                        $recording = 
                            Get-TwilioRecording -CallSid $_.CallSid -Credential $credential -Asmp3 -errorAction SilentlyContinue
                        $_ | 
                            Add-Member NoteProperty Recording $recording -Force 
                    
                    }
                
                    if ($includeTranscript) {
                    
                        $recording= Get-TwilioRecording -CallSid $item.Sid -Credential $credential -errorAction SilentlyContinue
                        if ($recording) {
                            Get-TwilioTranscription -RecordingSid $recording.Sid -Credential $credential 
                        }
                        
                    
                    
                        
                    
                    }

                    $_
                
                }
            if ($twiResponse.Calls.NextPageUri) {
                    $getWebParams.Url="https://api.twilio.com" + $twiResponse.Calls.NextPageUri
                    

            }
        } while ($twiResponse.Calls.NextPageUri)        
    }       
} 
 

 
