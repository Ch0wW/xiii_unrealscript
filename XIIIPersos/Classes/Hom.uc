//===============================================================================
//  Hom.
//===============================================================================

class Hom extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=HomM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=HomTex  FILE=Textures\Hom.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=HomM NUM=0 TEXTURE=HomTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=HomTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
