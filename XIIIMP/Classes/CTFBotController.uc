//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CTFBotController extends TeamBotController;

var XIIIMPFlag MyFlag,EnemyFlag;
var Array<NavigationPoint> HideSpotList;
var Array<NavigationPoint> GoPointList;
var Array<NavigationPoint> BackPointList;
var Array<NavigationPoint> GuardPointList;
var Array<NavigationPoint> WaitPointList;
var NavigationPoint HidePoint,TacticalPoint;
var int GoPhase,BackPhase,MaxHideTime,HideTime , ProtectTime, MaxProtectTime;
var NavigationPoint LastGoPointUsed,LastBackPointUsed;
var bool StopProtect;
var bool JustRespawn;
var bool ReadyToAttack;
var XIIIMPCTFStorage StorageObj;
var bool SeekAndFire;
var float LastSeeTime;
var bool NearTheFlag;
var bool DontChangeTactikalPoint;
var float LastTestTime;


const Order_CaptureTheFlag    = 1024;
const Order_ProtectTheFlag    = 2048;
const Order_SeekTheFlag       = 4096;
const Order_BringBackTheFlag  = 8192;
const Order_GoToSafePoint     = 16384;
const Order_WaitToFlagComeBack= 32768;
const Order_WaitBeforeAttack  = 8388608;
const Order_ProtectTheHolder  = 16777216; //24

const cAttack = 0;
const cDefense = 1;
const cSupport = 2;

const cHome = 0;
const cHeld = 1;
const cDropped = 2;


//__________________________________________________________________

function bool CanTryToHelp(TeamBotController Bot)
{
    if( Bot.Enemy != none )
        return false;

    if( Bot.IsInState('Dead') || Bot.IsInState('GameEnded') )
        return false;
    else if( Bot.IsInState('BringBackTheFlag') || Bot.IsInState('GoToSafePoint') )
        return false;
    else if( Bot.IsInState('WaitToFlagComeBack') )
        return false;
    else
        return true;
}

//__________________________________________________________________

function GrenadPossibility( GrenadPathNode GrenadNode )
{
    if( GrenadNode.Team != TeamID )
        return;

    if( ! IsInState('CaptureTheFlag') )
        return;

    super.GrenadPossibility( GrenadNode );
}

//__________________________________________________________________

function UpDateOrder(int OldOrder,int NewOrder)
{
    if( DBugBot )
    {
        Log("");
        Log("[ BOT"@ID@"] : UpDateOrder Role"@TeamRole@"->"@NewOrder);
    }

    if( NewOrder == TeamRole )
        return;

    TeamRole = NewOrder;


    if( Pawn == EnemyFlag.Holder )
    {
        if( DBugBot )
            Log(" > Disable, bring back the flag !");

        return;
    }

    LastDefaultOrderTime=0;
    ClearAllOrders();
}

//__________________________________________________________________

event Timer()
{
    if( MyWeaponIsAGrenad )
    {
        bFire=1;
        Pawn.Weapon.Fire(0);
        bFire=0;

        SetTimer2(0.5,false);
        SetTimer(0.0,false);
    }
    else if( XIIIWeapon(Pawn.Weapon).WeaponMode == WM_SemiAuto )
    {
        bFire=1;
        Pawn.Weapon.Fire(0);
        bFire=0;

        SetTimer2( XIIIWeapon(Pawn.Weapon).ShotTime + ( 3 - Skill )*0.25,false );
        SetTimer(0.0,false);
    }
    else if ( ( ( XIIIPawn(Pawn).WeaponMode == 'FM_M16' ) && ( XIIIWeapon(Pawn.Weapon).HasAltAmmo() ) ) && ( VSize( Enemy.Location - Pawn.Location ) < 1600 ) )
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

//__________________________________________________________________

event Timer2()
{
    if( MyWeaponIsAGrenad )
    {
        Pawn.Weapon.AIRating = 0.11;
        SwitchWeapon();
        SetTimer(1.0,false);
        SetTimer2(0.0,false);
    }
    else if( XIIIWeapon(Pawn.Weapon).WeaponMode == WM_SemiAuto )
    {
        if( XIIIPawn(Pawn).WeaponMode == 'FM_Snipe' )
            SetTimer(0.01 + FRand()/2,false);
        else
            SetTimer(0.01,false);

        SetTimer2(0.0,false);
    }
    else if ( ( ( XIIIPawn(Pawn).WeaponMode == 'FM_M16' ) && ( XIIIWeapon(Pawn.Weapon).HasAltAmmo() ) ) && ( VSize( Enemy.Location - Pawn.Location ) < 1600 ) )
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
        bFire=0;
        Enemy = none;
        Pawn.ControllerPitch = 0;
        SeekAndFire=false;
        SetTimer(0.0,false);
        SetTimer2(0.0,false);

        if( IsInState('Kill') )
            RemoveOrder( Order_Kill );
    }
}

//__________________________________________________________________

function CatchFlag()
{
    if( GetFlagState( MyFlag ) == cHome )
    {
        BackPhase = 0;
        AddOrder( 75 , Order_BringBackTheFlag , "BringBackTheFlag",0);
    }
    else
    {
        BackPhase = 0;
        AddOrder( 75 , Order_GoToSafePoint , "Go To Safe Point",0);
    }

    if( FindOrder( Order_CaptureTheFlag ) )
        RemoveOrder( Order_CaptureTheFlag );

    ForceOtherTeamBotToHelpTheFlagHolder();
}

//__________________________________________________________________

function ForceOtherTeamBotToHelpTheFlagHolder()
{
    local int Loop;

    for( Loop=0;Loop<MyTeam.Length;Loop++ )
    {
        if( ( MyTeam[ Loop ].TeamRole != cDefense ) && ( ! MyTeam[ Loop ].IsInState('Dead') ) )
        {
            MyTeam[ Loop ].LastDefaultOrderTime=0;

            if( ! MyTeam[ Loop ].FindOrder( Order_ProtectTheHolder ) )
            {
                MyTeam[ Loop ].Leader = EnemyFlag.Holder;
                MyTeam[ Loop ].AddOrder( 65,Order_ProtectTheHolder,"Protect The Holder",0);
            }
        }
        else if( ( MyTeam[ Loop ].TeamRole == cDefense ) && ( FindOrder( Order_CaptureTheFlag ) ) )
        {
            RemoveOrder( Order_CaptureTheFlag );
        }
    }
}

//__________________________________________________________________

function ForceTheBotToHelpTheHumanFlagHolder()
{
    if( ( TeamRole != cDefense ) && ( ! IsInState('Dead') ) )
    {
        LastDefaultOrderTime=0;

        if( ! FindOrder( Order_ProtectTheHolder ) )
        {
            Leader = EnemyFlag.Holder;
            AddOrder( 65,Order_ProtectTheHolder,"Protect The Holder",0);
        }
    }
    else if( ( TeamRole == cDefense ) && ( FindOrder( Order_CaptureTheFlag ) ) )
    {
        RemoveOrder( Order_CaptureTheFlag );
    }
}

