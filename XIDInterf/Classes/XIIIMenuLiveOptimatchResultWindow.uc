class XIIIMenuLiveOptimatchResultWindow extends XIIILiveWindow;

//var GUIListBox listbox;
var XIIIGUIMultiListBox listboxMulti;
var localized string TitleText, noOptimatchResultString;

var bool UpdateMe;
var bool ConnectingToGame;

var XIIIGUIButton GameTypeButton;
var XIIIGUIButton MapNameButton;
var XIIIGUIButton FragLimitButton;
var XIIIGUIButton TimeLimitButton;
var XIIIGUIButton FriendlyFireButton;
var XIIIGUIButton CycleLevelsButton;
var XIIIGUIButton LanguageButton;
var XIIIGUIButton PlayerCountButton;

var XIIILiveMsgBox waitbox;

var texture QoSIcons[4];

var bool ProbeRunning;

var localized string LabelNames[8];
var GUILabel Labels[8];

var int oldsel;
var float starttime;

var localized string EnglishString;
var localized string FrenchString;
var localized string GermanString;
var localized string SpanishString;
var localized string SwedishString;
var localized string DutchString;
var localized string ItalianString;

var localized string probeFailedString;

var localized string GameTypeStrings[6];

var localized string YesString,NoString,AnyString;

var localized string failedToJoinString;
var localized string noGamesFoundString;

var localized string areYouSureToJoinRed;
var int sessionsel;

var int BackFromJoin;
var bool BackFromJoinNotNow;
var string AutoLoginName;

var XboxLiveManager.eGameType 	searchGameType;
var string 			searchMap;
var int     			searchFriendlyFire;
var XboxLiveManager.eLanguage	searchLanguage;

function String GetLanguageString(XboxLiveManager.eLanguage language)
{
  switch (language)
  {
    case LANG_All:
    return AnyString;
    case LANG_EnglishOnly:
    return EnglishString;
    case LANG_FrenchOnly:
    return FrenchString;
    case LANG_GermanOnly:
    return GermanString;
    case LANG_SpanishOnly:
    return SpanishString;
    case LANG_SwedishOnly:
    return SwedishString;
    case LANG_DutchOnly:
    return DutchString;
    case LANG_ItalianOnly:
    return ItalianString;
  }
  return AnyString;
}

function string GetRealGameTypeString(XboxLiveManager.eGameType gameType)
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

function String GetGameTypeString(XboxLiveManager.eGameType gametype)
{
  switch (gametype)
  {
    case GT_DM:
      return GameTypeStrings[0];
    case GT_TeamDM:
      return GameTypeStrings[1];
    case GT_CTF:
      return GameTypeStrings[2];
    case GT_Duel:
      return GameTypeStrings[3];
    case GT_Sabotage:
      return GameTypeStrings[4];
  }
  return GameTypeStrings[5];
}

