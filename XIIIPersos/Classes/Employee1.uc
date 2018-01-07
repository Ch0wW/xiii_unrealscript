//===============================================================================
//  Employee1.
//===============================================================================

class Employee1 extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=Employee1M ANIM=JonesMajA

//#EXEC TEXTURE IMPORT NAME=Employee1Tex  FILE=Textures\Employee1.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=Employee1M NUM=0 TEXTURE=Employee1Tex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=Employee1Tex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
