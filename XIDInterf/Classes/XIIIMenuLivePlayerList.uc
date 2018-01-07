class XIIIMenuLivePlayerList extends XIIILiveWindow;

#exec OBJ LOAD FILE=XIIIXboxPacket.utx
//#exec OBJ LOAD FILE=GUIContent.utx

var localized string TitleText1, TitleText2, TitleText3, strLRHelp;

var XIIIGUIMultiListBox listbox;
var texture voiceIcons[3];
var texture onlineIcons[7];

var int counter;
var int playerListLength;

var localized string strOnlineStatus[7];

var XboxLiveManager.FRIEND_PACKET playerList[100];
var string                        playerListNames[100];
var int                           numberOfPlayersInList;

var XIIIGUIButton statusButton;

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


function Created()
{
  local int i;
  Super.Created();
  playerListLength=0;
  xboxlive.EnumerateFriends(TRUE);
}

function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  Super.InitComponent(MyController, MyOwner);
	OnClick = InternalOnClick;

  listbox = XIIIGUIMultiListBox(Controls[0]);
  listbox.bVisibleWhenEmpty = true;
  listbox.ScrollBar.bVisible = false;
  //listbox.WinLeft = 100;
  //listbox.WinTop = 100;
  listbox.SetNumberOfColumns(4);
  listbox.SetColumnOffset(0, 0);
  listbox.SetColumnOffset(1, 226);
  listbox.SetColumnOffset(2, 256);
  listbox.SetColumnOffset(3, 286);
  listbox.List.UserDefinedItemHeight = 36;

  voiceIcons[0]=texture'XIIIXboxPacket.CommunicatorON';
  voiceIcons[1]=texture'XIIIXboxPacket.CommunicatorMUTED';
  voiceIcons[2]=texture'XIIIXboxPacket.CommunicatorON';

  onlineIcons[eFriendStatus.FRIENDSTATUS_receivedinvitation]=texture'XIIIXboxPacket.GameInviteReceived';
  onlineIcons[eFriendStatus.FRIENDSTATUS_receivedfriendrequest]=texture'XIIIXboxPacket.FriendInviteReceived';
  onlineIcons[eFriendStatus.FRIENDSTATUS_sentinvitation]=texture'XIIIXboxPacket.GameInviteSent';
  onlineIcons[eFriendStatus.FRIENDSTATUS_sentfriendrequest]=texture'XIIIXboxPacket.FriendInviteSent';
  onlineIcons[eFriendStatus.FRIENDSTATUS_onlinefriendsignedin]=texture'XIIIXboxPacket.FriendOnline';
  onlineIcons[eFriendStatus.FRIENDSTATUS_offline]=none;
  onlineIcons[eFriendStatus.FRIENDSTATUS_none]=none;


  statusButton         = XIIIGUIButton(Controls[1]);
  statusButton.Caption = "";

  xboxlive.CachePlayerList();
  UpdatePlayerList(true);
}

function UpdatePlayerList(bool first)
{
  local XboxLiveManager.FRIEND_PACKET fp;
  local GUIMultiListBoxLine pack;
  local string name;
  local int q;
  local bool hasVoice,isMuted,isTalking;
  local string str;
  local bool friendsUpdated;
  local int nrIngamePlayers, temptop, tempindex;
  local bool playerListUpdated;

  playerListUpdated = xboxlive.IsPlayerListUpdated();
  friendsUpdated = xboxlive.IsFriendsListChanged(); // We might have friends on the player list!!


  if (!xboxlive.UpdatePlayersTalking() && !first && !friendsUpdated && !playerListUpdated)
  {

    statusButton.Caption = "";
    if (playerListLength > 1 && listbox.list.Index < playerListLength-1)
    {
      str = strOnlineStatus[eFriendStatus.FRIENDSTATUS_onlinefriendsignedin];

      if (playerList[listbox.list.Index].onlineStatus <= eFriendStatus.FRIENDSTATUS_sentfriendrequest)
        str = strOnlineStatus[playerList[listbox.list.Index].onlineStatus];
      statusButton.Caption = str;

    }

    return;
  }


  temptop   = listbox.List.top;
  tempindex = listbox.List.Index;
  listbox.List.Clear();

  playerListLength = xboxlive.GetNumberOfPlayers();
  nrIngamePlayers = 0;
  for (q=0; q<playerListLength; q++)
  {
    if (!xboxlive.IsPlayerInGame(q))
      continue;
    nrIngamePlayers++;


    hasVoice = xboxlive.HasPlayerVoice(q);
    isMuted = xboxlive.IsPlayerMuted(q);
    isTalking = xboxlive.IsPlayerTalking(q);
    name = xboxlive.GetPlayerName(q);
    pack = new class'GUIMultiListBoxLine';

    fp = xboxlive.GetFriend(name);
    // Must have some friends info also!
    playerListNames[q]         = name;
    playerList[q].onlineStatus = fp.onlineStatus;
    playerList[q].voiceStatus  = fp.voiceStatus;
    playerList[q].isOnline     = fp.isOnline;
    if (name == "")
    {
      playerListNames[q]         = name;
      playerList[q].onlineStatus = eFriendStatus.FRIENDSTATUS_none;
      playerList[q].isOnline     = true;
    }
    pack.items[0].tex = onlineIcons[playerList[q].onlineStatus];

    if (hasVoice && isTalking && !isMuted)
      pack.items[1].tex = voiceIcons[2];
    else
      pack.items[1].tex = none;
    if (hasVoice && !isMuted)
      pack.items[2].tex = voiceIcons[0];
    else
      pack.items[2].tex = none;
    if (isMuted)
      pack.items[2].tex = voiceIcons[1];

    listbox.List.Add(name, pack);
  }



  nrIngamePlayers++;

//  hasVoice = xboxlive.HasPlayerVoice(q);
//  isMuted = xboxlive.IsPlayerMuted(q);
//  isTalking = xboxlive.IsPlayerTalking(q);
  name = xboxlive.GetCurrentUser();
  pack = new class'GUIMultiListBoxLine';
  //fp = xboxlive.GetFriend(name);
  // Must have some friends info also!
  playerListNames[nrIngamePlayers-1]         = name;
  playerList[nrIngamePlayers-1].onlineStatus = eFriendStatus.FRIENDSTATUS_none;//fp.onlineStatus;
  playerList[nrIngamePlayers-1].voiceStatus  = 0;//fp.voiceStatus;
 // playerList[nrIngamePlayers-1].isOnline     = 0;//fp.isOnline;
  pack.items[0].tex = onlineIcons[playerList[nrIngamePlayers-1].onlineStatus];
/*
  if (hasVoice && isTalking && !isMuted)
    pack.items[1].tex = voiceIcons[2];
  else
    pack.items[1].tex = none;
  if (hasVoice && !isMuted)
    pack.items[2].tex = voiceIcons[0];
  else
    pack.items[2].tex = none;
  if (isMuted)
    pack.items[2].tex = voiceIcons[1];
  */
  listbox.List.Add(name, pack);



  if (listbox.List.ItemCount>tempindex)
  {
    listbox.List.top   = temptop;
    listbox.List.Index = tempindex;
  }



  playerListLength = nrIngamePlayers;

  statusButton.Caption = "";
  if (playerListLength > 1 && listbox.list.Index < playerListLength-1)
  {
    str = "";

 //Silly to say a player is offline...   if (playerList[listbox.list.Index].isOnline)
      str = /*friendsList[listbox.list.Index].name $ " " $*/ strOnlineStatus[eFriendStatus.FRIENDSTATUS_onlinefriendsignedin];
//    else
//      str = /*friendsList[listbox.list.Index].name $ " " $*/ strOnlineStatus[eFriendStatus.FRIENDSTATUS_offline];

    if (playerList[listbox.list.Index].onlineStatus <= eFriendStatus.FRIENDSTATUS_sentfriendrequest)
      str = /*str $ "  " $*/ strOnlineStatus[playerList[listbox.list.Index].onlineStatus];

    //C.SetPos(X+columnOffset[0]+10, Y+(H-16.0)*0.5-2);
    //C.DrawText(Elements[item].Item, false);
    statusButton.Caption = str;

  }
}

