//-----------------------------------------------------------
//
//-----------------------------------------------------------

class XIIIMenuLiveStatsWritePage extends XIIILiveWindow;

var  localized string	 statwritefailedString, statwritestartingString, statwritepleasewaitString;
var int userState;
var bool hasstarted;
var bool netfailshouldshow;
var localized string confirmquittext;

var XIIILiveMsgBox MsgBox;
var XIIILiveMsgBox MsgBoxnetfailure;
var XIIIMsgBoxInGame MsgBoxIngm;


function Created()
{
	fRatioX = 1.0;
	fRatioY = 1.0;
	fScaleTo = 1.0;
  
	Super.Created();
}

function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	
	if(netfailshouldshow == true)
	{
	myRoot.OpenMenu("XIDInterf.XIIILiveMsgBox");
	  MsgBoxnetfailure = XIIILiveMsgBox(myRoot.ActivePage);
	  MsgBoxnetfailure.SetupQuestion(confirmquittext, QBTN_Ok, QBTN_Ok, "");
	  MsgBoxnetfailure.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);	
	  MsgBoxnetfailure.OnButtonClick = QuitMsgBoxnetfailReturn;
	}
}

function ShowWindow()
{
	OnMenu = 0;
	myRoot.bFired = false;
	Super.ShowWindow();
	bShowBCK = false;
	bShowRUN = false;
	bShowSEL = false;
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);
	Process();
}

function QuitMsgBoxReturn(byte bButton)
{
}

function QuitMsgBoxnetfailReturn(byte bButton)
{
	if ((bButton & QBTN_Ok) != 0)
	{
	  netfailshouldshow = false;
	}
}

event HandleParameters(string Param1, string Param2)
{
	if ( Param1=="netfailure" )
	{
          netfailshouldshow = true;
	}
}

function Process()
{
	if(netfailshouldshow == false)
	{
	if(hasstarted == false)
	{
	  	  myRoot.OpenMenu("XIDInterf.XIIILiveMsgBox");
	  	  msgbox = XIIILiveMsgBox(myRoot.ActivePage);
		  msgbox.SetupQuestion(statwritepleasewaitString, 0, 0, statwritestartingString);
		  msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
	
		XIIIMPPlayerController(GetPlayerOwner()).StatUpdate();
		hasstarted = true;
	}

	if(xboxlive.IsMyStatsUpdateDone() == true)
	{
		//if(xboxlive.WasMyStatsUpdateSuccessful() == false)
		//{
		//	myRoot.CloseMenu(true);
		//	myRoot.OpenMenu("XIDInterf.XIIILiveMsgBox");
		//	msgbox = XIIILiveMsgBox(myRoot.ActivePage);
		//	msgbox.SetupQuestion(statwritepleasewaitString, QBTN_Ok, QBTN_Ok, statwritefailedString);
		//	msgbox.InitBox(160*fRatioX, 130*fRatioY*fScaleTo, 16, 16, 320*fRatioX, 230*fRatioY*fScaleTo);
		//	MsgBox.OnButtonClick = QuitMsgBoxReturn;
		//}
		
		userState = xboxlive.US_ONLINE;
		if (xboxlive.HasUserVoice(xboxlive.GetCurrentUser()))
			userState = userState | xboxlive.US_VOICE;
		xboxlive.SetUserState(xboxlive.GetCurrentUser(), userState);
		xboxlive.EnumerateFriends(FALSE);
		xboxlive.ResetVoiceNet();
		GetPlayerOwner().myHUD.bShowScores = false;
		GetPlayerOwner().myHUD.bHideHud = true;
		myRoot.CloseAll(true);
		myRoot.GotoState('');
		myRoot.Master.GlobalInteractions[0].ViewportOwner.Actor.ClientTravel("MapMenu", TRAVEL_Absolute, false);
		GotoState('');
	}
}
}


