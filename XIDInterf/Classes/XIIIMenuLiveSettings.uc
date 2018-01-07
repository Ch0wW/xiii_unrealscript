class XIIIMenuLiveSettings extends XIIILiveWindow;

var localized string TitleText;
var XIIIGUIButton Buttons[6];
var GUILabel Labels[6];
var localized string LabelNames[6];
var localized string YesString, NoString, OffString;
var bool bVoiceThroughSpeakers;
var bool bOnlineStatus;
var bool bVoiceEnabled;
var bool bVoiceMaskEnabled;

var int VoiceMaskID;
const VOICEMASKCOUNT = 14;
var XboxLiveManager.eVoiceMask VoiceMasks[VOICEMASKCOUNT];
var localized string VoiceStrings[VOICEMASKCOUNT];
var localized string SaveQuestionText;
var float sliderval1;
var float sliderval2;
var float sliderval3;
var float sliderval4;

var int NumSkin, NbSkins;
var string MyClass, MyName, MyTeam;
var string MemoClass, MemoName, MemoTeam;
var Array<string> PlayerSkin, PlayerClass;

var XIIIGUIButton  sliders[4];

function Created()
{
  local int i;
  local XboxLiveManager.eVoiceMask VoiceMask;
  Super.Created();

	bVoiceThroughSpeakers = xboxlive.GetVoiceThroughSpeakers();
  bOnlineStatus = xboxlive.GetOnlineStatus();
  bVoiceEnabled = xboxlive.GetVoiceStatus();
  bVoiceMaskEnabled = xboxlive.GetVoiceMaskEnabled();

  VoiceMask = xboxlive.GetVoiceMask();

  for (i=0; i<VOICEMASKCOUNT; i++)
  {
    if (VoiceMasks[i] == VoiceMask)
    {
      VoiceMaskID = i;
    }
  }

  for (i=0; i<4; i++)
  {
    Buttons[i] = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 490+5+30, 135+i*35, 60, 30));
    Buttons[i].StyleName = "SquareButton";
    Buttons[i].bDrawArrows = true;
  	Controls[i] = Buttons[i];
    Labels[i] = GUILabel(CreateControl(class'GUILabel', 280-9, 135+i*35, 230, 26));
    Labels[i].caption = LabelNames[i];
    Labels[i].StyleName="LabelWhite";
    Labels[i].TextColor.R=255;
    Labels[i].TextColor.G=255;
    Labels[i].TextColor.B=255;
    controls[10+i] = Labels[i];
  }
  Buttons[i] = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 465-5, 135+4*35, 125, 30));
  Buttons[i].StyleName = "SquareButton";
  Buttons[i].bDrawArrows = true;
	Controls[i] = Buttons[i];
  Labels[i] = GUILabel(CreateControl(class'GUILabel', 280-9, 135+4*35, 200, 26));
  Labels[i].caption = LabelNames[i];
  Labels[i].StyleName="LabelWhite";
  Labels[i].TextColor.R=255;
  Labels[i].TextColor.G=255;
  Labels[i].TextColor.B=255;
  controls[10+i] = Labels[i];
  i++;
  Buttons[i] = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 465-5, 135+5*35, 125, 30));
  Buttons[i].StyleName = "SquareButton";
  Buttons[i].bDrawArrows = true;
	Controls[i] = Buttons[i];
  Labels[i] = GUILabel(CreateControl(class'GUILabel', 280-9, 135+5*35, 200, 26));
  Labels[i].caption = LabelNames[i];
  Labels[i].StyleName="LabelWhite";
  Labels[i].TextColor.R=255;
  Labels[i].TextColor.G=255;
  Labels[i].TextColor.B=255;
  controls[10+i] = Labels[i];

  sliderval1 = xboxlive.GetVoiceMaskSpecEnergyWeight();
  sliderval2 = xboxlive.GetVoiceMaskPitchScale();
  sliderval3 = xboxlive.GetVoiceMaskWhisperValue();
  sliderval4 = xboxlive.GetVoiceMaskRoboticValue();

  sliders[0] = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 490, 275, 100, 30));
  sliders[1] = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 490, 305, 100, 30));
  sliders[2] = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 490, 335, 100, 30));
  sliders[3] = XIIIGUIButton(CreateControl(class'XIIIGUIButton', 490, 365, 100, 30));
  sliders[0].StyleName="SquareButton";
  sliders[1].StyleName="SquareButton";
  sliders[2].StyleName="SquareButton";
  sliders[3].StyleName="SquareButton";
  Controls[6] = sliders[0];
  Controls[7] = sliders[1];
  Controls[8] = sliders[2];
  Controls[9] = sliders[3];

