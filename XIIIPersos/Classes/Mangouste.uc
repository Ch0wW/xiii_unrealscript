//===============================================================================
//  Mangouste.
//===============================================================================

class Mangouste extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=MangousteM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=MangousteTex  FILE=Textures\Mangouste.tga  GROUP=Skins


//#EXEC MESHMAP SETTEXTURE MESHMAP=MangousteM NUM=0 TEXTURE=MangousteTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=MangousteTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
