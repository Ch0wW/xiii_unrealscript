//===============================================================================
//  Manta.
//===============================================================================

class Manta extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=MantaM ANIM=MantaA

//#EXEC ANIM DIGEST  ANIM=MantaA USERAWINFO VERBOSE

//#EXEC TEXTURE IMPORT NAME=MantaTex  FILE=Textures\Manta.tga  MIPS=Off GROUP=Skins
//#EXEC MESHMAP SETTEXTURE MESHMAP=MantaM NUM=0 TEXTURE=MantaTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=mantaTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
