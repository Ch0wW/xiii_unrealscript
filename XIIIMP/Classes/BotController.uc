//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BotController extends AIController native;

struct Order
{
    var int Priority;
    var int TypeId;
    var string TypeName;
    var int ExcludeIds;
};

var int ID, OrderNumber , KillOrderPriority;
var Array<Order> OrderList;
var Order CurrentOrder;
var bool DBugBot, DBugWarning ,DBugOrder, FirstWeaponPickUp , bInitPickUpList , bIsJumping;
var actor Item;
var float MoveSpeed , MaxMoveSpeed , ShotErrorTime, MaxShotErrorTime, SeekTime , MaxSeekTime ,SnipeTime , MaxSnipeTime;
var int RespawnTime, InitialShotError;
var string MyName;
var actor FearActor, HidePoint;
var Array<actor> MedKitList;
var Array<actor> WeaponList;
var Array<actor> ArmorList;
var Array<NavigationPoint> SnipeSpotList;
var Array<NavigationPoint> TrakNarSpotList;
var array<actor> FullPickUpList;
var int JumpHeight, JumpSpeed;
var NavigationPoint JumpTarget, SnipePoint , TrakNarPoint;
var bool PathErrorToAllArmor, PathErrorToAllWeapon, PathErrorToAllLife;
var bool DamnedImFlashed, MyWeaponIsAGrenad, Sniping;
var int HeadShotModificator;
var bool ReloadableWeapon;
var int MaxSeekDist_Life,MaxSeekDist_Weapon,MaxSeekDist_Armor;
var float MaxDistModificator;
var float AimTime , LastDefaultOrderTime;
var Actor PathCache[16];
var int PathCacheSize , PathIndex;
var bool FullPath , bFireMove;
var GameReplicationInfo GRI;
var vector NextPosition;
var bool MarioMode;
var int AttackArea;
var float MissPercent,StraffeDelay;
var int TeamRole; // Use For Team Game
//CTF --> 0:Attacker,1:Defender;2:Support( Mixte )
//BOMB --> ID of BombPoint To defend/Attack
var bool WaitBeforeFire, ForceFear;
var float LastAdjustAimTime;
var vector LastEnemyPos;
var int LastStraffeDir, NbStraffe;
var float StraffeValue;
var GrenadPathNode MyGrenadTarget;
var bool GrenadIsLauched;
var float LastDistCheckTime;
var bool CloseCombat;
var bool bBackMove;
var navigationPoint NavToUpDate;
var array<XIIIMPWatchPoint> WatchPointList;
var array<XIIIMPWatchPoint> UseableWatchPointList;
var int TeamID;
var float TimePassedBeforeSeeingMyEnemy ;

const Order_Weapon        = 1;
const Order_Life          = 2;
const Order_Armor         = 4;
const Order_Kill          = 8;
const Order_Fear          = 16;
const Order_SnipeSpot     = 32;
const Order_SnipeAndKill  = 64;
const Order_Seek          = 128;
const Order_Unblock       = 256;
const Order_TrakNar       = 65536;
const Order_GrenadLauncher= 1073741824;//30


//__________________________________________________________________
//__________________________________________________________________
// native
//__________________________________________________________________
//__________________________________________________________________

native static final function actor ExtendFindPathToward(actor Desired,optional float xyMargin,optional float heightMargin); //FRD FindPathToward with height and radius tolerance
native(639) static final function int CalcPathWeight(); // Calc the full path dist between Pawn and Target
native(638) static final function bool FindOrder( int IdToFind );
native(637) static final function FindMostImportantOrder();
native(636) static final function RemoveOrder( int IdToKill );
native(635) static final function ExcludeOrders( int ExcludeIds );
native(634) static final function AddOrder( int Priority , int TypeId , optional string TypeName , optional int ExcludeIds  );
native(633) static final function ModifyOrder( int IdToModify , int NewPriority );
native(632) static final function SearchHidePoint();
native(631) static final function FindMedKit();
native(630) static final function FindNearestArmor();
native(629) static final function FindBestArmor();
native(628) static final function FindNearestWeapon();
native(627) static final function FindBestWeapon();
native(626) static final function bool IsNearest( Actor Enemy1, Actor Enemy2);
native(625) static final function bool IsInAttackArea( Actor Enemy );
native function ClearAllOrders();
native function StopMvtWhenMayFall();
native function FindAllNearestWatchPoint(Pawn CenterActor);

//__________________________________________________________________
//__________________________________________________________________
// List of Orders Manadgment
//__________________________________________________________________
//__________________________________________________________________

function UpDateOrder(int OldOrder,int NewOrder)
{
    TeamRole = NewOrder;
}

//__________________________________________________________________

function ClientGameEnded()
{
    gotostate('GameEnded');
}

//__________________________________________________________________

function int GetDistToMyTarget()
{
    local int Loop;
    local float DistToTheItem;

    if( ! FullPath )
         return 10000000;

    for( Loop = PathIndex; Loop < PathCacheSize ; Loop ++ )
    {
        if( Loop == PathIndex )
            DistToTheItem += VSize( Pawn.Location - PathCache[ Loop ].Location );
        else
            DistToTheItem += VSize( PathCache[ Loop-1 ].Location - PathCache[ Loop ].Location );
    }

    return int( DistToTheItem );
}

//__________________________________________________________________

event LogOrderList()
{
    local int index;
    local Order MyOrder;

    Log("");
    Log("[ BOT"@ID@"] : Order("$OrderNumber$")");

    if( OrderNumber == 0 )
        return;

    for( index = 0; index < OrderNumber; index++ )
    {
        MyOrder = OrderList[ index ];
        Log("    > Order("@MyOrder.TypeName@") --->"@MyOrder.Priority);
    }
}

//__________________________________________________________________

event AddDefaultOrders()
{
    if( ( Level.TimeSeconds - LastDefaultOrderTime < 2.0 ) && ( LastDefaultOrderTime != 0) )
    {
		 if( ( DBugBot ) || ( DBugWarning ) )
			Log("[ WARNING ][ ORDER ][ BOT"@ID@"] : Runaway Loop !...");

        AddOrder(79,Order_UnBlock,"UnBlock",0);
    }
    else
    {
        if( ! PathErrorToAllLife )
            AddOrder(GetLifePriority(),Order_Life,"Life",0);

        if( ! PathErrorToAllWeapon )
            AddOrder(60,Order_Weapon,"Weapon",0);

        if( ! PathErrorToAllArmor )
            AddOrder(40,Order_Armor,"Armor",0);

        if( TrakNarSpotList.Length > 0 )
            AddOrder(30,Order_TrakNar,"TrakNar",0);
    }

    LastDefaultOrderTime = Level.TimeSeconds;
}

//__________________________________________________________________

function bool CheckPath()
{
    local vector              HitLocation;
    local vector              HitNormal;
    local actor               ColActor;

    ColActor=Trace( HitLocation,HitNormal,MoveTarget.Location,Pawn.Location, true);

    if( ColActor == none )
        return true;
    else
        return false;
}

//__________________________________________________________________

function TryToChangePath(NavigationPoint NavToUpDate)
{
    NavToUpDate.bSpecialCost=true;

    NavToUpDate.bSpecialCost=false;
}

//__________________________________________________________________

event ChangeState()
{
    switch( CurrentOrder.TypeId )
    {
        case Order_Kill : GotoState( 'Kill' ); break;
        case Order_Life : GotoState( 'Life' ); break;
        case Order_Seek : GotoState( 'Seek' ); break;
        case Order_Fear : gotoState( 'Fear' ); break;
        case Order_Weapon : GotoState( 'Weapon' ); break;
        case Order_Armor : GotoState( 'Armor' ); break;
        case Order_SnipeSpot : GotoState( 'SnipeSpot' ); break;
        case Order_SnipeAndKill : GotoState( 'SnipeAndKill' ); break;
        case Order_UnBlock : gotoState( 'UnBlock' ); break;
        case Order_TrakNar : gotoState( 'TrakNar' ); break;
        case Order_GrenadLauncher : gotoState( 'GrenadLauncher' ); break;
    }
}

//__________________________________________________________________

function Initialize(int BotID, int BotLevel , string BotName )
{
	 if (pawn==none) //FRD controller did not manage to spawn the pawn
	 {
		gotostate('dead');
		return;
	 }
    MyName = BotName;
    ID = BotID;
    //Skill = BotLevel;
    MaxMoveSpeed = 1.0;//0.9;//0.9 + BotLevel*0.5;
    MoveSpeed = MaxMoveSpeed;
    KillOrderPriority = 80;
    MaxSeekTime = 10 - Skill;
    OrderNumber = 0;
    OrderList.Length = 0;

    if( DBugBot )
    {
        Log("");
        Log("[ BOT"@ID@"][ Level"@int(Skill)@"][ Team"@TeamID@"] : *INIT*");
        log("    > Contoller ="@Self);
        log("    > Pawn ="@Pawn);
        log("    > name ="@BotName);
    }

    FirstWeaponPickUp = true;
    DamnedImFlashed = False;
    MyWeaponIsAGrenad = false;
    PathErrorToAllArmor = false;
    PathErrorToAllWeapon = false;
    PathErrorToAllLife = false;
    Sniping = false;
    ReloadableWeapon = true;
    LastDefaultOrderTime = 0;
    Enemy = none;
    FearActor = none;
    HidePoint = none;
    Item = none;
    JumpTarget = none;
    SnipePoint = none;
    MoveSpeed = MaxMoveSpeed;

    Pawn.SetPhysics(Phys_Walking);
    Pawn.Velocity = vect(0,0,0);
    Pawn.Acceleration = vect(0,0,0);

    switch( XIIIGameInfo(Level.Game).Plateforme )
    {
        case PF_PC : MaxDistModificator = 2; break;
        case PF_PS2 : MaxDistModificator = 1; break;
        case PF_GC : MaxDistModificator = 1; break;
        case PF_XBOX : MaxDistModificator = 1.5; break;
    }

    MaxDistModificator = 2;

    MaxSeekDist_Life = default.MaxSeekDist_Life * MaxDistModificator;
    MaxSeekDist_Weapon = default.MaxSeekDist_Weapon * MaxDistModificator;
    MaxSeekDist_Armor = default.MaxSeekDist_Armor * MaxDistModificator;

    Pawn.SetAnimStatus('Alert');

    if( ! bInitPickUpList )
        InitPickUpList();

    SetTimer( 0.0,False );
    SetTimer2(0.0,false);

	 SwitchWeapon();
    AddDefaultOrders();
}

