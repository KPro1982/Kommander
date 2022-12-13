modded class MissionGameplay
{   
	ref UITemplate UITemplateMenu;
	
	
	override void OnUpdate(float timeslice)
	{        		
		super.OnUpdate(timeslice); 	
			
		if ( GetGame().GetInput().LocalPress("UIOPENMENU") && GetGame().GetUIManager().GetMenu() == NULL) 
		{				
			
			// Menu logic
			if ( UITemplateMenu ) {
                if (UITemplateMenu.IsMenuOpen()) {
                    //Hide Menu
                    UITemplateMenu.SetMenuOpen(false);
                    GetGame().GetUIManager().HideScriptedMenu(UITemplateMenu);
                    UIMenuUtils.UnlockControls();
                } else if (GetGame().GetUIManager().GetMenu() == NULL) {
                    //Show Menu
                    GetGame().GetUIManager().ShowScriptedMenu(UITemplateMenu, NULL);
                    UITemplateMenu.SetMenuOpen(true);
                   UIMenuUtils.LockControls();
                }
            } else if (GetGame().GetUIManager().GetMenu() == NULL && UITemplateMenu == null) {
                //Create Menu
                UIMenuUtils.LockControls();
                UITemplateMenu = UITemplate.Cast(GetUIManager().EnterScriptedMenu(UI_TEMPLATEID, null));
				UITemplateMenu.SetMenuOpen(true);
            }													
		}
		
		
		
			
	}
	
	
}
