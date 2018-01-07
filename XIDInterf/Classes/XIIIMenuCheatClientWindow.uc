//============================================================================
// Special menu for cheaters
//============================================================================
class XIIIMenuCheatClientWindow extends XIIIWindow;

var XIIIbutton DndButton, GodButton, FlyButton, EquipButton, NeuButton, Ghostbutton;
var localized string DndText, GodText, FlyText, EquipText, NeuText, GhostText;


function Created()
{
     Super.Created();

     GodButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 160, 200, 30));
     GodButton.Text=GodText;
     GodButton.bNoBg =true;
     FlyButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 190, 200, 30));
     FlyButton.Text = FlyText;
     FlyButton.bNoBg =true;
     EquipButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 220, 200, 30));
     EquipButton.Text=EquipText;
     EquipButton.bNoBg =true;
     DndButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 250, 200, 30));
     DndButton.Text=NeuText;
     DndButton.bNoBg =true;
     GhostButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 280, 200, 30));
     GhostButton.Text=GhostText;
     GhostButton.bNoBg =true;

    Controls[0] = GodButton; Controls[1] = FlyButton;
    Controls[2] = EquipButton; Controls[3] = DndButton; Controls[4] = GhostButton;
}


function ShowWindow()
{
     OnMenu = 0;
     Super.ShowWindow();
     bShowBCK = true; bShowSEL = true;
}


function Paint(Canvas C, float X, float Y)
{
     Super.Paint(C, X, Y);
    C.bUseBorder = true; C.DrawColor = WhiteColor;
    DrawStretchedTexture(C, 220*fRatioX, 130*fRatioY*fScaleTo, 220*fRatioX, 230*fRatioY*fScaleTo, myRoot.FondMenu);
    C.bUseBorder = false;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
            //Controller.FocusedControl.OnClick(Self);
            switch(FindComponentIndex(FocusedControl))
            {
               case 0: GetPlayerOwner().ConsoleCommand("God");
               break;
               case 1: GetPlayerOwner().ConsoleCommand("TeleportNext");
               break;
               case 2: GetPlayerOwner().ConsoleCommand("EquipMe");
               break;
               case 3: GetPlayerOwner().ConsoleCommand("DAndD");
               break;
               case 4: GetPlayerOwner().ConsoleCommand("Ghost");
               break;
            }
            //myRoot.CloseMenu(true);
            return true;
	    }
	    if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
	    {
	        myRoot.CloseMenu(true);
    	    return true;
	    }
	    if (Key==0x26/*IK_Up*/)
	    {
	        PrevControl(FocusedControl);
    	    return true;
	    }
	    if (Key==0x28/*IK_Down*/)
	    {
	        NextControl(FocusedControl);
    	    return true;
	    }
        //return false;
    }
    return super.InternalOnKeyEvent(Key, state, delta);
//    return false;
}





defaultproperties
{
     DndText="Deaf & Dumb"
     GodText="God"
     FlyText="Teleport"
     EquipText="EquipMe"
     NeuText="Neu neu"
     GhostText="Ghost"
     Background=None
}