//__________________________________________________________________

function FindTeamRole()
{
    local int Loop,BestLevel,SecondBestLevel,WorstLevel;
    local CTFBotController Best,SecondBest,Worst;
    local Array<CTFBotController> TmpTeam;
    local CTFBotController Bot;


//    TeamRole = cDefense;
//    return;


    foreach DynamicActors(class'CTFBotController', BOT)
    {
        if( Bot.TeamID == TeamID )
        {
            TmpTeam.Length = TmpTeam.Length+1;
            TmpTeam[ TmpTeam.Length-1 ] = BOT;
        }
    }


    for( Loop=0;Loop<TmpTeam.Length;Loop++)
    {
        if( ( TmpTeam[Loop].Skill > BestLevel ) || ( Best == none ) )
        {
            BestLevel = TmpTeam[Loop].Skill;
            Best = TmpTeam[Loop];
        }
    }

    if( Best == self )
    {
        TeamRole = cAttack;
        return;
    }

    for( Loop=0;Loop<TmpTeam.Length;Loop++)
    {
        if( ( TmpTeam[Loop].Skill > SecondBestLevel ) || ( SecondBest == none ) )
        {
            if( TmpTeam[Loop] != Best )
            {
                SecondBestLevel = TmpTeam[Loop].Skill;
                SecondBest = TmpTeam[Loop];
            }
        }
    }

    if( SecondBest == self )
    {
        TeamRole = cDefense;
        return;
    }

    for( Loop=0;Loop<TmpTeam.Length;Loop++)
    {
        if( ( TmpTeam[Loop].Skill < WorstLevel ) || ( Worst == none ) )
        {
            if( ( TmpTeam[Loop] != Best ) && ( TmpTeam[Loop] != SecondBest ) )
            {
                WorstLevel = TmpTeam[Loop].Skill;
                Worst = TmpTeam[Loop];
            }
        }
    }

    if( Worst == self )
    {
        TeamRole = cDefense;
        return;
    }

    TeamRole = cAttack;
}


//__________________________________________________________________

function InitPickUpList()
{
    local PickUp A;
    local NavigationPoint Nav;
    local Pawn P;
    local TeamBotController Bot;
    local int Loop;
//    local XIIIMPBotInteraction BI;
	local Controller C;
	local XIIIMPFlag TmpFlag;
    local XIIIMPWatchPoint Watch;

    bInitPickUpList = true;


    foreach AllActors(class'XIIIMPWatchPoint', Watch)
    {
        WatchPointList.Length = WatchPointList.Length+1;
        WatchPointList[ WatchPointList.Length-1 ] = Watch;
    }


//	for ( C=Level.ControllerList; C!=None; C= C.NextController )
//	{
//		  if( XIIIMPPlayerController(C) != none )
//        {
//            if( C.PlayerReplicationInfo.Team.TeamIndex == TeamID )
//            {
//                BI = XIIIMPBotInteraction(XIIIMPPlayerController(C).MyInteraction );
//                BI.BotControllerList.Length = BI.BotControllerList.Length+1;
//                BI.BotControllerList[ BI.BotControllerList.Length-1 ] = self;
//            }
//
//            //break;   //FRD il  peut ya voir plusieurs players en splite
//        }
//	}


    foreach DynamicActors(class'XIIIMPCTFStorage', StorageObj)
    {
        if( StorageObj.TeamId == TeamId )
            break;
    }

    Nav = Level.NavigationPointList;

    while( Nav != none)
    {
        if( SnipePathNode( Nav) != none )
        {
            if( ( ( SnipePathNode( Nav ).Team == TeamID ) || ( SnipePathNode( Nav ).Team == 2 ) ) && ( SnipePathNode( Nav).BotLevel <= Skill ) )
            {
                SnipeSpotList.Length = SnipeSpotList.Length+1;
                SnipeSpotList[ SnipeSpotList.Length-1 ] = Nav;
            }
        }

        if( SafePathNode( Nav) != none )
        {
            if( ( ( SafePathNode( Nav ).Team == TeamID ) || ( SafePathNode( Nav ).Team == 2 ) ) && ( SafePathNode( Nav).BotLevel <= Skill ) )
            {
                HideSpotList.Length = HideSpotList.Length+1;
                HideSpotList[ HideSpotList.Length-1 ] = Nav;
            }
        }

        if( GuardPathNode( Nav) != none )
        {
            if( ( ( GuardPathNode( Nav ).Team == TeamID ) || ( GuardPathNode( Nav ).Team == 2 ) ) && ( GuardPathNode( Nav).BotLevel <= Skill ) )
            {
                if( GuardPathNode( Nav ).CanBeUsedByTheAttackTeam )
                {
                    WaitPointList.Length = WaitPointList.Length+1;
                    WaitPointList[ WaitPointList.Length-1 ] = Nav;
                }
                else
                {
                    GuardPointList.Length = GuardPointList.Length+1;
                    GuardPointList[ GuardPointList.Length-1 ] = Nav;
                }
            }
        }

        if( TacticalPathNode( Nav) != none )
        {
            if( ( ( TacticalPathNode( Nav ).Team == TeamID ) || ( TacticalPathNode( Nav ).Team == 2 ) ) && ( TacticalPathNode( Nav).BotLevel <= Skill ) )
            {
                if( ( TacticalPathNode( Nav).Direction == 0 ) || ( TacticalPathNode( Nav).Direction == 2 ) )
                {
                    GoPointList.Length = GoPointList.Length+1;
                    GoPointList[ GoPointList.Length-1 ] = Nav;
                }

                if( ( TacticalPathNode( Nav).Direction == 1 ) || ( TacticalPathNode( Nav).Direction == 2 ) )
                {
                    BackPointList.Length = BackPointList.Length+1;
                    BackPointList[ BackPointList.Length-1 ] = Nav;
                }
            }
        }

        Nav = Nav.NextNavigationPoint;
    }

    if( ( WaitPointList.Length == 0 ) && ( GuardPointList.Length != 0 ) )
    {
        for( Loop=0;Loop<GuardPointList.Length;Loop++)
        {
            WaitPointList.Length = WaitPointList.Length+1;
            WaitPointList[ WaitPointList.Length-1 ] = GuardPointList[Loop];
        }
    }

    foreach DynamicActors(class'PickUp', A)
    {
        FullPickUpList.Length = FullPickUpList.Length+1;
        FullPickUpList[ FullPickUpList.Length-1 ] = A;

        if ( MultiPlayerMedPickUp(A) != none )
        {
            MedKitList.Length = MedKitList.Length+1;
            MedKitList[ MedKitList.Length-1 ] = MultiPlayerMedPickUp(A);
        }
        else if( XIIIWeaponPickUp(A) != none )
        {
            WeaponList.Length = WeaponList.Length+1;
            WeaponList[ WeaponList.Length-1 ] = XIIIWeaponPickUp(A);
        }
        else if( XIIIArmorPickUp(A) != none )
        {
            ArmorList.Length = ArmorList.Length+1;
            ArmorList[ ArmorList.Length-1 ] = XIIIArmorPickUp(A);
        }
    }

    foreach DynamicActors(class'TeamBotController', BOT)
    {
        if( ( Bot.TeamID == TeamID ) && ( BOT != self ) )
        {
            MyTeam.Length = MyTeam.Length+1;
            MyTeam[ MyTeam.Length-1 ] = BOT;
        }
    }

    FindTeamRole();

    if( DBugBot )
    {
        Log("");
        Log("[ BOT"@ID@"][ Team"@TeamID@"][ Level"@int(Skill)@"] : PickUpList Construction");
        log("    > MedKit="$MedKitList.Length);
        log("    > Weapon="$WeaponList.Length);
        log("    > Armor="$ArmorList.Length);
        log("    > SnipePoint="$SnipeSpotList.Length);
        Log("    > Other Team Bot :"@MyTeam.Length );

        if( MyTeam.Length != 0 )
        {
            for( Loop = 0 ; Loop < MyTeam.Length ; Loop++ )
                 log("     "@Loop@":"@MyTeam[ Loop ]);

            Leader = MyTeam[ 0 ].Pawn;
        }

        Log("    > SafePoint="$HideSpotList.Length);
        If( TeamRole == 0 )
            Log("    > Role("$TeamRole$")=Attack");
        else If( TeamRole == 1 )
            Log("    > Role("$TeamRole$")=Defense");
        else
            Log("    > Role("$TeamRole$")=Support");
        Log("    > GoPoint="$GoPointList.Length);
        Log("    > BackPoint="$BackPointList.Length);
        Log("    > GuardPoint="$GuardPointList.Length);
        Log("    > WaitPoint="$WaitPointList.Length);
        log("    > WatchPoint="$WatchPointList.Length);
    }

    foreach DynamicActors(class'XIIIMPFlag', TmpFlag)
    {
        if ( PlayerReplicationInfo.Team == TmpFlag.Team )
           MyFlag = TmpFlag;
        else
           EnemyFlag = TmpFlag;
    }
}

