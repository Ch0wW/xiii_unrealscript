//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIILostEnemyTrigger extends XIIITriggers;

var() basesoldier NMIaSwitcher;
var IaController IACOntr;


// When XIIILostEnemyTrigger is triggered...
//
function Trigger(actor Other, pawn EventInstigator )
{
	//log(self$"@@@@@@@@  L'AttackSequencer est declenche ");
	Instigator = EventInstigator;
	gotostate('LostEnemy');
}

//
// SwitchNumAttack.
//
state() LostEnemy
{
	ignores trigger;

Begin:
	If (NMIaSwitcher!=none && !NMIaSwitcher.bisdead)
	{
	  IACOntr=Iacontroller(NMIaSwitcher.controller);
    if (IACOntr!=none && IACOntr.NiveauAlerte==2)
    {
        IACOntr.enemy=none;
        if (IACOntr.lastAttackpoint.bAccroupi)
           NMIaSwitcher.ShouldCrouch(true);
        IaCOntr.bCampeversSafePoint=true;
		  IAContr.HalteAuFeu();
        IaCOntr.gotostate('restesurplace');
    }
  }
	GotoState('');
}





defaultproperties
{
}
