//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KillCounterTrigger extends XIIITriggers;


var() BaseSoldier SoldiersToKill[4];	//tableau d'ennemis a surveiller
var int i,eNbVivants;

//-----------------------------------------------------------


function Trigger( actor Other, pawn EventInstigator )
{
	eNbVivants = 4;
	GotoState('TestMortSoldats');
}

State TestMortSoldats
{
	event Tick( float dt )
	{
		i = 0;
		while (i<eNbVivants)
		{
			if (( SoldiersToKill[i] == none ) || ( SoldiersToKill[i].bIsDead ))
			{
				SoldiersToKill[i] = SoldiersToKill[eNbVivants-1];
				eNbVivants --;
				if ( eNbVivants == 0 )
				{
					TriggerEvent(event,none,none);
					Destroy();
				}
			}
			else
			{
				i ++;
			}
		}
	}
}



defaultproperties
{
}
