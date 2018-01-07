//============================================================================
// Items light ingame menu.
//
//============================================================================
class XIIIMenuItemsIngame extends XIIIWindow;

var localized string TitleText;

function Created()
{
    local int i;

    Super.Created();

    bShowBCK = true;
    bShowSEL = true;

}

function Paint(Canvas C, float X, float Y)
{
    local float W, H;
    local int i;

    Super.Paint(C,X,Y);

    // main design
    if (!myRoot.GetLevel().bCineFrame)
	{
		C.DrawMsgboxBackground(false, 120*fRatioX, 50*fRatioY*fScaleTo, 10, 10, 420*fRatioX, 350*fRatioY*fScaleTo);
	}
    else
    {
		C.DrawMsgboxBackground(false, 0.09*C.ClipX*fRatioX, 0.2*C.ClipY*fRatioY*fScaleTo, 10, 10, 0.82*C.ClipX*fRatioX, 0.6*C.ClipY*fRatioY*fScaleTo);
    }

    // page title
    C.bUseBorder = true;
    C.DrawColor = WhiteColor;
    C.TextSize(Caps(TitleText), W, H);
    DrawStretchedTexture(C, 80, 110*fRatioY, (W+40)*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos(90*fRatioX, (125*fScaleTo*fRatioY)-H/2);
    C.DrawText(Caps(TitleText), false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01)/*IK_LeftMouse*/)
	    {
	        myRoot.CloseMenu(true);
            return true;
	    }
	    else if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B) /*IK_Escape*/)
	    {
	        myRoot.CloseMenu(true);
    	    return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



defaultproperties
{
     TitleText="temp page - Items ingame"
     bForceHelp=True
     Background=None
}
