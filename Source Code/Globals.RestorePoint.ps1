#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------
$CommandlineMessage = ""


function Get-ScriptDirectory
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
#>
	[OutputType([string])]
	param ()
	if ($null -ne $hostinvocation)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}



function Get-Settings
{
	[CmdletBinding()]
	[OutputType([hashtable])]
	param
	(
		[string]$settingname,
		[string]$settingpath
	)
	
	if (-not $settingpath)
	{
		$settingpath = Get-ScriptDirectory
	}
	
	$fullsettingpath = Add-Folder -Source $settingpath -Folder "$settingname"

	$hashtable = @{ }
	try
	{
		$json = Get-Content $fullsettingpath | Out-String
	}
	catch
	{
		Return $hashtable
	}
	(ConvertFrom-Json $json).psobject.properties | Foreach { $hashtable[$_.Name] = $_.Value }
	
	
	Return $hashtable
}
function Set-Settings
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$settingname,
		[Parameter(Mandatory = $true)]
		[string]$key,
		[Parameter(Mandatory = $true)]
		[AllowEmptyString()]
		[string]$value,
		[string]$settingpath
	)
	
	
	
	if ($settingpath)
	{
		if (-not (Test-Path -Path $settingpath))
		{
			New-Item -Path $settingpath -ItemType Directory
		}

		
	}
	else
	{
		$settingpath = Get-ScriptDirectory

	}
	
	
	$hashtable = Get-Settings -settingpath $settingpath -settingname $settingname
	$fullsettingpath = Add-Folder -Source $settingpath -Folder $settingname
	$hashtable[$key] = $value	
	$hashtable | ConvertTo-Json | Set-Content $fullsettingpath
}

function Read-ModParam
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$key
	)
	
	$settingpath = Read-GlobalParam -key "CurrentModFolder"
	$settingpath = Add-Folder -Source $settingpath -Folder "Kommander"
	$settingname = "ModSettings.json"
	
	$hashtable = Get-Settings -settingpath $settingpath  -settingname $settingname
	$value = $hashtable[$key]
	return $value
}
function Write-ModParam
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$key,
		[Parameter(Mandatory = $true)]
		[AllowEmptyString()]
		[string]$value,
		[switch]$Append
	)
	
	$settingpath = Read-GlobalParam -key "CurrentModFolder"
	$settingpath = Add-Folder -Source $settingpath -Folder "Kommander"
	$settingname = "ModSettings.json"
	
	if ($Append)
	{
		$oldvalue = Read-ModParam -settingname $settingname -key $key
		$value = $oldvalue + ';' + $value
	}
	Set-Settings -settingpath $settingpath  -settingname $settingname -key $key -value $value
}
function Read-GlobalParam
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$key
	)
	
	$hashtable = Get-Settings -settingname "GlobalSettings.json"
	$value = $hashtable[$key]
	return $value
}
function Write-GlobalParam
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]$key,
		[Parameter(Mandatory = $true,
				   Position = 2)]
		[AllowEmptyString()]
		[string]$value
	)
	
	Set-Settings -settingname "GlobalSettings.json" -key $key -value $value
}
function Read-TemplateParam
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$key
	)
	
	$hashtable = Get-Settings -settingname "TemplateSettings.json"
	$value = $hashtable[$key]
	return $value
}
function Write-TemplateParam
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[AllowNull()]
		[AllowEmptyString()]
		[string]$key,
		[Parameter(Mandatory = $true)]
		[AllowEmptyString()]
		[AllowNull()]
		[string]$value
	)
	
	Set-Settings -settingname "TemplateSettings.json" -key $key -value $value
}

function Get-TemplateHash
{
	[CmdletBinding()]
	[OutputType([hashtable])]
	param ()
	
	$hashtable = Get-Settings -settingname "TemplateSettings.json"
	return $hashtable
}