//__________________________________________________________________

function int GetFlagState(XIIIMPFlag F)
{
    if ( F.bHome )
        return cHome;
    else if ( F.bHeld )
        return cHeld;
    else
        return cDropped;
}

//__________________________________________________________________

function FlagPathStorage( actor Target)
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

    if( GetFlagState( XIIIMPFlag(Target) ) == 2 ) // Dropped
    {
        MoveTarget = FindPathToward(Target);

        if( MoveTarget == none ) // StaticMesh
            MoveTarget = FindPathTo(Target.Location + vect(0,0,70) );
    }
    else
        MoveTarget = ExtendFindPathToward(Target);


    PathCacheSize = 0;

    if( MoveTarget == none )
    {
        PathCacheSize = 0;
        FullPath=false;
    }
    else
    {
        for( Loop=0;Loop<16;Loop++)
        {
            if( RouteCache[ Loop ] == none )
                break;

//            log(" >"@Loop@":"@RouteCache[ Loop ]);

            PathCache[ Loop ] = RouteCache[ Loop ];

            PathCacheSize++;
        }

        FullPath = ( XIIIMPFlagBase(PathCache[ PathCacheSize-1 ]) != none );

        if( ! FullPath )
            FullPath = ( XIIIMPFlag(PathCache[ PathCacheSize-1 ]) != none );
    }

//    log("");
}

//__________________________________________________________________

event AddDefaultOrders()
{
    super(BotController).AddDefaultOrders();

    GoPhase=0;
    BackPhase=0;


    switch( TeamRole )
    {
        case cAttack :
        case cSupport :

             if( GetFlagState( MyFlag ) == cHome )
             {
                 //log("GetFlagState="@GetFlagState( EnemyFlag ));

                 if( GetFlagState( EnemyFlag ) != cHeld )
                 {
                    if( JustRespawn )
                        AddOrder( 39 , Order_WaitBeforeAttack , "Wait Before Attack",0);

                    AddOrder( 38 , Order_CaptureTheFlag , "Attack The Flag",0);
                 }
                 else
                 {
                    Leader = EnemyFlag.Holder;
                    AddOrder( 65,Order_ProtectTheHolder,"Protect The Holder",0);
                 }
             }
             else
                AddOrder( 75 , Order_SeekTheFlag , "Retrive My Flag",0);

             break;

        case cDefense :

             if( GetFlagState( MyFlag ) == cHome )
                AddOrder( 50 , Order_ProtectTheFlag , "Protect The Flag",0);
             else
                AddOrder( 75 , Order_SeekTheFlag , "Retrive My Flag",0);

             break;
    }
}

//__________________________________________________________________

