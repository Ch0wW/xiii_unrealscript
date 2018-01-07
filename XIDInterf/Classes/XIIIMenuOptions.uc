class XIIIMenuOptions extends XIIIWindowMainMenu;

var XIIITexturebutton VideoButton, SoundButton, ControlsButton, DifficultyButton, ParentalLockButton;
var XIIILabel VideoLabel, SoundLabel, DifficultyLabel, ControlsLabel, ParentalLockLabel;
var localized string VideoText, SoundText, ControlsText, DifficultyText, ParentalLockText, ParentalLockGlobalText, SaveQuestionText, SaveQuestionTitle;

var texture tBackGround[10];
var texture tHighlight[10];
var texture tOnomatopee[4];
var string sBackGround[10], sHighlight[10], sOnomatopee[4];
var bool bForceSave;


// info about parental lock
// if GoreLevel value is 0, parental lock is not activated, blood is visible
// if GoreLevel value is 1, parental lock is activated, blood is not visible

// AUDIO
VAR int MemoMusicValue, MemoStereoValue, MemoVolumeValue;

// VIDEO
VAR float MemoBrightness, MemoGamma, MemoContrast;
VAR int MemoShiftX, MemoShiftY;

// DIFFICULTY
VAR int MemoLevel;

// PARENTAL-LOCK
VAR int MemoGoreLevel;

// CONTROLS
VAR bool bMemoRumble, bMemoInvPad;
VAR int MemoAutoAim, MemoPadConfig;
VAR float MemoLookSpeed;

FUNCTION MemorizeConfig( )
{
	MemoMusicValue = int( GetPlayerOwner().ConsoleCommand("get HXAudio.HXAudioSubsystem MusicSliderPos") );
	MemoStereoValue = int( GetPlayerOwner().ConsoleCommand("get HXAudio.HXAudioSubsystem SoundMode") );
	MemoVolumeValue = int( GetPlayerOwner().ConsoleCommand("get HXAudio.HXAudioSubsystem MasterVolume") );
	MemoBrightness = float(GetPlayerOwner().ConsoleCommand("get XIIIMenuVideoClientWindow UserBrightness"));
	MemoGamma = float(GetPlayerOwner().ConsoleCommand("get XIIIMenuVideoClientWindow UserGamma"));
	MemoContrast = float(GetPlayerOwner().ConsoleCommand("get XIIIMenuVideoClientWindow UserContrast"));
	MemoShiftX = int( GetPlayerOwner().ConsoleCommand("get XIIIMenuVideoClientWindow DecalX") );
	MemoShiftY = int( GetPlayerOwner().ConsoleCommand("get XIIIMenuVideoClientWindow DecalY") );
	MemoLevel = int(GetPlayerOwner().ConsoleCommand("Get GameInfo Difficulty"));
	MemoGoreLevel = GetPlayerOwner().Level.Game.GoreLevel;
	bMemoRumble = GetPlayerOwner().bUseRumble;
	MemoAutoAim = GetPlayerOwner().iAutoAimMode;
    bMemoInvPad = GetPlayerOwner().bInverseLook;
    MemoLookSpeed = GetPlayerOwner().fLookSpeed;
	MemoPadConfig = GetPlayerOwner().UserPadConfig;
}

FUNCTION bool MayISave()
{
	return (
		MemoMusicValue != int( GetPlayerOwner().ConsoleCommand("get HXAudio.HXAudioSubsystem MusicSliderPos") )
	||	MemoStereoValue != int( GetPlayerOwner().ConsoleCommand("get HXAudio.HXAudioSubsystem SoundMode") )
	||	MemoVolumeValue != int( GetPlayerOwner().ConsoleCommand("get HXAudio.HXAudioSubsystem MasterVolume") )
	||	MemoBrightness != float(GetPlayerOwner().ConsoleCommand("get XIIIMenuVideoClientWindow UserBrightness"))
	||	MemoGamma != float(GetPlayerOwner().ConsoleCommand("get XIIIMenuVideoClientWindow UserGamma"))
	||	MemoContrast != float(GetPlayerOwner().ConsoleCommand("get XIIIMenuVideoClientWindow UserContrast"))
	||	MemoShiftX != int( GetPlayerOwner().ConsoleCommand("get XIIIMenuVideoClientWindow DecalX") )
	||	MemoShiftY != int( GetPlayerOwner().ConsoleCommand("get XIIIMenuVideoClientWindow DecalY") )
	||	MemoLevel != int( GetPlayerOwner().ConsoleCommand("Get GameInfo Difficulty") )
	||	MemoGoreLevel != GetPlayerOwner().Level.Game.GoreLevel
	||	bMemoRumble != GetPlayerOwner().bUseRumble
	||	MemoAutoAim != GetPlayerOwner().iAutoAimMode
	||	bMemoInvPad != GetPlayerOwner().bInverseLook
	||	MemoLookSpeed != GetPlayerOwner().fLookSpeed
	||	MemoPadConfig != GetPlayerOwner().UserPadConfig
	);
}

