//===========================================================================
// Split-Screen multiplayer game setup
//===========================================================================
class XIIIMenuSplitSetupClient extends XIIIMenuMultiBase;


var config string Map;
VAR config int GameTypeIndex;

var XIIIComboControl GameCombo, MapCombo;
var XIIICheckboxControl FriendlyCheck;
var XIIIValueControl PlayerCombo, FragEdit, TimeEdit;
var XIIIButton BotsButton, PlayersButton, OkButton;

var string Games[6], Prefix[6], GameInfo[6], Mutator, RealGames[6], RealPrefix[6], RealGameInfo[6];
var Array<string> MapsList, MapsUNRList;

var localized string TitleText, GameText, MapText, PlayerText, FriendlyText, FragText, TimeText, BotsText, PlayersText, OKText;

var texture tBackGround[7], tHighlight;
var string sBackground[7], sHighlight;

var bool Initialized;

var int OnPlayer, OnGame, OnMap, OnFrag, OnTime, MaxPlayerValue;

var int MaxPlayers, WinningScore, MaxTime, NbBots, IdealPC, N, FriendlyFire, FragLimit, TimeLimit, DefaultConfig;
var int TeamBot[7], NivBot[7], PC[4], PT[4];

var string URL;

var sound TempSound;


event HandleParameters(string Param1, string Param2)
{
    URL = Param1;
    log("Param1="$URL);
	Map = LocalParseOption ( URL, "Map", "");
	GameTypeIndex = int(localParseOption ( URL, "GameTypeIndex", "0"));
	IdealPC = int( localParseOption( URL,"IP", "0") );
	N = int( localParseOption( URL,"NP", "0") );
	//FriendlyFire = int( localParseOption( URL,"FF", "0") );
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
	PC[0] = int( localParseOption( URL,"PC0", "0") );
	PC[1] = int( localParseOption( URL,"PC1", "0") );
	PC[2] = int( localParseOption( URL,"PC2", "1") );
	PC[3] = int( localParseOption( URL,"PC3", "1") );
	PT[0] = int( localParseOption( URL,"PT0", "0") );
	PT[1] = int( localParseOption( URL,"PT1", "1") );
	PT[2] = int( localParseOption( URL,"PT2", "0") );
	PT[3] = int( localParseOption( URL,"PT3", "1") );

	//log(self@"---> DONNEES"@Map@GameType@IdealPC@N@FragLimit@TimeLimit@NbBots);
	//log(self@"---> NIVEAUX BOTS"@NivBot[0]@NivBot[1]@NivBot[2]@NivBot[3]@NivBot[4]@NivBot[5]@NivBot[6]);
	//log(self@"---> TEAM PLAYERS"@PT[0]@PT[1]@PT[2]@PT[3]);
}

