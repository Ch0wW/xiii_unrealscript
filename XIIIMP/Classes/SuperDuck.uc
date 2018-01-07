//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SuperDuck extends MarioSuperBonus;

var Pawn MyPawn;
var PlayerReplicationInfo MyPRI;
var name BoneToAttach;

//__________________________________________________________________________

function ReleaseTheDuck()
{
    XIIIMPDuckController(XIIIMPDuckGameInfo(Level.Game).TheDuck.Controller).ReInitPoint = MyPawn.Location;
    XIIIMPDuckGameInfo(Level.Game).TheDuck.Controller.GotoState('ReInit');
}

//__________________________________________________________________________

event Destroyed()
{
    XIIIMPPlayerPawn(MyPawn).HasTheDuck = false;
    XIIIMPDuckGameInfo(Level.Game).WhoHasTheDuck = none;

    MyPawn.bCanPickupInventory = true;
    MyPawn.SpeedFactorLimit = 1.0;

    SetTimer(0.0,false);
    SetTimer2(0.0,false);

    RemoveIconInPlayerHud();

    BroadcastLocalizedMessage( class'XIIIMPDuckMessage', -1, MyPRI);
    ReleaseTheDuck();

    super.Destroyed();
}

//__________________________________________________________________________

function GiveTo( pawn Other )
{
    Super.GiveTo(other);
    MyPawn = Other;

    MyPawn.SpeedFactorLimit = 1.15;
    MyPawn.bCanPickupInventory = false;

    XIIIMPDuckGameInfo(Level.Game).WhoHasTheDuck = MyPawn;
    XIIIMPPlayerPawn(MyPawn).HasTheDuck = true;

    SetTimer(1.0,true);
    SetTimer2(5.0,true);

    AddIconInPlayerHud( Other );

    MyPRI = MyPawn.Controller.PlayerReplicationInfo;

    BroadcastLocalizedMessage( class'XIIIMPDuckMessage', 0, MyPRI);

    AttachToPawn(Other);
}

//_____________________________________________________________________________

function AttachToPawn(Pawn P)
{
  	if ( ThirdPersonActor == None )
  	{
  		ThirdPersonActor = Spawn(AttachmentClass,Owner);
  		InventoryAttachment(ThirdPersonActor).InitFor(self);
  	}
  	P.AttachToBone(ThirdPersonActor,BoneToAttach);
  	ThirdPersonActor.SetRelativeLocation(ThirdPersonRelativeLocation);
  	ThirdPersonActor.SetRelativeRotation(ThirdPersonRelativeRotation);
}

//__________________________________________________________________________

event Timer()
{
    Spawn(class'BlastDuck',,, MyPawn.Location);

    MyPawn.Health += 2.5;

    if( MyPawn.Health > MyPawn.default.Health )
       MyPawn.Health = MyPawn.default.Health;
}

//__________________________________________________________________________

event Timer2()
{
    MyPawn.Controller.PlayerReplicationInfo.Score += 1;
    BroadcastLocalizedMessage( class'XIIIMPDuckMessage', MyPRI.Score, MyPRI);
    Spawn(class'BlastDuck',,, MyPawn.Location);
}

//__________________________________________________________________________




defaultproperties
{
     BoneToAttach="X Head"
     BonusIconId=256
     ThirdPersonRelativeLocation=(X=5.000000,Z=17.000000)
     ThirdPersonRelativeRotation=(Yaw=-16384,Roll=16384)
     AttachmentClass=Class'XIIIMP.DuckAttachment'
}
