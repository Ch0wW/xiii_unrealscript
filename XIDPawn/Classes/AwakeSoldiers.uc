//-----------------------------------------------------------
//
//-----------------------------------------------------------
class AwakeSoldiers extends Triggers;

var() array<BaseSoldier> ActorsToAwake;

//_____________________________________________________________________________
function AwakeSoldiers()
{
    local int i;

    for (i=0; i<ActorsToAwake.Length; i++)
      if ( ActorsToAwake[i] != none )
      {
        Log("@@@ making "$ActorsToAwake[i]$" Awake");
        ActorsToAwake[i].controller.bStasis=false;
        ActorsToAwake[i].bStasis=false;
        ActorsToAwake[i].SetPhysics(PHYS_Walking);
        ActorsToAwake[i].SetCollision(true,true,true);
        ActorsToAwake[i].SetDrawType(DT_Mesh);
        if (Iacontroller(ActorsToAwake[i].Controller).NiveauAlerte==1)
        {
           level.incAlerte();
           level.decattente();
        }
        else if (Iacontroller(ActorsToAwake[i].Controller).NiveauAlerte==2)
        {
           level.incAttaque();
           level.decattente();
        }
        ActorsToAwake[i].RefreshDisplaying();
     }
    Destroy();
}

//_____________________________________________________________________________
event Touch(actor other)
{
    if ( Pawn(Other).IsPlayerPawn() )
      AwakeSoldiers();
}

//_____________________________________________________________________________
event Trigger(actor other, pawn eventinstigator)
{
    if ( EventInstigator.IsPlayerPawn() )
      AwakeSoldiers();

}



defaultproperties
{
}
