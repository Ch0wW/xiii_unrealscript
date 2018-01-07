class XIIIMenuLiveFriendsMainPage extends XIIILiveWindow;

#exec OBJ LOAD FILE=XIIIXboxPacket.utx
//#exec OBJ LOAD FILE=GUIContent.utx
//var string MapList[64];
//var int MaxMaps, onMap;

var XIIIGUIMultiListBox listbox;
//var GUISlider  slider;
var localized string TitleText1, TitleText2, TitleText3;
var localized string YouHaveNoFriends, strLRHelp, strPlaying;
//var localized string strOnline;
//var localized string strOffline;

var localized string strOnlineStatus[7];
var int nrFriends;


enum eFriendStatus
{
  FRIENDSTATUS_receivedinvitation,
  FRIENDSTATUS_receivedfriendrequest,
  FRIENDSTATUS_sentinvitation,
  FRIENDSTATUS_sentfriendrequest,
  FRIENDSTATUS_onlinefriendsignedin,
  FRIENDSTATUS_offline,
  FRIENDSTATUS_none
};

enum eVoiceStatus
{
  VOICESTATUS_voiceon,
  VOICESTATUS_voicemuted,
  VOICESTATUS_voicetv,
  VOICESTATUS_voicenone,
};

/*
enum FriendStatusFlags      in scripts use:  xboxlive.XONLINE_FRIENDSTATE_FLAG_INVITEACCEPTED   etc.
{
	FLAG_INVITEACCEPTED = XONLINE_FRIENDSTATE_FLAG_INVITEACCEPTED,
	FLAG_INVITEREJECTED = XONLINE_FRIENDSTATE_FLAG_INVITEREJECTED,
	FLAG_JOINABLE				= XONLINE_FRIENDSTATE_FLAG_JOINABLE,
	FLAG_ONLINE					= XONLINE_FRIENDSTATE_FLAG_ONLINE,
	FLAG_RECEIVEDREQUEST= XONLINE_FRIENDSTATE_FLAG_RECEIVEDREQUEST,
	FLAG_SENTREQUEST		= XONLINE_FRIENDSTATE_FLAG_SENTREQUEST,
	FLAG_PLAYING				= XONLINE_FRIENDSTATE_FLAG_PLAYING,
	FLAG_RECEIVEDINVITE = XONLINE_FRIENDSTATE_FLAG_RECEIVEDINVITE,
	FLAG_SENTINVITE			= XONLINE_FRIENDSTATE_FLAG_SENTINVITE,
	FLAG_VOICE					= XONLINE_FRIENDSTATE_FLAG_VOICE
};
*/


//var GUIMultiListBoxLine friendsList[100];
var XboxLiveManager.FRIEND_PACKET friendsList[100];
var string friendsListNames[100];
var string friendsListTitles[100];

var int           numberOfFriendsInList;

var bool firsttime;

var texture onlineIcons[7];
var texture voiceIcons[3];

var XIIIGUIButton statusButton;



function Created()
{
  local int i;
     Super.Created();


/*     leftArrow = XIIIArrowbutton(CreateControl(class'XIIIArrowbutton', 0, 0, 12, 12));
     leftArrow.WinLeft = 200;
     leftArrow.WinTop = ControlOffset + 4;
     leftArrow.bLeftOrient = true;
     rightArrow = XIIIArrowbutton(CreateControl(class'XIIIArrowbutton', 0, 0, 12, 12));
     rightArrow.WinLeft = 208;
     rightArrow.WinTop = ControlOffset + 4;  */

/*AJ
     listbox = GUIListBox(CreateControl(class'GUIListBox', 100, 100, 440, 300));
     listbox.StyleName = "Listbox";
     listbox.List = new class'GUIMultiList';
     listbox.List.Add("Hello");
     listbox.List.Add("World");
     listbox.List.ItemsPerPage = 5;
     Controls[0]=listbox;
*/


     //slider = GUISlider(CreateControl(class'GUISlider', 0, 120, 100, 20));
     //Controls[2]=slider;

}


function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  //local int numberOfAccounts, q;
  //local string temp;
  local GUIMultiListBoxLine pack;
  local int q;


  Super.InitComponent(MyController, MyOwner);

  //xboxlive.EnumerateFriends(TRUE);

  listbox = XIIIGUIMultiListBox(Controls[0]);
  listbox.bVisibleWhenEmpty = true;
  listbox.ScrollBar.bVisible = false;
  //listbox.List = new class'GUIMultiList';

  onlineIcons[eFriendStatus.FRIENDSTATUS_receivedinvitation]=texture'XIIIXboxPacket.GameInviteReceived';
  onlineIcons[eFriendStatus.FRIENDSTATUS_receivedfriendrequest]=texture'XIIIXboxPacket.FriendInviteReceived';
  onlineIcons[eFriendStatus.FRIENDSTATUS_sentinvitation]=texture'XIIIXboxPacket.GameInviteSent';
  onlineIcons[eFriendStatus.FRIENDSTATUS_sentfriendrequest]=texture'XIIIXboxPacket.FriendInviteSent';
  onlineIcons[eFriendStatus.FRIENDSTATUS_onlinefriendsignedin]=texture'XIIIXboxPacket.FriendOnline';
  onlineIcons[eFriendStatus.FRIENDSTATUS_offline]=none;

  voiceIcons[eVoiceStatus.VOICESTATUS_voiceon]=texture'XIIIXboxPacket.CommunicatorON';
  voiceIcons[eVoiceStatus.VOICESTATUS_voicemuted]=texture'XIIIXboxPacket.CommunicatorMUTED';
  voiceIcons[eVoiceStatus.VOICESTATUS_voicetv]=none;//AJ


  listbox.SetNumberOfColumns(3);
  listbox.SetColumnOffset(0, 0);
  listbox.SetColumnOffset(1, 252);
  listbox.SetColumnOffset(2, 286);
  listbox.List.UserDefinedItemHeight = 36;

  statusButton         = XIIIGUIButton(Controls[1]);
  statusButton.Caption = "";



