//-----------------------------------------------------------
//
//-----------------------------------------------------------
class PRock03 extends Map08_PlainRock;

var(PRock03SetUp) XIIIPawn BureauKeyHolder, MagneticPassHolder, Jo;
var(PRock03SetUp) XIIIPorte DoorToOpen;
var(PRock03SetUp) XIIIPorte DoorToOpenByJo;
var(PRock03SetUp) name KeyEvent;
var(PRock03SetUp) localized string KeyEventItemName;
var(PRock03SetUp) name JoKeyEvent;
var(PRock03SetUp) localized string JoKeyEventItemName;
var(PRock03SetUp) MagneticPassTrigger PassTrigger;
var(PRock03SetUp) name EventBureauKeyPick;
var(PRock03SetUp) name EventMagneticCardPick;
var(PRock03SetUp) name EventJoKeyPick;

//_____________________________________________________________________________
function FirstFrame()
{
    local inventory Inv;

    Super.FirstFrame();

	if ( Jo != none )
	{
		Inv = GiveSomething(class'Keys', Jo );
		Inv.Event = JoKeyEvent;
		Keys(Inv).KeyCodeName = DoorToOpenByJo.UnlockItemCode;
		Inv.ItemName = JoKeyEventItemName;
		XIIIItems(Inv).EventCausedOnPick = EventJoKeyPick;
	}

    if ( MagneticPassHolder != none )
    {
		Inv = GiveSomething(class'PRock03MagneticCard', MagneticPassHolder );
		Inv.Event = PassTrigger.Tag;
		XIIIItems(Inv).EventCausedOnPick = EventMagneticCardPick;
    }
}

//_____________________________________________________________________________
function SetGoalComplete(int N)
{

	if ( N == 99 )
	{
		SetPrimaryGoal(1);
		return;
	}
    Super.SetGoalcomplete(N);

}

//_____________________________________________________________________________
function Trigger( actor Other, pawn EventInstigator )
{
	local inventory Inv;

	if ( DoorToOpen.GetStateName() == 'Locked' )
	{
		if ( BureauKeyHolder != none )
		{
			Inv = GiveSomething(class'Keys', BureauKeyHolder );
			Inv.Event = KeyEvent;
			Keys(Inv).KeyCodeName = DoorToOpen.UnlockItemCode;
			Inv.ItemName = KeyEventItemName;
			XIIIItems(Inv).EventCausedOnPick = EventBureauKeyPick;
		}
	}
}

//_____________________________________________________________________________


defaultproperties
{
     KeyEventItemName="Key"
     JoKeyEventItemName="Key"
     EndMapVideo="cine08"
}
