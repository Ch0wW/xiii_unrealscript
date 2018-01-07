//===============================================================================
//  Louche.
//===============================================================================

class Louche extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=LoucheM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=LoucheTex  FILE=Textures\Louche.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=LoucheM NUM=0 TEXTURE=LoucheTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=LoucheTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
