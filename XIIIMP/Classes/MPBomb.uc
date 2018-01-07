//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MPBomb extends XIIIWeapon;

var bool bPendingEnded;           // to not thrown before ending the pendingfire anim
var bool bUnFired;                // to not thrown before ending the pendingfire anim
var float ProjectileLifeTime;     // to make the projectile live less if hold a long time (GD request)

const DBGren=false;
const ACTIVATEDELAY=12.0;  // amount of time needed to prepare bomb & drop it
CONST BLOWDELAY=4.0;      // delay once prepared before blowing

var XIIIMPBombPick PickupSource;  // To allow respawn of bomb once used
var MPBombingBase ActiveBombBase;
var sound sndBombIsActived, sndBomdDesactived, sndBomdClick;

//_____________________________________________________________________________
replication
{
    Reliable if( Role<ROLE_Authority )
      ServerSetProjectileLifeTime, /*ServerResetPickupSource, */ServerBombFire, ServerBombUnFire;
}

/*
//_____________________________________________________________________________
function ServerResetPickupSource()
{
    // A Bomb should be made to respawn there
    //log( "BOMBING-]"@self@"ServerResetPickupSource "@PickupSource);
    PickupSource.GotoState('DelayBeforePickable');
//    LifeSpan = 5.0;
//    destroy();
}
*/

function ServerRespawnPickupSource() //Respawn BOMB if owner is disconnected
{
    // A Bomb should be made to respawn there
    //log( "BOMBING-]"@self@"ServerRespawnPickupSource "@PickupSource);
//    log("--- Pickup ServerRespawnPickupSource ---");
    PickupSource.GotoState('Pickup');
}

//_____________________________________________________________________________
event Destroyed()      //if owner disconnected
{
	ServerBombUnFire(0);
	ServerRespawnPickupSource();
	Super.Destroyed();
}

//_____________________________________________________________________________
function bool HandlePickupQuery( Pickup Item )
{
    local int OldAmmo, NewAmmo;
    local Pawn P;

//    Log("HandlePickupQuery"@Item@"for"@self);

    if (Item.InventoryType == Class)
    {
      if ( WeaponPickup(item).bWeaponStay && ((item.inventory == None) || item.inventory.bTossedOut) )
        return true;
      P = Pawn(Owner);
      if ( AmmoType != None )
      {
        OldAmmo = AmmoType.AmmoAmount;
        if ( Item.Inventory != None )
          NewAmmo = Weapon(Item.Inventory).PickupAmmoCount;
        else
          NewAmmo = class<Weapon>(Item.InventoryType).Default.PickupAmmoCount;
        if ( AmmoType.AddAmmo(NewAmmo) && (OldAmmo == 0)
          && (P.Weapon.class != item.InventoryType) )
          ClientWeaponSet(true);
      }
      Item.AnnouncePickup(Pawn(Owner));
      return true;
    }
    if ( Inventory == None )
      return false;

    return Inventory.HandlePickupQuery(Item);
}

//_____________________________________________________________________________
function ServerBombUnFire( float value )
{
//    Log("ServerBomb-Un-Fire");
    if( ActiveBombBase != none )
    {
      ActiveBombBase.BombTime = -1;
      Owner.PlayMenu(sndBomdClick);
    }
}

//_____________________________________________________________________________
function ServerBombFire()
{
    local int TouchingBombBase;

//    Log("ServerBomb-Fire");
    foreach Pawn(Owner).TouchingActors(class'MPBombingBase', ActiveBombBase)
    {
      ActiveBombBase.BombTime = Level.TimeSeconds;
      ActiveBombBase.BombingCount ++;
      break;
    }
}

