//===========================================================================
// Player Configuration in multiplayer mode (both online and splited)
//===========================================================================
class XIIIMenuProfileClient extends XIIIWindow;

// Game Information
var config string GameType;

// Player Name
//var UWindowEditControl NameEdit;
//var localized string NameText;

// Skin & Team
var XIIIComboControl ClassCombo, TeamCombo;

var XIIIButton OptionsButton;
var localized string ClassText, TeamText, OptionsText;
var string PlayerBaseClass;

var int ControlOffset;
var bool Initialized, bTeamGame;

var int OnSkin, MaxSkin, OnTeam;

var texture tHighlight;
var string sHighlight;

var color PadColor;

var texture tBackGround[4];
var string sBackground[4];

//var XIIIMenuSplitSetupClient PWin;
var bool bOnline;

function MsgBoxBtnClicked(byte bButton)
{
  switch (bButton)
  {
    case QBTN_Ok:
      //log("[XIIIMsgBox] Ok pressed");
      //xboxlive.ShutdownAndCleanup();
      //Controller.ReplaceMenu("XIDInterf.XIIIMenuLiveAccountWindow");
    break;
  }
  //log("msgbox clicked: "$bButton);
}

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
  local int i;
	
	Super.Initcomponent(pMyController, MyOwner);
  for (i=0; i<4; i++)
    tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));

  // Why do I have to set these? They are 0 at the moment. Only valid inside the render or what?
  fRatioX = 1.0;
  fRatioY = 1.0;
}

function Created()
{
     local float A;
     Super.Created();

     tHighlight = texture(DynamicLoadObject(sHighlight, class'Texture'));

     // Player Name
     ControlOffset += 50;
/*     NameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
     NameEdit.SetText(NameText);
     NameEdit.SetFont(F_Normal);
     NameEdit.SetNumericOnly(False);
     NameEdit.SetMaxLength(20);
     NameEdit.SetDelayedNotify(True);
     NameEdit.SetValue(GetPlayerOwner().PlayerReplicationInfo.PlayerName);
*/
     ControlOffset += 60;
     // Game Type
     ClassCombo = XIIIComboControl(CreateControl(class'XIIIComboControl', 70, ControlOffset, 500, 40));
     ClassCombo.Text = ClassText;
     ClassCombo.bArrows = true;
     LoadClasses();

     ControlOffset += 60;
     TeamCombo = XIIIComboControl(CreateControl(class'XIIIComboControl', 70, ControlOffset, 500, 40));
     TeamCombo.Text = TeamText;
     TeamCombo.bArrows = true;
     TeamCombo.AddItem("Red Team");//, String(0));
     TeamCombo.AddItem("Blue Team");//, String(1));
     TeamCombo.SetSelectedIndex(Max(GetPlayerOwner().PlayerReplicationInfo.Team.TeamIndex, 0));

     ControlOffset += 60;
     OptionsButton = XIIIbutton(CreateControl(class'XIIIbutton', 70, ControlOffset, 220, 40));
     OptionsButton.Text = OptionsText;
     OptionsButton.bUseBorder = true;

     Initialized = True;

     Controls[0] = ClassCombo; Controls[1] = TeamCombo; Controls[2] = OptionsButton;

     switch(int(right(string(GetPlayerOwner()), 1))%4)
     {
        case 1 : A = PadColor.R; PadColor.R = PadColor.G; PadColor.G = A; break;
        case 2 : A = PadColor.G; PadColor.G = PadColor.B; PadColor.B = A; break;
        case 3 : A = PadColor.R; PadColor.R = PadColor.B; PadColor.B = A; break;
     }
}


function LoadClasses()
{
    local int NumPlayerClasses;
    local string NextPlayer, NextDesc;
    local int SortWeight;

    GetPlayerOwner().GetNextIntDesc(PlayerBaseClass, 0, NextPlayer, NextDesc);
    while( (NextPlayer != "") && (NumPlayerClasses < 64) )
    {
        log("Loading..."$NextDesc$"  "$NextPlayer);
        ClassCombo.AddItem(NextDesc, NextPlayer);//, SortWeight);
        NumPlayerClasses++;
        GetPlayerOwner().GetNextIntDesc(PlayerBaseClass, NumPlayerClasses, NextPlayer, NextDesc);
    }
//    ClassCombo.Sort();
    MaxSkin = NumPlayerClasses;
//    log("CURRENT MESH: "$GetPlayerOwner().PawnClass);
    ClassCombo.SetSelectedIndex(ClassCombo.FindItemIndex(string(GetPlayerOwner().PawnClass), true));
}


function ShowWindow()
{
     Super.ShowWindow();
     bShowRUN = true;
     bTeamGame = myRoot.GetLevel().Game.bTeamGame;
     if (!bTeamGame) TeamCombo.bNeverFocus = true;
     GetPlayerOwner().MyHud.bHideHud = true;
}

function PaintGfxBackground(Canvas C, float X, float Y)
{
  local float W, H;
  local float MarginWidth, MarginHeight;

  W = WinWidth;
  H = WinHeight;

  if (W <= 1) W = W*640*fRatioX;
  if (H <= 1) H = H*480*fRatioY;

  C.DrawColor = WhiteColor;
  C.Style = 5;
  MarginWidth = 0;
  MarginHeight = 0;
  C.SetPos(MarginWidth/2, MarginHeight/2);
  C.DrawTileClipped( tBackGround[2], W-MarginWidth, H/2-MarginHeight/2, 0, 0, tBackGround[2].USize, tBackGround[2].VSize);
  C.SetPos(MarginWidth/2, H/2);
  C.DrawTileClipped( tBackGround[3], W-MarginWidth, H/2-MarginHeight/2, 0, 0, tBackGround[3].USize, tBackGround[3].VSize);
  C.bUseBorder = false;
  C.DrawColor = BlackColor;
}

