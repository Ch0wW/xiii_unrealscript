//___________________________________________________________
//
//___________________________________________________________
class Banque01MallettePick extends EventItemPick;

var() XIIIDocumentPick StunningSkillDoc;
var() XIIIDocumentPick SixSenseSkillDoc;


//___________________________________________________________
//auto state Pickup
Auto State Pickup
{

	event BeginState()
	{
		//bNoInteractionIcon = true;
		bInteractive = false;
		Disable('Touch');
	}

	event Trigger( actor Other, pawn EventInstigator )
	{
		bInteractive = true;
		//bNoInteractionIcon = false;
		Disable( 'Trigger' );
		Enable( 'Touch' );
	}

	function bool ValidTouch( actor Other )
	{

		local Inventory Copy;

		// make sure its a live player
		if ( (Pawn(Other)==none) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).Health <= 0) )
			return false;
		// make sure not touching through wall
		if ( !FastTrace(Other.Location+Pawn(Other).EyeHeight*vect(0,0,1), Location) )
			return false;
		// make sure game will let player pick me up
		if( Level.Game.PickupQuery(Pawn(Other), self) )
		{
			if ( bCauseEventOnPick )
			{
				TriggerEvent(Event, self, Pawn(Other));

				// when he gets the case, player gets also skill documents
				Copy = SixSenseSkillDoc.SpawnCopy(Pawn(Other));
				SixSenseSkillDoc.AnnouncePickup(Pawn(Other));
				Copy.PickupFunction(Pawn(Other));

				Copy = StunningSkillDoc.SpawnCopy(Pawn(Other));
				StunningSkillDoc.AnnouncePickup(Pawn(Other));
				Copy.PickupFunction(Pawn(Other));

			}
			return true;
		}
		return false;
	}
}


//___________________________________________________________


defaultproperties
{
     InvSelectItemSound=Sound'XIIIsound.Items.PassSel1'
     InvActivateSound=Sound'XIIIsound.Items.PassFire1'
     InvItemName="Case"
     bCauseEventOnPick=True
     InventoryType=None
     PickupMessage="Case"
     PickupSound=Sound'XIIIsound.Items.PassPick1'
     StaticMesh=StaticMesh'MeshObjetsPickup.valise'
}
