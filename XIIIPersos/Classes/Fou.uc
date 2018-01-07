//===============================================================================
//  Fou.
//===============================================================================

class Fou extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=FouM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=FouTex  FILE=Textures\Fou.tga  GROUP=Skins


//#EXEC MESHMAP SETTEXTURE MESHMAP=FouM NUM=0 TEXTURE=FouTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=FouTex SOUND=ImpCdvr__hPlayImpCdvr


defaultproperties
{
}
