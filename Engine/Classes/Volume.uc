//=============================================================================
// Volume:  a bounding volume
// touch() and untouch() notifications to the volume as actors enter or leave it
// enteredvolume() and leftvolume() notifications when center of actor enters the volume
// pawns with bIsPlayer==true  cause playerenteredvolume notifications instead of actorenteredvolume()
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Volume extends Brush
	native;

var Actor AssociatedActor;			// this actor gets touch() and untouch notifications as the volume is entered or left
var() name AssociatedActorTag;		// Used by L.D. to specify tag of associated actor
var() int LocationPriority;
var() string LocationName;

native function bool Encompasses(Actor Other); // returns true if center of actor is within volume

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( (AssociatedActorTag != '') && (AssociatedActorTag != 'None') )
		ForEach AllActors(class'Actor',AssociatedActor, AssociatedActorTag)
			break;
}
	
function SetAssociatedActor(Actor Other)
{
	AssociatedActor = Other;
	if ( AssociatedActor != None )
		GotoState('AssociatedTouch');
	else
		GotoState('');
}

State AssociatedTouch
{
	event touch( Actor Other )
	{
		AssociatedActor.touch(Other);
	}

	event untouch( Actor Other )
	{
		AssociatedActor.untouch(Other);
	}
}

defaultproperties
{
     LocationName="unspecified"
     bSkipActorPropertyReplication=True
     bCollideActors=True
     bCanSeeThrough=True
     bCanShootThroughWithRayCastingWeapon=True
     bCanShootThroughWithProjectileWeapon=True
}
