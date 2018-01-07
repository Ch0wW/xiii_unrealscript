//===========================================================================
class XIIIHSliderControl extends XIIIGUIBaseButton;

var float Value, MinValue, MaxValue, Step, SliderPosX, SliderWidth, GlobalSliderX;
var float TextX, TextY, CanvasClipX;
var bool bShowBordersOnlyWhenFocused;
var texture tArrowL, tArrowR;
var Color NotchColor, CursorColor;
var int NbMultiSplit;
VAR float CanvasOrgX;

//===========================================================================
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
    OnKeyEvent = InternalOnKeyEvent;
	TextAlign = TXTA_Center;
}


function SetValue(float NewValue)
{
	NewValue = fClamp(NewValue,MinValue,MaxValue);
	Value = NewValue;
}


function float GetValue()
{
	return Value;
}


function SetRange(float Min, float Max, float NewStep, optional float newSlidePos)
{
	MinValue = Min;
	MaxValue = Max;
	Step = NewStep;
	SliderPosX = NewSlidePos;
}


function BeforePaint(Canvas C, float X, float Y)
{
    local float W, H;

	SliderWidth = WinWidth*640 - SliderPosX;
	C.TextSize( Text, W, H);
	TextX = (SliderPosX*fRatioX-6-W)*0.5; //*fRatioX;
	TextY = (WinHeight*480*fRatioY - H)/2;
}

FUNCTION MyDrawLine( Canvas C, float X1, float Y1, float X2, float Y2, Color col )
{
	X1 += C.OrgX;
	X2 += C.OrgX;
	Y1 += C.OrgY;
	Y2 += C.OrgY;

	C.DrawLine( X1, Y1, X2, Y2, col );
}

function Paint(Canvas C, float X, float Y)
{
	LOCAL float CursorWidth, PosCursorX, PosCursorY, tmpX;
	LOCAL int i;

	Super.Paint(C, X, Y);

	CanvasClipX = C.ClipX;
	CanvasOrgX = C.OrgX;

	C.Font = font'XIIIFonts.PoliceF16';
	GlobalSliderX = C.OrgX+SliderPosX*fRatioX;

	// text box and slider display
	if (bHasFocus)
		BackColor.A = 255;
	else
		BackColor.A = 128;
	C.DrawColor = BackColor;
	C.bUseBorder = !bShowBordersOnlyWhenFocused || bHasFocus;
	DrawStretchedTexture(C, 0, 0, (SliderPosX-6)*fRatioX, WinHeight*480*fRatioY, myRoot.FondMenu);
	BackColor.A = 255;
	C.DrawColor = BackColor;
	C.bUseBorder = false;

    DrawStretchedTexture(C, (SliderPosX)*fRatioX-1, 40*WinHeight*fRatioY, 16*fRatioX, WinHeight*400*fRatioY, tArrowL);
	C.bUseBorder = true;
    DrawStretchedTexture(C, (SliderPosX+13)*fRatioX, 40*WinHeight*fRatioY, (SliderWidth-30)*fRatioX, WinHeight*400*fRatioY, myRoot.FondMenu);
	C.bUseBorder = false;
    DrawStretchedTexture(C, (SliderPosX+SliderWidth-12)*fRatioX+1, 40*WinHeight*fRatioY, 16*fRatioX, WinHeight*400*fRatioY, tArrowR);

	// text display
	C.DrawColor = TextColor;
	C.Style = 5;
	C.DrawColor.A = 255;
	C.Style = 1;
	C.SetPos(TextX,TextY);
	C.DrawText(/*Caps*/(Text), false);
	C.DrawColor = BackColor;
	
	CursorWidth = 6*fMin(1,fRatioX);
	PosCursorY = (WinHeight*90)*fRatioY;

	MyDrawLine( C, (SliderPosX+13+CursorWidth*0.5)*fRatioX, 240*WinHeight*fRatioY, (SliderPosX+13+SliderWidth-30-CursorWidth*0.5)*fRatioX, 240*WinHeight*fRatioY, NotchColor );

	for ( i=MinValue; i<=MaxValue; i+=Step )
	{
		tmpX = SliderPosX+13+(i-MinValue)*(SliderWidth-30-CursorWidth) / (MaxValue - MinValue)+CursorWidth*0.5;
		
		MyDrawLine( C, tmpX*fRatioX, 160*WinHeight*fRatioY, tmpX*fRatioX, 320*WinHeight*fRatioY, NotchColor );
	}
	// cursor display
	PosCursorX = (SliderPosX+13)*fRatioX + ((SliderWidth-30)*fRatioX-CursorWidth)*( (Value - MinValue) / (MaxValue - MinValue) );
//        DrawStretchedTexture(C, PosCursorX*fRatioX, PosCursorY, CursorWidth, 20*fRatioY, tCursor);        
	C.bUseBorder = true;
	C.DrawColor = CursorColor;
    DrawStretchedTexture(C, PosCursorX, PosCursorY, CursorWidth, WinHeight*300*fRatioY, myRoot.FondMenu);
	C.DrawColor = C.MakeColor(255,255,255,255);
	C.bUseBorder = false;
}


function bool InternalCapturedMouseMove(float deltaX, float deltaY)
{
	LOCAL float Perc, OldValue, RelativeX;

	RelativeX = ((Controller.MouseX-CanvasOrgX)/fRatioX-SliderPosX-13)/(SliderWidth-30);

	OldValue = Value;
	if ( RelativeX < 0)
            Adjust(-Step);
	else if (RelativeX > 1)
            Adjust(Step);
	else 
		Value = (step*int((RelativeX*(MaxValue - MinValue)+0.5*step)/step))+MinValue;

	Value = FClamp(Value,MinValue,MaxValue);
	if ( Value!=OldValue )
		OnChange( self );

	return true;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ((Key == 0x01) && ( State==1 ))  
		InternalCapturedMouseMove(0,0);


	if ( (Key==0x25 /*|| Key==0x64 || Key==0xEC*/) && ((State==1) || (State==2)))	// Left
	{
		Adjust(-Step);
	}

	if ( (Key==0x27 /*|| Key==0x66 || Key==0xED*/) && ((State==1) || (State==2))) // Right
	{
		Adjust(Step);
	}
        
	return false;
}

function Adjust(float amount)
{
	Value = fClamp(Value+Amount,MinValue,MaxValue);
}



defaultproperties
{
     tArrowL=Texture'XIIIMenuStart.Control_Console.fleche_gauche'
     tArrowR=Texture'XIIIMenuStart.Control_Console.fleche_droite'
     NotchColor=(B=64,G=64,R=64,A=255)
     CursorColor=(B=224,G=224,R=224,A=255)
     bRequireReleaseClick=True
}
