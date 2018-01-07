class XIIIMultiControlsWindow extends XIIIWindow;

var XIIIComboControl PadConfigButton;
var XIIIHSliderControl LookSpeedSlider;
var XIIIComboControl RumbleButton, AutoAimButton, InvPadButton;

var localized string RumbleText, AutoAimText, LSpeedText, InvPadText, PadConfigXBoxText[4];

var int NbButtons, BoxPosX, BoxPosY, BoxWidth, BoxHeight, FirstBoxHeight, BoxOffsetY, BoxInterY;
var int BackgroundPosX, BackgroundPosY, BackgroundWidth, BackgroundHeight, SliderPosX;

var int NbPadConfig;

var int LocalPadConfig;

var localized string sYes, sNo;

var float ControlOffset;
var int LSpeed;

var XIIILabel InfoLabel;

var bool bSplitScreenMode;

VAR bool bMemoUseRumble, bMemoAutoAim, bMemoInvPad;
VAR int memoPadConfig;
VAR float memoLookSpeed;

//_____________________________________________________________________________
FUNCTION SavePadConfig()
{
	bMemoUseRumble = GetPlayerOwner().bUseRumble;
	memoLookSpeed=GetPlayerOwner().fLookSpeed;
		bMemoAutoAim = bool(GetPlayerOwner().iAutoAimMode);
	bMemoInvPad = GetPlayerOwner().bInverseLook;
	memoPadConfig = Clamp(GetPlayerOwner().UserPadConfig,0,NbPadConfig - 1);
}

FUNCTION bool HadPadConfigChanged()
{
	return
		(
			( memoPadConfig != PadConfigButton.GetSelectedIndex( ) )
		||	( memoLookSpeed != 0.7f + LookSpeedSlider.GetValue()*0.1f )
		||	( bMemoUseRumble != bool(1-RumbleButton.GetSelectedIndex( ) ) )
		||	( bMemoInvPad != bool(1-InvPadButton.GetSelectedIndex( ) ) )
		||	( bMemoAutoAim != bool(1-AutoAimButton.GetSelectedIndex( ) ) )
		);
}

