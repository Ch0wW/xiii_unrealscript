//-----------------------------------------------------------
// WallExtinguisher
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class WallExtinguisher extends Explosif;

FUNCTION InitializeEmitters()
{
	ExplosiveEmitterOffset=vect(0,-48,0)>>Rotation;
	Super.InitializeEmitters();
}



defaultproperties
{
     DamageRadius=200.000000
     DamageAmount=50.000000
     ExplosiveType=4
     FragmentTexture=None
     BreakedStaticMesh=StaticMesh'StaticExplosifs.extinc01_KC'
     Fragments_Type=None
     Fragments3D=(Type=Class'XIDCine.XIIIFragment3DEmitter',Eparpillement=(X=256.000000,Y=256.000000,Z=256.000000),ScaleMax=2.000000,StaticMesh=StaticMesh'StaticExplosifs.extinctfragment',Blow=(Z=500.000000))
     ExplosiveEmitter=Class'XIDCine.ExtinguisherEmitter'
     StaticMesh=StaticMesh'StaticExplosifs.extinc01'
     bSLightGroup=LG_Decor2
     bDirectional=True
}
