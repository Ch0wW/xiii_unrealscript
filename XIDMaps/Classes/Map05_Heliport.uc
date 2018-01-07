//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Map05_Heliport extends MapInfo placeable;

VAR				bool bInformed;
VAR				Pawn PolicemenStack[4];
VAR				float TimeStack[4];
VAR				float TimeStamp;
VAR TRANSIENT	int StackPointer;
VAR()			float TriggerDelay;

//_____________________________________________________________________________
EVENT Trigger( Actor Other, Pawn EventInstigator )
{
	LOCAL int i;

// record who had seen XIII and when
	for (i=0;i<4;++i)
		if (PolicemenStack[i]==none)
		{
			PolicemenStack[i]=EventInstigator;
			TimeStack[i]=TimeStamp;
		}
	if (GetStateName()!='STA_isWarned')
		GotoState('STA_isWarned');
}

FUNCTION SetGoalComplete(int N)
{
	if ( N==0 )
		SetPrimaryGoal(3);

		super.SetGoalComplete(N);
}

EVENT Tick(float dt)
{
	TimeStamp+=dt;
}

STATE STA_isWarned
{
	EVENT Tick(float dt)
	{
		LOCAL int i;
//		LOCAL bool bNoPolicemenInList;

//		bNoPolicemenInList=true;

		TimeStamp+=dt;
		for (i=0;i<4;++i)
		{
			if (PolicemenStack[i]!=none)
				if (PolicemenStack[i].bisdead)
					PolicemenStack[i]=none;
				else
				{
//				bNoPolicemenInList=false;
					if (TimeStamp-TimeStack[i]>TriggerDelay)
						TriggerEvent(event,none,none);
				}

		}
//		if (bNoPolicemenInList)
//		{
//			GotoState('');
//		}

	}
}



defaultproperties
{
     TriggerDelay=4.000000
     EndMapVideo="cine03"
     Tag="XIIIVu"
     Event="Goal02"
}
