//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SabotageBotController extends BotController;

var Array<Controller> EnemyTeam, FriendTeam;
var Array<SabotageBotController> MyTeam;
var Array<SabotageBotController> MySubTeam;
var Array<SabotageBotController> OtherSubTeam;
var int BombSpotStatus[3]; // 0:Taken, 1:Free
var Array<NavigationPoint> DefendSpotList_1,DefendSpotList_2,DefendSpotList_3;
var Array<NavigationPoint> SnipeSpotList_1,SnipeSpotList_2,SnipeSpotList_3;
var int SubTeamID, OtherSubTeamID; // 0 or 1
var int TeamStatus; // 0:Attack, 1:Defense
var bool ForceUpFire;
var NavigationPoint DefendPoint, AttackPoint;
var bool forceSwitchSpot;
var float TotalDefendTime, TotalMaxDefendTime;
var float DefendTime, MaxDefendTime;
var bool FireMvt;
var bool SubTeamBotSwitchTheSpot, SubTeamInit;
var XIIIMPSabotageStorage StorageObj;
var bool WaitToStart , ReadyForNextAttackPoint;
var float TimeToWaitBeforeStart, AttackPointTime;
var MPBombingBase BombPoint[ 3 ];
var int AttackPathGroup, AttackPhaseIndex , AttackPhaseNumber;
var Array<NavigationPoint> AttackPointList;
var Array<NavigationPoint> GroupPointList;
var bool AloneRun , IHaveTheBomb;
var bool ForceContinueAttackPhase;

const Order_GoToDefenseSpot    =   1048576;
const Order_DefendTheSpot      =   2097152;
const Order_WaitToStart        =   4194304;
const Order_CoverFight         =  33554432; //25
const Order_GoToAttackSpot     =  67108864; //26
const Order_CoverTheBomb       = 134217728; //27
const Order_TakeTheBomb        = 268435456; //28
const Order_PutTheBomb         = 536870912; //29
const Order_BackToHomeBase     = 524288;

const cAttackStatus  = 0;
const cDefenseStatus = 1;

//__________________________________________________________________

function bool GetNumberOfEnemyInTheGrenadArea(BotGrenadTarget Target)
{
    local Controller C;
    local int NbFriend,NbEnemy;

    if( Rand( 100 ) < 50 )
    {
        foreach DynamicActors(class'Controller', C)
        {
            if( C != self )
            {
                if( VSize( Target.Location - C.Pawn.Location ) < 600 )
                {
                    if( IsEnemy( C.Pawn ) )
                        NbEnemy++;
                    else
                        NbFriend++;
                }
            }
        }

        if( ( NbEnemy != 0 ) && ( NbFriend == 0 ) )
            return true;
        else
            return false;
    }
    else
        return false;
}

//__________________________________________________________________

function GrenadPossibility( GrenadPathNode GrenadNode )
{
    if( GrenadNode.Team != TeamID )
        return;

    super.GrenadPossibility( GrenadNode );
}

//__________________________________________________________________

function bool BombCarrier( Pawn Other )
{
    local weapon TheBomb;

    TheBomb = Weapon(Other.FindInventoryType(class'MPBomb'));

    if( ( TheBomb == none ) || (  TheBomb.AmmoType.AmmoAmount == 0 ) )
        return false;
    else
        return true;
}

//__________________________________________________________________

function bool ShouldTakeTheBomb( Pawn Other )
{
    local int Loop;
    local float DistToTheBomb;

    if( ! SubTeamInit )
        InitializeSubTeam();

    if( ! StorageObj.TheBombPick.ReadyToPickUp(3) )
        return false;

    DistToTheBomb = VSize( Other.Location - StorageObj.TheBombPick.Location );

    for( Loop=0;Loop<MyTeam.Length;Loop++ )
    {
        if( MyTeam[ Loop ].FindOrder(Order_TakeTheBomb ) )
            return false;

        if( VSize( MyTeam[ Loop ].Pawn.Location - StorageObj.TheBombPick.Location ) < DistToTheBomb )
            return false;
    }

    return true;
}

//__________________________________________________________________

function GetAttackPointTime()
{
    AttackPointTime = StorageObj.Temporisation[ AttackPhaseIndex ];
}

//__________________________________________________________________

function GetGroupPathNode( int Start , int End )
{
    local int Loop, NbPossibility;

    End++;

    //log("!!! GetGroupPathNode"@Start@End@"!!!");

    for( Loop=0;Loop<GroupPointList.Length;Loop++ )
    {
      //   log(" >"@GroupPointList[ Loop ]@GroupPathNode(GroupPointList[ Loop ]).StartPointID@GroupPathNode(GroupPointList[ Loop ]).EndPointID);

         if( ( GroupPathNode(GroupPointList[ Loop ]).StartPointID == Start ) && ( GroupPathNode(GroupPointList[ Loop ]).EndPointID == End ) )
         {
             StorageObj.MyGPN = GroupPathNode(GroupPointList[ Loop ]);
             break;
         }
    }

    //log(" > Choose :"@StorageObj.MyGPN);

    NbPossibility = 1;

    if( StorageObj.MyGPN.Possibility2.Length != 0 )
        NbPossibility++;

    if( StorageObj.MyGPN.Possibility3.Length != 0 )
        NbPossibility++;

    StorageObj.PossibilityChoice = Rand( NbPossibility );

    StorageObj.Possibility.Length = 0;

    //log(" > Possibility :"@StorageObj.PossibilityChoice);


    switch( StorageObj.PossibilityChoice )
    {
        case 0 :
                for( Loop=0;Loop<StorageObj.MyGPN.Possibility1.Length;Loop++ )
                {
                    StorageObj.Possibility.Length = StorageObj.Possibility.Length+1;
                    StorageObj.Possibility[ StorageObj.Possibility.Length-1 ] = StorageObj.MyGPN.Possibility1[ Loop ];

                    StorageObj.Temporisation.Length = StorageObj.Temporisation.Length+1;
                    StorageObj.Temporisation[ StorageObj.Temporisation.Length-1 ] = StorageObj.MyGPN.Temporisation1[ Loop ];
                }

                break;
        case 1 :
                for( Loop=0;Loop<StorageObj.MyGPN.Possibility2.Length;Loop++ )
                {
                    StorageObj.Possibility.Length = StorageObj.Possibility.Length+1;
                    StorageObj.Possibility[ StorageObj.Possibility.Length-1 ] = StorageObj.MyGPN.Possibility2[ Loop ];

                    StorageObj.Temporisation.Length = StorageObj.Temporisation.Length+1;
                    StorageObj.Temporisation[ StorageObj.Temporisation.Length-1 ] = StorageObj.MyGPN.Temporisation2[ Loop ];
                }

                break;
        case 2 :
                for( Loop=0;Loop<StorageObj.MyGPN.Possibility3.Length;Loop++ )
                {
                    StorageObj.Possibility.Length = StorageObj.Possibility.Length+1;
                    StorageObj.Possibility[ StorageObj.Possibility.Length-1 ] = StorageObj.MyGPN.Possibility3[ Loop ];

                    StorageObj.Temporisation.Length = StorageObj.Temporisation.Length+1;
                    StorageObj.Temporisation[ StorageObj.Temporisation.Length-1 ] = StorageObj.MyGPN.Temporisation3[ Loop ];
                }

                break;
    }
}

//__________________________________________________________________

function bool IsInBombArea( Pawn Other )
{
    local int Loop;
    local float DistToBombBase;

    for( Loop=0;Loop<3;Loop++)
    {
        if( BombSpotStatus[ Loop ] == 1 )
        {
            if( VSize( Other.Location - BombPoint[ Loop ].Location ) < 2500 )
                return true;
        }
    }

    return  false;
}

//__________________________________________________________________

function BombIsActivated(MPBombingBase Target)
{
    local int Loop, TargetID;

    TargetID = -1;

    for( Loop=0;Loop<3;Loop++ )
    {
       if( BombPoint[ Loop ] == Target )
       {
           TargetID = Loop;
           break;
       }
    }

    if( TargetID == -1 )
        return;

    if( TargetID == StorageObj.CurrentDefendSpot[ SubTeamID ] )
        return;

    StorageObj.CurrentDefendSpot[ SubTeamID ] = TargetID;
    TeamRole = TargetID;

    LastDefaultOrderTime = 0;
    SubTeamBotSwitchTheSpot = true;
}

