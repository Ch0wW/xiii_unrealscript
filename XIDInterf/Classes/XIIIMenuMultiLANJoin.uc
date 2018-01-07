//============================================================================
// Join LAN game menu.
//
//============================================================================
class XIIIMenuMultiLANJoin extends XIIIMenuMultiBase;


struct ServerInfo
{
	var string IpAddr;
	var string SrvName;
};

var ServerInfo GameServers[32];

var XBOXClientBeaconReceiver BeaconReceiver;

var XIIIButton BackButton, RefreshButton;
var localized string CreateText, FilterText, RefreshText, BackText, QueryServerList, NoServersFound, RefreshingText;

var XIIIButton ServerButton[7], GameTypeButton[7], MapButton[7], PlayersButton[7];
var XIIIArrowButton LeftArrow, RightArrow;

var localized string ConnectingMsgBoxMenuTitle, ConnectingText;
var localized string networkcableDisconnectedString;
var XIIIMsgBox msgbox;
var int MsgBoxStatus;
var int IndexOfServerToJoin;
var float DelayToWait;

var int NbServersMax, NbServersByPage, NbServersOnThisPage;
var int CurrentPage, MaxPage, NewPage;

var bool bServerListObtained, bRefreshing;
var bool bMsgDisconnectedDisplayed;

VAR Array<STRING> MapDescList;
//var string Infos[4];

//============================================================================
function Created()
{
    local int i;
	LOCAL Array<STRING> MapUNRList;

    Super.Created();

	AllowedGameTypeIndex[0]=DeathmatchIndex;
	AllowedGameTypeIndex[1]=TeamDeathmatchIndex;
	AllowedGameTypeIndex[2]=CaptureTheFlagIndex;
	AllowedGameTypeIndex[3]=SabotageIndex;

    bShowBCK = true;
    bShowSEL = true;

	LeftArrow = XIIIArrowButton(CreateControl(class'XIIIArrowButton', 240, 333*fScaleTo, 16, 16));
	LeftArrow.bLeftOrient = true;
	LeftArrow.bNeverFocus = true;
	LeftArrow.bVisible = false;

	RightArrow = XIIIArrowButton(CreateControl(class'XIIIArrowButton', 380, 333*fScaleTo, 16, 16));
	RightArrow.bLeftOrient = false;
	RightArrow.bNeverFocus = true;
	RightArrow.bVisible = false;

	RefreshButton = XIIIButton(CreateControl(class'XIIIButton', 150, 370*fScaleTo, 100, 30*fScaleTo));
	RefreshButton.Text= RefreshText;
	RefreshButton.bUseBorder = true;

    BackButton = XIIIButton(CreateControl(class'XIIIButton', 400, 370*fScaleTo, 100, 30*fScaleTo));
	BackButton.Text= BackText;
	BackButton.bUseBorder = true;

	for (i=0;i<NbServersByPage;i++)
	{
		// server name
		ServerButton[i] = XIIIButton(CreateControl(class'XIIIButton', 30, (40*i + 50)*fScaleTo, 160, 30*fScaleTo));
		ServerButton[i].Text= "";
		ServerButton[i].bUseBorder = true;
		ServerButton[i].bNeverFocus = true;
		ServerButton[i].bVisible = false;
		// informations
		GameTypeButton[i] = XIIIButton(CreateControl(class'XIIIButton', 200, (40*i + 50)*fScaleTo, 160, 30*fScaleTo));
		GameTypeButton[i].Text= "";
		GameTypeButton[i].bUseBorder = true;
		GameTypeButton[i].bNeverFocus = true;
		GameTypeButton[i].bVisible = false;

		MapButton[i] = XIIIButton(CreateControl(class'XIIIButton', 370, (40*i + 50)*fScaleTo, 160, 30*fScaleTo));
		MapButton[i].Text= "";
		MapButton[i].bUseBorder = true;
		MapButton[i].bNeverFocus = true;
		MapButton[i].bVisible = false;

		PlayersButton[i] = XIIIButton(CreateControl(class'XIIIButton', 540, (40*i + 50)*fScaleTo, 70, 30*fScaleTo));
		PlayersButton[i].Text= "";
		PlayersButton[i].bUseBorder = true;
		PlayersButton[i].bNeverFocus = true;
		PlayersButton[i].bVisible = false;

		Controls[4 + i] = ServerButton[i];
		Controls[NbServersByPage + 4 + i] = GameTypeButton[i];
		Controls[2*NbServersByPage + 4 + i] = MapButton[i];
		Controls[3*NbServersByPage + 4 + i] = PlayersButton[i];
	}

	Controls[0] = RefreshButton;
	Controls[1] = BackButton;

	Controls[2] = LeftArrow; 
	Controls[3] = RightArrow;

	NewPage=1;
    IndexOfServerToJoin=-1;

    GetServersList();
    SetTimer(2, true);

	GetMapArray( -1, MapDescList, MapUNRList );

	GotoState('ReinitMusic');
}


