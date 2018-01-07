// ====================================================================
//  Class:  Engine.InteractionMaster
//
//  The InteractionMaster controls the entire interaction system.  It's
//  job is to take input and Pre/PostRender call and route them to individual
//  Interactions and/or viewports.
//
// 	The stubs here in script are for just the GlobalInteracations as those
// 	are the only Interactions the IM routes directly too.  A new stub is
// 	created in order to limit the number of C++ -> Uscript switches.
//
// (c) 2001, Epic Games, Inc.  All Rights Reserved 
// ====================================================================

class InteractionMaster extends Interactions
	    transient
		Native;

var transient Client CLient;

var transient const Interaction BaseMenu;	// Holds a pointer to the base menu system 
var transient const Interaction Console;	// Holds the special Interaction that acts as the console
var transient array<Interaction> GlobalInteractions;	// Holds a listing of all global Interactions


// Global time out system: whether in menu or game, if there is no user input for too long, a time out is launched (event InputTimeOut() is called)
var bool GlobalTimeOutArmed;                               // if true, the global time out system is used
var float DelayOfGlobalInputInactivityBeforeTimeOut;       // after this delay (in seconds), with no input from the user, the time out will be launched
var const float TimeOfLastInput;

native function Travel(string URL);	// Setup a travel to a new map

// ====================================================================
// Control functions
// ====================================================================

event Interaction AddInteraction(string InteractionName, optional Player AttachTo) 	// Adds an Interaction
{
	local Interaction NewInteraction;
	local class<Interaction> NewInteractionClass;
	
	NewInteractionClass = class<Interaction>(DynamicLoadObject(InteractionName, class'Class'));
	
	if (NewInteractionClass!=None)
	{
		NewInteraction = new NewInteractionClass;
		if (NewInteraction != None)
		{
			
			// Place the Interaction in the proper array
	
			if (AttachTo != None)	// Handle location Interactions
			{
				AttachTo.LocalInteractions.Length = AttachTo.LocalInteractions.Length + 1;
				AttachTo.LocalInteractions[AttachTo.LocalInteractions.Length-1] = NewInteraction;
				NewInteraction.ViewportOwner = AttachTo;
			}
			else	// Handle Global Interactions
			{
				GlobalInteractions.Length = GlobalInteractions.Length + 1;
				GlobalInteractions[GlobalInteractions.Length-1] = NewInteraction;
			}

			// Initialize the Interaction
			
			NewInteraction.Initialize();
			NewInteraction.Master = Self;

			return NewInteraction;
			
		}
		else
  			Log("Could not create interaction ["$InteractionName$"]",'IMaster');
			
	}
	else
		Log("Could not load interaction ["$InteractionName$"]",'IMaster');

	return none;	 	
	
} // AddInteraction

event RemoveInteraction(interaction RemoveMe)			// Removes a Interaction
{
	local int Index;


	if (RemoveMe.ViewportOwner != None)
	{
		for (Index = 0; Index < RemoveMe.ViewPortOwner.LocalInteractions.Length; Index++)
		{
			if ( RemoveMe.ViewPortOwner.LocalInteractions[Index] == RemoveMe )
			{
				RemoveMe.ViewPortOwner.LocalInteractions.Remove(Index,1);
				return;
			}
		}
	}
	else
	{
		for (Index = 0; Index < GlobalInteractions.Length; Index++)
		{
			if ( GlobalInteractions[Index] == RemoveMe )
			{
				GlobalInteractions.Remove(Index,1);
				return;
			}
		}
	}
	
	Log("Could not remove interaction ["$RemoveMe$"] (Not Found)", 'IMaster');

} // RemoveInteraction			
  	
// ====================================================================
// SetFocusTo - This function will cause a window to adjust it's position
// in it's array so that it processes input first and displays last.
// ====================================================================

