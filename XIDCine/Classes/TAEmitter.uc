//-----------------------------------------------------------
// TAEmitter
// Created by iKi
//-----------------------------------------------------------
class TAEmitter extends Emitter;

//		AutomaticInitialSpawning=False
//		FadeOut=True



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=TAEmitterA
         SpinParticles=True
         UseSizeScale=True
         Initialized=True
         MaxParticles=3
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-25.000000,Max=25.000000))
         StartSpinRange=(X=(Min=0.030000,Max=-0.030000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(relativetime=1.000000)
         StartSizeRange=(X=(Min=30.000000,Max=30.000000))
         InitialParticlesPerSecond=5.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.Ta'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=0.300000,Max=0.300000)
         Name="TAEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.TAEmitter.TAEmitterA'
     bDelayDisplay=True
}
