//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SuperArmor extends MarioSuperBonus;

//__________________________________________________________________________

simulated event Destroyed()
{
    RemoveIconInPlayerHud();
    super.Destroyed();
}

//__________________________________________________________________________

event Timer2()
{
    SetTimer( 0.0,false );
    SetTimer2( 0.0,false );

    Destroy();
}

//__________________________________________________________________________

function Inventory GiveArmor(class<Inventory> ItemClass, Pawn P)
{
  local Inventory NewItem;

  if( P.FindInventoryType(ItemClass)==None )
  {
    NewItem = Spawn(ItemClass,,,P.Location);
    if( NewItem != None )
      NewItem.GiveTo(P);
  }
  else
  {
    NewItem = P.FindInventoryType(ItemClass);

    Armor(NewItem).Charge = 100;
  }
  return NewItem;
}

//__________________________________________________________________________

simulated function GiveTo( pawn Other )
{
    Super.GiveTo(other);

    GiveArmor(class'Casque', Other);
    GiveArmor(class'GiletMk1', Other);
    AddIconInPlayerHud( Other );
    SetTimer2(1.0,false);
}



defaultproperties
{
     BonusIconId=2048
}
