class XIIIMenuBotsSetupClient extends XIIIMenuMultiBase;

var int OnCombo;

var class<GameInfo> GameClass;
var array<XIIIComboControl> BotSkills;
var array<XIIICheckBoxControl> BotTeams;
var XIIIValueControl BotsCombo;
var XIIIComboControl DefaultConfigButton;

var localized string NbBotText, BotText, SkillText, TeamText, SkillsText[4], RedTeam, BlueTeam;
var localized string Error1Text, Error2Text, Error3Text, Error4Text, Error5Text, MessageText;
var localized string DefaultConfigText, Config1Text, Config2Text;
var string URL, Map;

VAR int GameTypeIndex;
var int IPC, N, MaxBots, FragLimit, TimeLimit, BotNumber, TeamBot[7], NivBot[7], PC[4], PT[4], FriendlyFire, DefaultConfig;

var string sBackground, sHighlight;
var texture tBackground, tHighlight;

var bool bInitialized, bTeamGame;


function Created()
{
    local int i, j;

	Super.Created();

	tBackGround = texture(DynamicLoadObject(sBackGround, class'Texture'));
	tHighlight = texture(DynamicLoadObject(sHighlight, class'Texture'));

	// MLK: Test weither the selected map can support additionnal bots
	if (MaxBots > 0)
    {
        BotsCombo = XIIIValueControl(CreateControl(class'XIIIValueControl', 194, 35*fScaleTo, 288, 35));
        BotsCombo.Text = NbBotText;
		BotsCombo.SetRange(0,MaxBots);
        BotsCombo.SetValue(BotNumber);
        Controls[0] = BotsCombo;

		for (i=0; i<MaxBots; i++)
        {
			BotSkills[i] = XIIIComboControl(CreateControl(class'XIIIComboControl', 40, (85 + i*50)*fScaleTo, 280, 25));
            BotSkills[i].Text = BotText$i+1@":"@SkillText;
            BotSkills[i].bArrows = true;
			BotSkills[i].bCalculateSize = false;
			BotSkills[i].FirstBoxWidth = 170;
            for (j=0; j<4; j++)
                BotSkills[i].AddItem(SkillsText[j]);

			BotSkills[i].SetSelectedIndex(NivBot[i]);

            Controls[i*2 + 1] = BotSkills[i];

            BotTeams[i] = XIIICheckboxControl(CreateControl(class'XIIICheckboxControl', 330, (95 + i*50)*fScaleTo, 280, 25));
			BotTeams[i].Text = BotText$i+1@":"@TeamText;
            BotTeams[i].sYes = BlueTeam;
            BotTeams[i].sNo = RedTeam;
			BotTeams[i].bWhiteColorOnlyWhenFocused = true;
            Controls[i*2 + 2] = BotTeams[i];
			XIIICheckBoxControl(Controls[i*2 + 2]).bChecked = bool(TeamBot[i]);
			
			// no team in deathmatch, kill the mouette and mario modes
			if (( GameTypeIndex == DeathmatchIndex ) || ( GameTypeIndex == TheHuntIndex ) || ( GameTypeIndex == PowerUpIndex ))
            {
				BotTeams[i].bNeverFocus = true;
                bTeamGame = false;
            }
            else
				bTeamGame = true;
        }

		// default mode : use map default bots
		DefaultConfigButton = XIIIComboControl(CreateControl(class'XIIIComboControl', 80, 200*fScaleTo, 480, 35));
		DefaultConfigButton.Text = DefaultConfigText;
		DefaultConfigButton.bArrows = true;
		DefaultConfigButton.AddItem(Config1Text);
		DefaultConfigButton.AddItem(Config2Text);
		DefaultConfigButton.SetSelectedIndex(DefaultConfig);
		Controls[MaxBots*2 + 1] = DefaultConfigButton;

        AfterCreate();

        bInitialized = true;
	}
}