FUNCTION RestoreConfig()
{
	GetPlayerOwner().ConsoleCommand("set HXAudio.HXAudioSubsystem MusicSliderPos"@ MemoMusicValue );
	GetPlayerOwner().ConsoleCommand("set HXAudio.HXAudioSubsystem SoundMode"@ MemoStereoValue );
	GetPlayerOwner().ConsoleCommand("set HXAudio.HXAudioSubsystem MasterVolume"@ MemoVolumeValue );
	GetPlayerOwner().ConsoleCommand("set XIIIMenuVideoClientWindow UserBrightness"@ MemoBrightness );
	GetPlayerOwner().ConsoleCommand("set XIIIMenuVideoClientWindow UserGamma"@ MemoGamma );
	GetPlayerOwner().ConsoleCommand("set XIIIMenuVideoClientWindow UserContrast"@ MemoContrast );
	GetPlayerOwner().ConsoleCommand("set XIIIMenuVideoClientWindow DecalX"@ MemoShiftX );
	GetPlayerOwner().ConsoleCommand("set XIIIMenuVideoClientWindow DecalY"@ MemoShiftY );
	GetPlayerOwner().ConsoleCommand("set GameInfo Difficulty"@ MemoLevel );
	GetPlayerOwner().Level.Game.GoreLevel = MemoGoreLevel;
	GetPlayerOwner().bUseRumble = bMemoRumble;
	GetPlayerOwner().iAutoAimMode = MemoAutoAim;
	GetPlayerOwner().bInverseLook = bMemoInvPad;
	GetPlayerOwner().fLookSpeed = MemoLookSpeed;
	GetPlayerOwner().UserPadConfig = MemoPadConfig;
}

FUNCTION AskSaveConfigs()
{
	LOCAL XIIIMsgBox MsgBox;
	if ( bShowSAV || myRoot.CurrentPF==0 )
		ProcessSave();
	else
	{
		if ( myRoot.CurrentPF==2 ) // X-Box
		{
			if ( MayISave() )
			{
				myRoot.OpenMenu("XIDInterf.XIIIMsgBox");
				MsgBox = XIIIMsgBox(myRoot.ActivePage);
				MsgBox.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);
				MsgBox.SetupQuestion(SaveQuestionText, QBTN_Yes | QBTN_No, QBTN_Yes, SaveQuestionTitle);
				MsgBox.OnButtonClick = SaveMsgBoxReturn;
			}
			else
				myRoot.CloseMenu( false );
		}
		else
			myRoot.CloseMenu( false );
	}
}

FUNCTION ProcessSave()
{
	GetPlayerOwner().ConsoleCommand("Set GameInfo GoreLevel"@GetPlayerOwner().Level.Game.GoreLevel );
	SaveConfigs();
}

function SaveMsgBoxReturn(byte bButton)
{
	if ( (bButton & QBTN_Yes) != 0)
	{
		ProcessSave();
	}
	else
	{
		RestoreConfig( );
		myRoot.CloseMenu( true );
	}
}

