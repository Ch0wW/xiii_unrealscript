//=============================================================================
// NavigationPoint.
//
// NavigationPoints are organized into a network to provide AIControllers
// the capability of determining paths to arbitrary destinations in a level
//
//=============================================================================
class NavigationPoint extends Actor
	hidecategories(Lighting,LightColor,Force)
	native
	noexport;

#exec Texture Import File=Textures\S_Pickup.pcx Name=S_Pickup Mips=Off MASKED=1 COMPRESS=DXT1
#exec Texture Import File=Textures\SpwnAI.pcx Name=S_NavP Mips=Off MASKED=1 COMPRESS=DXT1
#exec Texture Import File=Textures\SubActionGameSpeed.pcx Name=SubActionGameSpeed Mips=Off COMPRESS=DXT1
#exec Texture Import File=Textures\LookTarget.pcx Name=S_LookTarget Mips=Off MASKED=1 COMPRESS=DXT1
#exec Texture Import File=Textures\ActionCamMove.pcx  Name=S_ActionCamMove Mips=Off COMPRESS=DXT1
#exec Texture Import File=Textures\ActionCamPause.pcx  Name=S_ActionCamPause Mips=Off COMPRESS=DXT1

// not used currently
#exec Texture Import File=Textures\SiteLite.pcx Name=S_Alarm Mips=Off MASKED=1 COMPRESS=DXT1

//------------------------------------------------------------------------------
// NavigationPoint variables
var transient const int newPathList[3]; //index of reachspecs (used by C++ Navigation code)
//var const array<ReachSpec> PathList; //index of reachspecs (used by C++ Navigation code)
var() name ProscribedPaths[4];	// list of names of NavigationPoints which should never be connected from this path
var() name ForcedPaths[4];		// list of names of NavigationPoints which should always be connected from this path
var int visitedWeight;
var const int bestPathWeight;
var const NavigationPoint nextNavigationPoint;
var const NavigationPoint nextOrdered;	// for internal use during route searches
var const NavigationPoint prevOrdered;	// for internal use during route searches
var const NavigationPoint previousPath;
var int cost;					// added cost to visit this pathnode
var() int ExtraCost;			// Extra weight added by level designer

var bool bEndPoint;	            // used by C++ navigation code
var bool bSpecialCost;			// if true, navigation code will call SpecialCost function for this navigation point
var bool taken;					// set when a creature is occupying this spot
var() bool bBlocked;			// this path is currently unuseable
var() bool bPropagatesSound;	// this navigation point can be used for sound propagation (around corners)
var() bool bOneWayPath;			// reachspecs from this path only in the direction the path is facing (180 degrees)
var() bool bNeverUseStrafing;	// shouldn't use bAdvancedTactics going to this point
var const bool bAutoBuilt;		// placed during execution of "PATHS BUILD"
var	bool bSpecialMove;			// if true, pawn will call SuggestMovePreparation() when moving toward this node
var bool bNoAutoConnect;		// don't connect this path to others except with special conditions (used by LiftCenter, for example)
var	const bool	bNotBased;		// used by path builder - if true, no error reported if node doesn't have a valid base
var const bool  bAutoPlaced;	// placed as marker for another object during a paths define
var const bool  bPathsChanged;	// used for incremental path rebuilding in the editor
var bool bAlreadyTargeted;  //targeted by a basesoldier

//event int SpecialCost(Pawn Seeker);

// Accept an actor that has teleported in.
// used for random spawning and initial placement of creatures
event bool Accept( actor Incoming, actor Source )
{
	// Move the actor here.
	taken = Incoming.SetLocation( Location );
	if (taken)
	{
		Incoming.Velocity = vect(0,0,0);
		Incoming.SetRotation(Rotation);
	}
	Level.Game.PlayTeleportEffect(Incoming, true, false);
	TriggerEvent(Event, self, Pawn(Incoming));
	return taken;
}

/* SuggestMovePreparation()
Optionally tell Pawn any special instructions to prepare for moving to this goal
(called by Pawn.PrepareForMove() if this node's bSpecialMove==true
*/
event bool SuggestMovePreparation(Pawn Other)
{
    return false;
}

/* ProceedWithMove()
Called by Controller to see if move is now possible when a mover reports to the waiting
pawn that it has completed its move
*/
function bool ProceedWithMove(Pawn Other)
{
    return true;
}

/* MoverOpened() & MoverClosed() used by NavigationPoints associated with movers */
function MoverOpened();
function MoverClosed();

event int SpecialCost(Pawn Seeker)
{
    return 10000;
}

defaultproperties
{
     bPropagatesSound=True
     bStatic=True
     bHidden=True
     bInteractive=False
     bCollideWhenPlacing=True
     bCanSeeThrough=True
     bCanShootThroughWithRayCastingWeapon=True
     bCanShootThroughWithProjectileWeapon=True
     //Texture=Texture'Engine.S_NavP'
     CollisionRadius=80.000000
     CollisionHeight=100.000000
}