//__________________________________________________________________

function ObjectifIsDestroyed(MPBombingBase Target)
{
    local int Loop, TargetID;

    TargetID = -1;

    for( Loop=0;Loop<3;Loop++ )
    {
       if( BombPoint[ Loop ] == Target )
       {
           TargetID = Loop;
           break;
       }
    }

    if( TargetID == -1 )
        return;

    BombSpotStatus[ TargetID ] = 0;
    StorageObj.CurrentAttackSpot[ 0 ] = -1;
    StorageObj.CurrentDefendSpot[ 0 ] = -1;
    StorageObj.CurrentDefendSpot[ 1 ] = -1;

    if( TeamStatus == cAttackStatus )
    {
        if( ! FindOrder( Order_BackToHomeBase ) )
            AddOrder(79,Order_BackToHomeBase,"BackToHomeBase",Order_CoverTheBomb);
    }
    else
    {
        SubTeamBotSwitchTheSpot = true;

    }
}

//__________________________________________________________________

function InitializeSubTeam()
{
    local SabotageBotController Bot;

    SubTeamInit = true;

    foreach DynamicActors(class'SabotageBotController', BOT)
    {
        if( ( Bot.TeamID == TeamID ) && ( BOT != self ) )
        {
            if( Bot.SubTeamID == SubTeamID )
            {
                MySubTeam.Length = MySubTeam.Length+1;
                MySubTeam[ MySubTeam.Length-1 ] = BOT;
            }
            else
            {
                OtherSubTeam.Length = OtherSubTeam.Length+1;
                OtherSubTeam[ OtherSubTeam.Length-1 ] = BOT;
            }
        }
    }
}

//__________________________________________________________________

function int GiveTheNumberOfEnemyInTheZone( Pawn Other )
{
    local int NbEnemy,Loop;

    NbEnemy=1;

    for( Loop=0;Loop<EnemyTeam.Length;Loop++ )
    {
         if( ( EnemyTeam[ Loop ] != Other ) && ( VSize( Other.Location - EnemyTeam[ Loop ].Location ) < 1000 ) )
             NbEnemy++;
    }

    return NbEnemy+10;
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
}

//__________________________________________________________________

function FocusFire(Pawn Other)
{
    if( IsInState('CoverFight') )
        return;

    if( IsInState('Kill') )
        return;

    if( IsShootable( Other ) )
    {
        //log("   > SeePlayer");
        SeePlayer( Other );
    }
    else
    {
        //log("   > Order_Seek");
        Enemy = Other;
        AddOrder( 70 ,Order_Seek,"Seek", 0);
    }
}

//__________________________________________________________________

function CallTheOtherBotOfMySubTeamInReinforcement()
{
    local int Loop;

    if( ! SubTeamInit )
        InitializeSubTeam();
   if( DBugBot )
	{
    	log("");
    	log("CallTheOtherBotOfMySubTeamInReinforcement");
	}

    if( MySubTeam.Length != 0 )
    {
        for( Loop=0;Loop<MySubTeam.Length;Loop++ )
        {
            //log(" >"@MySubTeam[ Loop ]);
            MySubTeam[ Loop ].FocusFire( Enemy );
        }
    }
}

//__________________________________________________________________

function CallTheOtherSubTeamInReinforcement()
{
    local int Loop;

    if( ! SubTeamInit )
        InitializeSubTeam();

    if( OtherSubTeam.Length != 0 )
    {
        StorageObj.CurrentDefendSpot[ OtherSubTeamID ] = StorageObj.CurrentDefendSpot[ SubTeamID ];

        for( Loop=0;Loop<OtherSubTeam.Length;Loop++ )
        {
             OtherSubTeam[ Loop ].LastDefaultOrderTime = 0;
             OtherSubTeam[ Loop ].TeamRole = TeamRole;
             OtherSubTeam[ Loop ].SubTeamBotSwitchTheSpot = true;
        }
    }
}

//__________________________________________________________________

function SayToOhterSubTeamBotThanTheSpotChange()
{
    local int Loop;

    if( ! SubTeamInit )
        InitializeSubTeam();

    if( MySubTeam.Length != 0 )
    {
        for( Loop=0;Loop<MySubTeam.Length;Loop++ )
        {
             MySubTeam[ Loop ].LastDefaultOrderTime = 0;
             MySubTeam[ Loop ].TeamRole = TeamRole;
             MySubTeam[ Loop ].SubTeamBotSwitchTheSpot = true;
        }
    }
}

//__________________________________________________________________

function UpDateOrder(int OldOrder,int NewOrder)
{
    if( NewOrder == TeamRole )
        return;

    if( DBugBot )
    {
        Log("");
        Log("[ BOT"@ID@"] : UpDateOrder Spot"@TeamRole@"->"@NewOrder);
    }
    if( StorageObj.CurrentAttackSpot[ SubTeamID ] == -1 )  //FRD initialisation des listes de points
          ChooseAttackSpot();
    TeamRole = NewOrder;

    if( TeamStatus == cDefenseStatus )
    {
        StorageObj.CurrentDefendSpot[ SubTeamID ] = TeamRole;
        StorageObj.ForceDefenseTeamRole = true;
    }
    else
    {
        StorageObj.CurrentAttackSpot[ SubTeamID ] = TeamRole;
        StorageObj.ForceAttackTeamRole = true;
    }

    ForceSwitchSpot = true;

    LastDefaultOrderTime = 0;
}

//__________________________________________________________________

function bool CoverFightOrKill( Pawn Other )
{
    if( FastTrace( Other.Location, Pawn.Location ) )
        return false;
    else
        return true;
}

//__________________________________________________________________

function ChooseDefendSpot()
{
    local int NbFreeSpot, Loop;
    local int TmpSpot[ 3 ];

    for( Loop = 0 ; Loop < 3 ; Loop++ )
    {
        if( BombSpotStatus[ Loop ] == 1 )
        {
            TmpSpot[ NbFreeSpot ] = Loop;
            NbFreeSpot++;
        }
    }

    TeamRole = TmpSpot[Rand( NbFreeSpot )];
    StorageObj.CurrentDefendSpot[ SubTeamID ] = TeamRole;

    if( ! SubTeamInit )
        InitializeSubTeam();

    if( MySubTeam.Length != 0 )
    {
        for( Loop=0;Loop<MySubTeam.Length;Loop++ )
        {
             MySubTeam[ Loop ].TeamRole = TeamRole;
        }
    }

    if( DBugBot )
    {
        Log("");
        Log("[ BOT"@ID@"] : Choose Defend Spot for Team"@SubTeamID@" --> Spot N"$StorageObj.CurrentDefendSpot[ SubTeamID ]);
    }
}

//__________________________________________________________________

function ChooseAttackSpot()
{
    local int NbFreeSpot, Loop , OldTeamRole;
    local int TmpSpot[ 3 ];

    for( Loop = 0 ; Loop < 3 ; Loop++ )
    {
        if( BombSpotStatus[ Loop ] == 1 )
        {
            TmpSpot[ NbFreeSpot ] = Loop;
            NbFreeSpot++;
        }
    }

    OldTeamRole = TeamRole;

    TeamRole = TmpSpot[Rand( NbFreeSpot )];

    StorageObj.CurrentAttackSpot[ SubTeamID ] = TeamRole;

    GetGroupPathNode( 0 , TeamRole );

    if( ! SubTeamInit )
        InitializeSubTeam();

    if( MySubTeam.Length != 0 )
    {
        for( Loop=0;Loop<MySubTeam.Length;Loop++ )
        {
             MySubTeam[ Loop ].TeamRole = TeamRole;
        }
    }

    if( DBugBot )
    {
        Log("");
        Log("[ BOT"@ID@"] : Choose Attack Spot for Team"@SubTeamID@" --> Spot N"$StorageObj.CurrentAttackSpot[ SubTeamID ]);
    }

    for( Loop=0;Loop<FriendTeam.Length;Loop++ )
    {
        XIIIBombHud(PlayerController(FriendTeam[Loop]).MyHud).BotBlink[ 0 ]=0;
        XIIIBombHud(PlayerController(FriendTeam[Loop]).MyHud).BotBlink[ 1 ]=0;
        XIIIBombHud(PlayerController(FriendTeam[Loop]).MyHud).BotBlink[ 2 ]=0;
        XIIIBombHud(PlayerController(FriendTeam[Loop]).MyHud).BotBlink[ TeamRole ]=1;
    }
}