function Write-ScratchParam
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$key,
		[Parameter(Mandatory = $true)]
		[AllowEmptyString()]
		[AllowNull()]
		[string]$value
	)
	
	Set-Settings -settingname "Temp.json" -key $key -value $value
}
function Read-ScratchParam
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$key
	)
	
	$hashtable = Get-Settings -settingname "Temp.json"
	$value = $hashtable[$key]
	return $value
}

function Get-KAddons
{
	[CmdletBinding()]
	[OutputType([string])]
	param ()
	
	$addonsfolder = Read-GlobalParam -key "AddonsFolder"
	$modname = Read-ModParam -key "ModName"
	$packedmodname = '@' + $modname
	$packedmodpath = Read-GlobalParam -key "PackedModFolder"
	$packedmodpath = Add-Folder -Source $packedmodpath -Folder $packedmodname

	$modlist = $modlist + $packedmodpath + ';'
	$addonsstr = Read-ModParam -key "AdditionalMPMods"
	if ($addonsstr)
	{
		$addons = $addonsstr.Split(";")
		$addons | foreach {
			$mod = $_
			$modlist = $modlist + $addonsfolder + '\' + $mod.Trim() + ';'
			
		}
	}
	$modlist = $modlist.TrimEnd(';')
	Return $modlist
}

function Start-kServer
{
	param
	(
		[switch]$CommandLine
	)
	
	$modlist = Get-kAddons
	$gamef = Read-GlobalParam -key "GameFolder"
	$serverDZ = $gamef + "\serverDZ.cfg"
	$mods = "`"-mod=" + $modlist + "`""
	$command = $gamef + "\DayZDiag_x64.exe"
	$params = $mods, '-filePatching', '-server', '-config=serverDZ.cfg', '-profiles=S:\Steam\steamapps\common\DayZ\profiles'
	
	if ($commandline)
	{
		return $command + "`n" + $params
	}
	else
	{
		Set-Folder -key "GameFolder"
		& $command @params
		
	}
	
	
}

function Start-kMPGame
{
	param
	(
		[switch]$CommandLine
	)
	
	$modlist = Get-KAddons
	$gamef = Read-GlobalParam ("GameFolder")
	$command = $gamef + "\DayZDiag_x64.exe"
	$mods = "`"-mod=" + $modlist + "`""
	$params = $mods, '-filePatching', '-connect=127.0.0.1', '-port=2302'
	
	if ($commandline)
	{
		return $command + "`n" + $params
	}
	else
	{
		Set-Folder -key "GameFolder"
		& $command @params
		
	}
	
}


function Start-kWorkbench
{
	[CmdletBinding()]
	param
	(
		[switch]$Commandline = $false
	)
	
	$modlist = Get-KAddons
	$workbenchf = Read-GlobalParam -key WorkbenchFolder
	$workbenchf = Read-GlobalParam -key WorkbenchFolder
	$command = Add-Folder -Source $workbenchf -Folder "workbenchApp.exe"
    $mods = "`"-mod=" + $modlist + "`""
	# $mods = "`"-mod=" + "P:\@FirstMod" + "`""
	$params = $mods
	
	
	if ($commandline)
	{
		 return $command + "`n" + $params

	}
	else
	{
		
		$curmodfolder = Read-GlobalParam -key "CurrentModFolder"
		$modworkbenchfolder = Add-Folder -Source $curmodfolder -Folder "Workbench"
		Set-Location $modworkbenchfolder
		& $command @params

	}
	
}
function Start-Build
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[switch]$Commandline = $false,
		[string]$BuildMethod
	)
	
	
	
	# start /D "S:\Steam\steamapps\common\DayZ Tools\Bin\AddonBuilder" addonbuilder.exe "P:\RationalGPS" S:\Mod-Packed\@RationalGPS\addons -clear -project=P:  
	
	$addonbuilder = Read-SteamCommon
	$addonbuilder = Add-Folder -Source $addonbuilder -Folder "DayZ Tools\Bin\AddonBuilder\addonbuilder.exe"
	$command = $addonbuilder
	
	$modname = Read-ModParam -key "ModName"
	
	$packedmodf = Read-GlobalParam -key "PackedModFolder"
	$packedmodf = Add-Folder -Source $packedmodf -Folder "@$modname\addons"
	$paramsetting = "P:\" + $modname
	$paramsetting = $paramsetting + "," + $packedmodf
	$paramsetting = $paramsetting + ", -project=P:"
	
	
	$params = $paramsetting.Split(',')
	
	if ($commandline)
	{
		$output = $command + "`n" + $params
		return $output
		
	}
	
	Start-Process $command -ArgumentList $params -Wait -RedirectStandardOutput buildoutput.txt -RedirectStandardError builderror.txt
	
	Set-BuildSuccess
	
}

