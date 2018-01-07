//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Sanc02b extends Map15_Sanctuaire;

// 0 - Espionner ce qui est dit pendant l'Assemblée. L'assemblée sera annulée si l'alerte est donnée
// 1 - ANTIGOAL : XIII s'est fait remarqué et a interrompu la reunion avant d'avoir pu obtenir tout les renseignements necessaires.
// 2 - S'echapper du sanctuaire
// 3 - ANTIGOAL : L'alerte a ete donnée. La reunion est annulée.


FUNCTION SomeoneShoots( Pawn Shooter )
{
}

STATE STA_NoShootAllowed
{
	EVENT BeginState( )
	{
		LOCAL Mutator m;

		m = spawn(class'Sanc02bMutator');
		m.NextMutator = Level.Game.BaseMutator.NextMutator;
		Level.Game.BaseMutator = m;
		LOG( "BEGINSTATE STA_NoShootAllowed"@m );
	}

	EVENT EndState( )
	{
		LOCAL Mutator m;

//		m = Level.Game.BaseMutator;
//		Level.Game.BaseMutator = m.NextMutator;
//		m.Destroy( );
		LOG( "ENDSTATE STA_NoShootAllowed"@m );
	}

	FUNCTION SomeoneShoots( Pawn Shooter )
	{
//		Log(Shooter@"SHOOTS");
//		if ( Shooter!=none /*&& Shooter.IsPlayerPawn()*/ )
			SetGoalComplete( 1 );
	}
}

//_____________________________________________________________________________
FUNCTION SetGoalComplete(int N)
{
	SUPER.SetGoalComplete(N);

	switch ( N )
	{
	case 0:
		GotoState( '' );
		SetSecondaryGoal(1);
		SetPrimaryGoal(2);
		break;
	case 513:
		GotoState( 'STA_NoShootAllowed' );
		break;
	}
}



defaultproperties
{
}