//__________________________________________________________________

function PickUpPathStorage( actor Target)
{
    local int Loop;

    if( NavToUpDate != none )
    {
        NavToUpDate.bSpecialCost=false;
        NavToUpDate = none;
    }
	 if (Vsize(Target.location-pawn.location)<400 && ActorReachable(Target))  //FRD in order to test direct and near path
	 {
		 movetarget=target;
		 PathCacheSize = 1;
		 PathCache[ 0 ] = target;
       FullPath=true;
		 return;
	 }

    MoveTarget = ExtendFindPathToward(Target);

//    if( MoveTarget == none )
//        MoveTarget = FindPathToward(Target);

    PathCacheSize = 0;

    for( Loop=0;Loop<16;Loop++)
    {
        if( RouteCache[ Loop ] == none )
            break;

        PathCache[ Loop ] = RouteCache[ Loop ];
        PathCacheSize++;
    }

    FullPath = ( InventorySpot(PathCache[ PathCacheSize-1 ]) == PickUp(Target).MyMarker );
}

//__________________________________________________________________


function NavPathStorage( NavigationPoint NavPoint )
{
    local int Loop;

	if (pawn==none || pawn.bIsDead)
	{
		 FullPath=true; //FRD to exit loop in states
		 return;
	}
    if( NavToUpDate != none )
    {
        NavToUpDate.bSpecialCost=false;
        NavToUpDate = none;
    }
    if (Vsize(NavPoint.location-pawn.location)<400 && ActorReachable(NavPoint))
    {//FRD in order to test direct and near path
        movetarget=NavPoint;
        PathCacheSize = 1;
        PathCache[ 0 ]=NavPoint;
        FullPath=true;
        return;
    }

    MoveTarget = ExtendFindPathToward(NavPoint);

//    if( MoveTarget == none )
//        MoveTarget = FindPathToward(NavPoint);

    PathCacheSize = 0;

//    log("");
//    log("[ BOT"@ID@"] : NavPathStorage to"@NavPoint);

//    if( NavToUpDate != none )
//        log("NavToUpDate="@NavToUpDate);

    if( ( MoveTarget == none ) && DBugWarning )
        log("!!! WARNING NavPathStorage !!!");

    for( Loop=0;Loop<16;Loop++)
    {
        if( RouteCache[ Loop ] == none )
            break;

//        log(" >"@Loop@":"@RouteCache[ Loop ]);

        PathCache[ Loop ] = RouteCache[ Loop ];
        PathCacheSize++;
    }

//    log("");

    FullPath = ( NavigationPoint(PathCache[ PathCacheSize-1 ]) == NavPoint );
}

//__________________________________________________________________

function ActorPathStorage( actor Target)
{
    local int Loop;

    if( NavToUpDate != none )
    {
        NavToUpDate.bSpecialCost=false;
        NavToUpDate = none;
    }
	 if (Vsize(Target.location-pawn.location)<400 && ActorReachable(Target))  //FRD in order to test direct and near path
	 {
		 movetarget=target;
		 PathCacheSize = 1;
		 PathCache[ 0 ] = target;
       FullPath=true;
		 return;
	 }
    MoveTarget = ExtendFindPathToward( Target);

//    if( MoveTarget == none )
//        MoveTarget = FindPathToward(Target);

    PathCacheSize = 0;

    for( Loop=0;Loop<16;Loop++)
    {
        if( RouteCache[ Loop ] == none )
            break;

        PathCache[ Loop ] = RouteCache[ Loop ];
        PathCacheSize++;
    }

    FullPath = true;
}

//__________________________________________________________________

function int GetLifePriority()
{
    local float LifePriority;

    LifePriority = Pawn.Health;
    LifePriority /= Pawn.default.Health;
    LifePriority = 100 - LifePriority*100;

    if( Pawn == none )
        LifePriority =1;

    return int(LifePriority);
}

//__________________________________________________________________

function GetRandomLocation()
{
    local int Loop;
    local actor A;

    Item = none;

    for( Loop=Rand(FullPickUpList.Length);Loop < FullPickUpList.Length ; Loop++ )
    {
        A = FullPickUpList[ Loop ];

        MoveTarget = ExtendFindPathToward( A);

//        if( MoveTarget == none )
//            MoveTarget = FindPathToward(A);


        Item = A;
        break;
    }

    Log("[ ERROR ][ PATH ][ BOT"@ID@"] : Item ="@Item@"Pawn ="@Pawn);

    if( Item == none )
        Log("[ ERROR ][ PATH ][ BOT"@ID@"] : All Path Failed ! ...");
}

//__________________________________________________________________

function bool MissTheShoot()
{
    if( LastAdjustAimTime == -1 )
    {
        LastAdjustAimTime = Level.TimeSeconds;
        LastEnemyPos = Enemy.Location;
    }
    else if( Level.TimeSeconds - LastAdjustAimTime > 1.0 )
    {
        LastAdjustAimTime = Level.TimeSeconds;

        if( VSize( LastEnemyPos - Enemy.Location ) > 150 )
        {
            if( Rand( 100 ) < 30+ Skill*20 )
            {
                ShotErrorTime = 1.0 + Level.TimeSeconds;
                InitialShotError = 200 + Rand(400);
            }
        }

        LastEnemyPos = Enemy.Location;
    }

    if( ( DamnedImFlashed ) || ( Enemy.DrawType == DT_None ) )
    {
        InitialShotError = 3000 + Rand(6000);
        return true;
    }
    else
    {
        if( Rand( 100 ) < (3.5-Skill)*MissPercent )
            return true;
        else
            return false;
    }
}

//__________________________________________________________________

function TestCloseCombat()
{
    if( Level.TimeSeconds - LastDistCheckTime > 0.5 )
    {
        //log("time"@Level.TimeSeconds - LastDistCheckTime);

        LastDistCheckTime = Level.TimeSeconds;

        if( VSize( Enemy.Location - Pawn.Location ) < 300 )
            CloseCombat = true;
        else
            CloseCombat = false;
    }
}


//__________________________________________________________________

function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	local rotator RotatorError;

	if( Enemy == none )
    	return ( Rotation );

    TestCloseCombat();

    if( ( MissTheShoot() ) || ( Level.TimeSeconds - ShotErrorTime < 0 ) )
    {
        //log("MISS");

        if( Rand( 2 ) == 1 )
            RotatorError.Yaw = InitialShotError;
        else
            RotatorError.Yaw = 65535-InitialShotError;

        SetRotation( rotator(Enemy.GetBoneCoords('X Spine1').Origin-(Pawn.Location+Pawn.EyePosition()) ) );
        Pawn.ControllerPitch = Rotation.Pitch / 256;
    }
    else
    {
        //log("TOUCH");

        if( ( Rand( 100 ) < (Skill+1)*10 + HeadShotModificator ) || ( ( CloseCombat ) && ( Rand( 100 ) < 55 + (Skill)*15 ) ) )
        {
            SetRotation( rotator(Enemy.GetBoneCoords('X Head').Origin-(Pawn.Location+Pawn.EyePosition()) ) );
            Pawn.ControllerPitch = Rotation.Pitch / 256;
        }
        else
        {
            SetRotation( rotator(Enemy.GetBoneCoords('X Spine1').Origin-(Pawn.Location+Pawn.EyePosition()) ) );
            Pawn.ControllerPitch = Rotation.Pitch / 256;
        }
    }

    //log(" > RotatorError="@RotatorError.Yaw);

    return ( Rotation + RotatorError );
}

//__________________________________________________________________

function InitShotError(bool ReduceError)
{
    local float ErrorTime;

    ErrorTime = MaxShotErrorTime - Skill + FRand();

    if ( ReduceError )
        ErrorTime -= 1.0;

    ShotErrorTime = ErrorTime + Level.TimeSeconds;
    InitialShotError = 200 + Rand(400);
    LastAdjustAimTime = -1;
    LastDistCheckTime = Level.TimeSeconds;
}

//__________________________________________________________________

