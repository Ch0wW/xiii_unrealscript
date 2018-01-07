//===============================================================================
//  Groflic.
//===============================================================================

class Groflic extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=GroflicM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=GroflicTex  FILE=Textures\Groflic.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=GroflicM NUM=0 TEXTURE=GroflicTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=GroflicTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