event ChangeState()
{
    if( DBugOrder ) LogOrderList();

    switch( CurrentOrder.TypeId )
    {
        case Order_CaptureTheFlag : GotoState( 'CaptureTheFlag' ); break;
        case Order_ProtectTheFlag : gotoState( 'ProtectTheFlag' ); break;
        case Order_SeekTheFlag : GotoState( 'SeekTheFlag' ); break;
        case Order_BringBackTheFlag : GotoState( 'BringBackTheFlag' ); break;
        case Order_GoToSafePoint : GotoState( 'GoToSafePoint' ); break;
        case Order_WaitToFlagComeBack : GotoState( 'WaitToFlagComeBack' ); break;
        case Order_WaitBeforeAttack : GotoState( 'WaitBeforeAttack' ); break;
        case Order_ProtectTheHolder : GotoState( 'ProtectTheHolder' ); break;
        case Order_Grouping : GotoState( 'Grouping' ); break;
        case Order_UnBump : gotoState( 'UnBump' ); break;
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
//__________________________________________________________________
//                            CaptureTheFlag
//__________________________________________________________________
//__________________________________________________________________

state CaptureTheFlag
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> CaptureTheFlag");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );

        NearTheFlag = false;

        if( ! DontChangeTactikalPoint )
            TacticalPoint = none;

        DontChangeTactikalPoint = false;

        LastTestTime = Level.TimeSeconds;
    }

    //--------------------------------------------------------------

    event EndState()
    {
        NearTheFlag = false;
        WaitBeforeFire = false;

        if( SeekAndFire )
        {
            bFire=0;
            Enemy = none;
            if (pawn!=none) Pawn.ControllerPitch = 0;
            SeekAndFire=false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);
        }
    }

    //--------------------------------------------------------------

    function GetRandomGoPoint()
    {
        local int Loop;
        local Array<NavigationPoint> TmpGoPoint;

        if( DBugBot )
        {
            log("");
            log("[ BOT"@ID@"] : Get Random TacticalPoint");
            log(" > Last:"@LastGoPointUsed);
        }

        for( Loop =0 ; Loop<GoPointList.Length ; Loop++ )
        {

            if( GoPointList[Loop] != LastGoPointUsed )
            {
                TmpGoPoint.Length = TmpGoPoint.Length+1;
                TmpGoPoint[ TmpGoPoint.Length-1 ] = GoPointList[ Loop ];
            }
            else if ( Rand( 100 ) < 25 + Skill*25 )
            {
                TmpGoPoint.Length = TmpGoPoint.Length+1;
                TmpGoPoint[ TmpGoPoint.Length-1 ] = GoPointList[ Loop ];

                if( DBugBot ) log("[ BOT"@ID@"] : Accept the last TacticalPoint");
            }
        }

        TacticalPoint = TmpGoPoint[Rand( TmpGoPoint.Length )];
        LastGoPointUsed = TacticalPoint;

        if( DBugBot )
        {
            log(" > New:"@TacticalPoint);
            log("");
        }
    }

    //--------------------------------------------------------------

    function int GetLifePriority()
    {
        if( VSize( EnemyFlag.Location - Pawn.Location ) < 1500 )
            return 1;
        else
            return global.GetLifePriority();
    }

    //--------------------------------------------------------------

    function float DistToTheEnemyFlag()
    {
        local int Loop;
        local float TmpDist;

        if( ! FullPath )
             return 10000;

        if( Level.TimeSeconds - LastTestTime < 0.5 )
             return 10001;

        //log("DistToTheEnemyFlag ..."@Level.TimeSeconds - LastTestTime);

        LastTestTime = Level.TimeSeconds;

        TmpDist = VSize( Pawn.Location - PathCache[ PathIndex ].Location );

        for( Loop = PathIndex; Loop < PathCacheSize-1 ; Loop ++ )
        {
            TmpDist += VSize( PathCache[ Loop ].Location - PathCache[ Loop+1 ].Location );
        }

        return TmpDist;

    }

    //--------------------------------------------------------------

    event EnemyNotVisible()
    {
        if( SeekAndFire )
        {
            bFire=0;
            Enemy = none;
            Pawn.ControllerPitch = 0;
            SeekAndFire=false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);
            Pawn.Weapon.ForceReload();
        }
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        local float TmpDist;

        if( Enemy != none )
        {
            if( ( WaitBeforeFire ) && ( Seen == Enemy ) )
                WaitBeforeFire = false;
            else
                return;
        }

        if( ! IsEnemy( Seen ) )
            return;

        if( ! NearTheFlag )
        {
            TmpDist = DistToTheEnemyFlag();

            if( TmpDist < 2000 )
                NearTheFlag = true;
        }

        if( NearTheFlag )
        {
            if( VSize( Seen.Location - Pawn.Location ) > 300 )
            {
                if( ! SeekAndFire )
                {
                    Enemy = Seen;
                    SeekAndFire=true;
                    SetTimer( (4-Skill)*0.2+FRand()/2 ,False );
                }
            }
            else if( ! FindOrder( Order_Kill ) )
            {
                Enemy = Seen;
                DontChangeTactikalPoint=true;
                AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
            }
        }
        else if( ! FindOrder( Order_Kill ) )
        {
            Enemy = Seen;
            DontChangeTactikalPoint=true;
            AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
        }
    }

    //--------------------------------------------------------------

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( ! PathErrorToAllLife )
        {
            if( FindOrder( Order_Life ) )
                ModifyOrder( Order_Life, GetLifePriority() );
            else
                AddOrder(GetLifePriority(),Order_Life,"Life",0);
        }

        WaitBeforeFire = true;

        SeePlayer( Agressor );
    }

    //--------------------------------------------------------------

    function bool SkipTacticalPoint()
    {
        local float TmpDist;

        if( GetFlagState( EnemyFlag ) == cDropped )
        {
            TmpDist = VSize( EnemyFlag.Location - Pawn.Location );

            if( TmpDist < 2000 )
                return true;
            else
                return false;
        }
    }

    //--------------------------------------------------------------

begin:

    while( Pawn.Physics == PHYS_Falling )
        sleep( 0.1 );

    if( SkipTacticalPoint() )
        GoPhase = 1;

    while( true )
    {
        if( GoPhase == 0 )
        {
            if( TacticalPoint == none )
                GetRandomGoPoint();

            NavPathStorage( TacticalPoint );
        }
        else
            FlagPathStorage( EnemyFlag );

        if( MoveTarget == none )
        {
            Sleep( 0.5 );
            break;
        }

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;
            Pawn.ShouldCrouch( false );

            if( ! SeekAndFire )
                MoveToward( MoveTarget, Focus , MoveSpeed );
            else
                MoveToward( MoveTarget, Enemy , MoveSpeed );
        }

        if( FullPath )
        {
            if ( GoPhase == 1 )
                break;
            else
                GoPhase++;
        }
    }

    RemoveOrder( Order_CaptureTheFlag );
}

//__________________________________________________________________
//__________________________________________________________________
//                            BringBackTheFlag
//__________________________________________________________________
//__________________________________________________________________

