//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TeamBotController extends BotController;

var Array<TeamBotController> MyTeam;
var pawn Leader;
var bool UnBumping;
var float LastBumpingTime;
var bool IsGrouped;
var XIIIMPTeamStorage StorageObj;
var int RepeatGrouping;
var pawn UnBumpActor;
var vector UnBlockPos1,UnBlockPos2;


const Order_Grouping       = 512;
const Order_UnBump         = 2147483648; //31


//__________________________________________________________________

function bool CanTryToHelp(TeamBotController Bot)
{
    if( Bot.Enemy != none )
        return false;

    if( Bot.IsInState('Dead') || Bot.IsInState('GameEnded') )
        return false;
    else
        return true;
}

//__________________________________________________________________

function TryToHelpMe()
{
    local int loop;
    local TeamBotController TmpBot;
    local vector MyVect,OtherVect;

    for( Loop=0;Loop<MyTeam.Length;Loop++)
    {
        TmpBot = MyTeam[Loop];

        if( CanTryToHelp( TmpBot ) )
        {
            if( VSize( Pawn.Location - TmpBot.Pawn.Location ) < 2500 )
            {
                MyVect = Pawn.Location;
                OtherVect = TmpBot.Pawn.Location;
                OtherVect.Z = MyVect.Z;

                if( ( normal( MyVect - OtherVect ) dot ( vector( TmpBot.Pawn.Rotation ) ) ) > 0.7 )
                {
                    if( FastTrace( Pawn.Location, TmpBot.Pawn.Location ) )
                    {
                        TmpBot.SeePlayer(Enemy);
                    }
                }
            }
        }
    }

}

//__________________________________________________________________

function FindTeamRole()
{
    local int Loop,BestLevel,SecondBestLevel,WorstLevel;
    local TeamBotController Best,SecondBest,Worst;
    local Array<TeamBotController> TmpTeam;
    local TeamBotController Bot;


    foreach DynamicActors(class'TeamBotController', BOT)
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
        TeamRole = 0;
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
        TeamRole = 0;
        return;
    }

    TeamRole = 1;
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

        AddOrder( 35,Order_Grouping,"Grouping",0);
    }

    LastDefaultOrderTime = Level.TimeSeconds;
}

//__________________________________________________________________

event ChangeState()
{
    switch( CurrentOrder.TypeId )
    {
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

function InitPickUpList()
{
    local PickUp A;
    local NavigationPoint Nav;
    local Pawn P;
    local TeamBotController Bot;
    local int Loop;

    bInitPickUpList = true;

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

        Nav = Nav.NextNavigationPoint;
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

    foreach DynamicActors(class'XIIIMPTeamStorage', StorageObj)
    {
        if( StorageObj.TeamId == TeamId )
            break;
    }

    FindTeamRole();

    if( DBugBot )
    {
        Log("");
        Log("[ BOT"@ID@"] : PickUpList Construction");
        log("    > MedKit="$MedKitList.Length);
        log("    > Weapon="$WeaponList.Length);
        log("    > Armor="$ArmorList.Length);
        log("    > SnipePoint="$SnipeSpotList.Length);
        Log("    > Other Team Bot :"@MyTeam.Length );
    }
}

//__________________________________________________________________

function bool IsEnemy( Pawn Target )
{
    return ( Target.Controller.PlayerReplicationInfo.Team.TeamIndex != TeamID );
}

//__________________________________________________________________

event bool NotifyBump(Actor Other)
{
	local Pawn BumpPawn;
//    if( LastBumpingTime == -1 )
//        LastBumpingTime = Level.TimeSeconds;
//    else if ( Level.TimeSeconds - LastBumpingTime > 3.0 )
//        LastBumpingTime = Level.TimeSeconds;
	BumpPawn=Pawn(other);
    if ( BumpPawn!= none && !BumpPawn.bIsDead)
    {
        if( Pawn.velocity!=vect(0,0,0) )
        {
				if( ! IsEnemy( Pawn(Other) ) )
            {
					UnBumpActor = Pawn(Other);
					AddOrder(79,Order_UnBump,"Un Bump",0);
            }
        }
    }
	 return false;
}

//__________________________________________________________________
//__________________________________________________________________
//                            Grouping
//__________________________________________________________________
//__________________________________________________________________

state Grouping
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Grouping");

        }

        Enemy = none;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );

        RepeatGrouping = 0;
    }

    //--------------------------------------------------------------

    event SeePlayer( Pawn Seen )
    {
        if( ( Seen == Leader ) && ( VSize( Pawn.Location - Leader.Location ) < 500 ) )
        {
            if( DBugBot )
            {
                Log("");
                Log("[ BOT"@ID@"] : FIND The LEADER");
            }

            IsGrouped = true;
            gotostate('Grouping','TakeGodPrey');
        }
        else
            global.SeePlayer( Seen );
    }

    //--------------------------------------------------------------

    function FindPathToMyLeader()
    {
        local actor Path;

        if( Leader == none || Leader.bIsDead)
            return;

        if( DBugBot ) Log(" > Search for"@Leader);

        Path = ExtendFindPathToward(Leader);

//        if( Path == none )
//            Path = FindPathToward(Leader);

        if( Path == none )
        {
            if( DBugBot ) Log("  > Failed ....");
            Leader = none;
        }
        else
        {
            MoveTarget = Path;

            if( DBugBot )
                Log("    > Ok");
        }
    }

    //--------------------------------------------------------------

    function FindMyBinome()
    {
        local Controller C;
        local float TmpDist, BestDist;
        local Array<Pawn> TmpBinome;

        Leader = none ;

        foreach DynamicActors(class'Controller', C)
        {
            if( ( C.PlayerReplicationInfo.Team.TeamIndex == TeamID ) && ( C != self ) )
            {
                if( ( C.Pawn != none ) && ( ! C.Pawn.bIsDead ) )
                {
                    if( ( TeamBotController(C) != none ) && ( TeamBotController(C).TeamRole == TeamRole ) )
                    {
                        Leader = C.Pawn;
                        return;
                    }
                    else
                    {
                        TmpBinome.Length = TmpBinome.Length+1;
                        TmpBinome[ TmpBinome.Length-1 ] = C.Pawn;
                    }
                }
            }
        }

        if( ( Leader == none ) && ( TmpBinome.Length != 0 ) )
            Leader = TmpBinome[ Rand(TmpBinome.Length) ];
    }

    //--------------------------------------------------------------

    function FindRandomTeamPrey()
    {
        local Controller C;
        local Array<Pawn> TmpPrey;

        if( StorageObj.Prey[ TeamID ] != none )
            return;

        foreach DynamicActors(class'Controller', C)
        {
            if( C.PlayerReplicationInfo.Team.TeamIndex != TeamID )
            {
                if( ( C.Pawn != none ) && ( ! C.Pawn.bIsDead ) )
                {
                    TmpPrey.Length = TmpPrey.Length+1;
                    TmpPrey[ TmpPrey.Length-1 ] = C.Pawn;
                }
            }
        }

        if( TmpPrey.Length != 0 )
            StorageObj.Prey[ TeamID ] = TmpPrey[ Rand(TmpPrey.Length) ];
        else
            StorageObj.Prey[ TeamID ] = none;
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

    FindMyBinome();

    if( DBugBot ) log(" > Leader ="@Leader);


	while( true )
   {
        FindPathToMyLeader();   //FRD findpathtomyleader peut mettre le leader a none si pas de chemin

        if( Leader == none || Leader.bIsDEad ) //FRD because find
        {
            log("[ BOT"@ID@"] ABORD GROUPING");
            goto('TakeGodPrey');
        }

        ActorPathStorage( Leader );

        if( ( Leader.bIsDead ) || ( Leader == none ) )
        {
            RepeatGrouping++;

            if( RepeatGrouping > 2 )
                goto('TakeGodPrey');
            else
                goto('begin');
        }

        if( TeamId == 0 ) Log("Grouping");

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            if( ( Leader.bIsDead ) || ( Leader == none ) )
            {
                RepeatGrouping++;

                if( RepeatGrouping > 2 )
                    goto('TakeGodPrey');
                else
                    goto('begin');
            }

            Pawn.ShouldCrouch( false );
            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            MoveToward( MoveTarget, Focus , MoveSpeed );
        }
    }

    goto('TakeGodPrey');