//_____________________________________________________________________________
function Created()
{
    local int i;
	LOCAL int id;

    Super.Created();

	SavePadConfig();

	// init values
	BoxWidth = 210;
	BoxHeight = 30;
	BoxPosX = 225;
	BoxOffsetY = 5;
	BoxInterY = 10;
	FirstBoxHeight = BoxHeight*1.4;
	BackgroundPosX = 210;
	BackgroundWidth = 240;
	BackgroundHeight = 230;
	SliderPosX = 140;

	// split screen mode
	if ( ( GetPlayerOwner().Level.Game!=none ) && ( GetPlayerOwner().Level.Game.NumPlayers > 1 ) && (myRoot.GetLevel().NetMode == 0) )
	{
		bSplitScreenMode = true;
		BackgroundHeight = 178;
		BoxInterY = 15;
		BoxHeight *= 1.7;
		FirstBoxHeight = BoxHeight*1.2;
		BoxPosY = 30; //WinHeigth*480-FirstBoxHeight
		
		XIIIBaseHud(GetPlayerowner().myHUD).InitViewPortId( none, false );
		id = XIIIBaseHud(GetPlayerowner().myHUD).ViewPortId;
		if ( GetPlayerowner().Level.Game.NumPlayers==2 )
		{
			switch( id )
			{
			case 0: // en haut
				BackgroundPosY = 30;
				break;
			case 1: // en bas
				BackgroundPosY = 10;
				break;
			}
		}
		else
		{
			BoxWidth *= 2;
			BoxPosX -= 115;
			BackgroundPosX -= 170;
			SliderPosX *= 2;
			switch( id )
			{
			case 0: // en haut à gauche
			case 1: // en haut à droite
				BackgroundPosY = 30;
				break;
			case 2: // en bas à gauche
			case 3: // en bas à droite
				BackgroundPosY = 10;
				break;
			}
		}
		BoxPosY = (BackgroundPosY+5)*2;
	}
	else
	{
		BackgroundPosY = 130;
		BoxPosY = 150;
	}

	PadConfigButton = XIIIComboControl(CreateControl(class'XIIIComboControl', BoxPosX, (BoxPosY - BoxOffsetY)*fScaleTo, BoxWidth, FirstBoxHeight*fScaleTo));
	PadConfigButton.bArrows = true;
	for (i=0;i<NbPadConfig;i++)
		PadConfigButton.AddItem(PadConfigXBoxText[i]);
	PadConfigButton.bShowBordersOnlyWhenFocused=true;

	RumbleButton = XIIIComboControl(CreateControl(class'XIIIComboControl',BoxPosX, (BoxPosY + (BoxHeight + BoxInterY))*fScaleTo, BoxWidth, BoxHeight*fScaleTo));
	RumbleButton.Text = RumbleText;
	RumbleButton.bArrows = true;
	RumbleButton.bSplitScreenMode = bSplitScreenMode;
	RumbleButton.bCalculateSize = false;
	RumbleButton.FirstBoxWidth = 170;
	RumbleButton.AddItem(sYes);
	RumbleButton.AddItem(sNo);
	RumbleButton.SetSelectedIndex( int(!bMemoUseRumble) );
	RumbleButton.bShowBordersOnlyWhenFocused=true;

	AutoAimButton = XIIIComboControl(CreateControl(class'XIIIComboControl', BoxPosX, (BoxPosY + (BoxHeight + BoxInterY)*2)*fScaleTo, BoxWidth, BoxHeight*fScaleTo));
	AutoAimButton.Text = AutoAimText;
	AutoAimButton.bArrows = true;
	AutoAimButton.bSplitScreenMode = bSplitScreenMode;
	AutoAimButton.bCalculateSize = false;
	AutoAimButton.FirstBoxWidth = 170;
	AutoAimButton.AddItem(sYes);
	AutoAimButton.AddItem(sNo);
	AutoAimButton.SetSelectedIndex( int(!bMemoAutoAim) );
	AutoAimButton.bShowBordersOnlyWhenFocused=true;

	InvPadButton = XIIIComboControl(CreateControl(class'XIIIComboControl',BoxPosX, (BoxPosY + (BoxHeight + BoxInterY)*3)*fScaleTo, BoxWidth, BoxHeight*fScaleTo));
	InvPadButton.Text = InvPadText;
	InvPadButton.bArrows = true;
	InvPadButton.bSplitScreenMode = bSplitScreenMode;
	InvPadButton.bCalculateSize = false;
	InvPadButton.FirstBoxWidth = 170;
	InvPadButton.AddItem(sYes);
	InvPadButton.AddItem(sNo);
	InvPadButton.SetSelectedIndex( int(!bMemoInvPad) );
	InvPadButton.bShowBordersOnlyWhenFocused=true;

    LookSpeedSlider = XIIIHSliderControl(CreateControl(class'XIIIHSliderControl', BoxPosX, (BoxPosY + (BoxHeight + BoxInterY)*4)*fScaleTo, BoxWidth, BoxHeight*fScaleTo));
    LookSpeedSlider.SetRange(0, 10, 1, SliderPosX);
    LookSpeedSlider.Text = LSpeedText;
	LookSpeedSlider.NbMultiSplit = GetPlayerOwner().Level.Game.NumPlayers;
	LookSpeedSlider.bShowBordersOnlyWhenFocused=true;

    Controls[0] = PadConfigButton;
    Controls[1] = RumbleButton; 
    Controls[2] = AutoAimButton;
    Controls[3] = InvPadButton;
    Controls[4] = LookSpeedSlider;

	LocalPadConfig = memoPadConfig;

	PadConfigButton.SetSelectedIndex(LocalPadConfig);
}

//_____________________________________________________________________________
function ShowWindow()
{
    InitValues();

    Super.ShowWindow();

    bShowCCL = true;
	bShowACC = true;
}


//_____________________________________________________________________________
function InitValues()
{
    local int i;

    LSpeed = int( ( ( memoLookSpeed-0.7 ) * 10.0 ) + 0.1 ); // FUCK the innacurate floats

    LookSpeedSlider.SetValue(LSpeed);
}


