//===============================================================================
//  Wax.
//===============================================================================

class Wax extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=WaxM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=WaxTex  FILE=Textures\Wax.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=WaxM NUM=0 TEXTURE=WaxTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=WaxTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
