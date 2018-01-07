//-----------------------------------------------------------
// XIIIExplosiveEmitter
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class XIIIExplosiveEmitter extends Emitter;



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=XIIIExplosiveEmitterA
         Disabled=True
         AutomaticInitialSpawning=False
         Initialized=True
         InitialParticlesPerSecond=60.000000
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         SecondsBeforeInactive=10000.000000
         Name="XIIIExplosiveEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.XIIIExplosiveEmitter.XIIIExplosiveEmitterA'
     Begin Object Class=SpriteEmitter Name=XIIIExplosiveEmitterB
         Disabled=True
         AutomaticInitialSpawning=False
         Initialized=True
         InitialParticlesPerSecond=60.000000
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         SecondsBeforeInactive=10000.000000
         Name="XIIIExplosiveEmitterB"
     End Object
     Emitters(1)=SpriteEmitter'XIDCine.XIIIExplosiveEmitter.XIIIExplosiveEmitterB'
     Begin Object Class=SpriteEmitter Name=XIIIExplosiveEmitterC
         FadeOut=True
         RespawnDeadParticles=False
         Disabled=True
         AutomaticInitialSpawning=False
         Initialized=True
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         InitialParticlesPerSecond=10.000000
         Texture=Texture'XIIICine.effets.Baommm'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         SecondsBeforeInactive=10000.000000
         Name="XIIIExplosiveEmitterC"
     End Object
     Emitters(2)=SpriteEmitter'XIDCine.XIIIExplosiveEmitter.XIIIExplosiveEmitterC'
}
