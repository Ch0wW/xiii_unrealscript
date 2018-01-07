// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIListBox extends GUIListBoxBase
	native;

var	GUIList List;	// For Quick Access;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	List = GUIList(Controls[0]);
	Super.Initcomponent(MyController, MyOwner);
	
	List.OnClick=InternalOnClick;
	List.OnClickSound=GUI_CS_Click;
	List.OnChange=InternalOnChange;
	
}

function bool InternalOnClick(GUIComponent Sender)
{
	List.InternalOnClick(Sender);
	OnClick(Self);
	return true;
}

function InternalOnChange(GUIComponent Sender)
{
	OnChange(Self);
}

function int ItemCount()
{
	return List.ItemCount;
}



defaultproperties
{
     Controls(0)=GUIList'GUI.GUIListBox.TheList'
     Controls(1)=GUIVertScrollBar'GUI.GUIListBoxBase.TheScrollbar'
}
