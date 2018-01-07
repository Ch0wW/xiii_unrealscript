class XIIIMenuLiveQuickmatchWindow extends XIIILiveWindow;

//var GUIListBox listbox;
var localized string TitleText;
var localized string connectingString;
var localized string searchingString;
var localized string noGamesFoundString;

var localized string failedToJoinString;

var bool UpdateMe;
var bool Probing;
var bool ConnectingToGame;
var float starttime;
var bool StartGameQuestion;
var int BackFromJoin;
var bool BackFromJoinNotNow;
var string AutoLoginName;




var XboxLiveManager.eGameType gameType;

function Created()
{
  local int i;
  Super.Created();
}

function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  local int numberOfAccounts;

  Super.InitComponent(MyController, MyOwner);
     //listbox = GUIListBox(Controls[0]);

     if (xboxlive == none)
  	  xboxlive=New Class'XboxLiveManager';

	OnClick = InternalOnClick;

     /*
     if (xboxlive != none && xboxlive.IsNetCableIn())
     {
       listbox.list.Add("Hello");
       listbox.list.Add("World");
     }
     */
     //listbox.bVisibleWhenEmpty = true;
}

function Start(XboxLiveManager.eGameType gt)
{
  gameType = gt;
  xboxlive.QuickmatchStartQuery(gametype);
  updateMe = true;

  Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
  msgbox = XIIILiveMsgBox(myRoot.ActivePage);
  msgbox.ShowWorking=true;
  msgbox.SetupQuestion(pleaseWaitString, QBTN_Cancel, QBTN_Cancel, searchingString);
  msgbox.OnButtonClick=MsgBoxBtnClicked;
  msgbox.InitBox(160, 130, 16, 16, 320, 230);
}


function ShowWindow()
{
     OnMenu = 0; myRoot.bFired = false;
     Super.ShowWindow();
     bShowBCK = true;
     bShowRUN = false;
     bShowSEL = false;
}

function string GetGameTypeString(XboxLiveManager.eGameType gameType)
{
  switch (gameType)
  {
    case GT_DM:
      return "XIIIMP.XIIIMPGameInfo";
    case GT_TeamDM:
      return "XIIIMP.XIIIMPTeamGameInfo";
    case GT_CTF:
      return "XIIIMP.XIIIMPCTFGameInfo";
    case GT_Sabotage:
      return "XIIIMP.XIIIMPBombGame";
    case GT_Duel:
      return "XIIIMP.XIIIRocketArena";
  }

  return "";
}

function StartGameMsgBox(BYTE button)
{
  local int N;
  local string GameTypeString, URL, Map;
  local class<GameInfo> GameClass;
  local bool FriendlyFire;
	local int i;
	local string MyClass, SkinCode;

  if (button == QBTN_Yes)
  {
    Map = xboxlive.GetRandomMap(gameType);
    FriendlyFire = false;
    xboxlive.SessionSetGameType(gameType);
    xboxlive.SessionSetMapName(Map);
    xboxlive.SessionSetTimeLimit(15);
    xboxlive.SessionSetFragLimit(25);
    xboxlive.SessionSetPublicSlots( xboxlive.GetRecommendedPlayers(map) );
    xboxlive.SessionSetPrivateSlots(0);
    xboxlive.SessionSetFriendlyFire(FriendlyFire);
    xboxlive.SessionSetCycleLevels(true);
    xboxlive.SessionSetMinSkill(SKILL_Beginner);
    xboxlive.SessionSetMaxSkill(SKILL_Elite);
    GameTypeString=GetGameTypeString(gameType);
    GameClass = Class<XIIIMPGameInfo>(DynamicLoadObject(GameTypeString, class'Class'));
    if (GameTypeString != "XIIIMP.XIIIMPGameInfo" && GameTypeString != "XIIIMP.XIIIRocketArena")
      class<XIIIMPTeamGameInfo>(GameClass).default.fFriendlyFireScale = float(FriendlyFire);
    N = xboxlive.GetRecommendedPlayers(map)+0;
    class<XIIIMPGameInfo>(GameClass).Default.MaxPlayers = N;
    //MapChanged(); GameChanged();
    //URL = Map$"?Game="$GameTypeString$"?Listen";
    //SaveConfigs();
    myRoot.bXboxStartup = true;
    myRoot.CloseMenu(true);
    myRoot.CloseMenu(true);
    myRoot.CloseMenu(true);
    Controller.OpenMenu("XIDInterf.XIIIMenuLiveAccountWindow");
    XIIIMenuLiveAccountWindow(myRoot.ActivePage).AutoLoginUser = xboxlive.GetCurrentUser();
    myRoot.CloseAll(true);
    myRoot.GotoState('');
    GetPlayerOwner().AttribPadToViewport();
    GetPlayerOwner().PlayerReplicationInfo.SetPlayerName(xboxlive.GetCurrentUser());
    //GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
  	// skin
  	MyClass = GetPlayerOwner().GetDefaultURL("MySkin");
  	SkinCode = class'MeshSkinList'.default.MeshSkinListInfo[0].SkinCode;
  	for (i=0;i<class'MeshSkinList'.default.MeshSkinListInfo.Length;i++)
  	{
  		if ( MyClass == class'MeshSkinList'.default.MeshSkinListInfo[i].SkinName )
  		{
  			SkinCode = class'MeshSkinList'.default.MeshSkinListInfo[i].SkinCode;
  			break;
  		}
  	}
  	

      URL = Map$
            "?listen"$
            "?Game="$GameTypeString$
            "?NP="$N$
            "?FF="$FriendlyFire$
            "?FR="$25$
            "?TI="$15$
		    "?SK="$SkinCode$
            "?GAMERTAG="$xboxlive.ConvertString(xboxlive.GetCurrentUser());
    log("TRAVELING w/URL: "$URL);
    GetPlayerOwner().ConsoleCommand("start "$URL);

    //GetPlayerOwner().ConsoleCommand("start "$Map$"?Game="$GameTypeString$"?listen");
  }
  else
  {
    myRoot.CloseMenu(true);
  }
}

