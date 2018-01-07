//===============================================================================
//  Spads.
//===============================================================================

class Spads extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=SpadsM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=SPADSTex  FILE=Textures\Spads.tga  GROUP=Skins
//#EXEC MESHMAP SETTEXTURE MESHMAP=SpadsM NUM=0 TEXTURE=SpadsTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=SpadsTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
