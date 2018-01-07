//=============================================================================
// Ammo.
//=============================================================================
class Ammo extends Pickup
  abstract
  native;

#exec Texture Import File=Textures\Ammo.pcx Name=S_Ammo Mips=Off MASKED=1 COMPRESS=DXT1

var() int AmmoAmount;

//_____________________________________________________________________________
function float BotDesireability(Pawn Bot)
{
    local Ammunition AlreadyHas;

    AlreadyHas = Ammunition(Bot.FindInventoryType(InventoryType));
    if ( AlreadyHas == None )
      return (0.35 * MaxDesireability);
    if ( AlreadyHas.AmmoAmount == 0 )
      return MaxDesireability;
    if (AlreadyHas.AmmoAmount >= AlreadyHas.MaxAmmo)
      return -1;

    return ( MaxDesireability * FMin(1, 0.15 * AmmoAmount/AlreadyHas.AmmoAmount) );
}

//_____________________________________________________________________________
function inventory SpawnCopy( Pawn Other )
{
    local inventory Copy;

    if ( Inventory != None )
    {
      Copy = Inventory;
      Inventory = None;
    }
    else
      Copy = spawn(InventoryType,Other,,,rot(0,0,0));
    Ammunition(Copy).AmmoAmount = AmmoAmount;

    Copy.GiveTo( Other );
    if( Level.Game.ShouldRespawn(self) )
      StartSleeping();
    else
      Destroy();
    return Copy;
}

defaultproperties
{
     MaxDesireability=0.200000
     RespawnTime=30.000000
     PickupMessage="You picked up some ammo."
     Texture=Texture'Engine.S_Ammo'
}
