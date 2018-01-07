//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Hual01b extends Map06_HualparBase;

VAR int iNbGenBroken;
VAR(Hual01bSetUp) LadderVolume ElectricalLadder;
VAR(Hual01bSetUp) StaticMeshActor ElectricalSFX;

FUNCTION SetGoalComplete(int N)
{
    Super.SetGoalcomplete(N);

    if ( N == 99 )
    {
		iNbGenBroken ++;
		switch(iNbGenBroken)
		{
			case 1:
			case 2:
			case 3:
				Objectif[iNbGenBroken+1].bCompleted = true;
				SetPrimaryGoal(iNbGenBroken+2);
				break;
			case 4:
				Objectif[5].bCompleted = true;
				SetSecondaryGoal(5);
				SetPrimaryGoal(6);
				ElectricalLadder.bPainCausing = false;
				ElectricalLadder.DamagePerSec = 0;
				ElectricalSFX.bHidden = true;
				ElectricalSFX.SetDrawType(DT_None);
				TriggerEvent('PowerShotDown', self, XIIIPawn);
				Super.SetGoalcomplete(2);
				break;
		}
		return;
    }
	
    if ( N == 1 )
    {
		if ( iNbGenBroken < 4 )
			SetPrimaryGoal(2);
    }
}



defaultproperties
{
}
