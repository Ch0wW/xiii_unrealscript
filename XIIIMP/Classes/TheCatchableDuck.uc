//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TheCatchableDuck extends TheDuck;


//_____________________________________________________________________________

event Bump( Actor Other )
{
    if( Pawn(Other) != none )
    {
        GiveSomething( class'SuperDuck',XIIIPawn(Other));
        XIIIMPDuckController(Controller).gotostate('Catched');

        if( CatchableDuckBotController( Pawn(Other).controller ) != none )
            CatchableDuckBotController( Pawn(Other).controller ).GetTheDuck();
    }

}

//_____________________________________________________________________________

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,vector momentum, class<DamageType> damageType)
{
    XIIIMPDuckController(controller).Damaged(instigatedBy);
    Spawn(class'BlastDuck',,, Location);

    return;
}

//_____________________________________________________________________________

function Inventory GiveSomething(class<Inventory> ItemClass, XIIIPawn P)
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

        if ( Ammunition(NewItem) != none )
            Ammunition(NewItem).AmmoAmount += Class<Ammunition>(ItemClass).default.AmmoAmount;
    }

    return NewItem;
}

//_____________________________________________________________________________



defaultproperties
{
}
