/*=============================================================================
// LadderVolumes, when touched, cause ladder supporting actors to use Phys_Ladder.
// note that underwater ladders won't be waterzones (no breathing problems)
============================================================================= */

class LadderVolume extends PhysicsVolume
	native;


var() name ClimbingAnimation, TopAnimation;	// name of animation to play when climbing this ladder
var() rotator WallDir;
var vector LookDir;
var vector ClimbDir;            // pawn can move in this direction (or reverse)
var const Ladder LadderList;    // list of Ladder actors associated with this LadderVolume
var() bool bNoPhysicalLadder;   // if true, won't push into/keep player against geometry in lookdir
var() bool bAutoPath;           // add top and bottom ladders automatically
var(sound) sound hFootLadderSound;   // sound to play for a footstep on this ladder

simulated function PostBeginPlay()
{
	local Ladder L, M;
	local vector Dir;

	Super.PostBeginPlay();
	LookDir = vector(WallDir);
	if ( !bAutoPath && (LookDir.Z != 0) )
	{
		ClimbDir = vect(0,0,1);
		for ( L=LadderList; L!=None; L=L.LadderList )
			for ( M=LadderList; M!=None; M=M.LadderList )
				if ( M != L )
				{
					Dir = Normal(M.Location - L.Location);
					if ( (Dir dot ClimbDir) < 0 )
						Dir *= -1;
					ClimbDir += Dir;
				}

		ClimbDir = Normal(ClimbDir);
		if ( (ClimbDir Dot vect(0,0,1)) < 0 )
			ClimbDir *= -1;
	}
}

simulated event PawnEnteredVolume(Pawn P)
{
    local rotator PawnRot;

    if ( !P.bCanClimbLadders || (P.Controller == None) || (P.Physics == PHYS_Ladder) || Level.Game.bGameEnded )
      return;

    Super.PawnEnteredVolume(P);
    PawnRot = P.Rotation;
    PawnRot.Pitch = 0;
    if ( (vector(PawnRot) Dot LookDir > 0.9)
      || ((AIController(P.Controller) != None) && (Ladder(P.Controller.MoveTarget) != None)) )
    {
//      Log("LADDER Volume, OnlyOneHandFree="$P.bHaveOnlyOneHandFree);
      if ( P.bHaveOnlyOneHandFree )
        P.YouCantClimb();
      else
        P.ClimbLadder(self);
    }
    else if ( !P.bDeleteMe && (P.Controller != None) )
      spawn(class'PotentialClimbWatcher',P);
}

simulated event PawnLeavingVolume(Pawn P)
{
    if ( P.OnLadder != self )
      return;
    Super.PawnLeavingVolume(P);
    P.OnLadder = None;
    P.EndClimbLadder(self);
}

simulated event PhysicsChangedFor(Actor Other)
{
    if ( (Other.Physics == PHYS_Falling) || (Other.Physics == PHYS_Ladder) || Other.bDeleteMe || (Pawn(Other) == None) || (Pawn(Other).Controller == None) || !Pawn(Other).bCanClimbLadders )
      return;
    if ( Level.bLonePlayer && Level.Game.bGameEnded )
      return;
    spawn(class'PotentialClimbWatcher',Other);
}

// ELR Can't reference type that do not exists in PREVIOUS compiled packages (not even in own package)
//	hFootLadderSound=Sound'XIIIsound.SpecActions__LadderClimb.LadderClimb__hXIIIClimbLadder'

defaultproperties
{
     ClimbDir=(Z=1.000000)
     RemoteRole=ROLE_SimulatedProxy
}
