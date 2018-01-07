//=============================================================================
// Inventory
//
// Inventory is the parent class of all actors that can be carried by other actors.
// Inventory items are placed in the holding actor's inventory chain, a linked list
// of inventory actors.  Each inventory class knows what pickup can spawn it (its
// PickupClass).  When tossed out (using the DropFrom() function), inventory items
// replace themselves with an actor of their Pickup class.
//
//=============================================================================
class Inventory extends Actor
  abstract
  native
  nativereplication;

#exec Texture Import File=Textures\Inventry.pcx Name=S_Inventory Mips=Off MASKED=1 COMPRESS=DXT1

//_____________________________________________________________________________
var byte InventoryGroup;        // The weapon/inventory set, 0-9.
var byte GroupOffset;           // position within inventory group. (used by prevweapon and nextweapon)
var bool bDisplayableInv;       // Item displayed in HUD.
var bool bTossedOut;            // true if weapon/inventory was tossed out (so players can't cheat w/ weaponstay)
var class<Pickup> PickupClass;  // what class of pickup is associated with this inventory item
var string PickupClassName;     // to dynamicload ref (avoid ref to pickup class so avoid loading all pickups defaults)
var travel int Charge;          // Charge (for example, armor remaining if an armor)
var string PlayerTransferClassName;    // class to give when transfered from enemy to a player (to avoid infinite ammo weapon for player)
var string NonPlayerTransferClassName; // class to give when transfered from plyer to a nonplayer (to give player grenads to bots
var class<Inventory> PlayerTransferClass;    // Class to give when transfered from enemy to a player (to avoid infinite ammo weapon for player)
var class<Inventory> NonPlayerTransferClass; // Class to give when transfered from plyer to a nonplayer (to give player grenads to bots

//_____________________________________________________________________________
// Rendering information.
// Player view rendering info.
var vector PlayerViewOffset;    // Offset from view center.
var float BobDamping;           // how much to damp view bob
// 3rd person mesh.
var actor ThirdPersonActor;     // the third person actor showing this inv on pawn
//var mesh ThirdPersonMesh;
//var staticMesh ThirdPersonStaticMesh;
var float ThirdPersonScale;
var() vector ThirdPersonRelativeLocation;
var() rotator ThirdPersonRelativeRotation;
var class<InventoryAttachment> AttachmentClass; // Attachment class to spawn ThirdPersonActor

//_____________________________________________________________________________
// HUD graphics.
var texture Icon;
//var texture StatusIcon;         // Icon used with ammo/charge/power count on HUD.
var travel string ItemName;     // ELR Added travel because need to memorize names of keys & similar stuff

//_____________________________________________________________________________
// Network replication.
replication
{
  // Things the server should send to the client.
  reliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
    Charge,ThirdPersonActor;
}

//_____________________________________________________________________________
// this function is called when the class if given to enemy as initial inventory (so need to dynamiload everything else except the class)
Static function StaticParseDynamicLoading(LevelInfo MyLI)
{
    Log("Inventory StaticParseDynamicLoading class="$default.class);
    MyLI.ForcedClasses[MyLI.ForcedClasses.Length] = default.class;
    if ( default.PickupClassName != "" )
      MyLI.ForcedClasses[MyLI.ForcedClasses.Length] =
        class(DynamicLoadObject(default.PickupClassName, class'Class'));
    if ( default.PlayerTransferClassName != "" )
      MyLI.ForcedClasses[MyLI.ForcedClasses.Length] =
        class(DynamicLoadObject(default.PlayerTransferClassName, class'Class'));
    if ( default.NonPlayerTransferClassName != "" )
      MyLI.ForcedClasses[MyLI.ForcedClasses.Length] =
        class(DynamicLoadObject(default.NonPlayerTransferClassName, class'Class'));
    if ( default.AttachmentClass != none )
      (default.AttachmentClass).Static.StaticParseDynamicLoading(MyLI);
}

