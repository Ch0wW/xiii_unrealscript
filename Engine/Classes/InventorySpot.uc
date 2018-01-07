//=============================================================================
// InventorySpot.
//=============================================================================
class InventorySpot extends NavigationPoint
	native;

var Pickup markedItem;

/* GetMoveTargetFor()
Possibly return pickup rather than self as movetarget
*/
function Actor GetMoveTargetFor(AIController B, float MaxWait)
{
	if ( (markedItem != None) && markedItem.ReadyToPickup(MaxWait) && (B.Desireability(markedItem) > 0) )
		return markedItem;
	
	return self;
}

defaultproperties
{
     bCollideWhenPlacing=False
     CollisionRadius=40.000000
     CollisionHeight=80.000000
     bHiddenEd=True
}
