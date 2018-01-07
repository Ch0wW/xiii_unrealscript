//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Amos01 extends Map03_Amos;

#exec OBJ LOAD FILE=XIIIAmos.utx
var(Amos01SetUp) StaticMeshActor DisplayScreen;         // the big screen actor
var(Amos01SetUp) StaticMesh Screen1, Screen2, Screen3;  // the staticmeshes to replace the original one

function FirstFrame()
{
	SUPER.FirstFrame();

    if ( Level.Game.GoreLevel != 0 )
    {
// PARENTAL LOCL ON
		ReplaceATextureByAnOther( Texture'XIIIAmos.Amfilm02', Texture'XIIIAmos.Amfilm02PL' );
	}
	else
	{
// PARENTAL LOCL OFF
		ReplaceATextureByAnOther( Texture'XIIIAmos.Amfilm02PL', Texture'XIIIAmos.Amfilm02' );
	}
}

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    Super.SetGoalcomplete(N);

    // Change the big screen visual
    switch(N)
    {
      Case 91:
        DisplayScreen.StaticMesh = Screen1;
        break;
      Case 92:
        DisplayScreen.StaticMesh = Screen2;
        break;
      Case 93:
        DisplayScreen.StaticMesh = Screen3;
        break;
    }
}

//_____________________________________________________________________________
function Trigger( actor Other, pawn EventInstigator )
{
	//log(self@"---> QUI ME TUE ?"@EventInstigator);
	if ( EventInstigator.IsA( 'XIIIPlayerPawn' ) )
	{
		//log(self@"---> C'EST LE PERSO PRINCIPAL");
		LOG( ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
		LOG( "FBI Killed by XIII" );
		SetGoalComplete(0);
	}
}

//_____________________________________________________________________________


defaultproperties
{
}
