//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ImpactEmitter extends Emitter;

var sound ClientImpactSound;    // sound to play o impact for clients (on-line)

//_____________________________________________________________________________
// Play impact sounds client side
simulated event PostBeginPlay()
{
    if ( Level.NetMode == NM_Client )
    {
//      Log(self@"PostBeginPlay sound"@ClientImpactSound);
      PlaySound(ClientImpactSound, 0);
    }
}

//_____________________________________________________________________________
function NoiseMake(Pawn P, float Amount)
{
    Instigator = P;
    MakeNoise(Amount);
}

defaultproperties
{
     bNetOptional=True
     bTearOff=True
     RemoteRole=ROLE_None
     SaturationDistance=100.000000
     StabilisationDistance=794.000000
}
