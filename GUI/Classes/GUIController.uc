// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIController extends BaseGUIController
		native;

var	editinline export	array<GUIPage>		MenuStack;			// Holds the stack of menus
var						GUIPage				ActivePage;			// Points to the currently active page
var editinline 			Array<GUIFont>		FontStack;			// Holds all the possible fonts
var 					Array<GUIStyles>	StyleStack;			// Holds all of the possible styles
var						Array<string>		StyleNames;			// Holds the name of all styles to use
var editinline 			Array<Material>		MouseCursors;		// Holds a list of all possible mouse
var editinline			Array<vector>		MouseCursorOffset;  // Only X,Y used, between 0 and 1. 'Hot Spot' of cursor material.
var transient			XIIIMenuData		myMenuData;

var                     bool                bContinueWithoutSaving; // true if the user hasn't selected/created a profile and still want to play; no save possible
var                     bool                bSavingPossible; // false means no media. Not redundant with previous one.
var                     bool                bLoadingPossible; // false means no media. Not redundant with previous one.
var                     bool                bProfileSelected; // true if the profile has been selected (in that case, the first menu is not XIIISelectProfile but XIIMenu

var						int					MouseX,MouseY;		// Where is the mouse currently located
var						int					LastMouseX, LastMouseY;
var						bool				ShiftPressed;		// Shift key is being held
var						bool				AltPressed;			// Alt key is being held
var						bool				CtrlPressed;		// Ctrl key is being held
var                     bool                CableDisconnected;

var						float				DblClickWindow;			// How long do you have for a double click
var						float				LastClickTime;			// When did the last click occur
var						int					LastClickX,LastClickY;	// Who was the active component

var						float				ButtonRepeatDelay;		// The amount of delay for faking button repeats
var						byte     			RepeatKey;				// Used to determine what should repeat
var						float				RepeatDelta; 			// Data var
var						float				RepeatTime;				// How long until the next repeat;
var						float				CursorFade;				// How visible is the cursor
var						int					CursorStep;				// Are we fading in or out

var						float				FastCursorFade;			// How visible is the cursor
var						int					FastCursorStep;			// Are we fading in or out

var						GUIComponent		FocusedControl;			// Top most Focused control
var						GUIComponent 		ActiveControl;			// Which control is currently active
var						GUIComponent		SkipControl;			// This control should be skipped over and drawn at the end
var						GUIComponent		MoveControl;			// Used for visual design

var						bool				bIgnoreNextRelease;				// Used to make sure discard errant releases.

var						bool				bHighlightCurrent;		// Highlight the current control being edited


var						bool				bCurMenuInitialized;	// Has the current Menu Finished initialization

var						string				GameResolution;
var config				float				MenuMouseSens;

var						bool				MainNotWanted;			// Set to true if you don't want main to appear.

// Sounds
var						sound				MouseOverSound;
var						sound				ClickSound;
var						sound				EditSound;
var						sound				UpSound;
var						sound				DownSound;

var						bool				bForceMouseCheck;		// HACK
var						bool				bIgnoreUntilPress;		// HACK

// no user input: time out management (to launch video...)
var const               bool                TimeOutArmed;                               // if true, the time out system is armed. When NoInputTimeOut() is called, the system is automatically disarmed. Use SetInputTimeOut() to re-arm it needed
var                     float               DelayOfInactivityBeforeCallingTimeOut;      // after this delay (in seconds), with no input from the user, the event NoInputTimeOut() is called
var const               float               TimeOfLastInput;                            // date when the last user input occurred


var	Material	DefaultPens[2]; 	// Contain to hold some default pens for drawing purposes


var VideoPlayer VP;   // Used to play videos
var(StartMap)  string    URL;

native event GUIFont GetMenuFont(string FontName); 	// Finds a given font in the FontStack
native event GUIStyles GetStyle(string StyleName); 	// Find a style on the stack
native function string GetCurrentRes();				// Returns the current res as a string
native function string GetMainMenuClass();			// Returns GameEngine.MainMenuClass

native function string InitController();			// init static classes

