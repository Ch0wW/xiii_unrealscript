//===============================================================================
//  mouette.
//===============================================================================

class mouette extends TousLesPersos;

//#exec MESH    DEFAULTANIM MESH=mouetteM ANIM=mouetteA

//#exec ANIM DIGEST  ANIM=mouetteA USERAWINFO VERBOSE

//#EXEC TEXTURE IMPORT NAME=mouetTex  FILE=Textures\Mouet.tga MIPS=Off GROUP=Skins
//#EXEC MESHMAP SETTEXTURE MESHMAP=mouetteM NUM=0 TEXTURE=mouetTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=mouetTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
