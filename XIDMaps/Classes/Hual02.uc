//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Hual02 extends Map06_HualparBase;

// obj 0 : Go to Carrington's cell
// obj 1 : Don't be detected
// obj 2 : Free Carrington
// obj 3 : Escape with Carrington

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
	switch (N)
	{
		case 91:
			SetPrimaryGoal (1) ;
			break ;

		case 92:
			SetPrimaryGoal (2) ;
			break ;

		case 93:
			SetPrimaryGoal (3) ;
			break ;

		case 94:
			SetPrimaryGoal (4) ;
			break ;
	}

  Super.SetGoalComplete(N);

}



defaultproperties
{
     EndMapVideo="cine04"
}
