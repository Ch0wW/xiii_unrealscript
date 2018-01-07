//===============================================================================
//  fbi.
//===============================================================================

class Fbi extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=FbiM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=FBITex  FILE=Textures\FBI.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=FbiM NUM=0 TEXTURE=FBITex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=FBITex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
