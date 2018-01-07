// ====================================================================
//  SouthEnd Multi column listbox with image support
// ====================================================================

class GUIMultiListBox extends GUIListBox;

var	GUIMultiList List;	// For Quick Access;



function bool SetColumnAlignment(int colIdx, int align) // 0 == left 1 == center 2 == right
{
  return List.SetColumnAlignment(colIdx, align);
}

function bool SetNumberOfColumns(int nrCols)
{
  return List.SetNumberOfColumns(nrCols);
}

function bool SetColumnOffset(int colIdx, int xOffs)
{
  return List.SetColumnOffset(colIdx, xOffs);
}








function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	List = GUIMultiList(Controls[0]);
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
     Controls(0)=GUIMultiList'GUI.GUIMultiListBox.TheList'
     Controls(1)=GUIVertScrollBar'GUI.GUIListBoxBase.TheScrollbar'
}
