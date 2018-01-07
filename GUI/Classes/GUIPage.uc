// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIPage extends GUIMultiComponent
	Native 	Abstract;


// Variables

var(Menu)   					Material				Background;			// The background image for the menu
var(Menu)						Color					BackgroundColor;	// The color of the background
var(Menu)						Color					InactiveFadeColor;	// Color Modulation for Inactive Page
var(Menu)						EMenuRenderStyle		BackgroundRStyle;
var(Menu)						bool					bRenderWorld;		// Should this menu hide the world
var(Menu)						bool					bPauseIfPossible;	// Should this menu pause the game if possible
var(Menu)						bool					bCheckResolution;	// If true, the menu will be force to run at least 640x480
var(Menu)						Sound					OpenSound;			// Sound to play when opened
var(Menu)						Sound					CloseSound;			// Sound to play when closed


var								bool					bRequire640x480;	// Does this menu require at least 640x480
// NL static load var								bool					bPersistent;		// If set in defprops, page is saved across open/close/reopen.

var								GUIPage					ParentPage;			// The page that exists before this one
var	const						array<GUIComponent>		Timers;				// List of components with Active Timers
var 							bool					bAllowedAsLast;		// If this is true, closing this page will not bring up the main menu

var                             bool                    bHidePreviousPage;  // if true, the previous pages in the stack won't be rendered
var                             bool                    bDoStoreInSaveMenuStack;  // if true, the page will be saved in the menu stack created when a map is loaded from the menu
var                             bool                    bNeedRawKey;		//
var const float LatentFloat;


// Latent functions.
native(430) final latent function Sleep( float Seconds );


// if last on the stack.
// Delegates

delegate OnOpen()
{
	PageLoadINI();
}

delegate OnReOpen()
{
}

delegate bool OnCanClose(optional Bool bCanceled)
{
	return true;
}

delegate OnClose(optional Bool bCanceled)
{
	if (!bCanceled)
		PageSaveINI();
}

function PageLoadINI()
{
	local int i;

	for (i=0;i<Controls.Length;i++)
		Controls[i].LoadINI();

	return;
}

function PageSaveINI()
{
	local int i;

	for (i=0;i<Controls.Length;i++)
		Controls[i].SaveINI("");
}

//=================================================
// PlayOpenSound / PlayerClosedSound

function PlayOpenSound()
{
	//PlayerOwner().PlayOwnedSound(OpenSound,SLOT_Interface,1.0);
}

function PlayCloseSound()
{
	//PlayerOwner().PlayOwnedSound(CloseSound,SLOT_Interface,1.0);
}


//=================================================
// InitComponent is responsible for initializing all components on the page.

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	FocusFirst(None,true);
}

//=================================================
// CheckResolution - Tests to see if this menu requires a resoltuion of at least 640x480 and if so, switches

function CheckResolution(bool Closing)
{
	local string CurrentRes;
	local int I,X,Y;

	if (!Closing)
	{
		CurrentRes = PlayerOwner().ConsoleCommand( "GETCURRENTRES" );
	    I = InStr( CurrentRes, "x" );
	    if( i > 0 )
	    {
			X = int( Left ( CurrentRes, i )  );
			Y = int( Mid( CurrentRes, i+1 ) );
	    }
		else
		{
			log("Couldn't parse GetCurrentRes call");
			return;
		}
		if ( ( (x<640) || (y<480) ) && (bRequire640x480) )
		{
			log("GUIPage::CheckResolution Setting GameResolution to"@CurrentRes);
			Controller.GameResolution = CurrentRes;
			PlayerOwner().ConsoleCommand("TEMPSETRES 640x480");
		}

		return;

	}

	if ( (bRequire640x480) || (Controller.GameResolution=="") )
		return;

	CurrentRes = PlayerOwner().ConsoleCommand( "GETCURRENTRES" );
	if (CurrentRes != Controller.GameResolution)
	{
		log("GUIPage::CheckResolution switching to"@CurrentRes);
		PlayerOwner().Player.Console.ConsoleCommand("SETRES"@Controller.GameResolution);
		Controller.GameResolution = "";
	}

}

event Tick( float DeltaTime );      // One page is ticked at once: the active one

event ChangeHint(string NewHint)
{
	Hint = NewHint;
}

event MenuStateChange(eMenuState Newstate)
{
	Super(GUIComponent).MenuStateChange(NewState);	// Skip the Multicomp's state change
}

event SetFocus(GUIComponent Who)
{
	if (Who==None)
		return;

	Super.SetFocus(Who);
}

event HandleParameters(string Param1, string Param2);	// Should be subclassed


// if subclassed, this parent function must always be called first
function string GetPageParameters()
{
    return string(Class);
}

// if GetPageParameters() is subclassed, you'd better have this one too !
function SetPageParameters(string PageParameters)
{
    log("SetPageParameters("$PageParameters$") called for "$self);
}




defaultproperties
{
     BackgroundColor=(B=255,G=255,R=255,A=255)
     InactiveFadeColor=(B=128,G=128,R=128,A=255)
     BackgroundRStyle=MSTY_Normal
     bRequire640x480=True
     bHidePreviousPage=True
     bDoStoreInSaveMenuStack=True
     bAcceptsInput=True
}
