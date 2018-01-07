//-----------------------------------------------------------
//
//-----------------------------------------------------------
class PutSoldiersToSleep extends Triggers;

var() array<BaseSoldier> ActorsToPutToSleep;

//_____________________________________________________________________________
event Trigger(actor other, pawn EventInstigator)
{
    local int i;

    if ( EventInstigator.IsPlayerPawn() )
    {
      for (i=0; i<ActorsToPutToSleep.Length; i++)
        if ( ActorsToPutToSleep[i] != none )
        {
          Log("@@@ making "$ActorsToPutToSleep[i]$" Sleeping");
          ActorsToPutToSleep[i].velocity=vect(0,0,0);
          ActorsToPutToSleep[i].Acceleration = vect(0, 0, 0);
          ActorsToPutToSleep[i].SetPhysics(PHYS_None);
          ActorsToPutToSleep[i].bStasis=true;
          ActorsToPutToSleep[i].Controller.bStasis=true;
          ActorsToPutToSleep[i].SetCollision(false,false,false);
          ActorsToPutToSleep[i].SetDrawType(DT_None);
      		if (ActorsToPutToSleep[i].Shadow!=none)
      			ActorsToPutToSleep[i].Shadow.DetachProjector(true);
          level.incattente();
          if (Iacontroller(ActorsToPutToSleep[i].Controller).NiveauAlerte==1)
            level.decAlerte();
          else if (Iacontroller(ActorsToPutToSleep[i].Controller).NiveauAlerte==2)
            level.decAttaque();
          ActorsToPutToSleep[i].RefreshDisplaying();
        }
      Destroy();
    }
}



defaultproperties
{
}
