//===============================================================================
//  Spanish.
//===============================================================================

class Spanish extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=SpanishM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=SpanishTex  FILE=Textures\Spanish.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=SpanishM NUM=0 TEXTURE=SpanishTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=SpanishTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