native function string GetXIIIEngineVersion();

native function ResetKeyboard();

// to reboot correctly on XBox, do nothing on other plateforms
native static final function RebootToDashboardFromScripts(int _iWhereToGo, int param1, int param2);


// To allow menu pages to have state code, call this function
native static final function InitStateFrame(Object object);

// Interface to the save game device
native static final function bool IsSavingMediaAvailable();

native static final function bool RequestCreateProfile(string UserName);
native static final function bool IsCreateProfileFinished(out int ReturnCode);

native static final function bool RequestUseProfile(string UserName);
native static final function bool IsUseProfileFinished(out int ReturnCode);

native static final function bool DoesMemoryCardIncludeThisProfile(out int ReturnCode);
native static final function bool StartNewCheckOnMemoryCardForThisProfile(out int ReturnCode, string UserName);

native static final function bool IsMemoryCardReady();					// Allows to waits for the OTE_Nothing state (in case something else is being processed)
native static final function bool HasMemoryCardBeenChanged();			// The engine HAS TO be the one who detects that. Not the menu *MUST BE CALLED ONLY ONCE BY FRAME* only in RootWindow !
native static final function bool SetMemoryCardActivation(int OnOff);	// The engine HAS TO be the one who detects that. Not the menu *MUST BE CALLED ONLY ONCE BY FRAME* only in RootWindow !


native static final function bool RequestGetProfileList();
native static final function bool IsGetProfileListFinished(out int ReturnCode, out array<string> Profile);

native static final function bool IsThereACheckpoint();
native static final function bool LoadAtCheckpoint(optional bool ForceLoadAtMapStart);      // default = false
native static final function GetDefaultDescription(out string Description);

native static final function int GetMaxNumberOfSavingSlots();

native static final function bool RequestIsSlotEmpty(int SlotNumber);
native static final function bool IsSlotEmptyFinished(out int ReturnCode, out INT IsEmpty);

native static final function bool RequestGetSlotContentDescription(int SlotNumber);
native static final function bool IsGetSlotContentDescriptionFinished(out int ReturnCode, out string Description);

native static final function bool RequestGetSlotContentDateAndTime(int SlotNumber);
native static final function bool IsGetSlotContentDateAndTimeFinished(out int ReturnCode, out int Year, out Byte Month, out Byte Day, out Byte Hour, out Byte Min );

native static final function bool RequestEraseSlot(int SlotNumber);
native static final function bool IsEraseSlotFinished(out int ReturnCode);

native static final function bool RequestReadSlot(int SlotNumber);
native static final function bool IsReadSlotFinished(out int ReturnCode);

native static final function bool RequestWriteSlot(int SlotNumber, optional string ContentDescription, optional bool bAtLastCheckpoint);
native static final function bool IsWriteSlotFinished(out int ReturnCode);

native static final function bool RequestReadUserConfig();
native static final function bool IsReadUserConfigFinished(out int ReturnCode);

native static final function bool RequestWriteUserConfig();
native static final function bool IsWriteUserConfigFinished(out int ReturnCode);


// To tell if we are leaving the press start menu page
native static final function bool EndOfPressStartPage();

// To arm/disarm the time out when user input is lacking. Also used to modify the delay.
native static final function SetInputTimeOut(bool Arm, optional float DelayBeforeTimeOut);



// To correctly handle the connection request to a distant server
native static final function int GetConnectionStatus(out string ErrorMsg);




delegate bool OnNeedRawKeyPress(byte NewKey);





