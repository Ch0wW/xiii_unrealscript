//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FlashBang extends XIIIWeapon;

var bool bPendingEnded;         // to not thrown before ending the pendingfire anim
var bool bUnFired;              // to not thrown before ending the pendingfire anim
var float ProjectileLifeTime;   // to make the projectile live less if hold a long time (GD request)
var sound hStopFireSound;       // To stop tic-tac sound if killed before throwing

CONST DBGren=false;

//_____________________________________________________________________________
replication
{
    Reliable if( Role<ROLE_Authority )
      ServerSetProjectileLifeTime;
}

//_____________________________________________________________________________
// FRD
function float RateSelf()
{
    local float distance;
    local vector PositionRelative;

    if ( !HasAmmo() )
      return -2;
    if (instigator.controller.enemy!=none)
    {
      PositionRelative=instigator.controller.enemy.location-instigator.location;
      distance=Vsize(PositionRelative);
      if (distance>1170)
        return 0.23;
      else if (distance<500)
        return 0.25;
      if (PositionRelative.z>400) // enemy au dessus donc pas prendre
        return (AIRating-2);
     }
     return AIRating;
}

//_____________________________________________________________________________
simulated function Fire(float value)
{
    if ( DBGren ) Log(">>> Fire call for "$self$" in state "$GetStateName());
    bUnFired = false;
    bPendingEnded = false;
    ProjectileLifeTime = Level.TimeSeconds + 5.0;
    if ( DBGren ) Log("  > Calling ServerSetProjectileLifeTime from Fire");
    ServerSetProjectileLifeTime();
    SetTimer(5.0, false);
    GotoState('PendingFire');
}

//_____________________________________________________________________________
// Replicate to server because projectiles spawned need their life time
function ServerSetProjectileLifeTime()
{
    if ( DBGren ) Log(">>> ServerSetProjectileLifeTime call");
    ProjectileLifeTime = Level.TimeSeconds + 5.0;
}

//_____________________________________________________________________________
simulated function UnFire( float value )
{
    if ( DBGren ) Log(">>> Global UnFire call for "$self$" in state "$GetStateName());
    bUnFired = true;
}

//_____________________________________________________________________________
state PendingFire
{
    simulated event BeginState()
    {
      if ( DBGren ) Log(">>> ClientPendingFire BeginState for "$self$" in state "$GetStateName());
      PlayThrowPrep();
    }
    simulated function Fire(float F) {}
    simulated function AltFire(float F) {}
    simulated function UnFire( float value )
    {
      if ( DBGren ) Log(">>> ClientPendingFire UnFire for "$self$" in state "$GetStateName());
      Global.UnFire(value);
      if ( bPendingEnded )
      {
        Instigator.controller.bFire = 1;
        Super(XIIIWeapon).Fire(0);
        Instigator.controller.bFire = 0;
        bUnFired = false;
        bPendingEnded = false;
      }
    }
    simulated function bool PutDown()
    {
      UnFire(0);
      if ( Instigator.PendingWeapon != none )
        bChangeWeapon = true;
      return True;
    }
    simulated event AnimEnd(int channel)
    {
      if ( DBGren ) Log(">>> ClientPendingFire AnimEnd for "$self$" in state "$GetStateName());
      bPendingEnded = true;
      if ( bUnFired )
      {
        Instigator.controller.bFire = 1;
        Super(XIIIWeapon).Fire(0);
        Instigator.controller.bFire = 0;
        bUnFired = false;
        bPendingEnded = false;
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

      if( iSec < 0 ) iSec = 0;
      if( iMilliSec < 0 ) iMilliSec = 0;

      sT = iSec$":"$iMilliSec$"0";

      bDrawbulletIcon = 1;

      AmmoText = "["$sT$"]"@string(Ammotype.AmmoAmount);
      return AmmoText;
    }
/*
    simulated event Tick(float dT)
    {

      Log("dif="$(ProjectileLifeTime - Level.TimeSeconds)$" >>"$sT);
      XIIIBaseHUD(Playercontroller(Pawn(Owner).Controller).MyHud).AddChronoDisplay(sT, 0.1);
    }
*/
    Simulated Event Timer()
    { // Force player to throw gren & make himself blow up
      UnFire(0);
    }
}

//_____________________________________________________________________________
simulated function PlayIdleAnim()
{
    if ( HasAmmo() )
      PlayAnim('Wait', 1.0, 0.3);
    else
      PlayAnim('WaitVide', 1.0, 0.3);
}

//_____________________________________________________________________________
simulated function TweenDown()
{
    if ( HasAmmo() )
      PlayAnim('Down', 1.0);
    else
      PlayAnim('DownVide', 1.0);
}

//_____________________________________________________________________________
simulated function PlayThrowPrep()
{
    PlayAnim('PendingFire', 1.0);
    PlayPendingFiringSound();
}

//_____________________________________________________________________________
simulated function PlayFiring()
{
//    if ( HasAmmo() ) // ELR Can't use HasAmmo as the ammo will be used after
    if ( AmmoType.Ammoamount > 1 )
      PlayAnim(LoadedFiringAnim, 1.0);
    else
      PlayAnim(EmptyFiringAnim, 1.0);

    if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone) )
      PlayFiringSound();

    if ( !HasAmmo() )
      return;

    IncrementFlashCount();
    if ( bDrawMuzzleflash )
      SetUpMuzzleFlash();
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

//_____________________________________________________________________________
simulated function NotifyOwnerKilled(controller Killer)
{
    Super.NotifyOwnerKilled(Killer);
    if ( Level.NetMode == NM_StandAlone )
    {
//      Log("GRENAD NotifyOwnerKilled should drop grenad");
      bPendingEnded = true;
      UnFire(2.0);
    }
    else
    {
//      Log("GRENAD NotifyOwnerKilled should stop sound instigator="$instigator);
      if ( Instigator.IsLocallyControlled() || (Level.NetMode == NM_StandAlone) )
        Instigator.PlayRolloffSound(hStopFireSound, self);
      gotoState('');
    }
}

//    Icon=texture'XIIIMenu.FlashbIcon'


defaultproperties
{
     hStopFireSound=Sound'XIIIsound.Guns__GrenFire.GrenFire__hGrenStop'
     bAllowEmptyShot=False
     WHand=WHA_2HShot
     WeaponMode=WM_SemiAuto
     AmmoName=Class'XIIIMP.FlashBangAmmo'
     PickupAmmoCount=1
     MeshName="XIIIArmes.FpsFlashBangM"
     FireOffset=(Y=5.000000,Z=-2.000000)
     CrossHair=Texture'XIIIMenu.HUD.MireCouteau'
     ShotTime=2.000000
     FiringMode="FM_Throw"
     FireNoise=0.000000
     AIRating=0.450000
     TraceDist=0.000000
     hFireSound=Sound'XIIIsound.Guns__GrenFire.GrenFire__hGrenFire'
     hSelectWeaponSound=Sound'XIIIsound.Guns__GrenSelWp.GrenSelWp__hGrenSelWp'
     InventoryGroup=17
     PickupClassName="XIIIMP.FlashBangPick"
     NonPlayerTransferClass=Class'XIIIMP.FlashBangBot'
     PlayerViewOffset=(X=5.000000,Y=4.000000,Z=-4.200000)
     ThirdPersonRelativeLocation=(X=7.000000,Y=-5.000000,Z=2.000000)
     ThirdPersonRelativeRotation=(Yaw=16384)
     AttachmentClass=Class'XIIIMP.FlashBangAttach'
     ItemName="FLASHBANG"
     DrawScale=0.300000
}
