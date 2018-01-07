class XIIIMenuInGameControlsWindow extends XIIIWindow;

var XIIIComboControl PadConfigButton;
var XIIIHSliderControl LookSpeedSlider;
var XIIIComboControl RumbleButton, AutoAimButton, InvPadButton;

var localized string RumbleText, AutoAimText, LSpeedText, InvPadText, PadConfigXBoxText[4],  SaveQuestionText, SaveQuestionTitle;

var int NbPadConfig;

var int LocalPadConfig;

var localized string sYes, sNo;

var float ControlOffset;
var int LSpeed;

var XIIILabel InfoLabel;
VAR bool bMemoUseRumble, bMemoAutoAim, bMemoInvPad;
VAR int memoPadConfig;
VAR float memoLookSpeed;

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

    Super.Created();

	SavePadConfig();

    ControlOffset += 125;
    PadConfigButton = XIIIComboControl(CreateControl(class'XIIIComboControl', 210, (ControlOffset - 4)*fScaleTo, 240, 40*fScaleTo));
	PadConfigButton.bArrows = true;
	for (i=0;i<NbPadConfig;i++)
		PadConfigButton.AddItem(PadConfigXBoxText[i]);
	PadConfigButton.bShowBordersOnlyWhenFocused=true;

    ControlOffset += 40;
	RumbleButton = XIIIComboControl(CreateControl(class'XIIIComboControl',210,ControlOffset*fScaleTo,240,29*fScaleTo));
	RumbleButton.Text = RumbleText;
	RumbleButton.bArrows = true;
	RumbleButton.bCalculateSize = false;
	RumbleButton.FirstBoxWidth = 180;
	RumbleButton.AddItem(sYes);
	RumbleButton.AddItem(sNo);
	RumbleButton.SetSelectedIndex( int(!bMemoUseRumble) );
	RumbleButton.bShowBordersOnlyWhenFocused=true;

    ControlOffset += 40;
	AutoAimButton = XIIIComboControl(CreateControl(class'XIIIComboControl',210,ControlOffset*fScaleTo,240,29*fScaleTo));
	AutoAimButton.Text = AutoAimText;
	AutoAimButton.bArrows = true;
	AutoAimButton.bCalculateSize = false;
	AutoAimButton.FirstBoxWidth = 180;
	AutoAimButton.AddItem(sYes);
	AutoAimButton.AddItem(sNo);
	AutoAimButton.SetSelectedIndex( int(!bMemoAutoAim) );
	AutoAimButton.bShowBordersOnlyWhenFocused=true;

    ControlOffset += 40;
	InvPadButton = XIIIComboControl(CreateControl(class'XIIIComboControl',210,ControlOffset*fScaleTo,240,29*fScaleTo));
	InvPadButton.Text = InvPadText;
	InvPadButton.bArrows = true;
	InvPadButton.bCalculateSize = false;
	InvPadButton.FirstBoxWidth = 180;
	InvPadButton.AddItem(sYes);
	InvPadButton.AddItem(sNo);
	InvPadButton.SetSelectedIndex( int(!bMemoInvPad) );
	InvPadButton.bShowBordersOnlyWhenFocused=true;

    // Create Look speed slider
    ControlOffset += 40;
    LookSpeedSlider = XIIIHSliderControl(CreateControl(class'XIIIHSliderControl', 210, ControlOffset*fScaleTo, 240, 29*fScaleTo));
    LookSpeedSlider.SetRange(0, 10, 1, 150);
    LookSpeedSlider.Text = LSpeedText;
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
    local string sVersion;
    local int i;
    local float fScale, W, H;

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
	C.DrawMsgboxBackground(false, 190*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 280*fRatioX, 230*fRatioY*fScaleTo);

	// restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255;
	C.Style = 1;
	C.bUseBorder = false;

}

function SaveMsgBoxReturn(byte bButton)
{
	if ( (bButton & QBTN_Yes) != 0)
	{
		GetPlayerOwner().UserPadConfig = LocalPadConfig;
		PadConfigChanged();
		LookSpeedChanged();
//		RumbleChanged();
		GetPlayerOwner().bUseRumble= !bool(RumbleButton.GetSelectedIndex());
		AutoAimChanged();
		InvPadChanged();

		SaveConfigs();
	}
	else
	{
		RestoreConfig( );
		myRoot.CloseMenu( true );
	}
}

function RestoreConfig( ) 
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
}
//_____________________________________________________________________________
function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	LOCAL XIIIMsgBox MsgBox;
    local int i;

	if ((State==1) || (State==2))// IST_Press // to avoid auto-repeat
    {
        if (Key==0x0D/*IK_Enter*/)
	    {
			if ( HadPadConfigChanged() )
			{
				myRoot.OpenMenu("XIDInterf.XIIIMsgBox");
				MsgBox = XIIIMsgBox(myRoot.ActivePage);
				MsgBox.InitBox(190*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 280*fRatioX, 230*fRatioY*fScaleTo);
				MsgBox.SetupQuestion( SaveQuestionText, QBTN_Yes | QBTN_No, QBTN_Yes, SaveQuestionTitle);
				MsgBox.OnButtonClick = SaveMsgBoxReturn;
			}
			else
				myRoot.CloseMenu( true );
            return true;
	    }
	    if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
	    {
			RestoreConfig( );
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
/*
function RumbleChanged()
{
	GetPlayerOwner().bUseRumble = bool(RumbleButton.GetSelectedIndex());
	XIIIPlayerController(GetPlayerOwner()).SetRumbleFX( GetPlayerOwner().bUseRumble );
	XIIIPlayerController(GetPlayerOwner()).RumbleFX(15);
}
*/

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



