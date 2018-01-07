//-----------------------------------------------------------
// GoundExtinguisher
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class GroundExtinguisher extends Explosif;



defaultproperties
{
     DamageRadius=100.000000
     DamageAmount=50.000000
     ExplosiveType=4
     FragmentTexture=None
     BreakedStaticMesh=StaticMesh'StaticExplosifs.extinc02_KC'
     Fragments_Type=None
     Fragments3D=(Type=Class'XIDCine.XIIIFragment3DEmitter',Eparpillement=(X=256.000000,Y=256.000000,Z=256.000000),ScaleMax=2.000000,StaticMesh=StaticMesh'StaticExplosifs.extinctfragment',Blow=(Z=500.000000))
     ExplosiveEmitter=Class'XIDCine.ExtinguisherEmitter'
     StaticMesh=StaticMesh'StaticExplosifs.extinc02'
     bSLightGroup=LG_Decor2
}
