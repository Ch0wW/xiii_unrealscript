//============================================================================
// The In Game menu for xbox live mode
//
//============================================================================
class XIIIMenuInGameXboxLive extends XIIILiveWindow;

#exec OBJ LOAD FILE=XIIIXboxPacket.utx

var  XIIIbutton          TeamButton, OptionsButton, FriendsButton, OnlineOptionsButton, QuitButton, ReturnButton, ChangeClassButton;//, RestartButton;
var  localized string    TeamText, OptionsText, QuitText, FriendsText, OnlineOptionsText, ReturnText, QuitText2;//RestartText, 
var  localized string    kickedString, serverDownString, ConfirmQuitTxt;
var  localized string	 statwritefailedString, statwritestartingString;

var texture inviteReceivedIcon, friendRequestReceivedIcon;
var float yPosInviteIcon;
var int userState;

var XboxliveManager xboxlive;
var XIIIMsgBox MsgBox;
var XIIIMsgBoxInGame MsgBoxIngm;
var bool hasstatsstarted;

var  bool      bTeamMode;
var localized string ChangeClass;

function Created()
{
	LOCAL class<GameInfo> GameClass;

  Super.Created();

  if (xboxlive == none)
    xboxlive=New Class'XboxLiveManager';

	if ( GetPlayerOwner().myHUD.bShowScores )
		GetPlayerOwner().myHUD.HideScores();
	
	// team mode
	GameClass = class<GameInfo>(dynamicloadobject(GetPlayerOwner().GameReplicationInfo.GameClass, class'class'));
	if ( !GameClass.default.bTeamGame || ( GetPlayerOwner().Level.NetMode == 0 ) )
	{
		bTeamMode = false;
	}
	else
	{
		bTeamMode = true;
	}

     ReturnButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 135*fScaleTo, 200, 30));
     ReturnButton.Text = ReturnText;
     ReturnButton.bNoBg =true;

     TeamButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 175*fScaleTo, 200, 30));
     TeamButton.Text = TeamText;
     TeamButton.bNoBg =true;

     OptionsButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 215*fScaleTo, 200, 30));
     OptionsButton.Text = OptionsText;
     OptionsButton.bNoBg =true;

     FriendsButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 255*fScaleTo, 200, 30));
     FriendsButton.Text = FriendsText;
     FriendsButton.bNoBg =true;

     //PlayersButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 275*fScaleTo, 200, 30));
     //PlayersButton.Text = PlayersText;
     //PlayersButton.bNoBg =true;

     OnlineOptionsButton       = XIIIbutton(CreateControl(class'XIIIbutton', 230, 295*fScaleTo, 200, 30));
     OnlineOptionsButton.Text  = OnlineOptionsText;
     OnlineOptionsButton.bNoBg = true;

     ChangeClassButton       = XIIIbutton(CreateControl(class'XIIIbutton', 230, 325*fScaleTo, 200, 30));
     ChangeClassButton.Text  = ChangeClass;
     ChangeClassButton.bNoBg = true;
     
     if (GetPlayerOwner().GameReplicationInfo.GameClass != "XIIIMP.XIIIMPBombGame")
     {
       ChangeClassButton.bVisible = false;
     }

     //RestartButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 325*fScaleTo, 200, 30));
     //RestartButton.Text = RestartText;
     //RestartButton.bNoBg =true;

     QuitButton = XIIIbutton(CreateControl(class'XIIIbutton', 230, 375*fScaleTo, 200, 30));
     QuitButton.Text = QuitText;
     QuitButton.bNoBg =true;

    Controls[0] = ReturnButton;  Controls[1] = TeamButton; Controls[2] = OptionsButton;
    Controls[3] = FriendsButton; Controls[4] = OnlineOptionsButton; /*Controls[5] = RestartButton;*/ Controls[5] = ChangeClassButton; Controls[6] = QuitButton;

    bPauseIfPossible=false;
    
    hasstatsstarted = false;
	GotoState('STA_ResetInputs');
}


function MsgBoxBtnClicked(byte bButton)
{
  if (bButton == QBTN_Continue)
    bDoQuitGame = true;
}

