//-----------------------------------------------------------
// CanExplosionEmitter
// Created by iKi
//-----------------------------------------------------------
class CanExplosionEmitter extends Emitter;



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=CanExplosionEmitterA
         Acceleration=(Z=-100.000000)
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(relativetime=0.200000,Color=(B=128,G=255,R=255))
         ColorScale(2)=(relativetime=1.000000,Color=(B=64,G=64,R=128))
         FadeOutStartTime=0.600000
         FadeInEndTime=0.200000
         MaxParticles=10
         StartLocationOffset=(Z=40.000000)
         StartLocationRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Max=60.000000))
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.200000),Y=(Min=0.100000,Max=0.200000),Z=(Min=0.100000,Max=0.200000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(relativetime=0.100000,RelativeSize=2.000000)
         SizeScale(2)=(relativetime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=25.000000),Y=(Min=52.000000),Z=(Min=25.000000))
         InitialParticlesPerSecond=22.000000
         Texture=Texture'XIIICine.extinct_exploAD'
         SecondsBeforeInactive=100.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=200.000000,Max=300.000000))
         VelocityLossRange=(Z=(Min=0.500000,Max=1.000000))
         Name="CanExplosionEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.CanExplosionEmitter.CanExplosionEmitterA'
     Begin Object Class=SpriteEmitter Name=CanExplosionEmitterB
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         MaxParticles=1
         StartLocationOffset=(Z=60.000000)
         SizeScale(1)=(relativetime=0.100000,RelativeSize=3.000000)
         SizeScale(2)=(relativetime=0.300000,RelativeSize=1.000000)
         SizeScale(3)=(relativetime=1.000000,RelativeSize=0.200000)
         InitialParticlesPerSecond=10.000000
         Texture=Texture'XIIICine.effets.eclairblanc'
         SecondsBeforeInactive=100.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
         Name="CanExplosionEmitterB"
     End Object
     Emitters(1)=SpriteEmitter'XIDCine.CanExplosionEmitter.CanExplosionEmitterB'
     Begin Object Class=SpriteEmitter Name=CanExplosionEmitterC
         Acceleration=(Z=-1500.000000)
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=128,G=255,R=255))
         ColorScale(1)=(relativetime=0.500000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(relativetime=1.000000,Color=(B=128,G=255,R=255))
         FadeOutStartTime=0.500000
         MaxParticles=10
         StartLocationOffset=(Z=60.000000)
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(relativetime=0.050000,RelativeSize=2.000000)
         SizeScale(2)=(relativetime=0.100000,RelativeSize=0.500000)
         SizeScale(3)=(relativetime=1.000000,RelativeSize=0.200000)
         StartSizeRange=(X=(Min=10.000000,Max=20.000000),Y=(Min=10.000000,Max=20.000000),Z=(Min=10.000000,Max=20.000000))
         InitialParticlesPerSecond=40.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.etincelle'
         SecondsBeforeInactive=100.000000
         LifetimeRange=(Min=1.300000,Max=1.300000)
         StartVelocityRange=(X=(Min=-1000.000000,Max=1000.000000),Y=(Min=-1000.000000,Max=1000.000000),Z=(Min=1500.000000,Max=1500.000000))
         VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=2.000000,Max=2.000000))
         Name="CanExplosionEmitterC"
     End Object
     Emitters(2)=SpriteEmitter'XIDCine.CanExplosionEmitter.CanExplosionEmitterC'
     Begin Object Class=SpriteEmitter Name=CanExplosionEmitterD
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         FadeOutStartTime=0.300000
         MaxParticles=2
         StartLocationOffset=(Z=150.000000)
         SizeScale(0)=(RelativeSize=1.200000)
         SizeScale(1)=(relativetime=1.000000,RelativeSize=1.000000)
         SizeScaleRepeats=1.000000
         StartSizeRange=(X=(Min=80.000000),Y=(Min=80.000000),Z=(Min=80.000000))
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.Blam'
         SecondsBeforeInactive=100.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
         Name="CanExplosionEmitterD"
     End Object
     Emitters(3)=SpriteEmitter'XIDCine.CanExplosionEmitter.CanExplosionEmitterD'
     Begin Object Class=SpriteEmitter Name=CanExplosionEmitterE
         Acceleration=(X=10.000000,Y=10.000000,Z=20.000000)
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         SymmetryU=True
         SymmetryV=True
         RandomSymmetryU=True
         RandomSymmetryV=True
         Initialized=True
         FadeOutStartTime=2.000000
         FadeInFactor=(W=2.000000)
         FadeInEndTime=1.500000
         MaxParticles=15
         StartLocationOffset=(Z=50.000000)
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Max=50.000000))
         SpinsPerSecondRange=(X=(Min=-0.300000,Max=0.400000),Y=(Min=-0.300000,Max=0.400000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(relativetime=0.200000,RelativeSize=1.500000)
         SizeScale(2)=(relativetime=0.500000,RelativeSize=1.000000)
         SizeScale(3)=(relativetime=1.000000,RelativeSize=0.600000)
         StartSizeRange=(X=(Min=70.000000),Y=(Min=70.000000),Z=(Min=70.000000))
         CenterV=-0.100000
         InitialParticlesPerSecond=50.000000
         DrawStyle=PTDS_Darken
         Texture=Texture'XIIICine.effets.explogrenadeB'
         SecondsBeforeInactive=100.000000
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-30.000000,Max=-30.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000))
         Name="CanExplosionEmitterE"
     End Object
     Emitters(4)=SpriteEmitter'XIDCine.CanExplosionEmitter.CanExplosionEmitterE'
     Begin Object Class=MeshEmitter Name=CanExplosionEmitterF
         StaticMesh=StaticMesh'StaticExplosifs.bidonexplosifKC'
         Acceleration=(Z=-1500.000000)
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Initialized=True
         DampingFactorRange=(Z=(Min=0.500000,Max=0.500000))
         MaxCollisions=(Min=1.000000,Max=2.000000)
         FadeOutStartTime=1.000000
         MaxParticles=1
         StartLocationOffset=(Z=30.000000)
         StartMassRange=(Min=0.800000)
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000))
         StartSizeRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         InitialParticlesPerSecond=100.000000
         SecondsBeforeInactive=100.000000
         LifetimeRange=(Min=1.000000,Max=1.500000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=2000.000000,Max=2000.000000))
         VelocityLossRange=(Z=(Min=0.500000,Max=1.000000))
         Name="CanExplosionEmitterF"
     End Object
     Emitters(5)=MeshEmitter'XIDCine.CanExplosionEmitter.CanExplosionEmitterF'
     CollisionRadius=512.000000
     CollisionHeight=256.000000
}