<#
	.SYNOPSIS
		Turns build log button green or red to indicate build success or failure
	
	.DESCRIPTION
		A detailed description of the Set-BuildSuccess function.
	
	.EXAMPLE
				PS C:\> Set-BuildSuccess
	
	.NOTES
		Additional information about the function.
#>
function Set-BuildSuccess
{
	[CmdletBinding()]
	param ()
	
	$lastbuild = Get-ScriptDirectory
	$lastbuild = Add-Folder -Source $lastbuild -Folder "Buildoutput.txt"
	
	$success = Get-Content -Path $lastbuild | Select-String -Pattern "build successful"
	$failure = Get-Content -Path $lastbuild | Select-String -Pattern "build fail"
	if ($success)
	{
		$buttonOpenBuildLog.BackColor = 'Green'
	}
	elseif ($failure)
	{
		$buttonOpenBuildLog.BackColor = 'Red'
		
	}
}


function Start-BuildBroken
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[switch]$Commandline = $false,
		[string]$BuildMethod
	)
	
	$trash = Link-Scripts
	$trash = Link-Source
	
	if ($BuildMethod -eq "Mikero")
	{
		# $params = "-P", "-Z", "-O", "-E=dayz", "-K", "+M=P:\PackedMods\@FirstMod", "S:\Steam\steamapps\common\DayZ\Mod-Source\FirstMod\Scripts"
		$command = "pboProject.exe"
		$scriptname = Read-ModParam -key "PboName"
		$paramsetting = Read-GlobalParam -key "PboProjectParams"
		$paramsetting += ", +M=S:\PackedMods\@RationalGPS"
		$paramsetting += ", S:\Mod-Source\RationalGPS\Scripts"
		$paramsetting += ", -L " + $scriptname
		
		$params = $paramsetting.Split(',')
		
		if ($commandline)
		{
			return $command + "`n" + $params
		}
		else
		{
			Set-Location "P:"
			Start-Process "pboProject.exe" -ArgumentList $params -Wait -RedirectStandardOutput buildoutput.txt -RedirectStandardError builderror.txt
		}
		
		
	}
	elseif ($BuildMethod -eq "Tools")
	{
		# start /D "S:\Steam\steamapps\common\DayZ Tools\Bin\AddonBuilder" addonbuilder.exe "P:\RationalGPS" S:\Mod-Packed\@RationalGPS\addons -clear -project=P:  
		
		$addonbuilder = Read-SteamCommon
		$addonbuilder = Add-Folder -Source $addonbuilder -Folder "DayZ Tools\Bin\AddonBuilder\addonbuilder.exe"
		$command = $addonbuilder
		
		$modname = Read-ModParam -key "ModName"
		
		$packedmodf = Read-GlobalParam -key "PackedModFolder"
		$packedmodf = Add-Folder -Source $packedmodf -Folder "@$modname\addons"
		$paramsetting = "P:\" + $modname
		$paramsetting = $paramsetting + "," + $packedmodf
		$paramsetting = $paramsetting + ", -project=P:"
		
		$additionalsettings = Read-GlobalParam -key "AddonBuilderParams"
		$paramsetting = $paramsetting + ',' + $additionalsettings
		
		$params = $paramsetting.Split(',')
		
		if ($commandline)
		{
			$output = $command + "`n" + $params
			return $output
			
		}
		
		Start-Process $command -ArgumentList $params -Wait -RedirectStandardOutput buildoutput.txt -RedirectStandardError builderror.txt
		$lastbuild = Get-ScriptDirectory
		$lastbuild = Add-Folder -Source $lastbuild -Folder "Buildoutput.txt"
		
		$success = Get-Content -Path $lastbuild | Select-String -Pattern "build successful"
		$failure = Get-Content -Path $lastbuild | Select-String -Pattern "build fail"
		if ($success)
		{
			$buttonOpenBuildLog.BackColor = 'Green'
		}
		elseif ($failure )
		{
			$buttonOpenBuildLog.BackColor = 'Red'
			
		}
		
		Link-All
		
	}
}
function Get-PackedMod
{
	[OutputType([string])]
	param ()
	
	[CmdletBinding()]

	
	$modname = "`@" + $lblModName.Text
	$packedmodfolder = Read-GlobalParam -key "PackedModFolder"
	$packedmodfolder = Add-Folder -Source $packedmodfolder -Folder $modname
	
	return $packedmodfolder
}


