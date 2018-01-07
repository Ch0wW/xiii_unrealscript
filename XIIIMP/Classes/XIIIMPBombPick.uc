//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPBombPick extends WeaponPickup;

state DelayBeforePickable
{

event beginstate()
{
	  SetDrawType(DT_None);
}
event endstate()
{
      SetDrawType(DT_StaticMesh);
}
begin:
      Sleep( 10.0 );

      GotoState('Pickup');
}

//_____________________________________________________________________________

function GiveHarnaisBomb( XIIIPawn P)
{
    local Inventory NewItem;

    if( P.FindInventoryType(Class'XIIIMP.HarnaisBomb')==None )
    {
        NewItem = Spawn(Class'XIIIMP.HarnaisBomb',,,P.Location);

        if( NewItem != None )
            NewItem.GiveTo(P);
    }
}

//_____________________________________________________________________________

// for this game the bomb pickup respawn only when the previous one is destroyed/used.
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
    if ( Copy == none ) // then the player could already have this type in inventory
      Copy = Other.FindInventoryType(InventoryType);
    MPBomb(Copy).PickupSource = self;
    //log( "BOMBING-] Setting PickupSource="@self@"for"@copy);
    StartSleeping();
    return Copy;
}

//_____________________________________________________________________________

auto state Pickup
{
    function bool ValidTouch( actor Other )
    {
      // make sure its a live player
      if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).Health <= 0) )
        return false;

      // Only  players on team 0 (Attackers) can pickup the bomb

      if ( Pawn(Other).PlayerReplicationInfo.Team.TeamIndex != 0 )
        return false;

      // make sure not touching through wall
      // ELR take EyeHeight into account
      if ( !FastTrace(Other.Location+Pawn(Other).EyeHeight*vect(0,0,1), Location) )
        return false;

      GiveHarnaisBomb( XIIIPawn(Other) );

      // make sure game will let player pick me up
      if( Level.Game.PickupQuery(Pawn(Other), self) )
      {
         TriggerEvent(Event, self, Pawn(Other));
        return true;
      }

      return false;
    }
}

//_____________________________________________________________________________

function SetRespawn()
{
    GotoState('Sleeping');
}

//_____________________________________________________________________________



defaultproperties
{
     InventoryType=Class'XIIIMP.MPBomb'
     RespawnTime=60000.000000
     PickupMessage="Bomb"
     PickupSound=Sound'XIIIsound.Items.PassPick1'
     hRespawnSound=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hRespawnGun'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'MeshArmesPickup.bombemagnet'
     DrawScale3D=(X=2.000000,Y=2.000000,Z=2.000000)
}
