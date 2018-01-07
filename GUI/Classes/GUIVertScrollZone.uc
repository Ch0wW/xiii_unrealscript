// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIVertScrollZone extends GUIComponent
	Native;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	
	OnClick = InternalOnClick; 
}

function bool InternalOnClick(GUIComponent Sender)
{
	local float perc;
	
	if (!IsInBounds())
		return false;
	
	perc = ( Controller.MouseY - ActualTop() ) / ActualHeight();
	OnScrollZoneClick(perc);

	return true;
		
}
	

delegate OnScrollZoneClick(float Delta)		// Should be overridden
{
}



defaultproperties
{
     bAcceptsInput=True
     bCaptureMouse=True
     bNeverFocus=True
     bRepeatClick=True
}