//__________________________________________________________________

function SwitchDefendSpot()
{
    local int NbFreeSpot, Loop;
    local int TmpSpot[ 3 ];

    for( Loop = 0 ; Loop < 3 ; Loop++ )
    {
        if( ( BombSpotStatus[ Loop ] == 1 ) && ( Loop != StorageObj.CurrentDefendSpot[ SubTeamID ] ) )
        {
            TmpSpot[ NbFreeSpot ] = Loop;
            NbFreeSpot++;
        }
    }

    if( NbFreeSpot != 0 )
    {
        TeamRole = TmpSpot[Rand( NbFreeSpot )];
        StorageObj.CurrentDefendSpot[ SubTeamID ] = TeamRole;

        SayToOhterSubTeamBotThanTheSpotChange();

        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : switch Defend Spot for Team"@SubTeamID@" --> Spot N"$StorageObj.CurrentDefendSpot[ SubTeamID ]);
        }
    }
}

//__________________________________________________________________

event AddDefaultOrders()
{
    if( Pawn == none )
    {
        gotostate('AntiBug');
        return;
    }

    if( ( Level.TimeSeconds - LastDefaultOrderTime < 3.0 ) && ( LastDefaultOrderTime != 0) )
    {
		 if( ( DBugBot ) || ( DBugWarning ) )
			Log("[ WARNING ][ ORDER ][ BOT"@ID@"] : Runaway Loop !...");

        AddOrder(79,Order_UnBlock,"UnBlock",0);
    }
    else
    {
        if( WaitToStart )
            AddOrder(101,Order_WaitToStart,"WaitToStart",0);

        if( TeamStatus == cDefenseStatus )
        {
            AddOrder(60,Order_GoToDefenseSpot,"GoToDefenseSpot",0);
        }
        else if( TeamStatus == cAttackStatus )
        {
            AddOrder(60,Order_GoToAttackSpot,"GoToAttackSpot",0);
        }
    }

    LastDefaultOrderTime = Level.TimeSeconds;
}

//__________________________________________________________________


event ChangeState()
{
    if( Pawn == none )
        return;

    switch( CurrentOrder.TypeId )
    {
        case Order_GoToDefenseSpot : gotoState( 'GoToDefenseSpot' ); break;
        case Order_DefendTheSpot : gotoState( 'DefendTheSpot' ); break;
        case Order_WaitToStart : gotoState( 'WaitStart' ); break;
        case Order_CoverFight : gotoState( 'CoverFight' ); break;
        case Order_GoToAttackSpot : gotoState( 'GoToAttackSpot' ); break;
        case Order_CoverTheBomb : gotoState( 'CoverTheBomb' ); break;
        case Order_TakeTheBomb : gotoState( 'TakeTheBomb' ); break;
        case Order_PutTheBomb : gotoState( 'PutTheBomb' ); break;
        case Order_BackToHomeBase : gotoState( 'BackToHomeBase' ); break;
        case Order_GrenadLauncher : gotoState( 'GrenadLauncher' ); break;
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
    }
}

//__________________________________________________________________

function InitPickUpList()
{
    local PickUp A;
    local NavigationPoint Nav;
    local Pawn P;
    local SabotageBotController Bot;
    local int Loop;
	local Controller C;
//    local XIIIMPBotInteraction BI;


    bInitPickUpList = true;

	//--------------

//    for ( C=Level.ControllerList; C!=None; C= C.NextController )
//	{
//        if( XIIIMPPlayerController(C) != none )
//        {
//            if( C.PlayerReplicationInfo.Team.TeamIndex == TeamID )
//            {
//                BI = XIIIMPBotInteraction(XIIIMPPlayerController(C).MyInteraction );
//                BI.BotControllerList.Length = BI.BotControllerList.Length+1;
//                BI.BotControllerList[ BI.BotControllerList.Length-1 ] = self;
//
//                if( TeamID == 0 )
//                    BI.GameType = 2;
//                else
//                    BI.GameType = 1;
//            }
//        }
//	}

	//--------------

    Nav = Level.NavigationPointList;

    while( Nav != none)
    {
        if( DefensePathNode( Nav) != none )
        {
            if( DefensePathNode( Nav).BotLevel <= Skill )
            {
                switch( DefensePathNode( Nav).DefensePointID )
                {
                    case 1 :
                        if( DefensePathNode( Nav).SnipeSpot )
                        {
                            SnipeSpotList_1.Length = SnipeSpotList_1.Length+1;
                            SnipeSpotList_1[ SnipeSpotList_1.Length-1 ] = Nav;
                        }
                        else
                        {
                            DefendSpotList_1.Length = DefendSpotList_1.Length+1;
                            DefendSpotList_1[ DefendSpotList_1.Length-1 ] = Nav;
                        }
                        break;
                    case 2 :
                        if( DefensePathNode( Nav).SnipeSpot )
                        {
                            SnipeSpotList_2.Length = SnipeSpotList_2.Length+1;
                            SnipeSpotList_2[ SnipeSpotList_2.Length-1 ] = Nav;
                        }
                        else
                        {
                            DefendSpotList_2.Length = DefendSpotList_2.Length+1;
                            DefendSpotList_2[ DefendSpotList_2.Length-1 ] = Nav;
                        }
                        break;
                    case 3 :
                        if( DefensePathNode( Nav).SnipeSpot )
                        {
                            SnipeSpotList_3.Length = SnipeSpotList_3.Length+1;
                            SnipeSpotList_3[ SnipeSpotList_3.Length-1 ] = Nav;
                        }
                        else
                        {
                            DefendSpotList_3.Length = DefendSpotList_3.Length+1;
                            DefendSpotList_3[ DefendSpotList_3.Length-1 ] = Nav;
                        }
                        break;
                }
            }
        }
        else if( MPBombingBase( Nav) != none )
        {
            BombPoint[ MPBombingBase( Nav).BombPointID -1 ] = MPBombingBase( Nav);
        }
        else if( AttackPathNode( Nav) != none )
        {
            AttackPointList.Length = AttackPointList.Length+1;
            AttackPointList[ AttackPointList.Length-1 ] = Nav;
        }
        else if( GroupPathNode( Nav) != none )
        {
            GroupPointList.Length = GroupPointList.Length+1;
            GroupPointList[ GroupPointList.Length-1 ] = Nav;
        }




        Nav = Nav.NextNavigationPoint;
    }

	//--------------

    foreach DynamicActors(class'XIIIMPSabotageStorage', StorageObj)
    {
        if( StorageObj.TeamId == TeamId )
            break;
    }

	//--------------

    foreach DynamicActors(class'PickUp', A)
    {
        FullPickUpList.Length = FullPickUpList.Length+1;
        FullPickUpList[ FullPickUpList.Length-1 ] = A;

        if( XIIIMPBombPick( A ) != none )
            StorageObj.TheBombPick = XIIIMPBombPick( A );
    }

	//--------------

    foreach DynamicActors(class'SabotageBotController', BOT)
    {
        if( ( Bot.TeamID == TeamID ) && ( BOT != self ) )
        {
            MyTeam.Length = MyTeam.Length+1;
            MyTeam[ MyTeam.Length-1 ] = BOT;
        }
    }

	//--------------

    foreach DynamicActors(class'Controller', C)
    {
        if( IsEnemy(C.Pawn) )
        {
            EnemyTeam.Length = EnemyTeam.Length+1;
            EnemyTeam[ EnemyTeam.Length-1 ] = C;
        }
        else
        {
            if( BotController(C) == none )
            {
                FriendTeam.Length = FriendTeam.Length+1;
                FriendTeam[ FriendTeam.Length-1 ] = C;
            }
        }
    }

	//--------------

    TeamStatus = TeamId;
    FindTeamRole();

    if( TeamStatus == cAttackStatus )
        RespawnTime=4.0;
    else
        RespawnTime=8.0;


	//--------------

    if( DBugBot )
    {
        Log("");
        Log("[ BOT"@ID@"][ Team"@TeamID@"][ Level"@int(Skill)@"] : PickUpList Construction");
        log("    > DefendPoint 1="$DefendSpotList_1.Length@"+"@SnipeSpotList_1.Length);
        log("    > DefendPoint 2="$DefendSpotList_2.Length@"+"@SnipeSpotList_2.Length);
        log("    > DefendPoint 3="$DefendSpotList_3.Length@"+"@SnipeSpotList_3.Length);
        Log("    > Other Team Bot :"@MyTeam.Length );

        if( MyTeam.Length != 0 )
        {
            for( Loop = 0 ; Loop < MyTeam.Length ; Loop++ )
                 log("     "@Loop@":"@MyTeam[ Loop ]);
        }

        Log("    > Enemy Team :"@EnemyTeam.Length );

        if( EnemyTeam.Length != 0 )
        {
            for( Loop = 0 ; Loop < EnemyTeam.Length ; Loop++ )
                 log("     "@Loop@":"@EnemyTeam[ Loop ]);
        }

        Log("    > SubTeam :"@SubTeamID);
    }
}

