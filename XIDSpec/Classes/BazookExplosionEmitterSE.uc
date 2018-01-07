//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BazookExplosionEmitterSE extends Emitter;

event PostBeginPlay()
{
    Spawn(class'BazookExplosionOverlayEmitter',self,, location, Rotation);
}


