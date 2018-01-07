// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class XIIILiveMsgBox extends XIIILiveWindow;

var GUILabel lMessage;
var Material MessageIcon;	// Like Warning/Question/Exclamation
var localized string ButtonNames[8]; // Buttons Names: Ok, Cancel, Retry, Continue, Yes, No, Abort, Ignore.  Clamped [0,7].
var array<XIIIGUIButton> Buttons;
var XIIIGUIButton DefaultButton, CancelButton;

var float MarginWidth, MarginHeight;

var bool ShowWorking;
var texture tWorking[4];
var string sWorking[4];

var int frameCounter;
var int index;

delegate OnButtonClick(byte bButton);
delegate OnTick(float deltatime);

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
  local int i;

	OnPreDraw=InternalOnPreDraw;
	Super.Initcomponent(pMyController, MyOwner);
	lMessage=GUILabel(Controls[1]);
	ParentPage.InactiveFadeColor=class'Canvas'.static.MakeColor(128,128,128,255);
  OnKeyEvent=InternalOnKeyEvent;

  for (i=0; i<4; i++)
    tWorking[i] = texture(DynamicLoadObject(sWorking[i], class'Texture'));
}

FUNCTION ShowWindow( )
{
	bShowACC = true;
}

function PaintGfxBackground(Canvas C, float X, float Y)
{
  local float W, H;
  C.DrawColor = WhiteColor;
  C.Style = 5;

  if (ShowWorking)
  {
    if (frameCounter++ > 12)
    {
        frameCounter = 0;
        index = index+1;
        if (index>3) index=0;
    }
    DrawStretchedTexture(C, WinLeft+MarginWidth/2+(WinWidth-tWorking[index].USize)/2, WinTop+MarginHeight, tWorking[index].USize, tWorking[index].VSize, tWorking[index]);
  }

  C.bUseBorder = false;
  C.DrawColor = BlackColor;
}

function InitBox(float _OrgX, float _OrgY, float _LineWidth, float _LineHeight, float _Width, float _Height)
{
    WinWidth=_Width;            // Set Window's width
    WinHeight=_Height;           // Set Window's height
    WinTop=_OrgY;            // Set the windows location on the Y axis
    WinLeft=_OrgX;           // Set the windows location on the X axis
    MarginWidth = _LineWidth;
    MarginHeight = _LineHeight;

    Controls[0].WinWidth=_Width;            // Set Window's width
    Controls[0].WinHeight=_Height;           // Set Window's height
    Controls[0].WinTop=_OrgY+_lineheight*2+30;            // Set the windows location on the Y axis
    Controls[0].WinLeft=_OrgX;           // Set the windows location on the X axis


    if (GUILabel(Controls[0]).Caption=="")
    {
        Controls[0].WinWidth=_Width;
        Controls[0].WinHeight=0; // no message
        Controls[0].WinTop=_OrgY;
        Controls[0].WinLeft=_OrgX;
    }

    Controls[1].WinWidth=_Width-2*(_LineWidth+1);
    Controls[1].WinHeight=_Height-2*(_LineHeight+1)+10;
    Controls[1].WinTop=_OrgY+_Height/2+35;
    Controls[1].WinLeft=_OrgX+_LineWidth;
}

event Tick(float deltatime)
{
	OnTick(deltatime);
}

function bool InternalOnPreDraw(Canvas C)
{
local float XL, YL;
local int i;
local array<string> MsgArray, MsgArray2;
local int NeededHeight;

    // captions
	if (GUILabel(Controls[0]).TextFont != "")
		C.Font = Controller.GetMenuFont(GUILabel(Controls[0]).TextFont).GetFont(C.SizeX);

	C.TextSize("W", XL, YL);
	C.WrapStringToArray(GUILabel(Controls[0]).Caption, MsgArray2, GUILabel(Controls[0]).ActualWidth(), "|");
    YL *= (MsgArray2.Length+1);
	Controls[0].WinHeight = YL + GUILabel(Controls[0]).Style.BorderOffsets[1] + GUILabel(Controls[0]).Style.BorderOffsets[3];

	if (lMessage.TextFont != "")
		C.Font = Controller.GetMenuFont(lMessage.TextFont).GetFont(C.SizeX);

	C.TextSize("W", XL, YL);
	C.WrapStringToArray(lMessage.Caption, MsgArray, lMessage.ActualWidth(), "|");
    YL *= (MsgArray.Length+1); // 0 is first index.

	if (lMessage.Style != None)
		YL += lMessage.Style.BorderOffsets[1] + lMessage.Style.BorderOffsets[3];

	lMessage.WinHeight = YL;

	if (Buttons.Length==0)
	  NeededHeight = lMessage.WinHeight + Controls[0].WinHeight + 2*MarginHeight;
	else
	  NeededHeight = lMessage.WinHeight + Buttons[0].ActualHeight() + Controls[0].WinHeight + 2*MarginHeight;
    if (NeededHeight > WinHeight)
        WinHeight = NeededHeight;

  Controls[0].WinTop = WinTop + MarginHeight;
  if (ShowWorking)
    Controls[0].WinTop += 32+5;
	lMessage.WinTop = WinTop + WinHeight/2 - lMessage.WinHeight/2 + lMessage.Style.BorderOffsets[1] + lMessage.Style.BorderOffsets[1] + 10;

	for (i = 0; i<Buttons.Length; i++)
    {
		Buttons[i].WinTop = WinTop + WinHeight - Buttons[i].ActualHeight() - 2*MarginHeight;
    }

	fRatioX = C.ClipX / 640;
	fRatioY = C.ClipY / 480;

    OnPreDraw=None;
	return true;
}

