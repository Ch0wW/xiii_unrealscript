//============================================================================
// The In Game menu for multiplayer mode
//
//============================================================================
class XIIIMenuInGameMulti extends XIIIWindow;

var  XIIIButton TeamButton, OptionsButton, QuitButton, ReturnButton, RestartButton, KickButton, BombButton;
var  localized string TeamText, OptionsText, QuitText, ReturnText, RestartText, KickText, ConfirmQuitTxt, BombText, QuitTextAsHost;
var bool bTeamMode, bBombMode;
var int NbButtons, BoxPosX, BoxPosY, BoxWidth, BoxHeight, NbPlayers;
var int BackgroundPosX, BackgroundPosY, BackgroundWidth, BackgroundHeight;
//var float fX, fY;


//============================================================================
function Created()
{
	LOCAL int i, LineSpace, FirstLineY;
//	LOCAL class<GameInfo> GameClass;
	LOCAL bool bCanKick, bShowQuitButton;

	Super.Created();

	// init values
	BoxWidth = 200;
	BoxHeight = 30;
	BoxPosX = 230;
	BackgroundPosX = 220;
	BackgroundPosY = 130;
	BackgroundWidth = 220;
	BackgroundHeight = 160;

	if ( GetPlayerOwner().myHUD.bShowScores )
		GetPlayerOwner().myHUD.HideScores();

	// team mode
	//GameClass = class<GameInfo>(dynamicloadobject(GetPlayerOwner().GameReplicationInfo.GameClass, class'class'));
	//!GameClass.default.bTeamGame

	NbButtons = 3;

	if ( !GetPlayerOwner().myHUD.IsA('XIIITeamHUD') || ( GetPlayerOwner().Level.NetMode == 0 ) )
	{
		bTeamMode = false;
	}
	else
	{
		bTeamMode = true;
		NbButtons++;

	}
	if ( GetPlayerOwner().myHUD.IsA('XIIIBombHUD')  )
	{
		bBombMode = true;
		NbButtons++;
	}
	else
	{
		bBombMode = false;
	}
	BoxPosY = 250 - 18*NbButtons;

	bCanKick = ( GetPlayerOwner().Level.Game!=none ) && ( GetPlayerOwner().Level.NetMode != 0 );
	if ( bCanKick )
		NbButtons++;

	if ( GetPlayerOwner().Level.NetMode != 0 ) // QUIT BUTTON ALWAYS AVAILABLE IN NET MODE
		bShowQuitButton = true;
	else // QUIT BUTTON ONLY AVAILABLE FOR FIRST VIEWPORT IN SPLIT MODE
	{
		XIIIBaseHud(GetPlayerOwner().myHUD).InitViewPortId( none, false );
		bShowQuitButton =  ( XIIIBaseHud(GetPlayerowner().myHUD).ViewPortId == 0 );
		if ( !bShowQuitButton )
			NbButtons--;
	}

	BoxPosY = 250 - NbButtons * 18;
	LineSpace = 35;

	// values update if we are in split screen mode
	if ( ( GetPlayerOwner().Level.Game!=none ) && ( GetPlayerOwner().Level.Game.NumPlayers > 1 ) && (myRoot.GetLevel().NetMode == 0) )
	{
		BackgroundPosY -= 100;
		BackgroundHeight = 170;
		BoxPosY -=70;
		BoxHeight *= 1.8;
		LineSpace *= 1.8;
		NbPlayers = GetPlayerOwner().Level.Game.NumPlayers;
		if ( NbPlayers > 2 )
		{
			BoxWidth *= 2;
			BoxPosX -= 110;
			BackgroundPosX -= 170;
		}
	}

	FirstLineY = BoxPosY;

	ReturnButton = XIIIButton(CreateControl(class'XIIIButton', BoxPosX, FirstLineY*fScaleTo, BoxWidth, BoxHeight*fScaleTo));
	ReturnButton.Text = ReturnText;
	ReturnButton.bUseBorder = true;
	ReturnButton.NbMultiSplit = NbPlayers;
	Controls[i] = ReturnButton;
	FirstLineY  += LineSpace;
	i++;

    if ( bTeamMode )
	{
		TeamButton = XIIIButton(CreateControl(class'XIIIButton', BoxPosX, FirstLineY*fScaleTo, BoxWidth, BoxHeight*fScaleTo));
		TeamButton.Text = TeamText;
		TeamButton.bUseBorder = true;
		TeamButton.NbMultiSplit = NbPlayers;
		Controls[i] = TeamButton;
		FirstLineY  += LineSpace;
		i++;
	}
	if ( bBombMode )
	{
		BombButton = XIIIButton(CreateControl(class'XIIIButton', BoxPosX, FirstLineY*fScaleTo, BoxWidth, BoxHeight*fScaleTo));
		BombButton.Text = BombText;
		BombButton.bUseBorder = true;
		BombButton.NbMultiSplit = NbPlayers;
		Controls[i] = BombButton;
		FirstLineY  += LineSpace;
		i++;
	}

    if ( bCanKick )
	{
		KickButton = XIIIButton(CreateControl(class'XIIIButton', BoxPosX, FirstLineY*fScaleTo, BoxWidth, BoxHeight*fScaleTo));
		KickButton.Text = KickText;
		KickButton.bUseBorder = true;
		Controls[i] = KickButton;
		FirstLineY  += LineSpace;
		i++;
	}

	OptionsButton = XIIIButton(CreateControl(class'XIIIButton', BoxPosX, FirstLineY*fScaleTo, BoxWidth, BoxHeight*fScaleTo));
	OptionsButton.Text = OptionsText;
	OptionsButton.bUseBorder = true;
	OptionsButton.NbMultiSplit = NbPlayers;
	Controls[i] = OptionsButton;
	FirstLineY  += LineSpace;
	i++;

	if ( bShowQuitButton )
	{
		QuitButton = XIIIButton(CreateControl(class'XIIIButton', BoxPosX, FirstLineY*fScaleTo, BoxWidth, BoxHeight*fScaleto));
		QuitButton.Text = QuitText;
		QuitButton.bUseBorder = true;
		QuitButton.NbMultiSplit = NbPlayers;
		Controls[i] = QuitButton;
		FirstLineY  += LineSpace;
	}

	//GetPlayerOwner().ResetInputs();

	// we define default user config in XIIIRootWindow
	if (( myRoot.CurrentPF == 3 ) && ( myRoot.DefaultUserConfig == -1 ))
	{
		log("SPLIT : define default config in XIIIRootWindow"@ GetPlayerOwner().UserPadConfig);
		myRoot.DefaultUserConfig = GetPlayerOwner().UserPadConfig;
	}

	GotoState('STA_ResetInputs');
}



