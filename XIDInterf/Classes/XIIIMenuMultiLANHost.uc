//============================================================================
// Host LAN game menu (XBOX)
//
//============================================================================
class XIIIMenuMultiLANHost extends XIIIMenuMultiBase;


var config string Map;
var config int GameTypeIndex;

var XIIIComboControl GameCombo, MapCombo;
var XIIICheckboxControl FriendlyCheck;
var XIIIValueControl PlayerCombo, FragEdit, TimeEdit;
var XIIIButton StartGame;
VAR XIIIEditCtrl ServerNameEdit;

var Array<string> MapsUNRList;
var XIIIMsgBox msgbox;

var localized string networkcableDisconnectedString;

var bool bMsgDisconnectedDisplayed;

var localized string TitleText, GameText, MapText, PlayerText, FriendlyText, FragText, TimeText, StartText, ServerNameText;

var texture tBackGround[7], tHighlight;
var string sBackground[7], sHighlight;

var bool Initialized;

var int OnPlayer, OnGame, OnMap, OnFrag, OnTime, MaxPlayerValue;

var int MaxPlayers, WinningScore, MaxTime, NbBots, IdealPC, N, FriendlyFire, FragLimit, TimeLimit;

var string URL;



//============================================================================
function Created()
{
    local int i,y;

    Super.Created();
    
    bMsgDisconnectedDisplayed = false;

	AllowedGameTypeIndex[0]=DeathmatchIndex;
	AllowedGameTypeIndex[1]=TeamDeathmatchIndex;
	AllowedGameTypeIndex[2]=CaptureTheFlagIndex;
	AllowedGameTypeIndex[3]=SabotageIndex;

    bShowBCK = true;
    bShowSEL = true;

	for (i=0; i<7; i++)
		tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));

	tHighlight = texture(DynamicLoadObject(sHighlight, class'Texture'));

	y=70;
	// ServerName
	ServerNameEdit = XIIIEditCtrl(CreateControl(class'XIIIEditCtrl', 288, y*fScaleTo, 300, 28));
	ServerNameEdit.TitleText= ServerNameText;
	ServerNameEdit.Text = "XIIIServer";
	ServerNameEdit.bCalculateSize = false;
	ServerNameEdit.FirstBoxWidth = 160;

	y+=45;

	// Players
	PlayerCombo = XIIIValueControl(CreateControl(class'XIIIValueControl', 288, y*fScaleTo, 300, 32));
	PlayerCombo.Text = PlayerText;
	PlayerCombo.bCalculateSize = false;
	PlayerCombo.FirstBoxWidth = 200;
	y+=45;

	// Game Type
	GameCombo = XIIIComboControl(CreateControl(class'XIIIComboControl', 288, y*fScaleTo, 300, 32));
	GameCombo.Text = GameText;
	//GameCombo.bSmallFont = true;
	GameCombo.bArrows = true;
	y+=45;
	
	// Map
	MapCombo = XIIIComboControl(CreateControl(class'XIIIComboControl', 288, y*fScaleTo, 300, 32));
	MapCombo.Text = MapText;
	MapCombo.bArrows = true;
	MapCombo.bCalculateSize = false;
	MapCombo.FirstBoxWidth = 160;
	y+=45;

	// Frag Limit
	FragEdit = XIIIValueControl(CreateControl(class'XIIIValueControl', 288, y*fScaleTo, 300, 32));
	FragEdit.Text = FragText;
	FragEdit.bCalculateSize = false;
	FragEdit.FirstBoxWidth = 200;
	FragEdit.SetRange(0,500);
	y+=45;

	// Time Limit
	TimeEdit = XIIIValueControl(CreateControl(class'XIIIValueControl', 288, y*fScaleTo, 300, 32));
	TimeEdit.Text = TimeText;
	TimeEdit.bCalculateSize = false;
	TimeEdit.FirstBoxWidth = 175;
	TimeEdit.SetRange(0,60);
	y+=45;

	// friendly fire
	FriendlyCheck = XIIICheckboxControl(CreateControl(class'XIIICheckboxControl', 288, y*fScaleTo, 300, 29));
	FriendlyCheck.Text = FriendlyText;
	FriendlyCheck.bWhiteColorOnlyWhenFocused = true;
y+=45;

	// start game button
	StartGame = XIIIButton(CreateControl(class'XIIIButton', 360, y*fScaleTo, 140, 32));
	StartGame.Text = StartText;

Controls[0] = ServerNameEdit;
	Controls[1] = PlayerCombo;
	Controls[2] = GameCombo;
	Controls[3] = MapCombo;
	Controls[4] = FragEdit;
	Controls[5] = TimeEdit;
	Controls[6] = FriendlyCheck;
	Controls[7] = StartGame;

	IterateGames();

	AfterCreate();

	GotoState('ReinitMusic');
}

