//=============================================================================
// XIIIDispatcher: recoi 1 trigger (qui correspond a son nom) en entree, et active
//un set d'event avec des delais optionnels
//=============================================================================
class XIIIDispatcher extends XIIITriggers;


//-----------------------------------------------------------------------------
// Dispatcher variables.

var() name  OutEvents[8]; // Events a genere
var() float OutDelays[8]; // Delai avant declenchement des events.
var() bool bTriggerOnceOnly;
var int i;


//____________________________________________________________________
// When dispatcher is triggered...
function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	gotostate('Dispatch');
}

//____________________________________________________________________
// When dispatcher is Untriggered...
function UnTrigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	gotostate('UnDispatch');
}

//____________________________________________________________________
// Dispatch events.
state() Dispatch
{
	ignores Trigger,UnTrigger;

Begin:
	for( i=0; i<ArrayCount(OutEvents); i++ )
	{
		if( (OutEvents[i] != '') && (OutEvents[i] != 'None') )
		{
			Sleep( OutDelays[i] );
			TriggerEvent(OutEvents[i],self,Instigator);
		}
	}
	if (bTriggerOnceOnly)
	   GotoState('fin');
	else
	   GotoState('');
}

//____________________________________________________________________
// Dispatch events.
state() UnDispatch
{
	ignores Trigger,Untrigger;

Begin:
	for( i=0; i<ArrayCount(OutEvents); i++ )
	{
		if( (OutEvents[i] != '') && (OutEvents[i] != 'None') )
		{
			Sleep( OutDelays[i] );
			UnTriggerEvent(OutEvents[i],self,Instigator);
		}
	}
	if (bTriggerOnceOnly)
	   GotoState('fin');
	else
	   GotoState('');
}

//____________________________________________________________________
state Fin
{
  function Trigger( actor Other, pawn EventInstigator );
  function UnTrigger( actor Other, pawn EventInstigator );
}



defaultproperties
{
}
