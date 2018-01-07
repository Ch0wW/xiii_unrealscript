//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SMarin02 extends Map11_SousMarin;

var(SMarin02Setup) Name KeyEvent;
var(SMarin02Setup) XIIIPawn KeyKeeper;
var(SMarin02Setup) Porte DoorToOpen;
var(SMarin02Setup) name EventClefPorte;

//_____________________________________________________________________________
function FirstFrame()
{
    local inventory Inv;

    Super.FirstFrame();

    if ( KeyKeeper != none )
    {
      Inv = GiveSomething(class'Keys', KeyKeeper );
      Inv.Event = KeyEvent;
      Keys(Inv).KeyCodeName = DoorToOpen.UnlockItemCode;
      XIIIItems(Inv).EventCausedOnPick = EventClefPorte;
    }
}

// No need for script as there is only one objective.


defaultproperties
{
}
