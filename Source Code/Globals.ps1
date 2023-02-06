function Get-KommanderFolder
{
	[CmdletBinding()]
	[OutputType([string])]
	param ()
	
	$logpath = Get-ScriptDirectory
	$curfolder = Read-FinalPathName -Source $logpath
	if ($curfolder -eq "Source Code")
	{
		$logpath = $logpath.TrimEnd('Source Code')
		$logpath = $logpath.TrimEnd('\')
	}

	return $logpath
}

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
		$settingpath = Get-KommanderFolder
	}
	
	$fullsettingpath = Add-Folder -Source $settingpath -Folder "$settingname"

	$hashtable = @{ }
	
	if (-not (Test-Path -Path $fullsettingpath))
	{
		
		New-Item -Path $fullsettingpath -ItemType File
	}
	
	
	$json = Get-Content $fullsettingpath | Out-String
	
	if ($json)
	{
		(ConvertFrom-Json $json).psobject.properties | Foreach { $hashtable[$_.Name] = $_.Value }
	}
	
	
	
	
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
		$settingpath = Get-KommanderFolder

	}
	$fullsettingpath = Add-Folder -Source $settingpath -Folder $settingname
	if (Test-Path -Path $fullsettingpath)
	{
		$hashtable = Get-Settings -settingpath $settingpath -settingname $settingname
	}
	else
	{
		$hashtable = @{ }
	}
	
	
	
	
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
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$key,
		[Parameter(Mandatory = $true)]
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

function Get-ServerAddons
{
	[CmdletBinding()]
	[OutputType([string])]
	param ()
	$modlist = "";
	$addonsfolder = Read-GlobalParam -key "AddonsFolder"
	$modname = Read-ModParam -key "ModName"
	$packedmodname = '@' + $modname
	#	$packedmodpath = Read-GlobalParam -key "PackedModFolder"
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

function Get-WorkbenchAddons
{
	[CmdletBinding()]
	[OutputType([string])]
	param ()
	$modlist = "";
	$addonsfolder = Read-GlobalParam -key "AddonsFolder"
	$modname = Read-ModParam -key "ModName"
	$packedmodname = '@' + $modname
	#	$packedmodpath = Read-GlobalParam -key "PackedModFolder"
	$packedmodpath = Read-GlobalParam -key "PackedModFolder"
	$packedmodpath = Add-Folder -Source $packedmodpath -Folder $packedmodname
	
	$modlist = $modlist + $packedmodpath + ';'
	$addonsstr = Read-ModParam -key "AdditionalWBMods"
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
	
	$modlist = Get-ServerAddons
	$gamef = Read-GlobalParam -key "GameFolder"
	$serverf = Read-GlobalParam -key "ServerFolder"
	$serverDZ = '"' + "-config=" + $serverf + "\serverDZ.cfg" + '"'
	$profilesf = Read-GlobalParam -key "ProfilesFolder" 
	$profilesparam = "`"-profiles=" + $profilesf + "`""
	$mods = "`"-mod=" + $modlist + "`""
	$command = $gamef + "\DayZDiag_x64.exe"
	#$params = $mods, '-filePatching', '-server', '-config=serverDZ.cfg', '-profiles=S:\Steam\steamapps\common\DayZ\profiles'
	$params = $mods, '-filePatching', '-server', $serverDZ, $profilesparam
	
	if ($commandline)
	{
		return $command + "`n" + $params
	}
	else
	{
		Set-Folder -key "GameFolder"
		#& $command @params
		Start-Process $command -ArgumentList $params  
		
	}
	
	
}

function Start-kMPGame
{
	param
	(
		[switch]$CommandLine
	)
	
	$modlist = Get-ServerAddons
	$gamef = Read-GlobalParam -key "GameFolder"

	$command = $gamef + "\DayZDiag_x64.exe"
	$mods = "`"-mod=" + $modlist + "`""
	$gameparams = $mods, '-filePatching', '-connect=127.0.0.1', '-port=2302'
	
	if ($commandline)
	{
		return $command + "`n" + $gameparams
	}
	else
	{
		Set-Folder -key "GameFolder"
		#& $command @params
		Start-Process $command -ArgumentList $gameparams 
	}
	
}


