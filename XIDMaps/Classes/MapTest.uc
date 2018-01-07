//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MapTest extends MapInfo placeable;

var int Goal0_2Targets;
var int Goal6_3Targets;
var int Goal8_3Targets;

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    if ( N == 0 )
    {
      Goal0_2Targets ++;
      if ( Goal0_2Targets<2 )
        return;
    }
    if ( N == 6 )
    {
      Goal6_3Targets ++;
      if ( Goal6_3Targets<3 )
        return;
    }
    if ( N == 8 )
    {
      Goal8_3Targets ++;
      if ( Goal8_3Targets<3 )
        return;
    }

    if ( N==7 )
      SetPrimaryGoal(8);
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



defaultproperties
{
     checkTime=1.000000
}
