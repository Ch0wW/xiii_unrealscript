//===============================================================================
//  XIII.
//===============================================================================

class XIII extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=XIIIM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=XIIITex  FILE=Textures\XIII.tga  GROUP=Skins


//#EXEC MESHMAP SETTEXTURE MESHMAP=XIIIM NUM=0 TEXTURE=XIIITex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=XIIITex SOUND=ImpCdvr__hPlayImpCdvr


defaultproperties
{
}
