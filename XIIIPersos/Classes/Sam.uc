//===============================================================================
//  Sam.
//===============================================================================

class Sam extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=SamM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=SamTex  FILE=Textures\Sam.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=SamM NUM=0 TEXTURE=SamTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=SamTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
