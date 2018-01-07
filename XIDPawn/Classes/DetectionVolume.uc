//=============================================================================
// detectionvolume.
//=============================================================================
class Detectionvolume extends Volume;


var bool bActivated;
var() bool bPawnActivable; //si vrai activable par pawn sinon par joueur
var() bool bLocalizeEnemy; // fait localiser l'enemy
var() XIIIpawn PersoEnContact;

ignores touch;

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
//Detection quand perso rentre dans volume
//
state() Detection
{

	function Trigger( actor Other, pawn EventInstigator )
	{
	}
	//_______________________________________________________________
	// When detectionvolume is triggered...
	event Touch( actor Other)
	{
		if (xiiipawn(Other)!=none && !bActivated && ((xiiipawn(Other).controller.bIsPlayer && !bPawnActivable) || (!xiiipawn(Other).controller.bIsPlayer && bPawnActivable)))
		{
			//log(self$"!!!!  Entered volume   !!!!");
			bActivated=true;
			instigator=xiiipawn(Other);
			TriggerEvent(Event, Self, instigator);
		}
	}
begin:
}

function xiiipawn CheckTouchList()
{
	local XIIIpawn P;

	ForEach TouchingActors(class'XIIIpawn', P)
		return P;
}

// When detectionvolume is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	PersoEnContact=CheckTouchList();
	if (PersoEnContact!=none)
	{
		if (!bActivated && ((PersoEnContact.controller.bIsPlayer && !bPawnActivable) || (!PersoEnContact.controller.bIsPlayer && bPawnActivable)))
       	{
			bActivated=true;
			instigator=PersoEnContact;
			TriggerEvent(Event, Self, instigator);
		}
	}
	gotostate('Detection');
}



defaultproperties
{
     bStatic=False
     bAlwaysRelevant=True
     InitialState="Detection"
     CollisionRadius=126.000000
     CollisionHeight=126.000000
}
