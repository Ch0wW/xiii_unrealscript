// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIVertList extends GUIListBase
		Native;



function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	OnKeyType=InternalOnKeyType;
	OnKeyEvent=InternalOnKeyEvent;
	OnClick=InternalOnClick;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local int NewIndex, row;

	if ( ( !IsInClientBounds() ) || (ItemsPerPage==0) )
		return false;

	// Get the Row..

	row = Controller.MouseY - ClientBounds[1];
	NewIndex = Top+ (row / ItemHeight);

	if (NewIndex >= ItemCount)
		return false;

	SetIndex(NewIndex);
	return true;
}

function bool InternalOnKeyType(out byte Key)
{
	// Add code to jump to next line with Char

	return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{

	if (ItemsPerPage==0) return false;


	if ( (Key==0x26 || Key==0x68) && (State==1 || State==2) )	// Up Arrow
	{
		Up();
		return true;
	}

	if ( (Key==0x28 || Key==0x62) && (State==1 || State==2) ) // Down Arrow
	{
		Down();
		return true;
	}

	if ( (Key==0x24 || Key==0x67) && (State==1) ) // Home
	{
		Home();
		return true;
	}

	if ( (Key==0x23 || Key==0x61) && (State==1) ) // End
	{
		End();
		return true;
	}

	if ( (Key==0x21 || Key==0x69) && (State==1) ) // PgUp
	{
		PgUp();
		return true;
	}

	if ( (Key==0x22 || Key==0x63) && (State==1) ) // PgDn
	{
		PgDn();
		return true;
	}

	if ( (key==0xEC) && (State==3) )
	{

		WheelUp();
		return true;
	}

	if ( (key==0xED) && (State==3) )
	{

		WheelDown();
		return true;
	}


	return false;
}


function WheelUp()
{
	if (MyScrollBar!=None)
		GUIVertScrollBar(MyScrollBar).WheelUp();
	else
	{
		if (!Controller.CtrlPressed)
			Up();
		else
			PgUp();
	}
}

function WheelDown()
{
	if (MyScrollBar!=None)
		GUIVertScrollBar(MyScrollBar).WheelDown();
	else
	{
		if (!Controller.CtrlPressed)
			Down();
		else
			PgDn();
	}
}


function Up()
{
	if ( (ItemCount<2) || (Index==0) ) return;

	Index = max(0,Index-1);

	if ( (Index<Top) || (Index>Top+ItemsPerPage) )
	{
		Top = Index;
		MyScrollBar.AlignThumb();
	}

	OnChange(self);
}

function Down()
{
	if ( (ItemCount<2) || (Index==ItemCount-1) )	return;

	Index = min(Index+1,ItemCount-1);
	if (Index<Top)
	{
		Top = Index;
		MyScrollBar.AlignThumb();
	}
	else if (Index>=Top+ItemsPerPage)
	{
		Top = Index-ItemsPerPage+1;
		MyScrollBar.AlignThumb();
	}

	OnChange(self);

}

function Home()
{
	if (ItemCount<2)	return;

	SetIndex(0);
	Top = 0;
	MyScrollBar.AlignThumb();

}

function End()
{
	if (ItemCount<2)	return;

	Top = ItemCount - ItemsPerPage;
	if (Top<0)
		Top = 0;

	SetIndex(ItemCount-1);
	MyScrollBar.AlignThumb();
}

function PgUp()
{

	if (ItemCount<2)	return;

	Index -= ItemsPerPage;

	// Adjust to bounds
	if (Index < 0)
		Index = 0;

	// If new index
	if (Top + ItemsPerPage <= Index)		// If index is forward but not visible, jump to it
		Top = Index;
	else if (Index + ItemsPerPage < Top)	// Item is way too far
		Top = Index;
	else if (Index < Top)	// Item is 1 page or less away
		SetTopItem(Top - ItemsPerPage);

	SetIndex(Index);
	MyScrollBar.AlignThumb();
}

function PgDn()
{

	if (ItemCount<2)	return;

	// Select item 1 page away from current selection
	Index += ItemsPerPage;

	// Adjust to bounds
	if (Index >= ItemCount)
		Index = ItemCount-1;


	if (Index < Top)  // If item is still before Top Item, go to it
		Top = Index;
	else if (Index - Top - ItemsPerPage >= ItemsPerPage)	// Too far away
		SetTopItem(Index);
	else if (Index - Top >= ItemsPerPage) // Just 1 page away
		SetTopItem(Top + ItemsPerPage);

	SetIndex(Index);
	MyScrollBar.AlignThumb();
}





defaultproperties
{
}