function Stop-kDayz
{
	taskkill /im DayZDiag_x64.exe /F /FI "STATUS eq RUNNING"
}

function Read-SteamCommon
{
	[CmdletBinding()]
	[OutputType([string])]
	param ()
	
	$regpath = (Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Bohemia Interactive\Dayz Tools').path
	$commonpath = $regpath.Split('\')
	$finalpath = $commonpath[0]
	for ($i = 1; $i -lt $commonpath.Length - 1; $i++)
	{
		$finalpath += '\' + $commonpath[$i]
	}
	return $finalpath
}


function Assert-Mikero
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)
	
	# "C:\Program Files (x86)\Mikero\DePboTools"
	
	
	
	$testpath = "C:\Program Files (x86)\Mikero\DePboTools"
	if (Test-Path -Path $testpath)
	{
		if ($outpath)
		{
			$outpath.Value = $testpath
		}
		return $true
	}
	else
	{
		return $false
	}
}

<#
	.SYNOPSIS
		Test whether DayzFolder Exists
	
	.DESCRIPTION
		A detailed description of the Assert-DayzFolder function.
	
	.PARAMETER dayzfolderpath
		A description of the dayzfolderpath parameter.
	
	.EXAMPLE
		PS C:\> Assert-DayzFolder
	
	.NOTES
		Additional information about the function.
#>
function Assert-DayzFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)
	
	$common = Read-SteamCommon
	$testpath = $common + "\DayZ"
	if (Test-Path -Path $testpath)
	{
		if($outpath)
		{
			$outpath.Value = $testpath
		}

		return $true
	}
	else
	{
		return $false
	}
}


<#
	.SYNOPSIS
		Determine whether a profile folder exists in server folder
	
	.DESCRIPTION
		Determine whether a profile folder exists in server folder. 
	
	.EXAMPLE
				PS C:\> Assert-ProfilesFolder
	
	.NOTES
		Additional information about the function.
#>
function Assert-ProfilesFolder
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)
	
	
	$testpath = Read-GlobalParam -key "ServerFolder"
	$testpath = Add-Folder -Source $testpath -Folder "Profiles"
	if (Test-Path -Path $testpath)
	{
		if ($outpath)
		{
			$outpath.Value = $testpath
		}
		
		return $true
	}
	else
	{
		return $false
	}
}

function Assert-ToolsFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)

	$common = Read-SteamCommon
	$testpath = Add-Folder -Source $common -Folder "\DayZ Tools\Bin\"

	if (Test-Path -Path $testpath)
	{
		if ($outpath)
		{
			$outpath.Value = $testpath
		}
		return $true
	}
	else
	{
		return $false
	}
}

