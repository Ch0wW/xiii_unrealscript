class XIIIMenuLiveScoreboard extends XIIILiveWindow;

var localized string TitleText;

//actual word
var localized string kills, deaths, suicides, gamesplayed, gameswon, minutesplayed, flagscapt, flagsret;
// s_ = symbol
var localized string s_kills, s_deaths, s_suicides, s_gamesplayed, s_gameswon, s_minutesplayed, s_flagscapt, s_flagsret;

var XIIIGUIButton Buttons[5];
var localized string ButtonNames[5];

function Created()
{
  local int i;
  Super.Created();
}


function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  Super.InitComponent(MyController, MyOwner);
	OnClick = InternalOnClick;
	
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
}


function ShowWindow()
{
     OnMenu = 0; myRoot.bFired = false;
     Super.ShowWindow();
     bShowBCK = true;
     bShowRUN = false;
     bShowSEL = true;
}


function Paint(Canvas C, float X, float Y)
{
  local int hpos;
  Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);
  
  hpos = 242;
  
  C.SetPos(290, (hpos));
  C.DrawText(s_kills$" - "$kills, false);
  
  C.SetPos(290, (hpos+=20));
  C.DrawText(s_deaths$" - "$deaths, false);
  
  C.SetPos(290, (hpos+=20));
  C.DrawText(s_suicides$" - "$suicides, false);
  
  C.SetPos(290, (hpos+=20));
  C.DrawText(s_gamesplayed$" - "$gamesplayed, false);
  
  //C.SetPos(290, (hpos+=20));
  //C.DrawText(s_gameswon$" - "$gameswon, false);

  C.SetPos(290, (hpos+=20));
  C.DrawText(s_minutesplayed$" - "$minutesplayed, false);
  
  C.SetPos(290, (hpos+=20));
  C.DrawText(s_flagscapt$" - "$flagscapt, false);
  
  C.SetPos(290, (hpos+=20));
  C.DrawText(s_flagsret$" - "$flagsret, false);
}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    local int i;
    if (Sender == Buttons[0])
    {
      xboxlive.SetLadderGame(false);
      xboxlive.SetStatisticsType(GT_DM);
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveScoreboardMain");
    }
    else if (Sender == Buttons[1])
    {
      xboxlive.SetLadderGame(false);
      xboxlive.SetStatisticsType(GT_TeamDM);
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveScoreboardMain");
    }
    else if (Sender == Buttons[2])
    {
      xboxlive.SetLadderGame(false);
      xboxlive.SetStatisticsType(GT_CTF);
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveScoreboardMain");
    }
    else if (Sender == Buttons[3])
    {
      xboxlive.SetLadderGame(false);
      xboxlive.SetStatisticsType(GT_Sabotage);
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveScoreboardMain");
    }
    else if (Sender == Buttons[4])
    {
      xboxlive.SetLadderGame(true);
      xboxlive.SetStatisticsType(GT_Ladder);
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveScoreboardMain");
    }
    /*else if (Sender == Buttons[4])
    {
      xboxlive.SetStatisticsType(GT_Duel);
      Controller.OpenMenu("XIDInterf.XIIIMenuLiveScoreboardMain");
    }*/
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




