//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Shark extends XIIIAmbientPawn;

var() int fFacteurvitesse;

   /*event tick(float dt) //steering
	{
	   super.tick(dt);

	   log(self@"SHARK "@physicsvolume@PhysicsVolume.bWaterVolume);
	} */
function PlayMoving()
{
   loopanim('nage');
}




defaultproperties
{
     fFacteurvitesse=1
     WaterSpeed=1000.000000
     ControllerClass=Class'XIDPawn.SharkController'
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     Mesh=SkeletalMesh'XIIIPersos.RequinM'
     CollisionHeight=10.000000
     Buoyancy=100.000000
}
