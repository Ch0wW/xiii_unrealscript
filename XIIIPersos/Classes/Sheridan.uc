//===============================================================================
//  Sheridan.
//===============================================================================

class Sheridan extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=SheridanM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=SheridanTex  FILE=Textures\sheridan.tga  GROUP=Skins
//#EXEC MESHMAP SETTEXTURE MESHMAP=SheridanM NUM=0 TEXTURE=SheridanTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=SheridanTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
