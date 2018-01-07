// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIListBoxBase extends GUIMultiComponent
		Native;

		
var		GUIVertScrollBar	ScrollBar;
var		bool				bVisibleWhenEmpty;						// List box is visible when empty.

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	local GUIListBase LocalList;

	LocalList = GUIListBase(Controls[0]);
	ScrollBar = GUIVertScrollBar(Controls[1]);	
	
	LocalList.StyleName = StyleName;	
	LocalList.bVisibleWhenEmpty = bVisibleWhenEmpty;
	
	Super.Initcomponent(MyController, MyOwner);

	
	LocalList.MyScrollBar = ScrollBar;
	ScrollBar.MyList = LocalList;	
	
	ScrollBar.FocusInstead = LocalList;
	
	for (i=0;i<ScrollBar.Controls.Length;i++)
		ScrollBar.Controls[i].FocusInstead = LocalList;
}



defaultproperties
{
     Controls(1)=GUIVertScrollBar'GUI.GUIListBoxBase.TheScrollbar'
     bAcceptsInput=True
}
