class BitmapMaterial extends RenderedMaterial
	abstract
	native
	noexport;

var(TextureFormat) const editconst enum ETextureFormat
{
	TEXF_P8,
	TEXF_RGBA7,
	TEXF_NoUsed1,
	TEXF_DXT1,
	TEXF_RGB8,
	TEXF_RGBA8,
	TEXF_NODATA,
	TEXF_DXT3,
	TEXF_DXT5,
	TEXF_G8,
	TEXF_G16,
	TEXF_RRRGGGBBB,
	TEXF_RGB565,
	TEXF_P4
} Format;

var(Texture) enum ETexClampMode
{
	TC_Wrap,
	TC_Clamp,
} UClampMode, VClampMode;

var const byte  UBits, VBits;
var const int   USize, VSize;
var(Texture) const int UClamp, VClamp;

defaultproperties
{
}