function InstanciateBeacon()
{
	BeaconReceiver = GetPlayerOwner().Spawn(Class'XBOXClientBeaconReceiver');
}

function DestroyBeacon()
{
    BeaconReceiver.Destroy();
    SetTimer(0, false);
    BeaconReceiver = none;
}

function MsgBoxBtnClicked(byte bButton)
{
    if ((bButton & QBTN_Ok) != 0)       // ok to overwrite
    {
        bMsgDisconnectedDisplayed = false;
        myRoot.CloseMenu();
        DestroyBeacon();
    }
}

function Paint(Canvas C, float X, float Y)
{
   local float W, H;
	
	Super.Paint(C,X,Y);

   	if (myRoot.CableDisconnected && !bMsgDisconnectedDisplayed)
	{
        Controller.OpenMenu("XIDInterf.XIIIMsgBox",false);
        msgbox = XIIIMsgBox(myRoot.ActivePage);
        msgbox.SetupQuestion(networkcableDisconnectedString, QBTN_Ok, QBTN_Ok);
        msgbox.OnButtonClick=MsgBoxBtnClicked;
        msgbox.InitBox(120, 130, 10, 10, 400, 230);
        
        bMsgDisconnectedDisplayed = true;
	}
	else
	{
		RefreshButton.bNeverFocus = false;

		// page display
		C.SetPos(235*fRatioX, 330*fRatioY*fScaleTo);
		if (!bServerListObtained)
		{
    		//C.SetPos(240*fRatioX, 250*fRatioY);
			C.DrawText(QueryServerList, false);
		}
		else 
		{
			if (bRefreshing)
			{
				C.DrawText(RefreshingText, false);
			}
			else
			{
				if ( NbServersMax == 0 )
					C.DrawText(NoServersFound, false);
//				else
//					C.DrawText("Page "$CurrentPage$"/"$MaxPage, false);
			}
		}
	}
}


function ServerDisplay(int NumGameServer)
{
	local int j,Line, NbInfo;
    local string TempStr, Str, StrServer, StrGameType, StrMap, StrPlayers;

	j = NumGameServer - (NewPage - 1)*NbServersByPage;
	
	Str = GameServers[NumGameServer].SrvName;
	TempStr = Str;

	StrServer = Left( TempStr, InStr(TempStr,"|"));
	TempStr = Mid( TempStr, Len(StrServer) + 1 );
	
	StrMap = Left( TempStr, InStr(TempStr, "|") );
	TempStr = Mid( TempStr, Len(StrMap) + 1 );

	StrGameType = Left( TempStr, InStr(TempStr,"|"));

	StrPlayers = Mid( TempStr, Len(StrGameType) + 2 );
	//log(self@"---> NOMBRE DE JOUEURS :"@StrPlayers);

	ServerButton[j].Text = StrServer;
	GameTypeButton[j].Text = GetGameTypeText(int(StrGameType));
	MapButton[j].Text = MapDescList[int(StrMap)];
	PlayersButton[j].Text = StrPlayers;

	ServerButton[j].bSmallFont=true;
	GameTypeButton[j].bSmallFont=true;
	MapButton[j].bSmallFont=true;
	PlayersButton[j].bSmallFont=false;

	ServerButton[j].bNeverFocus = false;
	ServerButton[j].bVisible = true;
	GameTypeButton[j].bVisible = true;
	MapButton[j].bVisible = true;
	PlayersButton[j].bVisible = true;
}


