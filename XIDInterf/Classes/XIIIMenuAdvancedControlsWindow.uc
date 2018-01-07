class XIIIMenuAdvancedControlsWindow extends XIIIWindow;

var XIIIHSliderControl LookSpeedSlider;// NL 1306, FactorSlider
var XIIICheckboxControl RumbleCheck, AutoAimCheck, InvPadCheck;
var localized string TitleText, RumbleCUBEText, LSpeedText, RumbleText, AutoAimText, InvPadText;//NL 1306 RSpeedText
var XIIIMenuControlsWindow PWin;

var int LSpeed;//NL 1306 Factor
var float controloffset;

var texture tBackGround[4];
var texture tHighlight;
var string sBackground[4], sHighlight;
var int iObjDecalY;


function Created()
{
    local int i;

    Super.Created();

     for (i=0; i<4; i++)
         tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));

     tHighlight = texture(DynamicLoadObject(sHighlight, class'Texture'));

    // Rumble
    RumbleCheck = XIIICheckboxControl(CreateControl(class'XIIICheckboxControl', 179, 150*fScaleTo, 282, 29));
    RumbleCheck.bChecked = GetPlayerOwner().bUseRumble;
    if (myRoot.CurrentPF==3)
	RumbleCheck.Text = RumbleCUBEText;
    else 
     	RumbleCheck.Text = RumbleText;
    RumbleCheck.bWhiteColorOnlyWhenFocused = true;

    // AutoAim
    AutoAimCheck = XIIICheckboxControl(CreateControl(class'XIIICheckboxControl', 179, 189*fScaleTo, 282, 29));
    AutoAimCheck.bChecked = bool(GetPlayerOwner().iAutoAimMode);
    AutoAimCheck.Text = AutoAimText;
	AutoAimCheck.bWhiteColorOnlyWhenFocused = true;

    // Inverse Pad
    InvPadCheck = XIIICheckboxControl(CreateControl(class'XIIICheckboxControl', 179, 228*fScaleTo, 282, 29));
    InvPadCheck.bChecked = GetPlayerOwner().bInverseLook;
    InvPadCheck.Text = InvPadText;
	InvPadCheck.bWhiteColorOnlyWhenFocused = true;

    // Create Look speed slider
    LookSpeedSlider = XIIIHSliderControl(CreateControl(class'XIIIHSliderControl', 179, 267*fScaleTo, 300, 29));
    LookSpeedSlider.SetRange(0, 10, 1, 160);
    LookSpeedSlider.Text = LSpeedText;

    Controls[0] = RumbleCheck;
	Controls[1] = AutoAimCheck;
    Controls[2] = InvPadCheck; 
    Controls[3] = LookSpeedSlider;

}


//_____________________________________________________________________________
function ShowWindow()
{
    PWin = XIIIMenuControlsWindow(ParentPage);
    InitValues();

    Super.ShowWindow();
    bShowCCL = true;
    bShowACC = true;
}



function InitValues()
{
    local int i, StrPos;
    local float f;

    RumbleCheck.bChecked = GetPlayerOwner().bUseRumble;
    AutoAimCheck.bChecked = bool(GetPlayerOwner().iAutoAimMode);
    InvPadCheck.bChecked = GetPlayerOwner().bInverseLook;

    StrPos = 0;
// NL 1306    Factor = PWin.Factor;
// NL 1306    log(Pwin$": "$int(right(left(PWin.PadConfig[0], strpos + 8), 1)));
// NL 1306    log(PWin.PadConfig[0]);
// NL 1306    log(Factor);

    //f = float(GetPlayerOwner().ConsoleCommand("Get XIIIPlayerController fLookSpeed"));
    f = GetPlayerOwner().fLookSpeed;
    LSpeed = int( ((f-0.7) * 10.0)+0.1 ); // FUCK the innacurate floats
//    Log("InitValues fLookSpeed="$f@"LSpeed="$LSpeed@"Factor="$Factor);

    LookSpeedSlider.SetValue(LSpeed);
// NL 1306    FactorSlider.SetValue(Factor);
}


