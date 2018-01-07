//=============================================================================
// Ammunition: the base class of weapon ammunition
// CHANGENOTE:  All changes to this class since v739 are related to the Weapon code updates.
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================

class Ammunition extends Inventory
    abstract
    native
    nativereplication;

var bool bInstantHit;               // Instant hit ammo (TraceFire)
var bool bPlayHitSound;             // if we should play sound for the next impact.
var bool bDrawTracingBullets;       // Do we draw the 2D effect for tracing bullets
var bool bDisplayNameInHUD;         // this ammo should have it's name in hud
var bool bHandToHand;               // hand to hand ammo
var travel int MaxAmmo;             // Maximum ammo holdable
var travel int AmmoAmount;          // Current amount of Ammo

var class<Projectile> ProjectileClass;    // ProjectileClass to spawn (if not bInstantHit)
var class<DamageType> MyDamageType;       // Damage Type
var float WarnTargetPct;
var float ImpactNoise;              // Noise made by the ammo when hitting something
var float SoftImpactNoise;          // Noise made by the ammo when hitting someone
var int Tracetype;                  // Used to allow Autoaim through objetcs that do have special weapon flags
var int HitSoundType;               // Type of sound vs type of impact
        // 0 = bullet
        // 1 = Fists
        // 2 = CommandoKnife // UNUSED
        // 3 = Bolt/Harpon
        // 4 = Grenade bounce
        // 5 = TKnife
var sound HitSoundMem;              // HitSound
var texture TBTexture;              // texture used if bool above true
var float fTraceFrequency;          // trace frequency if bool above
var float fFireDelay;               // Delay before Fire is effective
var class<ImpactEmitter> ImpactEmitterMem;  // Visual Impact SFX to run when impacting

//_____________________________________________________________________________
// Network replication
replication
{
    // Things the server should send to the client.
    reliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
      AmmoAmount;
}

//_____________________________________________________________________________
Static function StaticParseDynamicLoading(LevelInfo MyLI)
{
    Log("Ammunition StaticParseDynamicLoading class="$default.class);
    Super.StaticParseDynamicLoading(MyLI);
    if ( default.ProjectileClass != none )
      (default.ProjectileClass).Static.StaticParseDynamicLoading(MyLI);
}

//_____________________________________________________________________________
// Toss this item out.
function DropFrom(vector StartLocation)
{
    local Pickup P;

    if ( Instigator != None )
    {
      DetachFromPawn(Instigator);
      Instigator.DeleteInventory(self);
    }
    SetDefaultDisplayProperties();
    Inventory = None;
    Instigator = None;
    StopAnimating();
    GotoState('');

    P = spawn(PickupClass,,,StartLocation);

    if ( P == None )
    {
      destroy();
      return;
    }
    P.InitDroppedPickupFor(self);
    Ammo(P).Ammoamount = AmmoAmount;
    P.Velocity = Velocity;
    Velocity = vect(0,0,0);
}

//_____________________________________________________________________________
// Give this inventory item to a pawn.
function GiveTo( pawn Other )
{
    local ammunition Dual;

    Dual = ammunition(Other.FindInventoryType(class));
    if ( Dual == none )
    {
      Super.GiveTo(other);
      if ( Other.IsPlayerPawn() )
      {
        DebugLog("GIVETO (ammunition)"@self@"to"@Other@"Ammoamount="$AmmoAmount);
      }
    }
    else
    {
      if ( Other.IsPlayerPawn() )
      {
        DebugLog("GIVETO (ammunition)"@self@"to"@Other@"give ammo AmmoAmount="$AmmoAmount@"then Destroy because already owned");
      }
      if ( AmmoAmount > 0 )
        Dual.AddAmmo(AmmoAmount);
//        Dual.AmmoAmount += AmmoAmount;
      else
        Dual.AddAmmo(class<Ammo>(PickupClass).default.AmmoAmount);
//        Dual.AmmoAmount += class<Ammo>(PickupClass).default.AmmoAmount;
      Destroy();
    }
}

