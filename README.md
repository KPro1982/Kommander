Kommander

 A gui companion to workbench for mod creation, building, and launching

Installation
1. Download file
2. Unzip anywhere you want
3. Create a shortcut to desktop

Note: That you can use either the .exe to run or the ps1. 

Setup
Kommander is meant to be run from a central folder so that there is a single copy of it that is used for all mods. It creates a globalsettings.json in that folder.  It will create a Kommander folder within each mod that contains the mod specific settings.

You create new mods using the creation tool. To use Kommander with existing mods use the convert tool which creates a Kommander subfolder within your mod folder that contains the Kommander specific code.  Note that Kommander uses dayz.gproj folder in the Kommander folder.

The first time that you run Kommander it will pop up in the global settings form.  Kommander will attempt to locate the game folder, workbench folder, etc.  However, if it can't find it or if its wrong you need to choose the correct folder. The standard setup is for the game folder to be the server folder also as typically we use dayzdiag_64.exe for both server and game.  You must choose where to put your source code and packed mods.  You can put them where ever you want. Kommander will make the appropriate links if you run it as administrator.  If not, you must run the included linkall.bat file after you complete the first three steps in the process.

