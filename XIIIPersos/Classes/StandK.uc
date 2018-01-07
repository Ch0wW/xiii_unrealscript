//===============================================================================
//  StandK.
//===============================================================================

class StandK extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=StandKM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=StandKTex  FILE=Textures\StandK.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=StandKM NUM=0 TEXTURE=StandKTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=StandKTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
