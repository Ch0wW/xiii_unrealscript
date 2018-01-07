//=============================================================================
// Dispatcher: receives one trigger (corresponding to its name) as input,
// then triggers a set of specifid events with optional delays.
//=============================================================================
class Dispatcher extends Triggers;

#exec Texture Import File=Textures\Dispatch.pcx Name=S_Dispatcher Mips=Off MASKED=1

//-----------------------------------------------------------------------------
// Dispatcher variables.

var() name  OutEvents[32]; // Events to generate.
var() float OutDelays[32]; // Relative delays before generating events.
var int i;                // Internal counter.

//=============================================================================
// Dispatcher logic.

//
// When dispatcher is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	gotostate('Dispatch');
}

//
// Dispatch events.
//
state Dispatch
{
	ignores trigger;

Begin:
	for( i=0; i<ArrayCount(OutEvents); i++ )
	{
		if( (OutEvents[i] != '') && (OutEvents[i] != 'None') )
		{
			Sleep( OutDelays[i] );
			TriggerEvent(OutEvents[i],self,Instigator);
		}
	}
	GotoState('');
}

defaultproperties
{
     Texture=Texture'Gameplay.S_Dispatcher'
}