FUNCTION IterateGames()
{
	local int i;
	
	for (i=0;i<AllowedGameTypeIndex.Length;i++)
	{
		GameCombo.AddItem(GetGameTypeText(i));
	}

	OnGame = 0;
	GameCombo.SetSelectedIndex(0);
	
	Initialized = true;
	GameChanged();
}

FUNCTION IterateMaps()
{
	LOCAL Array<string> MapDescList;
	LOCAL int i;

	GetMapArray( OnGame, MapDescList, MapsUNRList );

	MapCombo.Clear();
	for( i=0; i<MapDescList.Length; i++ )
		MapCombo.AddItem( MapDescList[i] );

	OnMap = 0;
	MapCombo.SetSelectedIndex(0);
}

function AfterCreate()
{
	OnMenu = 0;
	
	IdealPC = int( Mid( MapCombo.GetValue(), 1 ) );
	PlayerCombo.SetRange(1,int(Mid(MapCombo.GetValue(),1)));
	
	OnPlayer = Max(1,IdealPC);
	PlayerCombo.SetValue(OnPlayer);
	
	OnFrag = WinningScore;
	FragEdit.SetValue(OnFrag);
	if (OnFrag == 0)
		FragEdit.sValue ="-";
	
	OnTime = MaxTime;
	TimeEdit.SetValue(OnTime);
	if (OnTime == 0)
		TimeEdit.sValue ="-";
	else
		TimeEdit.sValue = TimeEdit.sValue@"Min.";
}

function MsgBoxBtnClicked(byte bButton)
{
    if ((bButton & QBTN_Ok) != 0)       // ok to overwrite
    {
        bMsgDisconnectedDisplayed = false;
        myRoot.CloseMenu();
    }
}

