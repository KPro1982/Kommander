<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.213
	 Created on:   	12/11/2022 11:10 AM
	 Created by:   	Kpro1982
	 Organization: 	
	 Filename:     	ReplacementTools.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Rename-Folders
{
	[CmdletBinding()]
	param
	(
		[string]$Root,
		[string]$Source,
		[string]$Replace,
		[string]$ExcludeFolders

	)
	
	$folders = Get-ChildItem -Path $Root -Recurse -Directory
	# $TargetScriptPath = "$rootfolder\$Name\$TargetScripts"
	# $templateScripts = "$rootfolder\$Name\TemplateMod_Scripts"
	$excludedfolders = "*.git*"
	
	# Go through all the folders
	foreach ($item in $folders)
	{
#		$Parent = Split-Path $item.FullName
#		$Child = Split-Path -Path $item.FullName -leaf
		
		
		if ($item.FullName -NotLike $ExcludeFolders)
		{
			if ($item.fullname.Contains($Source))
			{
				$newname = $item.fullname
				$newname = $newname.Replace($Source, $Replace)
				Rename-Item $item.FullName -NewName $newname
				
			}
			
		}
		
		
		
	}
}

function Copy-TemplateFolder
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$ModName
	)
	
	$templatefolder = Read-GlobalParam -key "TemplateFolder"
	$targetfolder = Read-GlobalParam -key "ModSourceFolder"
	$targetfolder = Add-Folder -Source $targetfolder -Folder $ModName
	
	Copy-Item -Path $templatefolder\* -Destination $targetFolder -Include "*" -Container -Recurse
	Write-GlobalParam -key "CurrentModFolder" -value $targetFolder
	Write-ModParam -key "ModName" -value $ModName
	
}

function Edit-TemplateTokens
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Source,
		[Parameter(Mandatory = $true)]
		[string]$Replace,
		[Parameter(Mandatory = $true)]
		[string]$Folder,
		[string]$File,
		[string]$ExcludeFolders,
		[switch]$Recurse
	)
	
	if ($Recurse)
	{
		
		$targetfiles = Get-ChildItem $Folder *.* -File -rec
		
		foreach ($tfile in $targetfiles)
		{
			if ($tfile.FullName -NotLike $ExcludeFolders)
			{
				(Get-Content $tfile.PSPath) |
				Foreach-Object { $_ -replace $Source, $Replace } |
				Set-Content $tfile.PSPath
			}
		}
		
	}
	else  # just the one file
	{
		
			(Get-Content -Path "$Folder\$File") |
			Foreach-Object { $_ -replace $Source, $Replace } |
			Set-Content -Path "$Folder\$File"
		
	}
	
	
}

function Edit-TemplateRegions
{
	[CmdletBinding()]
	param
	(
		[string]$RegionStart,
		[string]$RegionEnd
	)
	
	$curmodfolder = Read-GlobalParam -key "CurrentModFolder"
	
	$targetfiles = Get-ChildItem $curmodfolder *.* -File -rec
	
	foreach ($file in $targetfiles)
	{
		$i = 0;
		$ii = 0;
		$starti = 0;
		$endi = 0;
		
		if ($file.FullName -NotLike $ExcludeFolders)
		{
			$arraylist = [System.Collections.ArrayList](Get-Content -Path $file.FullName)
			
			foreach ($line in $arraylist)
			{
				if ($line.Contains($RegionStart))
				{
					$starti = $i
				}
				if ($line.Contains($RegionEnd))
				{
					$endi = $i
					if (-not $starti)
					{
						
						return  # no start so its a parsing error
					}
					if ($starti -gt $endi)
					{
						return # start after end is a parsing error
						
					}
					
					# remove all lines between start and end
					for ($ii= $endi; $ii -ge $starti; $ii--) {
						$arraylist.RemoveAt($ii)
					}
				}
				$i += 1
				
			}
			
			
			
			$arraylist | Set-Content $file.PSPath
		}
	}
	
	
}