function AfterCreate()
{
    local int i, j;

    if (BotNumber < 1)
    {
        for (i=0; i<MaxBots; i++)
        {
            BotSkills[i].bNeverFocus = true;
			BotSkills[i].bVisible = false;
            BotTeams[i].bNeverFocus = true;
			BotTeams[i].bVisible = false;
        }
		DefaultConfigButton.bVisible = true;
		DefaultConfigButton.bNeverFocus = false;
    }
    else
	{
        for (i=0; i<BotNumber; i++)
        {
			BotSkills[i].bNeverFocus = false;
			BotSkills[i].bVisible = true;
            if (!bTeamGame)
			{
				BotTeams[i].bNeverFocus = true;
				BotTeams[i].bVisible = false;
			}
            else
			{
                BotTeams[i].bNeverFocus = false;
				BotTeams[i].bVisible = true;
			}
        }
        for (i=BotNumber; i<MaxBots; i++)
        {
			BotSkills[i].bNeverFocus = true;
			BotSkills[i].bVisible = false;
            BotTeams[i].bNeverFocus = true;
			BotTeams[i].bVisible = false;
        }
		DefaultConfigButton.bVisible = false;
		DefaultConfigButton.bNeverFocus = true;
    }

	if ( BotsCombo.Value==0 )
		BotsCombo.sValue="-";

}


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

		MaxBots = IPC - N;
		//log(self@"--->"@Map@GameType@IPC@N@FragLimit@TimeLimit@BotNumber@MaxBots);
		//log(self@"--->"@NivBot[0]@NivBot[1]@NivBot[2]@NivBot[3]@NivBot[4]@NivBot[5]@NivBot[6]);
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

	if ( maxBots > 0 )
	{
		if ( BotNumber > 0 )
		{
			OnMenu = FindComponentIndex(FocusedControl);
			C.Style = 5;
			C.DrawColor.A = 128;
			if ( OnMenu == 0 )
			{
				DrawStretchedTexture(C, 80*fRatioX, 35*fScaleTo*fRatioY, 480*fRatioX, 35*fScaleTo*fRatioY, tHighlight);
			}
			else
			{
				if ( float(OnMenu)/2 != int(float(OnMenu/2)) )
				{
					DrawStretchedTexture(C, 20*fRatioX, (50 + 25*OnMenu)*fScaleTo*fRatioY, 300*fRatioX, 45*fScaleTo*fRatioY, tHighlight);
				}
				else
				{
					DrawStretchedTexture(C, 320*fRatioX, (35 + 25*OnMenu)*fScaleTo*fRatioY, 320*fRatioX, 45*fScaleTo*fRatioY, tHighlight);
				}
			}
			C.Style = 1;
			C.DrawColor.A = 255;
		}
		else
		{
			OnMenu = FindComponentIndex(FocusedControl);
			C.Style = 5;
			C.DrawColor.A = 128;
			if ( OnMenu == 0 )
			{
				DrawStretchedTexture(C, 80*fRatioX, 35*fScaleTo*fRatioY, 480*fRatioX, 35*fScaleTo*fRatioY, tHighlight);
			}
			else
			{
				if ( OnMenu == (Maxbots + 1) )
				{
					DrawStretchedTexture(C, 80*fRatioX, 200*fScaleTo*fRatioY, 480*fRatioX, 35*fScaleTo*fRatioY, tHighlight);
				}
			}
			C.Style = 1;
			C.DrawColor.A = 255;
		}
	}
	else
	{
		if (MaxBots < 1)
		{
			TextWith = 400;
        		//C.Font = font'XIIIFonts.XIIIConsoleFont';
			//C.DrawColor = BlackColor;
			C.WrapStringToArray(MessageText, MsgArray, TextWith, "|");
			Length = MsgArray.Length;
 			if (Length > 1)
			{
				for(v=0;v<Length;v++)
				{
					C.TextSize(MsgArray[v], W, H);
					C.SetPos(120, 220 + (H*v*fRatioY));
					C.DrawText(MsgArray[v], false);
				}
			}

			//C.DrawColor = WhiteColor;
			//C.SetPos(120*fRatioX, 180*fRatioY);
			//C.DrawText(Caps(Error1Text), false);
			//C.SetPos(120*fRatioX, 210*fRatioY);
			//C.DrawText(Caps(Error2Text), false);
			//C.SetPos(120*fRatioX, 240*fRatioY);
			//C.DrawText(Caps(Error3Text), false);
		}
/*		else
		{
			if (BotNumber == -1)
			{
				C.SetPos(125*fRatioX, 210*fRatioY); C.DrawText(Caps(Error4Text), false);
			}
			else
			{
				if (BotNumber == 0)
				{
					C.SetPos(125*fRatioX, 210*fRatioY); C.DrawText(Caps(Error5Text), false);
				}
			}
		}*/
	}
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
	    if (MaxBots > 0)
		{
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
				if (FocusedControl == Controls[0])
				{
				   if (Key==0x25) BotNumber--;
				   if (Key==0x27) BotNumber++;
				   BotNumber = Clamp(BotNumber,0,MaxBots);
				   BotsCombo.SetValue(BotNumber);
				   AfterCreate();
				   return true;
				}
				if (FocusedControl == Controls[MaxBots*2 + 1])
				{
					if (Key==0x25) DefaultConfig--;
					if (Key==0x27) DefaultConfig++;
					DefaultConfig = Clamp(DefaultConfig,0,1);
					DefaultConfigButton.SetSelectedIndex(DefaultConfig);
					return true;
				}
				if (OnMenu%2 == 1)
				{
				   OnCombo = XIIIComboControl(FocusedControl).GetSelectedIndex();
				   if (Key==0x25) OnCombo--;
				   if (Key==0x27) OnCombo++;
				   OnCombo = Clamp(OnCombo,0,3);
				   XIIIComboControl(FocusedControl).SetSelectedIndex(OnCombo);
				   NivBot[int( 0.5*( OnMenu - 1 ) )] = OnCombo;
				}
				else if (OnMenu%2 == 0)
				{
					if (Key==0x25) XIIICheckBoxControl(FocusedControl).bChecked = true;
					else if (Key==0x27) XIIICheckBoxControl(FocusedControl).bChecked = false;
					TeamBot[int( 0.5*( OnMenu - 2 ) )] = int(XIIICheckBoxControl(FocusedControl).bChecked);
				}
				return true;
			}
        }
	}
    return super.InternalOnKeyEvent(Key, state, delta);
}




defaultproperties
{
     NbBotText="Bot Number"
     BotText="Bot"
     SkillText="Skill"
     TeamText="Team"
     SkillsText(0)="Easy"
     SkillsText(1)="Medium"
     SkillsText(2)="Hard"
     SkillsText(3)="Insane"
     RedTeam="Red"
     BlueTeam="Blue"
     Error1Text="This Map can't support more than the actual number"
     Error2Text="of players. Please change your number of players"
     Error3Text="setting to be able to play current map with bots"
     Error4Text="Game will use map default bots"
     Error5Text="Bots are disabled for the current map"
     MessageText="This Map can't support more than the actual number of players. Please change your number of players setting to be able to play current map with bots"
     DefaultConfigText="Default Config"
     Config1Text="Use Map Default Bots"
     Config2Text="Disable All Bots"
     MaxBots=4
     sBackground="XIIIMenuStart.vignette_fond"
     sHighlight="XIIIMenuStart.barreselectmenuoptadv"
     bUseDefaultBackground=False
}
