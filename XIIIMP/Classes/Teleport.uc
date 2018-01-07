//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Teleport extends MarioSuperBonus;

var Pawn MyPawn;
var int InitialHealth, SafeHealth;
var bool NoTeleport;

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
    InitialHealth = MyPawn.Health;

    if( InitialHealth < SafeHealth )
         NoTeleport = true;
    else
         NoTeleport = false;

    AddIconInPlayerHud( Other );
    SetTimer(0.1,true);
    SetTimer2(60.0,false);
}

//__________________________________________________________________________

event Timer()
{
    local NavigationPoint Nav;
    local int RandNavId,Index;
    local Array<NavigationPoint> TeleportSpotList;

    if( MyPawn == none )
        return;

    if( MyPawn.Health <= 0 )
        return;

    if( NoTeleport )
    {
        if( InitialHealth != MyPawn.Health )
            NoTeleport = false;
    }

    if( NoTeleport )
        return;

    If( MyPawn.Health < SafeHealth )
    {
        Nav = Level.NavigationPointList;

        while( Nav != none)
        {
            if( Nav.IsA('PlayerStart') )
            {
                TeleportSpotList.Length = TeleportSpotList.Length+1;
                TeleportSpotList[ TeleportSpotList.Length-1 ] = Nav;
            }

            Nav = Nav.NextNavigationPoint;
        }

        SetTimer(0.0,false);
        SetTimer2( 0.0,false );

        Nav = TeleportSpotList[ Rand(TeleportSpotList.Length) ];

        Spawn(class'SpawnEmitter',,, MyPawn.Location);
        MyPawn.SetLocation( Nav.Location );
        Spawn(class'SpawnEmitter',,, MyPawn.Location);
        Destroy();
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
     SafeHealth=100
     BonusIconId=16
}
