modded class MissionGameplay
{   
// This runs on the client	
// TM_REMOVEINPUTSTART	
	override void OnUpdate(float timeslice)
	{        		
		super.OnUpdate(timeslice);		
		if ( GetGame().GetInput().LocalPress("T5ActionName") && GetGame().GetUIManager().GetMenu() == NULL ) 
		{				
			Print(string.Format("Key pressed!"));	// delete after test		
			// do your stuff here															
		}
			
	}
// TM_REMOVEINPUTEND		
}