// ================================================
// OpenMenuXXXXX - Opens a new menu and places it on the stack
// if bReplace == false, places it on top; if bReplace == true, replace the stack top element
function bool OpenMenu(string NewMenuName, optional bool bReplace, optional string Param1, optional string Param2)
{
	local int CorrectIdx, i;
    CorrectIdx = -1;

    // if in main menu, page is in main menu array
    // -> CAREFUL : if pages are in both, initialize them two times.
	if (myMenuData.bMainMenuLoaded)
	{
		for(i=0; i<myMenuData.XIIIMenuStackStrings.Length; i++)
		{
			if( myMenuData.XIIIMenuStackStrings[i] == NewMenuName )
			{
				CorrectIdx = i;
				break;
			}
		}
        if (CorrectIdx < 0)
        {
            log("MENU FAILURE menu page class not found : "@NewMenuName);
            return false;
        }
        else
		    return OpenMenuWithClass(myMenuData.XIIIMenuStack[CorrectIdx].ClassObj, bReplace, Param1, Param2);
	}
	else// always the case, ingame menu is not unloaded if (myMenuData.bIngameMenuLoaded)
	{
		for(i=0; i<myMenuData.XIIIIngameMenuStackStrings.Length; i++)
		{
			if( myMenuData.XIIIIngameMenuStackStrings[i] == NewMenuName )
			{
				CorrectIdx = i;
				break;
			}
		}
        if (CorrectIdx < 0)
        {
            log("MENU FAILURE menu page class not found : "@NewMenuName);
            return false;
        }
        else
    		return OpenMenuWithClass(myMenuData.XIIIIngameMenuStack[CorrectIdx].ClassObj, bReplace, Param1, Param2);
	}
}


function LoadMainMenu()
{
	myMenuData.LoadMainMenu();
}

function LoadIngameMenu()
{
	myMenuData = new(none)class'XIIIMenuData';
	myMenuData.LoadIngameMenu();
}

function bool OpenMenuWithClass(class<GUIPage> NewMenuClass, optional bool bReplace, optional string Param1, optional string Param2)
{
	local GUIPage NewMenu;

	NewMenu = new(None) NewMenuClass;
    InitStateFrame(NewMenu);
	return InternalMenuInit(NewMenu, bReplace, Param1, Param2);
}

function bool InternalMenuInit(GUIPage NewMenu, optional bool bReplace, optional string Param1, optional string Param2)
{
	local GUIPage CurMenu;
	bCurMenuInitialized=false;
	if (NewMenu!=None)
	{
		CurMenu = ActivePage;

		if (bReplace == false)
        {   // Add this menu to the top of the stack and give it focus
    		NewMenu.ParentPage = CurMenu;
		    MenuStack.Length = MenuStack.Length+1;
		    MenuStack[MenuStack.Length-1] = NewMenu;
        }
        else
        {   // replace the top element
		    NewMenu.ParentPage = CurMenu.ParentPage;
		    if (CurMenu==None)  MenuStack.Length = MenuStack.Length+1;
		    MenuStack[MenuStack.Length-1] = NewMenu;

		    NewMenu.MenuState = MSAT_Focused;
        }

        ActivePage = NewMenu;
		ResetFocus();

		// check for parameters first because creation could depend on parameter passed
		NewMenu.HandleParameters(Param1, Param2);

		// Initialize this Menu
		NewMenu.InitComponent(Self, none);

		// Remove focus from the last menu
		if (CurMenu!=None)
		{
			CurMenu.MenuState = MSAT_Blurry;
			CurMenu.OnDeActivate();
		}

		NewMenu.CheckResolution(false);
		NewMenu.OnOpen();	// Pass along the event
		NewMenu.MenuState = MSAT_Focused;
		NewMenu.OnActivate();
		NewMenu.PlayOpenSound();

		SetControllerStatus(true);
		bCurMenuInitialized=true;

		bForceMouseCheck = true;

		return true;
	}
	else
	{
		log("Could not create menu"@NewMenu);
		return false;
	}
}

