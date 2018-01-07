//===============================================================================
//  Willard.
//===============================================================================

class Willard extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=WillardM ANIM=JonesMajA

//#EXEC TEXTURE IMPORT NAME=WillardTex  FILE=Textures\Willard.tga  GROUP=Skins
//#EXEC MESHMAP SETTEXTURE MESHMAP=WillardM NUM=0 TEXTURE=WillardTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=WillardTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
