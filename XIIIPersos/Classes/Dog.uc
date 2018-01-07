//===============================================================================
//  Dog.
//===============================================================================

class Dog extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=DogM ANIM=DogA

//#EXEC TEXTURE IMPORT NAME=DogTex  FILE=Textures\Dog.tga MIPS=Off GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=DogM NUM=0 TEXTURE=DogTex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=DogTex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
