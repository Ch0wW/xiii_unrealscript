// ====================================================================
//  (c) 2003 Ubi Soft.  All Rights Reserved
// ====================================================================

class XIIIMenuLiveJoinMsgBox extends XIIILiveMsgBox;


var localized string ConnectingMsgBoxMenuTitle, ConnectingText;
var int MsgBoxStatus;
var float DelayToWait;

var int ServerID;
//var int GameServerPort;

var XboxLiveManager xboxlive;
var int ResultCode;

var string URL;

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
    Super.InitComponent(pMyController, MyOwner);
    if (xboxlive == none)
      xboxlive=New Class'XboxLiveManager';
}

event HandleParameters(string Param1, string Param2)
{
    ServerID = int(Param1);
    //log("Server ID = "$ServerID);
}


Delegate OnButtonClick(byte bButton)
{
    // cancel the pending level (cmd "CANCEL" to UGameEngine);
	GetPlayerOwner().ConsoleCommand("CANCEL");
    if ((MsgBoxStatus == 0) || (MsgBoxStatus == 102) || (MsgBoxStatus == 103))
    {
        //myMMManager.LeaveGameServer();
        //xboxlive.Reset
        xboxlive.ResetVoiceNet();
        xboxlive.SessionReset();
    }
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	local int index;
	local bool bLeft, bRight, bUp, bDown;
	
	if (State==1)// IST_Press // to avoid auto-repeat
    {
        //if ((Key==0x0D/*IK_Enter*/) || (Key==0x01)/*IK_LeftMouse*/)
	    //{
		//	return InternalOnClick(FocusedControl);
	    //}
	    /*else*/ if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B) /*IK_Escape*/)
	    {
	        myRoot.CloseMenu(true);
    	    return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}


Delegate OnTick(float deltatime)
{
    local string ErrorMsg;
	local int i;
	local string MyClass, SkinCode;

    if (MsgBoxStatus == 0)
    {
        // poll the connection status
        MsgBoxStatus = MyRoot.GetConnectionStatus(ErrorMsg);
        if (MsgBoxStatus != 0)
        {
            log("Error Msg = "$ErrorMsg);
            UpdateTextDisplayed(ErrorMsg);
            ShowWorking = false;
            //myMMManager.LeaveGameServer();
            xboxlive.ResetVoiceNet();
            xboxlive.SessionReset();
            MsgBoxStatus = 99;
        }
    }
    else if (MsgBoxStatus == 99)
    {
        // nothing, just wait the user to cancel
    }
    else if (MsgBoxStatus == 100)
    {
        SetupQuestion(ConnectingText, QBTN_Cancel, QBTN_Cancel, "");//AJConnectingMsgBoxMenuTitle);
        //myMMManager = new(none) class'MatchMakingManager';
        MsgBoxStatus = 101;
    }
    else if (MsgBoxStatus == 101)
    {
        DelayToWait += deltatime;
        if (DelayToWait > 1.0)
        {
            //GetPlayerOwner().ConsoleCommand("start"@GameServers[IndexOfServerToJoin].IpAddr$"?LAN");
            GotoState('STA_JoinServer');
            MsgBoxStatus = 102;
        }
    }
    else if (MsgBoxStatus == 102)
    {
        // wait until GS grant join server
    }
    else if (MsgBoxStatus == 103)
    {
        //GetPlayerOwner().ConsoleCommand("start"@GameServerIP$":"$GameServerPort);
		// skin
		MyClass = GetPlayerOwner().GetDefaultURL("MySkin");
		SkinCode = class'MeshSkinList'.default.MeshSkinListInfo[0].SkinCode;
		for (i=0;i<class'MeshSkinList'.default.MeshSkinListInfo.Length;i++)
		{
  			if ( MyClass == class'MeshSkinList'.default.MeshSkinListInfo[i].SkinName )
  			{
  				SkinCode = class'MeshSkinList'.default.MeshSkinListInfo[i].SkinCode;
  				break;
  			}
		}

        myRoot.bXboxStartup = true;
		 GetPlayerOwner().ConsoleCommand("start"@URL$"?SK="$SkinCode$"?GAMERTAG="$xboxlive.ConvertString(xboxlive.GetCurrentUser()));

        MsgBoxStatus = 0;
    }
}

Delegate OnClose(optional Bool bCanceled)
{
    if (MsgBoxStatus == 0)
    {
        // Connection is ok, the engine wants to close the menus before loading the map
        myRoot.bProfileMenu = true;
        myRoot.GotoState('');
        // No need for myRoot.CloseAll() here because if this function is called, it is because the CloseAll() was called from the engine.
        GetPlayerOwner().AttribPadToViewport();
        Super.OnClose(bCanceled);
    }
    // in any other case, it is simply that the user wants to come back to close the messagebox by himself
}



State STA_JoinServer
{

Begin:
  //myMMManager.JoinGameServer(ServerID, ""/*Password*/);
	//while ( !myMMManager.IsJoinGameServerAcknowledged(ResultCode, GameServerIP, GameServerAltIP, GameServerPort) )
	//{
	//	Sleep(0.1);
	//}

	//if (ResultCode != 0)
	//{
  //      UpdateTextDisplayed(myMMManager.FailureMessages[ResultCode]);
  //      ShowWorking = false;
  //      MsgBoxStatus = 99;
	//}

    MsgBoxStatus = 103;
    GotoState('');
}








