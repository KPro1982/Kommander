echo linking P:\scripts to dayz
mklink /J  "WB_DAYZFOLDER\scripts\" "WB_PROJECTDRIVE\scripts\"

echo linking dayz\addons to workbench -- this link is needed if you use CF
mklink /J "WB_WORKBENCHFOLDER\addons" "WB_DAYZFOLDER\addons"

echo linking source code
mklink /J "WB_PROJECTDRIVE\WB_MODNAME\" "WB_SOURCEFOLDER\WB_MODNAME\" 
mklink /J "WB_DAYZFOLDER\WB_MODNAME\" "WB_SOURCEFOLDER\WB_MODNAME\" 

echo linking packed pbos
mklink /J "WB_PDRIVEPACKEDMOD" "WB_PACKEDMOD" 


