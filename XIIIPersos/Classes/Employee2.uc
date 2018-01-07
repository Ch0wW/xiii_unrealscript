//===============================================================================
//  Employee2.
//===============================================================================

class Employee2 extends TousLesPersos;

//#EXEC MESH    DEFAULTANIM MESH=Employee2M ANIM=JonesMajA

//#EXEC TEXTURE IMPORT NAME=Employee2Tex  FILE=Textures\Employee2.tga  GROUP=Skins

//#EXEC MESHMAP SETTEXTURE MESHMAP=Employee2M NUM=0 TEXTURE=Employee2Tex
//#EXEC OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
//#EXEC TEXTURE SETHITSOUND TEXTURE=Employee2Tex SOUND=ImpCdvr__hPlayImpCdvr



defaultproperties
{
}