//_____________________________________________________________________________
event ParseDynamicLoading(LevelInfo MyLI)
{
    Log("ParseDynamicLoading Actor="$self);
    if ( default.PickupClassName != "" )
      MyLI.ForcedClasses[MyLI.ForcedClasses.Length] =
        class(DynamicLoadObject(default.PickupClassName, class'Class'));
    if ( default.AttachmentClass != none )
      (default.AttachmentClass).Static.StaticParseDynamicLoading(MyLI);
    if ( default.PlayerTransferClassName != "" )
    {
      MyLI.ForcedClasses[MyLI.ForcedClasses.Length] =
        class(DynamicLoadObject(default.PlayerTransferClassName, class'Class'));
      class<Inventory>(MyLI.ForcedClasses[MyLI.ForcedClasses.Length-1]).Static.StaticParseDynamicLoading(MyLI);
    }
    if ( default.NonPlayerTransferClassName != "" )
    {
      MyLI.ForcedClasses[MyLI.ForcedClasses.Length] =
        class(DynamicLoadObject(default.NonPlayerTransferClassName, class'Class'));
      class<Inventory>(MyLI.ForcedClasses[MyLI.ForcedClasses.Length-1]).Static.StaticParseDynamicLoading(MyLI);
    }
}

//_____________________________________________________________________________
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    if ( (PickupClass == none) && (PickupClassName != "") )
      PickupClass = class<Pickup>(DynamicLoadObject(PickupClassName, class'Class')); // ParseDynMade
}

//_____________________________________________________________________________
// DO NOT SIMULATE else double attachspawn on clients & graphical bug.
function AttachToPawn(Pawn P)
{
    local name BoneName;

    if ( ThirdPersonActor == None )
    {
      ThirdPersonActor = Spawn(AttachmentClass,Owner);
      InventoryAttachment(ThirdPersonActor).InitFor(self);
    }
    BoneName = P.GetWeaponBoneFor(self);
    if ( BoneName == '' )
    {
//      ThirdPersonActor.SetLocation(P.Location);
//      ThirdPersonActor.SetBase(P);
      P.AttachToBone(ThirdPersonActor, 'X R Hand');
    }
    else
      P.AttachToBone(ThirdPersonActor,BoneName);

    ThirdPersonActor.SetRelativeLocation(ThirdPersonRelativeLocation);
    ThirdPersonActor.SetRelativeRotation(ThirdPersonRelativeRotation);
//    LOG("^ ATTACHED"@ThirdPersonActor@"to"@self);
}

//_____________________________________________________________________________
simulated function DetachFromPawn(Pawn P)
{
//    LOG("^ DETACHING"@ThirdPersonActor@"from"@self);
    if ( ThirdPersonActor != None )
    {
      ThirdPersonActor.Destroy();
      ThirdPersonActor = None;
    }
}

//_____________________________________________________________________________
// RenderOverlays() - Draw add. info for first person view of inventory
// the weapon/item first person rendering if made as everything else, using bHidden & Refreshdisplaying
simulated event RenderOverlays( canvas Canvas )
{
/*
  if ( (Instigator == None) || (Instigator.Controller == None))
    return;
  SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
  SetRotation( Instigator.GetViewRotation() );
  Canvas.DrawActor(self, false);
*/
}

//_____________________________________________________________________________
function String GetHumanReadableName()
{
    if ( ItemName == "" )
      ItemName = GetItemName(string(Class));
    return ItemName;
}

//_____________________________________________________________________________
// this function is called once a pawn has been given/announced the item
function PickupFunction(Pawn Other);

//_____________________________________________________________________________
// AI inventory functions.
simulated function Weapon RecommendWeapon( out float rating )
{
    if ( inventory != None )
      return inventory.RecommendWeapon(rating);
    else
    {
      rating = -1;
      return None;
    }
}

//_____________________________________________________________________________
// Called after a travelling inventory item has been accepted into a level.
event TravelPreAccept()
{
    Super.TravelPreAccept();
    GiveTo( Pawn(Owner) );
}

function TravelPostAccept()
{
    Super.TravelPostAccept();
    PickupFunction(Pawn(Owner));
}

// Called by engine when destroyed.
simulated event Destroyed()
{
//  Log("    DESTROY"@self@"Attached="$ThirdPersonActor);
  // Remove from owner's inventory.
  if( Pawn(Owner)!=None )
    Pawn(Owner).DeleteInventory( Self );
  else if ( Instigator != none )
    Instigator.DeleteInventory( Self );
  if ( ThirdPersonActor != None )
    ThirdPersonActor.Destroy();
}

