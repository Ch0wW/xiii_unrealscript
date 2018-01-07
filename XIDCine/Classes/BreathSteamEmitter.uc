//-----------------------------------------------------------
// BreathSteamEmitter
// Created by iKi
//-----------------------------------------------------------
class BreathSteamEmitter extends Emitter;

EVENT Trigger( actor Other, pawn EventInstigator )
{
	Emitters[0].Disabled=false;
	Emitters[0].SpawnParticle(1);
}

EVENT PostBeginPlay( )
{
	Emitters[0].Disabled=true;
}



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=BreathSteamEmitterA
         Acceleration=(Z=17.000000)
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=64,G=64,R=64))
         ColorScale(1)=(relativetime=1.000000,Color=(B=64,G=64,R=64))
         MaxParticles=5
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.400000,Max=0.400000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(relativetime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=5.000000,Max=15.000000))
         InitialParticlesPerSecond=1.000000
         Texture=Texture'XIIICine.extinct_fumeeAD'
         SecondsBeforeInactive=5.000000
         LifetimeRange=(Min=2.000000)
         StartVelocityRange=(X=(Min=22.000000,Max=30.000000))
         Name="BreathSteamEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.BreathSteamEmitter.BreathSteamEmitterA'
     AutoDestroy=False
     RelativeLocation=(Y=10.000000)
     RelativeRotation=(Yaw=16384)
}
