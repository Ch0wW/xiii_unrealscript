//=============================================================================
// Material: Abstract material class
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Material extends Object
	native
	editinlinenew
	hidecategories(Object)
	collapsecategories
	noexport;

#exec Texture Import File=Textures\DefaultTexture.pcx COMPRESS=DXT1

var() editinlineuse Material FallbackMaterial;
var Texture EditorIcon;
var transient Object EditorLayout;

//MC for HarmonX integration
// Sounds.
var(Sound) sound FootstepSound;			// Footstep sound.
var(Sound) sound XIIIFootStepSound;		// FootStep sound for main character
var(Sound) sndpnjstep PNJSndStep;
var(Sound) sndxiiistep XIIISndStep;
//var(Sound) sound LandSound;				// Land sound
//var(Sound) sound XIIILandSound;			// Land sound for main character
//var(Sound) sound JumpSound;				// Jump sound
//var(Sound) sound XIIIJumpSound;			// Jump sound for main character
var(Sound) sound HitSound;				// Sound when the texture is hit with a projectile.
var(Sound) float NoiseLoudness;				// for MakeNoise
//end MC

defaultproperties
{
     FallbackMaterial=Texture'Engine.DefaultTexture'
     NoiseLoudness=0.100000
}
