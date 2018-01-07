//=============================================================================
// Pickup items.
//
// Pickup is the base class of actors that when touched by an appropriate pawn,
// will create and place an Inventory actor in that pawn's inventory chain.  Each
// pickup class has an associated inventory class (its InventoryType).  Pickups are
// placed by level designers.  Pickups can only interact with pawns when in their
// default Pickup state.  Pickups verify that they can give inventory to a pawn by
// calling the GameInfo's PickupQuery() function.  After a pickup spawns an inventory
// item for a pawn, it then queries the GameInfo by calling the GameInfo's
// ShouldRespawn() function about whether it should remain active, enter its Sleep
// state and later become active again, or destroy itself.
//
// When navigation paths are built, each pickup has an InventorySpot (a subclass
// of NavigationPoint) placed on it and associated with it
// (the Pickup's MyMarker== the InventorySpot,
// and the InventorySpot's markedItem == the pickup).
//
//=============================================================================
class Pickup extends Actor
    abstract
    placeable
    native
    nativereplication;

//_____________________________________________________________________________
// AI related info.
var() bool bInstantRespawn;             // Can be tagged so this item respawns instantly.
var bool bOnlyReplicateHidden;          // only replicate changes in bHidden (optimization for level pickups)
var(Display) bool bAmbientGlow;         // Whether to glow or not.
var() float MaxDesireability;           // Maximum desireability this item will ever have.
var InventorySpot MyMarker;             // assigned when rebulding paths w/ bLonePlayer=false
var() class<Inventory> InventoryType;   // Inventory class to spawn when picking up.
var() float RespawnTime;                // Respawn after this time, 0 for instant.
var() localized string PickupMessage;   // Human readable description when picked up.
var() sound PickupSound;
var() sound hRespawnSound;

//_____________________________________________________________________________
simulated function PostBeginPlay()
{
    if ( !Level.bLonePlayer )
      SetDrawScale(1.5); // MULTI, ALL Pickups SCALED UP
    Super.PostBeginPlay();
}

//_____________________________________________________________________________
// Called when picked up on clients/on-line players = called on bHidden replication received
simulated event ClientPickedUp()
{
    if ( Level.NetMode != NM_StandAlone )
    { // on-line only play pickup sound
//      Log(Self@"SND ClientPickedUp"@PickupSound);
      PlaySound(PickupSound);
    }
}

//_____________________________________________________________________________
simulated event ClientRespawned()
{
//    Log("PICKUP SND CLIENTRESPAWN"@hRespawnSound);
    PlaySound(hRespawnSound);
}

//_____________________________________________________________________________
function MatchStarting()
{
    if ( ! Level.bLonePlayer )
    {
        if (MyMarker == none )
           Destroy();
        else
            Reset();
    }
}

//_____________________________________________________________________________
event Destroyed()
{
    if (MyMarker != None )
      MyMarker.markedItem = None;
    if (Inventory != None )
      Inventory.Destroy();
}

//_____________________________________________________________________________
// reset actor to initial state - used when restarting level without reloading.
function Reset()
{
    if ( Inventory != None )
      destroy();
    else
    {
      GotoState('Pickup');
      Super.Reset();
    }
}

//_____________________________________________________________________________
/* Pickups have an AI interface to allow AIControllers, such as bots, to assess the
 desireability of acquiring that pickup.  The BotDesireability() method returns a
 float typically between 0 and 1 describing how valuable the pickup is to the
 AIController.  This method is called when an AIController uses the
 FindPathToBestInventory() navigation intrinsic.
*/
function float BotDesireability( pawn Bot )
{
    local Inventory AlreadyHas;
    local float desire;

    desire = MaxDesireability;

    if ( RespawnTime < 10 )
    {
      AlreadyHas = Bot.FindInventoryType(InventoryType);
      if ( AlreadyHas != None )
      {
        if ( Inventory != None )
        {
          if( Inventory.Charge <= AlreadyHas.Charge )
            return -1;
        }
        else if ( InventoryType.Default.Charge <= AlreadyHas.Charge )
          return -1;
      }
    }
    return desire;
}

//_____________________________________________________________________________
// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
function inventory SpawnCopy( pawn Other )
{
    local inventory Copy;

    if ( Inventory != None )
    {
      Copy = Inventory;
      Inventory = None;
    }
    else
      Copy = spawn(InventoryType,Other,,,rot(0,0,0));

    Copy.GiveTo( Other );
    if( Level.Game.ShouldRespawn(self) )
      StartSleeping();
    else
      Destroy();
    return Copy;
}

//_____________________________________________________________________________
function StartSleeping()
{
    GotoState('Sleeping');
}

//_____________________________________________________________________________
function AnnouncePickup( Pawn Receiver )
{
    Receiver.HandlePickup(self);
    if ( Level.Game.StatLog != None )
      Level.Game.StatLog.LogPickup(self, Receiver);
    SetRespawn();
}

