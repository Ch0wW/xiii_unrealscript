class XIIIMenuPlayersSetupClient extends XIIIMenuMultiBase;

var int OnCombo, OnMenu;

var XIIIButton PlayerButton[4];
var XIIIComboControl PlayerClassButton[4];
var XIIICheckBoxControl PlayerTeamButton[4];

var localized string ClassText, TeamText, BlueTeam, RedTeam, PlayerText;

var string URL, Map;
var int PC[4], PT[4], NbClasses;
var int GameTypeIndex, IPC, N, MaxBots, FragLimit, TimeLimit, BotNumber, TeamBot[7], NivBot[7], FriendlyFire, DefaultConfig; 

var string sBackground, sHighlight;
var texture tBackground, tHighlight;


//------------------------------------------------------------------------
event HandleParameters(string Param1, string Param2)
{
	if ( Param1!="" )
	{
		URL = Param1;
		log("Param1="$URL);
		Map = localParseOption ( URL, "Map", "");
		GameTypeIndex = int(localParseOption ( URL, "GameTypeIndex", "0"));
		IPC = int( localParseOption( URL,"IP", "0") );
		N = int( localParseOption( URL,"NP", "0") );
		FriendlyFire = int( localParseOption( URL,"FF", "0") );
		FragLimit = int( localParseOption( URL,"FR", "0") );
		TimeLimit = int( localParseOption( URL,"TI", "0") );
		DefaultConfig = int( localParseOption( URL,"DC", "0") );
		BotNumber = int( localParseOption( URL,"NBots", "0") );
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

		log(self@"---> Classes :"@PC[0]@PC[1]@PC[2]@PC[3]);
		log(self@"---> Teams :"@PT[0]@PT[1]@PT[2]@PT[3]);
	}
}


function Created()
{
    local int i,j, MyClassIndex;

	Super.Created();

	tBackGround = texture(DynamicLoadObject(sBackGround, class'Texture'));
	tHighlight = texture(DynamicLoadObject(sHighlight, class'Texture'));

	NbClasses = class'MPClassList'.default.ClassListInfo.Length;
	log("NbClasses="$NbClasses);
	for (i=0;i<4;i++)
	{
		PlayerTeamButton[i] = XIIICheckboxControl(CreateControl(class'XIIICheckboxControl', 190, (50 + 100*i)*fScaleTo, 400, 25));
		PlayerTeamButton[i].Text = TeamText;
		PlayerTeamButton[i].sYes = BlueTeam;
		PlayerTeamButton[i].sNo = RedTeam;
		PlayerTeamButton[i].bWhiteColorOnlyWhenFocused = true;
		PlayerTeamButton[i].bChecked = bool(PT[i]);

		PlayerClassButton[i] = XIIIComboControl(CreateControl(class'XIIIComboControl', 190, (90 + 100*i)*fScaleTo, 410, 25));
		PlayerClassButton[i].Text = ClassText;
		PlayerClassButton[i].bArrows = true;
		PlayerClassButton[i].bCalculateSize = false;
		PlayerClassButton[i].FirstBoxWidth = 230;
		for (j=0;j<NbClasses;j++)
		{
			PlayerClassButton[i].AddItem(class'MPClassList'.default.ClassListInfo[j].ReadableName);
			if ( PC[i] == j )
				MyClassIndex = j;
		}
		PlayerClassButton[i].SetSelectedIndex(MyClassIndex);

		PlayerButton[i] = XIIIButton(CreateControl(class'XIIIButton', 35, (50 + 100*i)*fScaleTo, 130, 25));
		PlayerButton[i].Text = PlayerText@(i + 1);
		PlayerButton[i].bNeverFocus = true;
		PlayerButton[i].bVisible = true;

		Controls[2*i] = PlayerTeamButton[i];
		Controls[2*i + 1] = PlayerClassButton[i];
		Controls[8 + i] = PlayerButton[i];

	}

	AfterCreate();
}

