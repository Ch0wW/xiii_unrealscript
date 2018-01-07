//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WeaponAttachment extends InventoryAttachment
  native
  nativereplication;

var bool DBOnline;

var byte FlashCount;        // when incremented, draw muzzle flash for current frame
var byte AltFlashCount;     // when incremented, draw muzzle flash for current frame
var byte ReloadClientCount; // when incremented, draw muzzle flash for current frame
var name FiringMode;        // replicated to identify what type of firing/reload animations to play
var name AltFiringMode;     // replicated to identify what type of firing/reload animations to play

// ::TODO:: get rid of this var, XIIIUNUSED
var float FiringSpeed;    // used by human animations to determine the appropriate speed to play firing animations
var int iBTrailDist;    // Used to avoid (the most) bullet trails going through objects

var sound hFireSound;
var sound hAltFireSound;
var sound hReloadSound;

// FIXME - should firingmode be compressed to byte?
//_____________________________________________________________________________
replication
{
    // Things the server should send to the client.
    reliable if( bNetDirty && !bNetOwner && (Role==ROLE_Authority) )
      FlashCount, FiringMode, AltFlashCount, AltFiringMode, ReloadClientCount;
}

//_____________________________________________________________________________
//ThirdPersonEffects called by Pawn's C++ tick if FlashCount incremented becomes true
// OR called locally for local player
simulated event ThirdPersonEffects()
{
    // spawn 3rd person effects
    if ( Instigator != None )
    {
      // have pawn play firing anim
      Instigator.PlayFiring(1.0,FiringMode);
      // Play firing sounds for clients
//      if ( (Level.NetMode == NM_Client) && !Instigator.IsLocallyControlled() )
      if ( !Instigator.IsLocallyControlled() && (Level.NetMode != NM_StandAlone) )
        Instigator.PlayRolloffSound(hFireSound, self, 0, 0, 0 );
    }
}

//_____________________________________________________________________________
//ThirdPersonEffects called by Pawn's C++ tick if AltFlashCount incremented becomes true
// OR called locally for local player
simulated event ThirdPersonAltEffects()
{
    // spawn 3rd person effects
    if ( Instigator != None )
    {
      // have pawn play Altfiring anim
      Instigator.PlayFiring(1.0,AltFiringMode);
      // Play altfiring sounds for clients
//      if ( (Level.NetMode == NM_Client) && !Instigator.IsLocallyControlled() )
      if ( !Instigator.IsLocallyControlled() && (Level.NetMode != NM_StandAlone) )
        Instigator.PlayRolloffSound(hAltFireSound, self, 0, 0, 0 );
    }
}

//_____________________________________________________________________________
simulated event ThirdPersonReLoad()
{
    // spawn 3rd person effects
    if ( DBOnline ) Log("WATTACH ThirdPersonReLoad call for "$self@"hReloadSound="$hReloadSound);
    if ( Instigator != None )
    {
      // have pawn play reloading anim
      Instigator.PlayReLoading(1.0, FiringMode);
      // play reloading sound for clients
//      if ( (Level.NetMode == NM_Client) && !Instigator.IsLocallyControlled() )
      if ( !Instigator.IsLocallyControlled() && (Level.NetMode != NM_StandAlone) )
        Instigator.PlayRolloffSound(hReloadSound, self, 0, 2, 0 );
    }
}

defaultproperties
{
     SaturationDistance=800.000000
     StabilisationDistance=2500.000000
}
