// ====================================================================
//  SouthEnd Multi column listbox with image support
// ====================================================================

class XIIIGUIMultiListBox extends GUIMultiListBox;

var sound hMenuCurseur;
var XIIIRootWindow myRoot;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	
	List.OnClick=InternalOnClick;
	List.OnChange=InternalOnChange;
	myRoot = XIIIWindow(MenuOwner).myRoot;
}

function bool InternalOnClick(GUIComponent Sender)
{
  Super.InternalOnClick(Sender);
  myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	return true;
}

function InternalOnChange(GUIComponent Sender)
{
  Super.InternalOnChange(Sender);
  //myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
}



defaultproperties
{
     hMenuCurseur=Sound'XIIIsound.Interface.MnCurseur'
     Controls(0)=GUIMultiList'GUI.GUIMultiListBox.TheList'
     Controls(1)=GUIVertScrollBar'GUI.GUIListBoxBase.TheScrollbar'
}
