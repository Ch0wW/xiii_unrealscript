class PotentialClimbWatcher extends Info
	native;

simulated function Tick(float DeltaTime)
{
    local rotator PawnRot;
    local LadderVolume L;
    local bool bFound;

    if ( (Owner == None) || Owner.bDeleteMe || (Owner.Physics == PHYS_Ladder)
    || (Pawn(Owner).Controller == None) || Level.Game.bGameEnded )
    {
      destroy();
      return;
    }

    PawnRot = Owner.Rotation;
    PawnRot.Pitch = 0;
    ForEach Owner.TouchingActors(class'LadderVolume', L)
      if ( L.Encompasses(Owner) )
      {
        if ( (vector(PawnRot) Dot L.LookDir) > 0.9 )
        {
//          Log("LADDER PotentialClimbWatcher, OnlyOneHandFree="$Pawn(Owner).bHaveOnlyOneHandFree);
          if ( Pawn(Owner).bHaveOnlyOneHandFree )
            Pawn(Owner).YouCantClimb();
          else
          {
            Pawn(Owner).ClimbLadder(L);
            destroy();
            return;
          }
        }
        else
          bFound = true;
      }

    if ( !bFound )
    destroy();
}

defaultproperties
{
}