/*
	MyClass = GetPlayerOwner().GetDefaultURL("Class");
	MyName = GetPlayerOwner().GetDefaultURL("Name");
	MyTeam = GetPlayerOwner().GetDefaultURL("Team");
*/
	// version par GetDefaultUrl()
	MyName = GetPlayerOwner().GetDefaultURL("MyName");
	if (MyName == "")
		MyName = GetPlayerOwner().GetDefaultURL("Name");
	MyClass = GetPlayerOwner().GetDefaultURL("MySkin");
	MyTeam = GetPlayerOwner().GetDefaultURL("MyTeam");

	MemoName = MyName;
	MemoClass = MyClass;
	MemoTeam = MyTeam;

	NbSkins = class'MeshSkinList'.default.MeshSkinListInfo.Length;
	NumSkin = 0;
	for (i=0;i<NbSkins;i++)
	{
		PlayerSkin[i] = class'MeshSkinList'.default.MeshSkinListInfo[i].SkinReadableName;
		PlayerClass[i] = class'MeshSkinList'.default.MeshSkinListInfo[i].SkinName;
		if ( MyClass == PlayerClass[i] )
			NumSkin = i;
	}
	NumSkin = Clamp(NumSkin,0,NbSkins - 1);
  Buttons[5].Caption = PlayerSkin[NumSkin];
  if (xboxlive.IsIngame())
  {
    Buttons[5].bNeverFocus = true;
    Buttons[5].MenuState = MSAT_Disabled;
  }

  ResetButtons();
}

