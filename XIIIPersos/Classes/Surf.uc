//===============================================================================
//  Surf.
//===============================================================================

class Surf extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=SurfM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=SurfTex  FILE=Textures\Surf.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=SurfM NUM=0 TEXTURE=SurfTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=SurfTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
