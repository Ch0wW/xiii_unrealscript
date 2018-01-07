//====================================================================
//
//	XBox Controls
//
//====================================================================
class XIIIMenuControlsWindow extends XIIIWindow;

var XIIIComboControl PadConfigButton;
var XIIIButton AdvancedButton;
var XIIILabel InfoLabel[18];

var localized string TitleText, PadConfigXBoxText[4], AdvancedText;
var localized string InfoText[18], InfoTextClassicHalo[18], InfoTextGoofyHalo[18], InfoTextClassicXIII[18], InfoTextGoofyXIII[18];

var int NbPadConfig, iObjDecalY;

var int PadConfig;

var string sBackGround[8];
var texture tBackGround[4];


// infos about pad config definition
// PadConfig = 0 -> Classic Halo
// PadConfig = 1 -> Goofy Halo
// PadConfig = 2 -> Classic XIII
// PadConfig = 3 -> Goofy XIII


// info text definition
// 0 -> A
// 1 -> B
// 2 -> X
// 3 -> Y
// 4 -> Black
// 5 -> White
// 6 -> Left Trigger
// 7 -> Right Trigger
// 8 -> CrossDown
// 9 -> CrossRight
// 10 -> CrossLeft
// 11 -> CrossUp
// 12 -> Start
// 13 -> Select
// 14 -> LPad Button
// 15 -> RPad Button
// 16 -> Left ThumbStick
// 17 -> Right ThumbStick


// info controller buttons
// Joy1 -> A
// Joy2 -> B
// Joy3 -> X
// Joy4 -> Y
// Joy5 -> Black
// Joy6 -> White
// Joy7 -> Left Trigger
// Joy8 -> Right Trigger
// Joy9 -> CrossUp
// Joy10 -> CrossDown
// Joy11 -> CrossLeft
// Joy12 -> CrossRight
// Joy13 -> Start
// Joy14 -> Select
// Joy15 -> Left Thumbstick (press)
// Joy16 -> Right Thumbstick (press)
// JoyX -> Left Thumbstick (Left/Right)
// JoyY -> Left Thumbstick (Up/Down)
// JoyU -> Right Thumbstick (Left/Right)
// JoyV -> Right Thumbstick (Up/Down)


//_____________________________________________________________________________
function Created()
{
    local int i,j;

    Super.Created();

    tBackGround[0] = texture(DynamicLoadObject(sBackGround[0], class'Texture'));
    tBackGround[1] = texture(DynamicLoadObject(sBackGround[1], class'Texture'));
    tBackGround[2] = texture(DynamicLoadObject(sBackGround[2], class'Texture'));
    tBackGround[3] = texture(DynamicLoadObject(sBackGround[3], class'Texture'));
	
/*
	tBackGround[0] = texture(DynamicLoadObject(sBackGround[4], class'Texture'));
	tBackGround[1] = texture(DynamicLoadObject(sBackGround[5], class'Texture'));
	tBackGround[2] = texture(DynamicLoadObject(sBackGround[6], class'Texture'));
	tBackGround[3] = texture(DynamicLoadObject(sBackGround[7], class'Texture'));
*/

	PadConfigButton = XIIIComboControl(CreateControl(class'XIIIComboControl',30,355*fScaleTo + iObjDecalY,185,37*fScaleTo));
	PadConfigButton.bArrows = true;
	for (i=0;i<NbPadConfig;i++)
		PadConfigButton.AddItem(PadConfigXBoxText[i]);

	AdvancedButton = XIIIButton(CreateControl(class'XIIIButton',40,395*fScaleTo + iObjDecalY,165,25*fScaleTo));
	AdvancedButton.Text = AdvancedText;

	Controls[0] = PadConfigButton;
	Controls[1] = AdvancedButton;

	PadConfig = GetPlayerOwner().UserPadConfig;
	PadConfig = Clamp(PadConfig,0,NbPadConfig - 1);
	switch (PadConfig)
	{
		Case 0:
			for (i=0;i<18;i++)
				InfoText[i] = InfoTextClassicHalo[i];
			break;
		Case 1:
			for (i=0;i<18;i++)
				InfoText[i] = InfoTextGoofyHalo[i];
			break;
		Case 2:
			for (i=0;i<18;i++)
				InfoText[i] = InfoTextClassicXIII[i];
			break;
		Case 3:
			for (i=0;i<18;i++)
				InfoText[i] = InfoTextGoofyXIII[i];
			break;
	}
	InitLabels();
	PadConfigButton.SetSelectedIndex(PadConfig);
}


