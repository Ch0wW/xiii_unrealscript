//-----------------------------------------------------------
//
//-----------------------------------------------------------
class LiftDoor extends XIIIMover;

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

state() TriggerControl
{
     function Trigger( actor Other, pawn EventInstigator )
     {
          numTriggerEvents++;
          SavedTrigger = Other;
          Instigator = EventInstigator;
          if ( SavedTrigger != None )
               SavedTrigger.BeginEvent();
          GotoState( 'TriggerControl', 'Open' );
     }
     function UnTrigger( actor Other, pawn EventInstigator )
     {
          numTriggerEvents--;
          if ( numTriggerEvents <=0 )
          {
               numTriggerEvents = 0;
               SavedTrigger = Other;
               Instigator = EventInstigator;
               SavedTrigger.BeginEvent();
               GotoState( 'TriggerControl', 'Close' );
          }
     }

     function BeginState()
     {
          numTriggerEvents = 0;
     }

Open:
     bClosed = false;
     if ( DelayTime > 0 )
     {
          bDelaying = true;
          Sleep(DelayTime);
     }
     DoOpen();
     FinishInterpolation();
     FinishedOpening();
     SavedTrigger.EndEvent();
     if( bTriggerOnceOnly )
          GotoState('');
     Stop;
Close:          
     if ( DelayTime > 0 )
     {
          bDelaying = true;
          Sleep(DelayTime);
     }
     DoClose();
     FinishInterpolation();
     FinishedClosing();
}



defaultproperties
{
     bNoInteractionIcon=True
     MoverEncroachType=ME_IgnoreWhenEncroach
     InitialState="TriggerControl"
}
