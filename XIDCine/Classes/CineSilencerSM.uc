//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CineSilencerSM extends SMAttached
	/*placeable*/;

FUNCTION AttachTo(Pawn p)
{
	DebugLog("CineSlencerSM::AttachTo");
	p.AttachToBone(self,'X R Hand');
	SetRelativeLocation(0.3*Default.RelativeLocation);
	SetRelativeRotation(Default.RelativeRotation);
}


//	RelativeLocation=(X=8,Y=-7,Z=0))
//	RelativeRotation=(Roll=16384,Yaw=0,Pitch=0))
//    DrawScale=0.30


defaultproperties
{
     RelativeLocation=(X=-4.000000,Y=-8.000000,Z=14.000000)
     StaticMesh=StaticMesh'MeshArmesPickup.silencieux'
     DrawScale=0.900000
     DrawScale3D=(Y=0.800000,Z=0.800000)
}
