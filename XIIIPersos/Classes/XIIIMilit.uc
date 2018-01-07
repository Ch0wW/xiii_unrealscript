//===============================================================================
//  XIIIMilit.
//===============================================================================

class XIIIMilit extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=XIIIMilitM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=XIIIMilitTex  FILE=Textures\XIIIMilit.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=XIIIMilitM NUM=0 TEXTURE=XIIIMilitTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=XIIIMilitTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
