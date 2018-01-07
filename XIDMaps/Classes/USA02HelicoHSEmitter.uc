//-----------------------------------------------------------
//
//-----------------------------------------------------------
class USA02HelicoHSEmitter extends Emitter;



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=USA02HelicoHSEmitterA
         Acceleration=(X=-200.000000)
         UseColorScale=True
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         Initialized=True
         ColorScale(0)=(Color=(B=128,G=128,R=128))
         ColorScale(1)=(relativetime=0.200000,Color=(B=225,G=225,R=225))
         ColorScale(2)=(relativetime=1.000000,Color=(B=128,G=128,R=128))
         FadeOutStartTime=2.000000
         FadeInEndTime=1.000000
         MaxParticles=20
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-0.100000,Max=0.100000))
         SizeScale(1)=(relativetime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(relativetime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=50.000000),Y=(Min=50.000000))
         ParticlesPerSecond=2.000000
         InitialParticlesPerSecond=1.000000
         DrawStyle=PTDS_Darken
         Texture=Texture'XIIICine.effets.explogrenadeB'
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=25.000000,Max=25.000000))
         VelocityLossRange=(X=(Min=5.000000,Max=5.000000))
         Name="USA02HelicoHSEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDMaps.USA02HelicoHSEmitter.USA02HelicoHSEmitterA'
     AutoDestroy=False
     AutoReset=True
     bDynamicLight=True
}