//__________________________________________________________________

function FindTeamRole()
{
    local int Loop,BestLevel,SecondBestLevel;
    local SabotageBotController Best,SecondBest;
    local Array<SabotageBotController> TmpTeam;
    local SabotageBotController Bot;

    if( TeamStatus == cAttackStatus )
    {
        SubTeamID = 0;
        return;
    }

    foreach DynamicActors(class'SabotageBotController', BOT)
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
        SubTeamID = 0;
        OtherSubTeamID = 1;
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
        SubTeamID = 0;
        OtherSubTeamID = 1;
        return;
    }

    SubTeamID = 1;
    OtherSubTeamID = 0;
}

//__________________________________________________________________

function int GetLifePriority()
{
    return 0;
}

//__________________________________________________________________

function bool IsEnemy( Pawn Target )
{
    return ( Target.Controller.PlayerReplicationInfo.Team.TeamIndex != TeamID );
}

//__________________________________________________________________
//__________________________________________________________________
//                            GoToDefenseSpot
//__________________________________________________________________
//__________________________________________________________________

state GoToDefenseSpot
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Go To Defense Spot");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;
        Pawn.ShouldCrouch( false );

        if( StorageObj.CurrentDefendSpot[ SubTeamID ] == -1 )
            ChooseDefendSpot();
         if( DBugBot )
			{
				log("");
				log("--------------------------------------------------");
				log(" > Defense Spot N"$StorageObj.CurrentDefendSpot[ SubTeamID ]+1);
				log("--------------------------------------------------");
				log("");
			}
    }

    //--------------------------------------------------------------

    event EndState()
    {
        if( FireMvt )
        {
            Enemy = none;

            bFire=0;
            FireMvt=false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);

            if (pawn!=none) Pawn.Weapon.ForceReload();
        }

        if (DefendPoint!=none) DefensePathNode(DefendPoint).Closed = false;
    }

    //--------------------------------------------------------------

    function FindDefendSpot()
    {
        local Array<NavigationPoint> UseablePoint;
        local int Loop;
        local NavigationPoint TmpNode;

        if ( Pawn.Weapon.InventoryGroup == 14 )
        {
            switch( StorageObj.CurrentDefendSpot[ SubTeamID ] )
            {
                case 0 :
                    for( Loop=0; Loop<SnipeSpotList_1.Length ; Loop++ )
                    {
                        TmpNode = SnipeSpotList_1[Loop];

                        if( ! DefensePathNode(TmpNode).Closed )
                        {
                            UseablePoint.Length = UseablePoint.Length+1;
                            UseablePoint[ UseablePoint.Length-1 ] = TmpNode;
                        }
                    }

                    break;
                case 1 :
                    for( Loop=0; Loop<SnipeSpotList_2.Length ; Loop++ )
                    {
                        TmpNode = SnipeSpotList_2[Loop];

                        if( ! DefensePathNode(TmpNode).Closed )
                        {
                            UseablePoint.Length = UseablePoint.Length+1;
                            UseablePoint[ UseablePoint.Length-1 ] = TmpNode;
                        }
                    }

                    break;
                case 2 :
                    for( Loop=0; Loop<SnipeSpotList_3.Length ; Loop++ )
                    {
                        TmpNode = SnipeSpotList_3[Loop];

                        if( ! DefensePathNode(TmpNode).Closed )
                        {
                            UseablePoint.Length = UseablePoint.Length+1;
                            UseablePoint[ UseablePoint.Length-1 ] = TmpNode;
                        }
                    }
                 break;
            }
        }
        else
        {
            switch( StorageObj.CurrentDefendSpot[ SubTeamID ] )
            {
                case 0 :
                    for( Loop=0; Loop<DefendSpotList_1.Length ; Loop++ )
                    {
                        TmpNode = DefendSpotList_1[Loop];

                        if( ! DefensePathNode(TmpNode).Closed )
                        {
                            UseablePoint.Length = UseablePoint.Length+1;
                            UseablePoint[ UseablePoint.Length-1 ] = TmpNode;
                        }
                    }

                    break;
                case 1 :
                    for( Loop=0; Loop<DefendSpotList_2.Length ; Loop++ )
                    {
                        TmpNode = DefendSpotList_2[Loop];

                        if( ! DefensePathNode(TmpNode).Closed )
                        {
                            UseablePoint.Length = UseablePoint.Length+1;
                            UseablePoint[ UseablePoint.Length-1 ] = TmpNode;
                        }
                    }

                    break;
                case 2 :
                    for( Loop=0; Loop<DefendSpotList_3.Length ; Loop++ )
                    {
                        TmpNode = DefendSpotList_3[Loop];

                        if( ! DefensePathNode(TmpNode).Closed )
                        {
                            UseablePoint.Length = UseablePoint.Length+1;
                            UseablePoint[ UseablePoint.Length-1 ] = TmpNode;
                        }
                    }

                    break;
            }
        }

        if( UseablePoint.Length != 0 )
			{
            DefendPoint = UseablePoint[ Rand(UseablePoint.Length) ];
			}

        else
			{
				log(self@" a plus de defend point de disponible");
            DefendPoint = none;
			}
    }

    //--------------------------------------------------------------

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( Agressor == Pawn )
            return;

        SeePlayer( Agressor );
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        local float DistToBombingPoint;
        local int NbAttacker;

        if( ( ( ! IsEnemy( Seen ) ) || DamnedImFlashed ) || ( ! IsShootable( Seen ) ) )
            return;

        if( Enemy == none )
        {
            DistToBombingPoint = VSize( Seen.Location - BombPoint[ StorageObj.CurrentDefendSpot[ SubTeamID ] ].Location );
            NbAttacker = GiveTheNumberOfEnemyInTheZone( Seen );

            Enemy = Seen;

            if( ( ( StorageObj.CurrentDefendSpot[ OtherSubTeamID ] != StorageObj.CurrentDefendSpot[ SubTeamID ] ) && ( NbAttacker > 2 ) ) && ( DistToBombingPoint < 2000 ) )
                CallTheOtherSubTeamInReinforcement();

            if( ( NbAttacker > 2 ) && ( DistToBombingPoint < 2000 ) )
                CallTheOtherBotOfMySubTeamInReinforcement();

            if( FullPath && ( PathIndex > PathCacheSize -3 ) )
            {
                FireMvt=true;
                SetTimer( (4-Skill)*0.2+FRand()/2 ,False );
                Focus = Enemy;
            }
            else
            {
                if (DefendPoint!=none) DefensePathNode(DefendPoint).Closed = false;

                if( !FindOrder( Order_Kill ) )
                    AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
            }
        }
    }

    //--------------------------------------------------------------

    event EnemyNotVisible()
    {
        if( FireMvt )
        {
            Enemy = none;

            bFire=0;
            FireMvt=false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);

            Pawn.Weapon.ForceReload();
        }
    }

    //--------------------------------------------------------------