function ResetButtons()
{
  local int i;
  
  sliderval1 = xboxlive.GetVoiceMaskSpecEnergyWeight();
  sliderval2 = xboxlive.GetVoiceMaskPitchScale();
  sliderval3 = xboxlive.GetVoiceMaskWhisperValue();
  sliderval4 = xboxlive.GetVoiceMaskRoboticValue();

  if (bOnlineStatus)
	  Buttons[0].Caption = YesString;
  else
	  Buttons[0].Caption = NoString;
	
	if (bVoiceEnabled)
	  Buttons[1].Caption = NoString;
	else
	  Buttons[1].Caption = YesString;

  if (sliderval1>=0)
    sliders[0].Caption = ""$sliderval1;
  else
    sliders[0].Caption = offString;
  if (sliderval2>=0)
    sliders[1].Caption = ""$sliderval2;
  else
    sliders[1].Caption = offString;
  if (sliderval3>=0)
    sliders[2].Caption = ""$sliderval3;
  else
    sliders[2].Caption = offString;
  if (sliderval4>=0)
    sliders[3].Caption = ""$sliderval4;
  else
    sliders[3].Caption = offString;

  if (!bVoiceEnabled)
  {
	  Buttons[2].Caption = NoString;
    Buttons[2].bNeverFocus = true;
    Buttons[2].MenuState = MSAT_Disabled;
	  Buttons[3].Caption = NoString;
    Buttons[3].bNeverFocus = true;
    Buttons[3].MenuState = MSAT_Disabled;
    Buttons[4].bNeverFocus = true;
    Buttons[4].MenuState = MSAT_Disabled;
    sliders[0].bNeverFocus = true;
    sliders[1].bNeverFocus = true;
    sliders[2].bNeverFocus = true;
    sliders[3].bNeverFocus = true;
    sliders[0].bVisible    = false;
    sliders[1].bVisible    = false;
    sliders[2].bVisible    = false;
    sliders[3].bVisible    = false;
  }
  else
  {
    Buttons[2].bNeverFocus = false;
    if (Controller.FocusedControl == Buttons[2])
      Buttons[2].MenuState = MSAT_Focused;
    else
      Buttons[2].MenuState = MSAT_Blurry;
    if (bVoiceThroughSpeakers)
  	  Buttons[2].Caption = YesString;
    else
  	  Buttons[2].Caption = NoString;

    Buttons[3].bNeverFocus = false;
    if (Controller.FocusedControl == Buttons[3])
      Buttons[3].MenuState = MSAT_Focused;
    else
      Buttons[3].MenuState = MSAT_Blurry;
    if (bVoiceMaskEnabled)
  	  Buttons[3].Caption = YesString;
    else
  	  Buttons[3].Caption = NoString;
  	
    if (!bVoiceMaskEnabled)
    {
      Buttons[4].bNeverFocus = true;
      Buttons[4].MenuState = MSAT_Disabled;
      sliders[0].bNeverFocus = true;
      sliders[1].bNeverFocus = true;
      sliders[2].bNeverFocus = true;
      sliders[3].bNeverFocus = true;
      sliders[0].bVisible    = false;
      sliders[1].bVisible    = false;
      sliders[2].bVisible    = false;
      sliders[3].bVisible    = false;
    }
    else
    {
      Buttons[4].bNeverFocus = false;
      if (Controller.FocusedControl == Buttons[4])
        Buttons[4].MenuState = MSAT_Focused;
      else
        Buttons[4].MenuState = MSAT_Blurry;
      if (VoiceMasks[VoiceMaskID] == VOICE_Custom)
      {
        sliders[0].bNeverFocus = false;
        sliders[1].bNeverFocus = false;
        sliders[2].bNeverFocus = false;
        sliders[3].bNeverFocus = false;
        sliders[0].bVisible    = true;
        sliders[1].bVisible    = true;
        sliders[2].bVisible    = true;
        sliders[3].bVisible    = true;
      }
      else
      {
        sliders[0].bNeverFocus = true;
        sliders[1].bNeverFocus = true;
        sliders[2].bNeverFocus = true;
        sliders[3].bNeverFocus = true;
        sliders[0].bVisible    = false;
        sliders[1].bVisible    = false;
        sliders[2].bVisible    = false;
        sliders[3].bVisible    = false;
      }
    }
  }
  Buttons[4].Caption = VoiceStrings[VoiceMaskID];
}


function InitComponent(GUIController MyController,GUIComponent MyOwner)
{
  Super.InitComponent(MyController, MyOwner);
	OnClick = InternalOnClick;
}

function ShowWindow()
{
     OnMenu = 0; myRoot.bFired = false;
     Super.ShowWindow();
     bShowBCK = true;
     bShowRUN = false;
     bShowSEL = false;
}


function Paint(Canvas C, float X, float Y)
{
  Super.Paint(C, X, Y);
  PaintStandardBackground(C, X, Y, TitleText);

  if (xboxlive.GetVoiceThroughSpeakers() != bVoiceThroughSpeakers)
  {
    bVoiceThroughSpeakers = xboxlive.GetVoiceThroughSpeakers();
    if (bVoiceThroughSpeakers)
  	  Buttons[2].Caption = YesString;
    else
  	  Buttons[2].Caption = NoString;
  }
}


// Called when a button is clicked
function bool InternalOnClick(GUIComponent Sender)
{
    /*if (Sender == Controls[0])
    {
    }*/
    return true;
}

