//=============================================================================
// AudioTrigger.
//=============================================================================
class AudioTrigger extends Volume;

// -- variables
var() sound TouchMusic;
var() sound TouchSound;
var() sound UntouchMusic;
var() sound UntouchSound;
var() bool	bOnlyOnce;
//var() string Param1;

var int TouchCounter;
var() float minDelayTouchUntouch;
var() actor SoundActor;



auto state CanBeTouched
{
    event Touch (actor Other)
    {
        if ( Pawn(Other).IsPlayerPawn() )
        {
           // Log("CanBeTouched:Touch actor="$Other);
            PlayMusic( TouchMusic );
            if(SoundActor==none)
            {
                PlaySound( TouchSound );
            }
            else
            {
                SoundActor.PlaySound( TouchSound );
            }
            TriggerEvent( Event, Self, Pawn(Other));
            if (bOnlyOnce)
            {
                disable('touch');
            }
            else
            {
                TouchCounter++;   
                GotoState('CannotBeTouched');
            }
        }
    }
    
    event UnTouch (actor Other)
    {
        if ( Pawn(Other).IsPlayerPawn() )
        {
            if (TouchCounter == 0 && !bOnlyOnce)
            {
                GotoState('CannotBeTouched');
            }
            else
            {
                //		Log("UnTouch actor="$Other);
				if(!Other.bPendingDelete)
					PlayMusic( UntouchMusic );
                if(SoundActor==none)
                {
                    PlaySound( UntouchSound );
                }
                else
                {
                    SoundActor.PlaySound( UntouchSound );
                }
                
                UnTriggerEvent( Event, Self, Pawn(Other));
                
                if (bOnlyOnce)
				{
                    disable('untouch');
				//	 Log("bOnlyOnce.untouch "$Other);
				}
                else
                    TouchCounter--;
            }
        }
        
    }
}

state CannotBeTouched
{
	event Timer()
	{
		if (TouchCounter==0)
		{

	//		Log("UnTouch actor on lance le son timer=0");
			PlayMusic( UntouchMusic );
			if(SoundActor==none)
			{
				PlaySound( UntouchSound );
			}
			else
			{
				SoundActor.PlaySound( UntouchSound );
			}
		//	UnTriggerEvent( Event, Self, Pawn(Other));
		}
		GotoState('CanBeTouched');
	}

	event Touch (actor Other)
	{
	//	Log("Touch CannotBeTouched");
		TouchCounter++;
	}

	event UnTouch (actor Other)
	{
	//	Log("UnTouch CannotBeTouched");
		TouchCounter--;
	}


Begin:
	SetTimer(minDelayTouchUntouch, false);

}

defaultproperties
{
     minDelayTouchUntouch=0.200000
     bStatic=False
}