function BeforePaint(Canvas C, float X, float Y)
{
  super.BeforePaint(C, X, Y);

  if (bDoQuitGame)
  {
    QuitGame();
    return;
  }
  /*if (bDoRestartGame)
  {
    RestartGame();
    return;
  }*/

  if (myRoot.ActivePage == self && (xboxlive.IsServerDown() || xboxlive.IsKicked()))
  {
    Controller.OpenMenu("XIDInterf.XIIIMsgBox");
    msgbox = XIIIMsgBox(myRoot.ActivePage);
    if (xboxlive.IsKicked())
      msgbox.SetupQuestion(kickedString, QBTN_Continue, QBTN_Continue);
    else
      msgbox.SetupQuestion(serverDownString, QBTN_Continue, QBTN_Continue);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
    msgbox.InitBox(120*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 400*fRatioX, 230*fRatioY*fScaleTo);
    xboxlive.ResetVoiceNet();
  }
}

function Paint(Canvas C, float X, float Y)
{
  local float alphavalue;
  local float yoffs;
  
  yoffs = 20.0;

  Super.Paint(C,X,Y);

  C.Style = 1;
  C.bUseBorder = true;
  C.DrawColor = WhiteColor;  //220      100 / 130              220         260   230

  if (!bTeamMode)
    DrawStretchedTexture(C, 185*fRatioX, (100+yoffs)*fRatioY*fScaleTo, 290*fRatioX, 240*fRatioY*fScaleTo, myRoot.FondMenu);
  else
    DrawStretchedTexture(C, 185*fRatioX, (100+yoffs)*fRatioY*fScaleTo, 290*fRatioX, 240*fRatioY*fScaleTo, myRoot.FondMenu);
  C.bUseBorder = false;

  if (/*xboxlive.IsLoggedIn(xboxlive.GetCurrentUser()) && */xboxlive.HasInvite())
  {
    // render an invite icon
    if (!bTeamMode)
      C.SetPos( 185.0*fRatioX + 5, yPosInviteIcon+yoffs/*205.0*/ + 15.0 - 16.0);
    else
      C.SetPos(185.0*fRatioX + 5, /*(245.0 - 35.0)*/ yPosInviteIcon +yoffs + 15.0 - 16.0);

    alphavalue      = abs(sin(XIIIPlayerController(GetPlayerOwner()).Player.Actor.Level.TimeSeconds*4.0))*255.0;
    C.DrawColor = WhiteColor;
    C.DrawColor.A = alphavalue;
    C.Style = 5; // ERenderStyle.STY_Alpha;
    C.DrawTile(inviteReceivedIcon, inviteReceivedIcon.USize, inviteReceivedIcon.VSize, 0, 0, inviteReceivedIcon.USize, inviteReceivedIcon.VSize);
    C.Style = 1; // ERenderStyle.STY_Normal;
  }
  else if (xboxlive.HasFriendRequest())
  {
    // render a friend request icon
    if (XIIIPlayerController(GetPlayerOwner()).Player.Actor.Level.Game.IsA('XIIIMPTeamGameInfo') == false)
      C.SetPos( 185.0*fRatioX + 5, yPosInviteIcon+yoffs/*205.0*/ + 15.0 - 16.0);
    else
      C.SetPos(185.0*fRatioX + 5, /*(245.0 - 35.0)*/ yPosInviteIcon +yoffs+ 15.0 - 16.0);

    alphavalue      = abs(sin(XIIIPlayerController(GetPlayerOwner()).Player.Actor.Level.TimeSeconds*4.0))*255.0;
    C.DrawColor = WhiteColor;
    C.DrawColor.A = alphavalue;
    C.Style = 5; // ERenderStyle.STY_Alpha;
    C.DrawTile(friendRequestReceivedIcon, friendRequestReceivedIcon.USize, friendRequestReceivedIcon.VSize, 0, 0, friendRequestReceivedIcon.USize, friendRequestReceivedIcon.VSize);
    C.Style = 1; // ERenderStyle.STY_Normal;
  }
}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
  local XIIIMsgBoxInGame msgbox;
  local float yoffs;
  yoffs = 20.0;
  
  /*if (Sender == RestartButton)
  {
    myRoot.OpenMenu("XIDInterf.XIIIMenuYesNoWindow");
  }
  else */
  if (Sender == TeamButton)
  {
    myRoot.CloseAll(true);
    myRoot.GotoState('');
    GetPlayerOwner().ConsoleCommand("SwitchTeam");
  }
  else if (Sender == OptionsButton)
  {
    //if (myRoot.CurrentPF > 0)
    myRoot.OpenMenu("XIDInterf.XIIIMultiControlsWindow");
    //else
    //  myRoot.OpenMenu("XIDInterf.XIIIMenuInputPC");
  }
  else if (Sender == returnButton)
  {
    myRoot.CloseAll(true);
    myRoot.GotoState('');
  }
  else if (Sender == FriendsButton)
  {
    //myRoot.OpenMenu("XIDInterf.XIIIMenuLiveFriendsMainPage");
    myRoot.OpenMenu("XIDInterf.XIIIMenuLivePlayerList");
  }
  //else if (Sender == PlayersButton)
  //{
  //  myRoot.OpenMenu("XIDInterf.XIIIMenuLivePlayerList");
  //}
  else if (Sender == OnlineOptionsButton)
  {
    myRoot.OpenMenu("XIDInterf.XIIIMenuLiveSettings");
  }
  else if (Sender == ChangeClassButton)
  {
    myRoot.OpenMenu("XIDInterf.XIIIMenuInGameLiveSabotage");
  }
  else if (Sender == QuitButton)
  {
		bShowBCK = false;
		myRoot.OpenMenu("XIDInterf.XIIIMsgBoxInGame");
		MsgBox = XIIIMsgBoxInGame(myRoot.ActivePage);
		
  if (!bTeamMode)
		MsgBox.InitBox(185*fRatioX, (100+yoffs)*fRatioY*fScaleTo, 10, 10, 290*fRatioX, 240*fRatioY*fScaleTo);
  else
		MsgBox.InitBox(185*fRatioX, (100+yoffs)*fRatioY*fScaleTo, 10, 10, 290*fRatioX, 240*fRatioY*fScaleTo);
  		
    if (xboxlive.IsHost())
		  MsgBox.SetupQuestion(QuitText2, QBTN_Yes | QBTN_No, QBTN_No,"");
		else
		  MsgBox.SetupQuestion(ConfirmQuitTxt, QBTN_Yes | QBTN_No, QBTN_No,"");
		MsgBox.OnButtonClick = QuitMsgBoxReturn;
    
    //myRoot.OpenMenu("XIDInterf.XIIIMenuYesNoWindow");
    //XIIIMenuYesNoWindow(myRoot.ActivePage).bQuitGame = true;
    //if (xboxlive.IsHost())
    //  XIIIMenuYesNoWindow(myRoot.ActivePage).QuitText = QuitText2;
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
	myRoot.OpenMenu("XIDInterf.XIIIMenuLiveStatsWritePage");	
//GotoState('StatSaveQuit');
//GotoState   StatUpdate;

}