function AfterCreate()
{
    local int i,j, NbPads;

 	//NbPads = GetPlayerOwner().GetPadNumber();
	NbPads = 4;

	if ( N > NbPads )
		N = NbPads;

	for (i=0;i<4;i++)
	{
		if ( i<N )
		{
			PlayerClassButton[i].bNeverFocus = false;
			PlayerClassButton[i].bVisible = true;
			PlayerTeamButton[i].bNeverFocus = false;
			PlayerTeamButton[i].bVisible = true;
			PlayerButton[i].bVisible = true;

		}
		else
		{
			PlayerClassButton[i].bNeverFocus = true;
			PlayerClassButton[i].bVisible = false;
			PlayerTeamButton[i].bNeverFocus = true;
			PlayerTeamButton[i].bVisible = false;
			PlayerButton[i].bVisible = false;
		}

		// no sabotage class if we are not in sabotage mode
		if ( GameTypeIndex != SabotageIndex )
		{
			PlayerClassButton[i].bNeverFocus = true;
			PlayerClassButton[i].bVisible = false;
		}
	}
}


function ShowWindow()
{
     Super.ShowWindow();

     bShowBCK = true;
     bShowACC = true;
}


function Paint(Canvas C, float X, float Y)
{
   local float W, H;

   local array<string> MsgArray;
   local int v;
   local int Length;
   local int TextWith;


    Super.Paint(C, X, Y);

	DrawStretchedTexture(C, 28*fRatioX, 28*fScaleTo*fRatioY, 584*fRatioX, 406*fRatioY*fScaleTo, myRoot.tFondNoir);
	DrawStretchedTexture(C,  30*fRatioX,  30*fScaleTo*fRatioY, 580*fRatioX, 402*fScaleTo*fRatioY, tBackGround);

	OnMenu = FindComponentIndex(FocusedControl);
	C.Style = 5;
	C.DrawColor.A = 128;
	if (OnMenu%2 == 0)
	{
		DrawStretchedTexture(C, 175*fRatioX, (40 + 50*OnMenu)*fScaleTo*fRatioY, 420*fRatioX, 45*fScaleTo*fRatioY, tHighlight);
	}
	else
	{
		DrawStretchedTexture(C, 175*fRatioX, (80 + 50*(OnMenu - 1))*fScaleTo*fRatioY, 420*fRatioX, 45*fScaleTo*fRatioY, tHighlight);
	}
	C.Style = 1;
	C.DrawColor.A = 255;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if (State==1)// IST_Press // to avoid auto-repeat
    {
        if (Key==0x0D/*IK_Enter*/)
	    {
			URL =
				"?Map="$Map$
				"?IP="$IPC$
				"?NP="$N$
				"?FF="$FriendlyFire$
				"?FR="$FragLimit$
				"?TI="$TimeLimit$
				"?NBots="$BotNumber$
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
			
			//log(URL);

            myRoot.CloseMenu(true, URL);
            return true;
	    }
	    if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
	    {
			myRoot.CloseMenu(true, URL);
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
			if (OnMenu%2 == 0)
			{
				if (Key==0x25) XIIICheckBoxControl(FocusedControl).bChecked = true;
				else if (Key==0x27) XIIICheckBoxControl(FocusedControl).bChecked = false;
				PT[int( 0.5*OnMenu )] = int(XIIICheckBoxControl(FocusedControl).bChecked);
			}
			else if (OnMenu%2 == 1)
			{
			   OnCombo = XIIIComboControl(FocusedControl).GetSelectedIndex();
			   if (Key==0x25) OnCombo--;
			   if (Key==0x27) OnCombo++;
			   OnCombo = Clamp(OnCombo,0,( NbClasses - 1 ));
			   XIIIComboControl(FocusedControl).SetSelectedIndex(OnCombo);
			   PC[int( 0.5*( OnMenu - 1 ))] = OnCombo;
			}
			return true;
		}
	}
    return super.InternalOnKeyEvent(Key, state, delta);
}




defaultproperties
{
     TitleText="Select your profile"
     ProfileText="Existing profile(s)"
     NewProfileText="New profile"
     CreateText="Create new profile"
     ConfirmCreateText="Save profile"
     ProfileFailureText="This profile already exists. Please enter a new profile."
     ConfirmQuitText="Do you really want to quit ?"
     ConfirmQuitTitle="Quit game"
     ProfileErrorTitle="Error with profile"
     ProfileErrorText="FAILED to use profile %name%"
     NoProfileText="Continue without profile ?|saving game will not be possible"
     ProfileInitText="FAILED to read profiles"
     sBackground(0)="XIIIMenuStart.Profile.Profilefond1"
     sBackground(1)="XIIIMenuStart.Profile.Profilefond2"
     sBackground(2)="XIIIMenuStart.Profile.Profilefond3"
     sBackground(3)="XIIIMenuStart.Profile.Profilefond4"
     bForceHelp=True
     Background=None
     bAllowedAsLast=True
}
