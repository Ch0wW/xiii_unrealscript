//===============================================================================
//  Pam.
//===============================================================================

class Pam extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=PamM ANIM=JonesMajA

//#EXEC TEXTURE IMPORT NAME=PamTex  FILE=Textures\Pam.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=PamM NUM=0 TEXTURE=PamTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=PamTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