/*
function RestartGame()
{
    bDoRestartGame = false;
    //myRoot.bProfileMenu = true;
    myRoot.CloseAll(true);
    myRoot.GotoState('');
//        GetPlayerOwner().ConsoleCommand("RestartLevel");
// NL        GetPlayerOwner().ClientTravel( "?restart", TRAVEL_Relative, false );
        myRoot.Master.GlobalInteractions[0].ViewportOwner.Actor.ClientTravel( "?restart", TRAVEL_Relative, false );
// LN
}
*/

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int index;
    local bool bLeftOrRight, bUpOrDown;
    local controller P;

if(hasstatsstarted == false)
{
    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	{
//            Controller.FocusedControl.OnClick(FocusedControl);
		return InternalOnClick(FocusedControl);
	}
	if (Key==0x08 || Key==0x1B/*IK_Backspace - IK_Escape*/)
	{
		myRoot.CloseAll(true);
        	myRoot.GotoState('');
        	for ( P=myRoot.GetLevel().ControllerList; P!=None; P=P.NextController )
           	{
                	if (XIIIRootWindow(PlayerController(P).Player.LocalInteractions[0]).bIamInMulti == true)
                	myRoot.GetPlayerOwner().Player.Actor.SetPause( true );
            	}
          	xboxlive.EnumerateFriends(FALSE);
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
}
    return super.InternalOnKeyEvent(Key, state, delta);
//    return false;
}


