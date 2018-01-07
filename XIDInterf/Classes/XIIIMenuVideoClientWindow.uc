//===========================================================================
// Video Options
//===========================================================================
class XIIIMenuVideoClientWindow extends XIIIWindow
	config(user);

// Brightness, Gamma, Contrast
VAR XIIIHSliderControl BrightnessSlider, GammaSlider, ContrastSlider, HCenterSlider, VCenterSlider;
VAR XIIIComboControl ResCombo;//, DepthCombo;
VAR XIIIButton DefaultButton;
var localized string TitleText, BrightnessText, GammaText, ContrastText, DefaultText;
var localized string CenterText, HCenterText, VCenterText, ResText, DepthText;

var texture tBackground[4], tCenter, tHighlight;
var string sBackground[4], sCenter;

var int  OnBright, OnGamma, OnContrast, OnRes, YOrg, LineSpace, oldDecalX, oldDecalY;
var config int DecalX, DecalY;         // better be moved to LevelInfo
var config float UserBrightness, UserContrast, UserGamma;
var float  OldBright, OldGamma, OldContrast;
var bool       bInitialized;
var string     OldSettings;


function Created()
{
	LOCAL int i, MinRate, temp, CtrlIndex, nbItems;
	LOCAL string NextLook, NextDesc, NewVideoMode;
	LOCAL array<levelinfo.resinfo> videomodes;

	Super.Created();

	switch ( myRoot.CurrentPF )
	{
	case 0: // PC
		nbItems=5; // Brightness, Gamma, Contrast & Resolution + Default
		break;
	case 2: // XBox
		nbItems=4; //  Brightness, Gamma & Contrast + Default
		break;
	case 1: // PS2
	case 3: // GCube
		oldDecalX = DecalX;
		oldDecalY = DecalY;
//		myRoot.GetLevel().DecalScreen(0, DecalX);
//		myRoot.GetLevel().DecalScreen(1, DecalY);
		nbItems=2; // centrage X & Y
		break;
	}

	LineSpace=29+(370-(nbItems*29))/(nbItems+1);
	YOrg=27+LineSpace;

	tHighlight = texture(DynamicLoadObject("XIIIMenuStart.barreselectmenuoptadv", class'Texture'));

	tBackGround[0] = texture(DynamicLoadObject(sBackGround[0], class'Texture'));
	tBackGround[1] = texture(DynamicLoadObject(sBackGround[1], class'Texture'));
	tBackGround[2] = texture(DynamicLoadObject(sBackGround[2], class'Texture'));
	tBackGround[3] = texture(DynamicLoadObject(sBackGround[3], class'Texture'));
	tCenter = texture(DynamicLoadObject(sCenter, class'Texture'));

	if ( myRoot.CurrentPF==0 || myRoot.CurrentPF==2 ) // PC ou XBox
	{
		 // Brightness
		BrightnessSlider = XIIIHSliderControl(CreateControl(class'XIIIHSliderControl', 308, YOrg*fScaleTo, 300, 29*fScaleTo));
		BrightnessSlider.SetRange(0, 10, 1, 150);
		OnBright = int( UserBrightness * 10 );
		BrightnessSlider.SetValue(OnBright);
		BrightnessSlider.Text = BrightnessText;
		BrightnessSlider.OnChange = BrightnessChanged;
		Controls[CtrlIndex] = BrightnessSlider;
		CtrlIndex++;

		// Gamma
		GammaSlider = XIIIHSliderControl(CreateControl(class'XIIIHSliderControl', 308, (YOrg+LineSpace)*fScaleTo, 300, 29*fScaleTo));
		GammaSlider.SetRange(5, 15, 1, 150);
		OnGamma = int( UserGamma * 10);
		GammaSlider.SetValue(OnGamma);
		GammaSlider.Text = GammaText;
		GammaSlider.OnChange = GammaChanged;
		Controls[CtrlIndex] = GammaSlider;
		CtrlIndex++;

		// Contrast
		ContrastSlider = XIIIHSliderControl(CreateControl(class'XIIIHSliderControl', 308, (YOrg+LineSpace*CtrlIndex)*fScaleTo, 300, 29*fScaleTo));
		ContrastSlider.SetRange(0, 10, 1, 150);
		OnContrast = int( UserContrast * 10);
		ContrastSlider.SetValue(OnContrast);
		ContrastSlider.Text = ContrastText;
		ContrastSlider.OnChange = ContrastChanged;
		Controls[CtrlIndex] = ContrastSlider;
		CtrlIndex++;

		if ( myRoot.CurrentPF==0 ) // PC Only
		{
			ResCombo = XIIIComboControl(CreateControl(class'XIIIComboControl', 308, (YOrg+LineSpace*3)*fScaleTo, 300, 29*fScaleTo));

			myRoot.Getlevel().GETAVAILABLERES(videomodes);
			for (i=0; i<videomodes.length; i++)
			{
				NewVideoMode=string(videomodes[i].PixelWidth)$"x"$string(videomodes[i].PixelHeight);
				ResCombo.AddItem(NewVideoMode);
				log ("===>"@NewVideoMode );
			}
			OnRes = ResCombo.FindItemIndex(myRoot.GetPlayerOwner().ConsoleCommand( "GETCURRENTRES" ));
			ResCombo.SetSelectedIndex(OnRes);
			ResCombo.Text = ResText;
			ResCombo.bArrows = true;
			Controls[CtrlIndex] = ResCombo;
			CtrlIndex++;
		}

		// Default button
		DefaultButton = XIIIbutton( CreateControl(class'XIIIbutton', 408, (YOrg+LineSpace*CtrlIndex)*fScaleTo, 100, 29) );
		DefaultButton.Text = DefaultText;
		DefaultButton.bUseBorder = true;
		Controls[CtrlIndex] = DefaultButton;
		CtrlIndex++;
	}
	else // PS2 && Cube
	{
		HCenterSlider = XIIIHSliderControl(CreateControl(class'XIIIHSliderControl', 308, (YOrg)*fScaleTo, 300, 29*fScaleTo));
		HCenterSlider.SetRange(-10, 10, 1, 150);
		HCenterSlider.Text = HCenterText;
		HCenterSlider.SetValue(DecalX);
		Controls[CtrlIndex] = HCenterSlider;
		CtrlIndex++;

		VCenterSlider = XIIIHSliderControl(CreateControl(class'XIIIHSliderControl', 308, (YOrg+LineSpace)*fScaleTo, 300, 29*fScaleTo));
		VCenterSlider.SetRange(-10, 10, 1, 150);
		VCenterSlider.Text = VCenterText;
		VCenterSlider.SetValue(DecalY);
		Controls[CtrlIndex] = VCenterSlider;
		CtrlIndex++;
	}
}