state BringBackTheFlag
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> BringBackTheFlag");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );

        NearTheFlag = false;

        if( ! DontChangeTactikalPoint )
            TacticalPoint = none;

        DontChangeTactikalPoint = false;
    }

    //--------------------------------------------------------------

    event EndState()
    {
        SetTimer3(0.0,false);
        NearTheFlag = false;
        WaitBeforeFire = false;

        if( SeekAndFire )
        {
            bFire=0;
            Enemy = none;
            if (pawn!=none) Pawn.ControllerPitch = 0;
            SeekAndFire=false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);
        }
    }

    //--------------------------------------------------------------

    event EnemyNotVisible()
    {
        if( SeekAndFire )
        {
            bFire=0;
            Enemy = none;
            Pawn.ControllerPitch = 0;
            SeekAndFire=false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);
            Pawn.Weapon.ForceReload();
        }
    }

    //--------------------------------------------------------------

    function float DistToMyFlag()
    {
        local int Loop;
        local float TmpDist;

        if( ! FullPath )
             return 10000;

        TmpDist = VSize( Pawn.Location - PathCache[ PathIndex ].Location );

        for( Loop = PathIndex; Loop < PathCacheSize-1 ; Loop ++ )
        {
            TmpDist += VSize( PathCache[ Loop ].Location - PathCache[ Loop+1 ].Location );
        }

        return TmpDist;

    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        local float DistToTheEnemy;

        if( Enemy != none )
            return;

        if( ! IsEnemy( Seen ) )
            return;

        DistToTheEnemy = VSize( Seen.Location - Pawn.Location );

        if( ( DistToTheEnemy > 300 ) && ( DistToTheEnemy < 700 ) )
        {
            if( ! SeekAndFire )
            {
                Enemy = Seen;
                SeekAndFire=true;
                SetTimer( (4-Skill)*0.2+FRand()/2 ,False );
            }
        }
        else if( DistToTheEnemy < 300 )
        {
            Enemy = Seen;
            DontChangeTactikalPoint=true;
            AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
        }
    }

    //--------------------------------------------------------------

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( ! PathErrorToAllLife )
        {
            if( FindOrder( Order_Life ) )
                ModifyOrder( Order_Life, GetLifePriority() );
            else
                AddOrder(GetLifePriority(),Order_Life,"Life",0);
        }

        SeePlayer( Agressor );
    }

    //--------------------------------------------------------------

    function int GetLifePriority()
    {
        if( BackPhase == 0 )
            return 1;

        if( VSize( MyFlag.Location - Pawn.Location ) < 1500 )
            return 1;

        return global.GetLifePriority();
    }

    //--------------------------------------------------------------

    function GetRandomBackPoint()
    {
        local int Loop;
        local Array<NavigationPoint> TmpGoPoint;

        if( DBugBot )
        {
            log("");
            log("[ BOT"@ID@"] : Get Random TacticalPoint");
            log(" > Last:"@LastBackPointUsed);
        }

        for( Loop =0 ; Loop<BackPointList.Length ; Loop++ )
        {
            if( BackPointList[Loop] != LastBackPointUsed )
            {
                TmpGoPoint.Length = TmpGoPoint.Length+1;
                TmpGoPoint[ TmpGoPoint.Length-1 ] = BackPointList[ Loop ];
            }
            else if ( Rand( 100 ) < 25 + Skill*25 )
            {
                TmpGoPoint.Length = TmpGoPoint.Length+1;
                TmpGoPoint[ TmpGoPoint.Length-1 ] = BackPointList[ Loop ];

                if( DBugBot ) log("[ BOT"@ID@"] : Accept the last TacticalPoint");
            }
        }

        TacticalPoint = TmpGoPoint[Rand( TmpGoPoint.Length )];
        LastBackPointUsed = TacticalPoint;

        if( DBugBot )
        {
            log(" > New:"@TacticalPoint);
            log("");
        }
    }

    //--------------------------------------------------------------

    function bool StopOrder()
    {
        if( GetFlagState( MyFlag ) != cHome )
            return true;
        else
            return false;
    }

    //--------------------------------------------------------------

    event Timer3()
    {
        log("");
        log("--------------------------------------------");
        log("[ BOT"@ID@"] : !!! ANTIBUG BringBackTheFlag !!!");
        LogOrderList();
        log("--------------------------------------------");
        log("");

        LastDefaultOrderTime=0;
        ClearAllOrders();
    }

    //--------------------------------------------------------------

    function bool SkipTacticalPoint()
    {
        local float TmpDist;

        if( GetFlagState( MyFlag ) == cHome )
        {
            TmpDist = VSize( MyFlag.HomeBase.Location - Pawn.Location );

            if( TmpDist < 2000 )
                return true;
            else
                return false;
        }
    }

    //--------------------------------------------------------------

begin:

    while( Pawn.Physics == PHYS_Falling )
        sleep( 0.1 );

    if( SkipTacticalPoint() )
        BackPhase = 1;


    while( true )
    {
        if( BackPhase == 0 )
        {
            if( TacticalPoint == none )
                GetRandomBackPoint();

            NavPathStorage( TacticalPoint );
        }
        else
            NavPathStorage( MyFlag.HomeBase );

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            if( StopOrder() )
            {
                AddOrder( 75 , Order_GoToSafePoint , "Go To Safe Point",0);
                RemoveOrder( Order_BringBackTheFlag );
            }

            Pawn.ShouldCrouch( false );
            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            if( ! SeekAndFire )
                MoveToward( MoveTarget, Focus , MoveSpeed );
            else
                MoveToward( MoveTarget, Enemy , MoveSpeed );
        }

        if( FullPath )
        {
            if ( BackPhase == 1 )
                break;
            else
                BackPhase++;
        }
    }

    SetTimer3(2.0,false);
    //sleep( 1.0 );
    JustRespawn =true;
    RemoveOrder( Order_BringBackTheFlag );
}


//__________________________________________________________________
//__________________________________________________________________
//                            GoToSafePoint
//__________________________________________________________________
//__________________________________________________________________

state GoToSafePoint
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> GoToSafePoint");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );

        NearTheFlag = false;

        if( ! DontChangeTactikalPoint )
            TacticalPoint = none;

        DontChangeTactikalPoint = false;
    }

    //--------------------------------------------------------------

    event EndState()
    {
        NearTheFlag = false;

        if( SeekAndFire )
        {
            bFire=0;
            Enemy = none;
            if (pawn!=none) Pawn.ControllerPitch = 0;
            SeekAndFire=false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);
        }
    }

    //--------------------------------------------------------------

    event EnemyNotVisible()
    {
        if( SeekAndFire )
        {
            bFire=0;
            Enemy = none;
            Pawn.ControllerPitch = 0;
            SeekAndFire=false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);
            Pawn.Weapon.ForceReload();
        }
    }

    //--------------------------------------------------------------

    function float DistToMyFlag()
    {
        local int Loop;
        local float TmpDist;

        if( ! FullPath )
             return 10000;

        TmpDist = VSize( Pawn.Location - PathCache[ PathIndex ].Location );

        for( Loop = PathIndex; Loop < PathCacheSize-1 ; Loop ++ )
        {
            TmpDist += VSize( PathCache[ Loop ].Location - PathCache[ Loop+1 ].Location );
        }

        return TmpDist;

    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        local float DistToTheEnemy;

        if( Enemy != none )
            return;

        if( ! IsEnemy( Seen ) )
            return;

        DistToTheEnemy = VSize( Seen.Location - Pawn.Location );

        if( ( DistToTheEnemy > 300 ) && ( DistToTheEnemy < 700 ) )
        {
            if( ! SeekAndFire )
            {
                Enemy = Seen;
                SeekAndFire=true;
                SetTimer( (4-Skill)*0.2+FRand()/2 ,False );
            }
        }
        else if( DistToTheEnemy < 300 )
        {
            Enemy = Seen;
            DontChangeTactikalPoint=true;
            AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
        }
    }

    //--------------------------------------------------------------

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( ! PathErrorToAllLife )
        {
            if( FindOrder( Order_Life ) )
                ModifyOrder( Order_Life, GetLifePriority() );
            else
                AddOrder(GetLifePriority(),Order_Life,"Life",0);
        }

        SeePlayer( Agressor );
    }

    //--------------------------------------------------------------

    function int GetLifePriority()
    {
        if( BackPhase == 0 )
            return 1;

        return global.GetLifePriority();
    }

    //--------------------------------------------------------------

    function GetRandomSafePoint()
    {
        HidePoint = HideSpotList[Rand( HideSpotList.Length)];
    }

    //--------------------------------------------------------------

    function GetRandomBackPoint()
    {
        local int Loop;
        local Array<NavigationPoint> TmpGoPoint;

        if( DBugBot )
        {
            log("");
            log("[ BOT"@ID@"] : Get Random TacticalPoint");
            log(" > Last:"@LastBackPointUsed);
        }

        for( Loop =0 ; Loop<BackPointList.Length ; Loop++ )
        {
            if( BackPointList[Loop] != LastBackPointUsed )
            {
                TmpGoPoint.Length = TmpGoPoint.Length+1;
                TmpGoPoint[ TmpGoPoint.Length-1 ] = BackPointList[ Loop ];
            }
        }

        TacticalPoint = TmpGoPoint[Rand( TmpGoPoint.Length )];
        LastBackPointUsed = TacticalPoint;

        if( DBugBot )
        {
            log(" > New:"@TacticalPoint);
            log("");
        }
    }

    //--------------------------------------------------------------

    function bool StopOrder()
    {
        if( GetFlagState( MyFlag ) == cHome )
            return true;
        else
            return false;
    }

    //--------------------------------------------------------------