function Assert-ServerFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)
	
	$common = Read-SteamCommon
	$testpath = $common + "\DayZServer"
	if (Test-Path -Path $testpath)
	{
		if ($outpath)
		{
			$outpath.Value = $testpath
		}
		return $true
	}
	else
	{
		return $false
	}
}
function Assert-WorkbenchFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $true)]
		[ref]$outpath
	)
	
	$common = Read-SteamCommon
	$testpath = $common + "\DayZ Tools\Bin\Workbench"
	if (Test-Path -Path $testpath)
	{
		if ($outpath)
		{
			$outpath.Value = $testpath
		}
		return $true
	}
	else
	{
		return $false
	}
}

function Assert-ModScriptsFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)
	
	$curmodfolder = Read-GlobalParam "CurrentModFolder"
	if (-not $curmodfolder)
	{
		return $false
	}
	$testpath = Add-Folder -Source $curmodfolder -Folder "Scripts"
	if (Test-Path -Path $testpath)
	{
		if ($outpath)
		{
			$outpath.Value = $testpath
		}
		return $true
	}
	else
	{
		return $false
	}
}

function Assert-ProjectDrive
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $true)]
		[ref]$outpath
	)
	
	
	$testpath = "P:\"
	if (Test-Path -Path $testpath)
	{
		if ($outpath)
		{
			$outpath.Value = $testpath
		}
		return $true
	}
	else
	{
		return $false
	}
}






<#
	.SYNOPSIS
		Link directories delete if already exists
	
	.DESCRIPTION
		A detailed description of the Link-Directory function.
	
	.PARAMETER Link
		A description of the Link parameter.
	
	.PARAMETER Target
		A description of the Target parameter.
	
	.EXAMPLE
				PS C:\> Link-Directory
	
	.NOTES
		Additional information about the function.
#>
function Link-DayzFolders
{
	[CmdletBinding()]
	param
	(
		[string]$Link,
		[string]$Target
	)
	
	while (Test-Path -Path $Link)
	{
		if ((Get-Item -Path $Link -Force).LinkType) 
		{
			Remove-Item -Path $Link -Recurse 
		}
		
	}
	New-Item -ItemType SymbolicLink -Path $Link -Target $Target
	$output = $link  + "  ---->>  " + $target + "`n`n"
	Add-Content -Path "links.txt" -Value $output
}


<#
	.SYNOPSIS
		Remove all symbolic links
	
	.DESCRIPTION
		Remove all symbolic links in P: and Dayz folders.
	
	.EXAMPLE
				PS C:\> Remove-AllLinks
	
	.NOTES
		Additional information about the function.
#>
function Remove-AllLinks
{
	[CmdletBinding()]
	param ()
	
	Remove-FolderLinks -Folder "P:\"
	$dayzf = Read-GlobalParam -key "GameFolder"
	Remove-FolderLinks -Folder $dayzf
	
}

<#
	.SYNOPSIS
		Remove symbolic links in  a single folder
	
	.DESCRIPTION
		A detailed description of the Remove-FolderLinks function.
	
	.PARAMETER Folder
		A description of the Folder parameter.
	
	.EXAMPLE
		PS C:\> Remove-FolderLinks
	
	.NOTES
		Additional information about the function.
#>
function Remove-FolderLinks
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Folder
	)
	
	$targetfiles = Get-ChildItem $Folder *.* -Directory
	
	foreach ($link in $targetfiles)
	{
		if ((Get-Item -Path $link.PSPath -Force).LinkType)
		{
			Remove-Item -Path $link.PSPath -Recurse
		}
	}
}


