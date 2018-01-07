class XIIIMenuLiveFeedback extends XIIILiveWindow;


enum XBL_FEEDBACK
{
  unrealscriptsuckscanthaveelementstartingonone,
	NEG_NICKNAME,
	NEG_GAMEPLAY,
	NEG_SCREAMING,
	NEG_HARASSMENT,
	NEG_LEWDNESS,
	NEG_STATS_ATTACHMENT,

	POS_ATTITUDE,
	POS_SESSION,
	POS_STATS_ATTACHMENT
};


var localized string TitleText, strFeedback1, strFeedback2, strFeedback3, strFeedback4, strFeedback5, strFeedback6, strFeedback7;

var XIIIGUIButton Buttons[7];
var localized string ButtonNames[7];
//var localized string strFeedback, strComplaints;

var GUILabel Labels[2];
var localized string LabelNames[2];

var XIIILiveMsgBox msgbox;
var int popupStatus;



var XboxLiveManager.FRIEND_PACKET activePlayer;
var string                        activePlayerName;



function Created()
{
  local int i;
     Super.Created();


  Labels[0] = GUILabel(CreateControl(class'GUILabel', 300, 90, 150, 26));
  Labels[0].caption = LabelNames[0];
  Labels[0].StyleName="LabelWhite";
  Labels[0].TextColor.R=255;
  Labels[0].TextColor.G=255;
  Labels[0].TextColor.B=255;
  controls[7] = Labels[0];
  Labels[1] = GUILabel(CreateControl(class'GUILabel', 300, 195, 350, 26));
  Labels[1].caption = LabelNames[1];
  Labels[1].StyleName="LabelWhite";
  Labels[1].TextColor.R=255;
  Labels[1].TextColor.G=255;
  Labels[1].TextColor.B=255;
  controls[8] = Labels[1];


}


function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  local int i;
  Super.InitComponent(MyController, MyOwner);

  for (i=0; i<7; i++)
  {
	  Buttons[i] = XIIIGUIButton(Controls[i]);
	  Buttons[i].Caption = ButtonNames[i];
  }

	OnClick = InternalOnClick;
}


function ShowWindow()
{
  OnMenu = 0; myRoot.bFired = false;
  Super.ShowWindow();
  bShowBCK = true;
  bShowRUN = false;
  bShowSEL = true;

  activePlayer = xboxlive.GetActiveFriend();
  activePlayerName = xboxlive.GetActiveFriendName();
  TitleText = activePlayerName $ " - " $ LabelNames[0];

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
        xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.POS_ATTITUDE);
        myRoot.CloseMenu(true);
      }
      else if (popupStatus == 2)
      {
        xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.POS_SESSION);
        myRoot.CloseMenu(true);
      }
      else if (popupStatus == 3)
      {
        xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.NEG_NICKNAME);
        myRoot.CloseMenu(true);
      }
      else if (popupStatus == 4)
      {
        xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.NEG_GAMEPLAY);
        myRoot.CloseMenu(true);
      }
      else if (popupStatus == 5)
      {
        xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.NEG_SCREAMING);
        myRoot.CloseMenu(true);
      }
      else if (popupStatus == 6)
      {
        xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.NEG_HARASSMENT);
        myRoot.CloseMenu(true);
      }
      else if (popupStatus == 7)
      {
        xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.NEG_LEWDNESS);
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
    // GOOD ONES
    if (Sender == Controls[0])
    {
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(strFeedback1, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activePlayerName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);

      popupStatus = 1;
//      xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.POS_ATTITUDE);
//      myRoot.CloseMenu(true);
      return true;
    }
    else if (Sender == Controls[1])
    {
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(strFeedback2, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activePlayerName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);

      popupStatus = 2;
//      xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.POS_SESSION);
//      myRoot.CloseMenu(true);
      return true;
    }
    // BAD ONES
    else if (Sender == Controls[2])
    {
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(strFeedback3, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activePlayerName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);

      popupStatus = 3;
//      xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.NEG_NICKNAME);
//      myRoot.CloseMenu(true);
      return true;
    }
    else if (Sender == Controls[3])
    {
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(strFeedback4, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activePlayerName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);

      popupStatus = 4;
//      xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.NEG_GAMEPLAY);
//      myRoot.CloseMenu(true);
      return true;
    }
    else if (Sender == Controls[4])
    {
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(strFeedback5, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activePlayerName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);

      popupStatus = 5;
//      xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.NEG_SCREAMING);
//      myRoot.CloseMenu(true);
      return true;
    }
    else if (Sender == Controls[5])
    {
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(strFeedback6, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activePlayerName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);

      popupStatus = 6;
//      xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.NEG_HARASSMENT);
//      myRoot.CloseMenu(true);
      return true;
    }
    else if (Sender == Controls[6])
    {
      Controller.OpenMenu("XIDInterf.XIIILiveMsgBox",false);
      msgbox = XIIILiveMsgBox(myRoot.ActivePage);
      msgbox.SetupQuestion(strFeedback7, QBTN_Ok | QBTN_Cancel, QBTN_Cancel, activePlayerName);
      msgbox.OnButtonClick=ReturnMsgBox;
      msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);

      popupStatus = 7;
//      xboxlive.SendFeedBack(activePlayerName, XBL_FEEDBACK.NEG_LEWDNESS);
//      myRoot.CloseMenu(true);
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



