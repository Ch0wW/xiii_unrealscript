//-----------------------------------------------------------
// CorpseDetectorTriger
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class CorpseDetectorTrigger extends Trigger;

VAR() Pawn CorpseToDetect;

EVENT Touch(actor Other)
{
	if ( CorpseToDetect==Pawn(Other) )
	{
		CorpseToDetect.bCanBeGrabbed=false;
		TriggerEvent(event, self, CorpseToDetect);
	}
}



defaultproperties
{
}
