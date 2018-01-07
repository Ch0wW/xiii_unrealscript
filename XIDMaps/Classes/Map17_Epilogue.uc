//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Map17_Epilogue extends MapInfo placeable;


//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    Switch ( N )
    {
      Case 91:
        SetPrimaryGoal(1);
        Break;
    }
    Super.SetGoalComplete(N);
}

//_____________________________________________________________________________



defaultproperties
{
}
