modded class MissionGameplay
{   
// This runs on the client
	
	// TM_REMOVEINPUTSTART
	
	override void OnUpdate(float timeslice)
	{        		
		super.OnUpdate(timeslice);		
		if ( GetGame().GetInput().LocalPress("TMSHORTActionName") && GetGame().GetUIManager().GetMenu() == NULL ) 
		{				
			Print(string.Format("Key pressed!"));
			
			// do stuff here

							
								
		}
			
	}
	// TM_REMOVEINPUTEND
			
}
