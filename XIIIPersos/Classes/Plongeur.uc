//===============================================================================
//  Plongeur.
//===============================================================================

class Plongeur extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=PlongeurM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=PlongeurTex  FILE=Textures\Plongeur.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=PlongeurM NUM=0 TEXTURE=PlongeurTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=PlongeurTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