// Called when a button is clicked
function bool PrevValue(GUIComponent Sender)
{
  if (Sender == sliders[0])
  {
    if (sliderval1 <= 0)
      sliderval1 = -1.0;
    else if (sliderval1 > 0)
    {
      sliderval1-=0.05f;
      if (sliderval1<0)
        sliderval1 = 0;
    }
    xboxlive.SetVoiceMaskSpecEnergyWeight(sliderval1);
    if (sliderval1>=0)
      sliders[0].Caption = ""$sliderval1;
    else
      sliders[0].Caption = OffString;
  }
  if (Sender == sliders[1])
  {
    if (sliderval2 <= 0)
      sliderval2 = -1.0;
    else if (sliderval2 > 0)
    {
      sliderval2-=0.05f;
      if (sliderval2<0)
        sliderval2 = 0;
    }
    xboxlive.SetVoiceMaskPitchScale(sliderval2);
    sliders[1].Caption = ""$sliderval2;
    if (sliderval2>=0)
      sliders[1].Caption = ""$sliderval2;
    else
      sliders[1].Caption = OffString;
  }
  if (Sender == sliders[2])
  {
    if (sliderval3 <= 0)
      sliderval3 = -1.0;
    else if (sliderval3 > 0)
    {
      sliderval3-=0.05f;
      if (sliderval3<0)
        sliderval3 = 0;
    }
    xboxlive.SetVoiceMaskWhisperValue(sliderval3);
    sliders[2].Caption = ""$sliderval3;
    if (sliderval3>=0)
      sliders[2].Caption = ""$sliderval3;
    else
      sliders[2].Caption = offString;
  }
  if (Sender == sliders[3])
  {
    if (sliderval4 <= 0)
      sliderval4 = -1.0;
    else if (sliderval4 > 0)
    {
      sliderval4-=0.05f;
      if (sliderval4<0)
        sliderval4 = 0;
    }
    xboxlive.SetVoiceMaskRoboticValue(sliderval4);
    sliders[3].Caption = ""$sliderval4;
    if (sliderval4>=0)
      sliders[3].Caption = ""$sliderval4;
    else
      sliders[3].Caption = offString;
  }

  if (Sender == Controls[0])
  {
    bOnlineStatus = !bOnlineStatus;
    xboxlive.SetOnlineStatus(bOnlineStatus);
  }
  if (Sender == Controls[1])
  {
    bVoiceEnabled = !bVoiceEnabled;
    xboxlive.SetVoiceStatus(bVoiceEnabled);
  }
  if (Sender == Controls[2])
  {
  	bVoiceThroughSpeakers = !bVoiceThroughSpeakers;
    xboxlive.SetVoiceThroughSpeakers(bVoiceThroughSpeakers);
	  bVoiceThroughSpeakers = xboxlive.GetVoiceThroughSpeakers();
  }
  if (Sender == Controls[3])
  {
    bVoiceMaskEnabled = !bVoiceMaskEnabled;
    xboxlive.SetVoiceMaskEnabled(bVoiceMaskEnabled);
  }
  if (Sender == Controls[4])
  {
    VoiceMaskID--;
    if (VoiceMaskID<0)
      VoiceMaskID = VOICEMASKCOUNT-1;
    xboxlive.SetVoiceMask(VoiceMasks[VoiceMaskID]);
  }
  if (Sender == Buttons[5])
  {
    NumSkin--;
  	NumSkin = Clamp(NumSkin,0,NbSkins - 1);
    Buttons[5].Caption = PlayerSkin[NumSkin];
		MyClass = PlayerClass[NumSkin];
  }
  ResetButtons();
  return true;
}

