class XIIIMenuYesNoWindow extends XIIIWindow;

var  XIIIButton    YesButton, NoButton;
var  localized string    YesText, NoText, QuitText, RestartText, AreUText;
var bool bQuitGame, bAreUSure;
var int BoxWidth, BoxHeight, FirstBoxPosX, SecondBoxPosX, BoxPosY;
var int BackgroundPosX, BackgroundPosY, BackgroundWidth, BackgroundHeight;
var int TextPosX, TextPosY;

function Created()
{
     Super.Created();

	// init values
	BoxWidth = 70;
	BoxHeight = 30;
	FirstBoxPosX = 250;
	SecondBoxPosX = 340;
	BoxPosY = 260;
	BackgroundPosX = 220;
	BackgroundPosY = 130;
	BackgroundWidth = 220;
	BackgroundHeight = 230;
	TextPosX = 220;
	TextPosY = 200;

	// values update if we are in split screen mode
	if (( !GetPlayerOwner().Level.bLonePlayer ) && ( GetPlayerOwner().Level.Game.NumPlayers > 1 ))
	{
		BoxHeight *= 2;
		BackgroundPosY -= 70;
		BackgroundHeight = 345;
		TextPosY -= 40;
		if ( GetPlayerOwner().Level.Game.NumPlayers > 2 )
		{
			FirstBoxPosX -= 90;
			BoxWidth *= 2;
			BackgroundWidth *= 2;
			BackgroundPosX -= 120;

		}
	}

	YesButton = XIIIButton(CreateControl(class'XIIIButton', FirstBoxPosX, BoxPosY*fScaleTo, BoxWidth, BoxHeight));
	YesButton.NbMultiSplit = GetPlayerOwner().Level.Game.NumPlayers;
	YesButton.Text = YesText;
	YesButton.bUseBorder = true;

	NoButton = XIIIButton(CreateControl(class'XIIIButton', SecondBoxPosX, BoxPosY*fScaleTo, BoxWidth, BoxHeight));
	NoButton.NbMultiSplit = GetPlayerOwner().Level.Game.NumPlayers;
	NoButton.Text = NoText;
	NoButton.bUseBorder = true;

    Controls[0] = YesButton;
	Controls[1] = NoButton;
}


function ShowWindow()
{
    super.ShowWindow();
    NoButton.SetFocus(none);
    bShowCCL = true;
    bShowACC = true;
}

function Paint(Canvas C, float X, float Y)
{
    local int i;
    local float W, H;

    if (YesButton.bHasFocus)
	{
        YesButton.TextColor = BlackColor;
		YesButton.bUseBorder = true;
        NoButton.TextColor = Grey3Color;
		NoButton.bUseBorder = false;
    }
    else
	{
        YesButton.TextColor = Grey3Color;
		YesButton.bUseBorder = false;
        NoButton.TextColor = BlackColor;
		NoButton.bUseBorder = true;
    }

    Super.Paint(C,X,Y);

    C.bUseBorder = true;
	C.DrawColor = WhiteColor;

    DrawStretchedTexture(C, BackgroundPosX*fRatioX, BackgroundPosY*fRatioY*fScaleTo, BackgroundWidth*fRatioX, BackgroundHeight*fRatioY*fScaleTo, myRoot.FondMenu);
    C.bUseBorder = false;
    C.DrawColor = BlackColor;
    if (bQuitGame)
		C.TextSize(/*Caps*/(QuitText), W, H);
    else
		if (!bAreUSure)
			C.TextSize(/*Caps*/(RestartText), W, H);
		else
			C.TextSize(/*Caps*/(AreUText), W, H);

	C.SetPos(TextPosX*fRatioX + (220*fScaleTo*fRatioX-W)/2, TextPosY*fScaleTo*fRatioY + (60*fScaleTo*fRatioY - H)/2);

	if (bQuitGame)
		C.DrawText(/*Caps*/(QuitText), false);
    else
		if (!bAreUSure)
			C.DrawText(/*Caps*/(RestartText), false);
		else
			C.DrawText(/*Caps*/(AreUText), false);
    C.DrawColor = WhiteColor;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int index;
    local bool bLeftOrRight, bUpOrDown;

    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
//            Controller.FocusedControl.OnClick(FocusedControl);
            if (FocusedControl == Controls[0])
            {
                myRoot.CloseMenu(true);
                if (bQuitGame)
                    XIIIWindow(ParentPage).bDoQuitGame = true;
                else XIIIWindow(ParentPage).bDoRestartGame = true;
            }
            if (FocusedControl == Controls[1])
            {
                myRoot.CloseMenu(true);
                XIIIWindow(ParentPage).bDoQuitGame = false;
                XIIIWindow(ParentPage).bDoRestartGame = false;
            }
            return true;
	    }
	    if (Key==0x08 || Key ==0x1B/*IK_Backspace*/)
	    {
	        myRoot.CloseMenu(true);
    	    return true;
	    }
	    if (Key==0x25/*IK_Left*/)
	    {
	        PrevControl(FocusedControl);
    	    return true;
	    }
	    if (Key==0x27/*IK_Right*/)
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
     YesText="Yes"
     NoText="No"
     QuitText="Quit Game ?"
     RestartText="Restart Level ?"
     AreUText="Are you sure ?"
     bForceHelp=True
     Background=None
     bCheckResolution=True
     bRequire640x480=False
     bAllowedAsLast=True
     bHidePreviousPage=False
}
