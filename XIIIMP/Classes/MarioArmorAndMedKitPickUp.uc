//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MarioArmorAndMedKitPickUp extends MarioPickUp;
/*
auto state Pickup
{
    function bool ValidTouch( actor Other )
    {
      // make sure its a live player
      if ( (Pawn(Other)==none) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).Health <= 0) )
        return false;
      // make sure not touching through wall
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
    function Touch( actor Other )
    {
      local Inventory Copy;

      // If touched by a player pawn, let him pick this up.
      if( ValidTouch(Other) )
      {
        Copy = SpawnCopy(Pawn(Other));
        AnnouncePickup(Pawn(Other));
        //::DBUG::
          //PlayerController(Level.ControllerList).Player.Console.message(self$" After Announce pickup copy is "$copy$" InvItemName="$InvItemName$" ItemName="$copy.ItemName, 14.0);
        Copy.PickupFunction(Pawn(Other));
      }
      // don't allow inventory to pile up (frame rate hit)
      else if ( (Inventory != None) && (Pickup(Other) != none)
        && (Pickup(Other).Inventory != None) )
        Destroy();
    }
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
    {
      Copy = spawn(InventoryType,Other,,,rot(0,0,0));
      Copy.Charge = ProtectionLevel;
    }

    Copy.GiveTo( Other );

    if( Level.Game.ShouldRespawn(self) )
      StartSleeping();
    else
      Destroy();
    return Copy;
}
*/
//_____________________________________________________________________________

function float BotDesireability( pawn Bot )
{
    return MaxDesireability;
}

//_____________________________________________________________________________

function InitItemList()
{
    local MarioMutator MM;
    local int Loop;

    foreach DynamicActors(class'MarioMutator', MM)
    {
        ItemNumber = MM.ArmorAndMedKitNumber;

        for( Loop=0;Loop<ItemNumber;Loop++)
        {
            RandomInventoryType[Loop]=MM.ArmorAndMedKitInventoryType[Loop];
            RandomPickupMessage[Loop]=MM.ArmorAndMedKitPickupMessage[Loop];
            RandomPickupSound[Loop]=MM.ArmorAndMedKitPickupSound[Loop];
        }

        break;
    }

    InitList=true;
}

//_____________________________________________________________________________



defaultproperties
{
     MaxDesireability=1.000000
     RespawnTime=20.000000
     PickupMessage="Defensive Item"
     StaticMesh=StaticMesh'MeshArmesPickup.MultiBoxMedkit'
     DrawScale3D=(X=0.500000,Y=0.500000,Z=0.500000)
     CollisionHeight=34.000000
}