function ServerHide(int NumGameServer)
{
	ServerButton[NumGameServer].bNeverFocus = true;
	ServerButton[NumGameServer].bVisible = false;
	GameTypeButton[NumGameServer].bVisible = false;
	MapButton[NumGameServer].bVisible = false;
	PlayersButton[NumGameServer].bVisible = false;
}


function PageSwitch()
{
    local int i;

	// number of servers displayed on this page
	if ( NewPage == MaxPage )	
		NbServersOnThisPage = NbServersMax - (MaxPage - 1)*NbServersByPage;
	else
		NbServersOnThisPage = NbServersByPage;

	// display all servers on this page
	for (i=0;i<NbServersOnThisPage;i++)
	{
		ServerDisplay( (NewPage - 1)*NbServersByPage + i );
	}

	// erase void buttons
	for (i=NbServersOnThisPage;i<NbServersByPage;i++)
	{
		ServerButton[i].bNeverFocus = true;
		ServerButton[i].bVisible = false;
		GameTypeButton[i].bVisible = false;
		MapButton[i].bVisible = false;
		PlayersButton[i].bVisible = false;
	}

	// focus control
	if ( ( FindComponentIndex(FocusedControl) - 2 ) > NbServersOnThisPage )
	{
		Controls[NbServersOnThisPage + 2].FocusFirst(Self,false);
	}

	// new current page
	CurrentPage = NewPage;

}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    local int i;
	
    if (Sender == RefreshButton)
    {
        GotoState('Refreshing');
    }

    if (Sender == BackButton)
    {
		myRoot.CloseMenu(true);
        DestroyBeacon();
    }
	
	for (i=0;i<NbServersByPage;i++)
	{
		if (Sender == ServerButton[i])
		{
            myRoot.OpenMenu("XIDInterf.XIIIMsgBox",false);
            msgbox = XIIIMsgBox(myRoot.ActivePage);
            msgbox.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);
            msgbox.SetupQuestion(ConnectingText, QBTN_Cancel, QBTN_Cancel, ConnectingMsgBoxMenuTitle);
            msgbox.OnButtonClick = OnButtonMsgBoxClick;
            msgbox.OnTick = OnMsgBoxTick;
            msgbox.OnClose = OnMsgBoxClose;
            msgbox.ShowWorking = true;
            MsgBoxStatus = 100;

            IndexOfServerToJoin = i;
            DelayToWait = 0.0;
		}
	}
	return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	local int index;
	local bool bLeft, bRight, bUp, bDown;
	
	if (State==1)// IST_Press // to avoid auto-repeat
    {
	    if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B) /*IK_Escape*/)
	    {
	        myRoot.CloseMenu(true);
            DestroyBeacon();
    	    return true;
	    }
	    
		if (myroot.CableDisconnected && Key==0x0D/*IK_Enter*/)
	    {
			DestroyBeacon();
    	    return true;
	    }

		if ((Key==0x0D/*IK_Enter*/) || (Key==0x01)/*IK_LeftMouse*/)
		{
			return InternalOnClick(FocusedControl);
		}

		
		bLeft = (Key==0x25);
		bRight = (Key==0x27);
		bUp = (Key==0x26);
		bDown = (Key==0x28);

		// controls are
		//      4
		//      5
		//     ...
		//     0 1
		// (controls 2 and 3 are used by arrows buttons)
		if ( bLeft || bRight  || bUp || bDown )
		{
			index = FindComponentIndex(FocusedControl);
			switch (index)
			{
			case 0 :
				if ( bUp ) Controls[3 + NbServersOnThisPage].FocusFirst(Self,false);
				if ( bDown ) Controls[4].FocusFirst(Self,false);
                if ( bLeft || bRight ) Controls[1].FocusFirst(Self,false);
				break;
			case 1 :
				if ( bUp ) Controls[3 + NbServersOnThisPage].FocusFirst(Self,false);
				if ( bDown ) Controls[4].FocusFirst(Self,false);
                if ( bLeft || bRight ) Controls[0].FocusFirst(Self,false);
				break;
			case 4 :
				if ( bUp ) Controls[0].FocusFirst(Self,false);
				if ( bDown )
					if ( NbServersOnThisPage != 1 )
						Controls[index + 1].FocusFirst(Self,false);
					else
						Controls[0].FocusFirst(Self,false);
				NewPage = CurrentPage;
				if ( bRight ) NewPage ++;
				if ( bLeft ) NewPage --;
				NewPage = Clamp(NewPage,1,MaxPage);
				// page is changed
				if (NewPage != CurrentPage)
					PageSwitch();
				break;
			default:
				if ( index == (3 + NbServersOnThisPage) )
				{
					if ( bUp ) Controls[3 + NbServersOnThisPage - 1].FocusFirst(Self,false);
					if ( bDown ) Controls[0].FocusFirst(Self,false);
				}
				else
				{
					if ( bUp ) Controls[index - 1].FocusFirst(Self,false);
					if ( bDown ) Controls[index + 1].FocusFirst(Self,false);
				}
				NewPage = CurrentPage;
				if ( bRight ) NewPage ++;
				if ( bLeft ) NewPage --;
				NewPage = Clamp(NewPage,1,MaxPage);
				// page is changed
				if (NewPage != CurrentPage)
					PageSwitch();
			}
			return true;
		}
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



