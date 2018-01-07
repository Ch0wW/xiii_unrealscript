//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HelicoHSEmitter extends Emitter;

//      FadeInEndTime=0.5.000000
/*
    Begin Object Class=SpriteEmitter Name=HelicoHSEmitterA
      Acceleration=(X=-200.000000)
      UseColorScale=True
      ColorScale(0)=(Color=(B=128,G=128,R=128))
      ColorScale(1)=(relativetime=0.200000,Color=(B=225,G=225,R=225))
      ColorScale(2)=(relativetime=1.000000,Color=(B=128,G=128,R=128))
      FadeOutStartTime=2.000000
      FadeOut=True
      FadeIn=false
      MaxParticles=40
      StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
      SpinParticles=True
      SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-0.100000,Max=0.100000))
      UseSizeScale=True
      UseRegularSizeScale=False
	  UseRotationFrom=PTRS_Actor
      SizeScale(1)=(relativetime=0.200000,RelativeSize=1.000000)
      SizeScale(2)=(relativetime=1.000000,RelativeSize=1.000000)
      StartSizeRange=(X=(Min=50.000000),Y=(Min=50.000000))
      ParticlesPerSecond=2.000000
      InitialParticlesPerSecond=1.000000
      DrawStyle=PTDS_Brighten
      Texture=Texture'XIIICine.effets.explogrenadeB'
      LifetimeRange=(Min=3.000000,Max=3.000000)
      StartVelocityRange=(X=(Min=-1000.000000,Max=-500.000000),Z=(Min=0.000000,Max=200.000000))
      VelocityLossRange=(X=(Min=0.000000,Max=5.000000))
	  InactiveTime=60
	  AutomaticInitialSpawning=false
    End Object
*/


defaultproperties
{
     Begin Object Class=SpriteEmitter Name=HelicoHSEmitterA
         Acceleration=(X=-100.000000,Z=30.000000)
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         Initialized=True
         ColorScale(1)=(relativetime=0.200000,Color=(B=225,G=225,R=225))
         ColorScale(2)=(relativetime=1.000000,Color=(B=255,G=255,R=255))
         FadeOutStartTime=1.000000
         FadeInEndTime=1.000000
         MaxParticles=30
         StartLocationRange=(X=(Min=-100.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-0.100000,Max=0.100000))
         SizeScale(1)=(relativetime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(relativetime=1.000000,RelativeSize=0.200000)
         StartSizeRange=(X=(Min=30.000000,Max=50.000000),Y=(Min=30.000000,Max=50.000000))
         InitialParticlesPerSecond=25.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.explomiss'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-80.000000,Max=80.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-60.000000,Max=-30.000000))
         VelocityLossRange=(X=(Min=4.000000,Max=4.000000))
         Name="HelicoHSEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.HelicoHSEmitter.HelicoHSEmitterA'
     AutoDestroy=False
     AutoReset=True
     bDynamicLight=True
     CollisionRadius=4000.000000
     CollisionHeight=1000.000000
}
