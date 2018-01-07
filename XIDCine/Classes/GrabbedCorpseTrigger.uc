//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GrabbedCorpseTrigger extends XIIITriggers;


var() bool bActivableParTrigger;	//attend trigger pour s'activer sinon actif des le debut
var() XIIIPawn CorpseToDetect;			//otage ou corps assomme a prendre en compte

//-----------------------------------------------------------

function Touch(Actor Other)
{
	if ( !bActivableParTrigger)
	{
		if ((( XIIIPlayerPawn(Other) != none ) && ( XIIIPlayerPawn(Other).LHand != none ))
			&& (( CorpseToDetect != none ) && ( XIIIPlayerPawn(Other).LHand.pOnShoulder == CorpseToDetect )))
		{
			TriggerEvent(event,self,XIIIPlayerPawn(Other));
			Disable('Touch');
		}
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	bActivableParTrigger = false;
}



defaultproperties
{
}
