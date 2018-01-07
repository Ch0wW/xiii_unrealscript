//===============================================================================
//  Gamin.
//===============================================================================

class Gamin extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=GaminM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=GaminTex  FILE=Textures\Gamin.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=GaminM NUM=0 TEXTURE=GaminTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=GaminTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
