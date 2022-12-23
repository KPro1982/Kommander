Kommander

 A gui companion to workbench for mod creation, building, and launching


Installation
1. Download file
2. Unzip anywhere you want
3. Create a shortcut to desktop

Note: That you can use either the .exe to run or the ps1. 

New Feature Update
- added auto-archive 12/12/22
- added floating toolbar 12/11/22

Setup

Kommander is intended to run from a central folder so that there is a single copy of it that is used for all mods. It creates a globalsettings.json in that folder.  It will create a Kommander folder within each mod that contains the mod specific settings, build logs, and additional data.

The first time that you run Kommander it will pop up in the global settings form.  Kommander will attempt to locate the game folder, workbench folder, etc.  However, if it can't find it or if its wrong you need to choose the correct folder. The standard setup is for the game folder to be the server folder also as typically we use dayzdiag_64.exe for both server and game.  You must choose where to put your source code and packed mods.  You can put them where ever you want. Kommander will make the appropriate links if you run it as administrator.  If not, you must run the included linkall.bat file after you complete the first three steps in the process.

I've recently updated the log buttons.  The build log button now turns green if the build was success or red if it was a failure. Note that you cannot rebuild successfully while Workbench is open because workbench maintains a lock on the pbo. This does not prevent you from compiling with F7 from within Workbench. You must build once to use workbench. After that you only need to rebuild to publish the mod.

All logs are searchable with Grep for specific information i.e. your modname, 'warning', 'error', etc.

Kommander ModTemplate

By default Kommander's create mod from template uses a modtemplate that resides in the Kommander folder. You may change this to your mod template in the Template Settings form.  However, the customization features will only work with Kommander's own template as it relies on tokens included in that template. I intended these customization options to make it easier for new modders to experiement with some commonly used patterns.

Alternative ModTemplates

As an alternative to the Kommander template, you can create your own templates for specific tasks e.g. a template with  server-config logic, a template with UI logic.  You can then just select the template that you want before you create mod.

Please give me feedback, bug reports, and feature requests.