function InitWeaponParam()
{
    //if( DBugBot ) Log("[ BOT"@ID@"] : InitWeaponParam "@Pawn.PendingWeapon.InventoryGroup);

    HeadShotModificator = 30 ;
    MissPercent = 3;
    MyWeaponIsAGrenad = false;
    MoveSpeed = MaxMoveSpeed;
    Pawn.SightRadius = 2500;

    if( Pawn.PendingWeapon == none )
        return;

    switch( Pawn.PendingWeapon.InventoryGroup )
    {
//        case 1 :    //Knife
//                    HeadShotModificator = 40 ;
//                    MissPercent = 5;
//                    MyWeaponIsAGrenad = false;
//                    MoveSpeed = MaxMoveSpeed;
//                    break;
        case 2 :    // Beretta
                    HeadShotModificator = 30 ;
                    MissPercent = 3;
                    MyWeaponIsAGrenad = false;
                    MoveSpeed = MaxMoveSpeed;
                    Pawn.SightRadius = 2500;
                    break;
        case 3 :    // Magnum
                    HeadShotModificator = 30 ;
                    MissPercent = 3;
                    MyWeaponIsAGrenad = false;
                    MoveSpeed = MaxMoveSpeed;
                    Pawn.SightRadius = 2500;
                    break;
        case 4 :    // Grenad
                    HeadShotModificator = 50 ;
                    MissPercent = 0;
                    MyWeaponIsAGrenad = true;
                    MoveSpeed = MaxMoveSpeed;
                    Pawn.SightRadius = 2500;
                    break;
        case 5 :    // Grenad Frag
                    HeadShotModificator = 50 ;
                    MissPercent = 0;
                    MyWeaponIsAGrenad = true;
                    MoveSpeed = MaxMoveSpeed;
                    Pawn.SightRadius = 2500;
                    break;
//        case 6 :    // Arbalete
//                    HeadShotModificator = 50 ;
//                    MissPercent = 5;
//                    MyWeaponIsAGrenad = false;
//                    MoveSpeed = MaxMoveSpeed;
//                    break;
//        case 7 :    // Arbalete x3
//                    HeadShotModificator = 50 ;
//                    MissPercent = 5;
//                    MyWeaponIsAGrenad = false;
//                    MoveSpeed = MaxMoveSpeed;
//                    break;
//        case 8 :    // Harpon
//                    HeadShotModificator = 40 ;
//                    MissPercent = 5;
//                    MyWeaponIsAGrenad = false;
//                    MoveSpeed = MaxMoveSpeed;
//                    break;
        case 9 :    // Pompe
                    HeadShotModificator = -10 ;
                    MissPercent = 5;
                    MyWeaponIsAGrenad = false;
                    MoveSpeed = MaxMoveSpeed;
                    Pawn.SightRadius = 2500;
                    break;
        case 10 :   // Chasse
                    HeadShotModificator = 10 ;
                    MissPercent = 5;
                    MyWeaponIsAGrenad = false;
                    MoveSpeed = MaxMoveSpeed;
                    break;
        case 11 :   // M16
                    HeadShotModificator = 0 ;
                    MissPercent = 6;
                    MyWeaponIsAGrenad = false;
                    MoveSpeed = MaxMoveSpeed;
                    Pawn.SightRadius = 2500;
                    break;
        case 12 :   // Kalash
                    HeadShotModificator = 0 ;
                    MissPercent = 8;
                    MyWeaponIsAGrenad = false;
                    MoveSpeed = MaxMoveSpeed;
                    Pawn.SightRadius = 2500;
                    break;
        case 13 :   // UZI
                    HeadShotModificator = 5 ;
                    MissPercent = 7;
                    MyWeaponIsAGrenad = false;
                    MoveSpeed = MaxMoveSpeed;
                    Pawn.SightRadius = 2500;
                    break;
        case 14 :   // Snipe
                    HeadShotModificator = 50 ;
                    MissPercent = 2;
                    MyWeaponIsAGrenad = false;
                    MoveSpeed = MaxMoveSpeed;
                    Pawn.SightRadius = 5000;
                    break;
        case 15 :   // Bazook
                    HeadShotModificator = -20 ;
                    MissPercent = 2;
                    MyWeaponIsAGrenad = false;
                    MoveSpeed = MaxMoveSpeed * 0.66;
                    Pawn.SightRadius = 2500;
                    break;
        case 16 :   // M60
                    HeadShotModificator = -20 ;
                    MissPercent = 9;
                    MyWeaponIsAGrenad = false;
                    MoveSpeed = MaxMoveSpeed * 0.66;
                    Pawn.SightRadius = 2500;
                    break;
        case 21 :   // FlashBang
                    HeadShotModificator = 50 ;
                    MissPercent = 0;
                    MyWeaponIsAGrenad = true;
                    MoveSpeed = MaxMoveSpeed;
                    Pawn.SightRadius = 2500;
                    break;
    }
}

//__________________________________________________________________

function SwitchWeapon()
{
     local float rating;
     local Weapon W;

    if (Pawn == None )
        return;

    if (Pawn.Inventory == None )
        return;

    Pawn.PendingWeapon = Pawn.Inventory.RecommendWeapon(rating);

    //if( DBugBot ) Log("[ BOT"@ID@"] : SwitchWeapon to"@Pawn.PendingWeapon@"with rating of"@Rating);

    if (Pawn.PendingWeapon == None )
        return;

    if (Pawn.PendingWeapon == Pawn.Weapon )
        Pawn.PendingWeapon = None;

    if (Pawn.Weapon == None )
        Pawn.ChangedWeapon();
    else if ( Pawn.Weapon != Pawn.PendingWeapon )
        Pawn.Weapon.PutDown();

    InitWeaponParam();
}

//__________________________________________________________________

function PawnDied()
{
    if ( Pawn != None )
	{
		SetLocation(Pawn.Location);
		Pawn.UnPossessed();
	}

	Pawn = None;
	PendingMover = None;

    //log("");
    //Log("[ BOT"@ID@"] : PawnDied"@self);

    GotoState('Dead');
}

//__________________________________________________________________

function bool IsEnemy( Pawn Target )
{
    return True;
}

//__________________________________________________________________

function SomeoneWantKillMe( Pawn Agressor )
{
    if( ! PathErrorToAllLife )
    {
        if( FindOrder( Order_Life ) )
            ModifyOrder( Order_Life, GetLifePriority() );
        else
            AddOrder(GetLifePriority(),Order_Life,"Life",0);
    }

    if( Agressor == Pawn )
        return;

    if( Agressor == Enemy )
    {
        bFireMove = true;
        return;
    }

    if( ! IsEnemy( Agressor ) )
        return;

    if( ( Enemy == none ) || ( IsNearest( Enemy,Agressor) )  )
    {
        Enemy = Agressor;

        if( !FindOrder( Order_Kill ) )
            AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
        else
        {
            WaitBeforeFire = true;
            bFire=0;
            bFireMove = false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);
        }
    }
}

//__________________________________________________________________

function bool CheckThePowerOfTheEnemy( Pawn Other )
{
    local int MyPower,EnemyPower;
    local Inventory AlreadyHas;

    AlreadyHas = Other.FindInventoryType(Class'XIII.Casque');

    If( AlreadyHas != none )
    {
        log("Has Casque");
        EnemyPower++;
    }

    AlreadyHas = Other.FindInventoryType(Class'XIII.GiletMk1');

    If( AlreadyHas != none )
    {
        log("Has Gilet");
        EnemyPower++;
    }

    switch( Other.Weapon.InventoryGroup )
    {
        case 2 :    // Beretta
                    break;
        case 3 :    // Magnum
                    EnemyPower++;
                    break;
        case 4 :    // Grenad
                    break;
        case 5 :    // Grenad Frag
                    break;
        case 9 :    // Pompe
                    EnemyPower++;
                    break;
        case 11 :   // M16
                    EnemyPower+=2;
                    break;
        case 12 :   // Kalash
                    EnemyPower+=2;
                    break;
        case 13 :   // UZI
                    EnemyPower++;
                    break;
        case 14 :   // Snipe
                    EnemyPower++;
                    break;
        case 15 :   // Bazook
                    EnemyPower+=3;
                    break;
        case 16 :   // M60
                    EnemyPower+=3;
                    break;
        case 21 :   // FlashBang
                    break;
    }

    AlreadyHas = Pawn.FindInventoryType(Class'XIII.Casque');

    If( AlreadyHas != none )
    {
        log("Has Casque");
        MyPower++;
    }

    AlreadyHas = Pawn.FindInventoryType(Class'XIII.GiletMk1');

    If( AlreadyHas != none )
    {
        log("Has Gilet");
        MyPower++;
    }

    switch( Pawn.Weapon.InventoryGroup )
    {
        case 2 :    // Beretta
                    break;
        case 3 :    // Magnum
                    MyPower++;
                    break;
        case 4 :    // Grenad
                    break;
        case 5 :    // Grenad Frag
                    break;
        case 9 :    // Pompe
                    MyPower++;
                    break;
        case 11 :   // M16
                    MyPower+=2;
                    break;
        case 12 :   // Kalash
                    MyPower+=2;
                    break;
        case 13 :   // UZI
                    MyPower++;
                    break;
        case 14 :   // Snipe
                    MyPower++;
                    break;
        case 15 :   // Bazook
                    MyPower+=3;
                    break;
        case 16 :   // M60
                    MyPower+=3;
                    break;
        case 21 :   // FlashBang
                    break;
    }

    if( (  MyPower >= EnemyPower ) || ( Rand(100) > ( EnemyPower - MyPower )*20 ) )
        return true;
    else
        return false;
}


//__________________________________________________________________

function bool GetNumberOfEnemyInTheGrenadArea(BotGrenadTarget Target)
{
//    return true;

    if( Rand( 100 ) < 50 )
        return true;
    else
        return false;

//    local BotController BOT;
//
//    foreach DynamicActors(class'BotController', BOT)
//    {
//        if( ( BOT != self ) && ( VSize( Target.Location - Bot.Pawn.Location ) < Max(Target.AreaSize,600) ) )
//            return true;
//    }
//
//    return false;
}

