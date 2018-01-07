//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CineChampSM extends SMAttached;

FUNCTION AttachTo(Pawn p)
{
/*	DebugLog("CineCigareSM::AttachTo");
	p.AttachToBone(self,'X R Hand');
	SetRelativeLocation(Default.RelativeLocation);
	SetRelativeRotation(Default.RelativeRotation);
*/
//  if (bDansLaMain)
//   {
 //     log(self$"be n je le met dans la main");
       P.AttachToBone(self,'x l hand');
       SetRelativeLocation(RelativeLocation);
       SetRelativeRotation(RelativeRotation);
//   }
//   else
//   {
//     RelativeLocation=(X=-3.000000,Y=4.000000,Z=10.000000)
//     RelativeRotation=(Pitch=-17500,Yaw=-100,Roll=31000)
//       P.AttachToBone(self,'x r thigh');
 //      SetRelativeLocation(RelativeLocation);
//       SetRelativeRotation(RelativeRotation);
//   }
}




defaultproperties
{
     RelativeLocation=(X=6.000000,Y=-3.000000)
     RelativeRotation=(Pitch=62768,Yaw=16384,Roll=32000)
     StaticMesh=StaticMesh'MeshObjetsPickup.Champglass'
}