//_____________________________________________________________________________
function Paint(Canvas C, float X, float Y)
{
    local int i;
    local float fScale, W, H;
//	local float LabelPosX, LabelPosY, LabelWidth, LabelHeight;

    Super.Paint(C,X,Y);
    // background
    if (myRoot.GetLevel().bCineFrame)
	{
	    C.Style = 5;
		C.DrawColor = BlackColor;
		C.DrawColor.A = 192;
	    DrawStretchedTexture(C, 0, 0, WinWidth*C.ClipX, WinHeight*C.ClipY, myRoot.FondMenu);
		C.Style = 1;
	}
	C.DrawColor = WhiteColor;
	if ( GetPlayerOwner().Level.Game==none || GetPlayerOwner().Level.NetMode != 0 || GetPlayerOwner().Level.Game.NumPlayers == 1 )
		C.DrawMsgboxBackground(false, BackgroundPosX*fRatioX, BackgroundPosY*fScaleTo*fRatioY, 10, 10, BackgroundWidth*fRatioX, BackgroundHeight*fScaleTo*fRatioY);
	else
	{
		C.bUseBorder = true;
		//DrawStretchedTexture( C, BackgroundPosX, BackgroundPosY*fScaleTo, BackgroundWidth, BackgroundHeight*fScaleTo, texture'XIIIMenu.FonDialog');
		C.bUseBorder = false;
	}

	// only selected control has a border (border is a XIIILabel without text)
/*	LabelPosX = BackgroundPosX + 5;
	LabelPosY = BackgroundPosY + 16 + 39.5*FindComponentIndex(FocusedControl);
	LabelWidth = BackgroundWidth - 10;
	LabelHeight = 40.5;
	if ( bSplitScreenMode )
	{
		if ( GetPlayerOwner().Level.Game.NumPlayers >= 2 )
		{
			LabelHeight *= 1.53;
			LabelPosY = BackgroundPosY + 35 + (BoxHeight + BoxInterY)*FindComponentIndex(FocusedControl);;
			if ( GetPlayerOwner().Level.Game.NumPlayers > 2 )
			{
				LabelPosX += 40;
				LabelWidth *= 2;
			}
		}
	}
	InitLabel(InfoLabel, LabelPosX, LabelPosY*fScaleTo, LabelWidth, LabelHeight*fScaleTo, "");
	C.Style = 1;
	C.DrawColor = WhiteColor;
	DrawLabel(C, InfoLabel, true, false);
*/
	// restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255;
	C.Style = 1;
	C.bUseBorder = false;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int i;

	if ((State==1) || (State==2))// IST_Press // to avoid auto-repeat
    {
        if (Key==0x0D/*IK_Enter*/)
	    {
			if ( HadPadConfigChanged() )
			{
				GetPlayerOwner().UserPadConfig = LocalPadConfig;
				PadConfigChanged();
				LookSpeedChanged();
				//RumbleChanged();
				AutoAimChanged();
				InvPadChanged();
				//SaveConfigs();          // Also close menu as mentioned in state 'CloseMenu' (see XIIIWindow)
			}
			myRoot.CloseMenu(true);
            return true;
	    }
	    if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
	    {
			if ( bMemoUseRumble )
			{
				if ( !GetPlayerOwner().bUseRumble )
				{
					XIIIPlayerController( GetPlayerOwner( ) ).SetRumbleFX( true );
					GetPlayerOwner().bUseRumble = true;
					XIIIPlayerController(GetPlayerOwner()).RumbleFX(13);
				}
			}
			else
			{
				if ( GetPlayerOwner().bUseRumble )
				{
					XIIIPlayerController( GetPlayerOwner( ) ).SetRumbleFX( false );
					GetPlayerOwner().bUseRumble = false;
				}
			}
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
                if (Key==0x25) LocalPadConfig--;
                if (Key==0x27) LocalPadConfig++;
				LocalPadConfig = Clamp(LocalPadConfig,0,NbPadConfig - 1);

				PadConfigButton.SetSelectedIndex(LocalPadConfig);
            }
            else if (FocusedControl == Controls[1])
            {
				if (Key==0x25)
				{
					if ( RumbleButton.GetSelectedIndex()!=0 )
					{
						RumbleButton.SetSelectedIndex( 0 );
						XIIIPlayerController( GetPlayerOwner( ) ).SetRumbleFX( true );
						GetPlayerOwner().bUseRumble = true;
						XIIIPlayerController(GetPlayerOwner()).RumbleFX(13);
					}
				}
				else if (Key==0x27)
				{
					if ( RumbleButton.GetSelectedIndex()!=1 )
					{
						RumbleButton.SetSelectedIndex( 1 );
						XIIIPlayerController( GetPlayerOwner( ) ).SetRumbleFX( false );
						GetPlayerOwner().bUseRumble = false;
					}
				}
            }
            else if (FocusedControl == Controls[2])
            {
				if (Key==0x27) AutoAimButton.SetSelectedIndex(1);
				else if (Key==0x25) AutoAimButton.SetSelectedIndex(0);
            }
            else if (FocusedControl == Controls[3])
            {
				if (Key==0x27) InvPadButton.SetSelectedIndex(1);
				else if (Key==0x25) InvPadButton.SetSelectedIndex(0);
            }
            return true;
        }

    }
    return super.InternalOnKeyEvent(Key, state, delta);
}

//_____________________________________________________________________________
function PadConfigChanged()
{

	switch ( LocalPadConfig )
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
			break;
	}

	GetPlayerOwner().OptimizeInputBindings();
}


//_____________________________________________________________________________
function LookSpeedChanged()
{
    local float f;

    LSpeed = LookSpeedSlider.GetValue();
    f = 0.7+float(LSpeed)/10.0;

    GetPlayerOwner().fLookSpeed = f;
}


//_____________________________________________________________________________
function InvPadChanged()
{
	GetPlayerOwner().bInverseLook = !bool(InvPadButton.GetSelectedIndex());
}

//_____________________________________________________________________________
function AutoAimChanged()
{
	GetPlayerOwner().iAutoAimMode = 1-AutoAimButton.GetSelectedIndex();
}



