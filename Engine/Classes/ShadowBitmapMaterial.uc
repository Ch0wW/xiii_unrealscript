class ShadowBitmapMaterial extends BitmapMaterial
	native
	noexport;

var int		ShadowTarget;
var Actor	ShadowActor;
var vector	LightDirection;
var int		ShadowIntensity;   // 0=invisible   255=black

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
     USize=128
     VSize=128
     UClamp=128
     VClamp=128
}
