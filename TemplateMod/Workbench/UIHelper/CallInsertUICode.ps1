Param(
    [Parameter( Mandatory = $true)]
    $layoutname = ""    
)


$sourcename = ".\UI" + $layoutname + ".c"
$sourcepath = ".\$layoutname\5_Mission\UIHelper\UI\" + $sourcename 



$Definitions = (Get-Content ".\Definitions.txt")
$Casts = (Get-Content ".\Casts.txt")
$Switch = (Get-Content ".\Switch.txt")


$SourceContents = (Get-Content $sourcepath)


# Find Insertion Point
$TargetText = "*INSERTDEFINITIONS*"

for ($i=0; $i -lt $SourceContents.Count; $i++)
{
	if($SourceContents[$i] -like '*INSERTDEFINITIONS*') {
		$SourceContents[$i] = $Definitions

	}
	
	if($SourceContents[$i] -like '*INSERTCASTS*') {
		$SourceContents[$i] = $Casts

	}
	
	if($SourceContents[$i] -like '*INSERTSWITCH*') {
		$SourceContents[$i] = $Switch

	}
}

$SourceContents | Set-Content -Path $sourcepath