Begin:

    FindDefendSpot();

    if( DefendPoint != none )
    {
        DefensePathNode(DefendPoint).Closed = true;

        while( true )
        {
            NavPathStorage(DefendPoint);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                if( FireMvt )
                    MoveToward( MoveTarget, Enemy , MoveSpeed );
                else
                    MoveToward( MoveTarget, Focus , MoveSpeed );

                if( ForceSwitchSpot )
                {
                    if( DBugBot )
                    {
                        Log("");
                        Log("[ BOT"@ID@"] : Player Change Order_GoToDefenseSpot");
                    }

                    ForceSwitchSpot = false;
                    DefensePathNode(DefendPoint).Closed = false;
                    goto('begin');
                }

                if( SubTeamBotSwitchTheSpot )
                {
                    if( DBugBot )
                    {
                        Log("");
                        Log("[ BOT"@ID@"] : Other Bot Change Order_GoToDefenseSpot");
                    }

                    SubTeamBotSwitchTheSpot = false;
                    DefensePathNode(DefendPoint).Closed = false;
                    goto('begin');
                }
            }

            if( FullPath )
                break;
        }
    }
    else
    {
        //log("Oups !");
        RemoveOrder( Order_GoToDefenseSpot );
		  stop;
    }

    AddOrder(50,Order_DefendTheSpot,"DefendTheSpot",0);
    RemoveOrder( Order_GoToDefenseSpot );
}

//__________________________________________________________________
//__________________________________________________________________
//                            DefendTheSpot
//__________________________________________________________________
//__________________________________________________________________

state DefendTheSpot
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> DefendTheSpot");
        }

        Enemy = none;
        //Pawn.ControllerPitch = 0;

        Pawn.velocity=vect(0,0,0);
        Pawn.acceleration=vect(0,0,0);
        Focus = none;
        FocalPoint = vector(DefendPoint.Rotation)+Pawn.Location;

        if( DefensePathNode(DefendPoint).MustBeCrouched )
        {
            Pawn.ShouldCrouch( true );
        }
        else if( DefensePathNode(DefendPoint).DoNotCrouch )
        {
            Pawn.ShouldCrouch( false );
        }
        else if( Rand( 100 ) < 20 + Skill*20 )
        {
            Pawn.ShouldCrouch( true );
        }
        else
            Pawn.ShouldCrouch( false );

        Pawn.SpineYawControl(true,3000, 1.2);

        if( TotalDefendTime == -1 )
            TotalDefendTime = Level.TimeSeconds;
        if( DBugBot )
        		log(" > Defense Spot N"$StorageObj.CurrentDefendSpot[ SubTeamID ]);
    }

    //--------------------------------------------------------------

    event EndState()
    {
		  if (pawn!=none)
		  {
        		Pawn.SpineYawControl(false,3000, 1.2);
        		Pawn.ShouldCrouch( false );
		  }
        DefensePathNode(DefendPoint).Closed = false;
    }

    //--------------------------------------------------------------

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( Agressor == Pawn )
            return;

        SeePlayer( Agressor );
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        if( ( ( ! IsEnemy( Seen ) ) || DamnedImFlashed ) || ( ! IsShootable( Seen ) ) )
            return;

        if( Enemy == none )
        {
            TotalDefendTime = -1;
            Enemy = Seen;

            if( ( StorageObj.CurrentDefendSpot[ OtherSubTeamID ] != StorageObj.CurrentDefendSpot[ SubTeamID ] ) && ( GiveTheNumberOfEnemyInTheZone( Seen ) > 2 ) )
                CallTheOtherSubTeamInReinforcement();

            CallTheOtherBotOfMySubTeamInReinforcement();

            if( CoverFightOrKill( Seen ) )
            {
                if( !FindOrder( Order_CoverFight ) )
                    AddOrder(KillOrderPriority,Order_CoverFight,"Cover Fight",0);
            }
            else
            {
                if( !FindOrder( Order_Kill ) )
                    AddOrder(KillOrderPriority,Order_Kill,"Kill",Order_DefendTheSpot);
            }
        }
    }

    //--------------------------------------------------------------

Begin:

    DefendTime = Level.TimeSeconds;
    MaxDefendTime = 10 + Rand( 5 );

    while( true )
    {
        Sleep( 1.0 );

        if( ForceSwitchSpot )
        {
            if( DBugBot )
            {
                Log("");
                Log("[ BOT"@ID@"] : Player Stop Order_DefendTheSpot");
            }

            TotalDefendTime = -1;
            ForceSwitchSpot = false;
            RemoveOrder( Order_DefendTheSpot );
        }

        if( SubTeamBotSwitchTheSpot )
        {
            if( DBugBot )
            {
                Log("");
                Log("[ BOT"@ID@"] : Other Bot Stop Order_DefendTheSpot");
            }

            TotalDefendTime = -1;
            SubTeamBotSwitchTheSpot = false;
            RemoveOrder( Order_DefendTheSpot );
        }

        if( ( Level.TimeSeconds - DefendTime > MaxDefendTime ) || ( BombSpotStatus[ StorageObj.CurrentDefendSpot[ SubTeamID ] ] == 0 ) )
            break;
    }

    if( ( ! StorageObj.ForceDefenseTeamRole ) && ( Level.TimeSeconds - TotalDefendTime > TotalMaxDefendTime ) )
    {
        TotalDefendTime = -1;
        SwitchDefendSpot();
    }

    RemoveOrder( Order_DefendTheSpot );
}


//__________________________________________________________________
//__________________________________________________________________
//                            BackToHomeBase
//__________________________________________________________________
//__________________________________________________________________

state BackToHomeBase
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> BackToHomeBase");
        }

        Pawn.ShouldCrouch( false );
    }

    //--------------------------------------------------------------

    event EndState()
    {
        if (AttackPoint!=none) AttackPathNode(AttackPoint).Closed = false;
    }

    //--------------------------------------------------------------

    function FindAttackSpot()
    {
        local Array<NavigationPoint> UseablePoint;
        local int Loop, Tmp;
        local NavigationPoint TmpNode;

        for( Loop=0; Loop<AttackPointList.Length ; Loop++ )
        {
            TmpNode = AttackPointList[Loop];

            if( AttackPathNode(TmpNode).Group == 0 )
                Tmp++;

            if( ( ! AttackPathNode(TmpNode).Closed ) && ( AttackPathNode(TmpNode).Group == 0 ) )
            {
                UseablePoint.Length = UseablePoint.Length+1;
                UseablePoint[ UseablePoint.Length-1 ] = TmpNode;
            }
        }

    	if( DBugBot )
		{
        		Log("");
        		log("[ BOT"@ID@"] : BackToHomeBase ---> FreePoint:"@UseablePoint.Length$"/"$Tmp);
		}
       if( UseablePoint.Length != 0 )
            AttackPoint = UseablePoint[ Rand(UseablePoint.Length) ];
        else
            AttackPoint = none;
    }

    //--------------------------------------------------------------

    function bool AllReady()
    {
        local int Loop , NbReady , NbBot;

        for( Loop=0;Loop<MyTeam.Length;Loop++ )
        {
            if( MyTeam[ Loop ].IsInState('BackToHomeBase' ) )
            {
                NbBot++;

                if( MyTeam[ Loop ].ReadyForNextAttackPoint )
                    NbReady++;
            }
        }

        if( NbReady == NbBot )
            return true;
        else
            return false;
    }

    //--------------------------------------------------------------

