class XIIIMenuLiveStartup extends XIIILiveWindow;

var localized string TitleText;
var XboxLiveManager xboxlive;
var XIIILiveMsgBox msgbox;
var localized string creatingSessionString;
var localized string pleaseWaitString;
var float starttime;
var bool WaitForStart;
var bool WaitForCreate;


function Created()
{
  local int i;
  Super.Created();

  if (xboxlive == none)
    xboxlive=New Class'XboxLiveManager';
}

function MsgBoxBtnClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
      xboxlive.SessionReset();
	    myRoot.CloseMenu(true);
    break;
  }
}

function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  local int msg, userState;

  Super.InitComponent(MyController, MyOwner);
	OnClick = InternalOnClick;

  // Why do I have to set these? They are 0 at the moment. Only valid inside the render or what?
  fRatioX = 1.0;
  fRatioY = 1.0;
  fScaleTo = 1.0;

  Log("[XIIIMenuProfileClient] Created...");
  if (xboxlive.IsLoggedIn(xboxlive.GetCurrentUser()) && (GetPlayerOwner().Level.NetMode==NM_DedicatedServer || GetPlayerOwner().Level.NetMode==NM_ListenServer))
  {
    Log("[XIIIMenuProfileClient] Xbox live running (server)");
    if (!xboxlive.SessionCreate())
    {
      Log("[XIIIMenuProfileClient] Failed to create session!");
      msg = xboxlive.GetLastError();
      myRoot.OpenMenu("XIDInterf.XIIILiveMsgBox");
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
      msgbox.OnButtonClick=MsgBoxBtnClicked;
    }
    else
    {
      Log("[XIIIMenuProfileClient] Created session!");
      WaitForCreate = true;
      starttime = GetPlayerOwner().Level.TimeSeconds;
      myRoot.OpenMenu("XIDInterf.XIIILiveMsgBox");
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(pleaseWaitString, 0, 0, creatingSessionString);
      //msgbox.OnButtonClick=MsgBoxBtnClicked;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
    }
  }
  else if (xboxlive.IsLoggedIn(xboxlive.GetCurrentUser()) && GetPlayerOwner().Level.NetMode==NM_Client)
  {
    Log("[XIIIMenuProfileClient] Xbox live running (client)");
    userState = xboxlive.US_ONLINE;
    if (xboxlive.HasUserVoice(xboxlive.GetCurrentUser()))
      userState = userState | xboxlive.US_VOICE;
    //if (!xboxlive.IsLadderGame())
    //  userState = userState | xboxlive.US_JOINABLE;
    userState = userState | xboxlive.US_PLAYING;
    xboxlive.SetUserState(xboxlive.GetCurrentUser(), userState);
    myRoot.CloseAll(true);
    myRoot.GotoState('');
  }
}


function ShowWindow()
{
     OnMenu = 0; myRoot.bFired = false;
     Super.ShowWindow();
     bShowBCK = false;
     bShowRUN = false;
     bShowSEL = false;
     myRoot.GetLevel().Game.ChangeName(GetPlayerOwner(), xboxlive.GetCurrentUser(), false);
}

function ProcessWait()
{
  local int msg, userState;
  if (xboxlive.SessionIsSubnetStarted())// && (GetPlayerOwner().Level.TimeSeconds - starttime)>2.0)
  {
  	Log("[XIIIMenuProfileClient] Subnet started...");
    WaitForStart = false;
    myRoot.CloseAll(true);
    myRoot.GotoState('');
    userState = xboxlive.US_ONLINE;
    if (xboxlive.HasUserVoice(xboxlive.GetCurrentUser()))
      userState = userState | xboxlive.US_VOICE;
    //if (!xboxlive.IsLadderGame())
    //  userState = userState | xboxlive.US_JOINABLE;
    userState = userState | xboxlive.US_PLAYING;
    xboxlive.SetUserState(xboxlive.GetCurrentUser(), userState);
  }
  else
  {
  }
}

function ProcessCreate()
{
  local int msg, userState;
  if (xboxlive.SessionIsCreateFinished())
  {
  	Log("[XIIIMenuProfileClient] Create finished...");
    WaitForCreate = false;
    //WaitForStart = true;
    //myRoot.CloseMenu(true);

    if (xboxlive.SessionStartSubnet())
    {
      Log("[XIIIMenuProfileClient] Starting subnet... "$fRatioX$" "$fRatioY$" "$fScaleTo);
      WaitForStart = true;
    }
    else
    {
      myRoot.CloseMenu(true);
      Log("[XIIIMenuProfileClient] Failed to start subnet...");
      msg = xboxlive.GetLastError();
      myRoot.OpenMenu("XIDInterf.XIIILiveMsgBox");
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(xboxlive.GetErrorString(msg), QBTN_Ok, QBTN_Ok);
      msgbox.OnButtonClick=MsgBoxBtnClicked;
      msgbox.InitBox(120*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 400*fRatioX, 230*fRatioY*fScaleTo);
    }
  }
  else
  {
  }
}

function Paint(Canvas C, float X, float Y)
{
  if (WaitForCreate)
    ProcessCreate();

  if (WaitForStart)
    ProcessWait();

  Super.Paint(C, X, Y);

  if (BackGround != none)
    PaintStandardBackground(C, X, Y, TitleText);
}

// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
  return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
  if (waitForStart)
    return true;

    if (state==1/* || state==2*/)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
          //Controller.FocusedControl.OnClick(Self);
          InternalOnClick(Controller.FocusedControl);
          return true;
	    }
	    if (Key==0x25/*IK_Left*/)
	    {
    	    return true;
	    }
	    if (Key==0x27/*IK_Right*/)
	    {
    	    return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



