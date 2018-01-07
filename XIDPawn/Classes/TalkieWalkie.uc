//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TalkieWalkie extends SMAttached;

var bool bTalkieDansLaMain;

Function AttachToWalkie(pawn p,optional bool bDansLaMain)
{
   if (bDansLaMain)
   {
      //log(self$"be n je le met dans la main");
       P.AttachToBone(self,'x r hand');
       SetRelativeLocation(vect(10,-3,8));
       SetRelativeRotation(rot(30000,8000,32000));
		 bTalkieDansLaMain=true;
   }
   else
   {
       P.AttachToBone(self,'x r thigh');
       SetRelativeLocation(RelativeLocation);
       SetRelativeRotation(RelativeRotation);
		 bTalkieDansLaMain=false;
   }
}
      //Attention axes en vrac donc face au perso les axes sont:
     // Z c'est  Y
     // X c'est -Z
     // Y c'est -X
     //de face
     // |  roll
     // -- yaw
     //.  pitch



defaultproperties
{
     RelativeLocation=(X=-3.000000,Y=4.000000,Z=10.000000)
     RelativeRotation=(Pitch=-17500,Yaw=-100,Roll=31000)
     StaticMesh=StaticMesh'MeshObjetsPickup.walkie'
}
