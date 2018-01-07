// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIStyles extends GUI
	Native;

	
var		string				KeyName;			// This is the name of the style used for lookup
var		EMenuRenderStyle	RStyles[5];			// The render styles for each state
var		Material			Images[5];			// This array holds 1 material for each state (Blurry, Watched, Focused, Pressed, Disabled)
var		eImgStyle			ImgStyle[5];		// How should each image for each state be drawed		
var		Color				FontColors[5];		// This array holds 1 font color for each state
var		Color				ImgColors[5];		// This array holds 1 image color for each state
var		GUIFont				Fonts[5];			// Holds the fonts for each state
var		int					BorderOffsets[4];	// How thick is the border
var		string				FontNames[5];		// Holds the names of the 5 fonts to use

// Set by Controller 
var	bool					bRegistered;		// Used as Default only. Tells if Controller has this style registered.

// the OnDraw delegate Can be used to draw.  Return true to skip the default draw method

delegate bool OnDraw(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height);	 
delegate bool OnDrawText(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height, eTextAlign Align, string Text);

native function Draw(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height); 
native function DrawText(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height, eTextAlign Align, string Text); 			

event Initialize()
{
	local int i;
	
	// Preset all the data if needed 
	
	for (i=0;i<5;i++)
	{
		Fonts[i] = Controller.GetMenuFont(FontNames[i]);
	}
}



defaultproperties
{
     RStyles(0)=MSTY_Normal
     RStyles(1)=MSTY_Normal
     RStyles(2)=MSTY_Normal
     RStyles(3)=MSTY_Normal
     RStyles(4)=MSTY_Normal
     ImgStyle(0)=ISTY_Stretched
     ImgStyle(1)=ISTY_Stretched
     ImgStyle(2)=ISTY_Stretched
     ImgStyle(3)=ISTY_Stretched
     ImgStyle(4)=ISTY_Stretched
     FontColors(0)=(A=255)
     FontColors(1)=(A=255)
     FontColors(2)=(A=255)
     FontColors(3)=(A=255)
     FontColors(4)=(A=255)
     ImgColors(0)=(B=255,G=255,R=255,A=255)
     ImgColors(1)=(B=255,G=255,R=255,A=255)
     ImgColors(2)=(B=255,G=255,R=255,A=255)
     ImgColors(3)=(B=255,G=255,R=255,A=255)
     ImgColors(4)=(B=255,G=255,R=255,A=255)
     BorderOffsets(0)=9
     BorderOffsets(1)=9
     BorderOffsets(2)=9
     BorderOffsets(3)=9
     FontNames(0)="GUISmallFont"
     FontNames(1)="GUISmallFont"
     FontNames(2)="GUISmallFont"
     FontNames(3)="GUISmallFont"
     FontNames(4)="GUISmallFont"
}
