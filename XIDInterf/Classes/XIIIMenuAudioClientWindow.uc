//============================================================================
// Audio Volumes Configuration Menu
//============================================================================
class XIIIMenuAudioClientWindow extends XIIIWindow;


var XIIICheckBoxControl MusicCheck;
var localized string TitleText, MusicText, OnText, OffText;

var texture tBackGround[4], tHighLight;
var string sBackGround[4], sHighlight;

var int MusicValue, MusicValueOld;

var sound menuzik;


//============================================================================
function Created()
{
	local int i;

	Super.Created();

	for (i=0; i<4; i++)
		tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));

	tHighlight = texture(DynamicLoadObject(sHighlight, class'Texture'));

	// Music
	MusicCheck = XIIICheckboxControl(CreateControl(class'XIIICheckboxControl', 288, 206*fScaleTo, 300, 29*fScaleTo));
	MusicCheck.Text = MusicText;
	MusicCheck.sYes = OnText;
	MusicCheck.sNo = OffText;

	Controls[0] = MusicCheck;

	// default values
	MusicValue = int( GetPlayerOwner().ConsoleCommand("get HXAudio.HXAudioSubsystem MusicSliderPos") );
	if ( MusicValue != 0 )
		MusicValue = 2;
	MusicValueOld = MusicValue;
	// false value is no music
	MusicCheck.bChecked = (MusicValue != 0);
}


function ShowWindow()
{
     Super.ShowWindow();

     bShowCCL = true;
     bShowACC = true;
}


function Paint(Canvas C, float X, float Y)
{
    local float fScale, fHeight, W, H;
    local int i;

    Super.Paint(C,X,Y);

	DrawStretchedTexture(C, 253*fRatioX, 54*fRatioY, 353*fRatioX, 377*fScaleTo*fRatioY, myRoot.tFondNoir);

	DrawStretchedTexture(C, 255*fRatioX, 56*fRatioY, 349*fRatioX, 373*fScaleTo*fRatioY, tBackGround[0]);

	C.Style = 5;
	C.DrawColor.A = 180;
	DrawStretchedTexture(C, 255*fRatioX, (201*fScaleTo)*fRatioY, 349*fRatioX, 40*fRatioY, tHighlight);
	C.DrawColor.A = 255;
	DrawStretchedTexture(C, 120*fRatioX, 60*fRatioY, 180*fRatioX, 190*fScaleTo*fRatioY, tBackGround[1]);
	DrawStretchedTexture(C, 120*fRatioX, (60+190*fScaleTo)*fRatioY, 180*fRatioX, 190*fScaleTo*fRatioY, tBackGround[2]);
	DrawStretchedTexture(C, -60*fRatioX, (60+190*fScaleTo)*fRatioY, 180*fRatioX, 190*fScaleTo*fRatioY, tBackGround[3]);
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
    if ((State==1)||(State==2)) //  IST_Press
    {
        if (Key==0x0D/*IK_Enter*/)
	    {
			// new value for music ?
			if ( MusicValue != MusicValueOld )
			{
				GetPlayerOwner().StopMusic();
				GetPlayerOwner().SetMusicSliderPos(MusicValue);
				GetPlayerOwner().PlayMusic(menuzik);
				GetPlayerOwner().ConsoleCommand("set HXAudio.HXAudioSubsystem MusicSliderPos "$MusicValue);
			}
	        
			
//			SaveConfigs();
			SaveConfig();
			myRoot.CloseMenu(false);
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
			if (Key==0x25)
			{
				MusicCheck.bChecked = true;
				MusicValue = 2;
			}
			else
			{
				if (Key==0x27)
				{
					MusicCheck.bChecked = false;
					MusicValue = 0;
				}
			}
		}
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}





defaultproperties
{
     TitleText="Audio Options"
     MusicText="Music"
     SoundVolumeText="Sound Volume"
     OnText="On"
     OffText="Off"
     sBackground(0)="XIIIMenuStart.sonsdecor3"
     sBackground(1)="XIIIMenuStart.sonsXIII01A"
     sBackground(2)="XIIIMenuStart.sonsXIII02A"
     sBackground(3)="XIIIMenuStart.sonsXIII03A"
     sHighlight="XIIIMenuStart.barreselectmenuoptadv"
     menuzik=Sound'XIIIsound.Music__MapMenu.MapMenu__hMusicInit'
}
