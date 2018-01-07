//-----------------------------------------------------------
// FireWorkEmitter
// Created by iKi on Mar 21th 2002
// Last Modification Mar 21th 2002
//-----------------------------------------------------------
class FireWorkEmitter extends Emitter;

VAR() float StartSpeed;
VAR() float TimeBeforeExplode;

EVENT Trigger( actor Other, pawn EventInstigator )
{
	LOCAL int i;

	Emitters[1].Disabled=false;
	SetPhysics(PHYS_Projectile);
	SetTimer(TimeBeforeExplode,false);
	Velocity=StartSpeed*vector(rotation);
	Acceleration=vect(0,0,-10);
}

EVENT Timer()
{
	Emitters[1].Disabled=true; //RespawnDeadParticles=False;
	Emitters[0].Disabled=false;
	Velocity=vect(0,0,0);
}

EVENT PostBeginPlay( )
{
//	LOCAL int i;
//
//	for (i=0;i<Emitters.Length;++i)	
//		Emitters[i].Disabled=true;
}
//²



defaultproperties
{
     StartSpeed=666.000000
     TimeBeforeExplode=3.000000
     Begin Object Class=SpriteEmitter Name=FireWorkEmitterA
         Acceleration=(Z=-75.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         Disabled=True
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=64,G=128,R=128))
         ColorScale(1)=(relativetime=0.250000,Color=(R=128))
         ColorScale(2)=(relativetime=0.500000,Color=(G=128))
         ColorScale(3)=(relativetime=0.750000,Color=(B=128))
         ColorScale(4)=(relativetime=1.000000)
         MaxParticles=1000
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=5.000000))
         InitialParticlesPerSecond=666.000000
         Texture=Texture'XIIICine.effets.etincelle'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=5.000000,Max=8.000000)
         StartVelocityRange=(X=(Min=75.000000,Max=300.000000),Y=(Min=75.000000,Max=300.000000),Z=(Min=75.000000,Max=300.000000))
         GetVelocityDirectionFrom=PTVD_StartPositionAndOwner
         Name="FireWorkEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.FireWorkEmitter.FireWorkEmitterA'
     Begin Object Class=SpriteEmitter Name=FireWorkEmitterB
         UseColorScale=True
         FadeOut=True
         Disabled=True
         UseSizeScale=True
         UseRegularSizeScale=False
         Initialized=True
         ColorScale(0)=(Color=(G=64,R=64))
         ColorScale(1)=(relativetime=1.000000,Color=(G=64,R=64))
         MaxParticles=100
         SizeScale(0)=(relativetime=1.000000)
         StartSizeRange=(X=(Min=15.000000,Max=15.000000))
         ParticlesPerSecond=100.000000
         Texture=Texture'XIIICine.effets.etincelle'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=3.000000,Max=3.000000)
         Name="FireWorkEmitterB"
     End Object
     Emitters(1)=SpriteEmitter'XIDCine.FireWorkEmitter.FireWorkEmitterB'
     Physics=PHYS_Projectile
     bDirectional=True
}