function BeforePaint(Canvas C, float X, float Y)
{

	Super.BeforePaint(C, X, Y);

	if (bDoQuitGame)
		QuitGame();
	if (bDoRestartGame)
		RestartGame();
}


function Paint(Canvas C, float X, float Y)
{

	local int i;

	Super.Paint(C,X,Y);

	if ( GetPlayerOwner().Level.Game==none || GetPlayerOwner().Level.NetMode != 0 || GetPlayerOwner().Level.Game.NumPlayers == 1 )
		C.DrawMsgboxBackground(false, BackgroundPosX*fRatioX, BackgroundPosY*fScaleTo*fRatioY, 10, 10, BackgroundWidth*fRatioX, BackgroundHeight*fScaleTo*fRatioY);
	else
	{
		C.DrawColor = WhiteColor;
		C.bUseBorder = true;
		C.bUseBorder = false;
	}

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


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
	local XIIIMsgBoxInGame MsgBox;
	LOCAL bool bHost;

	if (Sender == RestartButton)
		myRoot.OpenMenu("XIDInterf.XIIIMenuYesNoWindow");

	if (( bTeamMode ) && (Sender == TeamButton))
	{
		GetPlayerOwner().ResetInputs();
		myRoot.CloseAll(true);
		myRoot.GotoState('');
		GetPlayerOwner().ConsoleCommand("SwitchTeam");
	}

	if (Sender == OptionsButton)
	{
		if (myRoot.CurrentPF > 0)
			myRoot.OpenMenu("XIDInterf.XIIIMultiControlsWindow");
		else
		    myRoot.OpenMenu("XIDInterf.XIIIMenuInputPC");
	}

	if (Sender == ReturnButton)
	{
		GetPlayerOwner().ResetInputs();
		myRoot.CloseAll(true);
		myRoot.GotoState('');
	}

	if (Sender == QuitButton)
	{
		if ( GetPlayerOwner().Level.Game==none || GetPlayerOwner().Level.NetMode != 0 || GetPlayerOwner().Level.Game.NumPlayers == 1 )
		{
			bShowBCK = false;
			myRoot.OpenMenu("XIDInterf.XIIIMsgBoxInGame");
			MsgBox = XIIIMsgBoxInGame(myRoot.ActivePage);
			MsgBox.InitBox(BackgroundPosX*fRatioX, BackgroundPosY*fScaleTo*fRatioY, 10, 10, BackgroundWidth*fRatioX, BackgroundHeight*fScaleTo*fRatioY);
			bHost = ( GetPlayerOwner().Level.Game!=none ) && ( GetPlayerOwner().Level.NetMode != 0 );
			if (bHost)
			   MsgBox.SetupQuestion(QuitTextAsHost, QBTN_Yes | QBTN_No, QBTN_No,"");
			else
			   MsgBox.SetupQuestion(ConfirmQuitTxt, QBTN_Yes | QBTN_No, QBTN_No,"");
			MsgBox.OnButtonClick = QuitMsgBoxReturn;
		}
		else
		{
			myRoot.OpenMenu("XIDInterf.XIIIMenuYesNoWindow");
			XIIIMenuYesNoWindow(myRoot.ActivePage).bQuitGame = true;
		}
	}

	if (Sender == KickButton)
	{
		myRoot.OpenMenu("XIDInterf.XIIIMenuInGameMultiKick");
//		XIIIMenuYesNoWindow(myRoot.ActivePage).bQuitGame = true;
	}
	if (Sender == BombButton)
	{
		myRoot.OpenMenu("XIDInterf.XIIIMenuInGameSabotage");
	}


	return true;
}