//__________________________________________________________________

function GrenadPossibility( GrenadPathNode GrenadNode )
{
    local weapon MyGrenad;
    local int Loop;

    if( GrenadNode.LastUsedTime == -1 )
        GrenadNode.LastUsedTime = Level.TimeSeconds;
    else if( Level.TimeSeconds - GrenadNode.LastUsedTime > 10 )
        GrenadNode.LastUsedTime = Level.TimeSeconds;
    else
        return;



    MyGrenad = Weapon(Pawn.FindInventoryType(class'FGrenad') );

    if( ( MyGrenad == none ) || (  MyGrenad.AmmoType.AmmoAmount == 0 ) )
    {
        MyGrenad = Weapon(Pawn.FindInventoryType(class'FlashBangBot') );

        if( ( MyGrenad == none ) || (  MyGrenad.AmmoType.AmmoAmount == 0 ) )
        {
            return;
        }
    }



    MyGrenadTarget = GrenadNode;

    if( GetNumberOfEnemyInTheGrenadArea(GrenadNode.Target) )
    {
        if( ( ! FindOrder( Order_GrenadLauncher ) ) && ( ! FindOrder( Order_Kill ) ) )
        {
            MyGrenad.AIRating = 2.0;
            SwitchWeapon();

            GrenadIsLauched = false;
            AddOrder(79,Order_GrenadLauncher,"GrenadLauncher",0);
        }
    }
}

//__________________________________________________________________

event HearNoise( float Loudness, Actor NoiseMaker)
{
    if( NoiseMaker.IsA('GrenadFlying') )
    {
//        if( ( Rand( 100 ) < 30 + Skill*20 ) || ( ForceFear ) )
        if( ( Rand( 100 ) < 90 ) || ( ForceFear ) )
        {
            if( FastTrace( NoiseMaker.Location, Pawn.Location ) )
            {
                if( VSize( NoiseMaker.Location - Pawn.Location ) < 600 )
                {
                    FearActor = NoiseMaker;
                    AddOrder( 90 ,Order_Fear , "Fear" , 0 );
                }
            }
        }
    }
}

//__________________________________________________________________

event SeePlayer( Pawn Seen )
{
    local float Dist;

    if( MyWeaponIsAGrenad )
    {
        Dist = VSize( Seen.Location - Pawn.Location );

        If( Dist > 1200 )
            return;

        if( Dist < 800 )
        {
            Pawn.Weapon.AIRating = 0.11;
            SwitchWeapon();
        }
    }

    if( ( ! IsEnemy( Seen ) ) || DamnedImFlashed )
        return;

    if( Seen.DrawType == DT_None )
        return;

    if( Enemy == none )
    {
        //if( CheckThePowerOfTheEnemy( Seen ) )
        //{
            Enemy = Seen;

            if( IsShootable( Seen ) )
                AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
            else
                AddOrder(70,Order_Seek,"Seek",0);
        //}
    }
    else if( IsNearest( Enemy,Seen) )
    {
        Enemy = Seen;
    }
}

//__________________________________________________________________

event MayFall()
{
    if( ! IsInState('Kill') )
        return;

    StopMvtWhenMayFall();
    Pawn.velocity=vect(0,0,0);
    Pawn.acceleration=vect(0,0,0);
}

//__________________________________________________________________

function bool IsShootable( Pawn ShootTarget )
{
    if( MyWeaponIsAGrenad )
        return ( FastTrace( ShootTarget.Location+ShootTarget.EyePosition(), Pawn.Location+Pawn.EyePosition() ) && ( ! Pawn.bIsCrouched ) );
    else
        return FastTrace( ShootTarget.Location, Pawn.Location + Pawn.EyePosition() + Pawn.Weapon.FireOffset )  ;
}

//__________________________________________________________________

function InitPickUpList()
{
    local PickUp A;
    local NavigationPoint Nav;
    local Pawn P;

    bInitPickUpList = true;

    Nav = Level.NavigationPointList;

    while( Nav != none)
    {
        if( Nav.IsA('SnipePathNode') )
        {
            SnipeSpotList.Length = SnipeSpotList.Length+1;
            SnipeSpotList[ SnipeSpotList.Length-1 ] = Nav;
        }

        if( Nav.IsA('TrakNarPathNode') )
        {
            TrakNarSpotList.Length = TrakNarSpotList.Length+1;
            TrakNarSpotList[ TrakNarSpotList.Length-1 ] = Nav;
        }

        Nav = Nav.NextNavigationPoint;
    }

    MarioMode = false;

    foreach DynamicActors(class'PickUp', A)
    {

        FullPickUpList.Length = FullPickUpList.Length+1;
        FullPickUpList[ FullPickUpList.Length-1 ] = A;

        if ( A.IsA('MultiPlayerMedPickUp') )
        {
            MedKitList.Length = MedKitList.Length+1;
            MedKitList[ MedKitList.Length-1 ] = A;
        }
        else if( A.IsA('XIIIWeaponPickUp') )
        {
            WeaponList.Length = WeaponList.Length+1;
            WeaponList[ WeaponList.Length-1 ] = A;
        }
        else if( A.IsA('XIIIArmorPickUp') )
        {
            ArmorList.Length = ArmorList.Length+1;
            ArmorList[ ArmorList.Length-1 ] = A;
        }
        else if (A.IsA('MarioPickUp'))
        {
            MarioMode = true;

            FullPickUpList.Length = FullPickUpList.Length+1;
                FullPickUpList[ FullPickUpList.Length-1 ] = A;

                if ( A.IsA('MarioArmorAndMedKitPickUp'))
            {
                MedKitList.Length = MedKitList.Length+1;
                    MedKitList[ MedKitList.Length-1 ] = A;
            }
                else if( ( A.IsA('MarioHeavyWeaponPickUp') ) || ( A.IsA('MarioSmallWeaponPickUp') ) )
            {
                WeaponList.Length = WeaponList.Length+1;
                    WeaponList[ WeaponList.Length-1 ] = A;
            }
        }
        else if (A.IsA('MarioSuperBonusPickUp'))
        {
            FullPickUpList.Length = FullPickUpList.Length+1;
            FullPickUpList[ FullPickUpList.Length-1 ] = A;

            ArmorList.Length = ArmorList.Length+1;
            ArmorList[ ArmorList.Length-1 ] = A;
        }
    }

    if( DBugBot )
    {
        Log("");
        Log("[ BOT"@ID@"] : PickUpList Construction");
        log("    > MedKit="$MedKitList.Length);
        log("    > Weapon="$WeaponList.Length);
        log("    > Armor="$ArmorList.Length);
        log("    > SnipePoint="$SnipeSpotList.Length);
        log("    > TrakNarPoint="$TrakNarSpotList.Length);
        log("    > MarioMode="$MarioMode);
    }
}

//__________________________________________________________________

function InitBotJump( int V , int H , NavigationPoint T )
{
    JumpSpeed = V;
    JumpHeight = H;
    JumpTarget = T;

    if( MoveSpeed != MaxMoveSpeed )
    {
        JumpSpeed *= 1.7;
        JumpHeight *= 1.7;
    }

    bIsJumping = true;
    GotoState('Jumping');
}

//__________________________________________________________________

function InitSnipe()
{
    Sniping = true;
    GotoState('Sniping');
}

//__________________________________________________________________

function Flashed()
{
    DamnedImFlashed = true;
}

//__________________________________________________________________


event Timer()
{
}
/*
event tick (float delta)
{
	super.tick(delta);
	if (pawn==none && !isinstate('dead') && !isinstate('gameended')) log(self@getstatename()@"PAWN== NONE NONE NONE NONE");
}   */
//__________________________________________________________________
//__________________________________________________________________
//                            Weapon
//__________________________________________________________________
//__________________________________________________________________

state Weapon
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Weapon");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );
    }

    event SeePlayer( Pawn Seen )
    {
        if( ( GetDistToMyTarget() > 800 ) && ( VSize( Pawn.Location - Seen.Location ) > VSize( PathCache[ PathIndex ].Location - Seen.Location ) ) )
            global.SeePlayer( Seen );
    }

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( Agressor == Pawn )
            return;

        if( ( GetDistToMyTarget() > 800 ) && ( VSize( Pawn.Location - Agressor.Location ) > VSize( PathCache[ PathIndex ].Location - Agressor.Location ) ) )
            global.SomeoneWantKillMe( Agressor );
    }

Begin:

    if( Pawn.Physics == PHYS_Falling )
    {
        while( true )
        {
            sleep( 0.1 );

            if ( Pawn.Physics != PHYS_Falling )
               break;
        }
    }

    if( ( Skill == 0 ) || FirstWeaponPickUp )
    {
        FindNearestWeapon();
        FirstWeaponPickUp = false;
    }
    else
        FindBestWeapon();

    if( Item == none )
    {
        Sleep( 0.5 );
        RemoveOrder( Order_Weapon );
    }
    else
    {
        while( true )
        {
            PickUpPathStorage(Item);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                if( ( PathIndex == PathCacheSize-1 ) && ( ! PickUp(Item).ReadyToPickUp(0) ) )
                    Goto('begin');

                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                Pawn.ShouldCrouch( false );
                MoveToward( MoveTarget, Focus , MoveSpeed );
            }

            if( FullPath )
                break;
        }

        SwitchWeapon();

        if( ( Pawn.Weapon.InventoryGroup == 14) && ( SnipeSpotList.Length != 0 ) )
        {
            Pawn.SetAnimStatus('Alert');
            AddOrder(50,Order_SnipeSpot,"Snipe",0);
        }

        RemoveOrder( Order_Weapon );
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            Fear
//__________________________________________________________________
//__________________________________________________________________

