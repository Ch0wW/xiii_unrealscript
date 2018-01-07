//===============================================================================
//  Galbrain.
//===============================================================================

class Galbrain extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=GalbrainM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=GalbrainTex  FILE=Textures\Galbrain.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=GalbrainM NUM=0 TEXTURE=GalbrainTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=GalbrainTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
