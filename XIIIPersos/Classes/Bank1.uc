//===============================================================================
//  Bank1.
//===============================================================================

class Bank1 extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=Bank1M ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=Bank1Tex  FILE=Textures\Bank1.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=Bank1M NUM=0 TEXTURE=Bank1Tex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=Bank1Tex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