function Created()
{
	local int i;

	Super.Created();
	
	switch( myRoot.CurrentPF )
	{
	case 1: // PS2
		AllowedGameTypeIndex[0]=DeathmatchIndex;
		AllowedGameTypeIndex[1]=TeamDeathmatchIndex;
		AllowedGameTypeIndex[2]=CaptureTheFlagIndex;
		AllowedGameTypeIndex[3]=TheHuntIndex;
		AllowedGameTypeIndex[4]=PowerUpIndex;
		break;
	case 2: // XBox
		AllowedGameTypeIndex[0]=DeathmatchIndex;
		AllowedGameTypeIndex[1]=TeamDeathmatchIndex;
		AllowedGameTypeIndex[2]=CaptureTheFlagIndex;
		AllowedGameTypeIndex[3]=SabotageIndex;
		break;
	case 3: // CUBE
		AllowedGameTypeIndex[0]=DeathmatchIndex;
		AllowedGameTypeIndex[1]=TeamDeathmatchIndex;
		AllowedGameTypeIndex[2]=CaptureTheFlagIndex;
		AllowedGameTypeIndex[3]=TheHuntIndex;
		break;
	}

	for (i=0; i<7; i++)
		tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));
	
	tHighlight = texture(DynamicLoadObject(sHighlight, class'Texture'));
	
	// Players
	PlayerCombo = XIIIValueControl(CreateControl(class'XIIIValueControl', 288, 70*fScaleTo, 300, 32));
	PlayerCombo.Text = PlayerText;
	PlayerCombo.bCalculateSize = false;
	PlayerCombo.FirstBoxWidth = 200;
	
	// Game Type
	GameCombo = XIIIComboControl(CreateControl(class'XIIIComboControl', 288, 116*fScaleTo, 300, 32));
	GameCombo.Text = GameText;
	//GameCombo.bSmallFont = true;
	GameCombo.bArrows = true;
	
	// Map
	MapCombo = XIIIComboControl(CreateControl(class'XIIIComboControl', 288, 162*fScaleTo, 300, 32));
	MapCombo.Text = MapText;
	MapCombo.bArrows = true;
	MapCombo.bCalculateSize = false;
	MapCombo.FirstBoxWidth = 160;
	
	// Frag Limit
	FragEdit = XIIIValueControl(CreateControl(class'XIIIValueControl', 288, 208*fScaleTo, 300, 32));
	FragEdit.Text = FragText;
	FragEdit.bCalculateSize = false;
	FragEdit.FirstBoxWidth = 200;
	FragEdit.SetRange(0,500);
	
	// Time Limit
	TimeEdit = XIIIValueControl(CreateControl(class'XIIIValueControl', 288, 254*fScaleTo, 300, 32));
	TimeEdit.Text = TimeText;
	TimeEdit.bCalculateSize = false;
	TimeEdit.FirstBoxWidth = 175;
	TimeEdit.SetRange(0,60);
	
	// Bots setup
	BotsButton = XIIIbutton(CreateControl(class'XIIIbutton', 320, 300*fScaleTo, 220, 32));
	BotsButton.Text = BotsText;
	BotsButton.bUseBorder = true;
	
	// friendly fire
	//FriendlyCheck = XIIICheckboxControl(CreateControl(class'XIIICheckboxControl', 288, 389*fScaleTo, 300, 29));
	//FriendlyCheck.Text = FriendlyText;
	//FriendlyCheck.bWhiteColorOnlyWhenFocused = true;

	// Players setup
	PlayersButton = XIIIbutton(CreateControl(class'XIIIbutton', 320, 346*fScaleTo, 220, 32));
	PlayersButton.Text = PlayersText;
	PlayersButton.bUseBorder = true;
	
	// OK go
	OKButton = XIIIbutton(CreateControl(class'XIIIbutton', 360, 392*fScaleTo, 139, 32));
	OKButton.Text = OKText;
	OKButton.bUseBorder = true;

    Controls[0] = PlayerCombo;
	Controls[1] = GameCombo;
	Controls[2] = MapCombo;
    Controls[3] = FragEdit;
	Controls[4] = TimeEdit;
	Controls[5] = BotsButton;
    //Controls[6] = FriendlyCheck;
	Controls[6] = PlayersButton;
	Controls[7] = OKButton;


	// real names of maps

    IterateGames();

    AfterCreate();

	if (myRoot.CurrentPF == 3 )
			hSoundMenu2 = TempSound;

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


function IterateMaps()
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

	PlayerCombo.SetRange(1,int(Mid(MapCombo.GetValue(),1)));
	OnPlayer = Max(GetPlayerOwner().GetPadNumber(), MaxPlayers);
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
	DrawStretchedTexture(C, 255*fRatioX, ((65+OnMenu*46)*fScaleTo)*fRatioY, 349*fRatioX, 40*fRatioY, tHighlight);//OnMenu]);
	C.DrawColor.A = 255;
	DrawStretchedTexture(C, 41*fRatioX, 88*fRatioY, 242*fRatioX, 170*fScaleTo*fRatioY, tBackGround[5]);
	DrawStretchedTexture(C, 41*fRatioX, (88+170*fScaleTo)*fRatioY, 242*fRatioX, 170*fScaleTo*fRatioY, tBackGround[6]);
	C.Style = 1;

	C.bUseBorder = true;
	DrawStretchedTexture(C, 100*fRatioX, 40*fRatioY, 180*fRatioX, 40*fRatioY, myRoot.FondMenu);
	C.TextSize(TitleText, W, H);
	C.DrawColor = BlackColor;
	C.SetPos((110 + (160-W)/2)*fRatioX, (60-H/2)*fRatioY); 
	C.DrawText(TitleText, false);
	C.bUseBorder = false;
	C.DrawColor = WhiteColor;
}


