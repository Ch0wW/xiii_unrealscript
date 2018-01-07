//===============================================================================
//  Slater.
//===============================================================================

class Slater extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=SlaterM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=SlaterTex  FILE=Textures\Slater.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=SlaterM NUM=0 TEXTURE=SlaterTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=SlaterTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
