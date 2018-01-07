class PloufEmitter extends TrigerredEmitter;



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=PloufEmitterA
         Acceleration=(Z=-300.000000)
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=False
         AutomaticInitialSpawning=False
         SymmetryU=True
         RandomSymmetryU=True
         Initialized=True
         ColorScale(0)=(Color=(B=163,G=163,R=163))
         ColorScale(1)=(relativetime=1.000000,Color=(B=128,G=128,R=128))
         FadeOutStartTime=0.200000
         FadeInEndTime=0.200000
         MaxParticles=3
         StartLocationOffset=(Z=-32.000000)
         StartLocationRange=(X=(Min=-64.000000,Max=64.000000),Y=(Min=-64.000000,Max=64.000000),Z=(Min=-20.000000))
         SizeScale(1)=(relativetime=0.100000,RelativeSize=2.000000)
         SizeScale(2)=(relativetime=1.000000,RelativeSize=0.100000)
         StartSizeRange=(X=(Min=50.000000),Y=(Min=50.000000),Z=(Min=50.000000))
         CenterV=-0.500000
         InitialParticlesPerSecond=20.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.couronne'
         SecondsBeforeInactive=10.000000
         LifetimeRange=(Min=2.000000,Max=3.000000)
         InitialDelayRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=200.000000,Max=200.000000))
         Name="PloufEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.PloufEmitter.PloufEmitterA'
     Begin Object Class=SpriteEmitter Name=PloufEmitterB
         Acceleration=(X=1.000000,Y=1.000000,Z=-500.000000)
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         Initialized=True
         FadeOutStartTime=0.500000
         MaxParticles=40
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000))
         StartSizeRange=(X=(Min=5.000000,Max=10.000000),Y=(Min=5.000000,Max=10.000000),Z=(Min=5.000000,Max=10.000000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.etincelle'
         LifetimeRange=(Min=2.000000,Max=3.000000)
         InitialDelayRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=750.000000,Max=100.000000))
         MaxAbsVelocity=(X=100.000000,Y=100.000000,Z=750.000000)
         Name="PloufEmitterB"
     End Object
     Emitters(1)=SpriteEmitter'XIDCine.PloufEmitter.PloufEmitterB'
     Begin Object Class=SpriteEmitter Name=PloufEmitterC
         UseDirectionAs=PTDU_Normal
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
         FadeOutStartTime=1.000000
         FadeInEndTime=0.500000
         MaxParticles=2
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-0.100000,Max=0.100000))
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(relativetime=0.050000,RelativeSize=2.000000)
         SizeScale(2)=(relativetime=0.500000,RelativeSize=3.000000)
         SizeScale(3)=(relativetime=1.000000,RelativeSize=4.000000)
         StartSizeRange=(X=(Min=150.000000,Max=200.000000),Y=(Min=150.000000,Max=200.000000))
         InitialParticlesPerSecond=50.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.grossebulle'
         LifetimeRange=(Min=5.000000,Max=6.000000)
         InitialDelayRange=(Min=0.300000,Max=0.300000)
         Name="PloufEmitterC"
     End Object
     Emitters(2)=SpriteEmitter'XIDCine.PloufEmitter.PloufEmitterC'
     Begin Object Class=SpriteEmitter Name=PloufEmitterD
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=159,G=159,R=159))
         ColorScale(1)=(relativetime=1.000000,Color=(B=128,G=128,R=128))
         FadeOutStartTime=3.000000
         FadeInEndTime=1.000000
         MaxParticles=3
         SpinsPerSecondRange=(X=(Min=-0.050000,Max=0.050000),Y=(Min=-0.050000,Max=0.050000))
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(relativetime=0.200000,RelativeSize=5.000000)
         SizeScale(2)=(relativetime=0.400000,RelativeSize=10.000000)
         SizeScale(3)=(relativetime=1.000000,RelativeSize=20.000000)
         InitialParticlesPerSecond=1.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.rondenlo'
         LifetimeRange=(Max=6.000000)
         InitialDelayRange=(Min=-1.000000,Max=-1.000000)
         Name="PloufEmitterD"
     End Object
     Emitters(3)=SpriteEmitter'XIDCine.PloufEmitter.PloufEmitterD'
     TimeTillResetRange=(Min=1.000000,Max=1.000000)
     bDynamicLight=True
     bLightChanged=True
}