begin :

    FindAttackSpot();

    if( AttackPoint != none )
    {
        AttackPathNode(AttackPoint).Closed = true;

        while( true )
        {
            NavPathStorage(AttackPoint);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                if( FireMvt )
                    MoveToward( MoveTarget, Enemy , MoveSpeed );
                else
                    MoveToward( MoveTarget, Focus , MoveSpeed );
            }

            if( FullPath )
                break;
        }
    }
	 else
	 {
        RemoveOrder( Order_GoToDefenseSpot );
		  stop;
	 }

    if( AllReady() )
    {
        if( StorageObj.TheBombPick.ReadyToPickUp(0) )
        {
            if( DBugBot )
                Log("---> Oups ! The Bomb --> TakeMyBomb");

            Sleep( 0.2 + FRand() );
            AttackPathNode(AttackPoint).Closed = false;

            Goto('TakeMyBomb');
        }
    }

    ReadyForNextAttackPoint=true;

    Pawn.ControllerPitch = 0;

    Pawn.velocity=vect(0,0,0);
    Pawn.acceleration=vect(0,0,0);
    Focus = none;
    FocalPoint = vector(AttackPoint.Rotation)+Pawn.Location;

    if( AttackPathNode(AttackPoint).MustBeCrouched )
    {
        Pawn.ShouldCrouch( true );
    }
    else if( AttackPathNode(AttackPoint).DoNotCrouch )
    {
        Pawn.ShouldCrouch( false );
    }
    else if( Rand( 100 ) < 20 + Skill*20 )
    {
        Pawn.ShouldCrouch( true );
    }
    else
        Pawn.ShouldCrouch( false );

    Pawn.SpineYawControl(true,3000, 1.2);

    while( true )
    {
        if( AllReady() )
        {
            Sleep( 1.0 + FRand() );

            ReadyForNextAttackPoint=false;
            Pawn.SpineYawControl(false,3000, 1.2);
            Pawn.ShouldCrouch( false );
            AttackPathNode(AttackPoint).Closed = false;

            RemoveOrder( Order_BackToHomeBase );
        }
        else
            Sleep( 0.5 );
    }

    //--------------------------------------------------------------

TakeMyBomb:

    Pawn.ShouldCrouch( false );

    Item = StorageObj.TheBombPick;

    while( true )
    {
        PickUpPathStorage(Item);

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            MoveToward( MoveTarget, Focus , MoveSpeed );
        }

        if( FullPath )
            break;
    }

    Goto('begin');
}

//__________________________________________________________________
//__________________________________________________________________
//                            WaitStart
//__________________________________________________________________
//__________________________________________________________________

state WaitStart
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> WaitStart");
        }

        Pawn.ShouldCrouch( false );
        ForceContinueAttackPhase = false;
    }

    //--------------------------------------------------------------

    event EndState()
    {
		  if (pawn!=none)
		  {
	        Pawn.SpineYawControl(false,3000, 1.2);
	        Pawn.ShouldCrouch( false );
		  }
        if (attackpoint!=none) AttackPathNode(AttackPoint).Closed = false;
    }

    //--------------------------------------------------------------

    function FindAttackSpot()
    {
        local Array<NavigationPoint> UseablePoint;
        local int Loop, Tmp;
        local NavigationPoint TmpNode;

        for( Loop=0; Loop<AttackPointList.Length ; Loop++ )
        {
            TmpNode = AttackPointList[Loop];

            if( AttackPathNode(TmpNode).Group == 0 )
                Tmp++;

            if( ( ! AttackPathNode(TmpNode).Closed ) && ( AttackPathNode(TmpNode).Group == 0 ) )
            {
                UseablePoint.Length = UseablePoint.Length+1;
                UseablePoint[ UseablePoint.Length-1 ] = TmpNode;
            }
        }

      if( DBugBot )
		{
			Log("");
        	Log("[ BOT"@ID@"] : BackToHomeBase ---> FreePoint:"@UseablePoint.Length$"/"$Tmp);
		}

        if( UseablePoint.Length != 0 )
            AttackPoint = UseablePoint[ Rand(UseablePoint.Length) ];
        else
            AttackPoint = none;
    }

    //--------------------------------------------------------------

    function bool AllReady()
    {
        local int Loop , NbReady , NbBot;

        for( Loop=0;Loop<MyTeam.Length;Loop++ )
        {
            if( MyTeam[ Loop ].IsInState('WaitStart' ) )
            {
                NbBot++;

                if( MyTeam[ Loop ].ReadyForNextAttackPoint )
                    NbReady++;
            }
        }

        if( NbReady == NbBot )
            return true;
        else
            return false;
    }

    //--------------------------------------------------------------

    function AloneOrNot()
    {
        local int Loop , NbReady , NbBot;

        for( Loop=0;Loop<MyTeam.Length;Loop++ )
        {
            if( MyTeam[ Loop ].IsInState('WaitStart' ) )
                NbBot++;
        }

        if( NbBot == 0 )
            AloneRun = true;
        else
            AloneRun = false;
    }

    //--------------------------------------------------------------

begin :

      if( WaitToStart )
      {
          Sleep( TimeToWaitBeforeStart + Rand( 3-Skill )*0.5 );
          WaitToStart = false;
      }

      if( TeamStatus == cAttackStatus )
      {
          if( ShouldTakeTheBomb( Pawn ) )
          {
                if( DBugBot )
                    Log("---> TakeMyBomb");

                Goto('TakeMyBomb');
          }
          else
          {
                if( DBugBot )
                    Log("---> WaitRestOfTheTeam");

                Goto('WaitRestOfTheTeam');
          }
      }
      else
          RemoveOrder( Order_WaitToStart );


    //--------------------------------------------------------------

WaitRestOfTheTeam:

    AloneOrNot();

    if( AloneRun )
        Goto('ForcedGoJump');

    FindAttackSpot();

    if( AttackPoint != none )
    {
        AttackPathNode(AttackPoint).Closed = true;

        while( true )
        {
            NavPathStorage(AttackPoint);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                if( FireMvt )
                    MoveToward( MoveTarget, Enemy , MoveSpeed );
                else
                    MoveToward( MoveTarget, Focus , MoveSpeed );
            }

            if( FullPath )
                break;
        }
    }

    if( DBugBot )
        Log("---> Ready !");

    if( AllReady() )
    {
        if( StorageObj.TheBombPick.ReadyToPickUp(0) )
        {
            if( DBugBot )
                Log("---> Oups ! The Bomb --> TakeMyBomb");

            Sleep( 0.2 + FRand() );
            AttackPathNode(AttackPoint).Closed = false;

            Goto('TakeMyBomb');
        }
    }

    ReadyForNextAttackPoint=true;

    Pawn.ControllerPitch = 0;

    Pawn.velocity=vect(0,0,0);
    Pawn.acceleration=vect(0,0,0);
    Focus = none;
    FocalPoint = vector(AttackPoint.Rotation)+Pawn.Location;

    if( AttackPathNode(AttackPoint).MustBeCrouched )
    {
        Pawn.ShouldCrouch( true );
    }
    else if( AttackPathNode(AttackPoint).DoNotCrouch )
    {
        Pawn.ShouldCrouch( false );
    }
    else if( Rand( 100 ) < 20 + Skill*20 )
    {
        Pawn.ShouldCrouch( true );
    }
    else
        Pawn.ShouldCrouch( false );

    Pawn.SpineYawControl(true,3000, 1.2);

ForcedGoJump:

    while( true )
    {
        if( AllReady() )
        {
            Sleep( 1.0 + FRand() );

            ReadyForNextAttackPoint=false;
            Pawn.SpineYawControl(false,3000, 1.2);
            Pawn.ShouldCrouch( false );
            AttackPathNode(AttackPoint).Closed = false;

            RemoveOrder( Order_WaitToStart );
        }
        else
            Sleep( 0.5 );
    }

    //--------------------------------------------------------------

TakeMyBomb:

    Pawn.ShouldCrouch( false );

    Item = StorageObj.TheBombPick;

    if( ( Item == none ) || ( ! PickUp(Item).ReadyToPickUp(0) ) )
    {
        Sleep( 0.5 );
        RemoveOrder( Order_TakeTheBomb );
    }
    else
    {
        while( true )
        {
            PickUpPathStorage(Item);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                MoveToward( MoveTarget, Focus , MoveSpeed );
            }

            if( FullPath )
                break;
        }

        if( DBugBot )
            Log("---> WaitRestOfTheTeam");

        Goto('WaitRestOfTheTeam');
    }
}


//__________________________________________________________________
//__________________________________________________________________
//                            AntiBug
//__________________________________________________________________
//__________________________________________________________________

state AntiBug
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> AntiBug");
        }
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
        WaitToStart = true;
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            Kill
//__________________________________________________________________
//__________________________________________________________________

state Kill
{
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

        if( IsInBombArea( Enemy ) )
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
}

//__________________________________________________________________
//__________________________________________________________________
//                            CoverFight
//__________________________________________________________________
//__________________________________________________________________

