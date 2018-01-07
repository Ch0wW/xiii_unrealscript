//===============================================================================
//  SM.
//===============================================================================

class SM extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=SMM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=SMTex  FILE=Textures\SM.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=SMM NUM=0 TEXTURE=SMTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=SMTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