event Tick(float dt)
{
	// pads number detection
	if ( GetPlayerOwner().GetPadNumber() != 0 )
	{
		OnPlayer = Clamp(OnPlayer,1,GetPlayerOwner().GetPadNumber());
		PlayerCombo.SetRange(1,GetPlayerOwner().GetPadNumber());
		PlayerCombo.SetValue(OnPlayer);
	}
	else
	{
		OnPlayer = 0;
		PlayerCombo.SetRange(0,0);
		PlayerCombo.SetValue(OnPlayer);
	}
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
		if (Key==0x0D/*IK_Enter*/)
		{
			if (FocusedControl == BotsButton)
				GotoBotSetup();
			if (FocusedControl == PlayersButton)
				GotoPlayersSetup();
			if (FocusedControl == OKButton)
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
				if (Key==0x25) OnPlayer--;
				if (Key==0x27) OnPlayer++;
				OnPlayer = Clamp(OnPlayer,1,GetPlayerOwner().GetPadNumber());
				PlayerCombo.SetValue(OnPlayer);
			}
			else if (OnMenu == 1)
			{
				OldOnGame = OnGame;
				if (Key==0x25) OnGame--;
				if (Key==0x27) OnGame++;
				OnGame = Clamp(OnGame,0,AllowedGameTypeIndex.Length - 1);
				if ( OldOnGame != OnGame )
				{
					GameCombo.SetSelectedIndex(OnGame);
					GameChanged();
				}
			}
			else if (OnMenu == 2)
			{
				if (Key==0x25) OnMap--;
				if (Key==0x27) OnMap++;
				OnMap = Clamp(OnMap,0,MapsUNRList.Length - 1);
				MapCombo.SetSelectedIndex(OnMap);
			}
			if (OnMenu == 3)
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
			else if (OnMenu == 4)
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
/*			else if (OnMenu == 6)
			{
				if (Key==0x25)
					FriendlyCheck.bChecked = true;
				else
					if (Key==0x27)
						FriendlyCheck.bChecked = false;
			}*/
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

		// players setup bouton is available if we are in TDM, CTF or sabotage mode
		if ( HasFriendlyFire( OnGame ) )
		{
			PlayersButton.bNeverFocus = false;
			PlayersButton.bVisible = true;
		}
		else
		{
			PlayersButton.bNeverFocus = true;
			PlayersButton.bVisible = false;
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
    local int N, IdealPC, FriendlyFire;

    N = PlayerCombo.GetValue();
	IdealPC = int( Mid( MapCombo.GetValue(), 1 ) );
	NbBots = Min(NbBots,IdealPC - N);

	//FriendlyFire = int(FriendlyCheck.bChecked);

    MapChanged();
    TimeChanged();
	FragChanged();

    URL =
		"?Map="$Map$
		"?GameTypeIndex="$AllowedGameTypeIndex[OnGame]$
		"?IP="$IdealPC$
		"?NP="$N$
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
		"?NB6="$NivBot[6]$
		"?PC0="$PC[0]$
		"?PC1="$PC[1]$
		"?PC2="$PC[2]$
		"?PC3="$PC[3]$
		"?PT0="$PT[0]$
		"?PT1="$PT[1]$
		"?PT2="$PT[2]$
		"?PT3="$PT[3];

    log("Go to bots setup :"@URL);
    myRoot.OpenMenu("XIDInterf.XIIIMenuBotsSetupClient", false, URL);
}


function GotoPlayersSetup()
{
    local string URL;
    local int N, IdealPC, FriendlyFire;

    N = PlayerCombo.GetValue();
	IdealPC = int( Mid( MapCombo.GetValue(), 1 ) );
	NbBots = Min(NbBots,IdealPC - N);

	//FriendlyFire = int(FriendlyCheck.bChecked);

    MapChanged();
    TimeChanged();
	FragChanged();

    URL =
		"?Map="$Map$
		"?GameTypeIndex="$AllowedGameTypeIndex[OnGame]$
		"?IP="$IdealPC$
		"?NP="$N$
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
		"?NB6="$NivBot[6]$
		"?PC0="$PC[0]$
		"?PC1="$PC[1]$
		"?PC2="$PC[2]$
		"?PC3="$PC[3]$
		"?PT0="$PT[0]$
		"?PT1="$PT[1]$
		"?PT2="$PT[2]$
		"?PT3="$PT[3];

    log("Go to players setup :"@URL);
    myRoot.OpenMenu("XIDInterf.XIIIMenuPlayersSetupClient", false, URL);
}

function StartPressed()
{
	local string URL, MyClass, SkinCode, MyName, Mutator;
	local int i, N, IdealPC, FriendlyFire, NbTeam0, NbTeam1;
	local int TeamBalanceBot[4];

    N = PlayerCombo.GetValue();
	IdealPC = int( Mid( MapCombo.GetValue(), 1 ) );
	NbBots = Min(NbBots,IdealPC - N);

	//FriendlyFire = int(FriendlyCheck.bChecked);

    GetPlayerOwner().ConsoleCommand("SetViewPortNumberForNextMap "$N);

	MapChanged();
	TimeChanged();
	FragChanged();

	TeamBalanceBot[0] = 1;
	TeamBalanceBot[1] = 0;
	TeamBalanceBot[2] = 1;
	TeamBalanceBot[3] = 0;

	if (( NbBots == 0 ) && ( DefaultConfig == 0 ))
	{
		for (i=0;i<N;i++)
		{
			if ( PT[i] == 0 )
				NbTeam0 ++;
			else
				NbTeam1 ++;
		}

		i = 0;
		while ( NbTeam0 != NbTeam1 )
		{
			if ( NbTeam0 < NbTeam1 )
			{
				TeamBalanceBot[i] = 0;
				NbTeam0 ++;
			}
			else
			{
				TeamBalanceBot[i] = 1;
				NbTeam1 ++;
			}
			i++;
		}

		URL =
			/*"?Map="$*/Map$
			"?Game="$GetGameInfoText(OnGame)$
			"?IP="$IdealPC$
			"?NP="$N$
			"?FR="$OnFrag$
			"?TI="$OnTime$
			"?NBots="$(IdealPC - N)$
			"?TB0="$TeamBalanceBot[0]$
			"?NB0="$1$
			"?TB1="$TeamBalanceBot[1]$
			"?NB1="$2$
			"?TB2="$TeamBalanceBot[2]$
			"?NB2="$2$
			"?TB3="$TeamBalanceBot[3]$
			"?NB3="$0$
			"?TB4="$1$
			"?NB4="$0$
			"?TB5="$0$
			"?NB5="$3$
			"?TB6="$1$
			"?NB6="$3$
			"?PC0="$PC[0]$
			"?PC1="$PC[1]$
			"?PC2="$PC[2]$
			"?PC3="$PC[3]$
			"?PT0="$PT[0]$
			"?PT1="$PT[1]$
			"?PT2="$PT[2]$
			"?PT3="$PT[3];
	}
	else
	{
		URL =
			/*"?Map="$*/Map$
			"?Game="$GetGameInfoText(OnGame)$
			"?IP="$IdealPC$
			"?NP="$N$
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
			"?NB6="$NivBot[6]$
			"?PC0="$PC[0]$
			"?PC1="$PC[1]$
			"?PC2="$PC[2]$
			"?PC3="$PC[3]$
			"?PT0="$PT[0]$
			"?PT1="$PT[1]$
			"?PT2="$PT[2]$
			"?PT3="$PT[3];
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

    myRoot.CloseAll(true);
    myRoot.GotoState('');
    myRoot.bProfileMenu = false;
	myRoot.DefaultUserConfig = GetPlayerOwner().UserPadConfig;
    GetPlayerOwner().AttribPadToViewport();
    log("TRAVELLING w/URL: "$URL);
    GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
}


// if subclassed, this parent function must always be called first
function string GetPageParameters()
{
	return Super.GetPageParameters()$"?GameType="$GameCombo.GetSelectedIndex()$"?MapName="$MapCombo.GetSelectedIndex()$"?FragLimit="$FragEdit.GetValue()$"?TimeLimit="$TimeEdit.GetValue()$"?NP="$PlayerCombo.GetValue()$"?DC="$DefaultConfig$"?NBots="$NbBots$"?TB0="$TeamBot[0]$"?NB0="$NivBot[0]$"?TB1="$TeamBot[1]$"?NB1="$NivBot[1]$"?TB2="$TeamBot[2]$"?NB2="$NivBot[2]$"?TB3="$TeamBot[3]$"?NB3="$NivBot[3]$"?TB4="$TeamBot[4]$"?NB4="$NivBot[4]$"?TB5="$TeamBot[5]$"?NB5="$NivBot[5]$"?TB6="$TeamBot[6]$"?NB6="$NivBot[6]$"?PC0="$PC[0]$"?PC1="$PC[1]$"?PC2="$PC[2]$"?PC3="$PC[3]$"?PT0="$PT[0]$"?PT1="$PT[1]$"?PT2="$PT[2]$"?PT3="$PT[3]$"?CFG="$GetPlayerOwner().UserPadConfig;
}

// if GetPageParameters() is subclassed, you'd better have this one too !
function SetPageParameters(string PageParameters)
{
    local int CFG;
	
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

	OnPlayer = int( localParseOption( PageParameters,"NP", "0") );
	PlayerCombo.SetValue(OnPlayer);

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
	PC[0] = int( localParseOption( PageParameters,"PC0", "0") );
	PC[1] = int( localParseOption( PageParameters,"PC1", "0") );
	PC[2] = int( localParseOption( PageParameters,"PC2", "1") );
	PC[3] = int( localParseOption( PageParameters,"PC3", "1") );
	PT[0] = int( localParseOption( PageParameters,"PT0", "0") );
	PT[1] = int( localParseOption( PageParameters,"PT1", "1") );
	PT[2] = int( localParseOption( PageParameters,"PT2", "0") );
	PT[3] = int( localParseOption( PageParameters,"PT3", "1") );

	CFG = int( localParseOption( PageParameters,"CFG","0") );

	// reinit controls
	if ( myRoot.CurrentPF == 1 )
	{
		switch ( CFG )
		{
			case 0:
				// specific inputs for classic
		        GetPlayerOwner().ConsoleCommand("SET XIIIPlayerController ConfigType CT_StrafeLookNotSameAxis");
				GetPlayerOwner().ConsoleCommand("SET Input JoyX Axis aStrafe SpeedBase=1.0 DeadZone=0.4");
				GetPlayerOwner().ConsoleCommand("SET Input JoyU Axis aTurn SpeedBase=1.0 DeadZone=0.4");
				break;
			case 1:
				// specific inputs for goofy
				GetPlayerOwner().ConsoleCommand("SET XIIIPlayerController ConfigType CT_StrafeLookSameAxis");
				GetPlayerOwner().ConsoleCommand("SET Input JoyX Axis aTurn SpeedBase=1.0 DeadZone=0.4");
				GetPlayerOwner().ConsoleCommand("SET Input JoyU Axis aStrafe SpeedBase=1.0 DeadZone=0.4");
				break;
		}
	}
	else if ( myRoot.CurrentPF == 2 )
	{

	}
/*	else if ( myRoot.CurrentPF == 3 )
	{
		switch ( CFG )
		{
			case 0:
				// specific inputs for classic
				GetPlayerOwner().ConsoleCommand("set XIIIPlayerController ConfigType CT_StrafeLookNotSameAxis");
				GetPlayerOwner().ConsoleCommand("SET Input JoyX Axis aStrafe SpeedBase=1.0 DeadZone=0.0");
				GetPlayerOwner().ConsoleCommand("SET Input JoyU Axis aTurn SpeedBase=1.0 DeadZone=0.0");
				break;
			case 1:
				// specific inputs for goofy
				GetPlayerOwner().ConsoleCommand("set XIIIPlayerController ConfigType CT_StrafeLookSameAxis");
				GetPlayerOwner().ConsoleCommand("SET Input JoyX Axis aTurn SpeedBase=1.0 DeadZone=0.0");
				GetPlayerOwner().ConsoleCommand("SET Input JoyU Axis aStrafe SpeedBase=1.0 DeadZone=0.0");
				break;
		}
	}*/
}





defaultproperties
{
     TitleText="Split Screen Game"
     GameText="Game Type"
     MapText="Map Name"
     PlayerText="Number of Player(s)"
     FriendlyText="Friendly Fire"
     FragText="Points Limit"
     TimeText="Time Limit"
     BotsText="Bots Setup"
     PlayersText="Players Setup"
     OKText="Create"
     sBackground(0)="XIIIMenuStart.multi_Bg01"
     sBackground(1)="XIIIMenuStart.multi_Bg02"
     sBackground(2)="XIIIMenuStart.multi_Bg03"
     sBackground(5)="XIIIMenuStart.Characters01"
     sBackground(6)="XIIIMenuStart.Characters02"
     sHighlight="XIIIMenuStart.barreselectmenuoptadv"
     WinningScore=10
     MaxTime=5
     TeamBot(0)=1
     TeamBot(2)=1
     TeamBot(4)=1
     TeamBot(6)=1
     NivBot(0)=1
     NivBot(1)=2
     NivBot(2)=2
     NivBot(5)=3
     NivBot(6)=3
     TempSound=Sound'XIIIsound.Interface__AmbianceMenu.AmbianceMenu__hMulti2'
     bUseDefaultBackground=False
     bForceHelp=True
}
