//===============================================================================
//  Frenchy.
//===============================================================================

class Frenchy extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=FrenchyM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=FrenchyTex  FILE=Textures\Frenchy.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=FrenchyM NUM=0 TEXTURE=FrenchyTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=FrenchyTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