function Created()
{
    local int i;
	
	Super.Created();

	MemorizeConfig( );

	for (i=0; i<10; i++)
		tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));
	for (i=0; i<10; i++)
		tHighlight[i] = texture(DynamicLoadObject(sHighlight[i], class'Texture'));
	for (i=0; i<4; i++)
		tOnomatopee[i] = texture(DynamicLoadObject(sOnomatopee[i], class'Texture'));
	
	if ( GetPlayerOwner().Level.Game.GoreLevel == 0 )
	{
		ParentalLockButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 25, 19*fScaleTo, 206, 163*fScaleTo));
		ParentalLockButton.tFirstTex[0]=tBackGround[8];
		ParentalLockButton.tFirstTex[1]=tHighlight[8];
		ParentalLockButton.xOff = 256;
		ParentalLockGlobalText = ParentalLockText@":"@(class'XIIIMenuYesNoWindow'.default.NoText);;
	}
	else
	{
		ParentalLockButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 25, 19*fScaleTo, 206, 163*fScaleTo));
		ParentalLockButton.tFirstTex[0]=tBackGround[9];
		ParentalLockButton.tFirstTex[1]=tHighlight[9];
		ParentalLockButton.xOff = 256;
		ParentalLockGlobalText = ParentalLockText@":"@(class'XIIIMenuYesNoWindow'.default.YesText);
	}
	
/*	VideoButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 244, 19*fScaleTo, 368, 139*fScaleTo));
	VideoButton.tFirstTex[0]=tBackGround[0];
	VideoButton.tSecondTex[0]=tBackGround[1];
	VideoButton.tFirstTex[1]=tHighlight[0];
	VideoButton.tSecondTex[1]=tHighlight[1];
	VideoButton.xOff = 256;
*/	
	DifficultyButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 25, 193*fScaleTo, 206, 242*fScaleTo));
	DifficultyButton.tFirstTex[0]=tBackGround[4];
	DifficultyButton.tSecondTex[0]=tBackGround[5];
	DifficultyButton.tFirstTex[1]=tHighlight[4];
	DifficultyButton.tSecondTex[1]=tHighlight[5];
	DifficultyButton.yOff = 256;
	
	SoundButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 244, /*169*/129*fScaleTo, 194, /*266*/306*fScaleTo));
	SoundButton.tFirstTex[0]=tBackGround[2];
	SoundButton.tSecondTex[0]=tBackGround[3];
	SoundButton.tFirstTex[1]=tHighlight[2];
	SoundButton.tSecondTex[1]=tHighlight[3];
	SoundButton.yOff = 256;
	
	ControlsButton = XIIITextureButton(CreateControl(class'XIIITextureButton', 450, /*169*/129*fScaleTo, 162, /*266*/306*fScaleTo));
	ControlsButton.tFirstTex[0]=tBackGround[6];
	ControlsButton.tSecondTex[0]=tBackGround[7];
	ControlsButton.tFirstTex[1]=tHighlight[6];
	ControlsButton.tSecondTex[1]=tHighlight[7];
	ControlsButton.yOff = 256;

	Controls[0]=ParentalLockButton;	
//	Controls[1]=VideoButton;
	Controls[1]=DifficultyButton;
	Controls[2]=SoundButton;
	Controls[3]=ControlsButton;

	InitLabel(ParentalLockLabel, 8, 130, 206, 32, ParentalLockGlobalText);
//    InitLabel(VideoLabel, 210, 32, 128, 32, VideoText);
    InitLabel(DifficultyLabel, 16, 300, 128, 32, DifficultyText);
    InitLabel(SoundLabel, 350, 350, 128, 32, SoundText);
    InitLabel(ControlsLabel, 425, 210, 128, 32, ControlsText);

	OnReOpen = InternalOnOpen;

	GetPlayerOwner().PlayMenu(hSoundOptionsMenu);
}


function InternalOnOpen()
{
	GetPlayerOwner().PlayMenu(hSoundOptionsMenu);
}


function Paint(Canvas C, float X, float Y)
{
	local float W,H;

	Super.Paint(C, X, Y);

	if ( myRoot.CurrentPF==1 || myRoot.CurrentPF==3) // PS2 ou GCUBE
	bShowSAV = MayISave();

	C.bUseBorder = true;
	DrawStretchedTexture(C, 25*fRatioX, 19*fScaleTo*fRatioY, 206*fRatioX, 163*fScaleTo*fRatioY, tBackGround[9]);
	//DrawStretchedTexture(C, 244*fRatioX, 19*fScaleTo*fRatioY, 368*fRatioX, 139*fRatioY*fScaleTo, myRoot.tFondNoir);
	C.bUseBorder = false;
	/*DrawStretchedTexture(C, 244*fRatioX, 19*fScaleTo*fRatioY, 184*fRatioX, 139*fScaleTo*fRatioY, tHighLight[0]);
	DrawStretchedTexture(C, (244+184)*fRatioX, 19*fScaleTo*fRatioY, 184*fRatioX, 139*fScaleTo*fRatioY, tHighLight[1]);*/

	C.bUseBorder = true;
	C.TextSize(class'XIIIMenu'.default.OptionsText, W, H);
	DrawStretchedTexture(C, 355*fRatioX, 40*fRatioY, 140*fRatioX, 40*fRatioY, myRoot.FondMenu);
	C.DrawColor = BlackColor;
	C.SetPos( 425 - W*0.5*fRatioX, (60 - H/2)*fRatioY);
	C.DrawText(class'XIIIMenu'.default.OptionsText, false);
	C.bUseBorder = false;
	C.DrawColor = WhiteColor;
}