event Timer()
{
    // Update server list regularly
    GotoState('Refreshing');
}



function GetServersList()
{
    local int i;
    local bool JustBeaconed;

    if (BeaconReceiver == none)
    {
        InstanciateBeacon();
        JustBeaconed = true;
    }

    NbServersMax = 0;
    for (i=0; i<32; i++)
    {
        if (BeaconReceiver.GetBeaconAddress(i) != "")
        {
            GameServers[NbServersMax].SrvName = BeaconReceiver.GetBeaconText(i);
            GameServers[NbServersMax].IpAddr = BeaconReceiver.GetBeaconAddress(i);
            //log(self@"---> BEACON RECEIVER Name="$GameServers[NbServersMax].SrvName@"IP="$GameServers[NbServersMax].IpAddr);
            if ( NbServersMax < NbServersByPage)
            {
                ServerDisplay(NbServersMax);
            }
            NbServersMax ++;
        }
	}

    // hide the buttons corresponding to servers that may have disappeared since last time the server list was received
    if ( NbServersMax < NbServersByPage)
    {
        for (i=NbServersMax; i<NbServersByPage; i++)
        {
            ServerHide(i);
        }
    }

	// current page is the first one
	CurrentPage = 1;

	// maximal number of pages
	if ( (NbServersMax/NbServersByPage)*NbServersByPage < NbServersMax )
		MaxPage = NbServersMax/NbServersByPage + 1;
	else
		MaxPage = NbServersMax/NbServersByPage;

/*	// arrows display
	if ( NbServersMax > NbServersByPage )
	{
		LeftArrow.bVisible = true;
		RightArrow.bVisible = true;
	}
*/
	// number of servers displayed on the first page
	if ( NbServersMax > NbServersByPage)
		NbServersOnThisPage = NbServersByPage;
	else
		NbServersOnThisPage = NbServersMax;

    // consider that the servers didn't have enough time to respond if the beacon has just been spawned
    if (!JustBeaconed)
    {
        bServerListObtained = true;
    }
}