state Fear
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Fear");
        }

        Pawn.ControllerPitch = 0;

        if( Pawn.bIsCrouched )
            Pawn.ShouldCrouch( false );

        ForceFear = false;

        if( FindOrder( Order_Kill ) )
            RemoveOrder( Order_Kill );
    }

    event HearNoise( float Loudness, Actor NoiseMaker);

    event SeePlayer( Pawn Seen )
    {
        if( ! IsEnemy( Seen ) )
            return;

        if( ! IsShootable( Seen ) )
            return;

        if( ( VSize( FearActor.Location - Pawn.Location ) < 1200 - (3-Skill)*100 ) && ( VSize( Seen.Location - Pawn.Location ) > 300 ) )
            return;

        Enemy = Seen;

        AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
        RemoveOrder( Order_Fear );
    }

    function SomeoneWantKillMe( Pawn Agressor );

Begin:

    if( Pawn.Physics == PHYS_Falling )
    {
        while( true )
        {
            sleep( 0.1 );

            if ( Pawn.Physics != PHYS_Falling )
               break;
        }
    }

    Pawn.ShouldCrouch( false );

    Sleep( 1.0 - 0.3*Skill );

    SearchHidePoint();

    if( HidePoint == none )
        RemoveOrder( Order_Fear );
    else
    {
        while( true )
        {
            if( HidePoint.IsA('PickUp') )
                PickUpPathStorage(HidePoint);
            else
                NavPathStorage(NavigationPoint(HidePoint));

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                Pawn.ShouldCrouch( false );
                MoveToward( MoveTarget, Focus , MoveSpeed );

                if( FearActor == none )
                {
                    if( DBugBot )
                    {
                        Log("");
                        Log("[ BOT"@ID@"] : Fear ---> Grenad Explosed");
                    }

                    break;
                }
                else if( VSize( FearActor.Location - Pawn.Location ) > 1500 - (3-Skill)*100 )
                     RemoveOrder( Order_Fear );
            }

            if( FullPath )
                break;

            if( FearActor == none )
                break;
        }

        if( FearActor != none )
        {
            if( DBugBot )
            {
                Log("");
                Log("[ BOT"@ID@"] : Fear ---> Safe Point");
            }

            Pawn.ShouldCrouch( true );

            if( FearActor.IsA('GrenadFlying') )
                Sleep( 2 );
            else
            {
                while( FearActor != none )
                {
                    Sleep( 0.5 );
                }
            }

            Pawn.ShouldCrouch( false );
        }

        RemoveOrder( Order_Fear );
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            Life
//__________________________________________________________________
//__________________________________________________________________

state Life
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Life("$GetLifePriority()$")");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );

        if( FindOrder( Order_Kill ) )
            RemoveOrder( Order_Kill );
    }

    event SeePlayer( Pawn Seen )
    {
        if( ! IsEnemy( Seen ) )
            return;

        if( ! ForceAttack( Seen ) )
            return;

        if( ! IsShootable( Seen ) )
            return;

        if( ! FindOrder( Order_Kill ) )
        {
            Enemy = Seen;
            AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
            ModifyOrder( Order_Life,KillOrderPriority-1 );
        }
    }

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( Agressor == Pawn )
            return;

        SeePlayer( Agressor );
    }

    function bool ForceAttack( Pawn Other )
    {
        local float DistToOther, DistToLife, DistToTarget;

        if ( (Other == none) || (MoveTarget == none) )
          return false;

        DistToOther = VSize( Pawn.Location - Other.Location );
//        DistToLife = VSize( Pawn.Location - Item.Location );
        DistToTarget = VSize( MoveTarget.Location - Other.Location );

        if( DistToOther < 500 )
            return true;

        if( DistToOther > DistToTarget )
            return true;

        return false;
    }

Begin:

    if( Pawn.Physics == PHYS_Falling )
    {
        while( true )
        {
            sleep( 0.1 );

            if ( Pawn.Physics != PHYS_Falling )
               break;
        }
    }

    FindMedKit();

    if( Item == none )
    {
        Sleep( 0.5 );
        RemoveOrder( Order_Life );
    }
    else
    {
        while( true )
        {
            PickUpPathStorage(Item);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                if( ( PathIndex == PathCacheSize-1 ) && ( ! PickUp(Item).ReadyToPickUp(0) ) )
                    Goto('begin');

                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                Pawn.ShouldCrouch( false );
                MoveToward( MoveTarget, Focus , MoveSpeed );
            }

            if( FullPath )
                break;
        }

        if( GetLifePriority() == 0 )
            RemoveOrder( Order_Life );
        else
            ModifyOrder( Order_Life , GetLifePriority() );
    }
}
//__________________________________________________________________
//__________________________________________________________________
//                            Armor
//__________________________________________________________________
//__________________________________________________________________

state Armor
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Armor");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );
    }

Begin:

    if( Pawn.Physics == PHYS_Falling )
    {
        while( true )
        {
            sleep( 0.1 );

            if ( Pawn.Physics != PHYS_Falling )
               break;
        }
    }

    if( Rand( 100 ) < 40 + Skill*20 )
        FindBestArmor();
    else
        FindNearestArmor();


    if( Item == none )
    {
        Sleep( 0.5 );
        RemoveOrder( Order_Armor );
    }
    else
    {
        while( true )
        {
            PickUpPathStorage(Item);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                if( ( PathIndex == PathCacheSize-1 ) && ( ! PickUp(Item).ReadyToPickUp(0) ) )
                    Goto('begin');

                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                Pawn.ShouldCrouch( false );
                MoveToward( MoveTarget, Focus , MoveSpeed );
            }

            if( FullPath )
                break;
        }

        RemoveOrder( Order_Armor );
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            Kill
//__________________________________________________________________
//__________________________________________________________________

