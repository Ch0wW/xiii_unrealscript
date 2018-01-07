// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIButton extends GUIComponent
		Native;

		
var		localized	string			Caption;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	OnKeyEvent=InternalOnKeyEvent;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if (key==0x0D && State==3)	// ENTER Pressed
	{
		OnClick(self);
		return true;
	}
	
	if (key==0x26 && (State==1 || State==2))
	{
		PrevControl(none);
		return true;
	}
			
	if (key==0x28 && (State==1 || State==2))
	{
		NextControl(none);
		return true;
	}
	
	return false;
}



event ButtonPressed();		// Called when the button is pressed;
event ButtonReleased();		// Called when the button is released;



defaultproperties
{
     bAcceptsInput=True
     bCaptureMouse=True
     WinHeight=0.040000
     bTabStop=True
     bFocusOnWatch=True
     bMouseOverSound=True
     OnClickSound=GUI_CS_Click
}