function LayoutButtons(byte ActiveButton)
{
local int i;
local float left, HalfBtnW, btnw;

	// Simply center the button(s)
	HalfBtnW = WinWidth /(2*Buttons.Length + (Buttons.Length + 1)); // interval is half button width
	btnw = 2 * HalfBtnW;
	left = HalfBtnW + WinLeft;
	
//	NextControl(FocusedControl);

	for (i = 0; i<Buttons.Length; i++)
	{
		Buttons[i].WinLeft = left;
		Buttons[i].WinWidth = btnw;
        Buttons[i].WinHeight = 30*fScaleTo;
		left += 3 * HalfBtnW;
		
		Buttons[i].WinTop = WinTop+WinHeight - Buttons[i].WinHeight - 5;
	}
}

function Paint(Canvas C, float X, float Y)
{
    local float XX,YY,W, H;
    local int i;

    Super.Paint(C,X,Y);

    C.DrawMsgboxBackground(true, WinLeft, WinTop, MarginWidth, MarginHeight, WinWidth, WinHeight);
    PaintGfxBackground(C, X, Y);
    C.DrawColor = WhiteColor;       // always exit a paint with a white color !
}

function UpdateTextDisplayed(string NewText)
{
    lMessage.Caption = NewText;
	OnPreDraw=InternalOnPreDraw;
}

function SetupQuestion(string Question, byte bButtons, byte ActiveButton, optional string Caption)
{
	LOCAL XIIIGUIButton DefaultButton;
//  if (caption == "")
//    caption = "Error";
    GUILabel(Controls[0]).Caption = Caption;

  if (bButtons==0)
    ShowWorking = true;

	lMessage.Caption = Question;

	// Create Buttons Based on Buttons parameter
	if ((bButtons & QBTN_Ok) != 0)
		AddButton(0, ActiveButton==QBTN_Ok, DefaultButton);
	if ((bButtons & QBTN_Continue) != 0)
		AddButton(3, ActiveButton==QBTN_Continue, DefaultButton);
	if ((bButtons & QBTN_Ignore) != 0)
		AddButton(7, ActiveButton==QBTN_Ignore, DefaultButton);
	if ((bButtons & QBTN_Yes) != 0)
		AddButton(4, ActiveButton==QBTN_Yes, DefaultButton);
	if ((bButtons & QBTN_No) != 0)
		AddButton(5, ActiveButton==QBTN_No, DefaultButton);
	if ((bButtons & QBTN_Abort) != 0)
		AddButton(6, ActiveButton==QBTN_Abort, DefaultButton);
	if ((bButtons & QBTN_Retry) != 0)
		AddButton(2, ActiveButton==QBTN_Retry, DefaultButton);
	if ((bButtons & QBTN_Cancel) != 0)
	{
		AddButton(1, ActiveButton==QBTN_Cancel, DefaultButton);
		CancelButton = Buttons[Buttons.Length-1];
	}
	LayoutButtons(ActiveButton);
	if ( DefaultButton==none )
		NextControl(FocusedControl);
	else
		DefaultButton.FocusFirst( self, false );
}

function bool AddButton(int idesc, bool bDefault, out XIIIGUIButton DefaultButton )
{
	LOCAL XIIIGUIButton btn;

	btn = new class'XIIIGUIButton';
	btn.StyleName="MsgBoxButton";
	btn.InitComponent(Controller, MenuOwner);

	Controls[Controls.Length] = btn;
	Buttons[Buttons.Length] = btn;
	btn.Caption = ButtonNames[Clamp(idesc,0,7)];
	btn.OnClick = ButtonClick;
	btn.Tag = 1 << idesc;
	if ( bDefault )
		DefaultButton=btn;
	return bDefault;
}

function bool ButtonClick(GUIComponent Sender)
{
	local int T;

	T = XIIIGUIButton(Sender).Tag;

	ParentPage.InactiveFadeColor=ParentPage.Default.InactiveFadeColor;
	Controller.CloseMenu(true);
	OnButtonClick(T);
	return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
  if (Buttons.Length==0)
    return true;

    if (State==1 /*|| State==2 || State==3*/)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/)||(Key==0x01/*IK_LeftMouse*/))
	    {
            ButtonClick(Controller.FocusedControl);
            return true;
	    }
	    if (Key==0x08/*IK_Backspace*/)
	    {
	        if (CancelButton != none)
			      ButtonClick(CancelButton);
    	    return true;
	    }
	    if (Key==0x25/*IK_Left*/)
	    {
	        NextControl(FocusedControl);
    	    return true;
	    }
	    if (Key==0x27/*IK_Right*/)
	    {
	        PrevControl(FocusedControl);
    	    return true;
	    }
    }
    return Super.InternalOnKeyEvent(Key, State, delta);
}

function string Replace(string Src, string Tag, string Value)
{
local string retval;
local int p, tsz;

	Tag="%"$Tag$"%";
	tsz = Len(Tag);
	p = InStr(Src, Tag);
	while (p != -1)
	{
		retval = retval$Left(Src, p)$Value;
		Src=Mid(Src, p+tsz);
		p = InStr(Src, Tag);
	}
    return retval$Src;
}


