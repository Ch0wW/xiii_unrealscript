//-----------------------------------------------------------
// TrigerredExplosionEmitter
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class TrigerredExplosionEmitter extends TrigerredEmitter;

//#exec OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound

VAR(Sound) int SoundExplosionType;
VAR sound ExplosionSound;

function Trigger( actor Other, pawn EventInstigator )
{
	Super.Trigger(Other,EventInstigator);
	PlaySound(ExplosionSound,SoundExplosionType);
//	Log("###===>>> Sound'XIIIsound.Explo__GenExplo.GenExplo__hGenExplo'");
}

//		InitialParticlesPerSecond=60.000000



defaultproperties
{
     ExplosionSound=Sound'XIIIsound.Explo__GenExplo.GenExplo__hGenExplo'
     Begin Object Class=SpriteEmitter Name=TrigerredExplosionEmitterA
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(relativetime=0.900000,Color=(G=160,R=180))
         ColorScale(2)=(relativetime=1.000000,Color=(R=180))
         FadeOutFactor=(W=5.000000,X=5.000000,Y=5.000000,Z=5.000000)
         MaxParticles=10
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.500000))
         SizeScale(1)=(relativetime=0.100000,RelativeSize=25.000000)
         SizeScale(2)=(relativetime=1.500000)
         Texture=Texture'XIIICine.effets.Explosion'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=7.000000,Max=7.000000)
         Name="TrigerredExplosionEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.TrigerredExplosionEmitter.TrigerredExplosionEmitterA'
     Begin Object Class=SpriteEmitter Name=TrigerredExplosionEmitterB
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(relativetime=0.900000,Color=(G=160,R=180))
         ColorScale(2)=(relativetime=1.000000,Color=(R=180))
         FadeOutFactor=(W=1.500000,X=1.500000,Y=1.500000,Z=1.500000)
         MaxParticles=10
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.500000))
         SizeScale(1)=(relativetime=0.500000,RelativeSize=25.000000)
         SizeScale(2)=(relativetime=1.500000)
         Texture=Texture'XIIICine.effets.Explosion'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=3.000000)
         Name="TrigerredExplosionEmitterB"
     End Object
     Emitters(1)=SpriteEmitter'XIDCine.TrigerredExplosionEmitter.TrigerredExplosionEmitterB'
     Begin Object Class=SpriteEmitter Name=TrigerredExplosionEmitterC
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         FadeOutStartTime=1.000000
         MaxParticles=1
         StartLocationOffset=(Z=60.000000)
         StartLocationRange=(Z=(Min=100.000000,Max=100.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(1)=(relativetime=0.300000,RelativeSize=1.200000)
         SizeScale(2)=(relativetime=1.000000)
         StartSizeRange=(X=(Min=400.000000,Max=400.000000),Y=(Min=400.000000,Max=400.000000),Z=(Min=400.000000,Max=400.000000))
         InitialParticlesPerSecond=5000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIICine.effets.Baommm'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=1.500000,Max=1.500000)
         Name="TrigerredExplosionEmitterC"
     End Object
     Emitters(2)=SpriteEmitter'XIDCine.TrigerredExplosionEmitter.TrigerredExplosionEmitterC'
     bUnlit=True
     RemoteRole=ROLE_None
}
