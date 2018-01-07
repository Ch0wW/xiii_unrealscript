//===============================================================================
//  Pacha.
//===============================================================================

class Pacha extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=PachaM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=PachaTex  FILE=Textures\Pacha.tga  GROUP=Skins


//#EXEC MESHMAP SETTEXTURE MESHMAP=PachaM NUM=0 TEXTURE=PachaTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=PachaTex SOUND=ImpCdvr__hPlayImpCdvr


defaultproperties
{
}
