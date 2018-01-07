//============================================================================
// The In Game menu for multiplayer mode
//
//============================================================================
class XIIIMenuInGameSabotage extends XIIIWindow;

//var  XIIIButton TeamButton, OptionsButton, QuitButton, ReturnButton, RestartButton, KickButton;
//var  localized string TeamText, OptionsText, QuitText, ReturnText, RestartText, KickText;
//var bool bTeamMode;
//VAR LOCALIZED STRING BackText;
VAR int NbButtons, BoxPosX, BoxPosY, BoxWidth, BoxHeight, NbPlayers;
VAR int BackgroundPosX, BackgroundPosY, BackgroundWidth, BackgroundHeight;
//var float fX, fY;
VAR XIIIButton ClassButtons[4], BackButton;


//============================================================================
function Created()
{
	LOCAL int i, j, LineSpace, FirstLineY;
	LOCAL class<GameInfo> GameClass;
	LOCAL bool bCanKick;

	Super.Created();

	// init values
	BoxWidth = 300;
	BoxHeight = 36;
	BoxPosX = 180;
	BackgroundPosX = 170;
	BackgroundPosY = 130;
	BackgroundWidth = 320;
	BackgroundHeight = 230;

	if ( GetPlayerOwner().myHUD.bShowScores )
		GetPlayerOwner().myHUD.HideScores();

	BoxPosY = 250 - 8 /*NbButtons*/ * 14;
	LineSpace = 42;
	FirstLineY = BoxPosY+4;

	for ( j=0; j<4; j++)
	{
		ClassButtons[j] = XIIIButton(CreateControl(class'XIIIButton', BoxPosX, FirstLineY*fScaleTo, BoxWidth, BoxHeight*fScaleTo));
		ClassButtons[j].Text = class'MPClassList'.default.ClassListInfo[j].ReadableName;
		ClassButtons[j].bUseBorder = false;
		ClassButtons[j].bNeverFocus = false;
//	ReturnButton.NbMultiSplit = NbPlayers;
		Controls[Controls.Length] = ClassButtons[j];
		FirstLineY  += LineSpace;
//		i++;
	}

	FirstLineY += 8;
	BackButton = XIIIButton(CreateControl(class'XIIIButton', 250, FirstLineY*fScaleTo, 160, BoxHeight*fScaleTo));
	BackButton.Text = BackText;
	BackButton.bUseBorder = true;
	Controls[Controls.Length] = BackButton;
	NbButtons=	Controls.Length;
}

function Paint(Canvas C, float X, float Y)
{
	LOCAL int i, j;
	LOCAL Controller Ctrl;

	Super.Paint(C,X,Y);
	
	C.DrawMsgboxBackground(false, BackgroundPosX*fRatioX, BackgroundPosY*fRatioY*fScaleTo, 10, 10, BackgroundWidth*fRatioX, BackgroundHeight*fRatioY*fScaleTo);		

	// only selected control has a border
    for (i=0; i<NbButtons; i++)
        XIIIButton(Controls[i]).bUseBorder = false;    
    if (FindComponentIndex(FocusedControl)!= -1)
        XIIIButton(Controls[FindComponentIndex(FocusedControl)]).bUseBorder = true;

	// restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255;
	C.Style = 1;
	C.bUseBorder = false;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int index;
    local bool bLeftOrRight, bUpOrDown;
    local controller P;

    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D) || (Key==0x01)) // IK_Enter && IK_LeftButton
	    {
			if ( FocusedControl==BackButton )
				Key=0x08;
			else
			{
				index= FindComponentIndex(FocusedControl);
				
				XIIIMPPlayerController(GetPlayerOwner()).ChangeClass( index );
				myRoot.CloseAll(true);
				myRoot.GotoState('');
				return true; //InternalOnClick(FocusedControl);
			}
	    }
	    if (Key==0x08 || Key==0x1B) // IK_Backspace - IK_Escape
	    {
	        myRoot.CloseMenu(true);
    	    return true;
	    }
	    if (Key==0x26) // IK_Up
	    {
	        PrevControl(FocusedControl);
    	    return true;
	    }
	    if (Key==0x28) // IK_Down
	    {
	        NextControl(FocusedControl);
    	    return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}


function ShowWindow()
{

     Super.ShowWindow();

     bShowBCK = true;
     bShowSEL = true;
}

//     BackText="Back"



defaultproperties
{
     bForceHelp=True
     Background=None
     bCheckResolution=True
     bRequire640x480=False
     bAllowedAsLast=True
}
