//===============================================================================
//  Rasta.
//===============================================================================

class Rasta extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=RastaM ANIM=MigA

//#EXEC TEXTURE IMPORT NAME=RastaTex  FILE=Textures\Rasta.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=RastaM NUM=0 TEXTURE=RastaTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=RastaTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
