// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class XIIIGUIListBox extends GUIListBox;

var sound hMenuCurseur;
var XIIIRootWindow myRoot;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	
	//List.OnClick=InternalOnClick;
	//List.OnClickSound=GUI_CS_Click;
	List.OnChange=InternalOnChange;
	myRoot = XIIIWindow(MenuOwner).myRoot;
}

/*function bool InternalOnClick(GUIComponent Sender)
{
	List.InternalOnClick(Sender);
	OnClick(Self);
	return true;
}*/

function InternalOnChange(GUIComponent Sender)
{
  super.InternalOnChange(Sender);
  myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
}



defaultproperties
{
     hMenuCurseur=Sound'XIIIsound.Interface.MnCurseur'
     Controls(0)=GUIList'GUI.GUIListBox.TheList'
     Controls(1)=GUIVertScrollBar'GUI.GUIListBoxBase.TheScrollbar'
}
