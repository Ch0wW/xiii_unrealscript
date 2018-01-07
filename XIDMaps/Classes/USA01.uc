//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Usa01 extends Map12_PortUSA;

var(Usa01SetUp) Usa01DecoBombe BombeDeco;
var(Usa01SetUp) float fBombDelay;
var(Usa01SetUp) float fTempsAvantCamera;
var(Usa01SetUp) float fTempsCamera;
var(Usa01SetUp) float fDelayBeforeEndGame;
var(Usa01SetUp) actor CibleExplosion;
var(Usa01SetUp) int eHauteurCamera;
var(Usa01SetUp) XIIIGoalTrigger BombInteraction;
var float fBombEventDelay, fHauteur, fTime;
var int eNbSeconds;
var bool bBombEventSent, bBombInPosition;
var chronometre Chrono;
var sound hBombReady;
var sound hCountDown;
var rotator rRotatorInit;
var vector vPosInit;
var name PrevState;

//_____________________________________________________________________________
event ParseDynamicLoading(LevelInfo MyLI)
{
    Log("ParseDynamicLoading Actor="$self);
    MyLI.ForcedClasses[MyLI.ForcedClasses.Length] = class'Usa01Bombe';
    class'Usa01Bombe'.Static.StaticParseDynamicLoading(MyLI);
    MyLI.ForcedClasses[MyLI.ForcedClasses.Length] = class'Chronometre';
    class'Chronometre'.Static.StaticParseDynamicLoading(MyLI);
    Super.ParseDynamicLoading(MyLI);
}

//_____________________________________________________________________________
function FirstFrame()
{
    local inventory Inv;

    Super.FirstFrame();

	// on regarde si le joueur possede deja une bombe
	Inv = XIIIPawn.FindInventoryKind( 'Usa01Bombe' );
	if ( Inv == none )
	{
		Inv = GiveSomething(class'Usa01Bombe', XIIIPawn);
	}
	Usa01Bombe(Inv).BombInteraction = BombInteraction;

	// on desactive le lieu de posage de bombe
	BombeDeco.bHidden = true;
	BombeDeco.RefreshDisplaying();
	BombInteraction.bInteractive = false;

}

//_____________________________________________________________________________
event Timer2()
{
    XIIIPawn.PlaySound(hCountDown);
    fBombEventDelay += 1.0;
    if ( !bBombEventSent && (fBombEventDelay > fBombDelay-2.5) )
    {
      bBombEventSent = true;
      TriggerEvent('BombNearExplo', none, none);
    }
	// prise en main de la camera au bout de x secondes
	eNbSeconds ++;
	if (eNbSeconds == (fBombDelay - fTempsAvantCamera))
	{
		PrevState = XIIIController.GetStateName();
		//SetTimer( 0, false );
		if ( XIIIController.bWeaponMode )
		{
			XIIIController.OldWeap = XIIIPawn.Weapon.InventoryGroup;
			XIIIPawn.Weapon.PutDown();
		}
		else
		{
			XIIIController.OldItem = XIIIItems(XIIIPawn.SelectedItem);
			XIIIController.OldItem.PutDown();
		}
		XIIIController.bWeaponBlock = true;
		rRotatorInit = XIIIController.Rotation;
		vPosInit = XIIIController.Pawn.Location;
		if ( !XIIIPawn.bIsDead && !Level.Game.bGameEnded)
		{
			XIIIController.GotoState('NoControl');
			GotoState('Waiting');
		}
	}
}

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
	local Usa01Bombe Bomb;

	switch (N)
	{
		//case 99: // bomb placed
		case 97:
				log(self@"---> DEMARRAGE CHRONO, BOMBE AMORCEE");
				BombeDeco.StaticMesh = StaticMesh'MeshArmesPickup.BombeMagnet';
				BombeDeco.RefreshDisplaying();
				Bomb = Usa01Bombe(XIIIPawn.FindInventoryType(class'Usa01Bombe'));
				if (Bomb != none )
					Bomb.UsedUp();
				// Give chrono
				TriggerEvent('GenPlong', self, XIIIPawn);
				Chrono = Chronometre(GiveSomething(class'Chronometre', XIIIPawn));
				XIIIPawn.PlaySound(hBombReady);
				if (Chrono != none)
					Chrono.ReSetTimer(fBombDelay);
				XIIIPawn.PlaySound(hCountDown);
				BombInteraction.bInteractive = false;
				SetTimer2(1.0, true);
			//}
			break;
		case 98: // Chrono over
			// if pawn underwater, mission failed because bomb damage player
			SetTimer2(0.0,false);
			BombeDeco.Destroy();
			if (Chrono != none)
				Chrono.Destroy();
			if ( XIIIPawn.PhysicsVolume.bWaterVolume )
			{
				GotoState('WaitForEndGame');
			}
			// else mission continue
			break;
		case 0:
			SetPrimaryGoal(1);
			BombeDeco.bHidden = false;
			BombeDeco.RefreshDisplaying();
			BombInteraction.bInteractive = true;
			break;
		case 1:
			SetPrimaryGoal(2);
			break;
	}

	Super.SetGoalcomplete(N);
}

