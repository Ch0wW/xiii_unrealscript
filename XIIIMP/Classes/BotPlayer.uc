//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BotPlayer extends XIIIMPPlayerPawn;

//_____________________________________________________________________________
// ELR to heal
function Heal(int H)
{
    Local int i;

//    log("Heal called w/ ammount="$H);
    Health = Min(Default.Health, Health+H);
//    PlaySound(hHealSound); // NO PLAYSOUND FOR BOTS
//    CheckMaluses(); // no need in this now that we don't have any negative fx for low health
}

event GainedChild( Actor Other )
{
    if( ( XIIIAmmo( Other ) != none ) || ( XIIIWeapon( Other ) != none ) )
    {
        BotController(Controller).SwitchWeapon();
    }
}

//_____________________________________________________________________________
event FellOutOfWorld()
{
	if ( Role < ROLE_Authority )
		return;
	Health = -1;
	SetPhysics(PHYS_None);
	Weapon = None;
	Died(None, class'Gibbed', Location);
}

//_____________________________________________________________________________
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

    if( ( Controller == none ) || ( instigatedBy == none ) )
        return;

    if( Controller.bIsBot )
        BotController( Controller ).SomeoneWantKillMe( instigatedBy );
}

//_____________________________________________________________________________
event Landed(vector HitNormal)
{
    BotController(controller).bIsJumping = false;

    super.Landed(HitNormal);
}

//__________________________________________________________________

event Touch( Actor Other )
{
    local NavigationPoint NavPoint, TmpNext, TmpNext2;

    if( JumpPathNode(Other) != none )
    {
        if ( Physics != PHYS_Falling )
        {
            TmpNext = NavigationPoint(BotController( Controller ).PathCache[ BotController( Controller ).PathIndex ]);

            if( BotController( Controller ).PathIndex +1 < BotController( Controller ).PathCacheSize )
                TmpNext2 = NavigationPoint(BotController( Controller ).PathCache[ BotController( Controller ).PathIndex +1 ]);

            if( ( JumpPathNode(Other).JumpTarget == TmpNext ) || ( JumpPathNode(Other).JumpTarget == TmpNext2 ) )
                BotController(controller).InitBotJump( JumpPathNode(Other).V, JumpPathNode(Other).H, JumpPathNode(Other).JumpTarget );
        }
    }
    else if( CrouchPathNode(Other) != none )
        ShouldCrouch( true );
    else if( GrenadPathNode(Other) != none )
        BotController(controller).GrenadPossibility( GrenadPathNode(Other) );
}

//__________________________________________________________________

simulated function AnimateRunning()
{
    super.AnimateRunning();

    MovementAnims[1] = 'StrafeG';
    MovementAnims[3] = 'StrafeD';
}



defaultproperties
{
     bUpdateEyeheight=True
     bSameZoneHearing=False
     bAdjacentZoneHearing=False
     bMuffledHearing=False
     SightRadius=2500.000000
     ControllerClass=Class'XIIIMP.BotController'
}