state Kill
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Kill");
            Log("    > Enemy :"@Enemy);
        }

        if( ! IsEnemy( Enemy ) )
        {
            Enemy = none ;
            RemoveOrder( Order_Kill );
            return;
        }

        if( Enemy == Pawn )
        {
            Enemy = none ;
            RemoveOrder( Order_Kill );
            return;
        }

        if( FindOrder( Order_TrakNar ) )
            RemoveOrder( Order_TrakNar );

        if( FindOrder( Order_GrenadLauncher ) )
            RemoveOrder( Order_GrenadLauncher );

        FocalPoint = vect(0,0,0);
        Focus = Enemy;
        Pawn.velocity=vect(0,0,0);
        Pawn.acceleration=vect(0,0,0);
        bFireMove = false;

        WaitBeforeFire = true;

        bFire=0;
        SetTimer(0.0,false);
        SetTimer2(0.0,false);
        SetTimer3(0.5,true);

        SetRotation( rotator(Enemy.GetBoneCoords('X Spine1').Origin-(Pawn.Location+Pawn.EyePosition()) ) );
        TimePassedBeforeSeeingMyEnemy = Level.TimeSeconds;
    }

    //--------------------------------------------------------------

    event EndState()
    {
        NbStraffe = 0;
        bFireMove = false;

        bFire=0;
        bFireMove = false;
        SetTimer(0.0,false);
        SetTimer2(0.0,false);
        SetTimer3(0.0,false);

        if( Pawn != none )
        {
            Pawn.ShouldCrouch( false );
            Pawn.Weapon.ForceReload();
        }
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        local vector MyVect,OtherVect;

        if( ( WaitBeforeFire ) && ( Seen == Enemy ) )
        {
            MyVect = Pawn.Location;
            OtherVect = Seen.Location;
            OtherVect.Z = MyVect.Z;

            if( ( normal( OtherVect - MyVect ) dot ( vector( Pawn.Rotation ) ) ) > 0.85 )
            {
                WaitBeforeFire = false;

                if( Rand( 100 ) < 10 + Skill*10 )
                {
                    Pawn.ShouldCrouch( true );
                    InitShotError(True);
                }
                else
                    InitShotError(false);

                if( Pawn.WeaponMode == 'FM_Snipe' )
                {
                    SetTimer( 1.0 + FRand()/2, false );
                }
                else
                    SetTimer( (4-Skill)*0.2+FRand()/2 ,False );
            }
        }

        if( bFireMove )
            return;

        if( ! IsEnemy( Seen ) )
            return;

        else if( IsNearest( Enemy,Seen) )
        {
            Enemy = Seen;
        }
    }

    //--------------------------------------------------------------

    event EnemyNotVisible()
    {
        if( WaitBeforeFire )
            return;

        if( Pawn.bIsCrouched )
            Pawn.ShouldCrouch( false );

        SetTimer(0.0,false);
        SetTimer2(0.0,false);

        bFireMove = false;
        NbStraffe = 0;

        if( ( Rand( 100 ) < 100 - Skill*10 ) || ( Enemy.Health < 70 ) )
        {
            bFire=0;
            AddOrder( 70 ,Order_Seek,"Seek", 0);
            RemoveOrder( Order_Kill );
        }
        else
        {
            bFire=0;
            Enemy = none;

            RemoveOrder( Order_Kill );
        }
    }

    //--------------------------------------------------------------

    event Timer()
    {
        if( MyWeaponIsAGrenad )
        {
            bFire=1;
            Pawn.Weapon.Fire(0);
            bFire=0;

            SetTimer2(0.5,false);
            SetTimer(0.0,false);

            ForceFear = true;
        }
        else if( Pawn.Weapon.WeaponMode == WM_SemiAuto )
        {
            bFire=1;
            Pawn.Weapon.Fire(0);
            bFire=0;

            SetTimer2( Pawn.Weapon.ShotTime + ( 3 - Skill )*0.25,false );
            SetTimer(0.0,false);
        }
        else if ( ( ( Pawn.WeaponMode == 'FM_M16' ) && ( Pawn.Weapon.HasAltAmmo() ) ) && ( VSize( Enemy.Location - Pawn.Location ) < 1600 ) )
        {
            bFire=1;
            Pawn.Weapon.AltFire(0);
            bFire=0;

            SetTimer2( 0.5,false );
            SetTimer(0.0,false);
        }
        else
        {
            bFire=1;
            Pawn.Weapon.Fire(0);

            SetTimer2( 2.5 - skill/2,false );
            SetTimer(0.0,false);
        }
    }

    //--------------------------------------------------------------

    event Timer2()
    {
        if( MyWeaponIsAGrenad )
        {
            Pawn.Weapon.AIRating = 0.11;
            SwitchWeapon();
            SetTimer(1.0,false);
            SetTimer2(0.0,false);
        }
        else if( Pawn.Weapon.WeaponMode == WM_SemiAuto )
        {
            if( Pawn.WeaponMode == 'FM_Snipe' )
                SetTimer(0.01 + FRand()/2,false);
            else
                SetTimer(0.01,false);

            SetTimer2(0.0,false);
        }
        else if ( ( ( Pawn.WeaponMode == 'FM_M16' ) && ( Pawn.Weapon.HasAltAmmo() ) ) && ( VSize( Enemy.Location - Pawn.Location ) < 1600 ) )
        {
            SetTimer(0.1,false);
            SetTimer2(0.0,false);
        }
        else
        {
            bFire=0;
            SetTimer(0.01,false);
            SetTimer2(0.0,false);
        }

        if( ! Pawn.Weapon.HasAmmo() )
            SwitchWeapon();

        if( ( Enemy == none ) || ( Enemy.bIsDead ) )
        {
            Pawn.ShouldCrouch( false );

            bFire=0;
            Enemy = none;

            RemoveOrder( Order_Kill );
        }
    }

    //--------------------------------------------------------------

    event Timer3()
    {
        if( ( Enemy == none ) || (Pawn == none ) || ( Enemy.bIsDead ) )
        {
            if ( Pawn != none )
              Pawn.ShouldCrouch( false );

            bFire=0;
            Enemy = none;

            RemoveOrder( Order_Kill );
            return;
        }

        if( WaitBeforeFire && ( Level.TimeSeconds - TimePassedBeforeSeeingMyEnemy > 1.5 ) )
        {
            AddOrder( 70 ,Order_Seek,"Seek", 0);
            RemoveOrder( Order_Kill );
        }

        SetRotation( rotator(Enemy.GetBoneCoords('X Spine1').Origin-(Pawn.Location+Pawn.EyePosition()) ) );

        if( ( bFireMove ) || ( bBackMove ) )
           return;

        if( VSize( Pawn.Location - Enemy.Location ) < 200 )
            bBackMove = true;
    }

    //--------------------------------------------------------------

    function int CheckStraffe( int Direction )
    {
        local vector              HitLocation;
        local vector              HitNormal;
        local actor               ColActor;
        local int                 StarffeDist;

        if( Direction == 0 )
            NextPosition = Pawn.Location + ( vector(pawn.rotation) cross (vect(0,0,1)) )*10000;
        else
            NextPosition = Pawn.Location + ( vector(pawn.rotation) cross (vect(0,0,1)) )*(-10000);

        ColActor=Trace( HitLocation,HitNormal,NextPosition,Pawn.Location, true);

        StarffeDist = VSize( HitLocation - Pawn.Location );
        return StarffeDist;
    }

    //--------------------------------------------------------------

    function int CheckBackMove()
    {
        local vector              HitLocation;
        local vector              HitNormal;
        local actor               ColActor;
        local int                 StarffeDist;

        ColActor=Trace( HitLocation,HitNormal,NextPosition,Pawn.Location, true);

        StarffeDist = VSize( HitLocation - Pawn.Location );
        return StarffeDist;
    }

    //--------------------------------------------------------------

Begin:


    while( true )
    {
        Sleep( ( 4-skill)*StraffeDelay );

        if( bFireMove )
        {
            if( ( Pawn.bIsCrouched ) && ( Rand( 100 ) < (Skill+1)*20 ) )
                Pawn.ShouldCrouch( false );


            if( ( LastStraffeDir == -1 ) || ( Rand( 100 ) < 50 ) )
                LastStraffeDir = Rand( 2 );

            StraffeValue = CheckStraffe( LastStraffeDir );

            if( StraffeValue > 100 )
            {
                if( LastStraffeDir == 0 )
                    StraffeValue = Min(100+Rand(200),StraffeValue);
                else
                    StraffeValue = Max(-100-Rand(200),-StraffeValue);

                if( Rand(2)==0 )
                    NextPosition = Pawn.Location + ( vector(pawn.rotation) cross (vect(0,0,1)) )*StraffeValue + vector(pawn.rotation)*StraffeValue*FRand()*(-1);
                else
                    NextPosition = Pawn.Location + ( vector(pawn.rotation) cross (vect(0,0,1)) )*StraffeValue + vector(pawn.rotation)*StraffeValue*FRand();
            }
            else
            {
                if( LastStraffeDir == 0 )
                    LastStraffeDir =1;
                else
                    LastStraffeDir =0;

                StraffeValue = CheckStraffe( LastStraffeDir );

                if( StraffeValue > 100 )
                {
                    if( LastStraffeDir == 0 )
                        StraffeValue = Min(100+Rand(200),StraffeValue);
                    else
                        StraffeValue = Max(-100-Rand(200),-StraffeValue);

                    if( Rand(2)==0 )
                        NextPosition = Pawn.Location + ( vector(pawn.rotation) cross (vect(0,0,1)) )*StraffeValue + vector(pawn.rotation)*StraffeValue*FRand()*(-1);
                    else
                        NextPosition = Pawn.Location + ( vector(pawn.rotation) cross (vect(0,0,1)) )*StraffeValue + vector(pawn.rotation)*StraffeValue*FRand();
                }
                else
                    bFireMove = false;
            }


            if( bFireMove )
            {
                MoveTo( NextPosition, Enemy );
                Pawn.velocity=vect(0,0,0);
                Pawn.acceleration=vect(0,0,0);
            }

            if( ( Rand( 100 ) > 30 + Skill*20 ) || ( NbStraffe == Skill+1 ) )
            {
                bFireMove = false;
                NbStraffe = 0;
            }
            else
                NbStraffe++;

            if( Rand( 100 ) < 10 + Skill*10 )
            {
                if( Pawn.bIsCrouched )
                    Pawn.ShouldCrouch( false );
                else
                    Pawn.ShouldCrouch( true );
            }
        }

        else if( bBackMove )
        {
            NextPosition = vector(Pawn.rotation)*(-1000)+Pawn.Location;

            StraffeValue = CheckBackMove();

            if( StraffeValue > 100 )
            {
                StraffeValue = Max(-100-Rand(200),-StraffeValue);
            }
            else
            {
                bBackMove = false;
            }

            NextPosition = vector(Pawn.rotation)*StraffeValue+Pawn.Location;

            if( bBackMove )
            {
                MoveTo( NextPosition, Enemy );
                Pawn.velocity=vect(0,0,0);
                Pawn.acceleration=vect(0,0,0);
                bBackMove = false;
            }

        }
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            Seek
//__________________________________________________________________
//__________________________________________________________________

state Seek
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Seek");

        }

        Pawn.ControllerPitch = 0;

        SeekTime = Level.TimeSeconds;

        Pawn.ShouldCrouch( false );
    }

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( ! PathErrorToAllLife )
        {
            if( FindOrder( Order_Life ) )
                ModifyOrder( Order_Life, GetLifePriority() );
            else
                AddOrder(GetLifePriority(),Order_Life,"Life",0);
        }

        if( ! IsEnemy( Agressor ) )
            return;

        if( Agressor == Pawn )
            return;

        if( ( Agressor == Enemy ) || ( IsNearest( Enemy,Agressor ) ) )
        {
            Enemy = Agressor;
            AddOrder(KillOrderPriority,Order_Kill,"Kill",Order_Seek);
        }
    }

    event SeePlayer( Pawn Seen )
    {
        if( ! IsEnemy( Seen ) )
            return;

        if( ( MyWeaponIsAGrenad ) && ( VSize( Seen.Location - Pawn.Location ) > 1200 ) )
           return;

        if( Seen == Enemy )
        {
            if( IsShootable( Seen ) )
                AddOrder(KillOrderPriority,Order_Kill,"Kill",Order_Seek);
        }
        else if( IsNearest( Enemy,Seen) )
        {
            Enemy = Seen;

            if( IsShootable(Seen) )
                AddOrder(KillOrderPriority,Order_Kill,"Kill",Order_Seek);
            else
                FindPathToMyEnemy();
        }
    }

    function FindPathToMyEnemy()
    {
        local actor Path;

        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : Search for"@Enemy);
        }

        Path = ExtendFindPathToward(Enemy);

//        if( Path == none )
//            Path = FindPathToward(Enemy);

        if( Path == none )
        {
            if( DBugBot ) Log("    > Failed ....");
            Enemy = none;
        }
        else
        {
            MoveTarget = Path;

            if( DBugBot )
                Log("    > Ok");
        }
    }