/*
	Buttons[0] = XIIIGUIButton(Controls[0]);
	Buttons[0].Caption = ButtonNames[0];
	Buttons[1] = XIIIGUIButton(Controls[1]);
	Buttons[1].Caption = ButtonNames[1];
	Buttons[2] = XIIIGUIButton(Controls[2]);
	Buttons[2].Caption = ButtonNames[2];
	Buttons[3] = XIIIGUIButton(Controls[3]);
	Buttons[3].Caption = ButtonNames[3];
	Buttons[4] = XIIIGUIButton(Controls[4]);
	Buttons[4].Caption = ButtonNames[4];
	Buttons[5] = XIIIGUIButton(Controls[5]);
	Buttons[5].Caption = ButtonNames[5];
*/
	OnClick = InternalOnClick;


     /*
     listbox.list.clear();
     numberOfAccounts = xboxlive.GetNumberOfAccounts();
     for (q=0; q<numberOfAccounts; q++)
     {
       temp = xboxlive.GetAccountName(q);
       listbox.list.Add(temp);
     }

     listbox.list.Add(newAccountString);
     listbox.bVisibleWhenEmpty = true;
     */
}


function ShowWindow()
{
  OnMenu = 0; myRoot.bFired = false;
//  bShowBCK = true;
//  bShowRUN = false;
  //bShowSEL = true;

   bShowSEL = true;
   bShowBCK = true;
   Super.ShowWindow();

  xboxlive.UpdateFriends();

}


function Paint(Canvas C, float X, float Y)
{

  local GUIMultiListBoxLine pack;
  local string str;

  // populate the local friends list
  local bool friendsUpdated;
  local int q, temptop, tempindex;

  friendsUpdated = xboxlive.IsFriendsListChanged();

  nrFriends = xboxlive.GetNumberOfFriends();
  if (friendsUpdated || firsttime )
  {
    firsttime = false;

    temptop   = listbox.List.top;
    tempindex = listbox.List.Index;

    listbox.List.Clear();

    for (q=0; q<nrFriends; q++)
    {
      friendsList[q]     = xboxlive.GetFriendAtIndex(q);
      friendsListNames[q] = xboxlive.GetFriendNameAtIndex(q);
      friendsListTitles[q] = xboxlive.GetFriendTitleAtIndex(q);
      //friendsList[q].items[0].tex = onlineIcons[friendPost.onlineStatus];
      //friendsList[q].items[1].tex = onlineIcons[1]; //friendPost.voiceStatus
      //friendsList[q].items[0].str = "";
      //friendsList[q].items[1].str = ""; //friendPost.voiceStatus


      pack = new class'GUIMultiListBoxLine';
      pack.items[0].tex = onlineIcons[friendsList[q].onlineStatus];
      if (friendsList[q].isOnline)
        pack.items[1].tex = voiceIcons[friendsList[q].voiceStatus]; //
      else
        pack.items[1].tex = none;
      //listbox.List.Add(friendPost.name, friendsList[q]);
      listbox.List.Add(friendsListNames[q], pack);

    }
    if (nrFriends == 0 && !xboxlive.IsUpdatingFriends())
    {
      pack = new class'GUIMultiListBoxLine';
      pack.items[0].tex = none;
      pack.items[1].tex = none;
      listbox.List.Add(YouHaveNoFriends, pack);
    }

    if (listbox.List.ItemCount>tempindex)
    {
      listbox.List.top   = temptop;
      listbox.List.Index = tempindex;
    }
  }

  if (nrFriends > 0)
  {
    str = "";
    if (friendsList[listbox.list.Index].isOnline)
    {
      if ((friendsList[listbox.list.Index].onlineStatusFlags & xboxlive.XONLINE_FRIENDSTATE_FLAG_PLAYING) != 0 )
      {
        if (friendsListTitles[listbox.list.Index] != "")
          str = strPlaying$" "$friendsListTitles[listbox.list.Index];
        else
          str = strPlaying;
      }
      else
      {
        if (friendsListTitles[listbox.list.Index] != "")
          str =  strOnlineStatus[eFriendStatus.FRIENDSTATUS_onlinefriendsignedin]$" ("$friendsListTitles[listbox.list.Index]$")";
        else
        str =  strOnlineStatus[eFriendStatus.FRIENDSTATUS_onlinefriendsignedin];
     }
    }
    else
      str =  strOnlineStatus[eFriendStatus.FRIENDSTATUS_offline];

    if (friendsList[listbox.list.Index].onlineStatus <= eFriendStatus.FRIENDSTATUS_sentfriendrequest)
      str =  strOnlineStatus[friendsList[listbox.list.Index].onlineStatus];

    //C.SetPos(X+columnOffset[0]+10, Y+(H-16.0)*0.5-2);
    //C.DrawText(Elements[item].Item, false);
    statusButton.Caption = str;

  }
  else
    statusButton.Caption = "";

/* AJ no room right now
  if (xboxlive.IsPlaying())
  {
    C.DrawColor = BlackColor;
    C.SetPos(260, 400);
    C.DrawText(strLRHelp, false);
    C.DrawColor = WhiteColor;
    C.bUseBorder = false;
  }
*/
     Super.Paint(C, X, Y);
     if (xboxlive.IsPlaying())
       PaintStandardBackground3(C, X, Y, TitleText1, TitleText2, TitleText3, 2);
     else
       PaintStandardBackground3(C, X, Y, "", TitleText2, TitleText3, 2);
}

