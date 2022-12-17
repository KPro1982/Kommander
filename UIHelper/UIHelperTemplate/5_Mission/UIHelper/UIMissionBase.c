modded class MissionBase {
    override UIScriptedMenu CreateScriptedMenu(int id) {
        UIScriptedMenu menu = NULL;
        menu = super.CreateScriptedMenu(id);
        if (!menu) {
            switch (id) {
            case UI_ID:
                menu = new UI;
                break;               	
            }			
									
            if (menu) {
                menu.SetID(id);
            }
        }
        return menu;
    }
	

}