function Start-kWorkbench
{
	[CmdletBinding()]
	param
	(
		[switch]$Commandline = $false
	)
	
	$modlist = Get-WorkbenchAddons
	$workbenchf = Read-GlobalParam -key "WorkbenchFolder"
	$command = Add-Folder -Source $workbenchf -Folder "workbenchApp.exe"
    $mods = "`"-mod=" + $modlist + "`""
	# $params = $mods + ",-dologs,-adminlog,-freezecheck,`"scriptDebug=true`""
	$params = $mods
	
	
	if ($commandline)
	{
		 return $command + "`n" + $params

	}
	else
	{
		
		$curmodfolder = Read-GlobalParam -key "CurrentModFolder"
		$modworkbenchfolder = Add-Folder -Source $curmodfolder -Folder "Kommander"
		#Set-Location $modworkbenchfolder
		Set-Folder -key "WorkbenchFolder"
		#Set-Folder -key "CurrentModFolder"
		# & $command @params
		
		
		Start-Process $command -ArgumentList $params 
	}
	
}

<#
	.SYNOPSIS
		Remove existing pbo from packed folder
	
	.DESCRIPTION
		Force delete option 
	
	.EXAMPLE
				PS C:\> Remove-ExistingPackedPbo
	
	.NOTES
		Additional information about the function.
#>
function Remove-ExistingPackedPbo
{
	[CmdletBinding()]
	param ()
	
	$curpackedmodf = Read-GlobalParam -key "PackedModFolder"
	$modname = Read-ModParam -key "ModName"
	$curpackedmodf = Add-Folder -Source $curpackedmodf -Folder "@$modname\addons\*"
	
	Remove-Item -Path $curpackedmodf -Filter '*.pbo' -Force 
}

function Start-BuildAddonBuilder
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[switch]$Commandline = $false

	)
	
	
	
	# start /D "S:\Steam\steamapps\common\DayZ Tools\Bin\AddonBuilder" addonbuilder.exe "P:\RationalGPS" S:\Mod-Packed\@RationalGPS\addons -clear -project=P:  
	
	$addonbuilder = Read-SteamCommon
	$addonbuilderf = Add-Folder -Source $addonbuilder -Folder "DayZ Tools\Bin\AddonBuilder"
	$addonbuilder = Add-Folder -Source $addonbuilderf -Folder "Addonbuilder.exe"
	$command = '"' + $addonbuilder + '"'
	
	$cliparams = Read-GlobalParam -key "AddonBuilderParams"
	
	$modname = Read-ModParam -key "ModName"
	Create-BuildFolder -ModName $modname
	
	$buildlogpath = Read-GlobalParam -key "CurrentModFolder"
	$buildlogpath = Add-Folder -Source $buildlogpath -Folder "Kommander\buildoutput.txt"
	
	$packedmodf = Read-GlobalParam -key "PackedModFolder"
	$packedmodf = Add-Folder -Source $packedmodf -Folder "@$modname\addons"
	
	$projectdrive = Read-GlobalParam -key "ProjectDrive"
	$paramsetting = Add-Folder -Source $projectdrive -Folder $modname
	$project = $projectdrive.TrimEnd('\')
	$project = "-project=" + $project
	$paramsetting = $paramsetting + "," + '"' + $packedmodf + '"'
	$paramsetting = $paramsetting + ", $cliparams"
	
	
	$params = $paramsetting.Split(',')
	
	if ($commandline)
	{
		$output = $command + "`n" + $params
		return $output
		
	}
	

	
	Set-Location -Path $addonbuilderf
	
	Reset-BuildSuccess
	
	Start-Process $command -ArgumentList $params  -Wait -RedirectStandardOutput "$buildlogpath"
	
	Set-BuildSuccess 
	
}

