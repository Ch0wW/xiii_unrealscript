//-----------------------------------------------------------
// Caisse (box)
// Created by iKi on Feb 19th 2002
// Last Modification Mar 11th 2002 by iKi
//-----------------------------------------------------------
class Caisse extends Explosif;



defaultproperties
{
     ExplosiveType=2
     FragmentTexture=None
     BreakedStaticMesh=StaticMesh'StaticExplosifs.caissexplosifKC'
     Fragments3D=(Type=Class'XIDCine.XIIIFragment3DEmitter',Eparpillement=(X=100.000000,Y=100.000000,Z=100.000000),Number=6,ScaleMin=0.500000,ScaleMax=0.200000,Offset=(Z=200.000000),StaticMesh=StaticMesh'StaticExplosifs.eclatplanche',Blow=(Z=100.000000))
     StaticMesh=StaticMesh'StaticExplosifs.caissexplosif'
     DrawScale=0.500000
     SaturationDistance=600.000000
     StabilisationDistance=3500.000000
     StabilisationVolume=-25.000000
     bSLightGroup=LG_Decor2
}
