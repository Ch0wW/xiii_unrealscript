//===============================================================================
//  Canard.
//===============================================================================

class Canard extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=CanardM ANIM=CanardA

//#EXEC TEXTURE IMPORT NAME=CanardTex  FILE=Textures\Canard.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=CanardM NUM=0 TEXTURE=CanardTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=canardTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
