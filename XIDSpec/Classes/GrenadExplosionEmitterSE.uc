//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GrenadExplosionEmitterSE extends Emitter;

event PostBeginPlay()
{
    Spawn(class'GrenadExplosionOverlayEmitter',self,, location, Rotation);
}


