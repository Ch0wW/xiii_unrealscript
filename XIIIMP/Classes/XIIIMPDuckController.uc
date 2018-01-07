//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPDuckController extends AIController;

#exec OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound

var float MoveSpeed,FastMoveSpeed, SlowMoveSpeed, BoostMoveSpeed;
var Array<NavigationPoint> NavPointList;
var NavigationPoint GoPoint, TeleportPoint;
var Actor PathCache[16], UpActor;
var int PathCacheSize , PathIndex;
var bool FullPath, SuperBoost;
var vector ReInitPoint;
var int MaxChange,NbChange;
var vector UpPoint;
var rotator InitialRotationRate;
var NavigationPoint PointToDodge;
var int BeginJump;



//__________________________________________________________________

event bool NotifyBump(Actor Other)
{
    if( ( Pawn(Other) != none ) && ( ! Pawn(Other).bIsDead ) )
    {
        // ----------- Lauch Sound for the Death ---------------------
        // 2:pawn.playsound(Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hHuntKill');
        TheDuck(Pawn).soundcounter2++;
        if( TheDuck(Pawn).soundcounter2 == 255 )
            TheDuck(Pawn).soundcounter2 =0;
        TheDuck(Pawn).PlaySoundOfTheDeath();
        // ------------------------------------------------------------

        Pawn(Other).Controller.PlayerReplicationInfo.Score -= 10;
        Other.TakeDamage(1000, pawn, Location, vect(0,0,0), class'DT_KKK');
    }
}

//__________________________________________________________________

function ResetAllbSpecialCost()
{
    local int Loop, Index , Test;
    local NavigationPoint NavPt, LastPoint;

    for( Loop=0;Loop < NavPointList.Length ; Loop++ )
    {
        NavPt = NavPointList[ Loop ];
        NavPt.bSpecialCost=false;
    }
}

//__________________________________________________________________

function Damaged(Pawn Other)
{
    if( IsInState('ReInitWithTeleport') )
        return;

    SuperBoost=true;
    SetTimer( 10.0 , false );
    gotostate('GoRandom','FlagMove');
}

//__________________________________________________________________

event Timer()
{
    SuperBoost=false;
    gotostate('GoRandom','FlagMove');
}

//__________________________________________________________________
//__________________________________________________________________
//                      INIT
//__________________________________________________________________
//__________________________________________________________________

auto state init
{
    event BeginState()
    {
        local TheDuck D;

        if( Pawn == none )
        {
            foreach DynamicActors(class'TheDuck', D)
            {
                Pawn = D;
                break;
            }
        }

        GetAllNavPoint();

        Pawn.SetPhysics(Phys_Walking);
        Pawn.Velocity = vect(0,0,0);
        Pawn.Acceleration = vect(0,0,0);
        Pawn.LoopAnim('neutre');
    }

    //--------------------------------------------------------------

    function GetAllNavPoint()
    {
        local NavigationPoint Nav;

        Nav = Level.NavigationPointList;

        while( Nav != none)
        {
            if( ( CrouchPathNode(Nav) == none ) && ( InventorySpot(Nav) == none ) )
            {
                if( JumpPathNode(Nav) == none )
                {
                    NavPointList.Length = NavPointList.Length+1;
                    NavPointList[ NavPointList.Length-1 ] = Nav;
                }
            }

            Nav.bSpecialCost=false;

            Nav = Nav.NextNavigationPoint;
        }
    }
    //--------------------------------------------------------------

begin:
    sleep(1.0);
    gotostate('ReInitWithTeleport');
}

//__________________________________________________________________
//__________________________________________________________________
//                      GoRandom
//__________________________________________________________________
//__________________________________________________________________

