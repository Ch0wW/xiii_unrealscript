//===============================================================================
//  Corsaire.
//===============================================================================

class Corsaire extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=CorsaireM ANIM=JonesMajA

//#EXEC TEXTURE IMPORT NAME=corsaireTex  FILE=Textures\Corsaire.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=CorsaireM NUM=0 TEXTURE=corsaireTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=CorsaireTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
