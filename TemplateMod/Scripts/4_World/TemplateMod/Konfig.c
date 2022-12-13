class TMSHORT_Konfig
{

	protected static string ConfigPATH = "$profile:\\TemplateMod\\Config_settings.json";
	private static const string configRoot = "$profile:\\TemplateMod\\";	
	

/////////////////////////////////////////////////////////////////////////////////////////////////////	
// Variables to save go here
//
	string ConfigVersion = "1";
	string ConfigString = "Hello World!";
	
	
// NonSerialed Variables that should not be saved go here
	[NonSerialized()]
	int ConfigInt = 1;
	
	
//////////////////////////////////////////////////////////////////////////////////////////////////
	
	void TMSHORT_Konfig()
	{
	
		// insert default settings here
	
	
	}
	
	// Setters are required to ensure SHumanCommandMoveSettings
	
	void SetConfigString(string value)
	{
		ConfigString = value;
		Save();
	}

	
	void Load(){
		Print("[TemplateMod] Loading Config");
		if (GetGame().IsServer()){
			
			if (FileExist(configRoot)==0) // Save Directory Does not Exist
	        {
	            Print("[TemplateMod] '" + configRoot + "' does not exist, creating directory");
	            MakeDirectory(configRoot);
	        }
			
			if (FileExist(ConfigPATH)){ //If Config File exist load File
			    JsonFileLoader<TMSHORT_Konfig>.JsonLoadFile(ConfigPATH, this);
				if (ConfigVersion != "1"){
					ConfigVersion = "1";
					Save();
				}
			}else{ //File does not exist create file
				Save();
			}
		}
	}
	
	void Save(){
		if (GetGame().IsServer()){
		
			JsonFileLoader<TMSHORT_Konfig>.JsonSaveFile(ConfigPATH, this);
			
		} 

		
	}


		
}
ref TMSHORT_Konfig m_TMSHORT_Konfig;

//Helper function to return Config
static ref TMSHORT_Konfig TMSHORT_GetKonfig()
{
	if (!m_TMSHORT_Konfig)
	{
		m_TMSHORT_Konfig = new TMSHORT_Konfig;
			
		if ( GetGame().IsServer() ){
			m_TMSHORT_Konfig.Load();
		}
	}

	return m_TMSHORT_Konfig;
};
