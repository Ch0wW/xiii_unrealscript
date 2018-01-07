//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DuckBotController extends BotController;

var bool SeekAndFire;

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

        if( ! PathErrorToAllWeapon )
            AddOrder(50,Order_Weapon,"Weapon",0);

        if( ! PathErrorToAllArmor )
            AddOrder(30,Order_Armor,"Armor",0);
    }

    LastDefaultOrderTime = Level.TimeSeconds;
}

//__________________________________________________________________

event bool NotifyBump(Actor Other)
{
    if( Pawn( Other ) != none )
    {
        super.SeePlayer( Pawn(Other) );
    }
}

//__________________________________________________________________

event SeeMonster( Pawn Seen )
{
    SeePlayer( Seen );
}

//__________________________________________________________________

event SeePlayer( Pawn Seen )
{
    if( TheDuck(Seen) != none )
    {
        if( Enemy == none )
        {
            Enemy = Seen;

            if( IsShootable( Seen ) )
                AddOrder(KillOrderPriority,Order_Kill,"Kill",0);
            else
                AddOrder(70,Order_Seek,"Seek",0);
        }
        else
        {
            Enemy = Seen;
        }
    }
//    else if ( IsInAttackArea( Seen ) )
//        super.SeePlayer( Seen );
}

//__________________________________________________________________

function bool MissTheShoot()
{
    if( Rand( 100 ) < (3.5-Skill)*MissPercent )
        return true;
    else
        return false;
}

//__________________________________________________________________

function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	local rotator RotatorError;

	if( Enemy == none )
    	return ( Rotation );

    if((  Level.TimeSeconds - ShotErrorTime < 0 ) || ( MissTheShoot() ) )
    {
        if( Rand( 2 ) == 1 )
            RotatorError.Yaw = InitialShotError;
        else
            RotatorError.Yaw = 65535-InitialShotError;


        if( TheDuck(Enemy ) != none )
            SetRotation( rotator(Enemy.Location-(Pawn.Location+Pawn.EyePosition()) ) );
        else
            SetRotation( rotator(Enemy.GetBoneCoords('X Spine1').Origin-(Pawn.Location+Pawn.EyePosition()) ) );

        Pawn.ControllerPitch = Rotation.Pitch / 256;
    }
    else
    {
        if( Rand( 100 ) < (Skill+1)*10 + HeadShotModificator )
        {
            if( TheDuck(Enemy ) != none )
                SetRotation( rotator(Enemy.Location-(Pawn.Location+Pawn.EyePosition()) ) );
            else
                SetRotation( rotator(Enemy.GetBoneCoords('X Head').Origin-(Pawn.Location+Pawn.EyePosition()) ) );

            Pawn.ControllerPitch = Rotation.Pitch / 256;
        }
        else
        {
            if( TheDuck(Enemy ) != none )
                SetRotation( rotator(Enemy.Location-(Pawn.Location+Pawn.EyePosition()) ) );
            else
                SetRotation( rotator(Enemy.GetBoneCoords('X Spine1').Origin-(Pawn.Location+Pawn.EyePosition()) ) );

            Pawn.ControllerPitch = Rotation.Pitch / 256;
        }
    }

    return ( Rotation + RotatorError );
}

//__________________________________________________________________
//__________________________________________________________________
//                            Kill
//__________________________________________________________________
//__________________________________________________________________

state Kill
{
    event SeeMonster( Pawn Seen )
    {
        SeePlayer( Seen );
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

        if( ( TheDuck(Seen) != none ) && ( Rand( 100 ) < 70 + Skill*10 ) )
        {
            Enemy = Seen;
        }
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

        if( TheDuck(Enemy) != none )
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
}

//__________________________________________________________________
//__________________________________________________________________
//                            Seek
//__________________________________________________________________
//__________________________________________________________________

state Seek
{
    event EndState()
    {
        bFire=0;
        SetTimer(0.0,false);
        SetTimer2(0.0,false);
        SeekAndFire=false;
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
        if( Seen == Enemy )
        {
            if( TheDuck(Seen) != none )
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
            else if( IsShootable( Seen ) )
                AddOrder(KillOrderPriority,Order_Kill,"Kill",Order_Seek);
        }
        else if( ( IsNearest( Enemy,Seen) ) && ( TheDuck(Enemy) != none ) )
        {
            Enemy = Seen;

            if( IsShootable(Seen) )
                AddOrder(KillOrderPriority,Order_Kill,"Kill",Order_Seek);
            else
                FindPathToMyEnemy();
        }
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

}

//__________________________________________________________________



defaultproperties
{
}
