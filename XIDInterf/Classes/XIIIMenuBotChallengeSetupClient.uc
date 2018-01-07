//===========================================================================
// Bot challenge game setup / one player only / on PC
//===========================================================================
class XIIIMenuBotChallengeSetupClient extends XIIIMenuMultiBase;


var config string Map;
VAR config int GameTypeIndex;

var XIIIComboControl GameCombo, MapCombo;
var XIIICheckboxControl FriendlyCheck;
var XIIIValueControl FragEdit, TimeEdit;
var XIIIButton BotsButton, OKButton;

var int MaxGames, NbMaps;

var localized string TitleText, GameText, MapText, FriendlyText, FragText, TimeText, BotsText, OKText;
VAR Array<string> MapsUNRList;

var texture tBackGround[7], tHighlight;
var string sBackground[7], sHighlight;

var bool Initialized;

var int OnGame, OnMap, OnFrag, OnTime, MaxPlayerValue, PointsLimitFactor;

var int WinningScore, MaxTime, NbBots, IdealPC, N, FriendlyFire, FragLimit, TimeLimit, DefaultConfig;
var int MaxScore;

var int TeamBot[7], NivBot[7];

var Array<int> GameNbPlayers;

var string URL;


//===========================================================================
event HandleParameters(string Param1, string Param2)
{
	if ( Param1 != "" )
	{
		URL = Param1;
		log("Param1="$URL);
		Map = LocalParseOption ( URL, "Map", "");
		// GameTypeIndex = int( localParseOption ( URL, "GameType", "0"));
		IdealPC = int( localParseOption( URL,"IP", "0") );
		N = int( localParseOption( URL,"NP", "0") );
		FriendlyFire = int( localParseOption( URL,"FF", "0") );
		FragLimit = int( localParseOption( URL,"FR", "0") );
		TimeLimit = int( localParseOption( URL,"TI", "0") );
		DefaultConfig = int( localParseOption( URL,"DC", "0") );
		NbBots = int( localParseOption( URL,"NBots", "0") );
		TeamBot[0] = int( localParseOption( URL,"TB0", "1") );
		NivBot[0] = int( localParseOption( URL,"NB0", "1") );
		TeamBot[1] = int( localParseOption( URL,"TB1", "0") );
		NivBot[1] = int( localParseOption( URL,"NB1", "2") );
		TeamBot[2] = int( localParseOption( URL,"TB2", "1") );
		NivBot[2] = int( localParseOption( URL,"NB2", "2") );
		TeamBot[3] = int( localParseOption( URL,"TB3", "0") );
		NivBot[3] = int( localParseOption( URL,"NB3", "0") );
		TeamBot[4] = int( localParseOption( URL,"TB4", "1") );
		NivBot[4] = int( localParseOption( URL,"NB4", "0") );
		TeamBot[5] = int( localParseOption( URL,"TB5", "0") );
		NivBot[5] = int( localParseOption( URL,"NB5", "3") );
		TeamBot[6] = int( localParseOption( URL,"TB6", "1") );
		NivBot[6] = int( localParseOption( URL,"NB6", "3") );

		//MaxBots = IPC - N;
		//log(self@"---> DONNEES"@Map@GameType@IdealPC@N@FragLimit@TimeLimit@NbBots);
		//log(self@"---> NIVEAUX BOTS"@NivBot[0]@NivBot[1]@NivBot[2]@NivBot[3]@NivBot[4]@NivBot[5]@NivBot[6]);
	}
}