//_____________________________________________________________________________
// Set up respawn waiting if desired.
function SetRespawn()
{
    if( Level.Game.ShouldRespawn(self) )
      GotoState('Sleeping');
    else
      Destroy();
}

//_____________________________________________________________________________
// HUD Messages
static function string GetLocalString( optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2 )
{
     return Default.PickupMessage;
}

//_____________________________________________________________________________
function InitDroppedPickupFor(Inventory Inv)
{
    bOnlyReplicateHidden = false;
    SetPhysics(PHYS_Falling);
    GotoState('');
    Inventory = Inv;
    bAlwaysRelevant = false;
    bMovable = true;
    RefreshDisplaying();
}

//_____________________________________________________________________________
function bool ReadyToPickup(float MaxWait)
{
    return false;
}

//_____________________________________________________________________________
event Landed(Vector HitNormal)
{
    GotoState('Pickup');
}

//_____________________________________________________________________________
// Pickup state: this inventory item is sitting on the ground.
auto state Pickup
{
    function bool ReadyToPickup(float MaxWait)
    {
      return true;
    }

    /* ValidTouch()
    Validate touch (if valid return true to let other pick me up and trigger event).
    */
    function bool ValidTouch( actor Other )
    {
      // make sure its a live player
      if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).Health <= 0) )
        return false;

      // make sure not touching through wall
      // ELR take EyeHeight into account
      if ( !FastTrace(Other.Location+Pawn(Other).EyeHeight*vect(0,0,1), Location) )
        return false;

      // make sure game will let player pick me up
      if( Level.Game.PickupQuery(Pawn(Other), self) )
      {
        TriggerEvent(Event, self, Pawn(Other));
        return true;
      }
      return false;
    }

    // When touched by an actor.
    event Touch( actor Other )
    {
      local Inventory Copy;

      // If touched by a player pawn, let him pick this up.
      if( ValidTouch(Other) )
      {
        Copy = SpawnCopy(Pawn(Other));
        AnnouncePickup(Pawn(Other));
        Copy.PickupFunction(Pawn(Other));
      }
      // don't allow inventory to pile up (frame rate hit)
      else if ( (Inventory != None) && Other.IsA('Pickup')
        && (Pickup(Other).Inventory != None) )
      {
        if ( Level.bLonePlayer )
        {
          // ELR No destroy, push instead
          //Destroy();
          Velocity = normal(Location - Other.Location) * 100 + vect(0,0,50);
          SetPhysics(PHYS_Falling);
        }
        else
          Destroy();
      }
    }

    // Make sure no pawn already touching (while touch was disabled in sleep).
    function CheckTouching()
    {
      local Pawn P;

      ForEach TouchingActors(class'Pawn', P)
        Touch(P);
    }

    function Timer()
    {
      if ( Inventory != None )
      {
        if ( (FRand() < 0.1) || !PlayerCanSeeMe() )
          Destroy();
        else
          SetTimer(3.0, true);
      }
    }

    event BeginState()
    {
      bOnlyReplicateHidden = true;
      if ( Inventory != None )
        SetTimer(20, false);
    }
Begin:
  CheckTouching();
}


//_____________________________________________________________________________
// Sleeping state: Sitting hidden waiting to respawn.
State Sleeping
{
    ignores Touch;

    function bool ReadyToPickup(float MaxWait)
    {
      return (LatentFloat < MaxWait);
    }

    function StartSleeping() {}

    event BeginState()
    {
      bHidden = true;
      ClientPickedUp();
      RefreshDisplaying(); // on clients this is made native in APickup::PostNetReceive() if bOnlyReplicateHidden.
    }
    event EndState()
    {
      bHidden = false;
      RefreshDisplaying(); // on clients this is made native in APickup::PostNetReceive() if bOnlyReplicateHidden.
    }
Begin:
  Sleep( ReSpawnTime );
  Sleep( Level.Game.PlaySpawnEffect(self) );
//  Log("PICKUP SND RESPAWN"@hRespawnSound);
  PlaySound(hRespawnSound);
  GoToState( 'Pickup' );
}

defaultproperties
{
     bOnlyReplicateHidden=True
     MaxDesireability=0.005000
     PickupMessage="Snagged an item."
     bOrientOnSlope=True
     bAlwaysRelevant=True
     bIgnoreDynLight=False
     bMovable=False
     bCollideActors=True
     bCollideWorld=True
     bUseCylinderCollision=True
     bCanSeeThrough=True
     bCanShootThroughWithRayCastingWeapon=True
     bCanShootThroughWithProjectileWeapon=True
     bFixedRotationDir=True
     DrawType=DT_Mesh
     Texture=Texture'Engine.S_Inventory'
     RotationRate=(Yaw=5000)
     DesiredRotation=(Yaw=30000)
     NetPriority=1.400000
     NetUpdateFrequency=8.000000
}