function Paint(Canvas C, float X, float Y)
{
    local float W, H;

    Super.Paint(C, X, Y);
    C.Style = 5;
    DrawStretchedTexture(C, 0, 0, 320*fRatioX, 240*fScaleTo*fRatioY, tBackGround[0]);
    DrawStretchedTexture(C, 320*fRatioX, 0, 320*fRatioX, 240*fScaleTo*fRatioY, tBackGround[1]);
    DrawStretchedTexture(C, 0, 240*fScaleTo*fRatioY, 320*fRatioX, 240*fScaleTo*fRatioY, tBackGround[2]);
    DrawStretchedTexture(C, 320*fRatioX, 240*fScaleTo*fRatioY, 320*fRatioX, 240*fScaleTo*fRatioY, tBackGround[3]);

    C.DrawColor.A = 128;
    DrawStretchedTexture(C, 168*fRatioX, (142 + FindComponentIndex(FocusedControl)*40)*fScaleTo*fRatioY, 301*fRatioX, 40*fRatioY, tHighLight);
    C.DrawColor.A = 255;

    C.bUseBorder = true;
    DrawStretchedTexture(C, 240*fRatioX, 55*fRatioY, 160*fRatioX, 40*fRatioY, myRoot.FondMenu);
    C.TextSize(TitleText, W, H);
    C.DrawColor = BlackColor;
    C.SetPos((320-W/2)*fRatioX, (75-H/2)*fRatioY);
	C.DrawText(TitleText, false);
    C.bUseBorder = false;
    C.DrawColor = WhiteColor;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int i;

    if ((State==1) || (State==2))// IST_Press // to avoid auto-repeat
    {
        if (Key==0x0D/*IK_Enter*/)
	    {
            LookSpeedChanged();
            RumbleChanged();
			AutoAimChanged();
            InvPadChanged();
//            SaveConfigs();
			SaveConfig();
			myRoot.CloseMenu(false);
			// Also close menu as mentioned in state 'CloseMenu' (see XIIIWindow)
// NL 1306            log(Factor);
// NL 1306            PWin.Factor = Factor;
            PWin.PadConfigChanged();
            //Controller.FocusedControl.OnClick(Self);
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
	    if ((Key==0x25) || (Key==0x27))
	    {
            OnMenu = FindComponentIndex(FocusedControl);
            if (OnMenu == 0)
            {
                if (Key==0x25) RumbleCheck.bChecked = true;
                else if (Key==0x27) RumbleCheck.bChecked = false;
            }
            else if (OnMenu == 1)
            {
                if (Key==0x25) AutoAimCheck.bChecked = true;
                else if (Key==0x27) AutoAimCheck.bChecked = false;
            }
            else if (OnMenu == 2)
            {
                if (Key==0x25) InvPadCheck.bChecked = true;
                else if (Key==0x27) InvPadCheck.bChecked = false;
            }
            return true;
        }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



//_____________________________________________________________________________
function LookSpeedChanged()
{
//    local string Command;
    local float f;

    LSpeed = LookSpeedSlider.GetValue();
    f = 0.7+ float(LSpeed)/10.0;
    log("LSPEED: "$LSpeed$"  "$f);
//    log("CHANGING LOOKSPEED "$LSpeed$" "$f);
//    Command = "set XIIIPlayerController fLookSpeed "$f;
//    Log("LSpeed="$LSpeed@"Command='"$Command$"'");
//    GetPlayerOwner().ConsoleCommand(Command);
    GetPlayerOwner().fLookSpeed = f;
}

//_____________________________________________________________________________
function InvPadChanged()
{
    GetPlayerOwner().bInverseLook = InvPadCheck.bChecked;
}

//_____________________________________________________________________________
function RumbleChanged()
{
    GetPlayerOwner().bUseRumble = RumbleCheck.bChecked;
}

//_____________________________________________________________________________
function AutoAimChanged()
{
    GetPlayerOwner().iAutoAimMode = int(AutoAimCheck.bChecked);
}




