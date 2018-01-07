class ArmorPickup extends Pickup
  abstract;

var() int ProtectionLevel;

//_____________________________________________________________________________
event ParseDynamicLoading(LevelInfo MyLI)
{
    Log("ParseDynamicLoading Actor="$self);
    class<Armor>(default.InventoryType).Static.StaticParseDynamicLoading(MyLI);
//    MyLI.ForcedMeshes[MyLI.ForcedMeshes.Length] = mesh(DynamicLoadObject(class<Weapon>(default.InventoryType).default.MeshName, class'mesh'));
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
      // ELR Added this to make each armor type unique in inventory (not giletMk1 & Mk2)
      Copy.Charge = ProtectionLevel;
    }

    Copy.GiveTo( Other );

    if( Level.Game.ShouldRespawn(self) )
      StartSleeping();
    else
      Destroy();
    return Copy;
}

//_____________________________________________________________________________
function float BotDesireability( pawn Bot )
{
    local Inventory AlreadyHas;
    local Armor AlreadyHasArmor;
    local float desire;
    local bool bChecked;

    desire = MaxDesireability;

    if ( RespawnTime < 10 )
    {
      bChecked = true;
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

    if ( !bChecked )
      AlreadyHasArmor = Armor(Bot.FindInventoryType(InventoryType));
    if ( AlreadyHasArmor != None )
      desire *= (1 - AlreadyHasArmor.Charge * AlreadyHasArmor.ArmorAbsorption * 0.00003);

    if ( Armor(Inventory) != None )
    {
      // pointing to specific, existing item
      desire *= (Inventory.Charge * 0.005);
      desire *= (Armor(Inventory).ArmorAbsorption * 0.01);
    }
    else
    {
      desire *= (InventoryType.default.Charge * 0.005);
      desire *= (class<Armor>(InventoryType).default.ArmorAbsorption * 0.01);
    }
    return desire;
}

defaultproperties
{
     CollisionHeight=20.000000
}
