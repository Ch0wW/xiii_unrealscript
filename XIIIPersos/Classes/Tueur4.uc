//===============================================================================
//  Tueur4.
//===============================================================================

class Tueur4 extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=Tueur4M ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=Tueur4Tex  FILE=Textures\Tueur4.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=Tueur4M NUM=0 TEXTURE=Tueur4Tex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=Tueur4Tex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
