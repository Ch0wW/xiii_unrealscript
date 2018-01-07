//=============================================================================
// CineWhiteHouseCardSM
// Created by iKi
// Last Modification by iKi
//=============================================================================

class CineWhiteHouseCardSM extends SMAttached
	/*placeable*/;

FUNCTION AttachTo(Pawn p)
{
	DebugLog("CineFBICardSM::AttachTo");
	p.AttachToBone(self,'X R Hand');
	SetRelativeLocation(Default.RelativeLocation);
	SetRelativeRotation(Default.RelativeRotation);
}

// Y -avant +arrière
// Yaw=-18384


defaultproperties
{
     RelativeLocation=(X=12.000000,Y=-2.650000,Z=2.000000)
     RelativeRotation=(Pitch=2000,Yaw=-20384,Roll=16384)
     StaticMesh=StaticMesh'MeshObjetsPickup.whitehousepass'
}
