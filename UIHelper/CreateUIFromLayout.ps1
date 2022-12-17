function Edit-UICodeFromLayout
{
	[CmdletBinding()]
	param
	(
		[string]$layoutpath
	)
	
	$layoutfolder = Read-ModParam -key "LayoutFolder"
	$scriptsfolder = Read-ModParam -key "ScriptsFolder"

	
	
	
	##############################################################################
	# Obtain Layout File
	
	
	$rootfolder = Get-Location
	$rootfolder = Add-Folder -Source $rootfolder -Folder "UIHelper"
	$templatefolder = "UIHelperTemplate"
	$layout = ".layout"
	$modkommanderf = Read-GlobalParam -key "CurrentModFolder"
	$modkommanderf = Add-Folder -Source $modkommanderf -Folder "Kommander"
	Set-Location -Path $rootfolder
	
	# forms asset not automatically loaded, so load it now
	Add-Type -AssemblyName System.Windows.Forms
	
	
	
	# strip away the full path.
	# UI variables will be renamed to include the layout name so that we can have multiple UI's in the same mod
	
	$Name = (Get-Item $layoutpath).Basename
	
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
	Copy-Item .\$templatefolder -Destination "$modkommanderf\$Name" -Recurse
	
	
	##############################################################################
	# Rename files inside the new copy of the UITemplate Folder using the $Name value we captured above
	
	# Rename UITemplate.c This is our main menu class. This changes the filename NOT internal references to the class
	$NewUIName = "UI" + $Name + ".c"
	$SourcePath = Add-Folder -Source $modkommanderf -Folder "$Name\5_Mission\UIHelper\UI\UITemplate.c"
	Rename-Item $SourcePath -NewName $NewUIName
	
	Set-Location -Path $modkommanderf
	
	##############################################################################
	# Rename internal reference from the generic template name to a specific name based on the $Name value
	
	
	# Rename internal reference to UI_TEMPLATEID which is the constant contained in constants.c
	$replacementID = "UI_" + $Name + "ID"
	# $targetfiles = Get-ChildItem $Name *.* -File -rec
	
	Edit-TemplateTokens -Source "UI_TEMPLATEID" -Replace $replacementID -Folder $Name -Recurse


	# Rename the main class INSIDE files. The filename was changed above
	$uitempname = "UI" + $Name
	Edit-TemplateTokens -Source "UITemplate" -Replace $uitempname -Folder $Name -Recurse
	
	# Rename the helper class inside UIMenuUtils to a unique name for each new layout processed.
	# Otherwise we will get a duplicate definition error if two of our mods run at the same time.
	$utilname = $Name + "Utils"
	Edit-TemplateTokens -Source "UIMenuUtils" -Replace $utilname  -Folder $Name -Recurse
	
	# change back to forward slashes because dayz needs that
	$forwardslashlayoutpath = $layoutpath -replace "\\", "/"
	
	# Insert the correct layout path into the Init() method of our main class
	Edit-TemplateTokens -Source "FULLLAYOUTPATH" -Replace $forwardslashlayoutpath -Folder $Name -Recurse

	
	##############################################################################
	# Call additional scripts
	# These are separate for ease of testing and maintainability
	# But they could all be included in the same file
	# Powershell scripts can take parameters which is what the -layoutname and -layoutpath are 
	
	
	# Code creation script
	Edit-CreateCode -layoutname $Name -layoutpath $layoutpath
	
	
	#  insert generated code into template scripts
	Edit-InsertCode -layoutname $Name

	
	##############################################################################
	# Copying files from the UIHelper folder into their proper location
	# copying inputs.xml
	$inputsfolder = Read-ModParam -key "InputsFolder"
	$inputsxml = Add-Folder -Source $inputsfolder -Folder "inputs.xml"
	$inputsfileui = Add-Folder -Source $inputsfolder -Folder "uiinputs.xml"
	If (Test-Path -Path $inputsxml )
	{
		# User already has an inputs.xml
		# So call it uiinputs.xml and inform the user that they have to integrate manually
		Copy-Item ".\$Name\inputs.xml" $inputsfileui
		Write-Host "Creating $inputsfileui....."
		Write-Host "IMPORTANT!!! You must integrate $inputsfileui into the existing inputs.xml before the keybinds will work."
	}
	else
	{
		# as no inputs.xml exists, create a new one
		Copy-Item ".\$Name\inputs.xml" $inputsxml
		
	}
	
	# copying 3_Game
	$gamepath = Add-Folder -Source $scriptsfolder -Folder "3_Game"
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
	$missionpath = Add-Folder -Source $scriptsfolder -Folder "5_Mission"
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

}
