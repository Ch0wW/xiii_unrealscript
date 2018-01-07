//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Regeneration extends MarioSuperBonus;

var Pawn MyPawn;
var sound SoundLoop;


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
    SetTimer(0.1,true);
    SetTimer2(15.0,false);
}

//__________________________________________________________________________

event Timer()
{
    MyPawn.Health += 2.5;

    if( MyPawn.Health > MyPawn.default.Health )
       MyPawn.Health = MyPawn.default.Health;
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
     BonusIconId=8
}
