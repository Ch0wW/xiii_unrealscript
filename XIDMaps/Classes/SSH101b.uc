//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SSH101b extends Map16_SSH1;


var(SSH101bSetup) Name KeyEvent;
var(SSH101bSetup) XIIIPawn KeyKeeper;
var(SSH101bSetup) Porte DoorToOpen;
var(SSH101bSetup) name EventKeyPick;


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
      //Inv.ItemName = DoorToOpen.UnlockItemCode;
	  XIIIItems(Inv).EventCausedOnPick = EventKeyPick;
    }
}


//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    super.SetGoalComplete(N);

    Switch(N)
    {
      Case 99:
        SetPrimaryGoal(2);
        break;
      Case 2:
        SetPrimaryGoal(3);
        break;
      Case 3:
        SetPrimaryGoal(4);
        break;
    }
}



defaultproperties
{
}
