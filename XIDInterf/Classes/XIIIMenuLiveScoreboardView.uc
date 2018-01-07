class XIIIMenuLiveScoreboardView extends XIIILiveWindow;

var string TitleText;
//var XIIIGUIMultiListBox listbox;
var int leaderboardsize;

var int toprankvalue;

var texture WhiteTex;

var int    statReady[12];
var string statNames[12];
var int    statKills[12];
var int    statDeaths[12];
var int    statGames[12];
var int    statGamesWon[12];
var int    statMinutes[12];
var int    statFlagsCaptured[12];
var int    statFlagsReturned[12];
var int    statSuicide[12];
var int	   statRank[12];

var localized string strName;
var localized string strKills;
var localized string strDeaths;
var localized string strGames;
var localized string strGamesWon;
var localized string strMinutes;
var localized string strFlagsCaptured;
var localized string strFlagsReturned;
var localized string strSuicide;

var int pageMode; // 0 and 1 so we can fit all the stats we want
var bool isUserStats; //so we can see whether it's user stats or overall stats

var localized string strFetching;

var localized string strTitle[5];

var XboxLiveManager.eGameType  gameType;


function Created()
{
  local int i;
  Super.Created();
}


function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  local int i,j;

  Super.InitComponent(MyController, MyOwner);
	OnClick = InternalOnClick;
}

event HandleParameters(string Param1, string Param2)
{
	if ( Param1=="user" )
	{
          isUserStats = true;
	}
	else
	  isUserStats = false;
}

function ShowWindow()
{
  local int q;

  OnMenu = 0; myRoot.bFired = false;
  Super.ShowWindow();
  bShowBCK = true;
  bShowRUN = false;
  bShowSEL = false;

  pageMode = 0;

  leaderboardsize = xboxlive.StatsGetLeaderboardSize();
  if (leaderboardsize != -1)
  {
    toprankvalue    = xboxlive.StatsGetActiveUserRank();
    //xboxlive.StatsSetRequestedRank(toprankvalue);
  }
  for (q=0; q<12; q++)
    statReady[q] = 0;

  gameType = xboxlive.GetStatisticsType();

  if (gameType == GT_DM)
  {
    TitleText = strTitle[0];
  }
  else if (gameType == GT_TeamDM)
  {
    TitleText = strTitle[1];
  }
  else if (gameType == GT_CTF)
  {
    TitleText = strTitle[2];
  }
  else if (gameType == GT_Sabotage)
  {
    TitleText = strTitle[3];
  }
  else if (gameType == GT_Ladder)
  {
    TitleText = strTitle[4];
  }
  else  // Must never happen!
    TitleText = "";

}

function ScrollStatsPage(bool scrollUp)
{
  local int q;

  if (leaderboardsize < 1)
    return;

  for (q=0; q<12; q++)
    statReady[q] = 0;

  if (scrollUp)
  {
    toprankvalue -= 12;
    if (toprankvalue < 1)
      toprankvalue = 1;
    //else if (toprankvalue == 0)
      //toprankvalue = 1;
  }
  else
  {
    if((toprankvalue + 12) <= leaderboardsize)
    {
      toprankvalue += 12;
      //don't really need this check now do we
      if(toprankvalue > leaderboardsize)
        toprankvalue = leaderboardsize;
    }
    //else
    //{
    //  if((leaderboardsize - 12) > 1)
    //	toprankvalue = leaderboardsize - 12;
    //  else if(leaderboardsize < 12)
    //    toprankvalue = 12 - leaderboardsize;

    //  if(toprankvalue > leaderboardsize)
    //    toprankvalue = leaderboardsize;
    //}
  }

  xboxlive.StatsSetRequestedRank(toprankvalue);
}

function Paint(Canvas C, float X, float Y)
{
local int q;
local int userpos;

  Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);


  C.bUseBorder = true;

  C.DrawColor = WhiteColor;

  C.DrawColor.A = 210;
  C.Style = 5; //ERenderStyle.STY_Alpha;

  C.SetPos(45, 100);
  C.DrawTile( WhiteTex, 550, 26, 0, 0, 8, 8 );

  //C.DrawColor.A = 128;

  C.SetPos(45, 130);
  C.DrawTile( WhiteTex, 550, 250, 0, 0, 8, 8 );

  C.Style = 1; //ERenderStyle.STY_Normal;



  C.DrawColor = BlackColor;

  //C.SetPos(50, 100);
  //C.DrawText("", false);

//  C.Font = font'XIIIFonts.XIIISmallFont';


  C.SetPos(130, 100);
  C.DrawText(strName, false);

  if (gameType == GT_CTF)
  {
    if (pageMode == 0)
    {
      C.SetPos(350, 100);
      C.DrawText(strFlagsCaptured$" / "$strFlagsReturned, false);

      C.SetPos(510, 100);
      C.DrawText(strSuicide, false);
    }
    else
    if (pageMode == 1)
    {
      C.SetPos(350, 100);
      //C.DrawText(strGames$" / "$strGamesWon, false);
      C.DrawText(strGames, false);

      C.SetPos(510, 100);
      C.DrawText(strMinutes, false);
    }
    else
    if (pageMode == 2)
    {
      C.SetPos(350, 100);
      C.DrawText(strKills$" / "$strDeaths, false);
    }

  }
  else //if (gameType == GT_DM || gameType == GT_TeamDM || gameType == GT_Sabotage)
  {

    if (pageMode == 0)
    {
      C.SetPos(350, 100);
      C.DrawText(strKills$" / "$strDeaths, false);

      C.SetPos(510, 100);
      C.DrawText(strSuicide, false);
    }
    else
    {
      C.SetPos(350, 100);
      //C.DrawText(strGames$" / "$strGamesWon, false);
      C.DrawText(strGames, false);

      C.SetPos(510, 100);
      C.DrawText(strMinutes, false);
    }

//    C.SetPos(420, 100);
//    C.DrawText(strFlagsCaptured$" / "$strFlagsReturned, false);
  }
