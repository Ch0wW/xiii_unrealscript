//===============================================================================
//  Nihei.
//===============================================================================

class Nihei extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=NiheiM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=NiheiTex  FILE=Textures\Nihei.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=NiheiM NUM=0 TEXTURE=NiheiTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=NiheiTex SOUND=ImpCdvr__hPlayImpCdvr


defaultproperties
{
}
