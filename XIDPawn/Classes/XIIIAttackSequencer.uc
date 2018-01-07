//=============================================================================
// XIIIAttackSequencer.
//=============================================================================
class XIIIAttackSequencer extends XIIITriggers;

//-----------------------------------------------------------------------------
// AttackSequencer variables.
var() basesoldier NMIaSwitcher;
var() GENNMI GenNmiDuPersoASwitcher;
var() int NumReseau;
var IaController IACOntr;

// When AttackSequencer is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
//	log(self$"@@@@@@@@  L'AttackSequencer est declenche ");
	Instigator = EventInstigator;
	gotostate('SwitchNumAttack');
}

//
// SwitchNumAttack.
//
state() SwitchNumAttack
{
	ignores trigger;

Begin:
	if (NMIaSwitcher==none && GenNmiDuPersoASwitcher!=none && GenNmiDuPersoASwitcher.instigator!=none)
		 NMIaSwitcher=basesoldier(GenNmiDuPersoASwitcher.instigator);
	If (NMIaSwitcher!=none && !NMIaSwitcher.bisdead)
	{
	   IACOntr=Iacontroller(NMIaSwitcher.controller);
      if (IACOntr!=none && NMIaSwitcher.NumReseauAttaque!=NumReseau)
      {
         NMIaSwitcher.NumReseauAttaque=NumReseau;
         if (IACOntr.enemy!=none)
         {
           if (NumReseau==0)
              IACONtr.gotostate('attaque');
           IACOntr.ChercheReseauAttaque();
         }
      }
  }
  GotoState('');
}



defaultproperties
{
     bCollideActors=False
}
