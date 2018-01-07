//-----------------------------------------------------------
//
//-----------------------------------------------------------
class LiftCage extends XIIIMover;

VAR actor act;
//____________________________________________________________________
function PostBeginPlay()
{
    Super.PostBeginPlay();

	if (KeyNum != 0)
	{
		bOpened=true;
		bClosed=false;
	}
	PrevKeyNum = KeyNum;
}
/*
EVENT Attach(Actor other)
{
	Log("ATTACH "$other);
}
*/
EVENT Detach(Actor other)
{
	if ( Velocity != vect(0,0,0) )
	{
		LOG ("REATTACH"@other@"To me"@name);
		act=other;
		SetTimer2(0.001,false);
//		other.Velocity-=Velocity;
	}
}

EVENT Timer2()
{
	if ( act!=none && !act.bDeleteMe )
		act.SetBase( self );
}




defaultproperties
{
     bNoInteractionIcon=True
     MoverEncroachType=ME_IgnoreWhenEncroach
     InitialState="TriggerToggle"
}
