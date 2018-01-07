//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HeadBloodTrailEmitterSE extends Emitter;

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    if ( !Level.bHighDetailMode )
      Emitters[0].UseCollision = false;
    if ( (Level.Game != none) && (XIIIGameInfo(Level.Game).PlateForme == 1) ) // PS2
    {
      Emitters[0].UseCollision = false;
      Emitters[0].SetMaxParticles(25);
    }
}


