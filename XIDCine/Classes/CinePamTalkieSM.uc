//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CinePamTalkieSM extends SMAttached;

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
       P.AttachToBone(self,'x r hand');
       SetRelativeLocation(vect(10,-3,0));
       SetRelativeRotation(rot(0,-16384,16384));
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
     RelativeLocation=(X=8.000000,Y=-7.000000)
     RelativeRotation=(Roll=16384)
     StaticMesh=StaticMesh'MeshObjetsPickup.walkiePlage'
     DrawScale=0.500000
}
