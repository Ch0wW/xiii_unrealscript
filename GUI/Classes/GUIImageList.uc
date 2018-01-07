// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIImageList extends GUIImage;
//	Native;

var array<string> MatNames;
var array<Material> Materials;
var int CurIndex;
var bool bWrap;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	OnKeyEvent=internalKeyEvent;
}

function AddMaterial(string MatName, out Material Mat)
{
local int i;

	if (Mat != None)
	{
		i = Materials.Length;
		Materials[i]=Mat;
		MatNames[i]=MatName;
	}
}

function string GetCurMatName()
{
	if (CurIndex >= 0 && CurIndex < Materials.Length)
		return MatNames[CurIndex];

	return "";
}

function SetIndex(int index)
{
	if (index >= 0 && index < Materials.Length)
	{
		CurIndex = index;
		Image = Materials[index];
	}
	else
	{
		Image = None;
		CurIndex = -1;
	}
}

function bool internalKeyEvent(out byte Key, out byte State, float delta)
{
	if ( ((Key==0x26 || Key==0x68 || Key==0x25 || Key==0x64) && (State==1)) || (key==0xEC && State==3) )	// Up/Left/MouseWheelUp
	{
		PrevImage();
		return true;
	}
	
	if ( ((Key==0x28 || Key==0x62 || Key==0x27 || Key==0x66) && (State==1)) || (key==0xED && State==3) )  // Down/Right/MouseWheelDn
	{
		NextImage();
		return true;
	}
	
	if ( (Key==0x24 || Key==0x67) && (State==1) ) // Home
	{
		FirstImage();
		return true;
	}
	
	if ( (Key==0x23 || Key==0x61) && (State==1) ) // End
	{
		LastImage();
		return true;
	}

	return false;
}

function PrevImage()
{
	if (CurIndex < 1)
	{
		if (bWrap)
			SetIndex(Materials.Length - 1);
	}
	else
		SetIndex(CurIndex - 1);
}

function NextImage()
{
	if (CurIndex < 0)
		SetIndex(0);
	else if ((CurIndex + 1) >= Materials.Length)
	{
		if (bWrap)
			SetIndex(0);
	}
	else
		SetIndex(CurIndex + 1);
}

function FirstImage()
{
	if (Materials.Length > 0)
		SetIndex(0);
}

function LastImage()
{
	if (Materials.Length > 0)
		SetIndex(Materials.Length - 1);
}



defaultproperties
{
     bAcceptsInput=True
     bCaptureMouse=True
     bTabStop=True
}
