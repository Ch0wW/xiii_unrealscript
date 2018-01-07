//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SuperBoost extends MarioSuperBonus;

var Pawn MyPawn;

//__________________________________________________________________________

simulated event Destroyed()
{
    MyPawn.SpeedFactorLimit = 1.0;
    RemoveIconInPlayerHud();
    super.Destroyed();
}

//__________________________________________________________________________

simulated function GiveTo( pawn Other )
{
    Super.GiveTo(other);
    MyPawn = Other;
    MyPawn.SpeedFactorLimit = 2.0;
    AddIconInPlayerHud( Other );
    SetTimer2(15.0,false);
}

//__________________________________________________________________________

event Timer2()
{
    SetTimer2( 0.0,false );
    Destroy();
}

//__________________________________________________________________________




defaultproperties
{
     BonusIconId=32
}
