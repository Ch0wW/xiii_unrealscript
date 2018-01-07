//=============================================================================
// Event.
//=============================================================================
class Triggers extends Actor
	abstract
	placeable
	native;

defaultproperties
{
     bHidden=True
     bInteractive=False
     bCollideActors=True
     bCanSeeThrough=True
     bCanShootThroughWithRayCastingWeapon=True
     bCanShootThroughWithProjectileWeapon=True
     CollisionRadius=40.000000
     CollisionHeight=40.000000
}
