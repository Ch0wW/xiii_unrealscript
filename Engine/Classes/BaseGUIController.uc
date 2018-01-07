// ====================================================================
//  Class:  Engine.BaseGUIController
// 
//  This is just a stub class that should be subclassed to support menus.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class BaseGUIController extends Interaction
		Native;

// Delegates
Delegate OnAdminReply(string Reply);	// Called By PlayerController

event bool CloseMenu(optional bool bCanceled, optional string Param1, optional string Param2)	// Close the top menu.  returns true if success.
{
	return true;	
}
event CloseAll(bool bCancel);

function SetControllerStatus(bool On)
{
	bActive = On;
	bVisible = On;
	bRequiresTick=On;
	
}

event InitializeController();	// Should be subclassed.

event bool NeedsMenuResolution(); // Big Hack that should be subclassed
event SetRequiredGameResolution(string GameRes);



event SetMenuStackBackup(string MenuStackAsText);
event string GetMenuStackBackup()
{
    return "";
}

defaultproperties
{
     bActive=False
     bNativeEvents=True
}
