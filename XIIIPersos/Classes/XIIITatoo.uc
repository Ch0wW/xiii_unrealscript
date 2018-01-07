//===============================================================================
//  XIIITatoo.
//===============================================================================

class XIIITatoo extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=XIIITatooM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=XIIITatooTex  FILE=Textures\XIIITatoo.tga  GROUP=Skins


//#EXEC MESHMAP SETTEXTURE MESHMAP=XIIITatooM NUM=0 TEXTURE=XIIITatooTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=XIIITatooTex SOUND=ImpCdvr__hPlayImpCdvr


defaultproperties
{
}
