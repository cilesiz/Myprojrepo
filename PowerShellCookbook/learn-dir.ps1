
                                #INTRODUCTION TO POWERSHELL VIA THE DIR COMMAND

#LAUNCHING POWERSHELL
    #Plain Powershell
        #Start->Run->Powershell.exe
    
    #Powershell ISE
        #Start->Run->PowerShell_ISE.exe
        #intellisense, name completion, debugging, syntax highlighting
        #preferred way to develop
    
    #From Commandline
        powershell.exe -file “F:\data\scripts\ps\Learn\Show-Dir.ps1” #launching a PowerShell file with an explicit path
        powershell.exe -file “.\Show-Dir.ps1” #launching a PowerShell file from current folder
        powershell.exe -c "Get-Childitem c:\temp;write-host 'hi there'" #Launching a powershell command
        powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -File F:\data\scripts\ps\Learn\Show-Dir.ps1 #Lauch PowerShell file with many switched including bypassing the execution policy

#DESKTOP INSTALL
    Invoke-WebRequest http://www.microsoft.com/en-us/download/details.aspx?id=34595

#POWERSHELL VERSIONS AT FORD
    #powershell 1
        #many commandlets missing, not recommended
    #powershell 2
        #standard Ford version
        #2k3 can only do v2, but not installed by default
        #2k8, 2k8R2 comes standard with v2, but no ISE
    #powershell 3
        #2k8, 2k8R2 but must be loaded
        #not a significant improvement to commandlets
        #required for advanced ISE
    #since powershell is based on .net, you can alows cheat and make your own commands in .net
    Get-host
    #remote PS access is not enabled, so you must use traditional methods such as psexec, or wmi
    #Execution policy is set to restricted by default
        Get-ExecutionPolicy #gets current execution policy
        Set-ExecutionPolicy restricted #stops PowerShell scripts from be executed
        Set-ExecutionPolicy unrestricted #allows any PowerShell scripts to be run

#COMMANDS
    #Verb-Noun notation - Commands are usually singular, not plural
        Get-Command #show all PowerShell commands
        Get-Help Set-ExecutionPolicy -Full #shows all help relating to set-execution policy
#ALIASES
    Get-Alias  #shows a listing of all aliases
    #command line aliases
        #Cmdlet 		Alias 	Command 	Description
        #--------------------------------------------------
        #Get-ChildItem	gci		dir,ls		Gets the items and child items in one or more specified locations.
        #Get-Location 	gl 		pwd 	 	Current Directory.
        #Set-Location 	sl 		cd, chdir 	Change current directory.
        #Copy-Item 	 	cpi 	copy 	 	Copy Files.
        #Remove-Item 	ri 		del 	 	Removes a File or directory.
        #Move-Item  	mi 		move 	 	Move a file.
        #Rename-Item 	rni		rn 	 	 	Rename a file.
        #New-Item 	 	ni 		n/a 	 	Creates a new empty file or folder.
        #Clear-Item 	cli 	n/a 	 	Clears the contents of a file.
        #Set-Item 	 	si 		n/a 	 	Set the contents of a file.
        #Mkdir 	 	 	n/a 	md 	 	 	Creates a new directory.
        #Get-Content 	gc 		type 	 	Sends contents of a file to the output stream.
        #Set-Content 	sc 		n/a 	 	Set the contents of a file.

#LEARN A COMMAND
    dir
    #command line dir is not the same as PowerShell dir
        Get-Alias dir #shows that dir is in fact an alias
        Get-ChildItem #shows that Get-ChildItem is the same as dir
        dir -r #gets all files and folders recursively. (Doesn’t use /s like cmd version)
        Get-PSDrive #shows what PowerShell drives can be accessed
        cd hklm: #change to registry
        cd env: #shows environment variables
        dir ("C:\Temp","c:\instapps") #lists contents for 2 folders at once
#PIPELINE
    #Commands accept output of other commands
    dir | foreach{$_.Name} #gets a list of files and folders and loops through them by Name
    dir | get-acl #get permission on folders in current directory 
    #many commands accept pipeline input

#DATA MANIPULATION THROUGH PIPELINE
    #Sort-Object
        dir | sort name #sort by name
        dir | sort lastwritetime -desc #sort by last write time in descending order
    #Select-Object
        dir | select -first 1 #shows first item
        dir | select * #shows all properties
        dir | select Fullname #shows only fullname
    #Select-String
        dir -r f:\data\scripts\*.ps1 | select-string http #recursively look for all ps1 files that contain "http"
        dir -r f:\data\scripts\*.ps1 | select-string http | select-Object LineNumber, Path #recursively look for all ps1 files that contain "http" but show only linenumber and path properties
    #Where-Object
        dir f:\data\scripts | where {$_.mode -match "d"} #shows only directories
        dir f:\data\scripts -r | where {$_.length -gt 10mb} #shows all files larger than 10 megabytes (notice how PowerShell is smart enough to understand 10mb?)
        dir f:\data\scripts -r *.ps1 | where {$_.LastWriteTime -lt “1/1/2013” -and $_.Length -gt 1000} #shows all .ps1 files that were last modified last year and have a length greater than 1000 bytes
    #Compare-Object (quick windiff)
        Compare-Object -ReferenceObject (dir F:\data\scripts\folder1) -DifferenceObject (dir F:\data\scripts\folder2) -Property name
        
