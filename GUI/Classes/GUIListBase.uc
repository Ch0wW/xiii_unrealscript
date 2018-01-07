// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIListBase extends GUIComponent
		Native
		Abstract;

//#exec OBJ LOAD FILE=GUIContent.utx
	
		
var		bool				bSorted;			// Should we sort this list
var		color				SelectedBKColor;	// Color for a selection background
var		Material			SelectedImage;		// Image to use when displaying
var		int 				Top,Index;			// Pointers in to the list
var		int					ItemsPerPage;		// # of items per Page.  Is set natively
var		int					ItemHeight;			// Size of each row.  Subclass should set in PreDraw.
var		int					UserDefinedItemHeight;	// SOUTHEND height of each row. if not zero this will be used instead of the automatic calculation of how many will fit...  Subclass should set in PreDraw.
var		int					ItemWidth;			// Width of each row.. Subclass should set in PreDraw.
var		int					ItemCount;			// # of items in this list
var		bool				bHotTrack;			// Use the Mouse X/Y to always hightlight something
var		bool				bVisibleWhenEmpty;	// List is still drawn when there are no items in it.

var		GUIScrollBarBase	MyScrollBar;


// Owner-draw.
delegate OnDrawItem(Canvas Canvas, int Item, float X, float Y, float W, float H, bool bSelected);
delegate OnAdjustTop(GUIComponent Sender);

function Sort();	// Add in a bit

function int SetIndex(int NewIndex)
{
	if (NewIndex < 0 || NewIndex >= ItemCount)
		Index = -1;
	else
		Index = NewIndex;

	if ( (index>=0) && (ItemsPerPage>0) )
	{
		if (Index<top)
			Top = Index;
			
		if (ItemsPerPage != 0 && Index==Top+ItemsPerPage)
			Top = Index-ItemsPerPage+1;
	}		
		
	OnChange(self);
	return Index;
}

function Clear()
{
	Top = 0;
	ItemCount=0;
	SetIndex(-1);
	MyScrollBar.AlignThumb();
}

function MakeVisible(float Perc)
{
	SetTopItem(int((ItemCount-ItemsPerPage) * Perc));
}

function SetTopItem(int Item)
{
	Top = Item;
	if (Top+ItemsPerPage>=ItemCount)
		Top = ItemCount - ItemsPerPage; 	

	if (Top<0)
		Top=0;
		
	OnAdjustTop(Self);		
}



defaultproperties
{
     SelectedBKColor=(B=255,G=255,R=255,A=255)
     bAcceptsInput=True
     bTabStop=True
}