function ShowWindow()
{
	OldBright = UserBrightness;
	OldGamma = UserGamma;
	OldContrast = UserContrast;

	BrightnessSlider.SetValue(OnBright);
	GammaSlider.SetValue(OnGamma);
	ContrastSlider.SetValue(OnContrast);

	if (myRoot.CurrentPF == 0)
	{
		OnRes = ResCombo.FindItemIndex(myRoot.GetPlayerOwner().ConsoleCommand( "GETCURRENTRES" ));
		ResCombo.SetSelectedIndex(OnRes);
	}
	Super.ShowWindow();
	bShowCCL = true;
	bShowACC = true;
}


function Paint(Canvas C, float X, float Y)
{
	local float fScale, fHeight, W, H;
	
	Super.Paint(C, X, Y);

	CONST ImageW=350;
	CONST ImageH=370;
	
	fHeight = fScaleTo;//myRoot.ScreenHeight/480;
    if (myRoot.CurrentPF > 0) fHeight = 0.95;
	fHeight= (fHeight*416) / 2;
	DrawStretchedTexture(C, (610-ImageW-2)*fRatioX, ( 425 - ImageH - 2 )*fScaleTo*fRatioY, (ImageW+4)*fRatioX, (ImageH+4)*fRatioY*fScaleTo, myRoot.tFondNoir);

	DrawStretchedTexture(C, (610-ImageW)*fRatioX, ( 425 - ImageH )*fScaleTo*fRatioY, ImageW*fRatioX, 370*fScaleTo*fRatioY, tBackGround[0]);

	OnMenu = FindComponentIndex(FocusedControl);
	C.Style = 5;
	C.DrawColor.A = 180;
	DrawStretchedTexture(C, (610-ImageW)*fRatioX, ((Yorg-5+OnMenu*LineSpace)*fScaleTo)*fRatioY, ImageW*fRatioX, 40*fRatioY, tHighlight);
	C.DrawColor.A = 255;	

	DrawStretchedTexture(C, (610-ImageW-130)*fRatioX, ( 448 - 192 )*fScaleTo*fRatioY, 192*fRatioX, 192*fScaleTo*fRatioY, tBackGround[2]);
	DrawStretchedTexture(C, (610-ImageW-130)*fRatioX, ( 448 - 192 - 192 )*fScaleTo*fRatioY, 192*fRatioX, 192*fScaleTo*fRatioY, tBackGround[1]);
	DrawStretchedTexture(C, (610-192-ImageW-130)*fRatioX, ( 448 - 192 )*fScaleTo*fRatioY, 192*fRatioX, 192*fScaleTo*fRatioY, tBackGround[3]);

	C.Style = 1;

	C.bUseBorder = true;
	DrawStretchedTexture(C, 150*fRatioX, 30*fRatioY, 170*fRatioX, 35*fRatioY, myRoot.FondMenu);
	C.TextSize(TitleText, W, H);
	C.DrawColor = BlackColor;
	C.SetPos((150 + (160-W)/2)*fRatioX, (47.5-H/2)*fRatioY);
	C.DrawText(TitleText, false);
	C.bUseBorder = false;
	C.DrawColor = WhiteColor;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	local int i;

	if ((State==1) || (State==2))// IST_Press // to avoid auto-repeat
	{
		if ( Key==0x0D || Key==0x01 )
		{
			if ( FocusedControl==DefaultButton)
			{
				BrightnessSlider.SetValue(5);
				GammaSlider.SetValue(10);
				ContrastSlider.SetValue(5);
				BrightnessChanged( BrightnessSlider );
				GammaChanged( GammaSlider );
				ContrastChanged( ContrastSlider );
				return true;
			}
		}

		if ( Key==0x0D/*IK_Enter*/ )
		{
			ConfirmSettings();
			if ( myRoot.CurrentPF == 0 )
				GetPlayerOwner().ConsoleCommand("SETRES"@ResCombo.GetValue());
//			SaveConfigs();
			SaveConfig();
			myRoot.CloseMenu(false);
			Controller.FocusedControl.OnClick(Self);
			return true;
		}
		if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
		{
			GetPlayerOwner().ConsoleCommand("Brightness "$OldBright);
			GetPlayerOwner().ConsoleCommand("Gamma "$OldGamma);
			GetPlayerOwner().ConsoleCommand("Contrast "$OldContrast);
			if ( ( myRoot.CurrentPF == 1 ) || ( myRoot.CurrentPF == 3 ) )
			{
				myRoot.GetLevel().DecalScreen(0, oldDecalX-DecalX);
				myRoot.GetLevel().DecalScreen(1, oldDecalY-DecalY);
				DecalX = oldDecalX;
				DecalY = oldDecalY;
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
		if ((Key==0x25) || (Key==0x27))
		{
			if ( FocusedControl==BrightnessSlider )
			{
				BrightnessChanged( BrightnessSlider );
			}
			else if ( FocusedControl==GammaSlider )
			{
				GammaChanged( GammaSlider );
			}
			else if ( FocusedControl==ContrastSlider )
			{
				ContrastChanged( ContrastSlider );
			}
			else if ( FocusedControl == ResCombo )
			{
			   if ( Key==0x25 ) OnRes--;
			   if ( Key==0x27 ) OnRes++;
			   OnRes = Clamp( OnRes,0,ResCombo.Items.Length-1);
			   ResCombo.SetSelectedIndex(OnRes);
			}
			else if ( FocusedControl == HCenterSlider)
			{
				if (Key==0x25 && DecalX!=-10) { myRoot.GetLevel().DecalScreen(0, -1); DecalX--; }
				if (Key==0x27 && DecalX!=10) { myRoot.GetLevel().DecalScreen(0, 1); DecalX++; }
			}
			else if ( FocusedControl == VCenterSlider)
			{
				if (Key==0x25 && DecalY!=-10) { myRoot.GetLevel().DecalScreen(1, -1); DecalY--; }
				if (Key==0x27 && DecalY!=10) { myRoot.GetLevel().DecalScreen(1, 1); DecalY++; }
			}
			return true;
		}
	}
	return super.InternalOnKeyEvent(Key, state, delta);
}


function ConfirmSettings()
{
	if ( myRoot.CurrentPF==0 || myRoot.CurrentPF==2 )
	{
		UserBrightness = BrightnessSlider.GetValue() * 0.1;
		UserGamma = GammaSlider.GetValue() * 0.1;
		UserContrast = ContrastSlider.GetValue() * 0.1;
		BrightnessChanged( BrightnessSlider );
		ContrastChanged( ContrastSlider );
		GammaChanged( GammaSlider );
	}
}

function BrightnessChanged( GUIComponent Sender )
{
	LOCAL float tmp;
	tmp = BrightnessSlider.GetValue() * 0.1;
	GetPlayerOwner().ConsoleCommand("Brightness "$tmp );
}

function GammaChanged( GUIComponent Sender )
{
	LOCAL float tmp;
	tmp = GammaSlider.GetValue() * 0.1;
	GetPlayerOwner().ConsoleCommand("Gamma "$tmp);
}

function ContrastChanged( GUIComponent Sender )
{
	LOCAL float tmp;
	tmp = ContrastSlider.GetValue() * 0.1;
	GetPlayerOwner().ConsoleCommand("Contrast "$tmp);
}





defaultproperties
{
     TitleText="Video Options"
     BrightnessText="Brightness"
     GammaText="Gamma"
     ContrastText="Contrast"
     DefaultText="Default"
     CenterText="CENTER"
     HCenterText="Horizontal"
     VCenterText="Vertical"
     ResText="Resolution"
     DepthText="Depth"
     sBackground(0)="XIIIMenuStart.VideoDecor1"
     sBackground(1)="XIIIMenuStart.VideoJones01A"
     sBackground(2)="XIIIMenuStart.VideoJones02A"
     sBackground(3)="XIIIMenuStart.VideoJones03A"
     sCenter="XIIIMenuStart.Boutonvideo2"
     UserBrightness=0.500000
     UserContrast=0.500000
     UserGamma=1.000000
}
