//-----------------------------------------------------------
//
//-----------------------------------------------------------
class LoseArmor extends MarioSuperBonus;

var Pawn MyPawn;

simulated event Destroyed()
{
    RemoveIconInPlayerHud();
    super.Destroyed();
}

//__________________________________________________________________________

function RemoveArmor(class<Inventory> ItemClass, Pawn P)
{
    local Inventory NewItem;

    if( P.FindInventoryType(ItemClass)!=None )
    {
        NewItem = P.FindInventoryType(ItemClass);

        if( NewItem != none )
        {
            if( Armor(NewItem).Charge > 20 )
            {
//                log("--- REMOVE ARMOR ---");
                Armor(NewItem).Charge -= 5;

                if( Armor(NewItem).Charge < 20 )
                    Armor(NewItem).Charge = 20;
            }
        }
    }
}

//__________________________________________________________________________

simulated function GiveTo( pawn Other )
{
    Super.GiveTo(other);
    MyPawn = Other;
    AddIconInPlayerHud( Other );
    SetTimer(1.0,true);
    SetTimer2(20.0,false);
}

//__________________________________________________________________________

event Timer()
{
    RemoveArmor(class'Casque', MyPawn);
    RemoveArmor(class'GiletMk1', MyPawn);
}

//__________________________________________________________________________

event Timer2()
{
    SetTimer( 0.0,false );
    SetTimer2( 0.0,false );

    Destroy();
}

//__________________________________________________________________________



defaultproperties
{
     BonusIconId=64
}
