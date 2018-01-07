//===============================================================================
//  Gardien.
//===============================================================================

class Gardien extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=GardienM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=GardienTex  FILE=Textures\Gardien.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=GardienM NUM=0 TEXTURE=GardienTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=GardienTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