function Paint(Canvas C, float X, float Y)
{
    super.Paint(C, X, Y);

    C.Style = 1;
    C.DrawColor = PadColor;
    DrawStretchedTexture(C, 0, 0, WinWidth*C.ClipX, WinHeight*C.ClipY, myRoot.FondMenu);
    PaintGfxBackground(C, X ,Y);
    C.DrawColor = WhiteColor;
    OnMenu = FindComponentIndex(FocusedControl);
    C.Style = 5;  C.DrawColor.A = 180;
    DrawStretchedTexture(C, 60*fRatioX, (145+OnMenu*60)*fRatioY, 515*fRatioX, 65*fRatioY, tHighlight);
    C.DrawColor.A = 255; C.Style = 1;
}


/*
function NameChanged()
{
     local string N;
     if (Initialized)
     {
          Initialized = False;
          N = NameEdit.GetValue();
          ReplaceText(N, " ", "_");
          NameEdit.SetValue(N);
          Initialized = True;

          GetPlayerOwner().ChangeName(NameEdit.GetValue());
          GetPlayerOwner().UpdateURL("Name", NameEdit.GetValue(), True);
     }
}*/


function UseSelected()
{
    local int NewTeam;

     if (Initialized)
     {
          //GetPlayerOwner().UpdateURL("Class", ClassCombo.GetValue2(), True);
          GetPlayerOwner().PawnClass = class<Pawn>(DynamicLoadObject(ClassCombo.GetValue2(), class'Class'));
          //if (xboxlive.IsLoggedIn(xboxlive.GetCurrentUser()))
          //  myRoot.GetLevel().Game.ChangeName(GetPlayerOwner(), xboxlive.GetCurrentUser(), false);
          //else
          myRoot.GetLevel().Game.ChangeName(GetPlayerOwner(), GetPlayerOwner().PawnClass.default.PawnName, false);
          log("ACt TEAM: "$GetPlayerOwner().PlayerReplicationInfo.Team.TeamIndex$" Wanted Team: "$TeamCombo.GetSelectedIndex());
//          GetPlayerOwner().UpdateURL("Team", string(TeamCombo.GetSelectedIndex()), True);
          NewTeam = TeamCombo.GetSelectedIndex();
//        if( GetPlayerOwner().PlayerReplicationInfo.Team.TeamIndex != NewTeam )
            GetPlayerOwner().ChangeTeam(NewTeam);
          log("Current Team: "$GetPlayerOwner().PlayerReplicationInfo.Team.TeamIndex);
     }
}


function StartPressed()
{
     local string URL, Checksum;

     UseSelected();

//     myRoot.b = true;
     myRoot.CloseAll(true);
     myRoot.GotoState('');
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if (Key==0x0D/*IK_Enter*/)
	    {
            if (FocusedControl == OptionsButton)
            {
                myRoot.OpenMenu("XIDInterf.XIIIMultiControlsWindow");
            }
            else {
                UseSelected();
                myRoot.bProfileMenu = false;
                myRoot.CloseAll(true);
                GetPlayerOwner().MyHud.bHideHud = false;
                myRoot.GotoState('');
            }
//            Controller.FocusedControl.OnClick(Self);
            return true;
	    }
	    if (Key==0x08) // BackSpace
	    {
	        myRoot.bProfileMenu = false;
            myRoot.CloseAll(true);
            myRoot.GotoState('');
    	    GetPlayerOwner().ClientTravel("MapMenu", TRAVEL_Absolute, false);
            myRoot.Master.GlobalInteractions[0].ViewportOwner.Actor.ConsoleCommand("SetViewPortNumberForNextMap 1");
            return true;
	    }
	    if (Key==0x26/*IK_Up*/)
	    {
	        PrevControl(FocusedControl);
    	    return true;
	    }
	    if (Key==0x28/*IK_Down*/)
	    {
	        NextControl(FocusedControl);
    	    return true;
	    }
	    if ((Key==0x25/*IK_Left*/) || (Key==0x27/*IK_Right*/))
	    {
            if (FocusedControl == Controls[0])
	        {
                if (Key==0x25) OnSkin--;
                if (Key==0x27) OnSkin++;
                if (OnSkin < 0) OnSkin = 0;
                if (OnSkin > MaxSkin - 1) OnSkin = MaxSkin - 1;
                classCombo.SetSelectedIndex(OnSkin);
            }
            if (FocusedControl == Controls[1])
	        {
                if (Key==0x25) OnTeam--;
                if (Key==0x27) OnTeam++;
                OnTeam = abs(OnTeam%2);
                TeamCombo.SetSelectedIndex(OnTeam);
            }
            return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
//    return false;
}


function SaveConfigs()
{
//     Super.SaveConfigs();
     GetPlayerOwner().SaveConfig();
     GetPlayerOwner().PlayerReplicationInfo.SaveConfig();
}





defaultproperties
{
     ClassText="Player Class"
     TeamText="Team"
     OptionsText="OPTIONS"
     PlayerBaseClass="XIIIMP.XIIIMPPlayerPawn"
     controloffset=50
     sHighlight="XIIIMenuStart.barreselectmenuoptadv"
     PadColor=(B=143,G=120,R=93)
     bForceHelp=True
     Background=None
     bCheckResolution=True
     bRequire640x480=False
     bAllowedAsLast=True
}
