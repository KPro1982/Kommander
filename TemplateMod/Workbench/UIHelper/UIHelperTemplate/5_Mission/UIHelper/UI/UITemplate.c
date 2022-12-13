class UITemplate extends UIScriptedMenu
{
	
    private bool                 m_Initialized;
    private bool                 m_IsMenuOpen;
	private Widget				 layoutroot;

	// [INSERTDEFINITIONS]

    void UITemplate()
    {
		/*
			This is the constructor, called when this class is instantiated
		*/
    }


    void ~UITemplate() 
    {		
		/*
			This is the destructor, called when this class is deleted / destroyed
		*/
		
        PPEffects.SetBlurMenu( UI_NOBLUR );
        GetGame().GetUIManager().Back();
        g_Game.GetUIManager().ShowCursor(true);
        g_Game.GetUIManager().ShowUICursor(false);
        GetGame().GetInput().ResetGameFocus();
        GetGame().GetMission().PlayerControlEnable(false);
        GetGame().GetMission().GetHud().Show( true );

        //Destroy root widget and all its children
        if ( layoutroot )
        	layoutroot.Unlink();	
    }

    //after show
    override void OnShow()
    {
        super.OnShow();
		UIMenuUtils.LockControls();
        PPEffects.SetBlurMenu( UI_BLUR ); //Add blurr effect
				
	/*
		This is where you initialize default / display values in menu widgets
	*/
		
		
    }

    //after hide
    override void OnHide()
    {
        super.OnHide();
        PPEffects.SetBlurMenu( UI_NOBLUR ); //Remove blurr effect

		UIMenuUtils.UnlockControls();

        /*
			Unlock controls, this also happens in missionGameplay.c however including it here will assure control is gained back incase that method is not invoked. 
			That can occur when other mods / scripts force a menu on screen illegally 
		*/

    }

    override Widget Init()
    {
		/* 
			Only draw and init widgets if not already done that, since this function is called each time you do ( ShowScriptedMenu() )
		*/
        if (!m_Initialized) 
			
        {
			layoutroot = GetGame().GetWorkspace().CreateWidgets( "FULLLAYOUTPATH");

			//Define elements from .layout ( you must cast each element to its according script class if you wish to use its functions see scripts\1_Core\proto\EnWidgets.c )


			// [INSERTCASTS]
						

			// Optional WIDGETHANDLER to attach a double-click event on a specifc widget
			/*
				WidgetEventHandler.GetInstance().RegisterOnDoubleClick( m_YourWidgetNameHere, this, "OnDoubleClicked" ); 
			*/

            m_Initialized = true;
        }
        return layoutroot;
    }

   

    //Called on each frame, this will be paused when the menu is hidden or missiongameplay callqueue is frozen / paused
    override void Update(float timeslice)
    {
        super.Update(timeslice);

    }

    /*
		Click event triggers when you click on a widget, this method wont get called if your widget has the "IgnorePointer" property toggled in your .layout
	*/
	override bool OnClick(Widget w, int x, int y, int button)
    {
		
	/*
		Close the menu with 
		GetGame().GetUIManager().HideScriptedMenu(this);
	*/
	
    // [INSERTSWITCH]



        return super.OnClick(w, x, y, button);
    }

    /*
		Called by WIDGETHANDLER that is registered above in Init() ( more of these examples can be found in vanilla scripts / menus creates by devs )
	*/
    void OnDoubleClicked(Widget w, int x, int y, int button) 
    {
        if (button == MouseState.LEFT)
        {
            //Do something
        }
        else if (button == MouseState.RIGHT)
        {
            //Do something
        }
    }

    bool IsMenuOpen() 
    {
        return m_IsMenuOpen;
    }

    void SetMenuOpen(bool isMenuOpen) 
    {
        m_IsMenuOpen = isMenuOpen;
        if (m_IsMenuOpen)
            PPEffects.SetBlurMenu( UI_BLUR);
        else
            PPEffects.SetBlurMenu( UI_NOBLUR );
    }
		
	
};
