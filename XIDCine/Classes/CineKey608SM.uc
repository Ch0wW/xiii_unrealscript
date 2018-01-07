//=============================================================================
// CineKey608SM
// Created by iKi
// Last Modification by iKi
//=============================================================================

class CineKey608SM extends SMAttached
	/*placeable*/;

FUNCTION AttachTo(Pawn p)
{
	p.AttachToBone(self,'X R Hand');
	SetRelativeLocation(Default.RelativeLocation);
	SetRelativeRotation(Default.RelativeRotation);
}

// Y -avant +arrière
//	RelativeLocation=(X=12,Y=-2.15,Z=2))
//	RelativeRotation=(Roll=18384,Yaw=-18384,Pitch=0))


defaultproperties
{
     RelativeLocation=(X=9.500000,Y=-9.150000,Z=5.000000)
     RelativeRotation=(Yaw=-18384,Roll=2000)
     StaticMesh=StaticMesh'MeshObjetsPickup.clef608'
     DrawScale=0.500000
}
