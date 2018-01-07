//=============================================================================
// CineFBICardSM
// Created by iKi
// Last Modification by iKi
//=============================================================================

class CineFBICardSM extends SMAttached
	/*placeable*/;

FUNCTION AttachTo(Pawn p)
{
	DebugLog("CineFBICardSM::AttachTo");
	p.AttachToBone(self,'X R Hand');
	SetRelativeLocation(Default.RelativeLocation);
	SetRelativeRotation(Default.RelativeRotation);
}

// Y -avant +arrière


defaultproperties
{
     RelativeLocation=(X=12.000000,Y=-2.150000,Z=2.000000)
     RelativeRotation=(Yaw=-18384,Roll=18384)
     StaticMesh=StaticMesh'MeshObjetsPickup.FBI_card'
}
