//============================================================================
// The In Game menu for multiplayer mode
//
//============================================================================
class XIIIMenuInGameMultiKick extends XIIIWindow;

//var  XIIIButton TeamButton, OptionsButton, QuitButton, ReturnButton, RestartButton, KickButton;
//var  localized string TeamText, OptionsText, QuitText, ReturnText, RestartText, KickText;
//var bool bTeamMode;
VAR LOCALIZED STRING BackText;
VAR int NbButtons, BoxPosX, BoxPosY, BoxWidth, BoxHeight, NbPlayers;
VAR int BackgroundPosX, BackgroundPosY, BackgroundWidth, BackgroundHeight;
//var float fX, fY;
VAR XIIIButton PlayerButtons[7], BackButton;
var string KickedPlayer;
var bool bSomebodyWasKicked;


//============================================================================
function Created()
{
	LOCAL int i, j, LineSpace, FirstLineY;
	LOCAL class<GameInfo> GameClass;
	LOCAL bool bCanKick;

	Super.Created();

	// init values
	BoxWidth = 200;
	BoxHeight = 22;
	BoxPosX = 230;
	BackgroundPosX = 220;
	BackgroundPosY = 130;
	BackgroundWidth = 220;
	BackgroundHeight = 230;

	if ( GetPlayerOwner().myHUD.bShowScores )
		GetPlayerOwner().myHUD.HideScores();

	BoxPosY = 250 - 8 /*NbButtons*/ * 14;
	LineSpace = 27;
	FirstLineY = BoxPosY;

	for ( j=0; j<7; j++)
	{
		PlayerButtons[j] = XIIIButton(CreateControl(class'XIIIButton', BoxPosX, FirstLineY*fScaleTo, BoxWidth, BoxHeight*fScaleTo));
		PlayerButtons[j].Text = "";
		PlayerButtons[j].bUseBorder = false;
		PlayerButtons[j].bNeverFocus = true;
//	ReturnButton.NbMultiSplit = NbPlayers;
		Controls[Controls.Length] = PlayerButtons[j];
		FirstLineY  += LineSpace;
//		i++;
	}

	FirstLineY += 4;
	BackButton = XIIIButton(CreateControl(class'XIIIButton', 280, FirstLineY*fScaleTo, 100, BoxHeight*fScaleTo));
	BackButton.Text = BackText;
	BackButton.bUseBorder = true;
//	ReturnButton.NbMultiSplit = NbPlayers;
	Controls[Controls.Length] = BackButton;
//	FirstLineY  += LineSpace;
//	i++;
	NbButtons=	Controls.Length;

//	FocusedControl = BackButton;

	
}


/*
function BeforePaint(Canvas C, float X, float Y)
{

	Super.BeforePaint(C, X, Y);

	if (bDoQuitGame)
		QuitGame();
	if (bDoRestartGame)
		RestartGame();
}
*/

function Paint(Canvas C, float X, float Y)
{
	LOCAL int i, j;
	LOCAL Controller Ctrl;

	Super.Paint(C,X,Y);
	
//	if (( GetPlayerOwner().Level.bLonePlayer ) || ( GetPlayerOwner().Level.Game.NumPlayers == 1 ))
	C.DrawMsgboxBackground(false, BackgroundPosX*fRatioX, BackgroundPosY*fRatioY*fScaleTo, 10, 10, BackgroundWidth*fRatioX, BackgroundHeight*fRatioY*fScaleTo);		
//	else
//		C.DrawMsgboxBackground(false, BackgroundPosX, BackgroundPosY*fScaleTo, 10, 10, BackgroundWidth, BackgroundHeight*fScaleTo);

	// only selected control has a border
    for (i=0; i<NbButtons; i++)
        XIIIButton(Controls[i]).bUseBorder = false;    
    if (FindComponentIndex(FocusedControl)!= -1)
        XIIIButton(Controls[FindComponentIndex(FocusedControl)]).bUseBorder = true;

	i=0;
	if ( GetPlayerOwner()!=none && GetPlayerOwner().Level!=none )
	{
		for ( Ctrl = GetPlayerOwner().Level.ControllerList; Ctrl!=None; Ctrl= Ctrl.NextController )
		{
			if ( Ctrl==GetPlayerOwner() )
				continue;
			if ( Ctrl.IsA( 'PlayerController' ) )
			{
				XIIIButton(Controls[i]).Text = PlayerController(Ctrl).PlayerReplicationInfo.PlayerName;
				Controls[i].bNeverFocus=false;
				i++;
			}
		}
	}
	if (( bSomebodyWasKicked ) && ( i == 0 )) 
	{
		NextControl(FocusedControl);
		bSomebodyWasKicked = false;
	}

	for ( j=i; j<7; j++ )
	{
		Controls[j].bNeverFocus=true;
		XIIIButton(Controls[j]).Text = "";
	}

	// restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255;
	C.Style = 1;
	C.bUseBorder = false;
}

function KickMsgBoxReturn(byte bButton)
{
	bShowBCK = true;
	if ((bButton & QBTN_Yes) != 0)
	{
		GetPlayerOwner().ConsoleCommand("Kick"@KickedPlayer);
		bSomebodyWasKicked = true;
	}
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int index;
    local bool bLeftOrRight, bUpOrDown;
    local controller P;
    local XIIIMsgBoxInGame MsgBox;


    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D) || (Key==0x01)) // IK_Enter && IK_LeftButton
	    {
			if ( FocusedControl==BackButton )
				Key=0x08;
			else
			{
				index= FindComponentIndex(FocusedControl);
				if ( index>=0 && index<=6)
				{	// confirm please
					//GetPlayerOwner().ConsoleCommand("Kick"@XIIIButton(FocusedControl).Text);
					KickedPlayer = XIIIButton(FocusedControl).Text;
					bShowBCK = false;
					myRoot.OpenMenu("XIDInterf.XIIIMsgBoxInGame");
					MsgBox = XIIIMsgBoxInGame(myRoot.ActivePage);
					MsgBox.InitBox(BackgroundPosX*fRatioX, BackgroundPosY*fScaleTo*fRatioY, 10, 10, BackgroundWidth*fRatioX, BackgroundHeight*fScaleTo*fRatioY);
					MsgBox.SetupQuestion(class'XIIIMenuInGameMulti'.default.ConfirmQuitTxt, QBTN_Yes | QBTN_No, QBTN_No,class'XIIIMenuInGameMulti'.default.KickText);
					MsgBox.OnButtonClick = KickMsgBoxReturn;			
				}

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




defaultproperties
{
     BackText="Back"
     bForceHelp=True
     Background=None
     bCheckResolution=True
     bRequire640x480=False
     bAllowedAsLast=True
}
