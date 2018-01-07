//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SSH102a extends Map16_SSH1;

var(Objectifs) float Chronotime;
var Chronometre PlayerChrono;

//_____________________________________________________________________________
function FirstFrame()
{
    Super.FirstFrame();
    PlayerChrono = Chronometre(GiveSomething(class'Chronometre', XIIIPawn));
    if (PlayerChrono != none)
      PlayerChrono.ReSetTimer(Chronotime);
}

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
  local Chronometre C;

  if (N==99)
  { // Chrono ended... too bad GameOver.
    Level.Game.EndGame( XIIIController.PlayerReplicationInfo, "GoalIncomplete" );
    return;
  }

  Super.SetGoalComplete(N);

  if ( bLevelComplete && (PlayerChrono != none) )
    PlayerChrono.Destroy();
}



defaultproperties
{
     Chronotime=60.000000
}