function ShowWindow()
{
	local int yMove;
	
	yMove = 20;

	xboxlive.EnumerateFriends(TRUE);
	
	xboxlive.UpdateFriends();
	
	   log("AJ  "$bTeamMode);
     //if ( (XIIIPlayerContrOller(GetPlayerOwner()).Player.Actor.Level.Game.IsA('XIIIMPTeamGameInfo') == false) ||
     //    ( GetPlayerOwner().Level.NetMode == 0 ) )
     if (!bTeamMode)
     {
        TeamButton.bNeverFocus = true;
        TeamButton.bVisible = false;
//        bNotATeamGame = true;
//        RestartButton.WinTop = 55; OptionsButton.WinTop = 95;
        //OptionsButton.WinTop = (205*fScaleTo/480); restartButton.WinTop = (255*fScaleTo/480);
        //yMove = -10;
        ReturnButton.WinTop  = ((125 + yMove) *fScaleTo/480);
        //TeamButton.WinTop    = ((165 + yMove)*fScaleTo/480);
        //yMove -= 20;
        OptionsButton.WinTop = ((165 + yMove)*fScaleTo/480);
        FriendsButton.WinTop = ((205 + yMove)*fScaleTo/480);
        yPosInviteIcon = ((205 + yMove)*fScaleTo);
        //AJPlayersButton.WinTop = ((245 + yMove)*fScaleTo/480);
        OnlineOptionsButton.WinTop  = ((245 + yMove)*fScaleTo/480);
        //RestartButton.WinTop = ((285 + yMove)*fScaleTo/480);
        //yMove += 20;
        QuitButton.WinTop    = ((285 + yMove)*fScaleTo/480);


     }
     else {
        TeamButton.bNeverFocus = false;
        TeamButton.bVisible = true;
//        TeamButton.WinTop = 75;
        //bNotATeamGame = false;
//        RestartButton.WinTop = 35; OptionsButton.WinTop = 115;
        //OptionsButton.WinTop = (215*fScaleTo/480); restartButton.WinTop = (275*fScaleTo/480);

        //yMove = 0;
        ReturnButton.WinTop  = ((125 + yMove - 10) *fScaleTo/480);
        TeamButton.WinTop    = ((165 + yMove - 15)*fScaleTo/480);
        OptionsButton.WinTop = ((205 + yMove - 25)*fScaleTo/480);
        FriendsButton.WinTop = ((245 + yMove - 35)*fScaleTo/480);
        yPosInviteIcon = ((245 + yMove - 35)*fScaleTo);
        //AJPlayersButton.WinTop = ((285 + yMove - 35)*fScaleTo/480);
        OnlineOptionsButton.WinTop = ((285 + yMove - 45)*fScaleTo/480);
        //RestartButton.WinTop = ((325 + yMove - 55)*fScaleTo/480);
        ChangeClassButton.WinTop = ((325 + yMove - 55)*fScaleTo/480);
        QuitButton.WinTop    = ((365 + yMove - 65)*fScaleTo/480);

     }
     Super.ShowWindow();
     // MLK The help bar text for this screen
     bShowBCK = true;
     bShowSEL = true;
}

function QuitMsgBoxStatOkReturn(byte bButton)
{
	bShowBCK = false;
	if ((bButton & QBTN_Ok) != 0)
	{
		GotoState('NormalQuit');
	}
}

function QuitMsgBoxStatCancel(byte bButton)
{
	bShowBCK = false;
	if ((bButton & QBTN_Cancel) != 0)
	{
		//GotoState('normalquit');
	}
}


State StatSaveQuit
{
Begin:	
	//myRoot.OpenMenu("XIDInterf.XIIIMenuLiveStatsWritePage");
	
	//if(!hasstatsstarted)
	//{
	//	XIIIMPPlayerController(GetPlayerOwner()).StatUpdate();
	//	hasstatsstarted = true;
	//}
    
	//while (xboxlive.IsMyStatsUpdateDone() == false)
	//{
	//	Sleep(0.01);
	//}
	
	//if(xboxlive.WasMyStatsUpdateSuccessful() == false)
	//{
	//	myRoot.OpenMenu("XIDInterf.XIIIMsgBoxInGame");
	//	MsgBoxIngm = XIIIMsgBoxInGame(myRoot.ActivePage);
	//	MsgBoxIngm.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);
	//	MsgBoxIngm.SetupQuestion(statwritefailedString, QBTN_Ok, QBTN_Ok,"");
	//	MsgBoxIngm.OnButtonClick = QuitMsgBoxStatOkReturn;
	//}
	
	//GotoState('NormalQuit');
}

State NormalQuit
{
Begin:
      userState = xboxlive.US_ONLINE;
      if (xboxlive.HasUserVoice(xboxlive.GetCurrentUser()))
        userState = userState | xboxlive.US_VOICE;
      xboxlive.SetUserState(xboxlive.GetCurrentUser(), userState);

        xboxlive.EnumerateFriends(FALSE);

        xboxlive.ResetVoiceNet();

        GetPlayerOwner().myHUD.bShowScores = false;
        GetPlayerOwner().myHUD.bHideHud = true;

        myRoot.CloseAll(true);
        myRoot.GotoState('');

        myRoot.Master.GlobalInteractions[0].ViewportOwner.Actor.ClientTravel("MapMenu", TRAVEL_Absolute, false);

	GotoState('');
}

State STA_ResetInputs
{
Begin:
	Sleep(0.1);
	GetPlayerOwner().ResetInputs();
	GotoState('');
}


