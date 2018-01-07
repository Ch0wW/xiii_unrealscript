// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUISlider extends GUIComponent
		Native;

		
var(Menu)	float 		MinValue, MaxValue;
var(Menu)	string		CaptionStyleName;
var			float		Value;
var			GUIStyles	CaptionStyle;
var			bool		bIntSlider;

delegate string OnDrawCaption()
{
	if (bIntSlider)
		return "("$int(Value)$")";
	else
		return "("$Value$")";
}

function SetValue(float NewValue)
{
	if (NewValue<MinValue) NewValue=MinValue;
	if (NewValue>MaxValue) NewValue=MaxValue;
	
	if (bIntSlider)
		Value = int(NewValue);
	else
		Value = NewValue;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	OnCapturedMouseMove=InternalCapturedMouseMove;
	OnKeyEvent=InternalOnKeyEvent;
	OnClick=InternalOnClick;
	OnMousePressed=InternalOnMousePressed;
	
	CaptionStyle = Controller.GetStyle(CaptionStyleName);	
}


function bool InternalCapturedMouseMove(float deltaX, float deltaY)
{
	local float Perc, OldValue;
	
	OldValue = Value;
	
	if ( (Controller.MouseX >= Bounds[0]) && (Controller.MouseX<=Bounds[2]) )
	{
		Perc = ( float(Controller.MouseX) - ActualLeft()) / ActualWidth();
		Perc = FClamp(Perc,0.0,1.0); 
		Value = ( (MaxValue - MinValue) * Perc) + MinValue;
	}
	else if (Controller.MouseX < Bounds[0])
		Value = MinValue;
	else if (Controller.MouseX > Bounds[2])
		Value = MaxValue;

	Value = FClamp(Value,MinValue,MaxValue);
	
	return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ( (Key==0x25 || Key==0x64) && (State==1) )	// Left
	{
		Adjust(-0.01);	
		return true;
	}
	
	if ( (Key==0x27 || Key==0x66) && (State==1) ) // Right
	{
		Adjust(0.01);
		return true;
	}
	
	
	return false;
}

function Adjust(float amount)
{
	local float Perc;
	Perc = (Value-MinValue) / (MaxValue-MinValue);
	Perc += amount;  
	Perc = FClamp(Perc,0.0,1.0); 
	Value = ( (MaxValue - MinValue) * Perc) + MinValue;
	FClamp(Value,MinValue, MaxValue);
	OnChange(self);
}

function string LoadINI()
{	local string s;
	
	s = Super.LoadINI();
	if (s!="")
		Value = float(s);
			
	return s;
}

function SaveINI(string V)
{
	Super.SaveINI(""$V);
}

function bool InternalOnClick(GUIComponent Sender)
{
	OnChange(self);
	return true;
}

function InternalOnMousePressed(GUIComponent Sender,bool RepeatClick)
{
	InternalCapturedMouseMove(0,0);
}



defaultproperties
{
     bAcceptsInput=True
     bCaptureMouse=True
     bRequireReleaseClick=True
     WinHeight=0.030000
     bTabStop=True
     OnClickSound=GUI_CS_Click
}
