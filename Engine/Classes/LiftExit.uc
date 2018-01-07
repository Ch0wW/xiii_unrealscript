//=============================================================================
// LiftExit.
//=============================================================================
class LiftExit extends NavigationPoint
	placeable
	native;

#exec Texture Import File=Textures\Lift_exit.pcx Name=S_LiftExit Mips=Off MASKED=1 COMPRESS=DXT1

var() name LiftTag;
var	Mover MyLift;
var() byte SuggestedKeyFrame;	// mover keyframe associated with this exit - optional
var byte KeyFrame;

function bool SuggestMovePreparation(Pawn Other)
{
	if ( (Other.Base == MyLift) && (MyLift != None) )
	{
		// if pawn is on the lift, see if it can get off and go to this lift exit
		if ( (self.Location.Z < Other.Location.Z + Other.CollisionHeight)
			 && Other.LineOfSightTo(self) )
			return false;

		// make pawn wait on the lift
		Other.DesiredRotation = rotator(Location - Other.Location);
		Other.Controller.WaitForMover(MyLift);
		return true;
	}
	return false;
}

defaultproperties
{
     SuggestedKeyFrame=255
     bSpecialMove=True
     //Texture=Texture'Engine.S_LiftExit'
}
