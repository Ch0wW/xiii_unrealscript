//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPSpecialMatos extends Inventory;

var() name BoneToAttach;                  // bone to attach the armor

//_____________________________________________________________________________

function GiveTo( pawn Other )
{
    DetachFromPawn(Pawn(Owner));
    Super.GiveTo(other);
    AttachMatosToPawn(Other);
}

//_____________________________________________________________________________

simulated function AttachMatosToPawn(Pawn P)
{
	local name BoneName;

	if ( ThirdPersonActor == None )
	{
		ThirdPersonActor = Spawn(AttachmentClass,Owner);
		InventoryAttachment(ThirdPersonActor).InitFor(self);
	}

    BoneName = BoneToAttach;

	if ( BoneName == '' )
	{
		ThirdPersonActor.SetLocation(P.Location);
		ThirdPersonActor.SetBase(P);
	}
	else
		P.AttachToBone(ThirdPersonActor,BoneName);

	ThirdPersonActor.SetRelativeLocation(ThirdPersonRelativeLocation);
	ThirdPersonActor.SetRelativeRotation(ThirdPersonRelativeRotation);
}

//_____________________________________________________________________________



defaultproperties
{
}
