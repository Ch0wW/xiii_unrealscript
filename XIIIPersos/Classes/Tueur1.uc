//===============================================================================
//  Tueur1.
//===============================================================================

class Tueur1 extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=Tueur1M ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=Tueur1Tex  FILE=Textures\Tueur1.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=Tueur1M NUM=0 TEXTURE=Tueur1Tex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=TUeur1Tex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
