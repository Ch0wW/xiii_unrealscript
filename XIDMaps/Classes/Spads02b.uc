//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Spads02b extends Map09_Spads;

var(Spads02bSetup) Name KeyEvent;
var(Spads02bSetup) XIIIPawn KeyKeeper;
var(Spads02bSetup) Porte DoorToOpen;
var(Spads02bSetup) name EventKeyPick;
var(Spads02bSetup) localized string KeyKeeperKeyName;

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
      Inv.ItemName = KeyKeeperKeyName;
      XIIIItems(Inv).sItemName = KeyKeeperKeyName;
      XIIIItems(Inv).EventCausedOnPick = EventKeyPick;
    }
}



defaultproperties
{
     KeyKeeperKeyName="Key"
}
