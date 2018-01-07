//-----------------------------------------------------------
// Trigger to display CWnd on screen
//-----------------------------------------------------------
class CWndBackShotTrigger extends CWndSFXTrigger;


var(CWndSFXTrigger) actor EnemyInTheBack;

var XIIIPlayerController XPC;


//____________________________________________________________________
function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	Disable( 'Trigger' );
	SetTimer2(0.1,false);
}

//____________________________________________________________________
event Timer2()
{
	XPC = XIIIGameInfo(Level.Game).MapInfo.XIIIController;

	// cas d'un ennemi qui shoote le joueur dans le dos
	if (( EnemyInTheBack.IsA('BaseSoldier') ) || ( EnemyInTheBack.IsA('GenNMI') ))
	{
		if ( EnemyInTheBack.IsA('GenNMI') )
		{
			EnemyInTheBack = GenNMI(EnemyInTheBack).SpawnActor;
		}
		GotoState('STA_BackShotSFXTrigger');
	}
}

//____________________________________________________________________
State STA_BackShotSFXTrigger
{
	event Tick( float dt )
	{
		if (( EnemyInTheBack == none ) || ( BaseSoldier(EnemyInTheBack).bIsDead ))
			Destroy();
		else
		{
			if ( IAController(BaseSoldier(EnemyInTheBack).Controller).bTire )
			{
				if ( !XPC.CanSee(BaseSoldier(EnemyInTheBack)) )
				{
					if ( (Level.Game != none) && (Level.Game.DetailLevel < 2) )
						bAnimatedInRealTime = false;
					iPhase = -1;
					SetTimer(0.25,false);
					TriggerEvent( Event, Self, Instigator );
					GotoState('');
				}
				else
					Destroy();
			}
		}
	}
}



defaultproperties
{
}
