//===============================================================================
//  Requin.
//===============================================================================

class Requin extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=RequinM ANIM=RequinA

//#EXEC ANIM DIGEST  ANIM=RequinA USERAWINFO VERBOSE

//#EXEC TEXTURE IMPORT NAME=RequinTex  FILE=Textures\Requin.tga  MIPS=Off GROUP=Skins
//#EXEC MESHMAP SETTEXTURE MESHMAP=RequinM NUM=0 TEXTURE=RequinTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=RequinTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
