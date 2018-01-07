//===============================================================================
//  Doc.
//===============================================================================

class Doc extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=DocM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=DocTex  FILE=Textures\Doc.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=DocM NUM=0 TEXTURE=DocTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=DocTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
