//===============================================================================
//  Scandi.
//===============================================================================

class Scandi extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=ScandiM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=ScandiTex  FILE=Textures\scandi.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=ScandiM NUM=0 TEXTURE=scandiTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=scandiTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