function Created()
{
	local int i;
	
	Super.Created();
	
	AllowedGameTypeIndex[0]=DeathmatchIndex;
	AllowedGameTypeIndex[1]=TeamDeathmatchIndex;
	AllowedGameTypeIndex[2]=CaptureTheFlagIndex;
	AllowedGameTypeIndex[3]=TheHuntIndex;
	AllowedGameTypeIndex[4]=SabotageIndex;
	AllowedGameTypeIndex[5]=PowerUpIndex;

	for (i=0; i<7; i++)
		tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));
	
	tHighlight = texture(DynamicLoadObject(sHighlight, class'Texture'));
	
	// Game Type
	GameCombo = XIIIComboControl(CreateControl(class'XIIIComboControl', 288, 96*fScaleTo, 300, 28));
	GameCombo.Text = GameText;
	//GameCombo.bSmallFont = true;
	GameCombo.bArrows = true;
	GameCombo.bCalculateSize = false;
	GameCombo.FirstBoxWidth = 150;
	
	// Map
	MapCombo = XIIIComboControl(CreateControl(class'XIIIComboControl', 288, 141*fScaleTo, 300, 28));
	MapCombo.Text = MapText;
	MapCombo.bArrows = true;
	MapCombo.bCalculateSize = false;
	MapCombo.FirstBoxWidth = 160;
	
	// Frag Limit
	FragEdit = XIIIValueControl(CreateControl(class'XIIIValueControl', 288, 186*fScaleTo, 300, 28));
	FragEdit.Text = FragText;
	FragEdit.bCalculateSize = false;
	FragEdit.FirstBoxWidth = 200;
	//FragEdit.SetRange(0,500);
	
	// Time Limit
	TimeEdit = XIIIValueControl(CreateControl(class'XIIIValueControl', 288, 231*fScaleTo, 300, 28));
	TimeEdit.Text = TimeText;
	TimeEdit.bCalculateSize = false;
	TimeEdit.FirstBoxWidth = 175;
	TimeEdit.SetRange(0,60);

	// Bots setup
	BotsButton = XIIIbutton(CreateControl(class'XIIIbutton', 340, 276*fScaleTo, 180, 28));
	BotsButton.Text = BotsText;
	BotsButton.bUseBorder = true;
	
	// friendly fire
	FriendlyCheck = XIIICheckboxControl(CreateControl(class'XIIICheckboxControl', 288, 321*fScaleTo, 300, 28));
	FriendlyCheck.Text = FriendlyText;
	FriendlyCheck.bWhiteColorOnlyWhenFocused = true;

	// OK go
	OKButton = XIIIbutton(CreateControl(class'XIIIbutton', 360, 366*fScaleTo, 139, 28));
	OKButton.Text = OKText;
	OKButton.bUseBorder = true;


	Controls[0] = GameCombo;
	Controls[1] = MapCombo;
	Controls[2] = FragEdit;
	Controls[3] = TimeEdit;
	Controls[4] = BotsButton;
	Controls[5] = FriendlyCheck;
	Controls[6] = OKButton;

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

	MaxGames = AllowedGameTypeIndex.Length;

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
	GameNbPlayers.Length = 0;
	for( i=0; i<MapDescList.Length; i++ )
	{
		MapCombo.AddItem( MapDescList[i] );
		GameNbPlayers[ i ] = NbPlayers[ GameMapsIndex[ i ] ];
	}

	OnMap = 0;
	MapCombo.SetSelectedIndex(0);
}

function AfterCreate()
{
	OnMenu = 0;
	
/*	OnFrag = WinningScore;
	FragEdit.SetValue(OnFrag);
	if (OnFrag == 0)
		FragEdit.sValue ="-";*/
	
	OnTime = MaxTime;
	TimeEdit.SetValue(OnTime);
	if (OnTime == 0)
		TimeEdit.sValue ="-";
	else
		TimeEdit.sValue = TimeEdit.sValue@"Min.";
}