function Process()
{
  local XboxLiveManager.XBL_MESSAGES msg;
  local int count, i, msg2;
  count = 0;
  msg = xboxlive.QuickmatchProcessQuery();

  if (msg != XBLE_NONE)
  {
    if (msg == XBLE_RUNNING)
    { // WHOOO
      UpdateMe = false;
      count = xboxlive.QuickmatchGetResultCount();
      /*for (i=0; i<count; i++)
      {
        listbox.list.Add(xboxlive.QuickmatchGetMapName(i));
      }*/

      if (count == 0)
      { // No games found
        // Autocreate one of the requested type...
        myRoot.CloseMenu(true);
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(noGamesFoundString, QBTN_Yes|QBTN_No, QBTN_Yes);
        msgbox.OnButtonClick=StartGameMsgBox;
        msgbox.InitBox(120, 130, 16, 16, 400, 230);
      }
      else
      { // Found game(s)
        //Send probes to find out which games work / are best

        if (!XboxLive.QuickmatchProbe())
        {
          // Create one instead (question)
          myRoot.CloseMenu(true);
          Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
          msgbox = XIIILiveMsgBox(myRoot.ActivePage);
          msgbox.SetupQuestion(noGamesFoundString, QBTN_Yes|QBTN_No, QBTN_Yes);
          msgbox.OnButtonClick=StartGameMsgBox;
          msgbox.InitBox(120, 130, 16, 16, 400, 230);
        }
        else
        {
          Probing = true;
        }
      }
    }
    else
    {
      myRoot.CloseMenu(true);
      UpdateMe = false;
      //msg = xboxlive.GetLastError();
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
      msgbox.OnButtonClick=MsgBoxBtnClicked;
      msgbox.InitBox(120, 130, 16, 16, 400, 230);
    }
  }
}

function ProcessProbe()
{
  local XboxLiveManager.XBL_MESSAGES msg;
  local int i, count, bestIndex, bestQOS, qos, msg2;
  if (!xboxlive.QuickmatchIsProbing())
  {
    myRoot.CloseMenu(true);
    probing = false;
    bestIndex = 0;
    bestQOS = 100;
    count = xboxlive.QuickmatchGetResultCount();
    for (i=0; i<count; i++)
    {
      qos = xboxlive.QuickmatchGetQoS(i);
      if (qos < bestQOS)
      {
        bestIndex = i;
        bestQOS = qos;
      }
    }
    // Ok, join the bestIndex game! (best QoS)
    if (!xboxlive.QuickmatchJoinSession(bestIndex))
    {
      msg2 = xboxlive.GetLastError();
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(failedToJoinString, QBTN_Ok, QBTN_Ok);
      msgbox.OnButtonClick=MsgBoxBtnClicked;
      msgbox.InitBox(120, 130, 16, 16, 400, 230);
    }
    else
    {
      starttime = GetPlayerOwner().Level.TimeSeconds;
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.ShowWorking=true;
      msgbox.SetupQuestion(pleaseWaitString, QBTN_Cancel, QBTN_Cancel, connectingString);
      msgbox.OnButtonClick=MsgBoxBtnClicked;
      msgbox.InitBox(160, 130, 16, 16, 320, 230);
      ConnectingToGame = true;
    }
  }
  else
  {
    msg = xboxlive.QuickmatchProcessQuery();
    if (msg != XBLE_NONE && msg != XBLE_RUNNING)
    {
      // Probe failed!
      probing = false;
      myRoot.CloseMenu(true);
      myRoot.CloseMenu(true);
    }
  }
}

