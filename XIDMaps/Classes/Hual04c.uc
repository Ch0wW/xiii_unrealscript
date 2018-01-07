//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Hual04c extends Map06_HualparBase;

VAR(Hual04Setup) float CheckDistance;
VAR(Hual04Setup) float WarningInterval;
VAR(Hual04Setup) Pawn Carrington;
//VAR(Hual04Setup) Sound WarningSentences[5];
VAR(Hual04Setup) float CheckInterval;
VAR(Hual04Setup) int LethalWarning;
VAR(Hual04Setup) DialogueManager WarningDialMan;
VAR(Hual04Setup) name CarringtonDeathEvent;
VAR(Hual04Setup) float CarringtonDeathMessageDelay;

VAR int WarningCount;

// 0 - Rejoindre Jones à l'helico
// 1 - Ne pas s'éloigner de Carrington
// 2 - Ralentir les ennemis pe

//_____________________________________________________________________________

function SetGoalComplete(int N)
{
	LOG("HUAL04C SetGoalComplete"@N);

	if ( N < Objectif.Length )
		Super.SetGoalComplete(N);

	if ( N == 99 )
	{
		SetPrimaryGoal(1);
		GotoState('CheckPlayerDistance');
	}
	else if ( N == 0 )
	{
		SetPrimaryGoal( 2 );
		GotoState('');
	}
	else if ( N == 2 )
		SetPrimaryGoal(3);
	else if ( N == 3 )
		SetPrimaryGoal(4);
}

//_____________________________________________________________________________

function FirstFrame()
{
    Super.FirstFrame();
	Level.SetInjuredEffect( false, 0.01 );
	
}
/*
EVENT Trigger(actor a,pawn p)
{
	GotoState('CheckPlayerDistance');
}
*/
//_____________________________________________________________________________

STATE CheckPlayerDistance
{
	EVENT BeginState( )
	{
		SetTimer( CheckInterval, true );
	}
	EVENT Timer( )
	{
		LOCAL Vector v;
		v.X = XIIIPawn.Location.X - Carrington.Location.X;
		v.Y = XIIIPawn.Location.Y - Carrington.Location.Y;
		v.Z = 0;
		if ( vSize( v ) > CheckDistance )
		{
			if (WarningDialMan.IsInState('STA_PlayingDialogue'))
				WarningDialMan.ForceLine( WarningCount );
			else
				WarningDialMan.StartDialogue( );

//			WarningDialMan.Trigger(self,none);
			WarningCount++;
			if ( WarningCount==LethalWarning )
			{
				TriggerEvent( CarringtonDeathEvent, none, none );
//				Level.Game.EndGame( XIIIPlayercontroller(EventInstigator.controller).PlayerReplicationInfo, "GoalIncomplete");//GoalIncomplete" );
				GotoState('TheEnd');
				return;
			}
			else
				GotoState('CheckPlayerPause');
		}
		else
		{
			WarningCount = 0;
		}

	}
}

STATE TheEnd
{
	EVENT BeginState( )
	{
//		XIIIController.GotoState('NoControl');
		Carrington.Controller.GotoState('');
		Carrington.PlayAnim('DeathTete',,0.1);
		SetTimer( CarringtonDeathMessageDelay, false );
		if ( CarringtonDeathMessageDelay==0 )
			Timer();
	}
	EVENT Timer( )
	{
		SetGoalComplete( 1 );
	}
}

STATE CheckPlayerPause
{
begin:
	Sleep( WarningInterval );
	GotoState('CheckPlayerDistance');
}



defaultproperties
{
     CheckDistance=2500.000000
     WarningInterval=5.000000
     CheckInterval=1.000000
     LethalWarning=3
     CarringtonDeathMessageDelay=3.000000
     EndMapVideo="cine06"
}