begin:

    if( Pawn.Physics == PHYS_Falling )
    {
        while( true )
        {
            sleep( 0.1 );

            if ( Pawn.Physics != PHYS_Falling )
               break;
        }
    }

    while( true )
    {
        if( BackPhase == 0 )
        {
            if( TacticalPoint == none )
                GetRandomBackPoint();

            NavPathStorage( TacticalPoint );
        }
        else
        {
            GetRandomSafePoint();
            NavPathStorage( HidePoint );
        }

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            if( StopOrder() )
            {
                AddOrder( 75 , Order_BringBackTheFlag , "BringBackTheFlag",0);
                RemoveOrder( Order_GoToSafePoint );
            }

            Pawn.ShouldCrouch( false );
            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            if( ! SeekAndFire )
                MoveToward( MoveTarget, Focus , MoveSpeed );
            else
                MoveToward( MoveTarget, Enemy , MoveSpeed );
        }

        if( PathIndex != PathCacheSize )
            break;

        if( FullPath )
        {
            if ( BackPhase == 1 )
                break;
            else
                BackPhase++;
        }
    }

    AddOrder( 75 , Order_WaitToFlagComeBack , "BringBackTheFlag",0);
    RemoveOrder( Order_GoToSafePoint );
}

//__________________________________________________________________
//__________________________________________________________________
//                            WaitToFlagComeBack
//__________________________________________________________________
//__________________________________________________________________

state WaitToFlagComeBack
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> WaitToFlagComeBack");
        }

        Pawn.velocity=vect(0,0,0);
        Pawn.acceleration=vect(0,0,0);
        Focus = none;
        FocalPoint = vector(HidePoint.rotation)*10000+Pawn.Location;

        Enemy = none;
        Pawn.ShouldCrouch( true );

        HideTime = Level.TimeSeconds;
        MaxHideTime = 20 + Rand( 20 );
    }

    //--------------------------------------------------------------

    event EndState()
    {
        if (pawn!=none) Pawn.SpineYawControl(false,3000, 1.2);
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        if( VSize( Seen.Location - Pawn.Location ) < 2000 )
            SomeoneWantKillMe( Seen );
    }

    //--------------------------------------------------------------

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

        if( !FindOrder( Order_Kill ) )
        {
            Enemy = Agressor;

            if( ! FindOrder( Order_Kill ) )
            {
                AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
                AddOrder( 75 , Order_GoToSafePoint , "Go To Safe Point",0);
                RemoveOrder( Order_WaitToFlagComeBack );
            }
        }
    }

    //--------------------------------------------------------------

begin:

    Pawn.SpineYawControl(true,3000, 1.2);

    while( true )
    {
        if( GetFlagState( MyFlag ) == cHome )
        {
            Sleep( FRand() );
            BackPhase = 1;
            AddOrder( 75 , Order_BringBackTheFlag , "BringBackTheFlag",0);
            RemoveOrder( Order_WaitToFlagComeBack );
        }
        else
            Sleep( 1.0 );

        if( Level.TimeSeconds - HideTime > MaxHideTime )
        {
            AddOrder( 75 , Order_GoToSafePoint , "Go To Safe Point",0);
            RemoveOrder( Order_WaitToFlagComeBack );
        }
    }
}


//__________________________________________________________________
//__________________________________________________________________
//                            ProtectTheFlag
//__________________________________________________________________
//__________________________________________________________________

state ProtectTheFlag
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> ProtectTheFlag");
        }

        Pawn.ShouldCrouch( false );

        Enemy = none;
        Pawn.ControllerPitch = 0;

        MaxProtectTime = 20 + Rand( 20 );
        ProtectTime = Level.TimeSeconds;

        SetTimer3( 1.0 , true );
    }

    //--------------------------------------------------------------

    event EndState()
    {
        SetTimer3( 0.0 , false );
        GuardPathNode(TacticalPoint).Closed = false;
		if (pawn!=none)
		{
        Pawn.SpineYawControl(false,3000, 1.2);
        Pawn.ShouldCrouch( false );
		}
    }

    //--------------------------------------------------------------

    function GetRandomGuardPoint()
    {
        local Array<NavigationPoint> TempList;
        local int Loop;
        local NavigationPoint TempPoint;

        for( Loop=0;Loop<GuardPointList.Length;Loop++)
        {
            TempPoint = GuardPointList[ Loop ];

            if( ! GuardPathNode(TempPoint).Closed )
            {
                TempList.Length = TempList.Length+1;
                TempList[ TempList.Length-1 ] = TempPoint;
            }
        }

        TacticalPoint = TempList[Rand( TempList.Length)];
    }

    //--------------------------------------------------------------

    function bool StopOrder()
    {
        if( GetFlagState( MyFlag ) != cHome )
            return true;
        else
            return false;
    }

    //--------------------------------------------------------------

    event Timer3()
    {
        local float TmpDist;

        if( GetFlagState( EnemyFlag ) == cDropped )
        {
            TmpDist = VSize( EnemyFlag.Location - Pawn.Location );

            //log("----"@TmpDist@"----");

            if( TmpDist < 2000 )
            {
                AddOrder( 79 , Order_CaptureTheFlag , "Attack The Flag",0);
            }
        }
    }

    //--------------------------------------------------------------