event bool CloseMenu(optional bool bCanceled, optional string Param1, optional string Param2)	// Close the top menu.  returns true if success.
{
	local GUIPage CurMenu;
	local int 	  CurIndex;

	if (MenuStack.Length <= 0)
	{
		log("Attempting to close a non-existing menu page");
		return false;
	}

	CurIndex = MenuStack.Length-1;
	CurMenu = MenuStack[CurIndex];

	// Remove the menu from the stack
	MenuStack.Remove(MenuStack.Length-1,1);

	// Look for the resolution switch
	CurMenu.PlayCloseSound();		// Play the closing sound
	CurMenu.OnClose(bCanceled);

	CurMenu.MenuOwner=None;
	CurMenu.Controller=None;

	MoveControl = None;
	SkipControl = None;

	// Grab the next page on the stack
	bCurMenuInitialized=false;
	if (MenuStack.Length>0)	// Pass control back to the previous menu
	{
		ActivePage = MenuStack[MenuStack.Length-1];
		ActivePage.MenuState = MSAT_Focused;
		ActivePage.CheckResolution(true);

		// check for parameters first because creation could depend on parameter passed
		ActivePage.HandleParameters(Param1, Param2);

		ActivePage.OnReOpen();
		ActivePage.OnActivate();

		ActiveControl = none;

		ActivePage.FocusFirst(None,true);
	}
	else
	{
		if (!CurMenu.bAllowedAsLast)
		{
			return true;
		}

		FocusedControl = None;
		ActiveControl = None;
		SkipControl = None;
		MoveControl = None;

		ActivePage = None;
 		SetControllerStatus(false);
	}

	bCurMenuInitialized=true;
	bForceMouseCheck = true;
	return true;
}

function GUIPage TopPage()
{
	return ActivePage;
}

function SetControllerStatus(bool On)
{

	bActive = On;
	bVisible = On;
	bRequiresTick=On;

	// Attempt to Pause as well as show the windows mouse cursor.
	ViewportOwner.bShowWindowsMouse=On;

	// Add code to pause/unpause/hide/etc the game here.
	if (On)
		bIgnoreUntilPress = true;
	else
		ViewportOwner.Actor.ConsoleCommand("toggleime 0");
}


event CloseAll(bool bCancel)
{
	local int i;
	// Close the current menu manually before we clean up the stack.
	if( MenuStack.Length >= 0 )
	{
		if ( !CloseMenu(bCancel) )
			return;
	}

	for (i=0;i<MenuStack.Length;i++)
	{
		MenuStack[i].CheckResolution(true);
		MenuStack[i].Controller = None;
		MenuStack[i] = None;
	}

	if (GameResolution!="")
	{
		ViewportOwner.Actor.ConsoleCommand("SETRES"@GameResolution);
		GameResolution="";
	}

	myMenuData.UnLoadMainMenu();
	// never unload ingame menu

    FocusedControl = None;
	ActiveControl = None;
	SkipControl = None;
	MoveControl = None;
	ActivePage = None;
	MenuStack.Remove(0,MenuStack.Length);
	SetControllerStatus(false);
}

event InitializeController()
{
	local int i;
	local class<GUIStyles> NewStyleClass;

	for (i=0;i<StyleNames.Length;i++)
	{
		NewStyleClass = class<GUIStyles>(DynamicLoadObject(StyleNames[i],class'class'));
		if (NewStyleClass != None)
			if (!RegisterStyle(NewStyleClass))
				log("Could not create requested style"@StyleNames[i]);

	}
    // initialise menu array and load the ingame one
	LoadIngameMenu();

    // Arm and init the time out system if necessary
    if (TimeOutArmed)
    {
        SetInputTimeOut(TimeOutArmed);
    }
    bContinueWithoutSaving=false;
    bProfileSelected=false;
    bSavingPossible=false;
}

function bool RegisterStyle(class<GUIStyles> StyleClass)
{
	local GUIStyles NewStyle;

	if (StyleClass != None && !StyleClass.default.bRegistered)
	{
		NewStyle = new(None) StyleClass;

		// Check for errors
		if (NewStyle != None)
		{
			// Dynamic Array Auto Sizes StyleStack.
			StyleStack[StyleStack.Length] = NewStyle;
			NewStyle.Controller = self;
			NewStyle.Initialize();
			return true;
		}
	}
	return false;
}

event ChangeFocus(GUIComponent Who)
{
	return;
}

function ResetFocus()
{

	if (ActiveControl!=None)
	{
		ActiveControl.MenuStateChange(MSAT_Blurry);
		ActiveControl=None;
	}

	RepeatKey=0;
	RepeatTime=0;

}

