class XIIIMenuLiveLoginWait extends XIIILiveWindow;

var localized string TitleText;

var bool loggingIn;
var bool mustUpdateXBE, mustManageAccount, mustLookAtMessage;
var localized string failedToLoginString, strMustUpdateXBE, strManageAccount, strLookAtMessage, serverBusyString, strInvalidUser;

var XIIILiveMsgBox waitbox;
var int popupStatus;


function Created()
{
  local int i;
     Super.Created();

   OnReOpen = InternalOnOpen;
	//bRequiresTick=On;
}


function Process()
{
  local int userState;
  local int errorCode;

  if (xboxlive != none)
  {
    if (xboxlive.IsLoggedIn(xboxlive.GetCurrentUser()))
    {
      if (waitbox != none)
      {
        myRoot.CloseMenu(true);
        waitbox = none;
      }
      userState = xboxlive.US_ONLINE;
      //if (xboxlive.HasUserVoice(xboxlive.GetCurrentUser()))
      //  userState = userState | xboxlive.US_VOICE;
      xboxlive.SetUserState(xboxlive.GetCurrentUser(), userState);

      if (xboxlive.IsJoiningAfterBoot())
      {
        xboxlive.SetActiveFriend(xboxlive.GetFriendInviterAfterBoot());
        Controller.OpenMenu("XIDInterf.XIIIMenuLiveMainWindow",true);
        Controller.OpenMenu("XIDInterf.XIIIMenuLiveJoinFriendWindow");
      }
      else
      {
        Controller.OpenMenu("XIDInterf.XIIIMenuLiveMainWindow",true);
      }
    }
    else
    {    //native static final function bool          BootToUpdateXBE();
      if (xboxlive.ErrorLoggingIn(xboxlive.GetCurrentUser()))
      {
        if (waitbox != none)
        {
          myRoot.CloseMenu(true);
          waitbox = none;
        }
        fRatioY  = 1.0;
        fScaleTo = 1.0;
        fRatioX  = 1.0;
        errorCode = xboxlive.GetLastError();
        if (errorCode == 20) // DAMN script language! XBLE_LOGON_UPDATE_REQUIRED)
        {
          mustUpdateXBE = true;
          loggingIn = false;

          Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
          msgbox = XIIILiveMsgBox(myRoot.ActivePage);
          msgbox.SetupQuestion(strMustUpdateXBE, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, "");
          msgbox.OnButtonClick=ReturnMsgBox;
          msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
          popupStatus = 1;
        }

        else if (errorCode == 21) // DAMN script language! XBLE_LOGON_SERVERS_TOO_BUSY)
        {
          Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
          msgbox = XIIILiveMsgBox(myRoot.ActivePage);
          msgbox.SetupQuestion(serverBusyString, QBTN_Ok|QBTN_Cancel, QBTN_Ok);
          msgbox.OnButtonClick=MsgBoxRetryBtnClicked;
          msgbox.InitBox(120, 130, 16, 16, 400, 230);
          popupStatus = 2;
        }
        
        else if (errorCode == 24) // DAMN script language! XBLE_LOGON_INVALID_USER)
        {
          mustManageAccount = true;
          loggingIn = false;

          Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
          msgbox = XIIILiveMsgBox(myRoot.ActivePage);
          msgbox.SetupQuestion(strInvalidUser, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, "");
          msgbox.OnButtonClick=ReturnMsgBox;
          msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
          popupStatus = 2;
        }
        
        else if (errorCode == 32) // DAMN script language! XBLE_LOGON_USER_ACCOUNT_REQUIRES_MANAGEMENT)
        {
          mustManageAccount = true;
          loggingIn = false;

          Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
          msgbox = XIIILiveMsgBox(myRoot.ActivePage);
          msgbox.SetupQuestion(strManageAccount, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, "");
          msgbox.OnButtonClick=ReturnMsgBox;
          msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
          popupStatus = 2;
        }

        else if (errorCode == 31) // DAMN script language! XBLE_LOGON_USER_HAS_MESSAGE)
        {
          mustLookAtMessage = true;
          loggingIn = false;

          Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
          msgbox = XIIILiveMsgBox(myRoot.ActivePage);
          msgbox.SetupQuestion(strLookAtMessage, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, "");
          msgbox.OnButtonClick=ReturnMsgBox;
          msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
          popupStatus = 3;
        }

        else
        {
          loggingIn = false;
          /*Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
          msgbox = XIIILiveMsgBox(myRoot.ActivePage);
          msgbox.SetupQuestion(failedToLoginString, QBTN_Ok, QBTN_Ok);
          msgbox.OnButtonClick=MsgBoxBtnClicked;
          msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
          */
          Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
          msgbox = XIIILiveMsgBox(myRoot.ActivePage);
          msgbox.SetupQuestion(networkTroubleShoot, QBTN_Ok | QBTN_Cancel, QBTN_Cancel);
          msgbox.OnButtonClick=MsgBoxClickedTroubleshooting;
          msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
        }
      }
        }
      }
    }

