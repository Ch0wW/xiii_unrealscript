// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIMultiComponent extends GUIComponent
		Native;

		
var		array<GUIComponent>		Controls;				// An Array of Components that make up this Control
var		GUIComponent			FocusedControl;			// Which component inside this one has focus

event int FindComponentIndex(GUIComponent Who)
{
	local int i;
	
	for (i=0;i<Controls.Length;i++)
		if (Who==Controls[i])
			return i;
	
	return -1;
} 

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	
	Super.Initcomponent(MyController, MyOwner);
	
	for (i=0;i<Controls.Length;i++)
	{
		Controls[i].InitComponent(MyController, Self);
	}
}

event SetFocus(GUIComponent Who)
{
	if (bNeverFocus)
	{
		if (FocusInstead != None)
			FocusInstead.SetFocus(Who);
			
		return;
	}
	if (Who==None) 
	{
	
		if (Controller.FocusedControl!=None)
			Controller.FocusedControl.LoseFocus(None);
			
		FocusFirst(Self,true);
		return;
	}
	else
		FocusedControl = Who;

	MenuStateChange(MSAT_Focused);

	if (MenuOwner!=None)
		MenuOwner.SetFocus(self);
}

event LoseFocus(GUIComponent Sender)
{
/*
	Controller.FocusedControl = None;

	if (FocusedControl!=None
		FocusedControl.LoseFocus();

	MenuStateChange(MSAT_Blurry);
*/		
	FocusedControl = None;
	Super.LoseFocus(Sender);
}


event bool FocusFirst(GUIComponent Sender, bool bIgnoreMultiTabStops)	
{

	local int i;

	if ( (!bVisible) || (MenuState==MSAT_Disabled) )
		return false;

	// Grab focus if not ignoring them
		
	if  ( (bTabStop) && (!bIgnoreMultiTabStops) ) 
	{
		Super.FocusFirst(Sender, bIgnoreMultiTabStops);
		return true;
	}		

	for (i=0;i<Controls.Length;i++)
	{
		if ( Controls[i].FocusFirst(self, bIgnoreMultiTabStops) )
			return true;
	}
		
	return false;
}


event bool FocusLast(GUIComponent Sender, bool bIgnoreMutliTabStops) 
{
	local int i;
	
	if ( (!bVisible) || (MenuState==MSAT_Disabled) )
		return false;

	if  ( (bTabStop) && (!bIgnoreMutliTabStops) ) //&& (FocusedControl!=None) )
	{
		Super.FocusLast(Sender, bIgnoreMutliTabStops);
		return true;
	}		
		
	for (i=Controls.Length;i>0;i--)
	{
		if (Controls[i-1].FocusLast(self, bIgnoreMutliTabStops) )
			return true;
	}
		
	return false;
}	

event bool NextControl(GUIComponent Sender)
{
	local int index,i;
	
	index = FindComponentIndex(Sender);

	index++;
	while (index<Controls.Length)
	{
		if ( Controls[index].FocusFirst(Self,false) )
		{
			return true;
		}

		index++;
	}

	// Noone. Try to leave..
	
	if (MenuOwner!=None)
	{
		return MenuOwner.NextControl(self);
	} 

	// Otherwise.. loop
	
	i = 0;
	while ( i < Index)
	{
		if (Controls[i].FocusFirst(Self,False))
			return true;
			
		i++;
	}
	
	return false;
		
}

event bool PrevControl(GUIComponent Sender)
{

	local int index, i;

	index = FindComponentIndex(Sender);
	index--;
	while (index>=0)
	{
		if ( Controls[index].FocusLast(Self,false) )
			return true;

		index--;
	}

	// Noone. Try to leave..
	
	if (MenuOwner!=None)
	{
		return MenuOwner.PrevControl(self);
	} 

	// Otherwise.. loop

	i = Controls.Length;
	while (i>Index)
	{
		i--;
		 if (Controls[i].FocusLast(Self,false))
			return true;
	}

	return false;
		
}

function string LoadINI()
{
	local int i;
	
	for (i=0;i<Controls.Length;i++)
		Controls[i].LoadINI();

	Super.LoadINI();
		
	return "";
}

function SaveINI(string Value)
{
	local int i;
	
	for (i=0;i<Controls.Length;i++)
		Controls[i].SaveINI("");

	Super.SaveINI(Value);
		
	return;
}

event MenuStateChange(eMenuState Newstate)
{

	local int i;
	
	if (NewState==MSAT_Disabled)
	{
		for (i=0;i<Controls.Length;i++)
			Controls[i].MenuStateChange(MSAT_Disabled);
	}
	else 
	{
		for (i=0;i<Controls.Length;i++)
			if (Controls[i].MenuState==MSAT_Disabled)
				Controls[i].MenuStateChange(MSAT_Blurry);
	}
		
	Super.MenuStateChange(NewState);
}

 
		


defaultproperties
{
}
