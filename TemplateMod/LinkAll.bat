echo linking P:\scripts to dayz
mklink /J  "WB_DAYZFOLDER\scripts\" "WB_PROJECTDRIVE\scripts\"

echo linking source code
mklink /J "WB_PROJECTDRIVE\WB_MODNAME\" "WB_SOURCEFOLDER" 
mklink /J "WB_DAYZFOLDER\WB_MODNAME\" "WB_SOURCEFOLDER" 

echo linking packed pbos
mklink /J "WB_PROJECTDRIVE\WB_MODNAME\" "WB_DAYZFOLDER\WB_MODNAME\" 