event MoveFocused(GUIComponent Ctrl, int bmLeft, int bmTop, int bmWidth, int bmHeight, float ClipX, float ClipY)
{
	local float val;


	if (AltPressed)
		val = 5;
	else
		val = 1;

	if (bmLeft!=0)
	{
		if (Ctrl.WinLeft<1)
			Ctrl.WinLeft = Ctrl.WinLeft + ( (Val/ClipX) * bmLeft);
		else
			Ctrl.WinLeft += (Val*bmLeft);
	}

	if (bmTop!=0)
	{
		if (Ctrl.WinTop<1)
			Ctrl.WinTop = Ctrl.WinTop + ( (Val/ClipY) * bmTop);
		else
			Ctrl.WinTop+= (Val*bmTop);
	}

	if (bmWidth!=0)
	{
		if (Ctrl.WinWidth<1)
			Ctrl.WinWidth = Ctrl.WinWidth + ( (Val/ClipX) * bmWidth);
		else
			Ctrl.WinWidth += (Val*bmWidth);
	}

	if (bmHeight!=0)
	{
		if (Ctrl.WinHeight<1)
			Ctrl.WinHeight = Ctrl.WinHeight + ( (Val/ClipX) * bmHeight);
		else
			Ctrl.WinHeight += (Val*bmHeight);
	}
}

function bool HasMouseMoved()
{
	if (MouseX==LastMouseX && MouseY==LastMouseY)
		return false;
	else
		return true;
}

event bool NeedsMenuResolution()
{
	if ( (ActivePage!=None) && (ActivePage.bRequire640x480) )
		return true;
	else
		return false;
}

event SetRequiredGameResolution(string GameRes)
{
	GameResolution = GameRes;
}


// This event is called when the user didn't create any input for a delay longer than DelayOfInactivityBeforeCallingTimeOut.
//event NoInputTimeOut();
event NoInputTimeOut()
{
	local int myPF;
	//myPF = int(XIIIGameInfo(ViewportOwner.Actor.Level.Game).PlateForme);

//log("POUR iNFO myPF ="@myPF$", ActivePage ="@ActivePage);

	if (myPF == 1 && ActivePage.IsA('XIIIMenuPressStart') )
	{
	//log("Time out PSX2 !!!!!");
        VP = new class'VideoPlayer';
        if ( VP != none )
         {
          log("video launched");
          VP.Open("trailer");
          VP.play();
          URL="mapmenu";
		  //GetPlayerOwner().ConsoleCommand("QUIT 5"); // quit 5
          //GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
        closeall(true);
        ViewportOwner.Actor.ClientTravel(URL, TRAVEL_Absolute, false);
	gotostate('');
	//return true;
         }
	}
	//ViewportOwner.Actor.ConsoleCommand("SCE_DEMO_ENDREASON_PLAYABLE_INACTIVITY_TIMEOUT"); // quit 1

}




defaultproperties
{
     FontStack(0)=GUISmallFont'GUI.GUIController.GUI_SmallFont'
     FontStack(1)=GUIBigFont'GUI.GUIController.GUI_BigFont'
     StyleNames(0)="GUI.STY_SquareButton"
     StyleNames(1)="GUI.STY_Listbox"
     StyleNames(2)="GUI.STY_NoAlphaButton"
     StyleNames(3)="GUI.STY_ScaleButton"
     StyleNames(4)="GUI.STY_Label"
     StyleNames(5)="GUI.STY_LabelWhite"
     StyleNames(6)="GUI.STY_MsgBoxButton"
     MouseCursors(0)=Texture'XIIIMenuStart.MouseCursorM'
     DblClickWindow=0.500000
     ButtonRepeatDelay=0.350000
     CursorStep=1
     FastCursorStep=1
     bHighlightCurrent=True
     MenuMouseSens=1.000000
     TimeOutArmed=True
     DelayOfInactivityBeforeCallingTimeOut=60.000000
     DefaultPens(0)=Texture'XIIIMenuStart.menublanc'
     DefaultPens(1)=Texture'XIIIMenuStart.menunoir'
}
