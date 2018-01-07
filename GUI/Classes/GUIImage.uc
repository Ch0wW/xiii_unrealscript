// ====================================================================
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIImage extends GUIComponent
	Native;

	
var(Menu) Material 			Image;				// The Material to Render
var(Menu) color				ImageColor;			// What color should we set
var(Menu) eImgStyle			ImageStyle;			// How should the image be displayed
var(Menu) EMenuRenderStyle	ImageRenderStyle;	// How should we display this image
var(Menu) eImgAlign			ImageAlign;			// If ISTY_Justified, how should image be aligned
var(Menu) int				DimX1,DimY1,DimX2,DimY2;// If set, it will pull a subimage from inside the image



defaultproperties
{
     ImageColor=(B=255,G=255,R=255,A=255)
     ImageRenderStyle=MSTY_Alpha
     DimX1=-1
     DimY1=-1
     DimX2=-1
     DimY2=-1
}