state GoRandom
{
    event BeginState()
    {
        if( PointToDodge != none )
            PointToDodge.bSpecialCost=false;

        NbChange = 0;
        BeginJump = 0;
        SetTimer3(0.0,false);
    }

    //--------------------------------------------------------------

    function GetRandomLocation()
    {
        local int Loop, Index , Test;
        local NavigationPoint NavPt, LastPoint;

        LastPoint = GoPoint;
        GoPoint = none;
        Index = 0;

        for( Loop=Rand(NavPointList.Length);Loop < NavPointList.Length ; Loop++ )
        {
            NavPt = NavPointList[ Loop ];

            if( ( NavPt != LastPoint ) && ( NavPt != TeleportPoint ) )
            {
                MoveTarget = FindPathToward( NavPt, True);

                if( MoveTarget != none )
                {
                    GoPoint = NavPt;
                    break;
                }
                else
                    Test++;
            }

            Index++;

            if( Loop == NavPointList.Length-1 )
                Loop =0;

            if( Index > NavPointList.Length )
                break;
        }
    }

    //--------------------------------------------------------------

    function NavPathStorage( NavigationPoint NavPoint )
    {
        local int Loop;

		  if (pawn==none || pawn.bIsDead)
		  {
				 FullPath=true; //FRD to exit loop in states
				 return;
		  }
		  if( PointToDodge != none )
        {
            PointToDodge = none;
            PointToDodge.bSpecialCost=false;
        }
		 if (Vsize(NavPoint.location-pawn.location)<400 && ActorReachable(NavPoint))
		 {//FRD in order to test direct and near path
            log("actorreachable j'y vais direct au navpoint");
            movetarget=NavPoint;
            PathCacheSize = 1;
            PathCache[ 0 ] = NavPoint;
            FullPath=true;
            return;
		  }
        MoveTarget = FindPathToward( NavPoint, True);

        PathCacheSize = 0;

        for( Loop=0;Loop<16;Loop++)
        {
            if( RouteCache[ Loop ] == none )
                break;

            PathCache[ Loop ] = RouteCache[ Loop ];
            PathCacheSize++;
        }

        FullPath = ( NavigationPoint(PathCache[ PathCacheSize-1 ]) == NavPoint );
    }

    //--------------------------------------------------------------

    function bool CheckPath()
    {
        local vector              HitLocation;
        local vector              HitNormal;

        UpActor=Trace( HitLocation,HitNormal,MoveTarget.Location,Pawn.Location, true);

        if( UpActor == none )
            return true;
        else
            return false;
    }

    //--------------------------------------------------------------

    event Timer3()
    {
        if( ! CheckPath() )
        {
            if( NbChange < 2 )
            {
                if( PointToDodge != none )
                    PointToDodge.bSpecialCost=false;

                PointToDodge = NavigationPoint( MoveTarget );
                PointToDodge.bSpecialCost=true;
                NbChange++;
                Gotostate('GoRandom','Begin');
            }
            else
                Gotostate('Fight','Begin');
        }
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        if( Enemy == none )
        {
            Enemy = Seen;
            SetTimer2( 10.0,false );
            gotostate('GoRandom','FlagMove');
        }
    }

    //--------------------------------------------------------------

    event Timer2()
    {
        Enemy = none;
        SetTimer2( 0.0,false );
        gotostate('GoRandom','FlagMove');
    }

    //--------------------------------------------------------------

begin:

    while( Pawn.Physics == PHYS_Falling )
        sleep( 0.1 );

    SetTimer3(0.5,true);

    GetRandomLocation();

    if( GoPoint == none )
    {
        GotoState('DoNothing');
    }
    else
    {
        while( true )
        {
            NavPathStorage(GoPoint);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

FlagMove:
                if( SuperBoost )
                {
                    TheDuck(Pawn).ChangeLoopAnimation( 0 );
                    MoveSpeed = BoostMoveSpeed;
                }
                else
                {
                    if( Enemy != none )
                    {
                        TheDuck(Pawn).ChangeLoopAnimation( 1 );
                        MoveSpeed = FastMoveSpeed;
                    }
                    else
                    {
                        TheDuck(Pawn).ChangeLoopAnimation( 2 );
                        MoveSpeed = SlowMoveSpeed;
                    }
                }

                if( CrouchPathNode(MoveTarget) != none )
                {
                    BeginJump++;

                    if( BeginJump < 5 )
                        Goto('begin');
                    else
                    {
                        BeginJump = 0;
                        gotostate('ReInitWithTeleport');
                    }
                }

                if( JumpPathNode(MoveTarget) != none )
                {
                    if( PathIndex < PathCacheSize -1 )
                        if( MoveTarget.Location.Z < PathCache[ PathIndex +1 ].Location.Z )
                        {
                            BeginJump++;

                            if( BeginJump < 5 )
                                Goto('begin');
                            else
                            {
                                BeginJump = 0;
                                gotostate('ReInitWithTeleport');
                            }
                        }
                }

                MoveToward( MoveTarget, Focus , MoveSpeed );

                NbChange = 0;
                BeginJump = 0;
            }

            if( FullPath )
                break;
        }

        Goto('begin');
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                      DoNothing
//__________________________________________________________________
//__________________________________________________________________

state DoNothing
{
    event BeginState()
    {
        TheDuck(Pawn).ChangeLoopAnimation(3);
        Pawn.Velocity = vect(0,0,0);
        Pawn.Acceleration = vect(0,0,0);
    }

begin:
    pawn.setphysics(Phys_falling);
    Waitforlanding();
    Sleep(0.5);
    Spawn(class'SpawnEmitter',,, Location);
    GotoState('ReInitWithTeleport');
}

//__________________________________________________________________
//__________________________________________________________________
//                      Fight
//__________________________________________________________________
//__________________________________________________________________

state Fight
{
    event BeginState()
    {
        TheDuck(Pawn).ChangeLoopAnimation(4);
        Pawn.Velocity = vect(0,0,0);
        Pawn.Acceleration = vect(0,0,0);
    }

begin:
      focus=UpActor;
      SetRotation( rotator(UpActor.GetBoneCoords('X Head').Origin-Pawn.Location ) );
      Sleep( 5.0 );
      gotostate('GoRandom');
}

//__________________________________________________________________
//__________________________________________________________________
//                      Catched
//__________________________________________________________________
//__________________________________________________________________

state Catched
{
    event BeginState()
    {
        Pawn.LoopAnim('Sol');
        Pawn.Velocity = vect(0,0,0);
        Pawn.Acceleration = vect(0,0,0);
        Pawn.SetDrawType(DT_None);
        Pawn.SetCollision(False,False,False);
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                      ReInit
//__________________________________________________________________
//__________________________________________________________________

state ReInit
{
    event BeginState()
    {
        Pawn.SetDrawType(DT_Mesh);
        ResetAllbSpecialCost();
    }

    function FindNearestNavPoint()
    {
        local int Loop;
        local NavigationPoint NearestPoint,TmpPoint;
        local float BestDist,TmpDist;

        NearestPoint = NavPointList[0];
        BestDist = VSize( NearestPoint.Location - ReInitPoint );

        for( Loop=0;Loop < NavPointList.Length ; Loop++ )
        {
            TmpPoint = NavPointList[Loop];

            TmpDist = VSize( TmpPoint.Location - ReInitPoint );

            if( TmpDist <  BestDist )
            {
                BestDist = TmpDist;
                NearestPoint = TmpPoint;
            }
        }

//        log("ReInit --> Teleport at"@NearestPoint);
//        log("");

        Pawn.SetLocation( NearestPoint.Location );
        Spawn(class'SpawnEmitter',,, NearestPoint.Location);
    }

begin:

    FindNearestNavPoint();
    Damaged(none);
    gotostate('GoRandom');
}

//__________________________________________________________________
//__________________________________________________________________
//                      ReInitWithTeleport
//__________________________________________________________________
//__________________________________________________________________

state ReInitWithTeleport
{
    event BeginState()
    {
        TheDuck(Pawn).FullDamage = 0;
        Pawn.SetDrawType(DT_Mesh);
        Pawn.SetCollision(true,true,true);
        ResetAllbSpecialCost();
    }

    function TeleportTheDuck()
    {
        local int RandID;

        RandID = Rand(NavPointList.Length);

        TeleportPoint = NavPointList[ RandID ];

//        log("ReInitWithTeleport --> Teleport at"@TeleportPoint@RandID@"/"@NavPointList.Length);
//        log("");

        Pawn.SetLocation( TeleportPoint.Location );
        Spawn(class'SpawnEmitter',,, TeleportPoint.Location);
    }

begin:
    // ----------- Lauch Sound for the Death ---------------------
	// 3: Pawn.PlaySound(Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hHuntLoop');
	TheDuck(Pawn).soundcounter3++;
    if( TheDuck(Pawn).soundcounter3 == 255 )
        TheDuck(Pawn).soundcounter3 =0;
    TheDuck(Pawn).PlaySoundOfTheDeath();
    // ------------------------------------------------------------

    TeleportTheDuck();
    gotostate('GoRandom');
}

//__________________________________________________________________
//__________________________________________________________________
//                            GameEnded
//__________________________________________________________________
//__________________________________________________________________

state GameEnded
{
    event BeginState()
    {
        Enemy = none;

        Pawn.velocity=vect(0,0,0);
        Pawn.acceleration=vect(0,0,0);

        SetTimer(0.0,false);
        SetTimer2(0.0,false);
        SetTimer3(0.0,false);

        // ----------- Lauch Sound for the Death ---------------------
        // 4 :pawn.PlaySound(Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hHuntStopLoop');
        TheDuck(Pawn).soundcounter4++;
        if( TheDuck(Pawn).soundcounter4 == 255 )
            TheDuck(Pawn).soundcounter4 =0;
        TheDuck(Pawn).PlaySoundOfTheDeath();
        // ------------------------------------------------------------

        TheDuck(Pawn).ChangeLoopAnimation( 3 );
    }

    event SeePlayer( Pawn Seen );

    event Timer();
    event Timer2();
    event Timer3();
}

//__________________________________________________________________



defaultproperties
{
     FastMoveSpeed=0.350000
     SlowMoveSpeed=0.100000
     BoostMoveSpeed=0.680000
     MaxChange=3
}
