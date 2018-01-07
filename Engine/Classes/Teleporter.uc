///=============================================================================
// Teleports actors either between different teleporters within a level
// or to matching teleporters on other levels, or to general Internet URLs.
//=============================================================================
class Teleporter extends NavigationPoint
	placeable
	native;

#exec Texture Import File=Textures\Teleport.pcx Name=S_Teleport Mips=Off MASKED=1 COMPRESS=DXT1

//-----------------------------------------------------------------------------
// Teleporter URL can be one of the following forms:
//
// TeleporterName
//		Teleports to a named teleporter in this level.
//		if none, acts only as a teleporter destination
//
// LevelName/TeleporterName
//     Teleports to a different level on this server.
//
// Unreal://Server.domain.com/LevelName/TeleporterName
//     Teleports to a different server on the net.
//
var() string URL;

//-----------------------------------------------------------------------------
// Product the user must have installed in order to enter the teleporter.
var() name ProductRequired;

//-----------------------------------------------------------------------------
// Teleporter destination flags.
var() bool    bChangesVelocity; // Set velocity to TargetVelocity.
var() bool    bChangesYaw;      // Sets yaw to teleporter's Rotation.Yaw
var() bool    bReversesX;       // Reverses X-component of velocity.
var() bool    bReversesY;       // Reverses Y-component of velocity.
var() bool    bReversesZ;       // Reverses Z-component of velocity.

// Teleporter flags
var() bool	  bEnabled;			// Teleporter is turned on;

//-----------------------------------------------------------------------------
// Teleporter destination directions.
var() vector  TargetVelocity;   // If bChangesVelocity, set target's velocity to this.

// AI related
var Actor TriggerActor;		//used to tell AI how to trigger me
var Actor TriggerActor2;

var float LastFired;

//-----------------------------------------------------------------------------
// Teleporter destination functions.

replication
{
	reliable if( Role==ROLE_Authority )
		bEnabled, URL;
	reliable if ( bNetInitial && (Role == ROLE_Authority) )
		bChangesVelocity, bChangesYaw, bReversesX, bReversesY, bReversesZ, TargetVelocity;
}

function PostBeginPlay()
{
	if (URL ~= "")
		SetCollision(false, false, false); //destination only

	if ( !bEnabled )
		FindTriggerActor();
	Super.PostBeginPlay();
}

function FindTriggerActor()
{
	local Actor A;

	TriggerActor = None;
	TriggerActor2 = None;
	ForEach DynamicActors(class 'Actor', A)
		if ( A.Event == Tag)
		{
			if ( A.IsA('Counter') )
				return; //FIXME - handle counters
			if (TriggerActor == None)
				TriggerActor = A;
			else
			{
				TriggerActor2 = A;
				return;
			}
		}
}

// Accept an actor that has teleported in.
simulated function bool Accept( actor Incoming, Actor Source )
{
	local rotator newRot, OldRot;
	local int oldYaw;
	local float mag;
	local vector oldDir;
	local Controller P;

	// Move the actor here.
	Disable('Touch');
	newRot = Incoming.Rotation;
	if (bChangesYaw)
	{
		OldRot = Incoming.Rotation;
		newRot.Yaw = Rotation.Yaw;
		if ( Source != None )
			newRot.Yaw += (32768 + Incoming.Rotation.Yaw - Source.Rotation.Yaw);
	}

	if ( Pawn(Incoming) != None )
	{
		//tell enemies about teleport
		if ( Role == ROLE_Authority )
			For ( P=Level.ControllerList; P!=None; P=P.NextController )
				if (P.Enemy == Incoming)
					P.LastSeenPos = Incoming.Location;

		Pawn(Incoming).SetLocation(Location);
		if ( (Role == ROLE_Authority)
			|| (Level.TimeSeconds - LastFired > 0.5) )
		{
			Pawn(Incoming).SetRotation(newRot);
			Pawn(Incoming).SetViewRotation(newRot);
			LastFired = Level.TimeSeconds;
		}
		if ( Pawn(Incoming).Controller != None )
		{
			Pawn(Incoming).Controller.MoveTimer = -1.0;
			Pawn(Incoming).SetMoveTarget(self);
		}
		Level.Game.PlayTeleportEffect( Incoming, false, true);
	}
	else
	{
		if ( !Incoming.SetLocation(Location) )
		{
			Enable('Touch');
			return false;
		}
		if ( bChangesYaw )
			Incoming.SetRotation(newRot);
	}
	Enable('Touch');


	if (bChangesVelocity)
		Incoming.Velocity = TargetVelocity;
	else
	{
		if ( bChangesYaw )
		{
			if ( Incoming.Physics == PHYS_Walking )
				OldRot.Pitch = 0;
			oldDir = vector(OldRot);
			mag = Incoming.Velocity Dot oldDir;
			Incoming.Velocity = Incoming.Velocity - mag * oldDir + mag * vector(Incoming.Rotation);
		}
		if ( bReversesX )
			Incoming.Velocity.X *= -1.0;
		if ( bReversesY )
			Incoming.Velocity.Y *= -1.0;
		if ( bReversesZ )
			Incoming.Velocity.Z *= -1.0;
	}

	// Play teleport-in effect.

	return true;
}