function Link-All
{
	[CmdletBinding()]
	param ()
	
	Link-Packed
	Link-Scripts
	Link-Source
	Link-Workbench
	Link-Addons
	
	if (Test-Path -Path "links.txt")
	{
		Remove-Item -Path "links.txt"
		
	}
	
}
function Link-Scripts
{
	[CmdletBinding()]
	param ()
	
	#TODO: Place script here
	# Link mklink /J  "S:\Steam\steamapps\common\DayZ\scripts\" "P:\scripts\"
	
	
	
	$link = Read-GlobalParam -key "GameFolder"
	$link = Add-Folder -Source $link -Folder "Scripts"
	
	$target = Read-GlobalParam -key "ProjectDrive"
	$target = Add-Folder -Source $target -Folder "Scripts"
	
	Link-DayzFolders -Link $link -Target $target
	
	
	
	
}

function Link-Source
{
	[CmdletBinding()]
	param ()
	
	#TODO: Place script here
	# mklink /J "P:\FirstMod\" "S:\Steam\steamapps\common\DayZ\Mod-Source\FirstMod\" 
	
		
	$link = Read-GlobalParam -key "ProjectDrive"
	$modname = Read-ModParam -key "ModName"
	$link = Add-Folder -Source $link -Folder $Modname
	
	$target = Read-GlobalParam -key "ModSourceFolder"
	$target = Add-Folder -Source $target -Folder $modname
	

	Link-DayzFolders -Link $link -Target $target
	
	$link = Read-GlobalParam -key "GameFolder"
	$link = Add-Folder -Source $link -Folder $Modname
	
	Link-DayzFolders -Link $link -Target $target
}
function Link-Packed
{
	[CmdletBinding()]
	param ()
	
	#TODO: Place script here
	# mklink /J "S:\Steam\steamapps\common\DayZ\@FirstMod\"  "P:\PackedMods\@FirstMod\" 
	# mklink /J "P:\@FirstMod\"  "P:\PackedMods\@FirstMod\" 
	
	$modname = Read-ModParam -key "ModName"
	$packedfolder = '@' + $modname
	
	$link = Read-GlobalParam -key "ProjectDrive"
	$link = Add-Folder -Source $link -Folder $packedfolder
	
	$target = Read-GlobalParam -key "PackedModFolder"
	$target = Add-Folder -Source $target -Folder $packedfolder
	
	Link-DayzFolders -Link $link -Target $target
	
	$target = Read-GlobalParam -key "PackedModFolder"
	$target = Add-Folder -Source $target -Folder $packedfolder
	
	Link-DayzFolders -Link $link -Target $target
	
}

function Link-Workbench
{
	[CmdletBinding()]
	param ()
	

	
	#mklink /J "S:\Steam\steamapps\common\DayZ Tools\Bin\Workbench\addons" "S:\Steam\steamapps\common\DayZ\addons"
	$workbenchf = ""
	Assert-WorkbenchFolder -outpath ([ref]$workbenchf)
	$link = Add-Folder -Source $workbenchf -Folder "Addons"
	$dayzf = Read-GlobalParam -key "GameFolder"
	$target = Add-Folder -Source $dayzf -Folder "Addons"
	
	Link-DayzFolders -Link $link -Target $target
}


# Safely add new folder to path
function Add-Folder
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Source,
		[Parameter(Mandatory = $true)]
		[string]$Folder
	)
	
	# check for terminal \
	$Source = $Source.TrimEnd('\')
	$Folder = $Folder.TrimStart('\')
	
	$newfolder = $Source + "\" + $Folder
	
	return $newfolder
}
function Assert-EndSlash
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Path
	)
	
	#TODO: Place script here
	
	$Path.TrimEnd('\')
	$Path += "\"
	
	return $Path
}

#

function Set-Folder
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$key
	)
	
	$foldername = Read-GlobalParam -key $key
	Set-Location -Path $foldername
	
}
function Set-PopupMessage
{
	[CmdletBinding()]
	param
	(
		[string]$Title,
		[string]$Message,
		[switch]$ClearMessage
	)
	
	
	if ($ClearMessage)
	{
		$Message = ""
		Write-ScratchParam -key "Message" -value ""
		
	}
	
	Write-ScratchParam -key "Message" -value $Message


	
	if ($Title)
	{
		Write-ScratchParam -key "Title" -value $Title
		
	}
}
function Get-PopupMessage
{
	[CmdletBinding()]
	[OutputType([string])]
	param ()
	
	#TODO: Place script here
	return Read-ScratchParam -key "Message"
}
function Get-PopupTitle
{
	[CmdletBinding()]
	[OutputType([string])]
	param ()
	
	#TODO: Place script here
	return Read-ScratchParam -key "Title"
}

