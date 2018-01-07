class XIIIMenuLiveJoinFriendWindow extends XIIILiveWindow;

var localized string TitleText, failedToFindSessionString, failedToJoinSessionString, sameSessionString;

var bool UpdateMe;
var bool ConnectingToGame;
var float starttime;

var int BackFromJoin;
var bool BackFromJoinNotNow;
var string AutoLoginName;


function Created()
{
  Super.Created();
}

function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  local int numberOfAccounts;
  local int i, msg;

  Super.InitComponent(MyController, MyOwner);

	OnClick = InternalOnClick;
	
	if (!xboxlive.IsLoggedIn(xboxlive.GetCurrentUser()))
	  return;
	
	if (xboxlive.IsJoiningAfterBoot() && !xboxlive.FriendFindSession(xboxlive.GetFriendInviterAfterBoot()))
  { // Failed to find friend session
    // Show error in messagebox
    //msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(failedToFindSessionString, QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
    msgbox.InitBox(120, 130, 16, 16, 400, 230);
  }
  else if (xboxlive.FriendIsInSameSession(xboxlive.GetActiveFriendName()))
  { // Friend is considered to be in same session already
    // Show error in messagebox
    //msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(sameSessionString, QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
    msgbox.InitBox(120, 130, 16, 16, 400, 230);
  }
  else if (!xboxlive.IsJoiningAfterBoot() && !xboxlive.FriendFindSession(xboxlive.GetActiveFriendName()))
  { // Failed to find friend session
    // Show error in messagebox
    //msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(failedToFindSessionString, QBTN_Ok, QBTN_Ok);
    msgbox.OnButtonClick=MsgBoxBtnClicked;
    msgbox.InitBox(120, 130, 16, 16, 400, 230);
  }
  else
  {
    Log("Trying to find friend session...");
    UpdateMe = true;
  }
  xboxlive.ResetJoiningAfterBoot();
}

function ShowWindow()
{
     OnMenu = 0; myRoot.bFired = false;
     Super.ShowWindow();
     bShowBCK = true;
     bShowRUN = false;
     bShowSEL = false;
}

function Process()
{
  local int msg;
  if (!xboxlive.FriendFindIsFinished())
  { // Not finished or failed?
    msg = xboxlive.GetLastError();
    if (msg != 0 && msg != 130)
    { // Failed!
      UpdateMe = false;
      // Show error in messagebox
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(failedToJoinSessionString, QBTN_Ok, QBTN_Ok);
      msgbox.OnButtonClick=MsgBoxBtnClicked;
      msgbox.InitBox(120*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 400*fRatioX, 230*fRatioY*fScaleTo);
    }
  }
  else
  { // Finished!!
    Log("Found friend session!!");
    if (!xboxlive.FriendJoinSession())
    { // Failed to join friends session
      // Show error in messagebox
      msg = xboxlive.GetLastError();
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(failedToFindSessionString, QBTN_Ok, QBTN_Ok);
      msgbox.OnButtonClick=MsgBoxBtnClicked;
      msgbox.InitBox(120*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 400*fRatioX, 230*fRatioY*fScaleTo);
    }
    UpdateMe = false;

    Log("Trying to join friend session!!");
    starttime = GetPlayerOwner().Level.TimeSeconds;
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(pleaseWaitString, 0, 0, "Connecting");
    msgbox.OnButtonClick=MsgBoxBtnClicked;
    msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
    ConnectingToGame = true;
  }
}

function ProcessConnect()
{
  local int msg;
  local string URL;
  local XIIIMenuLiveJoinMsgBox JoinMsgbox;
  local string MyClass, SkinCode;
	local int i;

  if (xboxlive.FriendJoinIsFinished() /*&& (GetPlayerOwner().Level.TimeSeconds - starttime)>2.0*/)
  {
    Log("Joined friend session!!");
    ConnectingToGame = false;
    // Connect to URL
    URL = xboxlive.FriendJoinGetURL();
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

    // Error!
    myRoot.CloseMenu(true);
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    msgbox.SetupQuestion(failedToJoinSessionString, QBTN_Ok, QBTN_Ok);
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
    while (XIIIMenuLiveAccountWindow(myRoot.ActivePage)==none)
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
  if (UpdateMe)
    Process();

  if (ConnectingToGame)
    ProcessConnect();

  Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);
}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    local int i,sel,msg;
    if (ConnectingToGame)
      return true;

/*
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
	    myRoot.CloseMenu(true);
      /*log("[XIIILiveMsgBox] Ok pressed");
      xboxlive.ShutdownAndCleanup();
	    myRoot.CloseMenu(true);
      Controller.ReplaceMenu("XIDInterf.XIIIMenuLiveAccountWindow");
      */
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
	        //xboxlive.QuickmatchCancelQuery();
	        myRoot.CloseMenu(true);
    	    return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