state CoverFight
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> CoverFight");
            Log("    > Enemy :"@Enemy);
        }

        if( Enemy == Pawn )
        {
            Enemy = none ;
            RemoveOrder( Order_CoverFight );
        }

        Focus = Enemy;
        Pawn.velocity=vect(0,0,0);
        Pawn.acceleration=vect(0,0,0);
        InitShotError(false);

        if( Pawn.WeaponMode == 'FM_Snipe' )
        {
            SetTimer( 0.5 + FRand(), false );
        }
        else
            SetTimer( (4-Skill)*0.2+FRand()/2 ,False );
    }

    //--------------------------------------------------------------

    event EndState()
    {
        bFire=0;
        SetTimer(0.0,false);
        SetTimer2(0.0,false);

        if (pawn!=none) Pawn.Weapon.ForceReload();
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        if( ! IsEnemy( Seen ) )
            return;

        else if( ( IsNearest( Enemy,Seen) ) || ( ! CoverFightOrKill( Seen ) ) )
        {
            Enemy = Seen;

            if( !FindOrder( Order_Kill ) )
                AddOrder(KillOrderPriority,Order_Kill,"Kill",0);

            RemoveOrder( Order_CoverFight );
        }
    }

    //--------------------------------------------------------------

    event EnemyNotVisible()
    {
        if( bFireMove )
        {
            bFire=0;

            SetTimer(0.0,false);
            SetTimer2(0.0,false);
        }
        else
        {
            bFire=0;
            Enemy = none;

            RemoveOrder( Order_CoverFight );
        }
    }

    //--------------------------------------------------------------

    function SomeoneWantKillMe( Pawn Agressor )
    {
        bFireMove = true;

        if( Agressor == Enemy )
            return;

        SeePlayer( Agressor );
    }

    //--------------------------------------------------------------

Begin:


    while( true )
    {
        Sleep( ( 4-skill)*StraffeDelay );

        if( bFireMove )
        {
            if( ( ! Pawn.bIsCrouched ) && ( Rand( 100 ) < (Skill+1)*25 ) )
                Pawn.ShouldCrouch( true );

            Sleep( 1.0 + FRand() );

            if( DefensePathNode(DefendPoint).MustBeCrouched )
            {
                Pawn.ShouldCrouch( true );
            }
            else if( DefensePathNode(DefendPoint).DoNotCrouch )
            {
                Pawn.ShouldCrouch( false );
            }
            else if( Rand( 100 ) < 20 + Skill*20 )
            {
                Pawn.ShouldCrouch( true );
            }
            else
                Pawn.ShouldCrouch( false );

            bFireMove=false;
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
        MaxSeekTime = 5;
        super.BeginState();
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            GoToAttackSpot
//__________________________________________________________________
//__________________________________________________________________

state GoToAttackSpot
{
    event BeginState()
    {
        local int loop;

        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Go To Attack Spot");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;
        Pawn.ShouldCrouch( false );

        if( StorageObj.CurrentAttackSpot[ SubTeamID ] == -1 )
            ChooseAttackSpot();

        AttackPhaseNumber = StorageObj.Possibility.Length;

        if( ! ForceContinueAttackPhase )
            AttackPhaseIndex = 0;

        bFire=0;
        FireMvt=false;
        SetTimer(0.0,false);
        SetTimer2(0.0,false);

        Pawn.Weapon.ForceReload();

		if( DBugBot )
		{
        log("");
        log("--------------------------------------------------");
        log(" > Attack Spot N"$StorageObj.CurrentAttackSpot[ SubTeamID ]+1);
        log("   > AttackPhaseNumber:"@AttackPhaseNumber);

        for( Loop=0 ; loop < StorageObj.Possibility.Length ; loop++ )
        log("   >"@StorageObj.Possibility[Loop]);
        log("--------------------------------------------------");
        log("");
		}
    }

    //--------------------------------------------------------------

    event EndState()
    {
        if (pawn!=none)
			{
				Pawn.SpineYawControl(false,3000, 1.2);
				Pawn.ShouldCrouch( false );
				AttackPathNode(AttackPoint).Closed = false;
		  }
        if( FireMvt )
        {
            Enemy = none;

            bFire=0;
            FireMvt=false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);

            if (pawn!=none) Pawn.Weapon.ForceReload();
        }

        if( FindOrder( Order_Kill ) )
            ForceContinueAttackPhase = true;
        else
            ForceContinueAttackPhase = false;
    }

    //--------------------------------------------------------------

    function FindAttackSpot()
    {
        local Array<NavigationPoint> UseablePoint;
        local int Loop;
        local NavigationPoint TmpNode;

        for( Loop=0; Loop<AttackPointList.Length ; Loop++ )
        {
            TmpNode = AttackPointList[Loop];

            if( (!AttackPathNode(TmpNode).Closed ) && ( AttackPathNode(TmpNode).Group == StorageObj.Possibility[ AttackPhaseIndex ] ) )
            {
                UseablePoint.Length = UseablePoint.Length+1;
                UseablePoint[ UseablePoint.Length-1 ] = TmpNode;
            }
        }

        if( UseablePoint.Length != 0 )
            AttackPoint = UseablePoint[ Rand(UseablePoint.Length) ];
        else
            AttackPoint = none;
    }

    //--------------------------------------------------------------

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( Agressor == Pawn )
            return;

        SeePlayer( Agressor );
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        if( ( ( ! IsEnemy( Seen ) ) || DamnedImFlashed ) || ( ! IsShootable( Seen ) ) )
            return;

        if( Enemy == none )
        {
            Enemy = Seen;

            if( FullPath && ( PathIndex > PathCacheSize -3 ) )
            {
                FireMvt=true;
                SetTimer( (4-Skill)*0.2+FRand()/2 ,False );
                Focus = Enemy;
            }
            else
            {
                if (DefendPoint!=none) DefensePathNode(DefendPoint).Closed = false;

                if( !FindOrder( Order_Kill ) )
                    AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
            }
        }
    }

    //--------------------------------------------------------------

    event EnemyNotVisible()
    {
        if( FireMvt )
        {
            Enemy = none;

            bFire=0;
            FireMvt=false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);

            Pawn.Weapon.ForceReload();
        }
    }

    //--------------------------------------------------------------

    function bool AllReady()
    {
        local int Loop , NbReady , NbBot;

        for( Loop=0;Loop<MyTeam.Length;Loop++ )
        {
            if( ( MyTeam[ Loop ].AttackPhaseIndex == AttackPhaseIndex ) && ( MyTeam[ Loop ].IsInState('GoToAttackSpot' ) ) )
            {
                NbBot++;

                if( MyTeam[ Loop ].ReadyForNextAttackPoint )
                    NbReady++;
            }

        }

        if( NbReady == NbBot )
            return true;
        else
            return false;
    }

    //--------------------------------------------------------------

    function AloneOrNot()
    {
        local int Loop , NbReady , NbBot;

        for( Loop=0;Loop<MyTeam.Length;Loop++ )
        {
            if( ( MyTeam[ Loop ].AttackPhaseIndex == AttackPhaseIndex ) && ( MyTeam[ Loop ].IsInState('GoToAttackSpot' ) ) )
                NbBot++;
        }

        if( NbBot == 0 )
            AloneRun = true;
        else
            AloneRun = false;
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

    FindAttackSpot();

    if( AttackPoint != none )
    {
        AttackPathNode(AttackPoint).Closed = true;

		if( DBugBot )
		{
        Log("");
        log("--- [ BOT"@ID@"] : GO"@StorageObj.Possibility[AttackPhaseIndex]@"("@AttackPoint@") ---");
		}

        while( true )
        {
            NavPathStorage(AttackPoint);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                if( FireMvt )
                    MoveToward( MoveTarget, Enemy , MoveSpeed );
                else
                    MoveToward( MoveTarget, Focus , MoveSpeed );
            }

            if( FullPath )
                break;
        }
    }
    else
    {
        RemoveOrder( Order_GoToAttackSpot );
    }

    ReadyForNextAttackPoint=true;

    Pawn.ControllerPitch = 0;

    Pawn.velocity=vect(0,0,0);
    Pawn.acceleration=vect(0,0,0);
    Focus = none;
    FocalPoint = vector(AttackPoint.Rotation)+Pawn.Location;

    if( AttackPathNode(AttackPoint).MustBeCrouched )
    {
        Pawn.ShouldCrouch( true );
    }
    else if( AttackPathNode(AttackPoint).DoNotCrouch )
    {
        Pawn.ShouldCrouch( false );
    }
    else if( Rand( 100 ) < 20 + Skill*20 )
    {
        Pawn.ShouldCrouch( true );
    }
    else
        Pawn.ShouldCrouch( false );

    Pawn.SpineYawControl(true,3000, 1.2);

    GetAttackPointTime();

    AloneOrNot();

    if( ( AttackPointTime != 0 ) && ( ! AloneRun ) )
        sleep( AttackPointTime );

    while( true )
    {
        if( AllReady() )
        {
            if( ! AloneRun )
                Sleep( 0.1 + FRand() );
            else
                Sleep( 1.0 );

            ReadyForNextAttackPoint=false;
            AttackPhaseIndex++;

            if( AttackPhaseIndex == AttackPhaseNumber-1 )
            {
                if( BombCarrier( Pawn ) )
                {
						if( DBugBot )
						{
                    Log("");
                    log("--- [ BOT"@ID@"] : GO TO BOMBSPOT ---");
						}
                    Sleep( 3.0 + FRand() );
                    AddOrder(78,Order_PutTheBomb,"Order_PutTheBomb",0);
                }
                else
                {
					   if( DBugBot )
						{
                    Log("");
                    log("--- [ BOT"@ID@"] : COVER BOMBSPOT ---");
						}
                    AddOrder(78,Order_CoverTheBomb,"CoverTheBomb",0);
                }
            }

            Pawn.SpineYawControl(false,3000, 1.2);
            Pawn.ShouldCrouch( false );
            AttackPathNode(AttackPoint).Closed = false;
            Goto('begin');
        }
        else
            Sleep( 0.5 );
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            TakeTheBomb
//__________________________________________________________________
//__________________________________________________________________

state TakeTheBomb
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Take The Bomb");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen );

    //--------------------------------------------------------------

    function SomeoneWantKillMe( Pawn Agressor );

    //--------------------------------------------------------------

Begin:

    Item = StorageObj.TheBombPick;

    if( ( Item == none ) || ( ! PickUp(Item).ReadyToPickUp(0) ) )
    {
        Sleep( 0.5 );
        RemoveOrder( Order_TakeTheBomb );
    }
    else
    {
        while( true )
        {
            PickUpPathStorage(Item);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                MoveToward( MoveTarget, Focus , MoveSpeed );
            }

            if( FullPath )
                break;
        }

        RemoveOrder( Order_TakeTheBomb );
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            PutTheBomb
//__________________________________________________________________
//__________________________________________________________________

state PutTheBomb
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Put The Bomb");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );
    }

    //--------------------------------------------------------------

    event EndState()
    {
        bFire = 0;

        SetTimer(0.0,false);
        SetTimer2(0.0,false);
        SetTimer3(0.0,false);
			if (pawn!=none)
			{
	        Pawn.ControllerPitch = 0;

	        Pawn.ShouldCrouch( false );
	        Pawn.SpineYawControl(false,3000, 1.2);
		  }
        SwitchWeapon();
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        if( IsEnemy( Seen ) )
            SomeoneWantKillMe( Seen );
    }

    //--------------------------------------------------------------

    function SomeoneWantKillMe( Pawn Agressor )
    {
        local int Loop;

        if( ! SubTeamInit )
            InitializeSubTeam();

        if( MyTeam.Length != 0 )
        {
            for( Loop=0;Loop<MyTeam.Length;Loop++ )
            {
                if( MyTeam[ Loop ].Enemy != Agressor )
                    MyTeam[ Loop ].FocusFire( Agressor );
            }
        }

        if( ( bFire == 1 ) && ( LatentFloat < 4.0 ) )
            return;
        else
            global.SomeoneWantKillMe( Agressor );
    }

    //--------------------------------------------------------------

    function Kassos()
    {
        local int Loop;
        local float DistToTheBomb;

        if( ! SubTeamInit )
            InitializeSubTeam();

        for( Loop=0;Loop<MyTeam.Length;Loop++ )
        {
            MyTeam[ Loop ].AddOrder(79,Order_BackToHomeBase,"BackToHomeBase",Order_CoverTheBomb);
        }
    }

    //--------------------------------------------------------------