function Paint(canvas C, float X, float Y)
{
     local float fScale, fHeight, W, H;

     Super.Paint(C,X,Y);

     DrawStretchedTexture(C, 253*fRatioX, 54*fRatioY, 353*fRatioX, 377*fScaleTo*fRatioY, myRoot.tFondNoir);

     fHeight = (373 / 192) * 64 * fScaleTo; // (sum_back.height/sum_tex.height) * tex_height
     DrawStretchedTexture(C, 255*fRatioX, 56*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[0]);
     DrawStretchedTexture(C, 255*fRatioX, (56+fHeight)*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[1]);
     DrawStretchedTexture(C, 255*fRatioX, (56+2*fHeight)*fRatioY, 349*fRatioX, fHeight*fRatioY, tBackGround[2]);

     OnMenu = FindComponentIndex(FocusedControl);
     C.Style = 5;
	 C.DrawColor.A = 180;
     DrawStretchedTexture(C, 255*fRatioX, ((91+OnMenu*45)*fScaleTo)*fRatioY, 349*fRatioX, 40*fRatioY, tHighlight);//OnMenu]);
     C.DrawColor.A = 255;
     DrawStretchedTexture(C, 41*fRatioX, 68*fRatioY, 242*fRatioX, 180*fScaleTo*fRatioY, tBackGround[5]);
     DrawStretchedTexture(C, 41*fRatioX, (68+180*fScaleTo)*fRatioY, 242*fRatioX, 180*fScaleTo*fRatioY, tBackGround[6]);
     C.Style = 1;

	 C.bUseBorder = true;
	 DrawStretchedTexture(C, 140*fRatioX, 20*fRatioY, 180*fRatioX, 40*fRatioY, myRoot.FondMenu);
	 C.TextSize(TitleText, W, H);
	 C.DrawColor = BlackColor;
	 C.SetPos((150 + (160-W)/2)*fRatioX, (40-H/2)*fRatioY);
	 C.DrawText(TitleText, false);
	 C.bUseBorder = false;
	 C.DrawColor = WhiteColor;

}


