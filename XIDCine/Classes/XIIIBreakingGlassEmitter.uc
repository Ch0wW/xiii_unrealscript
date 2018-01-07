//-----------------------------------------------------------
// XIIIBreakingGlassEmitter
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class XIIIBreakingGlassEmitter extends Emitter;

//        SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
//        StartSizeRange=(X=(Min=25.000000,Max=25.000000),Y=(Min=25.000000,Max=25.000000),Z=(Min=25.000000,Max=25.000000))
//        StartLocationRange=(X=(Min = -64,Max = 64),Y=(Min=0,Max=0),Z=(Min = -128,Max = 128))

//        Texture=Texture'XIIICine.glass13'
//        StartVelocityRange=(X=(Min=-20,Max=200),Y=(Min=-100,Max=100),Z=(Min=0,Max=0))
//        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=-64,Max=64),Z=(Min=-128,Max=128))
//        TextureUSubdivisions=2
//        TextureVSubdivisions=2



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=XIIIBreakingGlassEmitterA
         Acceleration=(Z=-950.000000)
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Initialized=True
         DampingFactorRange=(X=(Min=0.800000,Max=0.900000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.100000,Max=0.200000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=0.900000,Max=0.900000),Y=(Min=0.900000,Max=0.900000),Z=(Min=0.900000,Max=0.900000))
         StartSizeRange=(X=(Min=1.000000,Max=10.000000))
         InitialParticlesPerSecond=50000.000000
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=10.000000,Max=10.000000)
         Name="XIIIBreakingGlassEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.XIIIBreakingGlassEmitter.XIIIBreakingGlassEmitterA'
     CollisionRadius=512.000000
     CollisionHeight=256.000000
}
