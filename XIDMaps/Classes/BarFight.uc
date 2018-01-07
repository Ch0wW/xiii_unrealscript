//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BarFight extends MapInfo placeable;

VAR(BarSetup) Name ExitKeyEvent;
VAR(BarSetup) XIIIPawn ExitKeyKeeper;
var(BarSetup) Porte FinalDoor;
var(BarSetup) localized string sFinalDoorKeyName;
function FirstFrame()
{
    local inventory Inv;

    Super.FirstFrame();

    if ( ExitKeyKeeper != none )
    {
      Inv = GiveSomething(class'Keys', ExitKeyKeeper );
      Inv.Event = ExitKeyEvent;
      Keys(Inv).KeyCodeName = FinalDoor.UnlockItemCode;
      Inv.ItemName = sFinalDoorKeyName;
    }
}



defaultproperties
{
     ExitKeyEvent="ExitKeyEvent"
}
