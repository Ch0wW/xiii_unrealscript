//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Base01 extends Map10_Base;

var(Base01SetUp) Base01DoorObjective DoorVsZoneCheck[3];
var int iNumberDoorsPassed;

// Goal 91 == Door closing

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    if ( N == 91 )
    {
      if ( (XIIIPawn.Location - DoorVsZoneCheck[iNumberDoorsPassed].Location) dot vector(DoorVsZoneCheck[iNumberDoorsPassed].rotation) > 0.0 )
      {
        Log("-> Sas Door closed, player ok");
        iNumberDoorsPassed ++;
        return; // don't validate objective if player gone through door before closing
      }
      else
      {
        Log("-> Sas Door closed, player GameOver");
        Level.Game.EndGame( XIIIController.PlayerReplicationInfo, "GoalIncomplete" );
        return;
      }
    }
    Super.SetGoalComplete(N);
}



defaultproperties
{
}
