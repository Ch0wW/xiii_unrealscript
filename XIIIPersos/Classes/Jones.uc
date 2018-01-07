//===============================================================================
//  jones.
//===============================================================================

class Jones extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=JonesM ANIM=JonesMajA

//#EXEC TEXTURE IMPORT NAME=JonesTex  FILE=Textures\Jones.tga  GROUP=Skins


//#EXEC MESHMAP SETTEXTURE MESHMAP=JonesM NUM=0 TEXTURE=JonesTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=JonesTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
