class XIIIMenuLiveFriendsOnline extends XIIILiveWindow;

var localized string TitleText;

var XIIIGUIButton Buttons[3];
var localized string ButtonNames[4];
var localized string strOnline, strAcceptGameInviteQuestion, strJoinFriend, strRemoveFriendQuestion, strSendGameInviteQuestion, strLeaving, strNoSession;
var bool acceptinvite;
var XboxLiveManager.FRIEND_PACKET activeFriend;
var string                        activeFriendName;

var localized string pleaseInsertGameString;

var bool waitForUserToReboot;

var XIIILiveMsgBox msgbox;
var int popupStatus;

function Created()
{
  local int i;
     Super.Created();

}


function InitComponent(GUIController MyController,GUIComponent MyOwner)
{

  Super.InitComponent(MyController, MyOwner);

	Buttons[0] = XIIIGUIButton(Controls[0]);
	Buttons[0].Caption = ButtonNames[0];
	Buttons[1] = XIIIGUIButton(Controls[1]);
	Buttons[1].Caption = ButtonNames[1];
	Buttons[2] = XIIIGUIButton(Controls[2]);
	Buttons[2].Caption = "";//ButtonNames[2];

	OnClick = InternalOnClick;

}


function ShowWindow()
{
  local bool insamesession;

  OnMenu = 0; myRoot.bFired = false;
  Super.ShowWindow();
  bShowBCK = true;
  bShowRUN = false;
  bShowSEL = true;

  activeFriend = xboxlive.GetActiveFriend();
  activeFriendName = xboxlive.GetActiveFriendName();

  TitleText = activeFriendName $ " - " $ strOnline;

//  ButtonNames(0)="Send a game invitation"
//  ButtonNames(1)="Remove friend"
//  ButtonNames(2)="Join"

  insamesession = xboxlive.IsInSameSession(activeFriendName);
  if ( (activeFriend.onlineStatusFlags & xboxlive.XONLINE_FRIENDSTATE_FLAG_RECEIVEDINVITE) != 0 && !insamesession)
  {
    Buttons[2].bVisible=true;
    Buttons[2].Caption = ButtonNames[3];
  }
  else if ( (activeFriend.onlineStatusFlags & xboxlive.XONLINE_FRIENDSTATE_FLAG_JOINABLE) != 0 && !insamesession)
  {
    Buttons[2].bVisible=true;
    Buttons[2].Caption = ButtonNames[2];
  }
  else
    Buttons[2].bVisible=false;


  if (xboxlive.IsPlaying() && !insamesession && !xboxlive.IsLadderGame())
  {
    Buttons[0].bVisible=true;
    SetFocus(Buttons[0]);
    Buttons[0].SetFocus(none);
  }
  else
  {
    Buttons[0].bVisible=false;
    SetFocus(Buttons[1]);
    Buttons[1].SetFocus(none);
  }

}


function Paint(Canvas C, float X, float Y)
{
     Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);
}

function MsgBoxBtnClicked(byte bButton)
{
  waitForUserToReboot = false;
}

function MsgBoxBtnClicked2(byte bButton)
{
  myRoot.CloseMenu(true);
}

function ReturnMsgBox(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
      if (popupStatus == 1)
      {
        xboxlive.SendGameInvite(activeFriendName);
        myRoot.CloseMenu(true);
      }
      else if (popupStatus == 2)
      {
        xboxlive.RemoveFriend(activeFriendName);
        myRoot.CloseMenu(true);
      }
      else if (popupStatus == 3)
      {
        //
        if (acceptinvite)
        {
          xboxlive.AcceptGameInvite(activeFriendName);

          if (xboxlive.FriendIsInSameGame(activeFriendName))
          {
            Controller.OpenMenu("XIDInterf.XIIIMenuLiveJoinFriendWindow", true);
          }
          else if (xboxlive.GetFriendGameName(activeFriendName) != "")
          {
            waitForUserToReboot = true;
            //myRoot.CloseMenu(true);
            Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
            msgbox = XIIILiveMsgBox(myRoot.ActivePage);
            msgbox.SetupQuestion(xboxlive.GetFriendGameName(activeFriendName), QBTN_Cancel, QBTN_Cancel, pleaseInsertGameString);
            msgbox.OnButtonClick=MsgBoxBtnClicked;
            msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
          }
          else // Session no longer valid
          {
            msgbox = XIIILiveMsgBox(myRoot.ActivePage);
            msgbox.SetupQuestion(strNoSession, QBTN_Ok, QBTN_Ok);
            msgbox.OnButtonClick=MsgBoxBtnClicked2;
            msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
          }
        }
        else
        {
          if (xboxlive.FriendIsInSameGame(activeFriendName))
          {
          Controller.OpenMenu("XIDInterf.XIIIMenuLiveJoinFriendWindow",true);
      }
          else if (xboxlive.GetFriendGameName(activeFriendName) != "")
          {
            waitForUserToReboot = true;
            //myRoot.CloseMenu(true);
            Controller.OpenMenu("XIDInterf.XIIILiveMsgBox");
            msgbox = XIIILiveMsgBox(myRoot.ActivePage);
            msgbox.SetupQuestion(xboxlive.GetFriendGameName(activeFriendName), QBTN_Cancel, QBTN_Cancel, pleaseInsertGameString);
            msgbox.OnButtonClick=MsgBoxBtnClicked;
            msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
          }
          else // Session is no longer valid
          {
            msgbox = XIIILiveMsgBox(myRoot.ActivePage);
            msgbox.SetupQuestion(strNoSession, QBTN_Ok, QBTN_Ok);
            msgbox.OnButtonClick=MsgBoxBtnClicked2;
            msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
          }
          
        }
      }
      popupStatus = 0;
      return;
    break;

    case QBTN_Cancel:
      popupStatus = 0;
    break;

  }
}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    local int i;

  if (waitForUserToReboot)
    return true;

    if (Sender == Controls[0])
    {
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(strSendGameInviteQuestion, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activeFriendName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
      popupStatus=1;

      return true;
      //Controller.OpenMenu("XIDInterf.XIIIMenuLiveJoinStartWindow");
    }
    else if (Sender == Controls[1])
    {
      // remove friend
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(strRemoveFriendQuestion, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activeFriendName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
      popupStatus=2;
//      xboxlive.RemoveFriend(activeFriendName);
//      myRoot.CloseMenu(true);
      return true;
    }
    else if (Sender == Controls[2])
    { // Accept game invite or join
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);

      if ( (activeFriend.onlineStatusFlags & xboxlive.XONLINE_FRIENDSTATE_FLAG_RECEIVEDINVITE) != 0 )
      {
        if (xboxlive.IsIngame())
          msgbox.SetupQuestion(strLeaving$" "$strAcceptGameInviteQuestion, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activeFriendName);
        else
          msgbox.SetupQuestion(strAcceptGameInviteQuestion, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activeFriendName);
        acceptinvite = true;
      }
      else
      {
        if (xboxlive.IsIngame())
          msgbox.SetupQuestion(strLeaving$" "$strJoinFriend, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activeFriendName);
        else
          msgbox.SetupQuestion(strJoinFriend, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activeFriendName);
        acceptinvite = false;
      }
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
      popupStatus=3;
      return true;
      //Controller.OpenMenu("XIDInterf.XIIIMenuLiveFriendsMainPage");
    }

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



