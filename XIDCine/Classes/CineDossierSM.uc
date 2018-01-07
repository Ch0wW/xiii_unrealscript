//=============================================================================
// CineDossierSM
// Created by iKi
// Last Modification by iKi
//=============================================================================

class CineDossierSM extends SMAttached
	/*placeable*/;

FUNCTION AttachTo(Pawn p)
{
	DebugLog("CineFBICardSM::AttachTo");
	p.AttachToBone(self,'X R Hand');
	SetRelativeLocation(Default.RelativeLocation);
	SetRelativeRotation(Default.RelativeRotation);
}

// X +sort de la main dans le sene du bras
// Y +sous la main


defaultproperties
{
     RelativeLocation=(X=16.000000,Y=-4.250000,Z=2.000000)
     RelativeRotation=(Yaw=-3000,Roll=16384)
     StaticMesh=StaticMesh'MeshObjetsPickup.dossierFBI'
}
