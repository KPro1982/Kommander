function Edit-UICodeFromLayout
{
	[CmdletBinding()]
	param
	(
		[string]$layoutpath
	)
	
	$layoutfolder = Read-ModParam -key "LayoutFolder"
	$scriptsfolder = Read-ModParam -key "ScriptsFolder"
	$inputsfolder = Read-ModParam -key "InputsFolder"
	
	
	
	##############################################################################
	# Obtain Layout File
	
	
	$rootfolder = Get-Location
	$templatefolder = "UIHelperTemplate"
	$layout = ".layout"
	
	# forms asset not automatically loaded, so load it now
	Add-Type -AssemblyName System.Windows.Forms
	
	
	
	# strip away the full path.
	# UI variables will be renamed to include the layout name so that we can have multiple UI's in the same mod
	
	$Name = (Get-Item $FileBrowser.FileName).Basename
	
	##############################################################################
	#Copy and Rename UIHelperTemplate
	
	# Test-Path is the PS method for verifying that a file or folder exists
	# This test verifies that the UI folder doesn't exist. If it does user must be running it twice.
	# Force user to delete it manually to avoid issues
	If (Test-Path -Path $Name)
	{
		Write-Host "*** Error: a $Name folder already exists in this location. Please delete $Name folder and rerun this script."
		Read-Host "*** Any key to exit on error"
		Exit 0
		
	}
	
	# This is the actual copy instruction. Recurse flag is needed to copy subfolders
	Copy-Item .\$templatefolder -Destination ".\$Name" -Recurse
	
	# Remove git folder if it exists
	If (Test-Path -Path ".\$Name\.git")
	{
		Remove-Item ".\$Name\.git" -Recurse -Force
	}
	
	##############################################################################
	# Rename files inside the new copy of the UITemplate Folder using the $Name value we captured above
	
	# Rename UITemplate.c This is our main menu class. This changes the filename NOT internal references to the class
	$NewUIName = "UI" + $Name + ".c"
	$SourePath = ".\" + "$Name\5_Mission\UIHelper\UI\UITemplate.c"
	Rename-Item $SourePath -NewName $NewUIName
	
	
	
	##############################################################################
	# Rename internal reference from the generic template name to a specific name based on the $Name value
	
	
	# Rename internal reference to UI_TEMPLATEID which is the constant contained in constants.c
	$replacementID = "UI_" + $Name + "ID"
	$targetfiles = Get-ChildItem $Name *.* -File -rec
	
	# This loop will check all of the files. Its a more general solution than targeting specific files
	# Its more flexible if we expand the number of files
	# But we have to be careful that the values targeted for replacement are unique otherwise ooof
	
	foreach ($file in $targetfiles)
	{
		(Get-Content $file.PSPath) |
		Foreach-Object { $_ -replace "UI_TEMPLATEID", $replacementID } |
		Set-Content $file.PSPath
	}
	
	
	# Rename the main class INSIDE files. The filename was changed above
	$uitempname = "UI" + $Name
	foreach ($file in $targetfiles)
	{
		(Get-Content $file.PSPath) |
		Foreach-Object { $_ -replace "UITemplate", $uitempname } |
		Set-Content $file.PSPath
	}
	
	# Rename the helper class inside UIMenuUtils to a unique name for each new layout processed.
	# Otherwise we will get a duplicate definition error if two of our mods run at the same time.
	$utilname = $Name + "Utils"
	foreach ($file in $targetfiles)
	{
		(Get-Content $file.PSPath) |
		Foreach-Object { $_ -replace "UIMenuUtils", $utilname } |
		Set-Content $file.PSPath
	}
	
	# change back to forward slashes because dayz needs that
	$forwardslashlayoutpath = $layoutpath -replace "\\", "/"
	
	# Insert the correct layout path into the Init() method of our main class
	foreach ($file in $targetfiles)
	{
		(Get-Content $file.PSPath) |
		Foreach-Object { $_ -replace "FULLLAYOUTPATH", $forwardslashlayoutpath } |
		Set-Content $file.PSPath
	}
	
	##############################################################################
	# Call additional scripts
	# These are separate for ease of testing and maintainability
	# But they could all be included in the same file
	# Powershell scripts can take parameters which is what the -layoutname and -layoutpath are 
	
	
	# Code creation script
	& ".\CallCreateUICode.ps1" -layoutname $Name -layoutpath $layoutpath
	
	
	#  insert generated code into template scripts
	& ".\CallInsertUICode.ps1" -layoutname $Name
	
	##############################################################################
	# Copying files from the UIHelper folder into their proper location
	# copying inputs.xml
	
	$inputsfile = 'inputs.xml'
	$inputsfileui = 'uiinputs.xml'
	If (Test-Path -Path $inputsfolder$inputsfile)
	{
		# User already has an inputs.xml
		# So call it uiinputs.xml and inform the user that they have to integrate manually
		Copy-Item ".\$Name\inputs.xml" $inputsfolder$inputsfileui
		Write-Host "Creating $inputsfileui....."
		Write-Host "IMPORTANT!!! You must integrate $inputsfileui into the existing inputs.xml before the keybinds will work."
	}
	else
	{
		# as no inputs.xml exists, create a new one
		Copy-Item ".\$Name\inputs.xml" $inputsfolder
		
	}
	
	# copying 3_Game
	$gamepath = "$scriptsfolder" + "3_Game"
	If (Test-Path -Path $gamepath\UIHelper)
	{
		Write-Host	"Error: $gamepath \UIHelper folder already exists!!!"
		Exit 0
	}
	else
	{
		# copy folder
		Copy-Item ".\$Name\3_Game\UIHelper\" -Destination $gamepath -Recurse
	}
	
	# copying 5_Mission
	$missionpath = "$scriptsfolder" + "5_Mission"
	If (Test-Path -Path $missionpath\UIHelper)
	{
		Write-Host	"Error: $missionpath\UIHelper folder already exists!!!"
		Exit 0
	}
	else
	{
		# copy folder
		Copy-Item ".\$Name\5_Mission\UIHelper\" -Destination $missionpath -Recurse
		
	}
	
	#Remove temporary files
	Remove-Item ".\Switch.txt"
	Remove-Item ".\Definitions.txt"
	Remove-Item ".\Casts.txt"
	Remove-Item ".\Temp.txt"
	
	Write-Host ""
	Write-Host ""
	Exit 0
}