function Confirm-Globals
{
	[CmdletBinding()]
	[OutputType([bool])]
	param ()
	
	#TODO: Place script here
	
	$txtAddonsFolder = Read-GlobalParam -key "AddonsFolder"
	$txtGameFolder = Read-GlobalParam -key "GameFolder"
	$txtModSourceFolder = Read-GlobalParam -key "ModSourceFolder"
	$txtPackedModFolder = Read-GlobalParam -key "PackedModFolder"
	$txtProjectDrive = Read-GlobalParam -key "ProjectDrive"
	$txtServerFolder = Read-GlobalParam -key "ServerFolder"
	$txtWorkbenchFolder = Read-GlobalParam -key "WorkbenchFolder"
	
	
	
	if (-not $txtAddonsFolder)
	{
		return $false
	}
	
	if (-not $txtGameFolder)
	{
		return  $false
	}
	
	if (-not $txtModSourceFolder)
	{
		return $false
	}
	
	if (-not $txtPackedModFolder)
	{
		return $false
	}
	
	if (-not $txtProjectDrive)
	{
		return $false
	}
	
	if (-not $txtServerFolder)
	{
		return  $false
	}
	
	if (-not $txtWorkbenchFolder)
	{
		return $false
	}
	
	return  $true
}

<#
	.SYNOPSIS
		Copy addons to wb\addons
	
	.DESCRIPTION
		A detailed description of the Copy-Addons function.
	
	.PARAMETER Clear
		A description of the Clear parameter.
	
	.EXAMPLE
				PS C:\> Copy-Addons
	
	.NOTES
		Additional information about the function.
#>
function Link-Addons
{
	[CmdletBinding()]
	param
	(
		[switch]$Clear
	)
	
	$dayzf = Read-GlobalParam -key "GameFolder"
	$dzaddonsf = Add-Folder -Source $dayzf -Folder "Addons"
	$addonsf = Read-GlobalParam -key "AddonsFolder"
	$addons = Read-ModParam -key "AdditionalMPMods"
	$addonlist = $addons.Split(';')
	
	foreach ($mod in $addonlist)
	{
		$modfilter = Add-Folder -Source $addonsf -Folder "$mod\addons\*"
		
		$files = @(Get-ChildItem -Path $modfilter)
		
		foreach ($file in $files) {
			$link = Add-Folder -Source $dzaddonsf -Folder $file.Name
			$target = $file.FullName
			New-Item -ItemType SymbolicLink -Path $link -Target $target
		}
		
		
		
		
	}
	
}


function Mount-Pdrive
{
	[CmdletBinding()]
	param ()
	
	$testpath = ""
	Assert-ToolsFolder -outpath ([ref]$testpath)
	$command = Add-Folder -Source $testpath -Folder "\WorkDrive\WorkDrive.exe"
	$params = '/mount'
	Start-Process $command -ArgumentList $params
}

<#
	.SYNOPSIS
		Read final path/folder name from path
	
	.DESCRIPTION
		A detailed description of the Read-FinalPathName function.
	
	.PARAMETER Source
		A description of the Source parameter.
	
	.EXAMPLE
		PS C:\> Read-FinalPathName
	
	.NOTES
		Additional information about the function.
#>
function Read-FinalPathName
{
	[CmdletBinding()]
	param
	(
		[string]
		$Source
	)
	
$Source -replace '/', '\'
	$SourceArr = $Source.Split('\')
	$lasttoken = ""
	$lasttoken = $SourceArr.get($SourceArr.Length - 1)
	return $lasttoken
}




