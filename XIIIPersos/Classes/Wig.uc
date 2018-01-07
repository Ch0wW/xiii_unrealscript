//===============================================================================
//  Wig.
//===============================================================================

class Wig extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=WigM ANIM=JonesMajA

//#EXEC TEXTURE IMPORT NAME=WIGTex  FILE=Textures\WIG.tga  GROUP=Skins
//#EXEC MESHMAP SETTEXTURE MESHMAP=WigM NUM=0 TEXTURE=WIGTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=WIGTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