Begin:

    if( Pawn.Physics == PHYS_Falling )
    {
        while( true )
        {
            sleep( 0.1 );

            if ( Pawn.Physics != PHYS_Falling )
               break;
        }
    }

    Pawn.ShouldCrouch( false );

    if( Enemy != none )
        FindPathToMyEnemy();
    else
    {
        sleep(0.5);
        RemoveOrder( Order_Seek );
    }

    if( Enemy == none )
    {
        if( DBugBot )
            Log("[ BOT"@ID@"] : Enemy Lost");

        sleep(0.5);
        RemoveOrder( Order_Seek );
    }
    else
    {
        ActorPathStorage( Enemy);

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            if( Level.TimeSeconds - SeekTime > MaxSeekTime )
                Enemy = none;

            if( ( Enemy == none ) || ( Enemy.bIsDead ) )
                RemoveOrder( Order_Seek );

            Pawn.ShouldCrouch( false );
            MoveToward( MoveTarget, Focus , MoveSpeed );
        }
    }

    if( ( Enemy == none ) || ( Enemy.bIsDead ) )
        RemoveOrder( Order_Seek );
    else
        Goto('Begin');
}

//__________________________________________________________________
//__________________________________________________________________
//                            Dead
//__________________________________________________________________
//__________________________________________________________________

state Dead
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Dead");
            Log("    > ReSpawnTime"@RespawnTime$"sec");
        }

        bFire = 0;

        if( NavToUpDate != none )
        {
            NavToUpDate.bSpecialCost=false;
            NavToUpDate = none;
        }

        if( CheckGameEnded() )
        {
            if( DBugBot )
                Log("[ AntiBug ][ BOT"@ID@"] : Dead --> GameEnded");

            GotoState('GameEnded');
        }
        else
            SetTimer( RespawnTime + 6 , false);
    }

    event EndState()
    {
       SetTimer(0.0, false );
    }


    event HearNoise( float Loudness, Actor NoiseMaker);
    event SeePlayer( Pawn Seen );
    function SomeoneWantKillMe( Pawn Agressor );

    event Timer( )
    {
        Log("[ BOT"@ID@"] : Force ReInit");
        SetTimer(0.0,false);
        SetTimer2(0.0,false);
        Initialize( ID,Skill,MyName );
    }

    function bool CheckGameEnded()
    {
    	local Controller C;
    	local bool IsGameEnded;

    	IsGameEnded = false;

    	for ( C=Level.ControllerList; C!=None; C= C.NextController )
    	{
            if( C.IsInState('GameEnded') )
            {
            	IsGameEnded = true;
            	break;
            }
    	}

    	return IsGameEnded;
    }

Begin:

    sleep( 0.5 );

    if( CheckGameEnded() )
    {
        if( DBugBot )
            Log("[ AntiBug ][ BOT"@ID@"] : Dead --> GameEnded");

        GotoState('GameEnded');
    }

    Sleep(RespawnTime);

    if( CheckGameEnded() )
    {
        if( DBugBot )
            Log("[ AntiBug ][ BOT"@ID@"] : Dead --> GameEnded");

        GotoState('GameEnded');
    }
    super.ServerReStartPlayer();
    Initialize( ID,Skill,MyName );
}

//__________________________________________________________________
//__________________________________________________________________
//                            Jumping
//__________________________________________________________________
//__________________________________________________________________

state Jumping
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Jumping");
        }
    }

    event HearNoise( float Loudness, Actor NoiseMaker);
    event SeePlayer( Pawn Seen );
    function SomeoneWantKillMe( Pawn Agressor );

begin:

    if( JumpTarget != none )
    {
        Focus = none;
        FocalPoint = (JumpTarget.Location-Pawn.Location)*10000+Pawn.Location;
        Pawn.Velocity = vector( rotator(JumpTarget.Location-Pawn.Location ) )*JumpSpeed;
    }
    else
        Pawn.Velocity = vector( Pawn.Rotation)*JumpSpeed;

    Pawn.JumpZ = JumpHeight;
    Pawn.DoJump( true );

    while( bIsJumping )
    {
       sleep(0.1);
    }

    FindMostImportantOrder();
    ChangeState();
}

//__________________________________________________________________
//__________________________________________________________________
//                            Blind
//__________________________________________________________________
//__________________________________________________________________

state Blind
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> @#$#%$ I'm Flashed");
        }

        Pawn.ShouldCrouch( true );
        Enemy = none;

        if( MyWeaponIsAGrenad )
            SwitchWeapon();
    }

    function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
    {
    	local rotator RotatorError;
    	local float ErrorDelay, ErrorFactor, ShotError;

    	if( Enemy == none )
        	return ( Rotation );

        if( Rand( 100 ) > (Skill+1)*5 )
        {
            ShotError = 200 + Rand( 400 ) - Skill*50;

            if( Rand( 2 ) == 1 )
                RotatorError.Yaw = ShotError;
            else
                RotatorError.Yaw = 65535-ShotError;
        }

        SetRotation( rotator(Enemy.GetBoneCoords('X Spine1').Origin-(Pawn.Location+Pawn.EyePosition()) ) );
        Pawn.ControllerPitch = Rotation.Pitch / 256;

        return ( Rotation + RotatorError );
    }

    event HearNoise( float Loudness, Actor NoiseMaker)
    {
        if( Enemy != none )
            return;

        if( Pawn( NoiseMaker ) != none )
        {
            Enemy = Pawn( NoiseMaker );
            Focus = Enemy;
        }
    }

    event SeePlayer( Pawn Seen );
    function SomeoneWantKillMe( Pawn Agressor );

begin:

    while( DamnedImFlashed )
    {
        if( ( Enemy != none ) && ( ! MyWeaponIsAGrenad ) )
        {
            Focus = Enemy;

            if( Pawn.Weapon.WeaponMode == WM_SemiAuto )
            {
                bFire=1;
                Pawn.Weapon.Fire(0);
                bFire=0;

                Sleep( Pawn.Weapon.ShotTime );
            }
            else
            {
                bFire=1;
                Pawn.Weapon.Fire(0);
                Sleep( 2.5 - skill/2 );
                bFire=0;
            }

            Sleep( 2.5 - skill/2 );
        }
        else
            sleep(0.1);
    }

    FindMostImportantOrder();
    ChangeState();
}

//__________________________________________________________________
//__________________________________________________________________
//                            SnipeSpot
//__________________________________________________________________
//__________________________________________________________________

state SnipeSpot
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Go To Good Snipe Spot");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;
        Pawn.ShouldCrouch( false );
    }

    event HearNoise( float Loudness, Actor NoiseMaker);

    event SeePlayer( Pawn Seen )
    {
        if( ! IsEnemy( Seen ) )
            return;

        if( IsShootable( Seen ) )
        {
            Enemy = Seen;

            AddOrder(KillOrderPriority,Order_Kill,"Kill",Order_SnipeSpot);
        }
    }

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( Agressor == Pawn )
            return;

        if( ! IsEnemy( Agressor ) )
            return;

        Enemy = Agressor;
        AddOrder(KillOrderPriority,Order_Kill,"Kill",Order_SnipeSpot);
    }

    function FindGoodSnipeSpot()
    {
        if( SnipeSpotList.Length == 0 )
            SnipePoint = none;
        else
            SnipePoint = SnipeSpotList[Rand( SnipeSpotList.Length)];
    }

Begin:

    FindGoodSnipeSpot();

    if( SnipePoint != none )
    {
        while( true )
        {
            NavPathStorage(SnipePoint);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                MoveToward( MoveTarget, Focus , MoveSpeed );
            }

            if( FullPath )
                break;
        }
    }

    AddOrder(KillOrderPriority,Order_SnipeAndKill,"Order_SnipeAndKill",Order_SnipeSpot);
}


//__________________________________________________________________
//__________________________________________________________________
//                            SnipeAndKill
//__________________________________________________________________
//__________________________________________________________________

state SnipeAndKill
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> SnipeAndKill");
        }

        Pawn.velocity=vect(0,0,0);
        Pawn.acceleration=vect(0,0,0);
        Focus = none;
        FocalPoint = vector(SnipePoint.rotation)+Pawn.Location;

        if( SnipePathNode(SnipePoint).bDoNotCrouch )
            Pawn.ShouldCrouch( false );
        else
            Pawn.ShouldCrouch( true );

        SnipeTime = Level.TimeSeconds;
        MaxSnipeTime = 30 + Rand( 30 );
    }

    event EndState()
    {
        bFire=0;
    }

    event EnemyNotVisible()
    {
        Enemy = none;
        SetRotation( SnipePoint.Rotation );
        Pawn.ControllerPitch = Rotation.Pitch / 256;
    }

    event SeePlayer( Pawn Seen )
    {
        if( ! IsEnemy( Seen ) )
            return;

        if( Enemy == none )
        {
            if( IsShootable(Seen) )
                Enemy = Seen;
        }
        else if( Seen == Enemy )
        {
            if( ! IsShootable(Seen) )
                Enemy = none;
        }
    }

    function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
    {
    	local rotator RotatorError;
    	local float ShotError;
    	local int HeadShotPercent;

    	if( Enemy == none )
        	return ( Rotation );

        if( MissTheShoot() )
        {
            // Miss

            ShotError = 200 + Rand(400);

            if( Rand( 2 ) == 1 )
                RotatorError.Yaw = ShotError;
            else
                RotatorError.Yaw = 65535-ShotError;
        }
        else
            HeadShotPercent = 60 + Skill*10 ;


        if( Rand( 100 ) < HeadShotPercent )
        {
            SetRotation( rotator(Enemy.GetBoneCoords('X Head').Origin-(Pawn.Location+Pawn.EyePosition()) ) );
            Pawn.ControllerPitch = Rotation.Pitch / 256;
        }
        else
        {
            SetRotation( rotator(Enemy.GetBoneCoords('X Spine1').Origin-(Pawn.Location+Pawn.EyePosition()) ) );
            Pawn.ControllerPitch = Rotation.Pitch / 256;
        }

        return ( Rotation + RotatorError );
    }

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( ! PathErrorToAllLife )
        {
            if( FindOrder( Order_Life ) )
                ModifyOrder( Order_Life, GetLifePriority() );
            else
                AddOrder(GetLifePriority(),Order_Life,"Life",0);
        }

        if( ! IsEnemy( Agressor ) )
            return;

        if( Agressor == Enemy )
            return;

        if( Agressor == Pawn )
            return;

        if( ( Enemy == none ) || ( IsNearest( Enemy,Agressor) )  )
            Enemy = Agressor;
    }

