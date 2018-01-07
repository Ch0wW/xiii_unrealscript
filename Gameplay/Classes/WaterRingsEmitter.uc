//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WaterRingsEmitter extends Emitter;

var sound hImpactSound;

//_____________________________________________________________________________
function PlayImpactSound(int HitSoundType)
{
    PlaySound(hImpactSound, HitSoundType);
}


defaultproperties
{
     hImpactSound=Sound'XIIIsound.Impacts__ImpEau.ImpEau__hPlayImpEau'
     Begin Object Class=SpriteEmitter Name=WaterRingsEmitterA
         UseDirectionAs=PTDU_MoveAndViewForward
         Acceleration=(Z=0.100000)
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         MaxParticles=3
         SizeScale(1)=(relativetime=1.000000,RelativeSize=20.000000)
         StartSizeRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=5.000000,Max=5.000000),Z=(Min=5.000000,Max=5.000000))
         InitialParticlesPerSecond=3000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.rondenlo'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=1.000000,Max=1.500000)
         Name="WaterRingsEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'Gameplay.WaterRingsEmitter.WaterRingsEmitterA'
     Begin Object Class=SpriteEmitter Name=WaterRingsEmitterB
         Acceleration=(Z=-800.000000)
         FadeOut=True
         RespawnDeadParticles=False
         UseRegularSizeScale=False
         UniformSize=False
         AutomaticInitialSpawning=False
         Initialized=True
         FadeInEndTime=0.700000
         MaxParticles=15
         StartLocationRange=(Z=(Min=-20.000000,Max=-20.000000))
         StartSizeRange=(X=(Min=2.000000,Max=3.000000),Y=(Min=2.000000,Max=3.000000),Z=(Min=2.000000,Max=3.000000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.etincelle'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=500.000000,Max=800.000000))
         VelocityLossRange=(Z=(Min=4.000000,Max=5.000000))
         Name="WaterRingsEmitterB"
     End Object
     Emitters(1)=SpriteEmitter'Gameplay.WaterRingsEmitter.WaterRingsEmitterB'
     bUseCylinderCollision=True
}
