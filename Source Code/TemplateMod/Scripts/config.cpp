class CfgPatches
{
	class TMSHORT_TEMPLATEMOD
	{
        units[] = {};
        weapons[] = {};
        requiredVersion = 0.1;
		requiredAddons[] = {"DZ_Data"}; // add required mods here if any "mod1", "mod2"
	};
};

class CfgMods 
{
	class TMSHORT_TEMPLATEMOD
	{
		name = "Kpro1982";
		dir = "TEMPLATEMOD";
		credits = "Kpro1982";
		author = "Kpro1982";
		overview = "A new mod";
		creditsJson = "TEMPLATEMOD/Scripts/Data/Credits.json";
		versionPath = "TEMPLATEMOD/Scripts/Data/Version.hpp";
		type = "mod";
		
		// TM_NOINPUTSTART
		inputs="TEMPLATEMOD/Scripts/data/inputs.xml";
		// TM_NOINPUTEND
		
		dependencies[] =
		{
			"Game", "World", "Mission"
		};

		
		class defs
		{
			
			class engineScriptModule
			{
				value = "";
				files[] =
				{
					"scripts/1_core",
					"TEMPLATEMOD/Scripts/common",
					"TEMPLATEMOD/Scripts/1_core"
				};
			};

			class gameScriptModule
			{
				value="";
				files[] = 
				{
					"scripts/3_Game",
					"TEMPLATEMOD/Scripts/common",
					"TEMPLATEMOD/Scripts/3_Game"
				};
			};
			class worldScriptModule
			{
				value="";
				files[] = 
				{
					"scripts/4_World",
					"TEMPLATEMOD/Scripts/common",
					"TEMPLATEMOD/Scripts/4_World"
				};
			};

			class missionScriptModule 
			{
				value="";
				files[] = 
				{
					"scripts/5_Mission",
					"TEMPLATEMOD/Scripts/common",
					"TEMPLATEMOD/Scripts/5_Mission"
				};
			};
		};
	};
};
