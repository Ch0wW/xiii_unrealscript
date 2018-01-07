// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIComponent extends GUI
		Native;


// Variables

var		GUIComponent 		MenuOwner;				// Callback to the Component that owns this one
var		eMenuState		MenuState;					// Used to determine the current state of this component

// RenderStyle and MenuColor are usually pulled from the Parent menu, unless specificlly overridden

var(Menu)	string			IniOption;					// Points to the INI option to load for this component
var(Menu)	string			IniDefault;					// The default value for a missing ini option
var(Menu)	string			StyleName;					// Name of my Style
var(Menu)	bool			bBoundToParent;				// Use the Parents Bounds for all positioning
var(Menu)	bool			bScaleToParent;				// Use the Parent for scaling
var(Menu)	bool			bHasFocus;					// Does this component currently have input focus
var(Menu)	bool			bVisible;					// Is this component currently visible
var(Menu)	bool			bAcceptsInput;				// Does this control accept input
var(Menu)	bool			bCaptureTabs;				// This control wants tabs
var(Menu)	bool			bCaptureMouse;				// Set this if the control should capture the mouse when pressed
var(Menu)	bool			bNeverFocus;				// This control should never fully receive focus
var(Menu)	bool			bRepeatClick;				// Have the system accept holding down of the mouse
var(Menu)	bool			bRequireReleaseClick;		// If True, this component wants the click on release even if it's not active
var(Menu)	GUIComponent	FocusInstead;				// Who should get the focus instead of this control if bNeverFocus
var(Menu)	localized string			Hint;						// The hint that gets displayed for this component
var(Menu)	float			WinTop,WinLeft;				// Where does this component exist (in world space) - Grr.. damn Left()
var(Menu)	float			WinWidth,WinHeight;			// Where does this component exist (in world space) - Grr.. damn Left()
var(Menu)	int				MouseCursorIndex;			// The mouse cursor to use when over this control
var(Menu)	bool			bTabStop;					// Does a TAB/Shift-Tab stop here
var(Menu)	bool			bFocusOnWatch;				// If true, watching focuses
var(Menu)	int				Tag;						// Not used.
var(Menu)	GUILabel		FriendlyLabel;				// My state is projected on this objects state.

var(Menu)	bool			bMouseOverSound;			// Should component bleep when mouse goes over it
var(Menu)	enum			EClickSound
{
	GUI_CS_None,
	GUI_CS_Click,
	GUI_CS_Edit,
	GUI_CS_Up,
	GUI_CS_Down
} OnClickSound;

// Style holds a pointer to the GUI style of this component.

var			GUIStyles		 Style;						// My GUI Style

// Notes about the Top/Left/Width/Height : This is a somewhat hack but it's really good for functionality.  If
// the value is <=1, then the control is considered to be scaled.  If they are >1 they are considered to be normal world coords.
// 0 = 0, 1 = 100%

var			float		Bounds[4];								// Internal normalized positions in world space
var			float		ClientBounds[4];						// The bounds of the actual client area (minus any borders)

var			bool		bPendingFocus;							// Big big hack for ComboBoxes..

// Timer Support
var const	int			TimerIndex;			// For easier maintenance
var			bool		bTimerRepeat;
var			float		TimerCountdown;
var			float		TimerInterval;

// Used for Saving the last state before drawing natively

var		float 	SaveX,SaveY;
var 	color	SaveColor;
var		font	SaveFont;
var		byte	SaveStyle;

// Delegates

// Drawing delegates return true if you want to short-circuit the default drawing code

Delegate bool OnPreDraw(Canvas Canvas);
Delegate bool OnDraw(Canvas Canvas);

Delegate OnActivate();													// Called when the component gains focus
Delegate OnDeActivate();												// Called when the component loses focus
Delegate OnWatch();														// Called when the component is being watched
Delegate OnHitTest(float MouseX, float MouseY);							// Called when Hit test is performed for mouse input
Delegate OnRender(canvas Canvas);										// Called when the component is rendered
Delegate OnMessage(coerce string Msg, float MsgLife); 					// When a message comes down the line

Delegate OnInvalidate();	// Called when the background is clicked

// -- Input event delegates

Delegate bool OnClick(GUIComponent Sender);			// The mouse was clicked on this control
Delegate bool OnDblClick(GUIComponent Sender);		// The mouse was double-clicked on this control
Delegate bool OnRightClick(GUIComponent Sender);	// Control was right clicked.

Delegate OnMousePressed(GUIComponent Sender, bool bRepeat);		// Sent when a mouse is pressed (initially)
Delegate OnMouseRelease(GUIComponent Sender);		// Sent when the mouse is released.

Delegate OnChange(GUIComponent Sender);	// Called when a component changes it's value

Delegate bool OnKeyType(out byte Key)  	// Key Strokes
{
	return false;
}

Delegate bool OnKeyEvent(out byte Key, out byte State, float delta)
{
	return false;
}

Delegate bool OnCapturedMouseMove(float deltaX, float deltaY)
{
	return false;
}

Delegate OnLoadINI(GUIComponent Sender, string s);		// Do the actual work here
Delegate string OnSaveINI(GUIComponent Sender); 		// Do the actual work here