function AfterPaint(Canvas C, float X, float Y)
{
    local float zoom;

    super.AfterPaint(C, X, Y);

    C.Style = 5;
	if (ParentalLockButton.bDisplayTex) {
	    zoom = ParentalLockButton.zoom;
        DrawStretchedTexture(C, 150*fRatioX+23-150*zoom, 23*fRatioY+73-50*zoom, 120*zoom, 40*zoom, tOnomatopee[3]);
        DrawLabel(C, ParentalLockLabel);
    }
/*    if (VideoButton.bDisplayTex) {
        zoom = VideoButton.zoom;
        DrawStretchedTexture(C, 470*fRatioX+158-158*zoom, 115*fRatioY+71-71*zoom, 158*zoom, 71*zoom, tOnomatopee[0]);
        DrawLabel(C, VideoLabel);
    }*/
    if (DifficultyButton.bDisplayTex) {
        zoom = DifficultyButton.zoom;
        DrawStretchedTexture(C, 85*fRatioX+248-248*zoom, 242*fRatioY+76-76*zoom, 248*zoom, 76*zoom, tOnomatopee[2]);
        DrawLabel(C, DifficultyLabel);
    }
    if (SoundButton.bDisplayTex) {
        zoom = SoundButton.zoom;
        DrawStretchedTexture(C, 78*fRatioX+237-237*zoom, 135*fRatioY+126-126*zoom, 237*zoom, 126*zoom, tOnomatopee[1]);
        DrawLabel(C, soundLabel);
    }
    if (ControlsButton.bDisplayTex) {
        zoom = ControlsButton.zoom;
        DrawStretchedTexture(C, 470*fRatioX+248-248*zoom, 272*fRatioY+76-76*zoom, 158*zoom, 76*zoom, tOnomatopee[3]);
        DrawLabel(C, ControlsLabel);
    }
    C.Style = 1;
}


