//=============================================================================
// Canvas: A drawing canvas.
// This is a built-in Unreal class and it shouldn't be modified.
//
// Notes.
//   To determine size of a drawable object, set Style to STY_None,
//   remember CurX, draw the thing, then inspect CurX and CurYL.
//=============================================================================
class Canvas extends Object
	native
	noexport;

// Modifiable properties.
var font    Font;            // Font for DrawText.
var float   SpaceX, SpaceY;  // Spacing for after Draw*.
var float   OrgX, OrgY;      // Origin for drawing.
var float   ClipX, ClipY;    // Bottom right clipping region.
var float   CurX, CurY;      // Current position for drawing.
var float   Z;               // Z location. 1=no screenflash, 2=yes screenflash.
var byte    Style;           // Drawing style STY_None means don't draw.
var float   CurYL;           // Largest Y size since DrawText.
var color   DrawColor;       // Color for drawing.
var bool    bCenter;         // Whether to center the text.
var bool    bNoSmooth;       // Don't bilinear filter.
var bool	  bUseBorder;      // Draw border around tiles.
var bool    bNoRestoreState; // No restore state.
var bool    bDialogWindow;   // to add some display to the window
var bool    bTextShadow;     // Draw the text w/ a shadow (1 pixel down right, color *0.3)

var color   BorderColor;     // Border color around tiles.
var const int SizeX, SizeY;  // Zero-based actual dimensions.

// Stock fonts.
var font SmallFont;          // Small system font.
var font MedFont;           // Medium system font.

// Internal.
var const viewport Viewport; // Viewport that owns the canvas.

//::iKi::
var float CineFrameAlpha;
var float CineFrameDelay;
// native functions.
native(464) static final function StrLen( coerce string String, out float XL, out float YL );
native(465) static final function DrawText( coerce string Text, optional bool CR );
native(466) static final function DrawTile( Material Tex, float XL, float YL, float U, float V, float UL, float VL );
native(467) static final function DrawActor( Actor A, bool WireFrame, optional bool ClearZ, optional float DisplayFOV );
native(468) static final function DrawTileClipped( Material Tex, float XL, float YL, float U, float V, float UL, float VL );
native(469) static final function DrawTextClipped( coerce string Text, optional bool bCheckHotKey );
native(470) static final function TextSize( coerce string String, out float XL, out float YL );
native(480) static final function DrawPortal( int X, int Y, int Width, int Height, actor CamActor, vector CamLocation, rotator CamRotation, optional int FOV, optional bool ClearZ );
native(240) static final function DrawLine( float X1, float Y1, float X2, float Y2, color LineColor );

native(239) static final function WrapStringToArray(string Text, out array<string> OutArray, float dx, string EOL);

// These are helper functions.  They use the whole texture only.  If you need better support, use DrawTile
native(241) static final function DrawTileStretched(material Mat, float XL, float YL);
native(257) static final function DrawTileJustified(material Mat, byte Justification, float XL, float YL);
native(253) static final function DrawTileScaled(material Mat, float XScale, float YScale);
native(268) static final function DrawTextJustified(coerce string String, byte Justification, float x1, float y1, float x2, float y2);

//::iKi::
native(238) static final function DrawCineFrame(bool bOnOff);

// NL1306
native static final function DrawMsgboxBackground(bool bOnlyCenter, float _OrgX, float _OrgY, float _LineWidth, float _LineHeight, float _Width, float _Height);
// LN

// UnrealScript functions.
native(285) static final function DealWithResetEvent();
event Reset()
{
    /* --> turned into native function call
	Font        = Default.Font;
	SpaceX      = Default.SpaceX;
	SpaceY      = Default.SpaceY;
	OrgX        = Default.OrgX;
	OrgY        = Default.OrgY;
	CurX        = Default.CurX;
	CurY        = Default.CurY;
	Style       = Default.Style;
	DrawColor   = Default.DrawColor;
	CurYL       = Default.CurYL;
	bCenter     = false;
	bNoSmooth   = false;
	Z           = 1.0;
    */
    DealWithResetEvent();
}


/*native(269) static final function SetPos( float X, float Y )
{
	CurX = X;
	CurY = Y;
}*/
native(269) static final function SetPos( float X, float Y );

/*native(270) static final function SetOrigin( float X, float Y )
{
	OrgX = X;
	OrgY = Y;
}*/
native(270) static final function SetOrigin( float X, float Y );
/*native(271) static final function SetClip( float X, float Y )
{
	ClipX = X;
	ClipY = Y;
}*/
native(271) static final function SetClip( float X, float Y );

native static final function int GetScreenHeight();

final function DrawPattern( texture Tex, float XL, float YL, float Scale )
{
	DrawTile( Tex, XL, YL, (CurX-OrgX)*Scale, (CurY-OrgY)*Scale, XL*Scale, YL*Scale );
}
final function DrawIcon( texture Tex, float Scale )
{
	if ( Tex != None )
		DrawTile( Tex, Tex.USize*Scale, Tex.VSize*Scale, 0, 0, Tex.USize, Tex.VSize );
}
final function DrawRect( texture Tex, float RectX, float RectY )
{
	DrawTile( Tex, RectX, RectY, 0, 0, Tex.USize, Tex.VSize );
}


/*native(273) static final function SetDrawColor(byte R, byte G, byte B, optional byte A)
{
	local Color C;

	C.R = R;
	C.G = G;
	C.B = B;
	if ( A == 0 )
		A = 255;
	C.A = A;
	DrawColor = C;
}*/
native(273) static final function SetDrawColor(byte R, byte G, byte B, optional byte A);

/*native(274) static final function Color MakeColor(byte R, byte G, byte B, optional byte A)
{
	local Color C;

	C.R = R;
	C.G = G;
	C.B = B;
	if ( A == 0 )
		A = 255;
	C.A = A;
	return C;
}*/
native(274) static final function Color MakeColor(byte R, byte G, byte B, optional byte A);

defaultproperties
{
     Z=1.000000
     Style=1
     DrawColor=(B=127,G=127,R=127,A=255)
     CineFrameDelay=1.000000
}