function ShowWindow()
{
  OnMenu = 0; myRoot.bFired = false;
  Super.ShowWindow();
  bShowBCK = true;
  bShowRUN = false;
  bShowSEL = false;

  xboxlive.UpdateFriends();
}


function Paint(Canvas C, float X, float Y)
{

/* AJ no room right now
  if (xboxlive.IsPlaying())
  {
    C.DrawColor = BlackColor;
    C.SetPos(260, 400);
    C.DrawText(strLRHelp, false);
    C.DrawColor = WhiteColor;
  }
*/

  counter++;
  Super.Paint(C, X, Y);
//  PaintStandardBackground(C, X, Y, TitleText);
  PaintStandardBackground3(C, X, Y, TitleText1, TitleText2, TitleText3, 1);

  UpdatePlayerList(false);
}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
  local GUIMultiListBoxLine pack;
  local string name;

  if (playerListLength > 1 && listbox.list.Index < playerListLength-1)//listbox.list.ItemCount != 0)
  {
    name = listbox.list.GetItemAtIndex(listbox.list.Index);
    xboxlive.SetActiveFriend( name );

    if (playerList[listbox.list.Index].onlineStatus == eFriendStatus.FRIENDSTATUS_receivedfriendrequest)
      myRoot.OpenMenu("XIDInterf.XIIIMenuLivePlayerMenuSelectedGamerTag");
    else if (playerList[listbox.list.Index].onlineStatus == eFriendStatus.FRIENDSTATUS_sentfriendrequest)
      myRoot.OpenMenu("XIDInterf.XIIIMenuLivePlayerMenuSelectedGamerTagSentFriendRequest");
    else if (xboxlive.IsFriend(name))//    playerList[listbox.list.Index].onlineStatus == eFriendStatus.FRIENDSTATUS_onlinefriendsignedin)
      myRoot.OpenMenu("XIDInterf.XIIIMenuLivePlayerMenuSelectedGamerTagAlreadyFriend");

    else
      myRoot.OpenMenu("XIDInterf.XIIIMenuLivePlayerMenuSelectedGamerTagNothing");

    return true;
  }


/*enum eFriendStatus
{
  FRIENDSTATUS_receivedinvitation,
  FRIENDSTATUS_receivedfriendrequest,
  FRIENDSTATUS_sentinvitation,
  FRIENDSTATUS_sentfriendrequest,
  FRIENDSTATUS_onlinefriendsignedin,
  FRIENDSTATUS_offline,
  FRIENDSTATUS_none
};
*/
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
	        myRoot.CloseMenu(true);
    	    return true;
	    }
	    if (Key==0x25/*IK_Left*/)
	    {
        myRoot.CloseMenu(true);
        myRoot.OpenMenu("XIDInterf.XIIIMenuLiveOldPlayerList");
    	  return true;
	    }
	    if (Key==0x27/*IK_Right*/)
	    {
        myRoot.CloseMenu(true);
        myRoot.OpenMenu("XIDInterf.XIIIMenuLiveFriendsMainPage");
    	  return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