//_____________________________________________________________________________
simulated function Fire(float value)
{
    local int TouchingBombBase;
    local SabotageBotController Bot;

      foreach Pawn(Owner).TouchingActors(class'MPBombingBase', ActiveBombBase)
      {
        TouchingBombBase++;
        break;
      }
      if( TouchingBombBase == 0 )
        return;

      if( ActiveBombBase.CurrentTeam == 0 )
        return;


    if( Level.NetMode == NM_Standalone )
    {
      ActiveBombBase.BombTime = Level.TimeSeconds;
    }
    else
      ServerBombFire();

    Owner.PlayMenu(sndBomdClick);

    if( Level.NetMode == NM_Standalone )
    {
      foreach DynamicActors(class'SabotageBotController', BOT)
      {
        BOT.BombIsActivated(ActiveBombBase);
      }
    }

    if ( DBGren ) Log(">>> Fire call for "$self$" in state "$GetStateName());
    bUnFired = false;
    bPendingEnded = false;
    ProjectileLifeTime = Level.TimeSeconds + ACTIVATEDELAY;
    if ( DBGren ) Log("  > Calling ServerSetProjectileLifeTime from Fire");
    ServerSetProjectileLifeTime();
    SetTimer(ACTIVATEDELAY, false);
    GotoState('PendingFire');
}

//_____________________________________________________________________________
// Replicate to server because projectiles spawned need their life time
function ServerSetProjectileLifeTime()
{
    if ( DBGren ) Log(">>> ServerSetProjectileLifeTime call");
    ProjectileLifeTime = Level.TimeSeconds + ACTIVATEDELAY;
}

//_____________________________________________________________________________
simulated function UnFire( float value )
{
    if ( DBGren ) Log(">>> Global UnFire call for "$self$" in state "$GetStateName());
    bUnFired = true;
}

//_____________________________________________________________________________
// Server
state NormalFire
{
    function Timer()
    {
      local Vector Start, X,Y,Z;

      if ( !AmmoType.bInstantHit )
      {
        MakeNoise(FireNoise);
        GetAxes(Instigator.GetViewRotation(),X,Y,Z);
        Start = GetFireStart(X,Y,Z);
        AdjustedAim = Instigator.AdjustAim(AmmoType, Start, 0);
//        if ( (Default.ReloadCount != 0) && (ReLoadCount > 0) || ((Default.ReloadCount == 0) && HasAmmo()) )
          FeedBack();
        AmmoType.SpawnProjectile(Start,AdjustedAim);
        LifeSpan = 1.0;
//        Destroy();
      }
      else
      {
        RealTraceFire(fVarAccuracy,0,0);
      }
    }
}
//_____________________________________________________________________________
state PendingFire
{
    simulated event BeginState()
    {
      if ( DBGren )
        Log(">>> ClientPendingFire BeginState for "$self$" in state "$GetStateName());
      PlayBeginArming();
      SetTimer2( 0.5, true );
    }

    simulated event Timer2()
    {
      local int TouchingBombBase;
      local SabotageBotController Bot;
      local MPBombingBase TmpBombBase;

      if ( bChangeWeapon )
      {
        UnFire(0);
        GotoState('DownWeapon');
        return;
      }

      foreach Pawn(Owner).TouchingActors(class'MPBombingBase', TmpBombBase)
      {
        TouchingBombBase++;
        break;
      }

      if( TouchingBombBase == 0 )
      {
        SetTimer2( 0.0, false );
        UnFire( 0 );
      }
    }

    simulated function Fire(float F) {}
    simulated function AltFire(float F) {}
    simulated function UnFire( float value )
    {
      if ( DBGren )
        Log(">>> ClientPendingFire UnFire for "$self$" in state "$GetStateName());

      if( Level.NetMode == NM_Standalone )
      {
        if ( (value>0) || (ProjectileLifeTime - Level.TimeSeconds <= 0.0) )
        { // the bomb is armed, drop it
          ProjectileLifeTime = Level.TimeSeconds + BLOWDELAY;
          if ( DBGren ) Log("  > Calling ServerSetProjectileLifeTime from UnFire");
          ServerSetProjectileLifeTime();
          Instigator.controller.bFire = 1;
          Super(XIIIWeapon).Fire(0);
          Instigator.controller.bFire = 0;
//          ServerResetPickupSource();
        }
        else
        { // bomb not armed, return to wait state
          if( ActiveBombBase != none )
          {
            ActiveBombBase.BombTime = -1;
            Owner.PlayMenu(sndBomdClick);
          }
          GotoState('Idle');
        }
      }
      else
      {
        if ( (value>0) || (ProjectileLifeTime - Level.TimeSeconds <= 0.0) )
        { // the bomb is armed, drop it
          ProjectileLifeTime = Level.TimeSeconds + BLOWDELAY;
          if ( DBGren ) Log("  > Calling ServerSetProjectileLifeTime from UnFire");
          ServerSetProjectileLifeTime();
          Instigator.controller.bFire = 1;
          Super(XIIIWeapon).Fire(0);
          Instigator.controller.bFire = 0;
//          ServerResetPickupSource();
        }
        else
        { // bomb not armed, return to wait state
          Owner.PlayMenu(sndBomdClick);
          ServerBombUnFire(value);

          GotoState('Idle');
        }
      }
    }
    //_____________________________________________________________________________
    // ELR Text to be displayed in HUD
    simulated function string GetAmmoText(out int bDrawbulletIcon)
    {
      local string AmmoText,AltAmmoText;
      local int iSec, iMillisec;
      local string sT;

      iSec = ProjectileLifeTime - Level.TimeSeconds;
      iMilliSec = (ProjectileLifeTime*10.0 - Level.TimeSeconds*10.0 - iSec*10.0);
      sT = iSec$":"$iMilliSec$"0";

      bDrawbulletIcon = 1;

      AmmoText = "["$sT$"]"@string(Ammotype.AmmoAmount);
      return AmmoText;
    }
    Simulated Event Timer()
    { // Force player to throw gren & make himself blow up
      UnFire(1.0);
    }
}

