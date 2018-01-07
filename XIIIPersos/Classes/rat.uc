//===============================================================================
//  rat.
//===============================================================================

class rat extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=ratM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=RatTex  FILE=Textures\Rat.tga MIPS=Off GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=ratM NUM=0 TEXTURE=RatTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=RatTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