function Start-BuildMikero
{
	[CmdletBinding()]
	[OutputType([string])]
	param
	(
		[switch]$Commandline = $false
		
	)
	Remove-ExistingPackedPbo
	$modname = Read-ModParam -key "ModName"
	Create-BuildFolder -ModName $modname
	$buildlogpath = Read-GlobalParam -key "CurrentModFolder"
	$buildlogpath = Add-Folder -Source $buildlogpath -Folder "Kommander\buildoutput.txt"
	
	
	# $params = "-P", "-Z", "-O", "-E=dayz", "-K", "+M=P:\PackedMods\@FirstMod", "S:\Steam\steamapps\common\DayZ\Mod-Source\FirstMod\Scripts"
	$command = "pboProject.exe"
	$scriptname = Read-ModParam -key "ModName"
	$paramsetting = Read-GlobalParam -key "PboProjectParams"
	$packedmod = Get-PackedMod
	$paramsetting += ",`"+M=$packedmod`""
	$scriptsf = Read-ModParam -key "ScriptsFolder"
	$paramsetting += ",`"$scriptsf`""
	$paramsetting += ",+L=" + $scriptname
	
	$params = $paramsetting.Split(',')
	
	$trash = Link-All
	
	
	
	if ($commandline)
	{
		return $command + "`n" + $params
	}
	else
	{
		Set-Location "P:"
		Start-Process "pboProject.exe" -ArgumentList $params -RedirectStandardOutput "$buildlogpath"
	}
	
	
	Set-BuildSuccess
	
}

<#
	.SYNOPSIS
		Request a log file or log folder
	
	.DESCRIPTION
		A detailed description of the Request-Log function.
	
	.PARAMETER Folder
		A description of the Folder parameter.
	
	.PARAMETER FilePath
		A description of the FilePath parameter.
	
	.PARAMETER InitialDirectory
		A description of the InitialDirectory parameter.
	
	.PARAMETER Filter
		A description of the Filter parameter.
	
	.PARAMETER MostRecent
		A description of the MostRecent parameter.
	
	.EXAMPLE
		PS C:\> Request-Log
	
	.NOTES
		Additional information about the function.
#>
function Request-Log
{
	[CmdletBinding()]
	param
	(
		[string]$Folder,
		[string]$FilePath,
		[string]$InitialDirectory,
		[string]$Filter,
		[switch]$MostRecent
	)
	
	# reset old values if any
	Write-ScratchParam -key "RequestedLogFolder" -value ""
	Write-ScratchParam -key "RequestedLogPath" -value ""
	Write-ScratchParam -key "RequestedInitialDirectory" -value ""
	Write-ScratchParam -key "RequestedFilter" -value ""
	Write-ScratchParam -key "RequestedMostRecent" -value ""
	
	# set new values
	Write-ScratchParam -key "RequestedLogFolder" -value $Folder
	Write-ScratchParam -key "RequestedLogPath" -value $FilePath
	Write-ScratchParam -key "RequestedInitialDirectory" -value $InitialDirectory
	Write-ScratchParam -key "RequestedFilter" -value $Filter
	if ($MostRecent)
	{
		Write-ScratchParam -key "RequestedMostRecent" -value $true
	}
	else
	{
		Write-ScratchParam -key "RequestedMostRecent" -value $false
	}
	
	Show-DisplayLogs_psf
}



function Get-BuildLogPath
{
	[CmdletBinding()]
	[OutputType([string])]
	param ()
	
	$buildmethod = Read-GlobalParam -key "BuildMethod"
	if ($buildmethod -eq "Tools")
	{
		$buildlogpath = Read-GlobalParam -key "CurrentModFolder"
		$buildlogpath = Add-Folder -Source $buildlogpath -Folder "Kommander\buildoutput.txt"
	}
	elseif ($buildmethod -eq "Mikero")
	{
		$buildlogpath = ""
		Assert-MikeroLogFolder -outpath ([ref]$buildlogpath)
		$buildlogpath = Add-Folder -Source $buildlogpath -Folder "Scripts.packing.log"
	}
	
	return $buildlogpath
}

