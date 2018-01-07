//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ToitsFocus extends MapInfo
  placeable;

var int Goal1_2Targets;

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    if ( N == 1 )
    {
      Goal1_2Targets ++;
      if ( Goal1_2Targets<2 )
        return;
    }

    if ( N==6 )
      SetPrimaryGoal(7);
    if ( N==5 )
      SetPrimaryGoal(6);
    if ( N==4 )
      SetPrimaryGoal(5);
    if ( N==3 )
      SetPrimaryGoal(4);
    if ( N==2 )
      SetPrimaryGoal(3);
    if ( N==1 )
      SetPrimaryGoal(2);
    if ( N==0 )
      SetPrimaryGoal(1);

    super.SetGoalComplete(N);
}

//_____________________________________________________________________________


defaultproperties
{
     checkTime=1.000000
}
