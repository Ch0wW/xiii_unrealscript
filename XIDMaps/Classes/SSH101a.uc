//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SSH101a extends Map16_SSH1;

// 0 - Trouver un accès au centre de commandes de SSH1
// 1*- Ne pas se faire repérer par les GI
// 2*- Neutraliser les GI sans les tuer
// 3*- Ne pas utiliser d'armes à feu

//VAR(SSH101a) float DelayAlarm;
VAR(SSH101a) XIIIPawn CoffeeMachineSoldier;
//VAR Pawn Soldier;
VAR(SSH101a) Array<Pawn> PatrolSoldiers;
VAR int eNbVivants;

//_____________________________________________________________________________
event ParseDynamicLoading(LevelInfo MyLI)
{
    Super.ParseDynamicLoading(MyLI);
    MyLI.ForcedMeshes[MyLI.ForcedMeshes.Length] = Mesh( DynamicLoadObject("XIIIPersos.XIIIGalM",class'Mesh') );
}

FUNCTION FirstFrame()
{
	Super.FirstFrame();

	// changement du skin du perso principal
	XIIIPawn.Mesh = Mesh( DynamicLoadObject("XIIIPersos.XIIIGalM",class'Mesh') );

	eNbVivants = PatrolSoldiers.Length;
	log(self@"---> NOMBRE DE SOLDATS :"@eNbVivants);
	GotoState('STA_TestMortSoldats');
}

State STA_TestMortSoldats
{
	event Tick (float dt)
	{
		// on teste si les soldats sont morts ou simplement assommes

		local int i;

		i = 0;
		while (i<eNbVivants)
		{
			if ( PatrolSoldiers[i]!=none && PatrolSoldiers[i].bIsDead )
			{
				if ( PatrolSoldiers[i].HitDamageType.default.bCanKillStunnedCorspes )
				{
					TriggerEvent(Event,self,PatrolSoldiers[i]);
					SetGoalComplete( 2 );
				}
				// on retire le soldat du tableau
				PatrolSoldiers[i] = PatrolSoldiers[eNbVivants-1];
				eNbVivants --;
				if (eNbVivants < 1)
				{
					GotoState('');
				}
			}
			else
			{
				i ++;
			}
		}
	}
}


//_____________________________________________________________________________
//	DelayAlarm=2.0


defaultproperties
{
     iLoadSpecificValue=130
}