State WaitForEndGame
{
	event Beginstate()
	{
		SetTimer(fDelayBeforeEndGame, false);
	}

	event Timer()
	{
		Level.Game.EndGame( XIIIController.PlayerReplicationInfo, "GoalIncomplete" );
	}
}

State Waiting
{
	event BeginState()
	{
		XIIIPawn.SetPhysics(PHYS_None);
	}

	event Tick(float dt)
	{
		local rotator r;
		local vector v;

		fTime += dt;
		if ( XIIIPawn.bIsDead || Level.Game.bGameEnded )
		{
			SetTimer2(0.0,false);

/*			if ( !bBombEventSent )
			{
			  bBombEventSent = true;
			  TriggerEvent('BombNearExplo', none, none);
			}*/

			GotoState( '' );
		}

		if (fTime < fTempsCamera)
		{
			r = rotator(CibleExplosion.location - XIIIController.location);
			r -= XIIIController.Rotation;
			r.Yaw= ((r.Yaw+32768)&65535)-32768;
			r.Roll= ((r.Roll+32768)&65535)-32768;
			r.Pitch= ((r.Pitch+32768)&65535)-32768;

			XIIIController.SetRotation(r*0.03+XIIIController.Rotation);

			fHauteur += 50*dt;
			fHauteur = fMin(fHauteur,eHauteurCamera);
			XIIIPawn.SetLocation( vPosInit + fHauteur*vect(0,0,1));
		}
		else
		{
			fHauteur -= 50*dt;
			fHauteur = fMax(fHauteur,0);
			XIIIPawn.SetLocation( vPosInit + fHauteur*vect(0,0,1));
			if (fHauteur == 0)
			{
				XIIIController.GotoState(PrevState);
				XIIIController.bWeaponBlock = false;
				if ( XIIIController.bWeaponMode )
				{
					XIIIController.Switchweapon( XIIIController.OldWeap );
					XIIIPawn.ChangedWeapon();
				}
				else
				{
					if ( XIIIController.OldItem != none )
					{
						XIIIController.cNextItem();
						XIIIPawn.PendingItem = XIIIController.OldItem;
					}
					else
					{
						XIIIController.bWaitForWeaponMode = true;
						XIIIController.bWeaponMode = true;
						XIIIController.Switchweapon( 0 );
					}
					XIIIPawn.ChangedWeapon();
				}
				GotoState('');
			}
		}
	}
}




defaultproperties
{
     fBombDelay=40.000000
     fTempsAvantCamera=3.000000
     fTempsCamera=9.000000
     fDelayBeforeEndGame=7.000000
     eHauteurCamera=150
     hBombReady=Sound'XIIIsound.Items__BombFireSub.BombFireSub__hBombFire'
     hCountDown=Sound'XIIIsound.Interface__USA01_CountDown.USA01_CountDown__hPlayCounter'
     iLoadSpecificValue=142
}