TakeGodPrey:

    FindRandomTeamPrey();

    if( StorageObj.Prey[ TeamID ] != none )
    {
        if( ! FindOrder( Order_Seek ) )
        {
            Enemy = StorageObj.Prey[ TeamID ];
            AddOrder(70,Order_Seek,"Seek",Order_Grouping);
        }
    }

    RemoveOrder( Order_Grouping );
}

//__________________________________________________________________
//__________________________________________________________________
//                            Dead
//__________________________________________________________________
//__________________________________________________________________
/*state Dead
{
 	event BeginState()
   {
       super.BeginState();
	}
} */

//__________________________________________________________________
//__________________________________________________________________
//                            Kill
//__________________________________________________________________
//__________________________________________________________________

state Kill
{
    event BeginState()
    {
        if( ( Rand( 100 ) < 50 ) && ( FindOrder( Order_Grouping ) ) )
            RemoveOrder( Order_Grouping );

        TryToHelpMe();

        super.BeginState();
    }

    //--------------------------------------------------------------
}

//__________________________________________________________________
//__________________________________________________________________
//                            UnBump
//__________________________________________________________________
//__________________________________________________________________

state UnBump
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> UnBump");
        }

        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );


        if( NavigationPoint( MoveTarget ) != none )
        {
            NavToUpDate = NavigationPoint( MoveTarget );
            NavToUpDate.bSpecialCost=true;
        }
        else
            NavToUpDate = none;
    }

    //--------------------------------------------------------------

    event MayFall()
    {
        StopMvtWhenMayFall();
        Pawn.velocity=vect(0,0,0);
        Pawn.acceleration=vect(0,0,0);
    }

    //--------------------------------------------------------------

    event bool NotifyBump(Actor Other);

    //--------------------------------------------------------------

Begin:

    UnBlockPos1 = Pawn.Location + ( vector(pawn.rotation) cross (vect(0,0,1)) )*300;
    UnBlockPos2 = Pawn.Location + ( vector(pawn.rotation) cross (vect(0,0,1)) )*300 + vector(pawn.rotation)*400;

    Pawn.velocity=vect(0,0,0);
    Pawn.acceleration=vect(0,0,0);

    sleep(FRand());

UnBlockPahse1:

    focus = none;
    focalpoint = UnBlockPos1;
    MoveTo( UnBlockPos1 );

UnBlockPahse2:

    focus = none;
    focalpoint = UnBlockPos2;
    MoveTo( UnBlockPos2 );

    Pawn.velocity=vect(0,0,0);
    Pawn.acceleration=vect(0,0,0);

    RemoveOrder(Order_UnBump);
}

//__________________________________________________________________



defaultproperties
{
     LastBumpingTime=-1.000000
}