//_____________________________________________________________________________
simulated function PlayIdleAnim()
{
    PlayAnim('Wait', 1.0, 0.3);
}

//_____________________________________________________________________________
simulated function TweenDown()
{
    if ( HasAmmo() )
      PlayAnim('Down', 1.0);
    else
      AnimEnd(0);
}

//_____________________________________________________________________________
simulated function PlayBeginArming()
{
    PlayAnim('Wait', 1.0);
    PlayPendingFiringSound();
}

//_____________________________________________________________________________
simulated function PlayPendingFiringSound()
{
    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone) )
    {
      if ( bEmptyShot )
        Instigator.PlayRolloffSound(hNoAmmoSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 3 );
      else
      {
        if ( HasSilencer() )
          Instigator.PlayRolloffSound(hFireSound, self, 1, int(Pawn(Owner).IsPlayerPawn()), 3 );
        else
          Instigator.PlayRolloffSound(hFireSound, self, 0, int(Pawn(Owner).IsPlayerPawn()), 3 );
      }
    }
}



defaultproperties
{
     sndBombIsActived=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hBomBing'
     sndBomdDesactived=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hBombOut'
     sndBomdClick=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hBombClick'
     bAllowEmptyShot=False
     WHand=WHA_2HShot
     WeaponMode=WM_SemiAuto
     AmmoName=Class'XIIIMP.MPBombAmmo'
     PickupAmmoCount=1
     MeshName="XIIIArmes.fpsBombeMagnetM"
     FireOffset=(Y=5.000000,Z=-2.000000)
     CrossHair=Texture'XIIIMenu.HUD.MireCouteau'
     ShotTime=2.000000
     FiringMode="FM_Throw"
     FireNoise=0.000000
     AIRating=-2.000000
     TraceDist=0.000000
     hFireSound=Sound'XIIIsound.Guns__GrenFire.GrenFire__hGrenFire'
     hSelectWeaponSound=Sound'XIIIsound.Guns__GrenSelWp.GrenSelWp__hGrenSelWp'
     InventoryGroup=24
     PickupClassName="XIIIMP.XIIIMPBombPick"
     PlayerViewOffset=(X=5.000000,Y=4.000000,Z=-4.200000)
     ThirdPersonRelativeLocation=(X=7.000000,Y=-5.000000,Z=2.000000)
     ThirdPersonRelativeRotation=(Yaw=16384)
     AttachmentClass=Class'XIIIMP.MPBombAttach'
     Icon=Texture'XIIIMenu.HUD.BombemagnetIcon'
     ItemName="BOMB"
     DrawScale=0.300000
}
