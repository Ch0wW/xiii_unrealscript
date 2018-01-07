//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Sanc01 extends Map15_Sanctuaire;

VAR() XIIIMover PavingStone;
VAR() XIIIMover PavingStoneButton;
VAR() StaticMesh BrokenPavingStoneSM;

EVENT Trigger(actor Other,pawn EventInstigator)
{
	if ( PavingStone!=none && BrokenPavingStoneSM!=none )
	{
		PavingStone.StaticMesh = BrokenPavingStoneSM;
		PavingStone.GoToState('Locked');
		PavingStone.bNoInteractionIcon = true;
		if ( PavingStoneButton!=none )
		{
			PavingStoneButton.GoToState('Locked');
			PavingStoneButton.bNoInteractionIcon = true;
		}
	}
}



defaultproperties
{
}
