//===============================================================================
//  MouetSol.
//===============================================================================

class MouetSol extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=MouetSolM ANIM=MouetSolA

//#EXEC TEXTURE IMPORT NAME=MouetteSolTex  FILE=Textures\MouetPose.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=MouetSolM NUM=0 TEXTURE=MouetteSolTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=MouetteSolTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