//-----------------------------------------------------------------------------
// Teleporter functions.

function Trigger( actor Other, pawn EventInstigator )
{
	local Actor A;

	bEnabled = !bEnabled;
	if ( bEnabled ) //teleport any pawns already in my radius
		ForEach TouchingActors(class'Actor', A)
			Touch(A);
}

// Teleporter was touched by an actor.
simulated function Touch( actor Other )
{
	local Teleporter D,Dest[16];
	local int i;

	if ( !bEnabled )
		return;

	if( Other.bCanTeleport && Other.PreTeleport(Self)==false )
	{
		if( (InStr( URL, "/" ) >= 0) || (InStr( URL, "#" ) >= 0) )
		{
			// Teleport to a level on the net.
			if( (Role == ROLE_Authority) && (Pawn(Other) != None)
				&& Pawn(Other).IsHumanControlled() )
				Level.Game.SendPlayer(PlayerController(Pawn(Other).Controller), URL);
		}
		else
		{
			// Teleport to a random teleporter in this local level, if more than one pick random.

			foreach AllActors( class 'Teleporter', D )
				if( string(D.tag)~=URL && D!=Self )
				{
					Dest[i] = D;
					i++;
					if ( i > arraycount(Dest) )
						break;
				}

			i = rand(i);
			if( Dest[i] != None )
			{
				// Teleport the actor into the other teleporter.
				if ( Other.IsA('Pawn') )
					Level.Game.PlayTeleportEffect( Pawn(Other), false, true);
				Dest[i].Accept( Other, self );
				if ( Pawn(Other) != None )
					TriggerEvent(Event, self, Pawn(Other));
			}
		}
	}
}

/* SpecialHandling is called by the navigation code when the next path has been found.
It gives that path an opportunity to modify the result based on any special considerations
*/

function Actor SpecialHandling(Pawn Other)
{
	local int i;
	local vector Dist2D;
	if ( bEnabled && (Teleporter(Other.Controller.RouteCache[1]) != None)
		&& (string(Other.Controller.RouteCache[1].tag)~=URL) )
	{
		if ( Abs(Location.Z - Other.Location.Z) < CollisionHeight + Other.CollisionHeight )
		{
			Dist2D = Location - Other.Location;
			Dist2D.Z = 0;
			if ( VSize(Dist2D) < CollisionRadius + Other.CollisionRadius )
				Touch(Other);
		}
		return self;
	}

	if (TriggerActor == None)
	{
		FindTriggerActor();
		if (TriggerActor == None)
			return None;
	}

	if ( (TriggerActor2 != None)
		&& (VSize(TriggerActor2.Location - Other.Location) < VSize(TriggerActor.Location - Other.Location)) )
		return TriggerActor2;

	return TriggerActor;
}


defaultproperties
{
     bChangesYaw=True
     bEnabled=True
     bCollideActors=True
     RemoteRole=ROLE_SimulatedProxy
     //Texture=Texture'Engine.S_Teleport'
     CollisionRadius=40.000000
     CollisionHeight=80.000000
     bDirectional=True
}
