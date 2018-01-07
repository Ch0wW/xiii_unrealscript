//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPMutator extends Mutator;

CONST DBMutator=false;

//_____________________________________________________________________________
function bool CheckRelevance(Actor Other)
{
    if ( DBMutator ) Log("MUTATOR CheckRelevance for"@Other);
    // ELR Optimiza, dynamic load mesh for weapons at the init
    if (XIIIWeaponPickup(Other) != none)
    {
      DynamicLoadObject(class<XIIIWeapon>(XIIIWeaponPickup(Other).InventoryType).default.MeshName, class'mesh');
    }
    if (XIIIDecoPickup(Other) != none)
    {
      DynamicLoadObject(class<XIIIWeapon>(XIIIDecoPickup(Other).InventoryType).default.MeshName, class'mesh');
    }
    if ( (XIIIPickup(Other) != none) && (class<XIIIItems>(XIIIPickup(Other).InventoryType)!=none) && (class<XIIIItems>(XIIIPickup(Other).InventoryType).default.MeshName!="") )
    {
      DynamicLoadObject(class<XIIIItems>(XIIIPickup(Other).InventoryType).default.MeshName, class'mesh');
    }
    return Super.CheckRelevance(other);
}

//_____________________________________________________________________________
function bool ReplaceWith(actor Other, string aClassName)
{
    local Actor A;
    local class<Actor> aClass;

    if ( DBMutator ) Log("MUTATOR ReplaceWith"@Other@"by"@aClassName);

    if ( Other.IsA('Inventory') && (Other.Location == vect(0,0,0)) )
      return false;

    aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
    if ( aClass != None )
      A = Spawn(aClass,Other.Owner,Other.tag,Other.Location+ (aClass.default.CollisionHeight - Other.default.CollisionHeight) * vect(0,0,1.5), Other.Rotation);

    if ( DBMutator ) Log("        ReplaceWith"@Other@"by spawned"@A);

    if ( Other.IsA('Pickup') )
    {
      if ( Pickup(Other).MyMarker != None )
      {
        Pickup(Other).MyMarker.markedItem = Pickup(A);
        if ( Pickup(A) != None )
        {
          Pickup(A).MyMarker = Pickup(Other).MyMarker;
//          A.SetLocation(A.Location
//            + (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
        }
        Pickup(Other).MyMarker = None;
      }
      else if ( A.IsA('Pickup') )
          Pickup(A).Respawntime = 0.0;
    }
    if ( A != None )
    {
      A.event = Other.event;
      A.tag = Other.tag;
      Other.Destroy();
      return true;
    }
    return false;
}



defaultproperties
{
     DefaultWeaponName="XIIIMP.BerettaMulti"
}
