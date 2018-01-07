class XIIIMenuLiveOldPlayerMenuSelectedGamerTagNothing extends XIIILiveWindow;

var localized string TitleText;

var XIIIGUIButton Buttons[2];
var localized string ButtonNames[2];
var localized string strTitle, strSendFriendRequestQuestion;

var XboxLiveManager.FRIEND_PACKET activeFriend;
var string                        activeFriendName;

var XIIILiveMsgBox msgbox;
var int popupStatus;

enum eVoiceStatus
{
  VOICESTATUS_voiceon,
  VOICESTATUS_voicemuted,
  VOICESTATUS_voicetv,
  VOICESTATUS_voicenone,
};



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
  activeFriendName = xboxlive.GetActiveFriendName();
  TitleText = activeFriendName;
}


function Paint(Canvas C, float X, float Y)
{
     Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);
}

function ReturnMsgBox(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
      if (popupStatus == 1)
      {
        xboxlive.SendFriendRequest(activeFriendName);
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
    if (Sender == Controls[0])
    { // send friend request
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(strSendFriendRequestQuestion, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activeFriendName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
      popupStatus = 1;
      return true;
    }
    else if (Sender == Controls[1])
    {
      // send feedback
      myRoot.OpenMenu("XIDInterf.XIIIMenuLiveFeedback");
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



