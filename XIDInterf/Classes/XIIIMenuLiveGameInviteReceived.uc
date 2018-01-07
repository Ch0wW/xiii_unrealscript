class XIIIMenuLiveGameInviteReceived extends XIIILiveWindow;

var localized string TitleText;

var XIIIGUIButton Buttons[3];
var GUILabel  playlabel, gamelabel;
var localized string ButtonNames[3], playlabelstring;
var localized string strInviteReceived,strAcceptGameInviteQuestion,strDeclineGameInviteQuestion,strRemoveFriendQuestion,strLeaving,strNoSession;

var XboxLiveManager.FRIEND_PACKET activeFriend;
var string                        activeFriendName;

var XIIILiveMsgBox msgbox;
var int popupStatus;

var localized string pleaseInsertGameString;

var bool waitForUserToReboot;


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
	Buttons[2].Caption = ButtonNames[2];
	playlabel = GUILabel(Controls[3]);
	gamelabel = GUILabel(Controls[4]);
  activeFriend = xboxlive.GetActiveFriend();
  activeFriendName = xboxlive.GetActiveFriendName();
	playlabel.Caption  = playlabelstring;
	gamelabel.Caption = xboxlive.GetFriendGameName(activeFriendName);

	OnClick = InternalOnClick;
}


function ShowWindow()
{
  OnMenu = 0; myRoot.bFired = false;
  Super.ShowWindow();
  bShowBCK = true;
  bShowRUN = false;
  bShowSEL = true;

  activeFriend = xboxlive.GetActiveFriend();
  TitleText = activeFriendName $ strInviteReceived;

/*  if (xboxlive.IsPlaying())
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
*/

}


function Paint(Canvas C, float X, float Y)
{
  //if (waitForUserToReboot)
  //{
  //}

  Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);

	//C.WrapStringToArray(playlabelstring$xboxlive.GetFriendGameName(activeFriendName);, MsgArray, lMessage.ActualWidth(), "|");


}

function MsgBoxBtnClicked(byte bButton)
{
  waitForUserToReboot = false;
  myRoot.CloseMenu(true);
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
          activeFriend = xboxlive.GetActiveFriend();
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
      else if (popupStatus == 2)
      {
        xboxlive.DeclineGameInvite(activeFriendName);
        myRoot.CloseMenu(true);
      }
      else if (popupStatus == 3)
      {
        xboxlive.RemoveFriend(activeFriendName);
        myRoot.CloseMenu(true);
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
    { // accept game invite
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      if (xboxlive.IsIngame())
        msgbox.SetupQuestion(strLeaving$" "$strAcceptGameInviteQuestion, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activeFriendName);
      else
        msgbox.SetupQuestion(strAcceptGameInviteQuestion, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activeFriendName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);

      popupStatus=1;
      return true;
    }
    else if (Sender == Controls[1])
    {  // decline game invite
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(strDeclineGameInviteQuestion, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activeFriendName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);

      popupStatus=2;
      return true;
    }
    else if (Sender == Controls[2])
    {
      // remove friend
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(strRemoveFriendQuestion, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activeFriendName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);

      popupStatus=3;
      return true;
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



