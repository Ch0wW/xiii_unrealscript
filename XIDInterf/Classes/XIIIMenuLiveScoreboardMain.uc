class XIIIMenuLiveScoreboardMain extends XIIILiveWindow;

var string TitleText;

var XIIIGUIButton Buttons[4];
var localized string ButtonNames[4];
var localized string failedToResetString, sureResetStatsString, failedToGetStatsString, failedStatsUserNonexistant, failedFSYouhavenofriends;
var bool bProcessReset, bProcessUserStats, bProcessFriendsStats, bProcessOverallStats;

var localized string strTitle[5];

function Created()
{
  local int i;
  Super.Created();
}


function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  local int i;
  Super.InitComponent(MyController, MyOwner);
	OnClick = InternalOnClick;
	
	for (i=0; i<4; i++)
	{
  	Buttons[i] = XIIIGUIButton(Controls[i]);
  	Buttons[i].Caption = ButtonNames[i];
  }
}


function ShowWindow()
{
  OnMenu = 0; myRoot.bFired = false;
  Super.ShowWindow();
  bShowBCK = true;
  bShowRUN = false;
  bShowSEL = true;

  if (xboxlive.GetStatisticsType() == GT_DM)
  {
    TitleText = strTitle[0];
  }
  else if (xboxlive.GetStatisticsType() == GT_TeamDM)
  {
    TitleText = strTitle[1];
  }
  else if (xboxlive.GetStatisticsType() == GT_CTF)
  {
    TitleText = strTitle[2];
  }
  else if (xboxlive.GetStatisticsType() == GT_Sabotage)
  {
    TitleText = strTitle[3];
  }
  else if (xboxlive.GetStatisticsType() == GT_Ladder)
  {
    TitleText = strTitle[4];
  }
  else  // Must never happen!
    TitleText = "";

}

function ProcessReset()
{
  local int err;
  if (!xboxlive.StatsPumpReset())
  { // Finished or error
    err = xboxlive.GetLastError();
    myRoot.CloseMenu(true);
    bProcessReset = false;
    if (err != 0)
    {
      ShowErrorBox(failedToResetString);
    }
  }
}

function ProcessUserStats()
{
  local int err;
  if (!xboxlive.StatsPumpRequestUser())
  { // Finished or error
    err = xboxlive.GetLastError();
    myRoot.CloseMenu(true);
    bProcessUserStats = false;
    if (err != 0)
    {
      if(err == 112) //user doesn't exist
        ShowErrorBox(failedStatsUserNonexistant);
      else
        ShowErrorBox(failedToGetStatsString);
    }
    else
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveScoreboardView",false, "user");
  }
}

function ProcessFriendsStats()
{
  local int err;
  if (!xboxlive.StatsPumpRequestFriends())
  { // Finished or error
    err = xboxlive.GetLastError();
    myRoot.CloseMenu(true);
    bProcessFriendsStats = false;
    if (err != 0)
    {
      if(err == 131)
        ShowErrorBox(failedToGetStatsString);
      else
        ShowErrorBox(failedToGetStatsString);
    }
    else
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveScoreboardViewFriends",false);
  }
}

function ProcessOverallStats()
{
  local int err;
  if (!xboxlive.StatsPumpRequestOverall())
  { // Finished or error
    err = xboxlive.GetLastError();
    myRoot.CloseMenu(true);
    bProcessOverallStats = false;
    if (err != 0)
    {
      ShowErrorBox(failedToGetStatsString);
    }
    else
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveScoreboardView",false);
  }
}

function Paint(Canvas C, float X, float Y)
{
  Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);
  
  if(xboxlive.GetNumberOfFriends() == 0)
  {
    Buttons[2].bNeverFocus = true;
    Buttons[2].MenuState = MSAT_Disabled;
  }
  else
  {
    Buttons[2].bNeverFocus = false;
    if(Buttons[2].MenuState != MSAT_Watched && Buttons[2].MenuState != MSAT_Focused)
      Buttons[2].MenuState = MSAT_Blurry;
  }

  if (bProcessReset)
  {
    ProcessReset();
  }

  if (bProcessUserStats)
  {
    ProcessUserStats();
  }

  if (bProcessFriendsStats)
  {
    ProcessFriendsStats();
  }

  if (bProcessOverallStats)
  {
    ProcessOverallStats();
  }
}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    local int i;
    if (Sender == Buttons[0]) // USER
    {
      if (!xboxlive.StatsRequestUser(0,20))
      {
        ShowErrorBox(failedToGetStatsString);
      }
      else
      {
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(pleaseWaitString, QBTN_Cancel, QBTN_Cancel);
        msgbox.OnButtonClick=ResetUserStatsMsgBoxClicked;
        msgbox.InitBox(160, 130, 16, 16, 320, 230);
        bProcessUserStats = true;
      }
    }
    else if (Sender == Buttons[1]) // OVERALL
    {
      if (!xboxlive.StatsRequestOverall(0,20))
      {
        ShowErrorBox(failedToGetStatsString);
      }
      else
      {
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(pleaseWaitString, QBTN_Cancel, QBTN_Cancel);
        msgbox.OnButtonClick=ResetOverallStatsMsgBoxClicked;
        msgbox.InitBox(160, 130, 16, 16, 320, 230);
        bProcessOverallStats = true;
      }
    }
    else if (Sender == Buttons[2]) // FRIENDS
    {
      if (!xboxlive.StatsRequestFriends(0,20))
      {
        ShowErrorBox(failedToGetStatsString);
      }
      else
      {
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(pleaseWaitString, QBTN_Cancel, QBTN_Cancel);
        msgbox.OnButtonClick=ResetFriendsStatsMsgBoxClicked;
        msgbox.InitBox(160, 130, 16, 16, 320, 230);
        bProcessFriendsStats = true;
      }
    }
    else if (Sender == Buttons[3]) // RESET
    { // Reset
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(sureResetStatsString, QBTN_Ok|QBTN_Cancel, QBTN_Cancel);
      msgbox.OnButtonClick=SureMsgBoxClicked;
      msgbox.InitBox(160, 130, 16, 16, 320, 230);
    }
    return true;
}

function SureMsgBoxClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
      if (!xboxlive.StatsReset())
      {
        ShowErrorBox(failedToResetString);
        return;
      }
      else
      {
        Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
        msgbox = XIIILiveMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(pleaseWaitString, QBTN_Cancel, QBTN_Cancel);
        msgbox.OnButtonClick=ResetWaitMsgBoxClicked;
        msgbox.InitBox(160, 130, 16, 16, 320, 230);
        bProcessReset = true;
        return;
      }
    break;
  }
}

function ResetUserStatsMsgBoxClicked(byte bButton)
{
  xboxlive.StatsCancelRequestUser();
  bProcessUserStats = false;
}

function ResetOverallStatsMsgBoxClicked(byte bButton)
{
  xboxlive.StatsCancelRequestOverall();
  bProcessOverallStats = false;
}

function ResetFriendsStatsMsgBoxClicked(byte bButton)
{
  xboxlive.StatsCancelRequestFriends();
  bProcessFriendsStats = false;
}


function ResetWaitMsgBoxClicked(byte bButton)
{
  xboxlive.StatsCancelReset();
  bProcessReset = false;
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




