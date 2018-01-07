// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIVertScrollButton extends GUIGFXButton
		Native;

//#exec OBJ LOAD FILE=GUIContent.utx

var(Menu)	bool	UpButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	
	//if (UpButton)
		//Graphic = Material'GUIContent.Menu.ArrowBlueUp';
		//Graphic = texture'XIIIMenuStart.boutonHA';
	//else
		//Graphic = Material'GUIContent.Menu.ArrowBlueDown';
		//Graphic = texture'XIIIMenuStart.boutonHA';
}




defaultproperties
{
     Position=ICP_Scaled
     bNeverFocus=True
}
