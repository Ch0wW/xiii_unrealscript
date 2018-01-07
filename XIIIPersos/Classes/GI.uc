//===============================================================================
//  GI.
//===============================================================================

class Gi extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=GiM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=GITex  FILE=Textures\GI.tga  GROUP=Skins
//#EXEC MESHMAP SETTEXTURE MESHMAP=GiM NUM=0 TEXTURE=GITex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=GITex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
