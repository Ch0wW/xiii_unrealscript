//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIAlerteEmitter extends Emitter;




















defaultproperties
{
     Begin Object Class=SpriteEmitter Name=XIIIAlerteEmitterA
         Acceleration=(Z=-100.000000)
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=248,G=248,R=248))
         ColorScale(1)=(relativetime=1.000000,Color=(G=206,R=206))
         ColorScaleRepeats=3.000000
         FadeOutStartTime=0.800000
         MaxParticles=1
         StartLocationOffset=(Z=10.000000)
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(relativetime=0.300000,RelativeSize=1.500000)
         SizeScale(2)=(relativetime=0.500000,RelativeSize=1.000000)
         SizeScale(3)=(relativetime=0.600000,RelativeSize=1.300000)
         SizeScale(4)=(relativetime=0.700000,RelativeSize=1.000000)
         SizeScale(5)=(relativetime=0.800000,RelativeSize=1.300000)
         SizeScale(6)=(relativetime=0.900000,RelativeSize=1.000000)
         SizeScale(7)=(relativetime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.Alert'
         LifetimeRange=(Min=0.800000,Max=0.800000)
         InitialDelayRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(Z=(Min=90.000000,Max=90.000000))
         VelocityLossRange=(Z=(Min=1.000000,Max=1.000000))
         Name="XIIIAlerteEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDPawn.XIIIAlerteEmitter.XIIIAlerteEmitterA'
     AutoDestroy=False
}
