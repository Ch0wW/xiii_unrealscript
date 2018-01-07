//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Invisibility extends MarioSuperBonus;

var Pawn MyPawn;

//__________________________________________________________________________

simulated event Destroyed()
{
    MyPawn.SetDrawType(DT_Mesh);
    XIIIMPPlayerPawn(MyPawn).bMarioInvisibility=false;

    RemoveIconInPlayerHud();
    super.Destroyed();
}

//__________________________________________________________________________

simulated function GiveTo( pawn Other )
{
    Super.GiveTo(other);
    MyPawn = Other;
    MyPawn.SetDrawType(DT_None);
    XIIIMPPlayerPawn(Other).bMarioInvisibility=true;

    AddIconInPlayerHud( Other );
    SetTimer(0.1,true);
    SetTimer2(15.0,false);
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
     BonusIconId=2
}