function Create-BuildFolder
{
	[CmdletBinding()]
	param
	(
		[string]$ModName

	)
	$packedmodf = Read-GlobalParam -key "PackedModFolder"
	if (-not (Test-Path -Path $packedmodf))
	{
		New-Item -Path $packedmodf -ItemType Directory
	}
	
	$packedmodf = Add-Folder -Source $packedmodf -Folder "@$modname"
	if (-not (Test-Path -Path $packedmodf))
	{
		New-Item -Path $packedmodf -ItemType Directory
	}
	
	$packedmodf = Add-Folder -Source $packedmodf -Folder "addons"
	if (-not (Test-Path -Path $packedmodf))
	{
		New-Item -Path $packedmodf -ItemType Directory
	}
}

<#
	.SYNOPSIS
		Turns build log button green or red to indicate build success or failure
	
	.DESCRIPTION
		A detailed description of the Set-BuildSuccess function.
	
	.PARAMETER Path
		A description of the Path parameter.
	
	.EXAMPLE
		PS C:\> Set-BuildSuccess
	
	.NOTES
		Additional information about the function.
#>
function Set-BuildSuccess
{
	[CmdletBinding()]
	[OutputType([bool])]
	param()
	
	$buildlogpath = Get-BuildLogPath
	$buildmethod = Read-GlobalParam -key "BuildMethod"
	if($buildmethod -eq "Tools")
	{

		$success = Get-Content -Path $buildlogpath | Select-String -Pattern "build successful"
		$failure = Get-Content -Path $buildlogpath | Select-String -Pattern "build fail"
	}
	elseif ($buildmethod -eq "Mikero")
	{
	
		$ModName = Read-ModParam -key "ModName"
		$success = Get-Content -Path $buildlogpath | Select-String -Pattern "success"

		
	}
	
	if ($success)
	{
		$buttonOpenBuildLog.BackColor = 'Green'
		$buttonB.BackColor = 'Green'
		return $true
	}
	else
	{
		
		$buttonOpenBuildLog.BackColor = 'Red'
		return $false
		
	}
}

function Reset-BuildSuccess
{
	[CmdletBinding()]
	param ()
	$buttonOpenBuildLog = 'Transparent'
	
	
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
	taskkill /im DayZDiag_x64.exe /F /T /FI "STATUS eq RUNNING"
}



function Stop-DayzOnly
{
	[CmdletBinding()]
	param ()
	
	$processes = Get-Process dayz* | Where-Object { $_.mainWindowTitle -notlike "*port*" }

	Stop-Process $processes -Force
}

