
class XIIIMenuDifficultyWindow extends XIIIWindow;

VAR XIIIButton EasyButton, MediumButton, HardButton;
VAR localized string TitleText, EasyText, MediumText, HardText;
VAR texture tBackGround[4], tHighLight;
VAR int YOrg, LineSpace;

//VAR XIIILabel TitleLabel;

function Created()
{
    local int CtrlIndex;

    Super.Created();

	CONST nbItems=3;
	LineSpace=29+(370-(nbItems*29))/(nbItems+1);
	YOrg=27+LineSpace;

	EasyButton = XIIIbutton(CreateControl(class'XIIIbutton', 308, YOrg*fScaleTo, 270, 29*fScaleTo));
    EasyButton.Text=EasyText;
	Controls[CtrlIndex] = EasyButton;
	CtrlIndex++;

	MediumButton = XIIIbutton(CreateControl(class'XIIIbutton', 308, (YOrg+LineSpace)*fScaleTo, 270, 29*fScaleTo));
    MediumButton.Text=MediumText;
	Controls[CtrlIndex] = MediumButton;
	CtrlIndex++;

	HardButton = XIIIbutton(CreateControl(class'XIIIbutton', 308, (YOrg+LineSpace*2)*fScaleTo, 270, 29*fScaleTo));
    HardButton.Text=HardText;
	Controls[CtrlIndex] = HardButton;
	CtrlIndex++;
}


function Paint(Canvas C, float X, float Y)
{
	LOCAL float W, H;

	SUPER.Paint(C, X, Y);

	CONST ImageW=350;
	CONST ImageH=370;

	DrawStretchedTexture(C, (610-ImageW-2)*fRatioX, ( 425 - ImageH - 2 )*fScaleTo*fRatioY, (ImageW+4)*fRatioX, (ImageH+4)*fRatioY*fScaleTo, myRoot.tFondNoir);

	DrawStretchedTexture(C, (610-ImageW)*fRatioX, ( 425 - ImageH )*fScaleTo*fRatioY, ImageW*fRatioX, 370*fScaleTo*fRatioY, tBackGround[0]);

	OnMenu = FindComponentIndex(FocusedControl);
	C.Style = 5;
	C.DrawColor.A = 180;
	DrawStretchedTexture(C, (610-ImageW)*fRatioX, ((Yorg-5+OnMenu*LineSpace)*fScaleTo)*fRatioY, ImageW*fRatioX, 40*fRatioY, tHighlight);
	C.DrawColor.A = 255;	

	DrawStretchedTexture(C, (610-ImageW-116)*fRatioX, ( 438 - 186 )*fScaleTo*fRatioY, 186*fRatioX, 186*fScaleTo*fRatioY, tBackGround[2]);
	DrawStretchedTexture(C, (610-ImageW-116)*fRatioX, ( 438 - 186 - 186 )*fScaleTo*fRatioY, 186*fRatioX, 186*fScaleTo*fRatioY, tBackGround[1]);
	DrawStretchedTexture(C, (610-186-ImageW-116)*fRatioX, ( 438 - 93 )*fScaleTo*fRatioY, 186*fRatioX, 93*fScaleTo*fRatioY, tBackGround[3]);
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


function ShowWindow()
{
	local string strLevel;
	local int Level;
	
	log("SHOWWINDOW DIFF");
	strLevel = GetPlayerOwner().ConsoleCommand("Get GameInfo Difficulty");
	Level = int( strLevel );

	myRoot.bFired = false;
	
	switch(Level)
	{
	case 0:
		OnMenu = 0;
		MediumButton.MouseLeave(); HardButton.MouseLeave();
		EasyButton.MouseEnter(); SetFocus(EasyButton);
		break;
	case 1:
		OnMenu = 1;
		EasyButton.MouseLeave(); HardButton.MouseLeave();
		MediumButton.MouseEnter(); SetFocus(MediumButton);
		break;
	case 2:
		OnMenu = 2;
		EasyButton.MouseLeave(); MediumButton.MouseLeave();
		HardButton.MouseEnter(); SetFocus(HardButton);
		break;
	}
	
	Super.ShowWindow();
	bShowCCL = true;
	bShowSEL = true;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if (State==1)// IST_Press // to avoid auto-repeat
	{
		if (Key==0x0D/*IK_Enter*/||Key==0x01)
		{
			Controller.FocusedControl.OnClick(Self);
			switch( FocusedControl )
			{
			case EasyButton:
				GetPlayerOwner().ConsoleCommand("set GameInfo Difficulty 0");
				break;
			case MediumButton: GetPlayerOwner().ConsoleCommand("set GameInfo Difficulty 1");
				break;
			case HardButton: GetPlayerOwner().ConsoleCommand("set GameInfo Difficulty 2");
				break;
			}
//			SaveConfigs();
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
			OnMenu = FindComponentIndex(FocusedControl);
			return true;
		}
		if (Key==0x28/*IK_Down*/)
		{
			NextControl(FocusedControl);
			OnMenu = FindComponentIndex(FocusedControl);
			return true;
		}
/*		if (Key==0x01)
		{
			OnMenu = FindComponentIndex(FocusedControl);
			return true;
		}*/
		//return false;
	}
	return super.InternalOnKeyEvent(Key, state, delta);
}




defaultproperties
{
     TitleText="Difficulty"
     EasyText="Arcade"
     MediumText="Normal"
     HardText="Realistic"
     VeryHardText="XXX"
     tBackGround(0)=Texture'XIIIMenuStart.interface_options.difficultydecor2'
     tBackGround(1)=Texture'XIIIMenuStart.Difficulty.difficultyjones01A'
     tBackGround(2)=Texture'XIIIMenuStart.Difficulty.difficultyjones02A'
     tBackGround(3)=Texture'XIIIMenuStart.Difficulty.difficultyjones03A'
     tHighlight=Texture'XIIIMenuStart.Control_Console_advanced.barreselectmenuoptadv'
}