//_____________________________________________________________________________
// Transfer this inventory to Player (for SearchCorpse)
function Transfer( pawn Other )
{
    local ammunition Dual;

    if ( Other.IsPlayerPawn() )
    {
      DebugLog("TRANSFER (ammunition)"@self@"to"@Other@"AmmoAmount="$AmmoAmount);
    }
//		DetachFromPawn(Instigator); // no need ammos are not attached
    Instigator.DeleteInventory(self);

    // convert class if needed
    if ( (PlayerTransferClass == none) && (PlayerTransferClassName != "") )
      PlayerTransferClass = class<Inventory>(DynamicLoadObject(PlayerTransferClassName, class'class'));

    if ( class<Ammo>(PickupClass) != none )
      AmmoAmount = fMin(AmmoAmount, class<Ammo>(PickupClass).Default.AmmoAmount);

    if ( (PlayerTransferClass != none) && Other.IsHumanControlled() )
    {
      Dual = ammunition(Spawn(PlayerTransferClass,,,Other.Location));
      Dual.AmmoAmount = AmmoAmount;
      Dual.Transfer(Other);
      Destroy();
      return;
    }

    Dual = ammunition(Other.FindInventoryType(class));
    if ( Dual == none )
    {
      GiveTo(Other);
/*
      if ( (PickupClass != none) && (class<Ammo>(PickupClass) != none) ) // last test to avoid double message for ammos that have weapon as pickup (knives, grenads)
      {
        Other.PlaySound(PickupClass.default.PickupSound);
        Other.ReceiveLocalizedMessage( PickupClass.default.MessageClass, 0, None, None, PickupClass );
      }
*/
    }
    else
    {
//      Log("         (ammunition)"@self@"to"@Other@"give ammo then Destroy because already owned");
      Dual.AddAmmo(AmmoAmount);
/*
      if ( (PickupClass != none) && (class<Ammo>(PickupClass) != none) )
      {
        Other.PlaySound(PickupClass.default.PickupSound);
        Other.ReceiveLocalizedMessage( PickupClass.default.MessageClass, 0, None, None, PickupClass );
      }
*/
      Destroy();
      return;
    }
}

//_____________________________________________________________________________
native function bool HasAmmo();
/*
{
    return ( AmmoAmount > 0 );
}
*/

//_____________________________________________________________________________
function float RateSelf(Pawn Shooter, out name RecommendedFiringMode)
{
    return 0.5;
}

//_____________________________________________________________________________
function WarnTarget(Actor Target,Pawn P,vector FireDir)
{
//    Log("Warntarget call w/ Target="$Target@"Pawn="$P);
    if ( (Pawn(Target) != None) && (Pawn(Target).Controller != None) )
    {
      if ( bInstantHit )
      {
        if (FRand() < WarnTargetPct)
          Pawn(Target).Controller.ReceiveWarning(P, 10000, FireDir);
      }
      else if ( P.PressingFire() )
        Pawn(Target).Controller.ReceiveWarning(P, ProjectileClass.Default.Speed, FireDir);
    }
}

//_____________________________________________________________________________
function SpawnProjectile(vector Start, rotator Dir)
{
    AmmoAmount -= 1;
    Spawn(ProjectileClass,,, Start,Dir);
}

//_____________________________________________________________________________
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    AmmoAmount -= 1;
}

//_____________________________________________________________________________
// ELR to be defined in subclasses, used for weapon w/ multiple shots w/ only one ammo (ShotGun, Hunting Gun)
function ProcessTraceHitNoAmmo(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z);

//_____________________________________________________________________________
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
    Canvas.DrawText("Ammunition "$GetItemName(string(self))$" amount "$AmmoAmount);
    YPos += YL;
    Canvas.SetPos(4,YPos);
}

//_____________________________________________________________________________
function bool HandlePickupQuery( pickup Item )
{
    if ( class == item.InventoryType )
    {
      if (AmmoAmount==MaxAmmo)
        return true;
      item.AnnouncePickup(Pawn(Owner));
      AddAmmo(Ammo(item).AmmoAmount);
      return true;
    }
    if ( Inventory == None )
      return false;

    return Inventory.HandlePickupQuery(Item);
}

//_____________________________________________________________________________
// If we can, add ammo and return true.
// If we are at max ammo, return false
function bool AddAmmo(int AmmoToAdd)
{
    if ( Pawn(Owner).IsPlayerPawn() )
    {
      DebugLog(self@"AddAmmo"@AmmoToAdd);
    }

    If (AmmoAmount >= MaxAmmo)
      return false;
    AmmoAmount = Min(MaxAmmo, AmmoAmount+AmmoToAdd);
    return true;
}

//_____________________________________________________________________________
function PlayImpactSound(Sound S)
{
    if ( !Level.bLonePlayer )
    { // Antibug, remove impact sounds in multiplayer
      bPlayHitSound = false;
      SetUpImpactEmitter(S);
      return;
    }
    if ( HitSoundType >= 0 )
    {
      bPlayHitSound = true;
      HitSoundMem = S;
      SetUpImpactEmitter(S);
    }
}

//_____________________________________________________________________________
function SetUpImpactEmitter(Sound S);

defaultproperties
{
     bInstantHit=True
     MaxAmmo=666
     MyDamageType=Class'Engine.DamageType'
     WarnTargetPct=0.200000
     HitSoundType=-1
}