function Use-ReloadDayz
{
	[CmdletBinding()]
	param ()
	
	Stop-DayzOnly
	Start-Sleep -Seconds 1
	Start-kMPGame
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

function Read-MikeroInstallFolder
{
	[CmdletBinding()]
	[OutputType([string])]
	param ()
	
	$regpath = (Get-ItemProperty -Path 'Registry::HKCU\SOFTWARE\Mikero\depbo').path
	return $regpath
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
function Use-Launch
{
	[CmdletBinding()]
	param ()
	
	Stop-kDayz
	Start-kServer
	Start-Sleep -Seconds 10
	Start-kMPGame
}
function Use-ClientLogs
{
	[CmdletBinding()]
	param ()
	
	$appdata = $env:LOCALAPPDATA
	Request-Log -Folder "$appdata\Dayz" -InitialDirectory "$appdata\Dayz" -Filter "All Files (*.*)|*.*|RPT (*.RPT)|*.rpt|Log (*.log)|*.log" -MostRecent
}
function Use-ServerLogs
{
	[CmdletBinding()]
	param ()
	
	$profilef = Read-GlobalParam -key "ProfilesFolder"
	Request-Log -Folder $profilef -InitialDirectory $profilef -Filter "All Files (*.*)|*.*|RPT (*.RPT)|*.rpt|Log (*.log)|*.log" -MostRecent
}

function Merge-Logs
{
	[CmdletBinding()]
	param ()
	
	# Copy logs to temp
	$appdata = $env:LOCALAPPDATA
	$mostrecentclientlog = Get-ChildItem "$appdata\Dayz" -Filter "script*.log" | sort LastWriteTime | select -last 1
	
	$profilef = Read-GlobalParam -key "ProfilesFolder"
	$mostrecentserverlog = Get-ChildItem $profilef -Filter "script*.log" | sort LastWriteTime | select -last 1
	
	
	
}


function Use-Build
{
	[CmdletBinding()]
	param ()
	
	$linkall = Read-GlobalParam -key "AutoLinkOnBuild"
	if ($linkall -eq $true)
	{
		$trash = Link-All
	}

	
	
	$buildmethod = Read-GlobalParam -key "BuildMethod"
	Reset-BuildSuccess
	if ($buildmethod -eq "Tools")
	{
		Start-BuildAddonBuilder
	}
	elseif ($buildmethod -eq "Mikero")
	{
		Start-BuildMikero
	}
	
}

<#
	.SYNOPSIS
		Determine whether a profile folder exists in server folder
	
	.DESCRIPTION
		Determine whether a profile folder exists in server folder.
	
	.PARAMETER outpath
		A description of the outpath parameter.
	
	.PARAMETER Path
		Path to Server Folder
	
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
		[ref]$outpath,
		$Path
	)
	
	if ($Path)
	{
		$testpath = $Path
	}
	else
	{
		$testpath = Read-GlobalParam -key "ServerFolder"
	}
	

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

function Assert-ModLayoutFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)
	
	$modscriptsf = ""
	Assert-ModScriptsFolder ([ref]$modscriptsf)
	if ($modscriptsf)
	{
		$layoutf = Add-Folder -Source $modscriptsf -Folder "Gui\Layouts"
		if (Test-Path -Path $layoutf)
		{
			
			if ($outpath)
			{
				$outpath.Value = $layoutf
			}
			return $true
			
		}
		else
		{
			return $false
		}
		
	}
	
}

function Assert-ModInputsFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)
	
	$modscriptsf = ""
	Assert-ModScriptsFolder ([ref]$modscriptsf)
	if ($modscriptsf)
	{
		$inputsxml = Add-Folder -Source $modscriptsf -Folder "Data\inputs.xml"
		if (Test-Path -Path $inputsxml)
		{
			
			if ($outpath)
			{
				$outpath.Value = "$modscriptsf\data"
			}
			return $true
			
		}
		else
		{
			return $false
		}
		
	}
	
}

function Assert-MikeroLogFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $false)]
		[ref]$outpath
	)
	
	$modscriptsf = ""
	$curmoddrive = Read-GlobalParam -key "CurrentModFolder"
	$curmoddrive = $curmoddrive.Split("\")
	$curmoddrive = $curmoddrive[0]
	
	
	$testpath = Add-Folder -Source $curmoddrive -Folder "Temp"
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

function Assert-TemplateFolder
{
	[CmdletBinding()]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory = $true)]
		[ref]$outpath
	)
	
	$kommanderf = Get-KommanderFolder
	$testpath = Add-Folder -Source $kommanderf -Folder "Source Code\TemplateMod"

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
	
	if (Test-Path -Path $Link)
	{
		if ((Get-Item -Path $Link -Force).LinkType) 
		{
			Remove-Item -Path $Link -Recurse -Force
		}
		
	}
	
	$curfolder = Read-GlobalParam -key "CurrentModFolder"
	$logfolder = Add-Folder -Source $curfolder -Folder "Kommander\link.log"
	New-Item -ItemType SymbolicLink -Path $Link -Target $Target
	$output = $link  + "  ---->>  " + $target + "`n`n"
	Add-Content -Path $logfolder -Value $output
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
	$dayzaddonsf = Add-Folder -Source $dayzf -Folder "Addons"
	Remove-FileLinks -Folder $dayzaddonsf
	$workbenchf = Read-GlobalParam -key "WorkbenchFolder"
	Remove-FolderLinks -Folder $workbenchf
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
			Remove-Item -Path $link.PSPath -Recurse -Force
		}
	}
}
function Remove-FileLinks
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Folder
	)
	
	$targetfiles = Get-ChildItem $Folder *.* -File
	foreach ($link in $targetfiles)
	{
		if ((Get-Item -Path $link.PSPath -Force).LinkType)
		{
			Remove-Item -Path $link.PSPath -Recurse -Force
		}
	}
}