function ShowWindow()
{
     Super.ShowWindow();

     bShowBCK = true;
     bShowSEL = true;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	local int OldOnGame;
	
	if ((State==1) || (state==2))// IST_Press // to avoid auto-repeat
	{
		if (Key==0x0D/*IK_Enter*/ || Key==1)
		{
			if (FocusedControl == BotsButton)
				GotoBotSetup();
			if (FocusedControl == Controls[6])
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
			if (OnMenu == 0)
			{
				OldOnGame = OnGame;
				if (Key==0x25) OnGame--;
				if (Key==0x27) OnGame++;
				OnGame = Clamp(OnGame,0,MaxGames - 1);
				if ( OldOnGame != OnGame )
				{
					GameCombo.SetSelectedIndex(OnGame);
					GameChanged();
				}
			}
			if ( FocusedControl==MapCombo)
			{
				if (Key==0x25) OnMap--;
				if (Key==0x27) OnMap++;
				OnMap = Clamp(OnMap,0,MapsUNRList.Length - 1);
				MapCombo.SetSelectedIndex(OnMap);
			}
			if (OnMenu == 2)
			{
				if ( Key==0x25 )
					OnFrag -= PointsLimitFactor;
				if ( Key==0x27 )
					OnFrag += PointsLimitFactor;
				OnFrag = Clamp(OnFrag,0,MaxScore*PointsLimitFactor);
				FragEdit.SetValue(OnFrag);
				if (OnFrag == 0) FragEdit.sValue ="-";
			}
			if (OnMenu == 3)
			{
				if (Key==0x25) OnTime -= 5;
				if (Key==0x27) OnTime += 5;
				OnTime = Clamp(OnTime,0,60);
				TimeEdit.SetValue(OnTime);
				if (OnTime == 0)
					TimeEdit.sValue ="-";
				else
					TimeEdit.sValue = TimeEdit.sValue@"Min."; 
			}
			if (OnMenu == 5)
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

		OnFrag = GetDefaultGameTypeValue( OnGame );
		PointsLimitFactor = GetPointsLimitFactor( OnGame );
		FragEdit.SetValue(OnFrag);
		FragEdit.SetRange(0,MaxScore*PointsLimitFactor);

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


function GotoBotSetup()
{
    local string URL;
    local int N,  FriendlyFire;

    N = 1;

	IdealPC = GameNbPlayers[ MapCombo.GetSelectedIndex( ) ]; //int( Mid( MapCombo.GetValue(), 1 ) );

	NbBots = Min(NbBots,IdealPC - N);

	FriendlyFire = int(FriendlyCheck.bChecked);

    MapChanged();
    TimeChanged();
	FragChanged();

	URL =
		"?Map="$Map$
		"?GameTypeIndex="$AllowedGameTypeIndex[OnGame]$
		"?IP="$IdealPC$
		"?NP="$N$
		"?FF="$FriendlyFire$
		"?FR="$OnFrag$
		"?TI="$OnTime$
		"?NBots="$NbBots$
		"?DC="$DefaultConfig$
		"?TB0="$TeamBot[0]$
		"?NB0="$NivBot[0]$
		"?TB1="$TeamBot[1]$
		"?NB1="$NivBot[1]$
		"?TB2="$TeamBot[2]$
		"?NB2="$NivBot[2]$
		"?TB3="$TeamBot[3]$
		"?NB3="$NivBot[3]$
		"?TB4="$TeamBot[4]$
		"?NB4="$NivBot[4]$
		"?TB5="$TeamBot[5]$
		"?NB5="$NivBot[5]$
		"?TB6="$TeamBot[6]$
		"?NB6="$NivBot[6];

    //log(URL);
    myRoot.OpenMenu("XIDInterf.XIIIMenuBotsSetupClient", false, URL);
}


function StartPressed()
{
	LOCAL string URL, MyName, MyClass, SkinCode, Mutator;
	LOCAL int i, N, IdealPC, FriendlyFire;

	N = 1;

	IdealPC = GameNbPlayers[ MapCombo.GetSelectedIndex( ) ]; //int( Mid( MapCombo.GetValue(), 1 ) );
	//IdealPC = 8;

	NbBots = Min(NbBots,IdealPC - N);

	FriendlyFire = int(FriendlyCheck.bChecked);

    GetPlayerOwner().ConsoleCommand("SetViewPortNumberForNextMap "$N);

	MapChanged();
	TimeChanged();
	FragChanged();

	if (( NbBots == 0 ) && ( DefaultConfig == 0 ))
	{
		URL =
			/*"?Map="$*/Map$
			"?Game="$GetGameInfoText(OnGame)$
			"?IP="$IdealPC$
			"?NP="$N$
			"?FF="$FriendlyFire$
			"?FR="$OnFrag$
			"?TI="$OnTime$
			"?NBots="$(IdealPC - N)$
			"?TB0="$1$
			"?NB0="$1$
			"?TB1="$0$
			"?NB1="$2$
			"?TB2="$1$
			"?NB2="$2$
			"?TB3="$0$
			"?NB3="$0$
			"?TB4="$1$
			"?NB4="$0$
			"?TB5="$0$
			"?NB5="$3$
			"?TB6="$1$
			"?NB6="$3;
	}
	else
	{
		URL =
			/*"?Map="$*/Map$
			"?Game="$GetGameInfoText(OnGame)$
			"?IP="$IdealPC$
			"?NP="$N$
			"?FF="$FriendlyFire$
			"?FR="$OnFrag$
			"?TI="$OnTime$
			"?NBots="$NbBots$
			"?TB0="$TeamBot[0]$
			"?NB0="$NivBot[0]$
			"?TB1="$TeamBot[1]$
			"?NB1="$NivBot[1]$
			"?TB2="$TeamBot[2]$
			"?NB2="$NivBot[2]$
			"?TB3="$TeamBot[3]$
			"?NB3="$NivBot[3]$
			"?TB4="$TeamBot[4]$
			"?NB4="$NivBot[4]$
			"?TB5="$TeamBot[5]$
			"?NB5="$NivBot[5]$
			"?TB6="$TeamBot[6]$
			"?NB6="$NivBot[6];
	}

	Mutator = GetMutatorText( OnGame );
	if ( Mutator!="" )
		URL = URL$"?Mutator="$Mutator;

	// skin selection
	MyClass = GetPlayerOwner().GetDefaultURL("Class");
	SkinCode = class'MeshSkinList'.default.MeshSkinListInfo[0].SkinCode;
	for (i=0;i<class'MeshSkinList'.default.MeshSkinListInfo.Length;i++)
	{
		if ( MyClass == class'MeshSkinList'.default.MeshSkinListInfo[i].SkinName )
		{
			SkinCode = class'MeshSkinList'.default.MeshSkinListInfo[i].SkinCode;
			break;
		}
	}
	URL = URL$"?SK="$SkinCode;

	// name selection
	MyName = GetPlayerOwner().GetDefaultURL("Name");
	URL = URL$"?Name="$MyName;

	SaveConfigs();

    myRoot.CloseAll(true);
    myRoot.GotoState('');
    myRoot.bProfileMenu = false;
    GetPlayerOwner().AttribPadToViewport();
    log("TRAVELLING w/URL: "$URL);
    GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
}


// if subclassed, this parent function must always be called first
function string GetPageParameters()
{
    return Super.GetPageParameters()$"?GameType="$GameCombo.GetSelectedIndex()$"?MapName="$MapCombo.GetSelectedIndex()$"?FragLimit="$FragEdit.GetValue()$"?TimeLimit="$TimeEdit.GetValue()$"?Friendly="$FriendlyCheck.bChecked$"?DC="$DefaultConfig$"?NBots="$NbBots$"?TB0="$TeamBot[0]$"?NB0="$NivBot[0]$"?TB1="$TeamBot[1]$"?NB1="$NivBot[1]$"?TB2="$TeamBot[2]$"?NB2="$NivBot[2]$"?TB3="$TeamBot[3]$"?NB3="$NivBot[3]$"?TB4="$TeamBot[4]$"?NB4="$NivBot[4]$"?TB5="$TeamBot[5]$"?NB5="$NivBot[5]$"?TB6="$TeamBot[6]$"?NB6="$NivBot[6];
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

    OnFrag = int(localParseOption(PageParameters, "FragLimit", "0"));
    FragChanged();

    OnTime = int(localParseOption(PageParameters, "TimeLimit", "0"));
    TimeChanged();

    FriendlyCheck.bChecked = (Caps(localParseOption(PageParameters, "Friendly", "")) == "TRUE");

	DefaultConfig = int( localParseOption( PageParameters,"DC", "0") );

	NbBots = int( localParseOption( PageParameters,"NBots", "0") );

	TeamBot[0] = int( localParseOption( PageParameters,"TB0", "1") );
	NivBot[0] = int( localParseOption( PageParameters,"NB0", "1") );
	TeamBot[1] = int( localParseOption( PageParameters,"TB1", "0") );
	NivBot[1] = int( localParseOption( PageParameters,"NB1", "2") );
	TeamBot[2] = int( localParseOption( PageParameters,"TB2", "1") );
	NivBot[2] = int( localParseOption( PageParameters,"NB2", "2") );
	TeamBot[3] = int( localParseOption( PageParameters,"TB3", "0") );
	NivBot[3] = int( localParseOption( PageParameters,"NB3", "0") );
	TeamBot[4] = int( localParseOption( PageParameters,"TB4", "1") );
	NivBot[4] = int( localParseOption( PageParameters,"NB4", "0") );
	TeamBot[5] = int( localParseOption( PageParameters,"TB5", "0") );
	NivBot[5] = int( localParseOption( PageParameters,"NB5", "3") );
	TeamBot[6] = int( localParseOption( PageParameters,"TB6", "1") );
	NivBot[6] = int( localParseOption( PageParameters,"NB6", "3") );
}


function SaveConfigs()
{
     SaveConfig();
     GetPlayerOwner().SaveConfig();
     GetPlayerOwner().PlayerReplicationInfo.SaveConfig();
}



