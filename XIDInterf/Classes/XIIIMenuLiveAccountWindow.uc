class XIIIMenuLiveAccountWindow extends XIIILiveWindow;

var XIIIGUIMultiListBox listbox;

var localized string newAccountString, TitleText, failedToLoginString, newAccountString2, areYouSureString;
var string AutoLoginUser;
var bool AutoLoginNotNow;

function Created()
{
  local int i;
     Super.Created();
   bCheckNetworkCable=false;
   if (xboxlive == none)
	   xboxlive=New Class'XboxLiveManager';
    xboxlive.ShutdownAndCleanup();
}


function FindAccounts()
{
  local int accountCount,q,oldindex;
  local string temp;
  accountCount = xboxlive.GetNumberOfAccounts();

  oldindex = listbox.list.index;
    listbox.list.clear();

    for (q=0; q<accountCount; q++)
    {
     temp = xboxlive.GetAccountName(q);
     listbox.list.Add(temp);
    }
    listbox.list.Add(newAccountString);

    if (oldindex < listbox.list.elements.length)
      listbox.list.index = oldindex;
}


function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  local int numberOfAccounts;

  Super.InitComponent(MyController, MyOwner);
     listbox = XIIIGUIMultiListBox(Controls[0]);

     FindAccounts();
     listbox.bVisibleWhenEmpty = true;
     listbox.SetColumnAlignment(0, 1);
  if (xboxlive.IsJoiningAfterBoot())
  {
    if (!LoginUser(xboxlive.GetUserInvitedAfterBoot()))
    {
    }
  }
}


function ShowWindow()
{
     OnMenu = 0; myRoot.bFired = false;
     Super.ShowWindow();
     bShowBCK = true;
     bShowRUN = false;
     bShowSEL = true;
}

function Update()
{
  if (xboxlive.IsAccountListUpdated())
  {
     FindAccounts();
  }
}


function Paint(Canvas C, float X, float Y)
{
  if (myRoot.ActivePage == self)
  {
    Update();

    if (!AutoLoginNotNow && AutoLoginUser != "")
    {
      LoginUser(AutoLoginUser);
      AutoLoginUser = "";
    }
  }

  Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);
}


// Called when a button is clicked
/*
function bool InternalOnClick(GUIComponent Sender)
{
    local int i;
    if (Sender == NewButton) {
      Controller.OpenMenu("XIDInterf.XIIIMenuDifficultyWindow");
    XIIIMenuDifficultyWindow(myRoot.ActivePage).bLoad = true;
    XIIIMenuDifficultyWindow(myRoot.ActivePage).bNewGame = true;
//      for (i=0; i<myRoot.MenuStack.Length; i++)
//        log(i$": "$myRoot.MenuStack[i]);
    }
    if (Sender == LoadButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuLoadGameWindow");
    if (Sender == OptionsButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuOptions");
    if (Sender == MultiButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuSplitSetupClient");
    if (Sender == WorkButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuChooseMap");
    if (Sender == LiveButton)
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveAccountWindow");
    return true;
}
*/

function MsgBoxBtnClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Yes:
      xboxlive.ShutdownAndCleanup();
	    myRoot.CloseMenu(true);
	    xboxlive.RebootToDashboard(xboxlive.dashboardPage.DASHBOARD_ACCOUNT_CREATION);
    break;
    case QBTN_No:
    break;
  }
}

function bool LoginUser(string username)
{
  local int msg;
  if (AutoLoginUser!="" || !xboxlive.HasPasscode(username))
  {
    xboxlive.SetCurrentUser(username);
    //if (xboxlive.StartLogin(xboxlive.GetCurrentUser()))
    //{
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveLoginWait");
    //}
    /*else
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
        msgbox.SetupQuestion(failedToLoginString, QBTN_Ok, QBTN_Ok);
        msgbox.OnButtonClick=MsgBoxBtnClicked;
      }
      msgbox.InitBox(120, 130, 16, 16, 400, 230);
      return false;
    }*/
  }
  else
  {
    xboxlive.SetCurrentUser(username);
    Controller.OpenMenu("XIDInterf.XIIIMenuLivePassword");
  }
  return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
  local int msg;
    if (state==1/* || state==2*/)// IST_Press // to avoid auto-repeat
    {
      if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
	      if (listbox.list.SelectedText() == newAccountString)
	      {
          Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
          msgbox = XIIILiveMsgBox(myRoot.ActivePage);
          msgbox.SetupQuestion(areYouSureString, QBTN_Yes|QBTN_No, QBTN_No, newAccountString2);
          msgbox.OnButtonClick=MsgBoxBtnClicked;
          msgbox.InitBox(120, 130, 16, 16, 400, 230);
          //xboxlive.ShutdownAndCleanup();
    	    //myRoot.CloseMenu(true);
          //Controller.OpenMenu("XIDInterf.XIIIMenuLiveAccountWindow",true);
	      }
        else
        {
          LoginUser(listbox.list.SelectedText());
        }
        return true;
      }
	    if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
	    {
	        xboxlive.ShutdownAndCleanup();
	        myRoot.CloseMenu(true);
    	    return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}

// if subclassed, this parent function must always be called first
function string GetPageParameters()
{
    return Super.GetPageParameters()$"?AutoLoginUser="$AutoLoginUser;
}

// if GetPageParameters() is subclassed, you'd better have this one too !
function SetPageParameters(string PageParameters)
{
    log("SetPageParameters("$PageParameters$") called for "$self);

    AutoLoginUser = (localParseOption(PageParameters, "AutoLoginUser", ""));
}


