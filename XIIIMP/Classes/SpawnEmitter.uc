//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SpawnEmitter extends Emitter;

var sound hSpawnSound;    // Play on creation

//_____________________________________________________________________________
simulated event PostBeginPlay()
{
//    Log("SPAWN"@self);
    Super.PostBeginPlay();
    PlaySound(hSpawnSound);
}



defaultproperties
{
     hSpawnSound=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hRespawn'
     Begin Object Class=SpriteEmitter Name=SpawnEmitterA
         UseDirectionAs=PTDU_Normal
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=False
         AutomaticInitialSpawning=False
         SymmetryU=True
         SymmetryV=True
         RandomSymmetryU=True
         RandomSymmetryV=True
         Initialized=True
         FadeOutStartTime=0.100000
         MaxParticles=5
         StartLocationRange=(Z=(Max=20.000000))
         SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(relativetime=1.000000,RelativeSize=1.500000)
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.effets.explogrenadeC'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(Z=(Min=50.000000,Max=50.000000))
         Name="SpawnEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIIIMP.SpawnEmitter.SpawnEmitterA'
     Begin Object Class=SpriteEmitter Name=SpawnEmitterB
         UseDirectionAs=PTDU_Normal
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=False
         Initialized=True
         MaxParticles=1
         SizeScale(1)=(relativetime=1.000000,RelativeSize=1.200000)
         Texture=Texture'XIIICine.effets.eclairblanc'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=0.400000,Max=0.400000)
         Name="SpawnEmitterB"
     End Object
     Emitters(1)=SpriteEmitter'XIIIMP.SpawnEmitter.SpawnEmitterB'
     Begin Object Class=SpriteEmitter Name=SpawnEmitterC
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=False
         RandomSymmetryU=True
         RandomSymmetryV=True
         Initialized=True
         MaxParticles=3
         SizeScale(1)=(relativetime=1.000000,RelativeSize=1.000000)
         Texture=Texture'XIIICine.effets.explogrenadeB'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
         Name="SpawnEmitterC"
     End Object
     Emitters(2)=SpriteEmitter'XIIIMP.SpawnEmitter.SpawnEmitterC'
     Begin Object Class=SpriteEmitter Name=SpawnEmitterD
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=False
         Initialized=True
         FadeOutStartTime=0.200000
         MaxParticles=1
         StartLocationOffset=(Z=60.000000)
         SizeScale(1)=(relativetime=1.000000,RelativeSize=1.000000)
         Texture=Texture'XIIICine.effets.crac'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=0.400000,Max=0.400000)
         Name="SpawnEmitterD"
     End Object
     Emitters(3)=SpriteEmitter'XIIIMP.SpawnEmitter.SpawnEmitterD'
}
