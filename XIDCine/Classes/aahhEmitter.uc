//-----------------------------------------------------------
// aahhEmitter
// Created by iKi
//-----------------------------------------------------------
class aahhEmitter extends Emitter;



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=aahhEmitterA
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=32,G=32,R=192))
         ColorScale(1)=(relativetime=1.000000,Color=(B=32,G=32,R=192))
         FadeOutStartTime=1.000000
         MaxParticles=1
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(relativetime=0.200000,RelativeSize=1.250000)
         SizeScale(2)=(relativetime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.aahh'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
         Name="aahhEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.aahhEmitter.aahhEmitterA'
     bDelayDisplay=True
}