function Link-All
{
	[CmdletBinding()]
	param ()
	
	if (Test-Path -Path "links.txt")
	{
		Remove-Item -Path "links.txt"
		
	}
	
	$usebatch = Read-GlobalParam -key "UseBatch"
	if ($usebatch -eq $true)
	{
		$curmodf = Read-GlobalParam -key "CurrentModFolder"
		$linkpath = Add-Folder -Source $curmodf -Folder "linkall.bat"
		
		start-process $linkpath
		
	}
	else
	{
		
		$linkworkbench = Read-GlobalParam -key "LinkWorkbench"
		$linkscripts = Read-GlobalParam -key "LinkScripts"
		$linksource = Read-GlobalParam -key "LinkSource"
		$linkpacked = Read-GlobalParam -key "LinkPacked"
		$linkaddons = Read-GlobalParam -key "LinkAddons"
		
		if ($linkpacked -eq $true)
		{	
			Link-Packed
		}
		if ($linkscripts -eq $true)
		{
			Link-Scripts
		}
		if ($linksource -eq $true)
		{
			Link-Source
		}
		if ($linkworkbench -eq $true)
		{
			Link-Workbench
		}
		if ($linkaddons -eq $true)
		{
			Link-Addons
		}
		
		
		
		
		
		

		
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
	if ($addons)
	{
		$addonlist = $addons.Split(';')
	}
	
	
	foreach ($mod in $addonlist)
	{
		$modfilter = Add-Folder -Source $addonsf -Folder "$mod\addons\*"
		
		$files = @(Get-ChildItem -Path $modfilter)
		
		foreach ($file in $files) {
			$link = Add-Folder -Source $dzaddonsf -Folder $file.Name
			$target = $file.FullName
			Link-DayzFolders -Link $link -Target $target

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
	
	$Source = $Source -replace '/', '\'
	$SourceArr = $Source.Split('\')
	$lasttoken = ""
	$lasttoken = $SourceArr.get($SourceArr.Length - 1)
	return $lasttoken
}

function Start-Archive
{
	[CmdletBinding()]
	param
	(
		[string]$Comment
	)
	
	$sourcepath = Read-GlobalParam -key "CurrentModFolder"
	$targetpath = Read-GlobalParam -key "ArchiveFolder"
	$modname = Read-ModParam -key "ModName"
	$datetime = Get-Date -Format "yyyy-MM-dd-HH-mm"
	$targetpath = Add-Folder -source $targetpath -Folder "$modname"
	if (-not (Test-Path -Path $targetpath))
	{
		New-Item -Path $targetpath -ItemType "Directory"
		
	}
	if ($Comment)
	{
		$Comment = $Comment.Replace(' ','_')
		$targetpath = Add-Folder -Source $targetpath -Folder "$modname.$datetime--$Comment.zip"
		
	}
	else
	{
		$targetpath = Add-Folder -Source $targetpath -Folder "$modname.$datetime.zip"
	}

	Compress-Archive -Path $sourcepath -DestinationPath $targetpath
}

function Start-dngrep
{
	[CmdletBinding()]
	param
	(
		[string]$path,
		[string]$searchFor
	)
	
	if (-not $path)
	{
		$path = Read-GlobalParam -key "dngreppath"
	}
	$params = "-searchFor " + $searchFor
	$params = "-folder P:\scripts\", $searchFor
	Start-Process $path 
}


function Update-Batchfiles
{
	[CmdletBinding()]
	param
	(
		
	)
	# Copy Template Batch Files
	

	$templatefolder = Read-GlobalParam -key "TemplateFolder"
	$modfolder = Read-GlobalParam -key "CurrentModFolder"
	$ModName = Read-ModParam -key "ModName"
	
	Copy-Item "$templatefolder\*.bat" -Destination $modfolder -Force
	$targetfiles = Get-ChildItem $ModFolder  *.* -File -rec
	
	foreach ($file in $targetfiles)
	{
		if ($file.Extension -eq ".bat")
		{
			# WB_WORKBENCHFOLDER
			$workbenchf = ""
			Assert-WorkbenchFolder -outpath ([ref]$workbenchf)
			Edit-TemplateTokens -Source "WB_WORKBENCHFOLDER" -Replace $workbenchf -File $file -Folder $ModFolder
			
			#WB_PROJECTDRIVE
			$projectdrive = ""
			Assert-ProjectDrive -outpath ([ref]$projectdrive)
			$projectdrive = $projectdrive.TrimEnd('\')
			Edit-TemplateTokens -Source "WB_PROJECTDRIVE" -Replace $projectdrive -File $file -Folder $ModFolder
			
			# WB_PDRIVEPACKEDMOD
			$ppacked = ""
			Assert-ProjectDrive -outpath ([ref]$ppacked)
			$ppacked = Add-Folder -Source $ppacked -Folder "@$ModName"
			Edit-TemplateTokens -Source "WB_PDRIVEPACKEDMOD" -Replace $ppacked -File $file -Folder $ModFolder
			
			
			# WB_ADDONBUILDER
			$addonbuilder = Read-SteamCommon
			$addonbuilder = Add-Folder -Source $addonbuilder -Folder "DayZ Tools\Bin\AddonBuilder"
			Edit-TemplateTokens -Source "WB_ADDONBUILDERFOLDER" -Replace $addonbuilder -File $file -Folder $ModFolder
			
			
			# WB_PACKEDMOD
			$packmod = Read-GlobalParam -key "PackedModFolder"
			$packmod = Add-Folder -Source $packmod -Folder "@$ModName"
			$modlist = Get-ServerAddons
			Edit-TemplateTokens -Source "WB_PACKEDMOD" -Replace $packmod -File $file -Folder $ModFolder
			
			# WB_SERVERMODLIST
			$servermodlist = Get-ServerAddons
			Edit-TemplateTokens -Source "WB_SERVERMODLIST" -Replace $servermodlist -File $file -Folder $ModFolder
			
			# WB_WORKBENCHMODLIST			
			$workbenchmodlist = Get-WorkbenchAddons
			Edit-TemplateTokens -Source "WB_WORKBENCHMODLIST" -Replace $workbenchmodlist -File $file -Folder $ModFolder
			
			# WB_DAYZFOLDER
			$dayzf = ""
			Assert-DayzFolder -outpath ([ref]$dayzf)
			Edit-TemplateTokens -Source "WB_DAYZFOLDER" -Replace $dayzf -File $file -Folder $ModFolder
			
			
			# WB_PROFILES
			$dzprofies = ""
			Assert-DayzFolder -outpath ([ref]$dzprofies)
			$dzprofies = Add-Folder -Source $dzprofies -Folder "Profiles"
			Edit-TemplateTokens -Source "WB_PROFILES" -Replace $dzprofies -File $file -Folder $ModFolder
			
			# WB_MODNAME
			Edit-TemplateTokens -Source "WB_MODNAME" -Replace $Modname -File $file -Folder $ModFolder
			
			# WB_SOURCEFOLDER
			$sourcefolder = Read-GlobalParam -key "ModSourceFolder"
			Edit-TemplateTokens -Source "WB_SOURCEFOLDER" -Replace $sourcefolder -File $file -Folder $ModFolder
		}
		
	}
}