//_____________________________________________________________________________
function ShowWindow()
{
    Super.ShowWindow();

    bShowBCK = true;
    bShowACC = true;
}

//_____________________________________________________________________________
function InitLabels()
{
/*
	// labels positions defined for big XBox pad
	InitLabel(InfoLabel[0], 460, 145*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[0]);
	InitLabel(InfoLabel[1], 460, 105*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[1]);
	InitLabel(InfoLabel[2], 460, 125*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[2]);
	InitLabel(InfoLabel[3], 460, 85*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[3]);
	InitLabel(InfoLabel[5], 460, 65*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[5]);
	InitLabel(InfoLabel[6], 40, 285*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[6]);
	InitLabel(InfoLabel[7], 460, 282*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[7]);
	InitLabel(InfoLabel[9], 38, 170*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[9]);
	InitLabel(InfoLabel[12], 270, 255*fScaleTo + iObjDecalY, 100, 20*fScaleTo, InfoText[12]);
	InitLabel(InfoLabel[13], 270, 275*fScaleTo + iObjDecalY, 100, 20*fScaleTo, InfoText[13]);
	InitLabel(InfoLabel[14], 38, 125*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[14]);
	InitLabel(InfoLabel[15], 38, 190*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[15]);
	InitLabel(InfoLabel[16], 38, 105*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[16]);
	InitLabel(InfoLabel[17], 460, 170*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[17]);
*/

	InitLabel(InfoLabel[0], 460, 140*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[0]);
	InitLabel(InfoLabel[1], 460, 100*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[1]);
	InitLabel(InfoLabel[2], 460, 120*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[2]);
	InitLabel(InfoLabel[3], 460, 80*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[3]);
	InitLabel(InfoLabel[5], 460, 160*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[5]);
	InitLabel(InfoLabel[6], 40, 282*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[6]);
	InitLabel(InfoLabel[7], 460, 280*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[7]);
	InitLabel(InfoLabel[9], 38, 185*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[9]);
	InitLabel(InfoLabel[12], 38, 165*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[12]);
	InitLabel(InfoLabel[13], 38, 145*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[13]);
	InitLabel(InfoLabel[14], 38, 125*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[14]);
	//InitLabel(InfoLabel[15], 38, 205*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[15]);
	InitLabel(InfoLabel[16], 38, 105*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[16]);
	InitLabel(InfoLabel[17], 460, 180*fScaleTo + iObjDecalY, 140, 20*fScaleTo, InfoText[17]);
}


