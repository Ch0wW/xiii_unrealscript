//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Sanc02a extends Map15_Sanctuaire;

var(Sanc02aSetUp) Sanc02aDecoStatuePart DecoPart;
var(Sanc02aSetUp) BaseSoldier PawnPickingPawn;
var(Sanc02aSetUp) Sanc02amagneticcardpick CardPick;
var(Sanc02aSetUp) XIIIPawn KeyKeeper;
var(Sanc02aSetUp) porte DoorToOpen;
var(Sanc02aSetUp) name EventDoorKeyPick;


//______________________________________________________________________________
function FirstFrame()
{
    local inventory Inv;

    Super.FirstFrame();
    DecoPart.bHidden=true;
    DecoPart.RefreshDisplaying();
    // la cle est donnee au bon pawn
    if ( KeyKeeper != none )
    {
      Inv = GiveSomething(class'Keys', KeyKeeper );
      Keys(Inv).KeyCodeName = DoorToOpen.UnlockItemCode;
      XIIIItems(Inv).EventCausedOnPick = EventDoorKeyPick;
    }
}

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    local EventItemPick PickU;
    local Sanc02aStatuePart SPart;

    if ( N == 99 )
      SetPrimaryGoal(2);
    else if ( N == 98 )
    {
      DecoPart.bHidden=false;
	  DecoPart.RefreshDisplaying();
      TriggerEvent('Secret',self, XIIIPawn);
      // Must remove DecoPart from inventory
      SPart = Sanc02aStatuePart(XIIIPawn.FindInventoryType(class'Sanc02aStatuePart'));
      Log("Found SPart "$SPart$" in player inventory");
      if (SPart != none )
        SPart.UsedUp();
    }
    else if ( N == 97 )
    {
      foreach allactors(class'EventItemPick', PickU)
      {
        if ( caps(PickU.Event) == caps('StatuePartPicked') )
          PickU.Event = 'StatuePartUse';
      }
    }
    else if ( N == 96 )
    {
//      Log("Before Touch");
      CardPick.Touch(PawnPickingPawn);
//      Log("After Touch");
    }

    super.SetGoalComplete(N);

    if ( N==0 )
      SetPrimaryGoal(1);

}



defaultproperties
{
     iLoadSpecificValue=106
}
