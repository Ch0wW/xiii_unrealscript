//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TriggerPetitCachottier extends Triggers;

VAR()	Array<Actor> PersosACacher;
VAR()	bool bHideAtMapStart;
VAR		bool bFirstCall;

struct tpcMemo
{
	VAR bool ColActors, BlockActors, BlockPlayers;
};

VAR		Array<tpcMemo> MecaFlags;

FUNCTION ShowAndHide()
{
	LOCAL int i;

	for (i=0;i<PersosACacher.Length;i++)
	{
		if (PersosACacher[i]!=none)
		{
			PersosACacher[i].bHidden=!PersosACacher[i].bHidden;
			if ( PersosACacher[i].bHidden )
				PersosACacher[i].SetCollision(false,false,false);
			else
				PersosACacher[i].SetCollision(MecaFlags[i].ColActors ,MecaFlags[i].BlockActors, MecaFlags[i].BlockPlayers );

			PersosACacher[i].RefreshDisplaying();
		}
	}
}

EVENT PostBeginPlay( )
{
	LOCAL int i;

	MecaFlags.Insert( 0, PersosACacher.Length );
	
	for ( i = 0; i < PersosACacher.Length; ++i )
	{
		if ( PersosACacher[i]!=none )
		{
			MecaFlags[i].ColActors = PersosACacher[i].bCollideActors;
			MecaFlags[i].BlockActors = PersosACacher[i].bBlockActors;
			MecaFlags[i].BlockPlayers = PersosACacher[i].bBlockPlayers;
		}
		else
			Log(self@"~"@i@"~"@PersosACacher[i]);
	}

	if ( bHideAtMapStart )
		ShowAndHide();
}

EVENT Trigger(actor Other, pawn EventInstigator)
{
	ShowAndHide();
}



defaultproperties
{
     bHideAtMapStart=True
}
