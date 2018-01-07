//-----------------------------------------------------------
// Hual01a
// Created by iKi on ??? ???? 2001
// Last Modification Fev 08th 2002 by iKi
//-----------------------------------------------------------
class Hual01a extends Map06_HualparBase;

VAR() XIIIMover BridgeLever;
VAR() XIIIMover PowerLever;
VAR() name CloseBridgeEvent;
VAR() name LowPowerEvent;
VAR() Array<GenNMI> GeneratedEnemies;
VAR bool bYaDuJus;
VAR bool bPremiersEnnemisGeneres;
VAR int eNumEnnemi;


FUNCTION SetGoalComplete(int N)
{
    Local int i;
	
    if ( N < Objectif.Length )
		Super.SetGoalComplete(N);
	
    switch (N)
    {
	case 666:
		bYaDuJus = true;
		if (PowerLever!=none)
		{
			PowerLever.GoToState('PlayerTriggerToggle','Close'); // jam powersupply lever
		}
		//SetPrimaryGoal(1);
		Objectif[1].bPrimary = true;
		SetGoalComplete(1);
		break;
	case 555:
		if ( !bYaDuJus )
		{
			if ( BridgeLever != none )
			{
				BridgeLever.GoToState('PlayerTriggerToggle','Close'); // jam bridge lever
				TriggerEvent( LowPowerEvent, self, none );
				SetPrimaryGoal(1);
			}
		}
		else
		{
			TriggerEvent ( CloseBridgeEvent, self, none );
			BridgeLever.GoToState('Locked');
			BridgeLever.bNoInteractionIcon = true;
		}
		break;
	}
}


FUNCTION Trigger( actor Other , pawn EventInstigator )
{
	local GenNMI Generateur;
	local int i;
	
	if ( !bPremiersEnnemisGeneres )
	{
		for (i=0;i<4;i++)
		{
			Generateur = GeneratedEnemies[i];
			if ( Generateur != none )
			{
				//log(self@"---> GENERATEUR ENNEMI"@Generateur@"ACTIVE");
				Generateur.Trigger(self,none);
			}
		}
		eNumEnnemi = i;
		bPremiersEnnemisGeneres = true;
	}
	else
	{
		Generateur = GeneratedEnemies[eNumEnnemi];
		if ( Generateur != none )
		{
			//log(self@"---> GENERATEUR ENNEMI"@Generateur@"ACTIVE");
			Generateur.Trigger(self,none);
			eNumEnnemi ++;
		}
	}
}


// No script needed as there is only one objective.


defaultproperties
{
     CloseBridgeEvent="PontA"
     LowPowerEvent="PowerLow"
     iLoadSpecificValue=26
}
