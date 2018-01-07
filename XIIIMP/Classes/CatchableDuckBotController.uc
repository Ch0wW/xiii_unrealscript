//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CatchableDuckBotController extends BotController;

const Order_CatchTheDuck       = 131072;
const Order_Hunted             = 262144;
const Order_SeekDuckCarrier    = 524288;

var bool SeekAndFire;

//__________________________________________________________________

function GetTheDuck()
{
    if( !FindOrder( Order_Hunted ) )
    {
        AddOrder( 75, Order_Hunted,"Hunted",Order_CatchTheDuck);

        if( FindOrder( Order_Life ) )
            RemoveOrder( Order_Life );

        if( FindOrder( Order_Armor ) )
            RemoveOrder( Order_Armor );

        if( FindOrder( Order_Weapon ) )
            RemoveOrder( Order_Weapon );

        if( FindOrder( Order_Seek ) )
            RemoveOrder( Order_Seek );
    }
}

//__________________________________________________________________

event SeeMonster( Pawn Seen )
{
    log("see monster");

    if( FindOrder( Order_CatchTheDuck ) )
        ModifyOrder( Order_CatchTheDuck , 74 );
}

//__________________________________________________________________

event SeePlayer( Pawn Seen )
{
    if( XIIIMPDuckGameInfo(Level.Game).WhoHasTheDuck == Seen )
    {
        if( FindOrder( Order_SeekDuckCarrier ) )
            ModifyOrder( Order_SeekDuckCarrier , 75 );
    }
    else
    {
        super.SeePlayer( Seen );
    }
}

//__________________________________________________________________

event ChangeState()
{
    switch( CurrentOrder.TypeId )
    {
        case Order_Kill : GotoState( 'Kill' ); break;
        case Order_Life : GotoState( 'Life' ); break;
        case Order_Armor : GotoState( 'Armor' ); break;
        case Order_Weapon : GotoState( 'Weapon' ); break;
        case Order_Seek : GotoState( 'Seek' ); break;
        case Order_Fear : gotoState( 'Fear' ); break;
        case Order_UnBlock : gotoState( 'UnBlock' ); break;
        case Order_CatchTheDuck : gotoState( 'CatchTheDuck' ); break;
        case Order_SeekDuckCarrier : gotoState( 'SeekDuckCarrier' ); break;
        case Order_Hunted : gotoState( 'Hunted' ); break;
    }
}

//__________________________________________________________________

function InitPickUpList()
{
    local PickUp A;

    bInitPickUpList = true;
    MarioMode = false;

    foreach DynamicActors(class'PickUp', A)
    {
        FullPickUpList.Length = FullPickUpList.Length+1;
        FullPickUpList[ FullPickUpList.Length-1 ] = A;

        if ( MultiPlayerMedPickUp(A) != none )
        {
            MedKitList.Length = MedKitList.Length+1;
            MedKitList[ MedKitList.Length-1 ] = MultiPlayerMedPickUp(A);
        }
        else if( XIIIAmmoPick(A) != none )
        {
            WeaponList.Length = WeaponList.Length+1;
            WeaponList[ WeaponList.Length-1 ] = XIIIAmmoPick(A);
        }
        else if( XIIIArmorPickUp(A) != none )
        {
            ArmorList.Length = ArmorList.Length+1;
            ArmorList[ ArmorList.Length-1 ] = XIIIArmorPickUp(A);
        }
    }

    if( DBugBot )
    {
        Log("");
        Log("[ BOT"@ID@"] : PickUpList Construction");
        log("    > MedKit="$MedKitList.Length);
        log("    > Armor="$ArmorList.Length);
        log("    > Ammo="$WeaponList.Length);
        log("    > FullPickUpList="$FullPickUpList.Length);
    }
}

//__________________________________________________________________

function int GetLifePriority()
{
    if( XIIIMPDuckGameInfo(Level.Game).WhoHasTheDuck == Pawn )
        return 0;
    else
        super.GetLifePriority();
}

//__________________________________________________________________

event AddDefaultOrders()
{
    if( ( Level.TimeSeconds - LastDefaultOrderTime < 3.0 ) && ( LastDefaultOrderTime != 0) )
    {
		 if( ( DBugBot ) || ( DBugWarning ) )
			Log("[ WARNING ][ ORDER ][ BOT"@ID@"] : Runaway Loop !...");

        AddOrder(79,Order_UnBlock,"UnBlock",0);
    }
    else
    {
        if( ! PathErrorToAllLife )
            AddOrder(GetLifePriority(),Order_Life,"Life",0);

        if( ! PathErrorToAllArmor )
            AddOrder(60,Order_Armor,"Armor",0);

        if( ! PathErrorToAllWeapon )
            AddOrder(50,Order_Weapon,"Weapon",0);

        if( XIIIMPDuckGameInfo(Level.Game).WhoHasTheDuck != none )
            AddOrder(45,Order_SeekDuckCarrier,"SeekDuckCarrier",0);

        AddOrder(40,Order_CatchTheDuck,"CatchTheDuck",0);
    }

    LastDefaultOrderTime = Level.TimeSeconds;
}

//__________________________________________________________________
//__________________________________________________________________
//                            CatchTheDuck
//__________________________________________________________________
//__________________________________________________________________

