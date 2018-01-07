//-----------------------------------------------------------
// this is the mapinfo for Kello01b
//-----------------------------------------------------------
class Kello03 extends Map07_Kellownee;

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
  if ( N == 99 )
  {
    SetPrimaryGoal(0);
    return;
  }

  if ( N == 0 )
  {
    SetPrimaryGoal(1);
  }

  Super.SetGoalComplete(N);
}

//_____________________________________________________________________________



defaultproperties
{
     EndMapVideo="cine07"
}
