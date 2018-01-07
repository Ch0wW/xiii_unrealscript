//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CardboardFragmentsEmitter extends Emitter;



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=CardboardFragmentsEmitterA
         Acceleration=(Z=-300.000000)
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Initialized=True
         MaxParticles=10
         StartLocationRange=(X=(Min=-64.000000,Max=64.000000),Y=(Min=-64.000000,Max=64.000000),Z=(Min=-64.000000,Max=64.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=1.000000,Max=10.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.paperSSH1'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000),Z=(Min=140.000000,Max=120.000000))
         Name="CardboardFragmentsEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.CardboardFragmentsEmitter.CardboardFragmentsEmitterA'
     Begin Object Class=SpriteEmitter Name=CardboardFragmentsEmitterB
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         FadeOutStartTime=0.400000
         MaxParticles=1
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=40.000000,Max=70.000000))
         SizeScale(0)=(RelativeSize=0.800000)
         SizeScale(1)=(relativetime=0.100000,RelativeSize=2.000000)
         SizeScale(2)=(relativetime=0.150000,RelativeSize=1.000000)
         SizeScale(3)=(relativetime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=30.000000,Max=40.000000),Y=(Min=30.000000,Max=40.000000))
         InitialParticlesPerSecond=8.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.death3'
         SecondsBeforeInactive=10000.000000
         InitialTimeRange=(Min=0.100000,Max=0.100000)
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Max=10.000000))
         Name="CardboardFragmentsEmitterB"
     End Object
     Emitters(1)=SpriteEmitter'XIDCine.CardboardFragmentsEmitter.CardboardFragmentsEmitterB'
     AutoDestroy=False
}
