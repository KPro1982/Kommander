modded class MissionBase {
    override UIScriptedMenu CreateScriptedMenu(int id) {
        UIScriptedMenu menu = NULL;
        menu = super.CreateScriptedMenu(id);
        if (!menu) {
            switch (id) {
            case UI_TEMPLATEID:
                menu = new UITemplate;
                break;               	
            }			
									
            if (menu) {
                menu.SetID(id);
            }
        }
        return menu;
    }
	

}