function ResetButtons()
{
  local int sel;

  local XboxLiveManager.eGameType gametype;
  local string mapname;
  local int fraglimit;
  local int timelimit;
  local XboxLiveManager.eLanguage language;
  local XboxLiveManager.eSkill minskill;
  local XboxLiveManager.eSkill maxskill;
  local int playercount;
  local bool friendlyfire;
  local bool cyclelevels;
  local int maxplayers;

  sel = listboxMulti.list.Index;
  if (sel >= 0 && sel < listboxMulti.list.Elements.length)
  {
    gametype    = xboxlive.OptimatchGetGameType(sel);
    mapname     = xboxlive.OptimatchGetMapName(sel);
    fraglimit   = xboxlive.OptimatchGetFragLimit(sel);
    timelimit   = xboxlive.OptimatchGetTimeLimit(sel);
    language    = xboxlive.OptimatchGetLanguage(sel);
    minskill    = xboxlive.OptimatchGetMinSkill(sel);
    maxskill    = xboxlive.OptimatchGetMaxSkill(sel);
    playercount = xboxlive.OptimatchGetPlayerCount(sel);
    friendlyfire= xboxlive.OptimatchGetFriendlyFire(sel);
    cyclelevels = xboxlive.OptimatchGetCycleLevels(sel);
    maxplayers  = xboxlive.OptimatchGetTotalPublicSlots(sel) + xboxlive.OptimatchGetTotalPrivateSlots(sel);

    GameTypeButton.Caption      = GetGameTypeString(gametype);
    MapNameButton.Caption       = xboxlive.GetNiceName(mapname);
    FragLimitButton.Caption     = ""$fraglimit;

    if (gametype == GT_Duel)
      TimeLimitButton.Caption     = ""$timelimit$" sec";
    else
      TimeLimitButton.Caption     = ""$timelimit;
    if (friendlyfire)
      FriendlyFireButton.Caption  = YesString;
    else
      FriendlyFireButton.Caption  = NoString;
    //if (cyclelevels)
    //  CycleLevelsButton.Caption  = YesString;
    //else
    //  CycleLevelsButton.Caption  = NoString;
    LanguageButton.Caption      = GetLanguageString(language);
    PlayerCountButton.Caption   = ""$playercount$"/"$maxplayers;
  }
  else
  {
    GameTypeButton.Caption      = "";
    MapNameButton.Caption       = "";
    FragLimitButton.Caption     = "";
    TimeLimitButton.Caption     = "";
    FriendlyFireButton.Caption  = "";
    //CycleLevelsButton.Caption   = "";
    LanguageButton.Caption      = "";
    PlayerCountButton.Caption   = "";
  }
}

function Created()
{
  local int i;
  local int msg;

  Super.Created();
  GameTypeButton        = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 450-10,       100,    150,  30));
  MapNameButton         = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 450-10,       135,    150,  30));
  PlayerCountButton     = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500-10-12.5,  170,    75,   30));
  FriendlyFireButton    = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500-10,       204,    50,   30));
  //CycleLevelsButton     = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500-10,       240,    50,   30));
  LanguageButton        = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 450-10,       240,    150,  30));
  FragLimitButton       = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500-10-12.5,  275,    75,   30));
  TimeLimitButton       = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 500-10-12.5,  310,    75,   30));


  QoSIcons[0]=texture'XIIIXboxPacket.QoS1';
  QoSIcons[1]=texture'XIIIXboxPacket.QoS2';
  QoSIcons[2]=texture'XIIIXboxPacket.QoS3';


  //ResetButtons();

  Controls[1]=GameTypeButton;
  Controls[2]=MapNameButton;
  Controls[3]=PlayerCountButton;
  Controls[4]=FriendlyFireButton;
  //Controls[5]=CycleLevelsButton;
  Controls[5]=LanguageButton;
  Controls[6]=FragLimitButton;
  Controls[7]=TimeLimitButton;
  for (i=1; i<=7; i++)
  {
    Controls[i].StyleName = "SquareButton";
    Controls[i].bNeverFocus = true;
    Labels[i-1] = GUILabel(CreateControl(class'GUILabel', 300, 100+35*(i-1), 150, 26));
    if (i-1>=4)
    	Labels[i-1].caption = LabelNames[i];
    else
    Labels[i-1].caption = LabelNames[i-1];
    Labels[i-1].StyleName="LabelWhite";
    Labels[i-1].TextColor.R=255;
    Labels[i-1].TextColor.G=255;
    Labels[i-1].TextColor.B=255;
    controls[8+i-1] = Labels[i-1];
  }
}

