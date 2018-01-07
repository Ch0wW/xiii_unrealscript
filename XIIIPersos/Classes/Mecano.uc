//===============================================================================
//  Mecano.
//===============================================================================

class Mecano extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=MecanoM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=MecanoTex  FILE=Textures\Mecano.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=MecanoM NUM=0 TEXTURE=MecanoTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=mecanoTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
