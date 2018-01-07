//===============================================================================
//  Frenchy2.
//===============================================================================

class Frenchy2 extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=Frenchy2M ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=frenchy2Tex  FILE=Textures\Frenchy2.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=Frenchy2M NUM=0 TEXTURE=frenchy2Tex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=Frenchy2Tex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