function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  Super.InitComponent(MyController, MyOwner);
     listboxMulti = XIIIGUIMultiListBox(Controls[0]);
  if (xboxlive == none)
    xboxlive=New Class'XboxLiveManager';
	OnClick = InternalOnClick;
  listboxMulti.bVisibleWhenEmpty = true;
  updateMe = true;


  listboxMulti.SetNumberOfColumns(3);
  listboxMulti.SetColumnOffset(0, 0);
  listboxMulti.SetColumnOffset(1, 150);
  listboxMulti.SetColumnOffset(2, 205);

  if (xboxlive.IsLoggedIn(xboxlive.GetCurrentUser()))
  {
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
    waitbox = XIIILiveMsgBox(myRoot.ActivePage);
    waitbox.ShowWorking=true;
    waitbox.SetupQuestion(pleaseWaitString, QBTN_Cancel, QBTN_Cancel, "");
    waitbox.InitBox(160, 130, 16, 16, 320, 190);
    waitbox.OnButtonClick=WaitBoxBtnClicked;
  }
  bSHowUPDATE=false;

  //listbox.List.UserDefinedItemHeight = 36;
}

function ShowWindow()
{
     OnMenu = 0; myRoot.bFired = false;
     Super.ShowWindow();
     bShowBCK = true;
     bShowRUN = false;
     bShowSEL = false;
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
    searchGameType = xboxlive.GetSearchGameType();
    searchMap = xboxlive.GetSearchMap();
    searchFriendlyFire = xboxlive.GetSearchFriendlyFire();
    searchLanguage = xboxlive.GetSearchLanguage();

    Map = searchMap;//xboxlive.GetRandomMap(searchGameType);
    if (searchFriendlyFire == 1)
      FriendlyFire = true;
    else
      FriendlyFire = false;
    xboxlive.SessionSetGameType(searchGameType);
    xboxlive.SessionSetMapName(searchMap);
    xboxlive.SessionSetTimeLimit(15);
    xboxlive.SessionSetFragLimit(25);
    xboxlive.SessionSetPublicSlots( xboxlive.GetRecommendedPlayers(map) );
    xboxlive.SessionSetPrivateSlots(0);
    xboxlive.SessionSetFriendlyFire(FriendlyFire);
    xboxlive.SessionSetCycleLevels(true);
    xboxlive.SessionSetMinSkill(SKILL_Beginner);
    xboxlive.SessionSetMaxSkill(SKILL_Elite);
     xboxlive.SessionSetLanguage(searchLanguage);
    GameTypeString=GetRealGameTypeString(searchGameType);
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
  local GUIMultiListBoxLine pack;
  local XboxLiveManager.XBL_MESSAGES msg;
  local int count, i;
  count = 0;
  msg = xboxlive.OptimatchProcessQuery();

  if (msg != XBLE_NONE)
  {
    if (msg == XBLE_RUNNING)
    { // WHOOO
      UpdateMe = false;

      count = xboxlive.OptimatchGetResultCount();
      for (i=0; i<count; i++)
      {
        pack = new class'GUIMultiListBoxLine';
        pack.items[0].str = xboxlive.OptimatchGetPlayerCount(i)$"/"$(xboxlive.OptimatchGetTotalPublicSlots(i) + xboxlive.OptimatchGetTotalPrivateSlots(i));
        pack.items[1].tex = QoSIcons[xboxlive.OptimatchGetQoS(i)]; // QoS icon here!!
        //listboxMulti.List.Add(xboxlive.GetNiceName(xboxlive.OptimatchGetMapName(i)), pack);
        listboxMulti.List.Add(xboxlive.OptimatchGetOwner(i), pack);

        //AJ listboxMulti.list.Add(xboxlive.OptimatchGetMapName(i)$" "$xboxlive.OptimatchGetPlayerCount(i)$"/"$xboxlive.OptimatchGetTotalPublicSlots(i));
      }

      if (waitbox != none)
      {
        myRoot.CloseMenu(true);
        waitbox = none;
      }

      if (count == 0)
      {
        /*
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(noOptimatchResultString, QBTN_Continue, QBTN_Continue);
        msgbox.OnButtonClick=MsgBoxBtnClicked;
        msgbox.InitBox(120*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 400*fRatioX, 230*fRatioY*fScaleTo);
	*/
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(noGamesFoundString, QBTN_Yes|QBTN_No, QBTN_Yes);
        msgbox.OnButtonClick=StartGameMsgBox;
        msgbox.InitBox(120, 130, 16, 16, 400, 230);

      }
      else
      {
        ResetButtons();
        bShowRUN = true;
        bSHowUPDATE = true;
        if (!xboxlive.OptimatchProbe())
        {
          Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
          msgbox = XIIILiveMsgBox(myRoot.ActivePage);
          msgbox.SetupQuestion(probeFailedString, QBTN_Continue, QBTN_Continue);
          msgbox.OnButtonClick=MsgBoxBtnClicked;
          msgbox.InitBox(120*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 400*fRatioX, 230*fRatioY*fScaleTo);
        }
        else
          ProbeRunning = true;
      }
    }
    else
    {
      if (waitbox != none)
      {
        myRoot.CloseMenu(true);
        waitbox = none;
      }
      UpdateMe = false;
      //msg = xboxlive.GetLastError();
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
      msgbox.OnButtonClick=MsgBoxBtnClicked;
      msgbox.InitBox(120*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 400*fRatioX, 230*fRatioY*fScaleTo);
    }
  }
}

