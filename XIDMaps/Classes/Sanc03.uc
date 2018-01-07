//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Sanc03 extends Map15_Sanctuaire;

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    if ( N==0 )
      SetPrimaryGoal(1);
    if ( N==1 )
      SetPrimaryGoal(2);

    super.SetGoalComplete(N);
}

//_____________________________________________________________________________
function FirstFrame()
{
    Super.FirstFrame();
    XIIIController.SwitchWeapon(6);
}



defaultproperties
{
     EndMapVideo="cine14"
}
