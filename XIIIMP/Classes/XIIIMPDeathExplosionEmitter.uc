//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPDeathExplosionEmitter extends Emitter;


//_____________________________________________________________________________
event PostBeginPlay()
{
    Spawn(class'GrenadExplosionOverlayEmitter', self,, Location, Rotation);
    if ( !Level.bHighDetailMode )
      Emitters[2].UseCollision = false;
    if ( (Level.Game != none) && (Level.GetPlateForme() == 1) ) // PS2
    {
      Emitters[2].UseCollision = false;
      Emitters[2].SetMaxParticles(5);
    }
}



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=GrenadExplosionEmitterA
         Acceleration=(X=5.000000,Y=5.000000,Z=40.000000)
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(relativetime=0.150000,Color=(B=187,G=197,R=198))
         ColorScale(1)=(relativetime=0.250000,Color=(B=88,G=88,R=88))
         ColorScale(2)=(relativetime=0.900000)
         ColorScale(3)=(relativetime=1.000000,Color=(B=82,G=82,R=82))
         FadeOutStartTime=2.000000
         FadeInEndTime=0.100000
         MaxParticles=10
         StartLocationRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=-25.000000,Max=25.000000))
         SphereRadiusRange=(Min=-100.000000,Max=100.000000)
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=0.100000,Y=0.100000,Z=0.100000)
         SpinsPerSecondRange=(X=(Max=0.100000),Y=(Max=0.100000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(relativetime=0.250000,RelativeSize=2.800000)
         SizeScale(2)=(relativetime=0.300000,RelativeSize=2.900000)
         SizeScale(3)=(relativetime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=10.000000,Max=40.000000),Y=(Min=10.000000,Max=40.000000),Z=(Min=10.000000,Max=40.000000))
         CenterV=-1.000000
         InitialParticlesPerSecond=40.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.explogrenadeMD'
         SecondsBeforeInactive=20.000000
         LifetimeRange=(Min=4.500000,Max=5.000000)
         StartVelocityRange=(Z=(Min=25.000000,Max=45.000000))
         VelocityLossRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         Name="GrenadExplosionEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIIIMP.XIIIMPDeathExplosionEmitter.GrenadExplosionEmitterA'
     Begin Object Class=SpriteEmitter Name=GrenadExplosionEmitterB
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         NoSynchroAnim=True
         RandomSymmetryU=True
         RandomSymmetryV=True
         Initialized=True
         ColorScale(0)=(relativetime=0.100000,Color=(B=128,G=255,R=255))
         ColorScale(1)=(relativetime=0.250000,Color=(B=131,G=162,R=254))
         ColorScale(2)=(relativetime=0.500000)
         ColorScale(3)=(relativetime=1.000000)
         FadeOutStartTime=0.200000
         FadeInEndTime=0.500000
         MaxParticles=2
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.050000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(relativetime=0.300000,RelativeSize=2.000000)
         SizeScale(2)=(relativetime=0.500000,RelativeSize=1.000000)
         SizeScale(3)=(relativetime=1.000000)
         StartSizeRange=(X=(Max=200.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'XIIICine.effets.explosol'
         SecondsBeforeInactive=20.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         Name="GrenadExplosionEmitterB"
     End Object
     Emitters(1)=SpriteEmitter'XIIIMP.XIIIMPDeathExplosionEmitter.GrenadExplosionEmitterB'
     Begin Object Class=MeshEmitter Name=GrenadExplosionEmitterC
         StaticMesh=StaticMesh'StaticExplosifs.grenadfragment'
         UseMeshBlendMode=False
         Acceleration=(X=10.000000,Y=10.000000,Z=-500.000000)
         UseCollision=True
         UseMaxCollisions=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Initialized=True
         DampingFactorRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         MaxCollisions=(Min=1.000000,Max=2.000000)
         FadeOutStartTime=5.000000
         MaxParticles=10
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         StartLocationShape=PTLS_Sphere
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=-32767.000000,Max=32767.000000),Y=(Max=512.000000))
         RotationDampingFactorRange=(X=(Min=0.200000,Max=0.300000),Y=(Min=0.300000,Max=0.300000),Z=(Min=0.100000,Max=0.200000))
         StartSizeRange=(X=(Min=0.700000,Max=2.000000),Y=(Min=0.700000,Max=2.000000),Z=(Min=0.700000,Max=2.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         SecondsBeforeInactive=20.000000
         StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=400.000000,Max=400.000000))
         Name="GrenadExplosionEmitterC"
     End Object
     Emitters(2)=MeshEmitter'XIIIMP.XIIIMPDeathExplosionEmitter.GrenadExplosionEmitterC'
     Begin Object Class=SpriteEmitter Name=GrenadExplosionEmitterD
         Acceleration=(Z=-600.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=128,G=255,R=255))
         ColorScale(1)=(relativetime=1.000000,Color=(R=255))
         MaxParticles=10
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=10.000000)
         SizeScale(1)=(relativetime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(relativetime=1.000000,RelativeSize=10.000000)
         StartSizeRange=(X=(Min=1.000000,Max=1.500000),Y=(Min=1.000000,Max=1.500000),Z=(Min=1.000000,Max=3.000000))
         CenterU=0.500000
         CenterV=0.500000
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.etincelle'
         SecondsBeforeInactive=20.000000
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-2000.000000,Max=2000.000000),Y=(Min=-2000.000000,Max=2000.000000),Z=(Min=400.000000,Max=500.000000))
         MaxAbsVelocity=(X=1000.000000,Y=1000.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000))
         Name="GrenadExplosionEmitterD"
     End Object
     Emitters(3)=SpriteEmitter'XIIIMP.XIIIMPDeathExplosionEmitter.GrenadExplosionEmitterD'
     Begin Object Class=SpriteEmitter Name=GrenadExplosionEmitterE
         Acceleration=(Z=-10.000000)
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=128,G=128,R=128,A=255))
         ColorScale(1)=(relativetime=0.500000,Color=(B=111,G=149,R=166,A=255))
         ColorScale(2)=(relativetime=1.000000)
         FadeOutStartTime=6.000000
         FadeInEndTime=0.200000
         MaxParticles=15
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-35.000000,Max=35.000000))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=75.000000,Max=50.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.150000),Y=(Min=-0.100000,Max=0.150000),Z=(Min=-0.100000,Max=0.150000))
         SizeScale(1)=(relativetime=0.050000,RelativeSize=2.000000)
         SizeScale(2)=(relativetime=1.000000,RelativeSize=0.500000)
         StartSizeRange=(X=(Min=75.000000),Y=(Min=75.000000),Z=(Min=75.000000))
         CenterV=-1.000000
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.mist2'
         SecondsBeforeInactive=20.000000
         LifetimeRange=(Min=8.000000,Max=10.000000)
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=30.000000,Max=50.000000))
         VelocityLossRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
         Name="GrenadExplosionEmitterE"
     End Object
     Emitters(4)=SpriteEmitter'XIIIMP.XIIIMPDeathExplosionEmitter.GrenadExplosionEmitterE'
     Begin Object Class=SpriteEmitter Name=GrenadExplosionEmitterF
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         MaxParticles=2
         StartLocationOffset=(Z=100.000000)
         StartLocationRange=(Z=(Min=-5.000000,Max=5.000000))
         SizeScale(0)=(relativetime=0.250000,RelativeSize=1.000000)
         SizeScale(1)=(relativetime=0.200000,RelativeSize=1.500000)
         SizeScale(2)=(relativetime=0.300000,RelativeSize=1.200000)
         SizeScale(3)=(relativetime=0.400000,RelativeSize=1.500000)
         SizeScale(4)=(relativetime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=90.000000),Y=(Min=90.000000),Z=(Min=90.000000))
         InitialParticlesPerSecond=5000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.Blam'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         SecondsBeforeInactive=20.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.100000,Max=0.100000)
         Name="GrenadExplosionEmitterF"
     End Object
     Emitters(5)=SpriteEmitter'XIIIMP.XIIIMPDeathExplosionEmitter.GrenadExplosionEmitterF'
     CollisionRadius=500.000000
     CollisionHeight=500.000000
}
