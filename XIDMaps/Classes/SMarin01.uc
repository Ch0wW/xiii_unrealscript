//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SMarin01 extends Map11_SousMarin;

var(SMarin01SetUp) XIIIPawn Garde;
var(SMarin01SetUp) localized string sClefPorte;
var(SMarin01SetUp) Volume vVolumeGoal99;
var(SMarin01SetUp) name EventClefPorte;

//_____________________________________________________________________________
function FirstFrame()
{
    local inventory Inv;

    Super.FirstFrame();

	if ( Garde != none )
	{
	    Inv = GiveSomething(class'Keys', Garde);
	    Inv.Event = 'ClefPorte';
	    Keys(Inv).KeyCodeName = "ClefPorte";
	    Inv.ItemName = sClefPorte;
		XIIIItems(Inv).EventCausedOnPick = EventClefPorte;
	}
}

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
  Super.SetGoalComplete(N);

  if ( N == 99 )
  {
    if ( vVolumeGoal99.Encompasses( XIIIPawn ) )
      TriggerEvent('Inside', self, XIIIPawn);
    else
      TriggerEvent('Outside', self, XIIIPawn);
  }
}



defaultproperties
{
     EndMapVideo="cine11"
}
