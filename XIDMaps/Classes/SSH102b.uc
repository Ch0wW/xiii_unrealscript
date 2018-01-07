//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SSH102b extends Map16_SSH1;

VAR(SSH102bSetUp) float Goal0ChronoTime;
VAR(SSH102bSetUp) Mover DoorToOpen;
VAR float OldDoorMoveTime;
VAR chronometre Chrono;


//_____________________________________________________________________________
FUNCTION FirstFrame()
{
	Super.FirstFrame();
	
	Tag = 'DialogueHP';
	
	if ( DoorToOpen!=none )
	{
		OldDoorMoveTime = DoorToOpen.MoveTime;
		DoorToOpen.MoveTime=0.1;
		DoorToOpen.Trigger(none,none);
		SetTimer2( 0.1, false );
	}
}


//_____________________________________________________________________________
EVENT Trigger(actor Other, pawn EventInstigator)
{
	LOCAL inventory inv;
	
	if ( !Objectif[0].bCompleted )
	{
		inv = GiveSomething(class'Chronometre', XIIIPawn);
		Chrono = Chronometre(inv);
		if (Chrono != none)
			Chrono.ReSetTimer(Goal0ChronoTime+0.9);
	}
}

//_____________________________________________________________________________
EVENT Timer2( )
{
	DoorToOpen.MoveTime = OldDoorMoveTime;
}


//_____________________________________________________________________________
FUNCTION SetGoalComplete(int N)
{
    LOCAL chronometre C;
	
    if (N == 99)
    { // Chrono ended... too bad GameOver.
		Level.Game.EndGame( XIIIController.PlayerReplicationInfo, "GoalIncomplete" );
		return;
    }
	
    Super.SetGoalComplete(N);
	
    if (N == 0)
    {
		if (Chrono != none)
			Chrono.Destroy();
		SetPrimaryGoal(1);
    }
}


//_____________________________________________________________________________


defaultproperties
{
     Goal0ChronoTime=30.000000
     EndMapVideo="cine15"
}
