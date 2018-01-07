//-----------------------------------------------------------
// ExtinguisherEmitter
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class ExtinguisherEmitter extends Emitter;



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=ExtinguisherEmitterA
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(relativetime=0.200000,Color=(B=128,G=255,R=255))
         ColorScale(1)=(relativetime=0.500000,Color=(B=64,G=128,R=255))
         FadeOutStartTime=0.600000
         MaxParticles=1
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         SizeScale(1)=(relativetime=0.100000,RelativeSize=3.000000)
         SizeScale(2)=(relativetime=0.200000,RelativeSize=0.200000)
         SizeScale(3)=(relativetime=1.000000,RelativeSize=0.200000)
         StartSizeRange=(X=(Min=50.000000),Y=(Min=50.000000),Z=(Min=50.000000))
         InitialParticlesPerSecond=5.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.eclairblanc'
         SecondsBeforeInactive=10.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         Name="ExtinguisherEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.ExtinguisherEmitter.ExtinguisherEmitterA'
     Begin Object Class=SpriteEmitter Name=ExtinguisherEmitterB
         Acceleration=(Z=-10.000000)
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         OnceTextureAnim=True
         Initialized=True
         FadeOutStartTime=1.000000
         MaxParticles=5
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-25.000000,Max=25.000000))
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-0.100000,Max=0.100000))
         SizeScale(1)=(relativetime=0.200000,RelativeSize=1.500000)
         SizeScale(2)=(relativetime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=20.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.extinct_fumeeAD'
         SecondsBeforeInactive=10.000000
         LifetimeRange=(Min=3.500000)
         InitialDelayRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000))
         Name="ExtinguisherEmitterB"
     End Object
     Emitters(1)=SpriteEmitter'XIDCine.ExtinguisherEmitter.ExtinguisherEmitterB'
     Begin Object Class=SpriteEmitter Name=ExtinguisherEmitterC
         Acceleration=(Z=-800.000000)
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Initialized=True
         MaxParticles=30
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=5.000000,Max=20.000000),Y=(Min=5.000000,Max=20.000000),Z=(Min=5.000000,Max=20.000000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.extinct_fumeeAD'
         SecondsBeforeInactive=10.000000
         InitialDelayRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-10.000000,Max=600.000000))
         Name="ExtinguisherEmitterC"
     End Object
     Emitters(2)=SpriteEmitter'XIDCine.ExtinguisherEmitter.ExtinguisherEmitterC'
     Begin Object Class=SpriteEmitter Name=ExtinguisherEmitterD
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(relativetime=0.100000,Color=(R=255))
         ColorScale(1)=(relativetime=0.200000,Color=(B=128,G=255,R=255))
         ColorScale(2)=(relativetime=0.800000,Color=(B=255,G=255,R=255))
         ColorScaleRepeats=4.000000
         FadeOutStartTime=0.600000
         MaxParticles=1
         StartLocationRange=(Z=(Min=50.000000,Max=50.000000))
         SizeScale(1)=(relativetime=0.100000,RelativeSize=1.000000)
         SizeScale(2)=(relativetime=0.200000,RelativeSize=1.500000)
         SizeScale(3)=(relativetime=0.300000,RelativeSize=1.000000)
         SizeScale(4)=(relativetime=0.400000,RelativeSize=1.500000)
         SizeScale(5)=(relativetime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.Baommm'
         SecondsBeforeInactive=10.000000
         LifetimeRange=(Min=0.800000,Max=0.800000)
         InitialDelayRange=(Min=0.200000,Max=0.200000)
         Name="ExtinguisherEmitterD"
     End Object
     Emitters(3)=SpriteEmitter'XIDCine.ExtinguisherEmitter.ExtinguisherEmitterD'
     AutoDestroy=False
     bDynamicLight=True
     bDelayDisplay=True
     CollisionRadius=512.000000
     CollisionHeight=256.000000
}
