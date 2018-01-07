//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SSH101c extends Map16_SSH1;

var int GoalZeroTargets;
var(SSH101cSetUp) int NumberOfDeadBeforeGoal1;
var(SSH101cSetUp) MagneticPassTrigger PassTrigger;
var(SSH101cSetUp) XIIIPawn MagneticPassHolder;
var(SSH101cSetUp) name EventMagneticCardPick;

// Obj 00 = Buter NumberOfDeadBeforeGoal1 persos.
// Obj 01 = Sortir de la map.

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    if ( N == 0 )
    {
      GoalZeroTargets ++;
      if ( GoalZeroTargets<NumberOfDeadBeforeGoal1 )
        return;
    }

    if ( N == 0 )
    {
      SetPrimaryGoal(1);
      TriggerEvent('portesecour', self, XIIIPawn);
    }

    super.SetGoalComplete(N);
}

//_____________________________________________________________________________
function FirstFrame()
{
    local inventory Inv;

    Super.FirstFrame();

    if ( MagneticPassHolder != none )
    {
		Inv = GiveSomething(class'PRock03MagneticCard', MagneticPassHolder );
		Inv.Event = PassTrigger.Tag;
		XIIIItems(Inv).EventCausedOnPick = EventMagneticCardPick;
    }
}

//_____________________________________________________________________________


defaultproperties
{
     NumberOfDeadBeforeGoal1=8
     iLoadSpecificValue=191
}
