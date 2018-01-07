//===============================================================================
//  Tueur5.
//===============================================================================

class Tueur5 extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=Tueur5M ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=Tueur5Tex  FILE=Textures\Tueur5.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=Tueur5M NUM=0 TEXTURE=Tueur5Tex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=Tueur5Tex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
