// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIVertGripButton extends GUIGFXButton
		Native;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
//	Graphic = Material'GUIContent.Menu.ButGrip';
}




defaultproperties
{
     Position=ICP_Bound
     bNeverFocus=True
     OnClickSound=GUI_CS_None
}
