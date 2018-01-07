//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SuperDamage extends MarioSuperBonus;

var Pawn MyPawn;
var float DamageFactor;

//__________________________________________________________________________

simulated event Destroyed()
{
    ModifyDamage_Down();
    RemoveIconInPlayerHud();
    super.Destroyed();
}

//__________________________________________________________________________

function ModifyDamage_Down()
{
    XIIIMPPlayerPawn(MyPawn).SuperDamageFactor = 1.0;
}

//__________________________________________________________________________

function ModifyDamage_Up()
{
    XIIIMPPlayerPawn(MyPawn).SuperDamageFactor = DamageFactor;
}

//__________________________________________________________________________

simulated function GiveTo( pawn Other )
{
    Super.GiveTo(other);
    MyPawn = Other;
    ModifyDamage_Up();

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
     DamageFactor=2.000000
     BonusIconId=4
}
