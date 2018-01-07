//=============================================================================
// Texture: An Unreal texture map.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Texture extends BitmapMaterial
	safereplace
	native
	noteditinlinenew
	dontcollapsecategories
	noexport;

// Palette.
var(Texture) palette Palette;
var	transient int NewPalette;

// Texture flags.

var(Surface)			bool bMasked;
var(Surface)			bool bAlphaTexture;
var private				bool bRealtime;           // Texture changes in realtime.
var private				bool bParametric;         // Texture data need not be stored.
var private transient	bool bRealtimeChanged;    // Changed since last render.

// Animation.
var(Animation) texture AnimNext;
var transient  texture AnimCurrent;
var(Animation) byte    PrimeCount;
var transient  byte    PrimeCurrent;
var transient  byte    LastFrameCount;
var            byte    CreationMode;
var(Animation) float   MaxFrameRate;
var transient  float   Accumulator;

// Mipmaps.
var private native const array<int> Mips;

var const transient int	RenderInterface[4];

//::iKi:: Textures functions BEGIN
native final function float GetAnimLength( );
//::iKi:: Textures functions END

defaultproperties
{
}