function ProcessConnect()
{
  local int msg;
  local string URL;
  local XIIIMenuLiveJoinMsgBox JoinMsgbox;

  if (xboxlive.QuickmatchJoinIsFinished() && (GetPlayerOwner().Level.TimeSeconds - starttime)>2.0)
  {
    ConnectingToGame = false;
    // Connect to URL
    URL = xboxlive.QuickmatchGetURL();

    myRoot.CloseMenu(true);

    BackFromJoin=1;
    AutoLoginName=xboxlive.GetCurrentUser();
    BackFromJoinNotNow=true;

    Controller.OpenMenu("XIDInterf.XIIIMenuLiveJoinMsgBox");
    JoinMsgbox = XIIIMenuLiveJoinMsgBox(myRoot.ActivePage);
    JoinMsgbox.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 220*fRatioX, 230*fRatioY*fScaleTo);//, true);
    JoinMsgbox.MsgBoxStatus = 100;
    JoinMsgbox.URL = URL;
  }
  else
  {
    msg = xboxlive.GetLastError();
    if (msg == 0) // Still waiting?
      return;

    // Error!
    myRoot.CloseMenu(true);
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(failedToJoinString, QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
    msgbox.InitBox(120, 130, 16, 16, 400, 230);
    ConnectingToGame = false;
  }
}

event Tick(float deltatime)
{
  if (BackFromJoin==1 && !BackFromJoinNotNow)
  {
    BackFromJoin=0;
    BackFromJoinNotNow=false;
	  myRoot.CloseMenu(true);
    myRoot.CloseMenu(true);
    myRoot.CloseMenu(true);
    Controller.OpenMenu("XIDInterf.XIIIMenuLiveAccountWindow", true);
    XIIIMenuLiveAccountWindow(myRoot.ActivePage).AutoLoginUser = AutoLoginName;
    return;
  }
}

function Paint(Canvas C, float X, float Y)
{
  if (UpdateMe)
    Process();

  if (ConnectingToGame)
    ProcessConnect();

  if (Probing)
    ProcessProbe();

  Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);
}

// if subclassed, this parent function must always be called first
function string GetPageParameters()
{
    return Super.GetPageParameters()$"?BackFromJoin="$BackFromJoin$"?AutoLoginName="$xboxlive.ConvertString(AutoLoginName);
}

// if GetPageParameters() is subclassed, you'd better have this one too !
function SetPageParameters(string PageParameters)
{
    log("SetPageParameters("$PageParameters$") called for "$self);

    BackFromJoin = int(localParseOption(PageParameters, "BackFromJoin", ""));
    AutoLoginName = xboxlive.UnconvertString((localParseOption(PageParameters, "AutoLoginName", "")));
}

// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    //local int i,sel,msg;
    if (ConnectingToGame)
      return true;

    /*
    sel = listbox.list.Index;

    if (sel >= 0 && sel < listbox.list.Elements.length)
    {
      if (!xboxlive.QuickmatchJoinSession(sel))
      {
        msg = xboxlive.GetLastError();
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
        msgbox.OnButtonClick=MsgBoxBtnClicked;
        msgbox.InitBox(120*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 400*fRatioX, 230*fRatioY*fScaleTo);
      }
      else
      {
        starttime = GetPlayerOwner().Level.TimeSeconds;
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(pleaseWaitString, 0, 0, "Connecting");
        msgbox.OnButtonClick=MsgBoxBtnClicked;
        msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
        ConnectingToGame = true;
      }
    }
    */
    return true;
}

function MsgBoxBtnClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
      if (updateMe || probing)
      {
	      xboxlive.QuickmatchCancelQuery();
	      myRoot.CloseMenu(true);
	    }
      /*log("[XIIILiveMsgBox] Ok pressed");
      xboxlive.ShutdownAndCleanup();
	    myRoot.CloseMenu(true);
      Controller.ReplaceMenu("XIDInterf.XIIIMenuLiveAccountWindow");
      */
    break;
    case QBTN_Cancel:
      xboxlive.QuickmatchCancelQuery();
	    myRoot.CloseMenu(true);
    break;
  }
  //log("msgbox clicked: "$bButton);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
  local int msg;
    if (state==1/* || state==2*/)// IST_Press // to avoid auto-repeat
    {
      if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
          //Controller.FocusedControl.OnClick(Self);
          InternalOnClick(Controller.FocusedControl);
          return true;
	    }
	    if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
	    {
	        xboxlive.QuickmatchCancelQuery();
	        myRoot.CloseMenu(true);
    	    return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



