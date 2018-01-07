//-----------------------------------------------------------
// XIIIFragment3DEmitter
// Created by iKi on ??? ???? 2001
// Last Modification Fev 14th 2002 by iKi
//-----------------------------------------------------------
class XIIIFragment3DEmitter extends Emitter;



defaultproperties
{
     Begin Object Class=MeshEmitter Name=XIIIFragment3DEmitterA
         Acceleration=(Z=-950.000000)
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Initialized=True
         DampingFactorRange=(X=(Min=0.800000,Max=0.900000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.100000,Max=0.200000))
         StartLocationRange=(Y=(Min=-64.000000,Max=64.000000),Z=(Min=-128.000000,Max=128.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=-32767.000000,Max=32767.000000),Y=(Max=512.000000))
         RotationDampingFactorRange=(X=(Min=0.200000,Max=0.300000),Y=(Min=0.300000,Max=0.300000),Z=(Min=0.100000,Max=0.200000))
         StartSizeRange=(X=(Min=1.000000,Max=10.000000))
         InitialParticlesPerSecond=50000.000000
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=10.000000,Max=10.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=200.000000),Y=(Min=-100.000000,Max=100.000000))
         Name="XIIIFragment3DEmitterA"
     End Object
     Emitters(0)=MeshEmitter'XIDCine.XIIIFragment3DEmitter.XIIIFragment3DEmitterA'
     CollisionRadius=512.000000
     CollisionHeight=256.000000
}