Delegate OnClose(optional Bool bCanceled)
{
//    ToDoWhenThisMenuIsClosed(bCanceled);
}


function ToDoWhenThisMenuIsClosed(Bool bCanceled)
{
    log("XIIIMenuMultiLANJoin.ToDoWhenThisMenuIsClosed()");

    DestroyBeacon();
	myRoot.bProfileMenu = true;
	myRoot.GotoState('');
    // No need for myRoot.CloseAll() here because if this function is called, it is because the CloseAll() was called from the engine.
	GetPlayerOwner().AttribPadToViewport();
    Super.OnClose(bCanceled);
}


//
// "Connecting Message box" delegates
//

function OnButtonMsgBoxClick(byte bButton)
{
    // cancel the pending level (cmd "CANCEL" to UGameEngine);
	GetPlayerOwner().ConsoleCommand("CANCEL");
}

function OnMsgBoxTick(float deltatime)
{
    local string ErrorMsg, MyClass, SkinCode, MyName, MyTeam;
	local int i;

    if (MsgBoxStatus == 0)
    {
        // poll the connection status
        MsgBoxStatus = MyRoot.GetConnectionStatus(ErrorMsg);
        if (MsgBoxStatus != 0)
        {
            log("Error Msg = "$ErrorMsg);
            msgbox.UpdateTextDisplayed(ErrorMsg);
            msgbox.ShowWorking = false;
            MsgBoxStatus = 99;
        }
    }
    else if (MsgBoxStatus == 99)
    {
        // nothing, just wait
    }
    else if (MsgBoxStatus == 100)
    {
        DelayToWait += deltatime;
        if (DelayToWait > 2.0)
        {
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

			// name selection
			MyName = GetPlayerOwner().GetDefaultURL("MyName");
			if (MyName == "")
				MyName = GetPlayerOwner().GetDefaultURL("Name");		

			// team selection
			MyTeam = GetPlayerOwner().GetDefaultURL("MyTeam");
			if (MyTeam == "")
				MyTeam = GetPlayerOwner().GetDefaultURL("Team");

            //log("start"@GameServers[IndexOfServerToJoin].IpAddr$"?LAN?Name="$GetPlayerOwner().PlayerReplicationInfo.PlayerName);
            //GetPlayerOwner().ConsoleCommand("start"@GameServers[IndexOfServerToJoin].IpAddr$"?LAN?Name="$GetPlayerOwner().PlayerReplicationInfo.PlayerName$"?SK="$SkinCode);
            GetPlayerOwner().ConsoleCommand("start xbox.join?LAN?Name="$MyName$"?SK="$SkinCode$"?team="$MyTeam$"?XNADDR="$BeaconReceiver.GetXNADDR(IndexOfServerToJoin)$"?XNKID="$BeaconReceiver.GetXNKID(IndexOfServerToJoin)$"?XNKEY="$BeaconReceiver.GetXNKEY(IndexOfServerToJoin));
            MsgBoxStatus = 0;
        }
    }
}

function OnMsgBoxClose(optional Bool bCanceled)
{
    if (MsgBoxStatus == 0)
    {
        // Connection is ok, the engine wants to close the menus before loading the map
        ToDoWhenThisMenuIsClosed(bCanceled);
    }
    // in any other case, it is simply that the user wants to come back to close the messagebox by himself
}



State Refreshing
{
Begin:
    bRefreshing=true;
    GetServersList();
    Sleep(1);
    bRefreshing=false;
    SetTimer(5, true);
    GotoState('');
}




defaultproperties
{
     RefreshText="Refresh list"
     BackText="Back"
     QueryServerList="Getting a list of server..."
     NoServersFound="No servers found"
     RefreshingText="Refreshing server list..."
     ConnectingMsgBoxMenuTitle="Connection status"
     ConnectingText="Connecting to the server...."
     NbServersByPage=7
     hSoundMenu2=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hMulti2'
}