function PlayerController PlayerOwner()
{
	return Controller.ViewportOwner.Actor;
}


event Timer();		// Should be subclassed

function native final SetTimer(float Interval, optional bool bRepeat);
function native final KillTimer();

function string LoadINI()
{
	local string s;

	if ( (PlayerOwner()==None) || (INIOption=="") )
		return "";

	if(!(INIOption~="@INTERNAL"))
		s = PlayerOwner().ConsoleCommand("get"@IniOption);

	if (s=="")
		s = IniDefault;

	OnLoadINI(Self,s);

	return s;
}

function SaveINI(string Value)
{
	local string s;

	if (INIOption=="")
		return;

	if (PlayerOwner()==None)
		return;

	s = OnSaveINI(Self);
	if ( s!="" )
	{
	}
}

function string ParseOption(string URL, string Key, string DefaultVal)
{
	local string s;

	if (PlayerOwner()==None)
		return DefaultVal;

	s = PlayerOwner().Level.Game.ParseOption( URL, Key);
	if (s=="")
		return DefaultVal;
	else
		return s;
}



// Functions

event MenuStateChange(eMenuState Newstate)
{

	// Check for never focus

	bPendingFocus=false;

	if (NewState==MSAT_Focused && bNeverFocus)
		NewState = MSAT_Blurry;

	MenuState = NewState;

	switch (MenuState)
	{
		case MSAT_Blurry:
			bHasFocus = false;
			OnDeActivate();
			break;

		case MSAT_Watched:

			if (bFocusOnWatch)
			{
				SetFocus(None);
				return;
			}

			OnWatch();
			break;

		case MSAT_Focused:
			bHasFocus = true;
			OnActivate();
			break;

	}

	if (FriendlyLabel!=None)
		FriendlyLabel.MenuState=MenuState;

}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	Controller = MyController;
	MenuOwner = MyOwner;

	Style = Controller.GetStyle(StyleName);
}

function bool IsInBounds()	// Script version of PerformHitTest
{
	return ( (Controller.MouseX >= Bounds[0] && Controller.MouseX<=Bounds[2]) && (Controller.MouseY >= Bounds[1] && Controller.MouseY <=Bounds[3]) );
}

function bool IsInClientBounds()
{
	return ( (Controller.MouseX >= ClientBounds[0] && Controller.MouseX<=ClientBounds[2]) && (Controller.MouseY >= ClientBounds[1] && Controller.MouseY <=ClientBounds[3]) );
}

event SetFocus(GUIComponent Who)
{

	if (MenuState==MSAT_Focused)
		return;

	if (bNeverFocus)
	{
		if (FocusInstead != None)
			FocusInstead.SetFocus(Who);

		return;
	}

	bPendingFocus = true;

	if (Controller.FocusedControl!=None)
		Controller.FocusedControl.LoseFocus(None);

	Controller.FocusedControl = self;

	MenuStateChange(MSAT_Focused);
	if (MenuOwner!=None)
		MenuOwner.SetFocus(self);
}

event LoseFocus(GUIComponent Sender)
{
	if (Controller!=None)
		Controller.FocusedControl = None;
	//else
	//	log("GUIComponent::LoseFocus - Control==None");

	MenuStateChange(MSAT_Blurry);

	if (MenuOwner!=None)
		MenuOwner.LoseFocus(Self);
}

event bool FocusFirst(GUIComponent Sender, bool bIgnoreMultiTabStops)	// Focus your first child, or yourself if no childrean
{
	if ( (!bVisible) || (bNeverFocus) || (MenuState==MSAT_Disabled) || (!bTabStop) )
		return false;

	SetFocus(None);
	return true;
}

event bool FocusLast(GUIComponent Sender, bool bIgnoreMultiTabStops) // Focus your last child, or yourself
{
	if ( (!bVisible) || (bNeverFocus) || (MenuState==MSAT_Disabled) || (!bTabStop) )
		return false;

	SetFocus(None);
	return true;
}

event bool NextControl(GUIComponent Sender)
{
	if (MenuOwner!=None)
		return MenuOwner.NextControl(Self);

	return false;
}

event bool PrevControl(GUIComponent Sender)
{
	if (MenuOwner!=None)
		return MenuOwner.PrevControl(Self);

	return false;
}

event bool NextPage()
{
	if (MenuOwner != None)
		return MenuOwner.NextPage();

	return false;
}

event bool PrevPage()
{
	if (MenuOwner != None)
		return MenuOwner.PrevPage();

	return false;
}

// Force control to use same area as its MenuOwner.
function FillOwner()
{
	WinLeft = 0.0;
	WinTop = 0.0;
	WinWidth = 1.0;
	WinHeight = 1.0;
	bScaleToParent = true;
	bBoundToParent = true;
}

// The ActualXXXX functions are not viable until after the first render so don't
// use them in inits
native function float ActualWidth();
native function float ActualHeight();
native function float ActualLeft();
native function Float ActualTop();



defaultproperties
{
     bVisible=True
     WinWidth=1.000000
     Tag=-1
     TimerIndex=-1
}
