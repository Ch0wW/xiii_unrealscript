//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIFireTorchEmitter extends Emitter;

EVENT Trigger(actor Other, Pawn EventInstigator)
{
	if ( Emitters[0].Disabled )
	{
		Emitters[0].Disabled=false;
		Emitters[1].Disabled=false;
//		Emitters[0].RespawnDeadParticles=false;
//		Emitters[1].Disabled=false;
	}
	else
	{
		Emitters[0].RespawnDeadParticles=false;
		Emitters[1].RespawnDeadParticles=false;
	}
}



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=XIIIFireTorchEmitterA
         FadeOut=True
         Disabled=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         Initialized=True
         FadeOutFactor=(W=2.000000,X=2.000000,Y=2.000000,Z=10.000000)
         MaxParticles=50
         StartLocationRange=(Y=(Min=-34.000000,Max=34.000000),Z=(Min=-78.000000,Max=78.000000))
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSpinRange=(X=(Min=-0.200000,Max=0.200000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(relativetime=1.000000,RelativeSize=0.800000)
         StartSizeRange=(X=(Min=70.000000,Max=70.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.Explosion'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=1.500000,Max=1.500000)
         Name="XIIIFireTorchEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.XIIIFireTorchEmitter.XIIIFireTorchEmitterA'
     Begin Object Class=SpriteEmitter Name=XIIIFireTorchEmitterB
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         FadeOut=True
         Disabled=True
         UseSizeScale=True
         AutomaticInitialSpawning=False
         Initialized=True
         MaxParticles=5
         StartLocationRange=(X=(Min=-50.000000,Max=-50.000000),Y=(Min=-34.000000,Max=34.000000),Z=(Min=50.000000,Max=78.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(relativetime=1.000000,RelativeSize=1.200000)
         StartSizeRange=(X=(Min=75.000000,Max=75.000000))
         ParticlesPerSecond=5.000000
         InitialParticlesPerSecond=60.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.aahh'
         SecondsBeforeInactive=10000.000000
         Name="XIIIFireTorchEmitterB"
     End Object
     Emitters(1)=SpriteEmitter'XIDCine.XIIIFireTorchEmitter.XIIIFireTorchEmitterB'
     bActorLight=True
     bDynamicLight=True
     LightType=LT_Steady
     LightEffect=LE_TorchWaver
     LightBrightness=255
     LightHue=41
     LightSaturation=117
     LightRadius=50
}