state CatchTheDuck
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> CatchTheDuck");
        }

        if( XIIIMPDuckGameInfo(Level.Game).WhoHasTheDuck != none )
        {
            ModifyOrder( Order_CatchTheDuck , 40 ); //Security if Priority = 75
        }

        Enemy = XIIIMPDuckGameInfo(Level.Game).TheDuck;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );

        SetTimer3(1.0,true);
    }

    event EndState()
    {
        SetTimer3(0.0,False);
    }

    event Timer3()
    {
        CheckDuckState();
    }

    event SeePlayer( Pawn Seen )
    {
        if( ( ( VSize( Seen.Location - Pawn.Location ) < 500 ) || ( Rand( 100 ) > skill*30 ) ) && ( PathIndex < PathCacheSize - 1 ) )
            global.SeePlayer( Seen );
    }

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( Agressor == Pawn )
            return;

        if( PathIndex < PathCacheSize - 1 )
            global.SomeoneWantKillMe( Agressor );
    }

    function CheckDuckState()
    {
        if( XIIIMPDuckGameInfo(Level.Game).WhoHasTheDuck != none )
        {
            if( XIIIMPDuckGameInfo(Level.Game).WhoHasTheDuck != Pawn )
            {
                AddOrder(45,Order_SeekDuckCarrier,"SeekDuckCarrier",0);
                ModifyOrder( Order_CatchTheDuck , 40 ); //Security if Priority = 75
            }
        }
    }

Begin:

    while(true)
    {
        ActorPathStorage( Enemy );

        if( MoveTarget == none )
            RemoveOrder( Order_CatchTheDuck );
        else
        {
            for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
            {
                MoveTarget = PathCache[ PathIndex ];
                Focus=MoveTarget;

                MoveToward( MoveTarget, Focus , MoveSpeed );
            }

            if( Rand( 100 ) < 30 + skill*15 )
                RemoveOrder( Order_CatchTheDuck );
        }
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            Hunted
//__________________________________________________________________
//__________________________________________________________________

state Hunted
{
    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> Hunted");
        }

        Enemy = none;
        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );

        if( ! Pawn.Weapon.HasAmmo() )
            SwitchWeapon();
        else
            Pawn.Weapon.ForceReload();
    }

    event SeePlayer( Pawn Seen )
    {
        if( VSize( Seen.Location - Pawn.Location ) < 200 )
            SomeoneWantKillMe( Seen );
    }

    function SomeoneWantKillMe( Pawn Agressor )
    {
        if( Agressor == Pawn )
            return;

        if( ( !FindOrder( Order_Kill ) ) && ( VSize( Agressor.Location - Pawn.Location ) < 600 ) )
        {
            Enemy = Agressor;
            AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
        }
    }

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

Begin:

    GetRandomLocation();

    while( true )
    {
        PickUpPathStorage(Item);

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            if( ! CheckPath() )
                Goto('begin');

            MoveToward( MoveTarget, Focus , MoveSpeed );
        }

        if( FullPath )
            goto('begin');
    }
}

//__________________________________________________________________
//__________________________________________________________________
//                            SeekDuckCarrier
//__________________________________________________________________
//__________________________________________________________________

state SeekDuckCarrier
{
    event EndState()
    {
        bFire=0;
        SetTimer(0.0,false);
        SetTimer2(0.0,false);
        SetTimer3(0.0,false);
        SeekAndFire=false;
    }

    event BeginState()
    {
        if( DBugBot )
        {
            Log("");
            Log("[ BOT"@ID@"] : *STATE* ---> SeekDuckCarrier");

        }

        Pawn.ControllerPitch = 0;

        Pawn.ShouldCrouch( false );

        Enemy = XIIIMPDuckGameInfo(Level.Game).WhoHasTheDuck;

        SetTimer3(1.0,true);
    }

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

    event Timer3()
    {
        CheckDuckState();
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

        if( ( Agressor == Enemy ) || ( VSize( Agressor.Location - Pawn.Location ) < 500 ) )
        {
            Enemy = Agressor;
            AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
        }
    }

    event SeePlayer( Pawn Seen )
    {
        if( Seen == Enemy )
        {
            if( IsShootable( Seen ) )
            {
                if( VSize( Seen.Location - Pawn.Location ) > 300 )
                {
                    if( ! SeekAndFire )
                    {
                        SeekAndFire=true;
                        SetTimer( (4-Skill)*0.2+FRand()/2 ,False );
                    }
                }
                else
                    AddOrder(KillOrderPriority,Order_Kill,"Kill",Order_Seek);
            }
        }
        else if( ( VSize( Seen.Location - Pawn.Location ) < 400 ) && ( Rand( 100 ) < 90 - Skill*20 ) )
        {
            if( IsShootable(Seen) )
            {
                Enemy = Seen;
                AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
            }
        }
    }

    event EnemyNotVisible()
    {
        if( SeekAndFire )
        {
            SeekAndFire=false;
            SetTimer(0.0,false);
            SetTimer2(0.0,false);
            Pawn.Weapon.ForceReload();
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

        if( Path == none )
            Path = FindPathToward(Enemy);

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

    function CheckDuckState()
    {
        if( XIIIMPDuckGameInfo(Level.Game).WhoHasTheDuck == none )
            RemoveOrder(Order_SeekDuckCarrier);
    }

Begin:

    FindPathToMyEnemy();

    if( Enemy == none )
        RemoveOrder( Order_SeekDuckCarrier );

    while( true )
    {
        ActorPathStorage( Enemy);

        if( MoveTarget == none )
            RemoveOrder( Order_SeekDuckCarrier );

        for( PathIndex = 0; PathIndex < PathCacheSize ; PathIndex ++ )
        {
            MoveTarget = PathCache[ PathIndex ];
            Focus=MoveTarget;

            MoveToward( MoveTarget, Focus , MoveSpeed );
        }

        if( ( Rand( 100 ) < 60 + skill*10 ) && ( ! IsShootable( Enemy ) ) )
            RemoveOrder( Order_SeekDuckCarrier );
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
        if( Pawn.bIsCrouched )
            Pawn.ShouldCrouch( false );

        RemoveOrder( Order_Kill );
    }
}

//__________________________________________________________________



defaultproperties
{
}