#Output
    #Export-Csv
        dir | export-csv -path test.csv -notypeinformation #outputs current directory to csv
    #Export-Clixml
        dir | export-clixml -path test.xml #outputs entire directory object to xml (can be imported to another machine)
    #Out-GridView
        dir | Out-GridView #outputs to GUI
    #Format-Table (ft)
        dir | format-table #formats the output as a table
        dir | acl | ft -AutoSize #gets permission of objects in current folder, puts in table and auto sizes it
    #Format-List
        dir |format-list #formats the output as a list
    #> (output overwrite) and >> (output append)
        dir > out.txt;notepad .\out.txt  #redirects output of dir to txt file as unicode (default)
    #out-file
        dir | Out-file -Encoding ascii -FilePath .\out.txt;notepad .\out.txt #redirects output of dir to txt file but allows more switches so we can change the output encoding to ascii

#COMMON SWITCHES
    #switchs can be abbreviated -f -fo -for -forc -force (just make sure its the switch you want!)  
    #-whatif 
        dir \\fmc103105\proj\*.csv | remove-item -whatif #displaces which CSV files WOULD be removed if the whatif command were not specified
    #-computername
        Test-Connection -ComputerName fmc103105,fcas615 #performs a ping by computername for servers specified
    #-erroraction
        dir -recurse \\fmc103105\proj -ErrorAction Inquire #prompts the user when an error is encountered
    #-confirm
        dir F:\data\scripts\1.txt | del -confirm #tries to delete file, but prompts the user first
    #-path
        dir -Path c:\temp #lists contents of c:\temp by specifying the -path switch
    #-Force
        dir C:\Users\$ABAKER9 #shows non hidden files only
        dir -force C:\Users\$ABAKER9 #-f forces dir to show hidden files as well
        
#COMMON COMMANDS
    #get-date (http://technet.microsoft.com/en-us/library/ee692801.aspx)
        get-date -f d #gets current date in short date format
        get-date -f F #gets current date in FullDateTimePattern (long date and long time)
    #get-eventlog
        Get-Eventlog system -After (get-date).addhours(-1) #get all events from system that occured within the last hour
        Get-EventLog system  -message *uptime* #shows all system events that contain the word "uptime"
        Get-EventLog –log Security -Newest 1000 | Where {$_.message –match "Account Name:\s*abaker9”} #get newest 1000 security events that have a message that matches complex pattern
        Get-EventLog system | where {$_.EventID -eq 6009 -or $_.eventID -eq 6008} #Shows all system events that match Windows 2008/2k3 Restarted (6009) or Windows 2008/2k3/2k Unexpected Restart (6008)
        Get-EventLog system -source eventlog #shows all system events created by eventlog
        Get-EventLog security  -Newest 10 -entrytype FailureAudit #shows newest 10 failure audits from the security event log
        Get-EventLog system -computername fmc103105,localhost -source eventlog -m microsoft* |select  machinename, message, timegenerated
    #Get-Process (alias gps)
        Get-Process #gets all processes
        Get-Process | Sort-Object vm | where {$_.vm -gt 1000Mb} #gets all processes who use more than 1000Mb of virtual memory
    #Stop-Process (alias kill)
        #Stop-Process 3512 #kills process by pid
        #kill 3512 -force  #kill process by pid, with force option and using kill alias for stop-process
        Stop-Process -processname notepad #kills process by name
    #Stop-Service
        stop-service lcfd #stops tivoli service
    #Start-Service
        start-service lcfd #starts tivoli service
    #Get-Service
        Get-Service lcfd #gets info on tivoli service
        Get-Service -computername fmc103105 lcfd | start-service #gets tivoli service object from another machine and passes it to start-service commandlet which starts it
    #get-acl
        dir \\fmc103105\proj  | get-acl #gets all folders and sends them to get-acl which gathers permission information
        dir \\fmc103105\proj | where-object {$_.mode -match "d"} | get-acl | Format-Table -Wrap -AutoSize #get all directories, gathers permission information and makes it pretty with the format table commandlet
    #Get-WindowsFeature
        Get-WindowsFeature telnet*
    #get-content
        get-content C:\windows\system32\drivers\etc\hosts
    #import-csv
        import-csv F:\data\scripts\ps\learn\servers.csv

#FURTHER LEARNING
    #Microsoft scripting guys
        #http://technet.microsoft.com/en-us/scriptcenter/dd742419.aspx
    #Video links
        #http://channel9.msdn.com/Events/TechEd/NorthAmerica/2012/WSV321-R
        #http://channel9.msdn.com/Events/TechEd/NorthAmerica/2011/WSV315
        #https://www.youtube.com/results?search_query=powershell
   

 

