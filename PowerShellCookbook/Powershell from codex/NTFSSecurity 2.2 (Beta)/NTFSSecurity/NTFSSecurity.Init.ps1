#region Internals
#region C# Code
$type_NTFS1 = @' 
	using System;
	using System.IO;
	using System.Collections;
	using System.Runtime.InteropServices;
	using Microsoft.Win32.SafeHandles;
	
	namespace NTFS
	{
		public class DriveInfoExt
		{
			[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
			static extern bool GetDiskFreeSpace(string lpRootPathName,
				out uint lpSectorsPerCluster,
				out uint lpBytesPerSector,
				out uint lpNumberOfFreeClusters,
				out uint lpTotalNumberOfClusters);
	
			DriveInfo _drive = null;
			uint _sectorsPerCluster = 0;
			uint _bytesPerSector = 0;
			uint _numberOfFreeClusters = 0;
			uint _totalNumberOfClusters = 0;
	
			public uint SectorsPerCluster { get { return _sectorsPerCluster; } }
			public uint BytesPerSector { get { return _bytesPerSector; } }
			public uint NumberOfFreeClusters { get { return _numberOfFreeClusters; } }
			public uint TotalNumberOfClusters { get { return _totalNumberOfClusters; } }
			public DriveInfo Drive { get { return _drive; } }
			public string DriveName { get { return _drive.Name; } }
			public string VolumeName { get { return _drive.VolumeLabel; } }
	
			public DriveInfoExt(string DriveName)
			{
				_drive = new DriveInfo(DriveName);
	
				GetDiskFreeSpace(_drive.Name,
					out _sectorsPerCluster,
					out _bytesPerSector,
					out _numberOfFreeClusters,
					out _totalNumberOfClusters);
			}
		}
			
		public class FileInfoExt
		{
			[DllImport("kernel32.dll", SetLastError = true, EntryPoint = "GetCompressedFileSize")]
			static extern uint GetCompressedFileSize(string lpFileName, out uint lpFileSizeHigh);
	
			public static ulong GetCompressedFileSize(string filename)
			{
				uint high;
				uint low;
				low = GetCompressedFileSize(filename, out high);
				int error = Marshal.GetLastWin32Error();
	
				if (high == 0 && low == 0xFFFFFFFF && error != 0)
				{
					throw new System.ComponentModel.Win32Exception(error);
				}
				else
				{
					return ((ulong)high << 32) + low;
				}
			}
		}
	}
'@
#endregion

function Testing-AddOrphanedAces([string] $Path)
{
	if (-not (Test-Path $Path))
	{
		throw New-Object System.IO.DirectoryNotFoundException
	}
	
	$i = 0
	$VerbosePreference = 'Continue'

	Pop-Location
	Set-Location $Path
	$dir = dir -Recurse

	foreach ($item in $dir)
	{
		foreach ($temp in (1..5))
		{
			$rid = Get-Random -Minimum 2000 -Maximum 8000
			$item | Add-Ace -AccessRights ReadAndExecute `
				-AccessType Allow `
				-Account "S-1-5-21-2154805076-549298816-3569373936-$rid" `
			
			Write-Host '.' -NoNewline
			$i++
		}
	}
	Write-Host

	Push-Location
	$VerbosePreference = 'SilentlyContinue'
	
	Write-Host "$i orphaned Sids added to objects in $Path" -ForegroundColor DarkYellow
}

function Testing-SetSecurityInheritance([string] $Path)
{
	if (-not (Test-Path $Path))
	{
		throw New-Object System.IO.DirectoryNotFoundException
	}
	$i = 0
	
	$VerbosePreference = 'Continue'

	Pop-Location
	Set-Location $Path
	$dir = dir -Recurse

	foreach ($item in $dir)
	{
		if ((Get-Random -Minimum 1 -Maximum 1000) -lt 333)
		{
			$item.DisableInheritance()
			Write-Host "." -NoNewline
			$i++
		}
	}	
	Write-Host

	Push-Location
	$VerbosePreference = 'SilentlyContinue'
	
	Write-Host "Disabled security inheritance on $i items in folder $Path" -ForegroundColor DarkYellow
}
#endregion

Add-Type -TypeDefinition $type_NTFS1 -Language CSharpVersion3
Add-Type -Path $PSScriptRoot\Security2.dll
Add-Type -Path $PSScriptRoot\PrivilegeControl.dll -ReferencedAssemblies $PSScriptRoot\ProcessPrivileges.dll
Add-Type -Path $PSScriptRoot\ProcessPrivileges.dll

#using Update-FormatData and not FormatsToProcess in the PSD1 as FormatsToProcess does not offer
#putting format data in front of the default data. This is required to make the new formatter the default ones.
Update-FormatData -PrependPath $PSScriptRoot\NTFSSecurity.format.ps1xml

New-Alias -Name Get-Ace -Value Get-Access
New-Alias -Name Add-Ace -Value Add-Access
New-Alias -Name Remove-Ace -Value Remove-Access
New-Alias -Name Get-OrphanedAce -Value Get-OrphanedAccess

New-Alias -Name Get-Inheritance -Value Get-AccessInheritance
New-Alias -Name Enable-Inheritance -Value Enable-AccessInheritance
New-Alias -Name Disable-Inheritance -Value Disable-AccessInheritance

Write-Verbose "Types added" 
Write-Verbose "NTFSSecurity Module loaded"

if ($PSVersionTable.PSVersion.Major -ge 3)
{
	Enable-Privileges
}
else
{
	Write-Warning "In PowerShell 2.0 the 'Backup', 'Restore' and 'TakeOwnership' Privilege cannot be enabled automatically. Use the cmdlet Enable-Privileges for enabling them."
}