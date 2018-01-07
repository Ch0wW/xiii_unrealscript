//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// AlarmFilter Created by iKi
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
class AlarmFilter extends Info placeable;

VAR(Filter)	bool	bInitiallyOn;
VAR(Filter)	Array<Color>	Colors;
VAR			Color	NeutralColor;
VAR(Filter)	Array<float>	SpeedToReachColor;
VAR(Filter)	Array<float>	PauseTimeOnColor;

VAR TRANSIENT	int CurrentIndex;
VAR	TRANSIENT	XIIIPlayerController	PC;

AUTO STATE STA_init
{
begin:
	sleep(0.2);
	if (Colors.Length==0)
	{
		destroy();
		stop;
	}
	do
	{
		sleep(0.1);
		PC=XIIIGameInfo(Level.Game).MapInfo.XIIIController;
//		LOG("----------------------------------"@GetStateName());
	} until (PC!=none);
//		if (PC==none) goto ('toto');
	if (bInitiallyOn)
		TurnFilterOn();
	else
		TurnFilterOff();
	stop;
}

FUNCTION TurnFilterOff()
{
	PC.FilterColorWanted=NeutralColor;
	PC.FilterColorSpeed=0.5;
	GotoState('STA_FilterOff');
}

FUNCTION TurnFilterOn()
{
	CurrentIndex=0;
	UseCurrentColor();
	TriggerEvent( event, none, none );
	GotoState('STA_FilterOn');
}

FUNCTION UseCurrentColor()
{
	if ( CurrentIndex >= Colors.Length )
	{
		CurrentIndex=0;
		TriggerEvent( event, none, none );
	}
//	log("UseCurrentColor"@CurrentIndex);
	PC.FilterColorWanted=Colors[CurrentIndex];
	if (CurrentIndex<SpeedToReachColor.Length)
		PC.FilterColorSpeed=SpeedToReachColor[CurrentIndex];
	else
		PC.FilterColorSpeed=1.0;
}

STATE STA_FilterOff
{
	EVENT Trigger(Actor a,Pawn p)
	{
		TurnFilterOn();
	}
}

STATE STA_FilterOn
{
	EVENT Tick(float dt)
	{
		if (PC.FilterColorWanted==PC.FilterColor)
		{
			if ((CurrentIndex<PauseTimeOnColor.Length) && (PauseTimeOnColor[CurrentIndex]!=0.0))
			{
				Disable ('Tick');
				SetTimer(PauseTimeOnColor[CurrentIndex],false);
			}
			else
			{
				CurrentIndex++;
				UseCurrentColor();
			}

		}
	}
	EVENT Timer()
	{
		CurrentIndex++;
		UseCurrentColor();
		Enable('Tick');
	}
	EVENT Trigger(Actor a,Pawn p)
	{
		TurnFilterOff();
	}

}



defaultproperties
{
     NeutralColor=(B=128,G=128,R=128)
     bAlwaysRelevant=True
}
