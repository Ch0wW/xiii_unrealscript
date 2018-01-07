//-----------------------------------------------------------
// Bidon (can)
// Created by iKi
//-----------------------------------------------------------
class Bidon extends Explosif;

//	Fire=(Type=FT_Explosion,ScaleMin=150.000000,ScaleMax=150.000000,offset=(Z=150.000000),DrawStyle=PTDS_Translucent,Lifetime=4.000000,OneTextureAnimOnly=True)
//    Smoke=(Type=ST_RubanFumeeNoire,offset=(Z=10.000000),DrawStyle=PTDS_Modulated,Lifetime=10.000000,FadeOut=True,FadeOutBegin=5.000000)
//Class'XIDCine.XIIIFragment3DEmitter'


defaultproperties
{
     ExplosiveType=1
     FragmentTexture=None
     BreakedStaticMesh=StaticMesh'StaticExplosifs.bidonsol'
     ExplosiveEmitter=Class'XIDCine.CanExplosionEmitter'
     bDynamicLight=True
     StaticMesh=StaticMesh'StaticExplosifs.bidonexplosif'
     SaturationDistance=600.000000
     StabilisationDistance=3500.000000
     StabilisationVolume=-25.000000
}
