//-----------------------------------------------------------
//
//-----------------------------------------------------------
class LoseLife extends MarioSuperBonus;

var Pawn MyPawn;

simulated event Destroyed()
{
    RemoveIconInPlayerHud();
    super.Destroyed();
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
    if( MyPawn.Health > 50 )
    {
       MyPawn.Health -= 12.5;

       if( MyPawn.Health < 50 )
           MyPawn.Health = 50;
    }
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
     BonusIconId=128
}