Begin:

    if( Pawn.WeaponMode != 'FM_Snipe' )
        RemoveOrder( Order_SnipeAndKill );

    while( true )
    {
        if( Enemy != none )
        {
            Focus = enemy;

            AimTime = 0.5 + FRand();
            Sleep( AimTime );

            bFire=1;

            sleep( Pawn.Weapon.ShotTime );

            Pawn.Weapon.Fire(0);
            bFire=0;

            if( ! Pawn.Weapon.HasAmmo() )
                RemoveOrder( Order_SnipeAndKill );
        }
        else
            Sleep( 0.2 );

        if( ( Enemy == none ) || ( Enemy.bIsDead ) )
        {
            Enemy = none;
            bFire=0;

            if( Level.TimeSeconds - SnipeTime > MaxSnipeTime )
                RemoveOrder( Order_SnipeAndKill );
        }
    }
}


//__________________________________________________________________
//__________________________________________________________________
//                            UnBlock
//__________________________________________________________________
//__________________________________________________________________

state UnBlock
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> UnBlock");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;
        Pawn.ShouldCrouch( false );
    }

    //--------------------------------------------------------------

    event EndState()
    {
        TrakNarPoint = none;
    }

    //--------------------------------------------------------------

    function GetRandomUnblockPoint()
    {
        local NavigationPoint Nav;
        local Array<NavigationPoint> UseablePoint;

        Nav = Level.NavigationPointList;

        while( Nav != none)
        {
            if( Nav.IsA('PlayerStart') )
            {
                UseablePoint.Length = UseablePoint.Length+1;
                UseablePoint[ UseablePoint.Length-1 ] = Nav;
            }

            Nav = Nav.NextNavigationPoint;
        }

        TrakNarPoint = UseablePoint[ Rand(UseablePoint.Length) ];
    }

    //--------------------------------------------------------------

Begin:

    if( Pawn.Physics == PHYS_Falling )
    {
        while( true )
        {
            sleep( 0.1 );

            if ( Pawn.Physics != PHYS_Falling )
               break;
        }
    }

    Pawn.ShouldCrouch( false );

    GetRandomUnblockPoint();

    if( TrakNarPoint == none )
    {
        log("!!! OUPS !!!");
        Sleep(3.0);
        RemoveOrder( Order_UnBlock );
    }

    while( true )
    {
        NavPathStorage(TrakNarPoint);

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            MoveToward( MoveTarget, Focus , MoveSpeed );
        }

        if( FullPath )
            break;
    }

    RemoveOrder( Order_UnBlock );
}



//__________________________________________________________________
//__________________________________________________________________
//                            TrakNar
//__________________________________________________________________
//__________________________________________________________________

state TrakNar
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> TrakNar");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );
    }

    event EndState()
    {
        if( Pawn != none )
            Pawn.SpineYawControl(false,3000, 1.2);
    }

    event HearNoise( float Loudness, Actor NoiseMaker);

    function FindGoodTrakNarSpot()
    {
        if( TrakNarSpotList.Length == 0 )
            TrakNarPoint = none;
        else
            TrakNarPoint = TrakNarSpotList[Rand( TrakNarSpotList.Length)];
    }

Begin:

    if( Pawn.Physics == PHYS_Falling )
    {
        while( true )
        {
            sleep( 0.1 );

            if ( Pawn.Physics != PHYS_Falling )
               break;
        }
    }

    Pawn.ShouldCrouch( false );

    FindGoodTrakNarSpot();

    if( TrakNarPoint != none )
    {
        while( true )
        {
            NavPathStorage(TrakNarPoint);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                Pawn.ShouldCrouch( false );
                MoveToward( MoveTarget, Focus , MoveSpeed );
            }

            if( FullPath )
                break;
        }
    }

    if( Beretta(Pawn.Weapon) == none )
    {
        Pawn.velocity=vect(0,0,0);
        Pawn.acceleration=vect(0,0,0);
        Focus = none;
        FocalPoint = vector(TrakNarPoint.Rotation)+Pawn.Location;

        if( ( Rand( 100 ) < 20 + Skill*20 ) || ( TrakNarPathNode(TrakNarPoint).bShouldCrouch ) )
        {
            Pawn.ShouldCrouch( true );
            InitShotError(True);
        }
        else
            InitShotError(false);

        Pawn.SpineYawControl(true,3000, 1.2);

        Sleep( 10 + Rand( 5 ) );
    }

    RemoveOrder(Order_TrakNar);
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
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> GameEnded");
        }

        bFire=0;
        Enemy = none;

		if (pawn!=none)
		{
        Pawn.ControllerPitch = 0;
        Pawn.ShouldCrouch( false );
        Pawn.velocity=vect(0,0,0);
        Pawn.acceleration=vect(0,0,0);
		}

        SetTimer(0.0,false);
        SetTimer2(0.0,false);
        SetTimer3(0.0,false);

        if( NavToUpDate != none )
        {
            NavToUpDate.bSpecialCost=false;
            NavToUpDate = none;
        }
    }

    event HearNoise( float Loudness, Actor NoiseMaker);
    event SeePlayer( Pawn Seen );
    function SomeoneWantKillMe( Pawn Agressor );

    event Timer();
    event Timer2();
    event Timer3();
}

//__________________________________________________________________
//__________________________________________________________________
//                            GrenadLauncher
//__________________________________________________________________
//__________________________________________________________________

state GrenadLauncher
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Grenad Launcher");
            Log("    > Target :"@MyGrenadTarget.Target);
        }

        Focus = MyGrenadTarget.Target;
        Pawn.velocity=vect(0,0,0);
        Pawn.acceleration=vect(0,0,0);

        if( GrenadIsLauched )
            RemoveOrder( Order_GrenadLauncher );
    }

    //--------------------------------------------------------------

    event EndState()
    {
        bFire=0;
        SetTimer(0.0,false);
        SetTimer2(0.0,false);
        GrenadIsLauched = true;
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        if( Focus == none )
            global.SeePlayer( Seen );
    }

    //--------------------------------------------------------------

    event EnemyNotVisible();

    //--------------------------------------------------------------

    event HearNoise( float Loudness, Actor NoiseMaker);

    //--------------------------------------------------------------

    event Timer()
    {
        bFire=1;
        Pawn.Weapon.Fire(0);

        SetTimer2(0.5,false);
        SetTimer(0.0,false);
    }

    //--------------------------------------------------------------

    event Timer2()
    {
        bFire=0;
        Pawn.Weapon.AIRating = 0.11;
        SwitchWeapon();

        SetTimer2(0.0,false);

        gotostate('GrenadLauncher','GoToHide');
    }

    //--------------------------------------------------------------

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( Focus == none )
            global.SomeoneWantKillMe( Agressor );
    }


    //--------------------------------------------------------------

Begin:

    While( true )
    {
        Sleep( 0.5 );

        if( ( FlashBangBot(Pawn.Weapon) != none ) || ( Grenad(Pawn.Weapon) != none ) )
        {
            SetTimer( 0.5, false );
            gotostate('GrenadLauncher','WaitToLauch');
        }
    }

WaitToLauch:

    While( true )
    {
        Sleep( 0.5 );
    }

GoToHide:

    Pawn.ControllerPitch = 0;

    while( true )
    {
        NavPathStorage(MyGrenadTarget.HidePoint);

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            MoveToward( MoveTarget, Focus , MoveSpeed );
        }

        if( FullPath )
            break;
    }

    Enemy = none;

    Pawn.velocity=vect(0,0,0);
    Pawn.acceleration=vect(0,0,0);

    Focus = none;
    FocalPoint = vector(MyGrenadTarget.HidePoint.Rotation)*1000+Pawn.Location;

    Sleep( 2.0 );

    if ( DBugOrder ) log("RemoveOrder Order_GrenadLauncher");

    RemoveOrder( Order_GrenadLauncher );
}

//__________________________________________________________________




defaultproperties
{
     Id=-1
     MaxShotErrorTime=4.000000
     RespawnTime=4
     MaxSeekDist_Life=1500
     MaxSeekDist_Weapon=1500
     MaxSeekDist_Armor=1500
     AttackArea=1000
     MissPercent=5.000000
     StraffeDelay=0.150000
     bIsPlayer=True
     PlayerReplicationInfoClass=Class'XIII.XIIIPlayerReplicationInfo'
}
