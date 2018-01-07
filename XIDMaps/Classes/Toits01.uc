//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Toits01 extends Map04_Toits;

VAR() HookPoint HookPointToActive;
VAR bool bHookPointActivated;

FUNCTION FirstFrame()
{
	if ( HookPointToActive!=none )
	{
		HookPointToActive.bInteractive=false;
	}
	Super.FirstFrame();
}

//_____________________________________________________________________________
FUNCTION SetGoalComplete(int N)
{
	switch ( N )
	{
	case 91:
		SetPrimaryGoal(1);
		break;
	case 92:
		SetPrimaryGoal(2);
		break;
	case 99:
		if ( !bHookPointActivated )
		{
			bHookPointActivated = true;

			if ( HookPointToActive!=none )
			{
				HookPointToActive.bInteractive=true;
			}
		}


		
	}
	Super.SetGoalComplete(N);
}

//_____________________________________________________________________________




defaultproperties
{
}