//_____________________________________________________________________________
function Paint(Canvas C, float X, float Y)
{
    local float fScale, W, H;

    Super.Paint(C, X, Y);

    C.Style = 1;

    DrawStretchedTexture(C, 0, iObjDecalY, 320*fRatioX, 240*fScaleTo*fRatioY, tBackGround[0]);
    DrawStretchedTexture(C, 320*fRatioX , iObjDecalY, 320*fRatioX, 240*fScaleTo*fRatioY, tBackGround[1]);
    DrawStretchedTexture(C, 0, 240*fScaleTo*fRatioY  + iObjDecalY, 320*fRatioX, 240*fScaleTo*fRatioY, tBackGround[2]);
    DrawStretchedTexture(C, 320*fRatioX, 240*fScaleTo*fRatioY + iObjDecalY, 320*fRatioX, 240*fScaleTo*fRatioY, tBackGround[3]);

    C.bUseBorder = true;
    DrawStretchedTexture(C, 45, 40*fRatioY + iObjDecalY, 120*fRatioX, 40*fRatioY, myRoot.FondMenu);
    C.TextSize(/*Caps(*/TitleText/*)*/, W, H);
    C.DrawColor = BlackColor;
	C.SetPos((105 - W/2)*fRatioX, (60 - H/2)*fRatioY + iObjDecalY);
	C.DrawText(/*Caps(*/TitleText/*)*/, false);
    C.bUseBorder = false;
    C.DrawColor = WhiteColor;

    C.Style = 5;
	C.DrawColor.A = 128;
	C.SpaceX = 1;
	DrawLabel(C, InfoLabel[0], true, true);
	DrawLabel(C, InfoLabel[1], true, true);
	DrawLabel(C, InfoLabel[2], true, true);
	DrawLabel(C, InfoLabel[3], true, true);
	DrawLabel(C, InfoLabel[5], true, true);
	DrawLabel(C, InfoLabel[6], true, true);
	DrawLabel(C, InfoLabel[7], true, true);
	DrawLabel(C, InfoLabel[9], true, true);
	DrawLabel(C, InfoLabel[10], true, true);
	DrawLabel(C, InfoLabel[12], true, true);
	DrawLabel(C, InfoLabel[13], true, true);
	DrawLabel(C, InfoLabel[14], true, true);
	//DrawLabel(C, InfoLabel[15], true, true);
	DrawLabel(C, InfoLabel[16], true, true);
	DrawLabel(C, InfoLabel[17], true, true);
	C.SpaceX = 0;
    C.Style = 1;
}