//  C.Font = font'XIIIFonts.PoliceF16';


  if (leaderboardsize == -1)
  {
    leaderboardsize = xboxlive.StatsGetLeaderboardSize();
    if (leaderboardsize < 1)
    {
      C.DrawColor = WhiteColor;
      return;
    }
    toprankvalue    = xboxlive.StatsGetActiveUserRank();
    //xboxlive.StatsSetRequestedRank(toprankvalue);
  }

  if (leaderboardsize == 0)
  {
    C.DrawColor = WhiteColor;
    return;
  }

  for (q=0; q<12; q++)
  {

    if (toprankvalue+q >= leaderboardsize)
      break;

    if (statReady[q] == 0 && xboxlive.StatsIsRankReady(toprankvalue+q))
    {
      statNames[q]   = xboxlive.StatsGetResultName(toprankvalue+q);
      
      statKills[q]   = xboxlive.StatsGetResultKills(toprankvalue+q);
      statDeaths[q]  = xboxlive.StatsGetResultDeaths(toprankvalue+q);
      statSuicide[q] = xboxlive.StatsGetResultSuicides(toprankvalue+q);
      statGames[q]   = xboxlive.StatsGetResultGames(toprankvalue+q);
      statGamesWon[q]= xboxlive.StatsGetResultGamesWon(toprankvalue+q);
      statMinutes[q] = xboxlive.StatsGetResultMinutes(toprankvalue+q);
      
      statFlagsCaptured[q] = xboxlive.StatsGetResultFlagsCap(toprankvalue+q);
      statFlagsReturned[q] = xboxlive.StatsGetResultFlagsRet(toprankvalue+q);
      
      statRank[q] = xboxlive.StatsGetResultPosition(toprankvalue+q);

      statReady[q] = 1;
    }

    if (statReady[q] == 1)
    {
      if(isUserStats == true)
      {
        userpos = xboxlive.StatsGetActiveUserRank();
        if((userpos >= toprankvalue) && (userpos <= toprankvalue+12) && (userpos == statRank[q]))
        {
          C.bUseBorder = false;
          C.Style = 5;
          C.DrawColor = WhiteColor;
          C.SetPos(45, 133 + q*20);
          C.DrawTile( WhiteTex, 550, 19, 0, 0, 8, 8 );
          C.DrawColor = BlackColor;
          C.Style = 1;
          C.bUseBorder = true;
        }
      }
  
      C.SetPos(50, 131 + q*20);
      C.DrawText(statRank[q], false);
      //C.DrawText(q + toprankvalue, false);

      C.SetPos(130, 131 + q*20);
      C.DrawText(statNames[q], false);

      if (pageMode == 0)
      {
      	C.SetPos(350, 131 + q*20);
      	if (gameType == GT_CTF)
      	  C.DrawText(statFlagsCaptured[q] $"/"$statFlagsReturned[q], false);
      	else
          C.DrawText(statKills[q] $"/"$statDeaths[q], false);

        C.SetPos(510, 131 + q*20);
        C.DrawText(statSuicide[q], false);
      }
      else
      if (pageMode == 1)
      {
        C.SetPos(350, 131 + q*20);
        //C.DrawText(statGames[q]$"/"$statGamesWon[q], false);
        C.DrawText(statGames[q], false);

        C.SetPos(510, 131 + q*20);
        C.DrawText(statMinutes[q], false);
      }
      else
      if (pageMode == 2)
      {
      	C.SetPos(350, 131 + q*20);
      	//don't really need this check as only ctf can have pagemode2...but ya
      	if (gameType == GT_CTF)
          C.DrawText(statKills[q] $"/"$statDeaths[q], false);
      }

    }
    else
    {
      C.SetPos(50, 131 + q*20);
      C.DrawText(q + toprankvalue, false);

      C.SetPos(100, 131 + q*20);
      C.DrawText(strFetching, false);

    }
  }


  //C.SetPos(48, 382);
  //C.SetPos(230, 412);
  //C.DrawText(strUpDown, false);


  C.DrawColor = WhiteColor;

}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    local int i;
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
	    	xboxlive.StatsStopCachingLeaderboard();
	        myRoot.CloseMenu(true);
    	    return true;
	    }
	    if (Key==0x26/*IK_Up*/)
	    {
          ScrollStatsPage(true);
    	    return true;
	    }
	    if (Key==0x28/*IK_Down*/)
	    {
          ScrollStatsPage(false);
    	    return true;
	    }
	    if (Key==0x25/*IK_Left*/)
	    {
              if (gameType == GT_CTF)
              {
              	pageMode--;
              	if(pageMode < 0)
              	  pageMode = 2;
              }
              else
              {
	      if (pageMode == 0)
	        pageMode = 1;
	      else
	        pageMode = 0;
              }

    	  return true;
	    }
	    if (Key==0x27/*IK_Right*/)
	    {
	      if (gameType == GT_CTF)
              {
              	pageMode++;
              	if(pageMode > 2)
              	  pageMode = 0;
              }
              else
              {
	      if (pageMode == 0)
	        pageMode = 1;
	      else
	        pageMode = 0;
              }

    	  return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