// Called when a button is clicked
function bool NextValue(GUIComponent Sender)
{
  if (Sender == sliders[0])
  {
    if (sliderval1 < 0)
      sliderval1 = 0;
    else if (sliderval1 < 1.0)
    {
      sliderval1+=0.05;
      if (sliderval1>1.0)
        sliderval1 = 1.0;
    }
    xboxlive.SetVoiceMaskSpecEnergyWeight(sliderval1);
    if (sliderval1>=0)
      sliders[0].Caption = ""$sliderval1;
    else
      sliders[0].Caption = OffString;
  }
  if (Sender == sliders[1])
  {
    if (sliderval2 < 0)
      sliderval2 = 0;
    else if (sliderval2 < 1.0)
    {
      sliderval2+=0.05;
      if (sliderval2>1.0)
        sliderval2 = 1.0;
    }
    xboxlive.SetVoiceMaskPitchScale(sliderval2);
    if (sliderval2>=0)
      sliders[1].Caption = ""$sliderval2;
    else
      sliders[1].Caption = OffString;
  }
  if (Sender == sliders[2])
  {
    if (sliderval3 < 0)
      sliderval3 = 0;
    else if (sliderval3 < 1.0)
    {
      sliderval3+=0.05;
      if (sliderval3>1.0)
        sliderval3 = 1.0;
    }
    xboxlive.SetVoiceMaskWhisperValue(sliderval3);
    if (sliderval3>=0)
      sliders[2].Caption = ""$sliderval3;
    else
      sliders[2].Caption = OffString;
  }
  if (Sender == sliders[3])
  {
    if (sliderval4 < 0)
      sliderval4 = 0;
    else if (sliderval4 < 1.0)
    {
      sliderval4+=0.05;
      if (sliderval4>1.0)
        sliderval4 = 1.0;
    }
    xboxlive.SetVoiceMaskRoboticValue(sliderval4);
    if (sliderval4>=0)
      sliders[3].Caption = ""$sliderval4;
    else
      sliders[3].Caption = OffString;
  }

  if (Sender == Controls[0])
  {
    bOnlineStatus = !bOnlineStatus;
    xboxlive.SetOnlineStatus(bOnlineStatus);
  }
  if (Sender == Controls[1])
  {
    bVoiceEnabled = !bVoiceEnabled;
    xboxlive.SetVoiceStatus(bVoiceEnabled);
  }
  if (Sender == Controls[2])
  {
  	bVoiceThroughSpeakers = !bVoiceThroughSpeakers;
    xboxlive.SetVoiceThroughSpeakers(bVoiceThroughSpeakers);
	  bVoiceThroughSpeakers = xboxlive.GetVoiceThroughSpeakers();
  }
  if (Sender == Controls[3])
  {
    bVoiceMaskEnabled = !bVoiceMaskEnabled;
    xboxlive.SetVoiceMaskEnabled(bVoiceMaskEnabled);
  }
  if (Sender == Controls[4])
  {
    VoiceMaskID++;
    if (VoiceMaskID>=VOICEMASKCOUNT)
      VoiceMaskID = 0;
    xboxlive.SetVoiceMask(VoiceMasks[VoiceMaskID]);
  }
  if (Sender == Buttons[5])
  {
    NumSkin++;
  	NumSkin = Clamp(NumSkin,0,NbSkins - 1);
    Buttons[5].Caption = PlayerSkin[NumSkin];
		MyClass = PlayerClass[NumSkin];
  }
  ResetButtons();
  return true;
}

function bool MayISave()
{
	return (
		( MemoClass != MyClass )
	);
}
function SaveMsgBoxReturn(byte bButton)
{
	if ( (bButton & QBTN_Yes) != 0)
	{
		ProcessSave();
	}
	else
	{
		myRoot.CloseMenu(true);
	}
}


function ProcessSave()
{
	GetPlayerOwner().UpdateURL("MySkin",MyClass,true);
	SaveConfigs();
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (state==1/* || state==2*/)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
	    {
          //Controller.FocusedControl.OnClick(Self);
          InternalOnClick(Controller.FocusedControl);
          return true;
	    }
	    if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
	    {
		//SaveConfigs();
	        //myRoot.CloseMenu(true);
		if (MayISave())
		{
			myRoot.OpenMenu("XIDInterf.XIIILiveMsgBox");
			MsgBox = XIIILiveMsgBox(myRoot.ActivePage);
			MsgBox.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);
			MsgBox.SetupQuestion(SaveQuestionText, QBTN_Yes | QBTN_No, QBTN_Yes, "");
			MsgBox.OnButtonClick = SaveMsgBoxReturn;
		}
		else
		{
	        myRoot.CloseMenu(true);
		}
    	    return true;
	    }
	    if (Key==0x25/*IK_Left*/)
	    {
	        PrevValue(Controller.FocusedControl);
    	    return true;
	    }
	    if (Key==0x27/*IK_Right*/)
	    {
	        NextValue(Controller.FocusedControl);
    	    return true;
	    }
    }
    else if (state==2)
    {
	    if (Key==0x25/*IK_Left*/)
	    {
	        PrevValue(Controller.FocusedControl);
    	    return true;
	    }
	    if (Key==0x27/*IK_Right*/)
	    {
	        NextValue(Controller.FocusedControl);
    	    return true;
	    }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}