Begin:

    AttackPoint = BombPoint[ StorageObj.CurrentAttackSpot[ SubTeamID ] ];

    while( true )
    {
        NavPathStorage(AttackPoint);

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            MoveToward( MoveTarget, Focus , MoveSpeed );
        }

        if( FullPath )
            break;

        if( VSize( Pawn.Location - AttackPoint.Location ) < BombPoint[ StorageObj.CurrentAttackSpot[ SubTeamID ] ].CollisionRadius )
            break;
    }

    Pawn.ControllerPitch = 0;

    Pawn.velocity=vect(0,0,0);
    Pawn.acceleration=vect(0,0,0);

    Focus = none;
    FocalPoint = vector(AttackPoint.Rotation)+Pawn.Location;

    Pawn.ShouldCrouch( true );
    Pawn.SpineYawControl(true,3000, 1.2);

    Pawn.PendingWeapon = weapon(Pawn.FindInventoryType(class'MPBomb'));
    Pawn.Weapon.PutDown();

    sleep( 2.0 );

    bFire=1;
    Pawn.Weapon.Fire(0);

    sleep(16.0);

    Kassos();

    AddOrder(79,Order_BackToHomeBase,"BackToHomeBase",Order_PutTheBomb);
}

//__________________________________________________________________
//__________________________________________________________________
//                            CoverTheBomb
//__________________________________________________________________
//__________________________________________________________________

state CoverTheBomb
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Cover The Bomb");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;
        Pawn.ShouldCrouch( false );
    }

    event EndState()
    {
        if (pawn!=none) Pawn.SpineYawControl(false,3000, 1.2);
        AttackPathNode(AttackPoint).Closed = false;
    }

    //--------------------------------------------------------------

    function FindAttackSpot()
    {
        local Array<NavigationPoint> UseablePoint;
        local int Loop;
        local NavigationPoint TmpNode;

        for( Loop=0; Loop<AttackPointList.Length ; Loop++ )
        {
            TmpNode = AttackPointList[Loop];

            if( ( ! AttackPathNode(TmpNode).Closed ) && ( AttackPathNode(TmpNode).Group == StorageObj.Possibility[ AttackPhaseIndex ] ) )
            {
                UseablePoint.Length = UseablePoint.Length+1;
                UseablePoint[ UseablePoint.Length-1 ] = TmpNode;
            }
        }

        if( UseablePoint.Length != 0 )
            AttackPoint = UseablePoint[ Rand(UseablePoint.Length) ];
        else
            AttackPoint = none;
    }

    //--------------------------------------------------------------

Begin:

    FindAttackSpot();

    if( AttackPoint != none )
    {
        AttackPathNode(AttackPoint).Closed = true;

        while( true )
        {
            NavPathStorage(AttackPoint);

            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                MoveToward( MoveTarget, Focus , MoveSpeed );
            }

            if( FullPath )
                break;

            if( VSize( Pawn.Location - AttackPoint.Location ) < BombPoint[ StorageObj.CurrentAttackSpot[ SubTeamID ] ].CollisionRadius )
                break;
        }

        Pawn.velocity=vect(0,0,0);
        Pawn.acceleration=vect(0,0,0);
        Focus = none;
        FocalPoint = vector(AttackPoint.Rotation)+Pawn.Location;

        if( AttackPathNode(AttackPoint).MustBeCrouched )
        {
            Pawn.ShouldCrouch( true );
        }
        else if( AttackPathNode(AttackPoint).DoNotCrouch )
        {
            Pawn.ShouldCrouch( false );
        }
        else if( Rand( 100 ) < 20 + Skill*20 )
        {
            Pawn.ShouldCrouch( true );
        }
        else
            Pawn.ShouldCrouch( false );

        Pawn.SpineYawControl(true,3000, 1.2);
    }
}

//__________________________________________________________________



defaultproperties
{
     BombSpotStatus(0)=1
     BombSpotStatus(1)=1
     BombSpotStatus(2)=1
     TeamStatus=1
     TotalDefendTime=-1.000000
     TotalMaxDefendTime=40.000000
     WaitToStart=True
     TimeToWaitBeforeStart=2.000000
}