//_____________________________________________________________________________
function PadConfigChanged()
{

	// generic inputs
/*	GetPlayerOwner().ConsoleCommand("SET Input Joy2 PrevWeapon");
	GetPlayerOwner().ConsoleCommand("SET Input Joy6 QuickHeal");
	GetPlayerOwner().ConsoleCommand("SET Input Joy8 Fire | onrelease UnFire");
	GetPlayerOwner().ConsoleCommand("SET Input Joy9 CenterView | ACTOR ALIGN SNAPTOFLOOR ALIGN=1");
	GetPlayerOwner().ConsoleCommand("SET Input Joy10 CenterView | ACTOR ALIGN SNAPTOFLOOR ALIGN=1");
	GetPlayerOwner().ConsoleCommand("SET Input Joy11 InventoryNext");
	GetPlayerOwner().ConsoleCommand("SET Input Joy12 InventoryPrevious");
	GetPlayerOwner().ConsoleCommand("SET Input Joy13 ShowMenu");
	GetPlayerOwner().ConsoleCommand("SET Input Joy14 ShowScores | onrelease HideScores");
	GetPlayerOwner().ConsoleCommand("SET Input Joy15 Duck");
	GetPlayerOwner().ConsoleCommand("SET Input JoyY Axis aBaseY SpeedBase=1.0 DeadZone=0.4");
	GetPlayerOwner().ConsoleCommand("SET Input JoyV Axis aLookup SpeedBase=1.0 DeadZone=0.4 INVERT=-1");
*/
	switch ( PadConfig )
	{
		case 0:
			// specific inputs for classic halo
	        GetPlayerOwner().ConsoleCommand("SET XIIIPlayerController ConfigType CT_StrafeLookNotSameAxis");
			GetPlayerOwner().ConsoleCommand("SET Input Joy1 Jump");
			GetPlayerOwner().ConsoleCommand("SET Input Joy3 Grab");
			GetPlayerOwner().ConsoleCommand("SET Input Joy4 PrevWeapon");
			GetPlayerOwner().ConsoleCommand("SET Input Joy7 AltFire | onrelease UnFire");
			GetPlayerOwner().ConsoleCommand("SET Input JoyX Axis aStrafe SpeedBase=1.0 DeadZone=0.4");
			GetPlayerOwner().ConsoleCommand("SET Input JoyU Axis aTurn SpeedBase=1.0 DeadZone=0.4");
			//GetPlayerOwner().ConsoleCommand("SET Input JoyZ Axis aTurn SpeedBase=1.0 DeadZone=0.4");
			break;
		case 1:
			// specific inputs for goofy halo
	        GetPlayerOwner().ConsoleCommand("SET XIIIPlayerController ConfigType CT_StrafeLookSameAxis");
			GetPlayerOwner().ConsoleCommand("SET Input Joy1 Jump");
			GetPlayerOwner().ConsoleCommand("SET Input Joy3 Grab");
			GetPlayerOwner().ConsoleCommand("SET Input Joy4 PrevWeapon");
			GetPlayerOwner().ConsoleCommand("SET Input Joy7 AltFire | onrelease UnFire");
			GetPlayerOwner().ConsoleCommand("SET Input JoyX Axis aTurn SpeedBase=1.0 DeadZone=0.4");
			GetPlayerOwner().ConsoleCommand("SET Input JoyU Axis aStrafe SpeedBase=1.0 DeadZone=0.4");
			//GetPlayerOwner().ConsoleCommand("SET Input JoyZ Axis aStrafe SpeedBase=1.0 DeadZone=0.4");
			break;
		case 2:
			// specific inputs for classic XIII
	        GetPlayerOwner().ConsoleCommand("SET XIIIPlayerController ConfigType CT_StrafeLookNotSameAxis");
			GetPlayerOwner().ConsoleCommand("SET Input Joy1 Grab");
			GetPlayerOwner().ConsoleCommand("SET Input Joy3 PrevWeapon");
			GetPlayerOwner().ConsoleCommand("SET Input Joy4 AltFire | onrelease UnFire");
			GetPlayerOwner().ConsoleCommand("SET Input Joy7 Jump");
			GetPlayerOwner().ConsoleCommand("SET Input JoyX Axis aStrafe SpeedBase=1.0 DeadZone=0.4");
			GetPlayerOwner().ConsoleCommand("SET Input JoyU Axis aTurn SpeedBase=1.0 DeadZone=0.4");
			//GetPlayerOwner().ConsoleCommand("SET Input JoyZ Axis aTurn SpeedBase=1.0 DeadZone=0.4");
			break;
		case 3:
			// specific inputs for goofy XIII
	        GetPlayerOwner().ConsoleCommand("SET XIIIPlayerController ConfigType CT_StrafeLookSameAxis");
			GetPlayerOwner().ConsoleCommand("SET Input Joy1 Grab");
			GetPlayerOwner().ConsoleCommand("SET Input Joy3 PrevWeapon");
			GetPlayerOwner().ConsoleCommand("SET Input Joy4 AltFire | onrelease UnFire");
			GetPlayerOwner().ConsoleCommand("SET Input Joy7 Jump");
			GetPlayerOwner().ConsoleCommand("SET Input JoyX Axis aTurn SpeedBase=1.0 DeadZone=0.4");
			GetPlayerOwner().ConsoleCommand("SET Input JoyU Axis aStrafe SpeedBase=1.0 DeadZone=0.4");
			//GetPlayerOwner().ConsoleCommand("SET Input JoyZ Axis aStrafe SpeedBase=1.0 DeadZone=0.4");
			break;
	}

	GetPlayerOwner().OptimizeInputBindings();
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	local int i;

	if ((State==1) || (State==2))// IST_Press // to avoid auto-repeat
	{
		if (Key==0x0D/*IK_Enter*/)
		{
			OnMenu = FindComponentIndex(FocusedControl);
			switch (OnMenu)
			{
				case 0:
					GetPlayerOwner().UserPadConfig = PadConfig;
					PadConfigChanged();
//					SaveConfigs();
					SaveConfig();
					myRoot.CloseMenu(false);
				break;
				case 1:
					Controller.OpenMenu("XIDInterf.XIIIMenuAdvancedControlsWindow");
				break;
			}
			return true;
		}

		if (Key==0x08/*IK_Backspace*/)
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

		if ((Key==0x25/*IK_Left*/) || (Key==0x27/*IK_Right*/))
		{
			if (FocusedControl == Controls[0])
			{
				if (Key==0x25) PadConfig--;
				if (Key==0x27) PadConfig++;
				PadConfig = Clamp(PadConfig,0,NbPadConfig - 1);
				
				switch (PadConfig)
				{
					Case 0:
						for (i=0;i<18;i++)
							InfoText[i] = InfoTextClassicHalo[i];
						break;
					Case 1:
						for (i=0;i<18;i++)
							InfoText[i] = InfoTextGoofyHalo[i];
						break;
					Case 2:
						for (i=0;i<18;i++)
							InfoText[i] = InfoTextClassicXIII[i];
						break;
					Case 3:
						for (i=0;i<18;i++)
							InfoText[i] = InfoTextGoofyXIII[i];
						break;
				}
				InitLabels();
				PadConfigButton.SetSelectedIndex(PadConfig);
			}
			return true;
		}
	}
	return super.InternalOnKeyEvent(Key, state, delta);
}




