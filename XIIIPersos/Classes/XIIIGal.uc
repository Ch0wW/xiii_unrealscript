//===============================================================================
//  XIIIGal.
//===============================================================================

class XIIIGal extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=XIIIGalM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=XIIIGalTex  FILE=Textures\XIIIGal.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=XIIIGalM NUM=0 TEXTURE=XIIIGalTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=XIIIGalTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
