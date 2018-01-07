//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZigouillateurVolume extends Volume;

VAR() Array<Actor> PersosAZigouiller;

//_____________________________________________________________________________
FUNCTION Touch (actor Other)
{
	LOCAL int i;

	if ( Pawn(Other)!=none && Pawn(Other).Controller.bIsPlayer )
	{
		for (i=0;i<PersosAZigouiller.Length;i++)
		{
      if (PersosAZigouiller[i] != none)
      {
        if ( (XIIIPawn(PersosAZigouiller[i]) == none) || (XIIIPlayerPawn(Other) == none) )
          PersosAZigouiller[i].Destroy();
        else
        { // destroy only if not visible and not in player's hand
          if ( !Pawn(Other).Controller.CanSee(Pawn(PersosAZigouiller[i]))
          && ( XIIIPawn(PersosAZigouiller[i]) != XIIIPlayerPawn(Other).LHand.pOnShoulder ) )
            PersosAZigouiller[i].Destroy();
        }
      }
		}
		TriggerEvent(event,self,Pawn(other));
	}
	Destroy();
}



defaultproperties
{
}
