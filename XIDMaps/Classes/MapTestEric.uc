//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MapTestEric extends MapInfo;

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    Super.SetGoalcomplete(N);

    Switch(N)
    {
      Case 0: SetPrimaryGoal(1); SetPrimaryGoal(2); break;
    }
}



defaultproperties
{
}