Begin :

    if( Pawn.Physics == PHYS_Falling )
    {
        while( true )
        {
            sleep( 0.1 );

            if ( Pawn.Physics != PHYS_Falling )
               break;
        }
    }

    GetRandomGuardPoint();

    Pawn.ShouldCrouch( false );

    while( true )
    {
        NavPathStorage( TacticalPoint );

        if( MoveTarget == none )
        {
            Sleep( 0.5 );
            break;
        }

        GuardPathNode(TacticalPoint).Closed = true;

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            if( StopOrder() )
            {
                AddOrder( 75 , Order_SeekTheFlag , "Retrive My Flag",0);
                RemoveOrder(Order_ProtectTheFlag);
            }

            Pawn.ShouldCrouch( false );

            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            MoveToward( MoveTarget, Focus , MoveSpeed );
        }

        if( FullPath )
            break;
    }

    Focus = none;
    FocalPoint = vector(TacticalPoint.rotation)*10000+Pawn.Location;
    Pawn.SpineYawControl(true,3000, 1.2);

    if( Rand( 100 ) < 50 )
        Pawn.ShouldCrouch( true );
    else
        Pawn.ShouldCrouch( false );

    while( true )
    {
        if( GetFlagState( MyFlag ) == cHome )
            Sleep( 1.0 );
        else
        {
            AddOrder( 75 , Order_SeekTheFlag , "Retrive My Flag",0);
            RemoveOrder(Order_ProtectTheFlag);
        }

        if( Level.TimeSeconds - ProtectTime > MaxProtectTime )
        {
            if( Rand( 100 ) < 30 )
            {
                RemoveOrder(Order_ProtectTheFlag);
            }
            else
            {
                ProtectTime = Level.TimeSeconds;
                GuardPathNode(TacticalPoint).Closed = false;
                Pawn.ShouldCrouch( false );
                Goto('begin');
             }
        }
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            SeekTheFlag
//__________________________________________________________________
//__________________________________________________________________

state SeekTheFlag
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> SeekTheFlag");
        }

        Enemy = MyFlag.Holder;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );

        LastSeeTime = Level.TimeSeconds;
    }

    //--------------------------------------------------------------

    event EndState()
    {
        bFire=0;
        SetTimer(0.0,false);
        SetTimer2(0.0,false);
        SeekAndFire=false;
    }

    //--------------------------------------------------------------

    event EnemyNotVisible()
    {
        if( SeekAndFire )
        {
            bFire=0;
            SeekAndFire=false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);
            Pawn.Weapon.ForceReload();
        }
    }

    //--------------------------------------------------------------

    function bool StopOrder()
    {
        if( ( ( TeamRole == cDefense ) && ( Level.TimeSeconds - LastSeeTime > 20 ) ) && ( GetFlagState( EnemyFlag ) != cHeld ) )
        {
            if( DBugBot )
            {
                Log("");
                Log("[ BOT"@ID@"] : ABORD SeekTheFlag Time without seeing the Holder ="@int(Level.TimeSeconds - LastSeeTime)@"s");
            }

            return true;
        }

        if( GetFlagState( MyFlag ) == cHome )
            return true;
        else
            return false;
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        if( ! IsEnemy( Seen ) )
            return;

        if( Seen == Enemy )
        {
            LastSeeTime = Level.TimeSeconds;

            if( IsShootable( Seen ) )
            {
                if( VSize( Seen.Location - Pawn.Location ) > 200 )
                {
                    if( ! SeekAndFire )
                    {
                        SeekAndFire=true;
                        SetTimer( (4-Skill)*0.2+FRand()/2 ,False );
                    }
                }
                else if( ! FindOrder( Order_Kill ) )
                    AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
            }
        }
        else if( ( VSize( Seen.Location - Pawn.Location ) < 400 ) && ( Rand( 100 ) < 90 - Skill*20 ) )
        {
            if( IsShootable(Seen) )
            {
                Enemy = Seen;

                if( ! FindOrder( Order_Kill ) )
                    AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
            }
        }
    }

    //--------------------------------------------------------------

    function int GetLifePriority()
    {
        if( VSize( MyFlag.Location - Pawn.Location ) < 1500 )
            return 1;

        return global.GetLifePriority();
    }

    //--------------------------------------------------------------

    event bool NotifyBump(Actor Other);

    //--------------------------------------------------------------

Begin :

    Sleep( FRand()/4 );

    while( true )
    {
        FlagPathStorage( MyFlag );

        if( MoveTarget == none )
        {
            log("!!! Impossible de rechercher le flag !!!");
            Sleep( 0.5 );
            break;
        }

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            if( StopOrder() )
                break;

            Pawn.ShouldCrouch( false );
            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            if( ! SeekAndFire )
                MoveToward( MoveTarget, Focus , MoveSpeed*1.1 );
            else
                MoveToward( MoveTarget, Enemy , MoveSpeed*1.1 );
        }

        if( StopOrder() )
            break;
        else
            goto('begin');
    }

    RemoveOrder(Order_SeekTheFlag);
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
        if( Enemy == none )
            RemoveOrder( Order_Kill );

        super.BeginState();
    }

    //--------------------------------------------------------------

    event EnemyNotVisible()
    {
        if( Pawn.bIsCrouched )
            Pawn.ShouldCrouch( false );

        bFire=0;

        if( ( Enemy == MyFlag.Holder ) || ( bFireMove ) )
            AddOrder( 70 ,Order_Seek,"Seek", 0);
        else
            Enemy = none;

        RemoveOrder( Order_Kill );
    }

    //--------------------------------------------------------------

    function int GetLifePriority()
    {
        if( Enemy == MyFlag.Holder )
            return 1;

        return global.GetLifePriority();
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            WaitBeforeAttack
//__________________________________________________________________
//__________________________________________________________________

state WaitBeforeAttack
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> WaitBeforeAttack");
        }

        JustRespawn=false;
        ReadyToAttack=false;

        Enemy = none;
        Pawn.ControllerPitch = 0;

        MaxProtectTime = 40;
        ProtectTime = Level.TimeSeconds;
    }

    //--------------------------------------------------------------

    event EndState()
    {
        GuardPathNode(TacticalPoint).Closed = false;
		if (pawn!=none)
		{
        Pawn.SpineYawControl(false,3000, 1.2);
        Pawn.ShouldCrouch( false );
		}
    }

    //--------------------------------------------------------------

    function GetRandomWaitPoint()
    {
        local Array<NavigationPoint> TempList;
        local int Loop;
        local NavigationPoint TempPoint;

        for( Loop=0;Loop<WaitPointList.Length;Loop++)
        {
            TempPoint = WaitPointList[ Loop ];

            if( ! GuardPathNode(TempPoint).Closed )
            {
                TempList.Length = TempList.Length+1;
                TempList[ TempList.Length-1 ] = TempPoint;
            }
        }

        TacticalPoint = TempList[Rand( TempList.Length)];
    }

    //--------------------------------------------------------------

    function bool StopOrder()
    {
        if( GetFlagState( MyFlag ) != cHome )
            return true;
        else
            return false;
    }

    //--------------------------------------------------------------

    function bool AllReady()
    {
        local int Loop , NbReady , NbBot;

        for( Loop=0;Loop<MyTeam.Length;Loop++ )
        {
            if( ( MyTeam[ Loop ].TeamRole != cDefense ) && ( MyTeam[ Loop ].FindOrder(Order_WaitBeforeAttack ) ) )
            {
                NbBot++;

                if( CTFBotController(MyTeam[ Loop ]).ReadyToAttack )
                    NbReady++;
            }

        }

        if( NbReady == NbBot )
            return true;
        else
            return false;
    }

    //--------------------------------------------------------------