function QuitMsgBoxReturn(byte bButton)
{
	bShowBCK = true;
	if ((bButton & QBTN_Yes) != 0)
	{
		QuitGame();
	}
}


function QuitGame()
{
	if ( myRoot.CurrentPF == 3 )
	{		switch ( myRoot.DefaultUserConfig )
		{
			case 0:
				// specific inputs for classic
				GetPlayerOwner().ConsoleCommand("set XIIIPlayerController ConfigType CT_StrafeLookNotSameAxis");
				GetPlayerOwner().ConsoleCommand("SET Input JoyX Axis aStrafe SpeedBase=1.0 DeadZone=0.0");
				GetPlayerOwner().ConsoleCommand("SET Input JoyU Axis aTurn SpeedBase=1.0 DeadZone=0.0");
				break;
			case 1:
				// specific inputs for goofy
				GetPlayerOwner().ConsoleCommand("set XIIIPlayerController ConfigType CT_StrafeLookSameAxis");
				GetPlayerOwner().ConsoleCommand("SET Input JoyX Axis aTurn SpeedBase=1.0 DeadZone=0.0");
				GetPlayerOwner().ConsoleCommand("SET Input JoyU Axis aStrafe SpeedBase=1.0 DeadZone=0.0");
				break;
		}
	}

	GetPlayerOwner().myHUD.bShowScores = false;
	GetPlayerOwner().myHUD.bHideHud = true;
	myRoot.CloseAll(true);
	myRoot.GotoState('');

	myRoot.Master.GlobalInteractions[0].ViewportOwner.Actor.ClientTravel("MapMenu", TRAVEL_Absolute, false);
	myRoot.Master.GlobalInteractions[0].ViewportOwner.Actor.ConsoleCommand("SetViewPortNumberForNextMap 1");
}



function RestartGame()
{
    bDoRestartGame = false;
    myRoot.bProfileMenu = true;
    myRoot.CloseAll(true);
    myRoot.GotoState('');
    myRoot.Master.GlobalInteractions[0].ViewportOwner.Actor.ClientTravel( "?restart", TRAVEL_Relative, false );
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int index;
    local bool bLeftOrRight, bUpOrDown;
    local controller P;

    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
            return InternalOnClick(FocusedControl);
	    }
	    if (Key==0x08 || Key==0x1B/*IK_Backspace - IK_Escape*/)
	    {
	        myRoot.CloseAll(true);
	        myRoot.GotoState('');
/*            for ( P=myRoot.GetLevel().ControllerList; P!=None; P=P.NextController )
            {
                if (XIIIRootWindow(PlayerController(P).Player.LocalInteractions[0]).bIamInMulti == true)
                myRoot.GetPlayerOwner().Player.Actor.SetPause( true );
            }*/
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
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}


function ShowWindow()
{

     Super.ShowWindow();

     bShowBCK = true;
     bShowSEL = true;
}


State STA_ResetInputs
{
Begin:
	Sleep(0.1);
	GetPlayerOwner().ResetInputs();
	GotoState('');
}



defaultproperties
{
     TeamText="Change Team"
     OptionsText="Options"
     QuitText="Quit Game"
     ReturnText="Return to game"
     RestartText="Restart Game"
     KickText="Kick a player"
     ConfirmQuitTxt="Are you sure ?"
     BombText="Change Class"
     QuitTextAsHost="Leaving the game now will end this session.  Are you sure?"
     bForceHelp=True
     Background=None
     bCheckResolution=True
     bRequire640x480=False
     bAllowedAsLast=True
}