defaultproperties
{
     TitleText="Controls"
     NumPadText="Pad Number"
     PadText="Pad Configuration"
     AdvancedText="Advanced"
     sButtonsX(0)="A"
     sButtonsX(1)="B"
     sButtonsX(2)="X"
     sButtonsX(3)="Y"
     sButtonsX(4)="Black"
     sButtonsX(5)="White"
     sButtonsX(6)="Left Trigger"
     sButtonsX(7)="Right Trigger"
     sButtonsX(8)="CrossDown"
     sButtonsX(9)="CrossRight"
     sButtonsX(10)="CrossLeft"
     sButtonsX(11)="CrossUp"
     sButtonsX(12)="Start"
     sButtonsX(13)="Select"
     sButtonsX(14)="LPad Button"
     sButtonsX(15)="RPad Button"
     sButtonsX(16)="Left ThumbStick"
     sButtonsX(17)="Right ThumbStick"
     sButtonsP(0)="Triangle"
     sButtonsP(1)="Circle"
     sButtonsP(2)="Cross"
     sButtonsP(3)="Square"
     sButtonsP(4)="L2"
     sButtonsP(5)="R2"
     sButtonsP(6)="L1"
     sButtonsP(7)="R1"
     sButtonsP(8)="Select"
     sButtonsP(9)="L3"
     sButtonsP(10)="R3"
     sButtonsP(11)="Start"
     sButtonsP(12)="CrossUp"
     sButtonsP(13)="CrossRight"
     sButtonsP(14)="CrossDown"
     sButtonsP(15)="CrossLeft"
     sButtonsP(16)="Left Stick"
     sButtonsP(17)="Right Stick"
     sButtonsG(0)="L Shoulder"
     sButtonsG(1)="R Shoulder"
     sButtonsG(2)="Z Trigger"
     sButtonsG(3)="Y"
     sButtonsG(4)="X"
     sButtonsG(5)="A"
     sButtonsG(6)="B"
     sButtonsG(7)="CrossLeft"
     sButtonsG(8)="CrossRight"
     sButtonsG(9)="CrossUp"
     sButtonsG(10)="CrossDown"
     sButtonsG(11)="Start"
     sButtonsG(16)="LPad"
     sButtonsG(17)="RPad"
     sBackground(0)="XIIIMenuStart.controlsPS2_1"
     sBackground(1)="XIIIMenuStart.controlsPS2_2"
     sBackground(2)="XIIIMenuStart.controlsPS2_3"
     sBackground(3)="XIIIMenuStart.controlsPS2_4"
     sBackground(4)="XIIIMenuStart.controlsXbox1"
     sBackground(5)="XIIIMenuStart.controlsXbox2"
     sBackground(6)="XIIIMenuStart.controlsXbox3"
     sBackground(7)="XIIIMenuStart.controlsXbox4"
     sBackground(8)="XIIIMenuStart.controlsGamecube1"
     sBackground(9)="XIIIMenuStart.controlsGamecube2"
     sBackground(10)="XIIIMenuStart.controlsGamecube3"
     sBackground(11)="XIIIMenuStart.controlsGamecube4"
     sHighlight(0)="XIIIMenuStart.selectboutonconfig"
     sHighlight(1)="XIIIMenuStart.selectboutonoptadvance"
     bForceHelp=True
}