//_____________________________________________________________________________
// Give this inventory item to a pawn.
function GiveTo( pawn Other )
{
    if ( Other.IsPlayerPawn() )
      DebugLog("GIVETO (inventory)"@self@"to"@Other);
    Instigator = Other;
    Other.AddInventory( Self );
    GotoState('');
}

//_____________________________________________________________________________
// Transfer this inventory to Player (for SearchCorpse)
function Transfer( pawn Other )
{
    if ( Other.IsPlayerPawn() )
    {
      DebugLog("TRANSFER (inventory)"@self@"to"@Other);
    }
    if ( Instigator != none )
    {
      DetachFromPawn(Instigator);
      Instigator.DeleteInventory(self);
    }
    GiveTo(Other);
}


//_____________________________________________________________________________
// Function which lets existing items in a pawn's inventory
// prevent the pawn from picking something up. Return true to abort pickup
// or if item handles pickup, otherwise keep going through inventory list.
function bool HandlePickupQuery( pickup Item )
{
   // Log(">> HandlePickupQuery for "$self);
    if ( Item.InventoryType == Class )
      return true;
    if ( Inventory == None )
      return false;

    return Inventory.HandlePickupQuery(Item);
}

//_____________________________________________________________________________
// Select first activatable powerup.
function Powerups SelectNext()
{
    if ( Inventory != None )
      return Inventory.SelectNext();
    else
      return None;
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
    P.Velocity = Velocity;
    Velocity = vect(0,0,0);
}

//_____________________________________________________________________________
function Use( float Value );

//_____________________________________________________________________________
// Find a weapon in inventory that has an Inventory Group matching F.
simulated function Weapon WeaponChange( byte F )
{
    if( Inventory == None)
      return None;
    else
      return Inventory.WeaponChange( F );
}

//_____________________________________________________________________________
// ELR Same as WeaponChange but to be used for SelectWeapon, use new to avoid new bugs
simulated function Weapon WeaponSelect( byte F )
{
    if( Inventory == None)
      return None;
    else
      return Inventory.WeaponSelect( F );
}

//_____________________________________________________________________________
// Find the previous weapon (using the Inventory group)
simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if ( Inventory == None )
      return CurrentChoice;
    else
      return Inventory.PrevWeapon(CurrentChoice,CurrentWeapon);
}

//_____________________________________________________________________________
// Find the next weapon (using the Inventory group)
simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if ( Inventory == None )
      return CurrentChoice;
    else
      return Inventory.NextWeapon(CurrentChoice,CurrentWeapon);
}

//_____________________________________________________________________________
// Find the previous weapon (using the Inventory group)
simulated function PowerUps PrevItem(PowerUps CurrentChoice, PowerUps CurrentItem)
{
    if ( Inventory == None )
      return CurrentChoice;
    else
      return Inventory.PrevItem(CurrentChoice,CurrentItem);
}

//_____________________________________________________________________________
// Find the next weapon (using the Inventory group)
simulated function PowerUps NextItem(PowerUps CurrentChoice, PowerUps CurrentItem)
{
    if ( Inventory == None )
      return CurrentChoice;
    else
      return Inventory.NextItem(CurrentChoice,CurrentItem);
}

/* XIIIUNUSED
//_____________________________________________________________________________
// Used to inform inventory when owner event occurs (for example jumping or weapon change)
function OwnerEvent(name EventName)
{
    if( Inventory != None )
      Inventory.OwnerEvent(EventName);
}
*/

//_____________________________________________________________________________
// used to ask inventory if it needs to affect its owners display properties
function SetOwnerDisplay()
{
    if( Inventory != None )
      Inventory.SetOwnerDisplay();
}

//_____________________________________________________________________________
function NotifyOwnerKilled(controller Killer);

defaultproperties
{
     BobDamping=0.960000
     ThirdPersonScale=1.000000
     AttachmentClass=Class'Engine.InventoryAttachment'
     bHidden=True
     bOnlyOwnerSee=True
     bClientAnim=True
     bAcceptsProjectors=True
     bInteractive=False
     bReplicateMovement=False
     bTravel=True
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_None
     NetPriority=1.400000
}