function MsgBoxClickedTroubleshooting(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
        xboxlive.RebootToDashboard(xboxlive.dashboardPage.DASHBOARD_NETWORK_CONFIG);
        myRoot.CloseMenu(true);
    break;

    case QBTN_Cancel:
      xboxlive.ShutdownAndCleanup();
      myRoot.CloseMenu(true);
    break;
  }
}

function MsgBoxBtnClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
      xboxlive.ShutdownAndCleanup();
	    myRoot.CloseMenu(true);
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveAccountWindow",true);
      xboxlive.GetNumberOfAccounts();
    break;
  }
  //log("msgbox clicked: "$bButton);
}

function MsgBoxRetryBtnClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
      LoginUser();
    break;
    case QBTN_Cancel:
      xboxlive.ShutdownAndCleanup();
	    myRoot.CloseMenu(true);
	    myRoot.CloseMenu(true);
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveAccountWindow",true);
    break;
  }
}

function WaitBoxBtnClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Cancel:
      xboxlive.ShutdownAndCleanup();
	    myRoot.CloseMenu(true);
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveAccountWindow",true);
      xboxlive.GetNumberOfAccounts();
    break;
  }
  //log("msgbox clicked: "$bButton);
}

function LoginUser()
{
  local int msg;
  //Controller.CloseMenu(true);
  if (!xboxlive.StartLogin(xboxlive.GetCurrentUser()))
  {
    msg = xboxlive.GetLastError();
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
    msgbox = XIIILiveMsgBox(myRoot.ActivePage);
    if (msg == 21) // XBLE_LOGON_SERVERS_TOO_BUSY
    {
      msgbox.SetupQuestion(serverBusyString, QBTN_Ok|QBTN_Cancel, QBTN_Ok);
      msgbox.OnButtonClick=MsgBoxRetryBtnClicked;
    }
    else
    {
      myRoot.CloseMenu(true);
      //msgbox.SetupQuestion(failedToLoginString, QBTN_Ok, QBTN_Ok);
      //msgbox.OnButtonClick=MsgBoxBtnClicked;
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(networkTroubleShoot, QBTN_Ok | QBTN_Cancel, QBTN_Cancel);
      msgbox.OnButtonClick=MsgBoxClickedTroubleshooting;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
    }
    msgbox.InitBox(120, 130, 16, 16, 400, 230);
  }
  else
  {
    //Controller.OpenMenu("XIDInterf.XIIIMenuLiveLoginWait");
    Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
    waitbox = XIIILiveMsgBox(myRoot.ActivePage);
    waitbox.ShowWorking=true;
    waitbox.SetupQuestion(pleaseWaitString, QBTN_Cancel, QBTN_Cancel, "");
    waitbox.InitBox(160, 130, 16, 16, 320, 230);
    waitbox.OnButtonClick=WaitBoxBtnClicked;
  }
}

function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  local int msg;
  Super.InitComponent(MyController, MyOwner);
	OnClick = InternalOnClick;

  LoginUser();
}

function ShowWindow()
{
     OnMenu = 0; myRoot.bFired = false;
     Super.ShowWindow();
     bShowBCK = true;
     bShowRUN = false;
     bShowSEL = false;
}


function Paint(Canvas C, float X, float Y)
{
  if (myRoot.ActivePage == waitbox && loggingIn)
    Process();

  Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);
}

function ReturnMsgBox(byte bButton)
{
  local int userState;

  switch (bButton)
  {
    case QBTN_Ok:
      if (popupStatus == 1)
      {
        xboxlive.BootToUpdateXBE();
        myRoot.CloseMenu(true);
      }
      else if (popupStatus == 2)
      {
        xboxlive.RebootToDashboard(xboxlive.dashboardPage.DASHBOARD_ACCOUNT_MANAGEMENT);
        myRoot.CloseMenu(true);
      }
      else if (popupStatus == 3)
      {
        xboxlive.RebootToDashboard(xboxlive.dashboardPage.DASHBOARD_MESSAGES);
        myRoot.CloseMenu(true);
      }
      popupStatus = 0;
      return;
    break;
    case QBTN_Cancel:    // the cancel is the same for both mustManageAccount and mustUpdateXBE
      if (popupStatus == 3)
      {

        userState = xboxlive.US_ONLINE;
        //if (xboxlive.HasUserVoice(xboxlive.GetCurrentUser()))
        //  userState = userState | xboxlive.US_VOICE;
        xboxlive.SetUserState(xboxlive.GetCurrentUser(), userState);
        Controller.OpenMenu("XIDInterf.XIIIMenuLiveMainWindow",true);

      }
      else
      {
        loggingIn = false;
        mustManageAccount = false;
        mustUpdateXBE = false;
        while (XIIIMenu(MyRoot.ActivePage) == none)
          myRoot.CloseMenu(true);
      }

    popupStatus = 0;
    break;

  }
}

// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
  /*
    local int i;
    if (Sender == Controls[0])
    {
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveJoinStartWindow");
    }
    return true;
    */
    return true;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
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
	        xboxlive.ShutdownAndCleanup();
	        myRoot.CloseMenu(true);
	        myRoot.CloseMenu(true);
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