Begin :

    GetRandomWaitPoint();

    Pawn.ShouldCrouch( false );

    while( true )
    {
        NavPathStorage( TacticalPoint );

        if( MoveTarget == none )
        {
            Sleep( 0.5 );
            break;
        }

        GuardPathNode(TacticalPoint).Closed = true;

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            if( StopOrder() )
            {
                AddOrder( 75 , Order_SeekTheFlag , "Retrive My Flag",0);
                RemoveOrder(Order_ProtectTheFlag);
            }

            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            MoveToward( MoveTarget, Focus , MoveSpeed );
        }

        if( FullPath )
            break;
    }

    ReadyToAttack=true;
    Focus = none;
    FocalPoint = vector(TacticalPoint.rotation)*10000+Pawn.Location;
    Pawn.SpineYawControl(true,3000, 1.2);

    if( Rand( 100 ) < 50 )
        Pawn.ShouldCrouch( true );
    else
        Pawn.ShouldCrouch( false );

    while( true )
    {
        if( GetFlagState( MyFlag ) == cHome )
            Sleep( 1.0 );
        else
        {
            AddOrder( 75 , Order_SeekTheFlag , "Retrive My Flag",0);
            RemoveOrder(Order_WaitBeforeAttack);
        }

        if( Level.TimeSeconds - ProtectTime > MaxProtectTime )
            RemoveOrder(Order_WaitBeforeAttack);

        if( AllReady() )
        {
            Sleep( 1.0 + FRand() );
            RemoveOrder(Order_WaitBeforeAttack);
        }
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            ProtectTheHolder
//__________________________________________________________________
//__________________________________________________________________

state ProtectTheHolder
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> ProtectTheHolder");

        }

        Enemy = none;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );
        StopProtect = false;

        if( Leader == Pawn )
        {
            AddOrder( 75 , Order_BringBackTheFlag , "BringBackTheFlag",0);
            RemoveOrder( Order_ProtectTheHolder );
        }
    }

    //--------------------------------------------------------------

    event EndState()
    {
        SetTimer3(0.0,false);

        if( StopProtect && pawn!=none)
        {
            Pawn.ShouldCrouch( false );
            Pawn.SpineYawControl(false,3000, 1.2);
        }
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        if( ( ! IsEnemy( Seen ) ) || ( VSize( Pawn.Location - Seen.Location ) > 600 ) )
            return;

        Enemy = Seen;

        ForceOtherTeamBotToHelpProtector();

        if( ! FindOrder( Order_Kill ) )
            AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
    }

    //--------------------------------------------------------------

    function forceOtherTeamBotToHelpProtector()
    {
        local int Loop;

        for( Loop=0;Loop<MyTeam.Length;Loop++ )
        {
            if( MyTeam[ Loop ].IsInState('ProtectTheHolder') )
            {
                if( ! MyTeam[ Loop ].FindOrder( Order_Kill ) )
                {
                    MyTeam[ Loop ].Enemy = Enemy;
                    MyTeam[ Loop ].AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
                }
            }
        }
    }

    //--------------------------------------------------------------

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( ( ! IsEnemy( Agressor ) ) || ( VSize( Pawn.Location - Agressor.Location ) > 1000 ) )
            return;

        Enemy = Agressor;

        if( ! FindOrder( Order_Kill ) )
            AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
    }

    //--------------------------------------------------------------

    function FindPathToMyLeader()
    {
        local actor Path;

         if( Leader == none || Leader.bIsDead)
            return;

        Path = ExtendFindPathToward(Leader);

//        if( Path == none )
//            Path = FindPathToward(Leader);

        if( Path == none )
            Leader = none;
        else
            MoveTarget = Path;
    }

    //--------------------------------------------------------------

    function bool StopOrder()
    {
        if( GetFlagState( EnemyFlag ) == cHome )
        {
            JustRespawn =true;
            return true;
        }
        else
            return false;
    }

    //--------------------------------------------------------------

    event Timer3()
    {
        local float DistToLeader;

        DistToLeader = VSize( Pawn.Location - Leader.Location );

        if( ! StopProtect )
        {
            if( DistToLeader < 400 + Rand( 200 ) )
            {
                StopProtect = true;
                gotostate('ProtectTheHolder','StraffeBeforeHoldPosition');
            }
        }
        else
        {
            if( DistToLeader > 800 )
            {
                StopProtect = false;

                Pawn.ShouldCrouch( false );
                Pawn.SpineYawControl(false,3000, 1.2);

                gotostate('ProtectTheHolder','Begin');
            }
        }
    }

    //--------------------------------------------------------------

    event bool NotifyBump(Actor Other);

    //--------------------------------------------------------------

Begin:

    //log(" > Go to Holder");

    SetTimer3(0.4,true);
    Timer3();

    Sleep( FRand()/2 );

    while( true )
    {
        if( StopOrder() )
        {
            //log("   > RemoveOrder for StopOrder");
            RemoveOrder( Order_ProtectTheHolder );
        }

        FindPathToMyLeader();

        if( ( Leader == none ) || ( Leader.bIsDead ) )
        {
            //log("   > RemoveOrder for Path");
            RemoveOrder( Order_ProtectTheHolder );
        }
        else
        {
            Pawn.ShouldCrouch( false );
            Focus=MoveTarget;

            //log("   > MoveToward to"@MoveTarget);

            MoveToward( MoveTarget, Focus , MoveSpeed );
        }
    }

StraffeBeforeHoldPosition:

    Pawn.velocity=vect(0,0,0);
    Pawn.acceleration=vect(0,0,0);

    if( Rand( 100 ) < 50 )
        UnBlockPos1 = Pawn.Location + ( vector(pawn.rotation) cross (vect(0,0,1)) )*300;
    else
        UnBlockPos1 = Pawn.Location + ( vector(pawn.rotation) cross (vect(0,0,1)) )*(-300);

    MoveTo( UnBlockPos1, Leader );

    Pawn.velocity=vect(0,0,0);
    Pawn.acceleration=vect(0,0,0);

HoldPosition :

    //log(" > HoldPosition");

    FindAllNearestWatchPoint(Leader);

    if( UseableWatchPointList.Length != 0 )
    {
        Focus = none;
        FocalPoint = UseableWatchPointList[ Rand( UseableWatchPointList.Length ) ].Location;
    }
    else
        Focus = Leader;

    Pawn.SpineYawControl(true,3000, 1.2);

    if( Rand( 100 ) < 50 )
        Pawn.ShouldCrouch( true );
    else
        Pawn.ShouldCrouch( false );

    SetTimer3(1.0,true);

    while( true )
    {
        if( StopOrder() )
            RemoveOrder( Order_ProtectTheHolder );

        if( ( Leader.bIsDead ) || ( Leader == none ) )
            RemoveOrder( Order_ProtectTheHolder );

        sleep( 0.5 );
    }
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
        super.BeginState();
        JustRespawn=true;
        DontChangeTactikalPoint = false;
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            GameEnded
//__________________________________________________________________
//__________________________________________________________________

state GameEnded
{
    function UpDateOrder(int OldOrder,int NewOrder);
}

//__________________________________________________________________




defaultproperties
{
     JustRespawn=True
}
