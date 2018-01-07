class RenderTargetMaterial extends BitmapMaterial
	native
	noexport;

var int		RenderTarget;
var int     TexRes[32];

native function Update( int X, int Y, int Width, int Height, vector CamLocation, rotator CamRotation, float ViewFOV,
                        optional color FilterColor, optional float HighLight, optional Material FilterTexture );

native function AllocRect( int Width, int Height, out int X, out int Y );
native function FreeRect( int X, int Y, int Width, int Height );

//
//	Default properties
//

defaultproperties
{
     Format=TEXF_RGBA8
     UClampMode=TC_Clamp
     VClampMode=TC_Clamp
     UBits=7
     VBits=7
     USize=256
     VSize=256
     UClamp=256
     VClamp=256
}
