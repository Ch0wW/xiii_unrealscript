//=============================================================================
// Plage01.
//=============================================================================
class Plage01 extends Map01_Plage
     placeable;

var(PlageSetUp) XIIIPawn TueurPlanque;        // He own the pickup
var(PlageSetUp) localized string sClefPickup; // Name of the key for display
var(PlageSetUp) name EventPickupKeyPick;

//_____________________________________________________________________________
function FirstFrame()
{
    local inventory Inv;

    Super.FirstFrame();

    if ( TueurPlanque != none )
    {
      Inv = GiveSomething(class'Keys', TueurPlanque);
      Inv.Event = 'ClefPickup';
      Keys(Inv).KeyCodeName = "ClefPickup";
      Inv.ItemName = sClefPickup;
	  XIIIItems(Inv).EventCausedOnPick = EventPickupKeyPick;
    }

    // Trigger clouds
    TriggerEvent('PL_nuages', Self, none);

    XIIIPawn.SoundStepCategory=1;
}

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    Switch ( N )
    {
      Case 91:
        SetPrimaryGoal(0);
        Break;
      Case 92:
        SetPrimaryGoal(1);
        Break;
      Case 93:
        SetPrimaryGoal(2);
        Break;
    }
    Super.SetGoalComplete(N);
}

//_____________________________________________________________________________



defaultproperties
{
     EndMapVideo="cine01"
}
