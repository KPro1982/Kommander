# Kommander

 A gui companion to workbench for mod creation, building, and launching. 

## Installation
1. Download file
2. Unzip anywhere you want
3. Create a shortcut to desktop

Note: That you can use either the .exe to run or the 'Kommander.Package.ps1'. 

## New Feature Update
*Kommander is currently in active development. I am squashing bugs as I find them and adding new features. The releases page contains links to stable releases. Or download from the main page here for the current experiemental build. Expect things to break from time to time and check back here frequently for updates.*

Current experiemental build -- rev. 2023.2.7
- **2/6/23** added side-by-side log view, added start/stop archive timer
- **2/1/23** added ability to select different mods to launch with workbench than launch with server / client; Added Update Batch Files button which will update batchfiles to reflect additional mods selected.
- **1/31/23** added additional control over what links are created and when they are created. Added log of links which is saved in the Mod's Kommander folder.
- **1/14/23** added timed archive
- **1/10/23** added ability to link without admin privileges via batch 
- **12/31/22** removed search capability and moved it to KodeWizard, a standalone tool 
- **12/30/22** added search capability
- **12/12/22** added auto-archive 
- **12/11/22** added floating toolbar 

## Setup

### SEE WIKI FOR ADDITIONAL SETUP INFORMATION

Kommander is intended to run from a central folder so that there is a single copy of it that is used for all mods. It creates a globalsettings.json in that folder.  It will create a Kommander folder within each mod that contains the mod specific settings, build logs, and additional data.

The first time that you run Kommander it will pop up in the global settings form.  Kommander will attempt to locate the game folder, workbench folder, etc.  However, if it can't find it or if its wrong you need to choose the correct folder. You must choose where to put your source code and packed mods.  You can put them anywhere you want. Kommander will make the appropriate links if you run it as administrator.  If not, you must run the included linkall.bat file after you complete the first three steps in the process.

The standard setup is for the game folder to be the server folder also as typically we use dayzdiag_64.exe for both server and game.  **HOWEVER, IF YOU DO THIS YOU MUST COPY OR CREATE THE SERVERDZ.CFG AND MISSIONS FILES IN THE DAYZ FOLDER.**  You can do this yourself or I have provided a tool that will do it for you on the tools tab.  

## Usuage Notes

Building your Mod: You *must* build once to use workbench. But you do not need to rebuild your mod everytime you make a change in the script. After the first build, you only need to *rebuild* your mod at the end of the process when you are ready to publish it. The build log button now turns green if the build was success or red if it was a failure. However, please note that you cannot rebuild while Workbench is open because workbench maintains a lock on the pbo. This does not prevent you from compiling with F7 from within Workbench.  

I've recently updated the log display.  All logs are now searchable with Grep for specific information i.e. your modname, 'warning', 'error', etc.  I have also added access to the so-called bin-logs produced by dayz tools addonbuilder.

### Kommander ModTemplate

By default Kommander's create mod from template uses a modtemplate that resides in the Kommander folder. You may change this to your mod template in the Template Settings form.  However, the customization features will only work with Kommander's own template as it relies on tokens included in that template. I intended these customization options to make it easier for new modders to experiement with some commonly used patterns.

### Alternative ModTemplates

As an alternative to the Kommander template, you can create your own templates for specific tasks e.g. a template with  server-config logic, a template with UI logic.  You can then just select the template that you want before you create mod.

### BUG REPORT
Fixed -- bug where WB wouldn't show some mods when it loaded is fixed. Sorry for any inconvenience.

Fixed -- the "mount P" button on the tools menu is bugged if you do not use the standard set up for the "Projects Folder". I mistakenly left that folder location hard coded in. I just removed it as I don't think it is very useful anyway. PM me on discord if this was your favorite feature and I'll put it back in but I doubt anyone wants it.

Fixed -- Addonbuilder did not include all relevant files when building using Kommander. Fixed by adding CLI parameters and an includes.txt. Many thanks to JaccuziAdmiral for identifying the issue and solving it!



Please give me feedback, bug reports, and feature requests.

