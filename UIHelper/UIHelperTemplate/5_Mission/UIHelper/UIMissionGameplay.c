modded class MissionGameplay
{   
	ref UI UIMenu;
	
	
	override void OnUpdate(float timeslice)
	{        		
		super.OnUpdate(timeslice); 	
			
		if ( GetGame().GetInput().LocalPress("UIOPENMENU") && GetGame().GetUIManager().GetMenu() == NULL) 
		{				
			
			// Menu logic
			if ( UIMenu ) {
                if (UIMenu.IsMenuOpen()) {
                    //Hide Menu
                    UIMenu.SetMenuOpen(false);
                    GetGame().GetUIManager().HideScriptedMenu(UIMenu);
                    Utils.UnlockControls();
                } else if (GetGame().GetUIManager().GetMenu() == NULL) {
                    //Show Menu
                    GetGame().GetUIManager().ShowScriptedMenu(UIMenu, NULL);
                    UIMenu.SetMenuOpen(true);
                   Utils.LockControls();
                }
            } else if (GetGame().GetUIManager().GetMenu() == NULL && UIMenu == null) {
                //Create Menu
                Utils.LockControls();
                UIMenu = UI.Cast(GetUIManager().EnterScriptedMenu(UI_ID, null));
				UIMenu.SetMenuOpen(true);
            }													
		}
		
		
		
			
	}
	
	
}
