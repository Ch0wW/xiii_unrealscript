// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIList extends GUIVertList
		Native;

//#exec OBJ LOAD FILE=GUIContent.utx
	

var		eTextAlign			TextAlign;			// How is text Aligned in the control

var	    array<GUIListElem>	Elements;

native final function SortList();

// Used by SortList.
delegate int CompareItem(GUIListElem ElemA, GUIListElem ElemB);

// Accessor function for the items.

function string SelectedText()
{
	if ( (Index >=0) && (Index <Elements.Length) )
		return Elements[Index].Item;
	else
		return "";
}

function Add(string NewItem, optional Object obj, optional string Str)
{
	Elements.Length = Elements.Length+1;
	
	Elements[Elements.Length-1].Item=NewItem;
	Elements[Elements.Length-1].ExtraData=obj;
	Elements[Elements.Length-1].ExtraStrData=Str;

	ItemCount=Elements.Length;
	
	if (Elements.Length == 1)
		SetIndex(0);
	else
		OnChange(self);

	MyScrollBar.AlignThumb();
}

function Replace(int index, string NewItem, optional Object obj, optional string Str)
{
	if ( (Index<0) || (Index>=Elements.Length) )
		Add(NewItem,Obj,Str);
	else
	{
		Elements[Index].Item = NewItem;
		Elements[Index].ExtraData = obj;
		Elements[Index].ExtraStrData = Str;
	}
}		

function Insert(int Index, string NewItem, optional Object obj, optional string Str)
{
	if ( (Index<0) || (Index>=Elements.Length) )
		Add(NewItem,Obj,Str);
	else
	{
		Elements.Insert(index,1);
		Elements[Index].Item=NewItem;
		Elements[Index].ExtraData=obj;
		Elements[Index].ExtraStrData=Str;

		ItemCount=Elements.Length;	

		OnChange(self);
		MyScrollBar.AlignThumb();
	}
}	

event Swap(int IndexA, int IndexB)
{
	local GUI.GUIListElem elem;

	if ( (IndexA<0) || (IndexA>=Elements.Length) || (IndexB<0) || (IndexB>=Elements.Length) )
		return;

	elem = Elements[IndexA];
	Elements[IndexA] = Elements[IndexB];
	Elements[IndexB] = elem;
}
	
function string GetItemAtIndex(int i)
{
	if ((i<0) || (i>Elements.Length))
		return "";
		
	return Elements[i].Item;
}

function SetItemAtIndex(int i, string NewItem)
{
	if ((i<0) || (i>Elements.Length))
		return;
		
	Elements[i].Item = NewItem;
}

function object GetObjectAtIndex(int i)
{
	if ((i<0) || (i>Elements.Length))
		return None;
		
	return Elements[i].ExtraData;
}

function string GetExtraAtIndex(int i)
{
	if ((i<0) || (i>Elements.Length))
		return "";
		
	return Elements[i].ExtraStrData;
}

function SetExtraAtIndex(int i, string NewExtra)
{
	if ((i<0) || (i>Elements.Length))
		return;
		
	Elements[i].ExtraStrData = NewExtra;
}

function GetAtIndex(int i, out string ItemStr, out object ExtraObj, out string ExtraStr)
{
	if ((i<0) || (i>Elements.Length))
		return;
		
	ItemStr = Elements[i].Item;
	ExtraObj = Elements[i].ExtraData;
	ExtraStr = Elements[i].ExtraStrData;
}  

function LoadFrom(GUIList Source, optional bool bClearFirst)
{
	local string t1,t2;
	local object t;
	local int i;

	if (bClearfirst)
		Clear();
	
	for (i=0;i<Source.Elements.Length;i++)
	{
		Source.GetAtIndex(i,t1,t,t2);
		Add(t1,t,t2);
	}
}

function Remove(int i, optional int Count)
{
	if (Count==0)
		Count=1;
		
	Elements.Remove(i, Count);

	ItemCount = Elements.Length;		
		
	SetIndex(-1);
	MyScrollBar.AlignThumb();
} 

function RemoveItem(string Item)
{
	local int i;

	// Work through array. If we find it, remove it (will reduce Elements.Length).
	// If we don't, move on to next one.
	i=0;
	while(i<Elements.Length)
	{
		if(Item ~= Elements[i].Item)
			Elements.Remove(i, 1);
		else
			i++;
	}

	ItemCount = Elements.Length;

	SetIndex(-1);
	MyScrollBar.AlignThumb();
}

function Clear()
{
	Elements.Remove(0,Elements.Length);

	Super.Clear();
	OnChange(self);
}	

function string Get()
{
	if ( (Index<0) || (Index>=ItemCount) )
		return "";
	else
		return Elements[Index].Item;
}

function object GetObject()
{
	if ( (Index<0) || (Index>=ItemCount) )
		return none;
	else
		return Elements[Index].ExtraData;
}	

function string GetExtra()
{
	if ( (Index<0) || (Index>=ItemCount) )
		return "";
	else
		return Elements[Index].ExtraStrData;
}
	
function string find(string Text, optional bool bExact)
{
	local int i;
	for (i=0;i<ItemCount;i++)
	{
		if (bExact)
		{
			if (Text == Elements[i].Item)
			{
				SetIndex(i);
				return  Elements[i].Item;
			}
		}
		else
		{
			if (Text ~=  Elements[i].Item)
			{
				SetIndex(i);
				return  Elements[i].Item;
			}
		}
	}
	return "";
}



defaultproperties
{
     TextAlign=TXTA_Center
}
