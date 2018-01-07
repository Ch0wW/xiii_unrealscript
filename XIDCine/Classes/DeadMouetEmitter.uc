//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DeadMouetEmitter extends Emitter;



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=DeadMouetEmitterA
         Acceleration=(X=10.000000,Y=10.000000,Z=-30.000000)
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Initialized=True
         FadeOutStartTime=3.000000
         MaxParticles=10
         StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         SpinsPerSecondRange=(X=(Min=-0.500000,Max=1.000000),Y=(Min=-0.800000,Max=1.000000))
         StartSizeRange=(X=(Min=5.000000,Max=15.000000),Y=(Min=5.000000,Max=15.000000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.plumesM'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Max=6.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-30.000000,Max=10.000000),Z=(Min=-10.000000,Max=200.000000))
         VelocityLossRange=(Z=(Min=2.000000,Max=2.000000))
         Name="DeadMouetEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.DeadMouetEmitter.DeadMouetEmitterA'
     Begin Object Class=SpriteEmitter Name=DeadMouetEmitterB
         Acceleration=(Z=-10.000000)
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         AutomaticInitialSpawning=False
         Initialized=True
         FadeOutStartTime=1.000000
         MaxParticles=1
         StartLocationOffset=(Z=60.000000)
         SizeScale(1)=(relativetime=0.200000,RelativeSize=2.000000)
         SizeScale(2)=(relativetime=1.000000,RelativeSize=0.200000)
         StartSizeRange=(X=(Min=30.000000,Max=30.000000),Y=(Min=30.000000,Max=30.000000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.iiik'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         Name="DeadMouetEmitterB"
     End Object
     Emitters(1)=SpriteEmitter'XIDCine.DeadMouetEmitter.DeadMouetEmitterB'
     AutoDestroy=False
     bDynamicLight=True
}
