//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Hual04aFusible extends EventItem;

var actor FuseInteraction;

//_____________________________________________________________________________
state idle
{
	simulated function Activate()
	{
		local actor A;

		A = XIIIPlayercontroller(Pawn(Owner).controller).MyInteraction.TargetActor;

		if (( A == none ) || ( A != FuseInteraction ))
			return;

		if ( XIIIPawn(Owner).bHaveOnlyOneHandFree && (IHand == IH_2H) )
			PlayerController(Pawn(owner).controller).MyHud.LocalizedMessage(class'XIIISoloMessage', 8);
		else
			GotoState('InUse');
	}
}

//_____________________________________________________________________________


defaultproperties
{
     IconNumber=25
     sItemName="Fuse"
     PickupClassName="XIII.Hual04aFusiblePick"
     PlayerViewOffset=(Y=7.000000,Z=-7.000000)
     ItemName="Fuse"
     Event="FusibleRamasse"
     Mesh=SkeletalMesh'XIIIDeco.fpsTLfusibleM'
}