function JoinGameTest()
{
     local string URL, Checksum;
     local int N;

     URL = "192.168.0.18";
     //URL = "192.168.0.18:7777";
/*     class'StatLog'.Static.GetPlayerChecksum(GetPlayerOwner(), Checksum);
     if (Checksum == "")
          URL = URL $ "?Checksum=NoChecksum";
     else
          URL = URL $ "?Checksum="$Checksum;
*/
    myRoot.bXboxStartup = true;
    myRoot.GotoState('');
    myRoot.CloseAll(true);
     GetPlayerOwner().AttribPadToViewport();
     //log("TRAVELING w/URL: "$URL);
     //GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
    GetPlayerOwner().ConsoleCommand("start 192.168.0.18");
}

// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{

  if (nrFriends > 0)
  {
    if ((friendsList[listbox.list.Index].onlineStatusFlags & xboxlive.XONLINE_FRIENDSTATE_FLAG_RECEIVEDINVITE) != 0)
    {
      xboxlive.SetActiveFriend(friendsListNames[listbox.list.Index]);
      myRoot.OpenMenu("XIDInterf.XIIIMenuLiveGameInviteReceived");
    }

    else if ((friendsList[listbox.list.Index].onlineStatusFlags & xboxlive.XONLINE_FRIENDSTATE_FLAG_RECEIVEDREQUEST) != 0)
    {
      xboxlive.SetActiveFriend(friendsListNames[listbox.list.Index]);
      myRoot.OpenMenu("XIDInterf.XIIIMenuLiveFriendsshipRequested");
    }

    else if ((friendsList[listbox.list.Index].onlineStatusFlags & xboxlive.XONLINE_FRIENDSTATE_FLAG_SENTINVITE) != 0)
    {
      xboxlive.SetActiveFriend(friendsListNames[listbox.list.Index]);
      myRoot.OpenMenu("XIDInterf.XIIIMenuLiveFriendsInvited");
    }

    else if ((friendsList[listbox.list.Index].onlineStatusFlags & xboxlive.XONLINE_FRIENDSTATE_FLAG_SENTREQUEST) != 0)
    {
      xboxlive.SetActiveFriend(friendsListNames[listbox.list.Index]);
      myRoot.OpenMenu("XIDInterf.XIIIMenuLiveFriendsCancelFriendRequest");
    }





    else if (friendsList[listbox.list.Index].isOnline)
    {
      xboxlive.SetActiveFriend(friendsListNames[listbox.list.Index]);
      myRoot.OpenMenu("XIDInterf.XIIIMenuLiveFriendsOnline");
    }
    else
    {
      xboxlive.SetActiveFriend(friendsListNames[listbox.list.Index]);
      myRoot.OpenMenu("XIDInterf.XIIIMenuLiveFriendsOffline");
    }
    return true;
  }

  return false;
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
	        //AJxboxlive.EnumerateFriends(FALSE);
	        myRoot.CloseMenu(true);
    	    return true;
	    }
	    if (Key==0x25/*IK_Left*/)
	    {
        myRoot.CloseMenu(true);

        if (xboxlive.IsPlaying())
          myRoot.OpenMenu("XIDInterf.XIIIMenuLivePlayerList");
        else
          myRoot.OpenMenu("XIDInterf.XIIIMenuLiveOldPlayerList");
  	    return true;
	    }
	    if (Key==0x27/*IK_Right*/)
	    {
        myRoot.CloseMenu(true);
	//      if (xboxlive.IsPlaying())
          myRoot.OpenMenu("XIDInterf.XIIIMenuLiveOldPlayerList");
          return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}