function ShowWindow()
{
//     VideoButton.MouseEnter();
     bShowSEL = true;
     bShowBCK = true;
     Super.ShowWindow();
}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
/*    if (Sender == VideoButton)
		Controller.OpenMenu("XIDInterf.XIIIMenuVideoClientWindow");*/
    if (Sender == SoundButton)
		Controller.OpenMenu("XIDInterf.XIIIMenuAudioClientWindow");
    if (Sender == ControlsButton)
    {
        if (myRoot.CurrentPF != 0)
            Controller.OpenMenu("XIDInterf.XIIIMenuControlsWindow");
        else
            Controller.OpenMenu("XIDInterf.XIIIMenuInputPC");
    }
    if (Sender == DifficultyButton)
		Controller.OpenMenu("XIDInterf.XIIIMenuDifficultyWindow");
	if (Sender == ParentalLockButton)
	{
		if ( GetPlayerOwner().Level.Game.GoreLevel == 0 )
		{
			// parental lock is activated
			ParentalLockButton.tFirstTex[0]=tBackGround[9];
			ParentalLockButton.tFirstTex[1]=tHighlight[9];
			GetPlayerOwner().Level.Game.GoreLevel = 1;
			ParentalLockLabel.sLabel = ParentalLockText@":"@(class'XIIIMenuYesNoWindow'.default.YesText);
			ParentalLockButton.MouseEnter();
		}
		else
		{
			// parental lock is deactivated
			ParentalLockButton.tFirstTex[0]=tBackGround[8];
			ParentalLockButton.tFirstTex[1]=tHighlight[8];
			GetPlayerOwner().Level.Game.GoreLevel = 0;
			ParentalLockLabel.sLabel = ParentalLockText@":"@(class'XIIIMenuYesNoWindow'.default.NoText);
			ParentalLockButton.MouseEnter();
		}
	}
	return true;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int index;
   local bool bLeft, bRight, bUp, bDown;

    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ( (Key==0x0D) || (Key==0x01) )
	    {
//            Controller.FocusedControl.OnClick(Self);
            return InternalOnClick(FocusedControl);//true;
	    }
	    if ( (Key==0x08) || (Key==0x1B) )
	    {
			AskSaveConfigs( );
    	    return true;
	    }

        bUp = (Key==0x26);
        bDown = (Key==0x28);
        bLeft = (Key==0x25);
        bRight = (Key==0x27);
        // controls are
        //   0 1
        //   2 3 4
	    if (bUp ||bDown || bLeft ||bRight)
	    {
	        index = FindComponentIndex(FocusedControl);
            switch (index)
	        {
	            case 0 :
                    if ( bUp || bDown ) Controls[1].FocusFirst(Self,false);
                    if ( bLeft|| bRight ) Controls[1].FocusFirst(Self,false);
                break;
/*	            case 1 : 
                    if (bUp || bDown) Controls[3].FocusFirst(Self,false);
                    if ( bLeft|| bRight ) Controls[0].FocusFirst(Self,false);
                break;*/
	            case 1 : 
                    if (bUp || bDown) Controls[0].FocusFirst(Self,false);
                    if ( bLeft ) Controls[3].FocusFirst(Self,false);
                    if ( bRight ) Controls[2].FocusFirst(Self,false);
				break;
	            case 2 : 
                    if (bUp || bDown) Controls[0].FocusFirst(Self,false);
                    if ( bLeft ) Controls[1].FocusFirst(Self,false);
                    if ( bRight ) Controls[3].FocusFirst(Self,false);
                break;
	            case 3 : 
                    if (bUp || bDown) Controls[0].FocusFirst(Self,false);
                    if ( bLeft ) Controls[2].FocusFirst(Self,false);
                    if ( bRight ) Controls[1].FocusFirst(Self,false);
                break;
			}
			return true;
	    }
        //return false;
    }
    return super.InternalOnKeyEvent(Key, state, delta);
//    return false;
}




defaultproperties
{
     VideoText="Video"
     SoundText="Sound"
     ControlsText="Controls"
     DifficultyText="Difficulty"
     ParentalLockText="Parental Lock"
     SaveQuestionText="Do you want to save your settings?"
     SaveQuestionTitle="Options changed"
     sBackground(0)="XIIIMenuStart.optionsVideo01gris"
     sBackground(1)="XIIIMenuStart.optionsVideo02gris"
     sBackground(2)="XIIIMenuStart.optionsSon01gris"
     sBackground(3)="XIIIMenuStart.optionsSon02gris"
     sBackground(4)="XIIIMenuStart.optionsDifficulty01gris"
     sBackground(5)="XIIIMenuStart.optionsDifficulty02gris"
     sBackground(6)="XIIIMenuStart.optionsControlegris01"
     sBackground(7)="XIIIMenuStart.optionsControlegris02"
     sBackground(8)="XIIIMenuStart.parentallockoffGRIS"
     sBackground(9)="XIIIMenuStart.parentallockonGRIS"
     sHighlight(0)="XIIIMenuStart.optionsVideo01"
     sHighlight(1)="XIIIMenuStart.optionsVideo02"
     sHighlight(2)="XIIIMenuStart.optionsSon01"
     sHighlight(3)="XIIIMenuStart.optionsSon02"
     sHighlight(4)="XIIIMenuStart.optionsDifficulty01"
     sHighlight(5)="XIIIMenuStart.optionsDifficulty02"
     sHighlight(6)="XIIIMenuStart.optionsControle01"
     sHighlight(7)="XIIIMenuStart.optionsControle02"
     sHighlight(8)="XIIIMenuStart.parentallockoff"
     sHighlight(9)="XIIIMenuStart.parentallockon"
     sOnomatopee(0)="XIIIMenuStart.optionVideoTipTap"
     sOnomatopee(1)="XIIIMenuStart.optionSonWoooo"
     sOnomatopee(2)="XIIIMenuStart.optionDifficultyBrrrr"
     sOnomatopee(3)="XIIIMenuStart.optionSonBuzzz"
}