function Paint(Canvas C, float X, float Y)
{
    local float fScale, fHeight, W, H;
    local int i;

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


	DrawStretchedTexture(C, 253*fRatioX, 54*fRatioY, 353*fRatioX, 377*fScaleTo*fRatioY, myRoot.tFondNoir);

	fHeight = (373 / 192) * 64 * fScaleTo; // (sum_back.height/sum_tex.height) * tex_height
	DrawStretchedTexture(C, 255*fRatioX, 56*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[0]);
	DrawStretchedTexture(C, 255*fRatioX, (56+fHeight)*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[1]);
	DrawStretchedTexture(C, 255*fRatioX, (56+2*fHeight)*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[2]);

	OnMenu = FindComponentIndex(FocusedControl);
	C.Style = 5;
	C.DrawColor.A = 180;
	DrawStretchedTexture(C, 255*fRatioX, ((65+OnMenu*45)*fScaleTo)*fRatioY, 349*fRatioX, 40*fRatioY, tHighlight);//OnMenu]);
	C.DrawColor.A = 255;
	DrawStretchedTexture(C, 41*fRatioX, 88*fRatioY, 242*fRatioX, 170*fScaleTo*fRatioY, tBackGround[5]);
	DrawStretchedTexture(C, 41*fRatioX, (88+170*fScaleTo)*fRatioY, 242*fRatioX, 170*fScaleTo*fRatioY, tBackGround[6]);
	C.Style = 1;

	C.bUseBorder = true;
	C.TextSize(TitleText, W, H);
	DrawStretchedTexture(C, (155-W*0.5-5)*fRatioX, 40*fRatioY, (W+10)*fRatioX, 40*fRatioY, myRoot.FondMenu);
	C.DrawColor = BlackColor;
	C.SetPos( 155-W*0.5*fRatioX, (60-H/2)*fRatioY);
	C.DrawText( TitleText, false);
	C.bUseBorder = false;
	C.DrawColor = WhiteColor;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	local int OldOnGame;
	
	if ((State==1) || (state==2))// IST_Press // to avoid auto-repeat
	{
		if (Key==0x0D/*IK_Enter*/)
		{
			if (FocusedControl == StartGame && Len(ServerNameEdit.Text)>=1)// at least one letter
				StartPressed();
			return true;
		}
		if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
		{
			myRoot.CloseMenu(true);
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
		if ((Key==0x25) || (Key==0x27))
		{
			OnMenu = FindComponentIndex(FocusedControl);
			if (FocusedControl==PlayerCombo)
			{
				if (Key==0x25) OnPlayer--;
				if (Key==0x27) OnPlayer++;
				OnPlayer = Clamp(OnPlayer,1,int(Mid(MapCombo.GetValue(),1)));
				PlayerCombo.SetValue(OnPlayer);
			}
			else if (FocusedControl==GameCombo)
			{
				OldOnGame = OnGame;
				if (Key==0x25) OnGame--;
				if (Key==0x27) OnGame++;
				OnGame = Clamp(OnGame,0,AllowedGameTypeIndex.Length - 1);
				if ( OldOnGame != OnGame )
				{
					GameCombo.SetSelectedIndex(OnGame);
					GameChanged();
					OnPlayer = Clamp(OnPlayer,1,int(Mid(MapCombo.GetValue(),1)));
					PlayerCombo.SetRange(1,int(Mid(MapCombo.GetValue(),1)));
					PlayerCombo.SetValue(OnPlayer);
				}
			}
			else if (FocusedControl == MapCombo )
			{
				if (Key==0x25) OnMap--;
				if (Key==0x27) OnMap++;
				OnMap = Clamp(OnMap,0,MapsUNRList.Length - 1);
				MapCombo.SetSelectedIndex(OnMap);
				OnPlayer = Clamp(OnPlayer,1,int(Mid(MapCombo.GetValue(),1)));
				PlayerCombo.SetRange(1,int(Mid(MapCombo.GetValue(),1)));
				PlayerCombo.SetValue(OnPlayer);
			}
			if (FocusedControl == FragEdit )
			{
				if (Key==0x25)
					if ( OnFrag <= 100 )
						OnFrag -= 10;
					else
						OnFrag -= 50;
				if (Key==0x27)
					if ( OnFrag >= 100 )
						OnFrag += 50;
					else
						OnFrag += 10;
				OnFrag = Clamp(OnFrag,0,500);
				FragEdit.SetValue(OnFrag);
				if (OnFrag == 0) FragEdit.sValue ="-";
			}
			else if (FocusedControl == TimeEdit )
			{
				if (Key==0x25) OnTime-=5;
				if (Key==0x27) OnTime+=5;
				OnTime = Clamp(OnTime,0,60);
				TimeEdit.SetValue(OnTime);
				if (OnTime == 0)
					TimeEdit.sValue ="-";
				else
					TimeEdit.sValue = TimeEdit.sValue@"Min.";
			}
			else if (FocusedControl == FriendlyCheck )
			{
				if (Key==0x25)
					FriendlyCheck.bChecked = true;
				else
					if (Key==0x27)
						FriendlyCheck.bChecked = false;
			}
			return true;
		}
	}
	return super.InternalOnKeyEvent(Key, state, delta);
}


function GameChanged()
{
	local int CurrentGame, i;

	if (Initialized)
	{
		OnMap = 0;
		Initialized=false;

		CurrentGame = GameCombo.GetSelectedIndex();

		if (MapCombo != None)
			IterateMaps();

		// friendly fire is visible in Team Deathmatch, Capture The Flag and Sabotage modes
		if ( HasFriendlyFire( OnGame ) )
		{
			FriendlyCheck.bNeverFocus = false;
			FriendlyCheck.bVisible = true;
		}
		else
		{
			FriendlyCheck.bNeverFocus = true;
			FriendlyCheck.bVisible = false;
		}

		// time limit and points limit are not visible in Sabotage mode
		if ( HasTimeAndFragLimits( OnGame ) )
		{
			TimeEdit.bNeverFocus = false;
			TimeEdit.bVisible = true;
			FragEdit.bNeverFocus = false;
			FragEdit.bVisible = true;
		}
		else
		{
			TimeEdit.bNeverFocus = true;
			TimeEdit.bVisible = false;			
			FragEdit.bNeverFocus = true;
			FragEdit.bVisible = false;
		}
		Initialized = true;
	}
}


function MapChanged()
{
     if (Initialized)
     {
		 Map = MapsUNRList[OnMap];
     }
}


function FragChanged()
{
     if (Initialized)
     {
          FragEdit.SetValue(OnFrag);
		  if (OnFrag == 0)
			  FragEdit.sValue ="-";	
     }
}


function TimeChanged()
{
     if (Initialized)
     {
          TimeEdit.SetValue(OnTime);
		  if (OnTime == 0)
			  TimeEdit.sValue ="-";
		  else
			  TimeEdit.sValue = TimeEdit.sValue@"Min.";
     }
}



function StartPressed()
{
	local int i, N, IdealPC, FriendlyFire;
	local string MyClass, SkinCode, AdminPassword, MyName, Mutator, MyTeam;

    N = PlayerCombo.GetValue();

	IdealPC = int( Mid( MapCombo.GetValue(), 1 ) );

	FriendlyFire = int(FriendlyCheck.bChecked);

	// one viewport only
    GetPlayerOwner().ConsoleCommand("SetViewPortNumberForNextMap "$1);

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

	MapChanged();
	TimeChanged();
	FragChanged();

	URL =
		Map$
		"?listen"$
		"?LAN"$
		"?SN="$ServerNameEdit.Text$
		"?Game="$GetGameInfoText(OnGame)$
		"?GameIdx="$OnGame$
		"?MapIdx="$GameMapsIndex[OnMap]$
		"?IP="$IdealPC$
		"?NP="$N$
		"?FF="$FriendlyFire$
		"?FR="$OnFrag$
		"?TI="$OnTime$
		"?SK="$SkinCode;
	Mutator = GetMutatorText( OnGame );
	if ( Mutator!="" )
		URL = URL$"?Mutator="$Mutator;

	// name selection
	MyName = GetPlayerOwner().GetDefaultURL("MyName");
	if (MyName == "")
		MyName = GetPlayerOwner().GetDefaultURL("Name");
	URL = URL$"?Name="$MyName;

	// team selection
	MyTeam = GetPlayerOwner().GetDefaultURL("MyTeam");
	if (MyTeam == "")
		MyTeam = GetPlayerOwner().GetDefaultURL("Team");
	URL = URL$"?team="$MyTeam;

    SaveConfigs();

    AdminPassword = GenerateAdminPassword();        // one shot password
    URL = URL$"?AdminPassword="$AdminPassword$"?Password="$AdminPassword;

	// launch the server !!
	myRoot.bProfileMenu = false;
	myRoot.CloseAll(true);
	myRoot.GotoState('');
	GetPlayerOwner().AttribPadToViewport();
	log("TRAVELLING w/URL: "$URL);
	GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
}



function string GenerateAdminPassword()
{
    local int i;
    local string Source, Result;

    Source = "0123456789abcdefghijklmnopqrstuvwxyz";

    for (i=Rand(20)+10; i>0; i--)
    {
        Result = Result$Mid(Source, Rand(Len(Source)-1), 1);
    }

    return Result;
}



function SaveConfigs()
{
     SaveConfig();
     GetPlayerOwner().SaveConfig();
     GetPlayerOwner().PlayerReplicationInfo.SaveConfig();
}



// if subclassed, this parent function must always be called first
function string GetPageParameters()
{
    return Super.GetPageParameters()$"?NbOfPlayers="$PlayerCombo.GetValue()$"?GameType="$GameCombo.GetSelectedIndex()$"?MapName="$MapCombo.GetSelectedIndex()$"?FragLimit="$FragEdit.GetValue()$"?TimeLimit="$TimeEdit.GetValue()$"?Friendly="$FriendlyCheck.bChecked$"?ServerName="$ServerNameEdit.Text;
}

// if GetPageParameters() is subclassed, you'd better have this one too !
function SetPageParameters(string PageParameters)
{
    log("SetPageParameters("$PageParameters$") called for "$self);

    OnGame = int(localParseOption(PageParameters, "GameType", "0"));
    GameCombo.SetSelectedIndex(OnGame);
    GameChanged();

    OnMap = int(localParseOption(PageParameters, "MapName", "0"));
    MapCombo.SetSelectedIndex(OnMap);
    MapChanged();
	PlayerCombo.SetRange(1,int(Mid(MapCombo.GetValue(),1)));

    OnPlayer = int(localParseOption(PageParameters, "NbOfPlayers", "1"));
    PlayerCombo.SetValue(OnPlayer);

    OnFrag = int(localParseOption(PageParameters, "FragLimit", "0"));
    //FragEdit.SetValue(OnFrag);
    FragChanged();

    OnTime = int(localParseOption(PageParameters, "TimeLimit", "0"));
    //TimeEdit.SetValue(OnTime);
    TimeChanged();

    FriendlyCheck.bChecked = (Caps(localParseOption(PageParameters, "Friendly", "")) == "TRUE");

    ServerNameEdit.SetText( localParseOption( PageParameters, "ServerName", "XIIIServer") );
}








defaultproperties
{
     TitlePCText="LAN Host"
     GameText="Game Type"
     MapText="Map Name"
     PlayerText="Number of Player(s)"
     FriendlyText="Friendly Fire"
     FragText="Points Limit"
     TimeText="Time Limit"
     OKText="Create"
     ServerNameText="Server Name"
     sBackground(0)="XIIIMenuStart.multi_Bg01"
     sBackground(1)="XIIIMenuStart.multi_Bg02"
     sBackground(2)="XIIIMenuStart.multi_Bg03"
     sBackground(5)="XIIIMenuStart.Characters01"
     sBackground(6)="XIIIMenuStart.Characters02"
     sHighlight="XIIIMenuStart.barreselectmenuoptadv"
     WinningScore=10
     MaxTime=5
     MaxScore=10
     bUseDefaultBackground=False
     hSoundMenu2=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hMulti2'
     bForceHelp=True
}