event SetFocusTo(Interaction Inter, optional Player ViewportOwner)
{
	local array<Interaction> InteractionArray;
	local Interaction temp;
	local int i,iIndex;
	
	
	if (ViewportOwner != none)
		InteractionArray = ViewportOwner.LocalInteractions;
	else
		InteractionArray = GlobalInteractions;
		
	if (InteractionArray.Length == 0)
	{
		Log("Attempt to SetFocus on an empty Array.",'IMaster');
		return;
	}
	
	// Search for the Interaction

	iIndex = -1;
	for ( i=0; i<InteractionArray.Length; i++ )
	{
		if (InteractionArray[i] == Inter)
		{
			iIndex = i; 
			break;
		}
	}

	// Was it found?
	
	if (iIndex<0)
	{
		log("Interaction "$Inter$" is not in "$ViewportOwner$".",'IMaster');
		return;
	}
	else if (iIndex==0)
		return;					// Already has focus
	

	// Move it to the top.		
		
	temp = InteractionArray[iIndex];
	for ( i=0; i<iIndex; i++)
		InteractionArray[i+1] = InteractionArray[i];
		
	InteractionArray[0] = temp;
	InteractionArray[0].bActive = true;		// Give it Input
	InteractionArray[0].bVisible = true;	// Make it visible	

    // bug fix proposed by Josh Adams 30/May/2002, confirmed by Joe Wilcox the same day
    if (ViewportOwner != none)
	    ViewportOwner.LocalInteractions = InteractionArray;
    else
	    GlobalInteractions = InteractionArray;
} // SetFocusTo				


	
// ====================================================================
// Input Functions
//
// The Process functions are here to limit the # of switches from C++ to Script. 
// ====================================================================
/* --> Become a 100% C++ function 		
event bool Process_KeyType( array<Interaction> InteractionArray, out EInputKey Key ) // Process a single key press
{
	local int Index;
	
	// Chain through the Interactions
	
	for ( Index=0; Index<InteractionArray.Length; Index++) 
	{
		// Give each Interaction the chance to process the key event

		if ( ( InteractionArray[Index].bActive ) && (!InteractionArray[Index].bNativeEvents) && ( InteractionArray[Index].KeyType(key,Unicode) ) )
			return true;				// and break the chain if processed
	
	}
	return false;	// Keep processing

} // Process_KeyType
*/

/* --> Become a 100% C++ function 		
event bool Process_KeyEvent( array<Interaction> InteractionArray,
				out EInputKey Key, out EInputAction Action, FLOAT Delta ) // Process the range of input events
{
	local int Index;

	// Chain through the Interactions
	
	for ( Index=0; Index<InteractionArray.Length; Index++)
	{
		// Give each Interaction the chance to process the key event
		
		if ( ( InteractionArray[Index].bActive ) && (!InteractionArray[Index].bNativeEvents) && ( InteractionArray[Index].KeyEvent(Key, Action, Delta ) ) )
		{
			return true;						// and break the chain if processed
		}
	
	}
	return false; 

} // Process_KeyEvent
*/

// ====================================================================
// Render functions only occure on local interactions.  The process
// the array in reverse order so that the objects that have focus
// are drawn last. 
// ====================================================================
/* --> Become a 100% C++ function 		

event Process_PreRender( array<Interaction> InteractionArray, canvas Canvas )
{
	local int index;

	// Chain through the Interactions

	for ( Index=InteractionArray.Length; Index>0; Index--)	// Give each Interaction PreRender time
	{
		if ( (InteractionArray[Index-1].bVisible ) && (!InteractionArray[Index-1].bNativeEvents) )
			InteractionArray[Index-1].PreRender(canvas);
	}			
		
} // Process_PreRender
*/

/* --> Become a 100% C++ function 		
event Process_PostRender( array<Interaction> InteractionArray, canvas Canvas )
{
	local int index;

	// Chain through the Interactions

	for ( Index=InteractionArray.Length; Index>0; Index--)	// Give each Interaction PreRender time
	{
		if ( (InteractionArray[Index-1].bVisible ) && (!InteractionArray[Index-1].bNativeEvents) )
			InteractionArray[Index-1].PostRender(canvas);
	}			

} // Process_PostRender
*/

// ====================================================================
// Tick - Interactions can request access to be ticked.
// ====================================================================
/* --> Become a 100% C++ function 		
event Process_Tick( array<Interaction> InteractionArray, float DeltaTime )
{
	local int Index;
	
	// Chain through the Interactions

	for ( Index=0; Index<InteractionArray.Length; Index++) 
	{
		// Give each Interaction that requires it tick

		if ( (InteractionArray[Index].bRequiresTick ) && (!InteractionArray[Index].bNativeEvents) )
			InteractionArray[Index].Tick(DeltaTime);	
	}
}	
*/

// ====================================================================
// Message - The IM is responsible for sending Message events to all
// interactions.
// ====================================================================
/* --> Become a 100% C++ function 		
event Process_Message( coerce string Msg, float MsgLife, array<Interaction> InteractionArray)
{
	local int Index;
	
	// Chain through the Interactions

	for ( Index=0; Index<InteractionArray.Length; Index++) 
	{
		// Give each Interaction the message

		InteractionArray[Index].Message(Msg, MsgLife);	
	}

} // Message
*/


// This event is called if 'GlobalTimeOutArmed' is true, and if no input from the user
// occurred since 'DelayOfGlobalInputInactivityBeforeTimeOut' seconds
event InputTimeOut()
{
    log("Time out !!!!!");
    //Console.ConsoleCommand("Exit");
}

defaultproperties
{
     DelayOfGlobalInputInactivityBeforeTimeOut=30.000000
}
