//===============================================================================
//  amos.
//===============================================================================

class Amos extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=AmosM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=AmosTex  FILE=Textures\Amos.tga  MIPS=Off GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=AmosM NUM=0 TEXTURE=AmosTex

//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=AmosTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
