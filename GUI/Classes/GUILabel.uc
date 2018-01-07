// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUILabel extends GUIComponent
	Native;

	
var(Menu)	localized 	string				Caption;			// The text to display
var(Menu)				eTextAlign			TextAlign;			// How is the text aligned in it's bounding box
var(Menu)				color				TextColor;			// The Color to display this in.
var(Menu)				color				FocusedTextColor;	// The Color to display this in.
var(Menu)				EMenuRenderStyle	TextStyle;			// What canvas style to use
var(Menu)				string 				TextFont;			// The Font to display it in
var(Menu)				bool				bTransparent;		// Draw a Background for this label
var(Menu)				bool				bMultiLine;			// Will cut content to display on multiple lines when too long
var(Menu)				color				BackColor;			// Background color for this label
var(Menu)				bool				bChecked;


defaultproperties
{
     TextColor=(A=255)
     FocusedTextColor=(B=255,G=255,R=255,A=255)
     TextStyle=MSTY_Normal
     TextFont="GUIBigFont"
     bTransparent=True
     BackColor=(R=255,A=255)
}
