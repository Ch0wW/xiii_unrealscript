//=============================================================================
// CineCigareSM
// Created by iKi
// Last Modification by iKi
//=============================================================================

class CineCigareSM extends SMAttached
	/*placeable*/;

FUNCTION AttachTo(Pawn p)
{
	p.AttachToBone(self,'X R Hand');
	SetRelativeLocation(Default.RelativeLocation);
	SetRelativeRotation(Default.RelativeRotation);
}



defaultproperties
{
     bHidden=True
     RelativeLocation=(X=6.000000,Y=-7.000000,Z=0.500000)
     RelativeRotation=(Pitch=-200,Roll=18432)
     StaticMesh=StaticMesh'MeshObjetsPickup.Cigare'
}