function ProcessConnect()
{
  local int msg;
  local string URL;
  local XIIIMenuLiveJoinMsgBox JoinMsgbox;
  local string MyClass, SkinCode;
	local int i;

  if (xboxlive.OptimatchJoinIsFinished() /*&& (GetPlayerOwner().Level.TimeSeconds - starttime)>2.0*/)
  {
    ConnectingToGame = false;
    // Connect to URL
    URL = xboxlive.OptimatchGetURL();
    
    if (URL != "")
    {
      myRoot.CloseMenu(true);

      BackFromJoin=1;
      AutoLoginName=xboxlive.GetCurrentUser();
      BackFromJoinNotNow=true;

      Controller.OpenMenu("XIDInterf.XIIIMenuLiveJoinMsgBox");
      JoinMsgbox = XIIIMenuLiveJoinMsgBox(myRoot.ActivePage);
      JoinMsgbox.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 220*fRatioX, 230*fRatioY*fScaleTo);//, true);
      JoinMsgbox.MsgBoxStatus = 100;
      JoinMsgbox.URL = URL;//$"?SK="$SkinCode;
    }
  }
  else
  {
    msg = xboxlive.GetLastError();
    if (msg == 0) // Still waiting?
      return;

    if (waitbox != none)
    {
      myRoot.CloseMenu(true);
      waitbox = none;
    }

    // Error!
    myRoot.CloseMenu(true);
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(failedToJoinString, QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
    msgbox.InitBox(120*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 400*fRatioX, 230*fRatioY*fScaleTo);
    ConnectingToGame = false;
  }
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

event Tick(float deltatime)
{
  if (Controller != none && BackFromJoin==1 && !BackFromJoinNotNow)
  {
    log("Back from join and autologinname exist!");
    //BackFromJoin=0;
    //BackFromJoinNotNow=false;
	  myRoot.CloseMenu(true);
    myRoot.CloseMenu(true);
    myRoot.CloseMenu(true);
    myRoot.CloseMenu(true);
    //myRoot.CloseMenu(true);
    log("Back from join and autologinname exist (2)");
    Controller.OpenMenu("XIDInterf.XIIIMenuLiveAccountWindow", true);
    XIIIMenuLiveAccountWindow(myRoot.ActivePage).AutoLoginUser = AutoLoginName;
    log("Back from join and autologinname exist (3)");
    return;
  }
}

function Paint(Canvas C, float X, float Y)
{
  local int newsel, count, i;
  local GUIMultiListBoxLine pack;
  local XboxLiveManager.XBL_MESSAGES msg;
  local string name;
  local int temptop;
  local int tempindex;

  if (UpdateMe)
    Process();
  else if (ConnectingToGame)
    ProcessConnect();
  else if (probeRunning && !xboxlive.OptimatchIsProbing())
  {
    name = listboxMulti.List.GetItemAtIndex(listboxMulti.List.Index);
    temptop = listboxMulti.List.top;
    tempindex = listboxMulti.List.Index;
    listboxMulti.List.Clear();
    probeRunning = false;
    count = xboxlive.OptimatchGetResultCount();
    for (i=0; i<count; i++)
    {
      pack = new class'GUIMultiListBoxLine';
      pack.items[0].str = xboxlive.OptimatchGetPlayerCount(i)$"/"$(xboxlive.OptimatchGetTotalPublicSlots(i) + xboxlive.OptimatchGetTotalPrivateSlots(i));
      pack.items[1].tex = QoSIcons[xboxlive.OptimatchGetQoS(i)]; // QoS icon here!!
      //listboxMulti.List.Add(xboxlive.GetNiceName(xboxlive.OptimatchGetMapName(i)), pack);
      listboxMulti.List.Add(xboxlive.OptimatchGetOwner(i), pack);
      if (name == xboxlive.OptimatchGetOwner(i))
        tempindex = i;
      //AJ listboxMulti.list.Add(xboxlive.OptimatchGetMapName(i)$" "$xboxlive.OptimatchGetPlayerCount(i)$"/"$xboxlive.OptimatchGetTotalPublicSlots(i));
    }
    if (listboxMulti.List.ItemCount>tempindex)
    {
      if (temptop>tempindex)
        temptop = tempindex;
      if (tempindex>temptop+listboxMulti.List.ItemsPerPage)
        temptop = tempindex;
      listboxMulti.List.top   = temptop;
      listboxMulti.List.Index = tempindex;
    }
    //ResetButtons();
  }
  else if (probeRunning)
  {
    msg = xboxlive.OptimatchProcessQuery();
    if (msg != XBLE_NONE && msg != XBLE_RUNNING)
    {
      // Probe failed!
      probeRunning = false;
    }
  }

  newsel = listboxMulti.list.Index;
  if (newsel != oldsel)
  {
    oldsel = newsel;
    ResetButtons();
  }

  Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);
}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    local int i,sel,msg;
    local string URL;

    if (ConnectingToGame)
      return true;

    sessionsel = -1;
    sel = listboxMulti.list.Index;

    if (sel >= 0 && sel < listboxMulti.list.Elements.length)
    {
      //if(true)
      if((xboxlive.OptimatchGetQoS(sel) == 2))
      {
      	sessionsel = sel;
      	Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(areYouSureToJoinRed, QBTN_Ok | QBTN_Cancel, QBTN_Ok);
        msgbox.OnButtonClick=MsgBoxBtnClickedForRed;
        msgbox.InitBox(120*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 400*fRatioX, 230*fRatioY*fScaleTo);
      }
      else
      if (!xboxlive.OptimatchJoinSession(sel))
      {
        msg = xboxlive.GetLastError();
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(failedToJoinString, QBTN_Ok, QBTN_Ok);
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
    return true;
}

function MsgBoxBtnClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
    break;
    case QBTN_Continue:
      myRoot.CloseMenu(true);
    break;
  }
  //log("msgbox clicked: "$bButton);
}

function MsgBoxBtnClickedForRed(byte bButton)
{
  if(sessionsel == -1)
    return;

  switch (bButton)
  {
    case QBTN_Ok:
      if (!xboxlive.OptimatchJoinSession(sessionsel))
      {
        //msg = xboxlive.GetLastError();
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(failedToJoinString, QBTN_Ok, QBTN_Ok);
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
    break;
  }
}

function WaitBoxBtnClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Cancel:
	    xboxlive.OptimatchCancelQuery();
	    bSHowUPDATE=true;
      myRoot.CloseMenu(true);
    break;
  }
  //log("msgbox clicked: "$bButton);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
  local int msg;

  //log(""$Key);
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
	        xboxlive.OptimatchCancelQuery();
	        myRoot.CloseMenu(true);
    	    return true;
	    }
	    if (Key==0xCB && bSHowUPDATE == true)
	    {
	      myRoot.CloseMenu(true);
	      XIIIMenuLiveOptimatchWindow(myRoot.ActivePage).bAutoUpdate = true;
	
        bSHowUPDATE=false;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



