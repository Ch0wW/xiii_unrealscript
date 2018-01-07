//=============================================================================
// PhysicsVolume:  a bounding volume which affects actor physics
// Each Actor is affected at any time by one PhysicsVolume
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class PhysicsVolume extends Volume
	native
	nativereplication;

var()		bool		bPainCausing;	 // Zone causes pain.
var()		vector		ZoneVelocity;
var()		vector		Gravity;
var()		float		GroundFriction;
var()		float		TerminalVelocity;
var()		float		DamagePerSec;
var() class<DamageType>	DamageType;
var()		int			Priority;	// determines which PhysicsVolume takes precedence if they overlap
var() sound  EntrySound;	//only if waterzone
var() sound  ExitSound;		// only if waterzone
var() class<actor> EntryActor;	// e.g. a splash (only if water zone)
var() class<actor> EntryNonPawnActor;	// e.g. a splash (only if water zone)
var() class<actor> ExitActor;	// e.g. a splash (only if water zone)
var() float  FluidFriction;
var() vector ViewFlash, ViewFog;

var()		bool	bDestructive; // Destroys most actors which enter it.
var()		bool	bNoInventory;
var()		bool	bMoveProjectiles;// this velocity zone should impart velocity to projectiles and effects
var()		bool	bBounceVelocity;	// this velocity zone should bounce actors that land in it
var()		bool	bNeutralZone; // Players can't take damage in this zone.
var			bool	bWaterVolume;
var()		bool	bWaterEffectIsOn; // Activate the water effect.
var()		bool	bSkipWaterRepulsion; // Activate the water effect.
var	Info PainTimer;

// Distance Fog
var(VolumeFog) bool   bDistanceFog;	// There is distance fog in this physicsvolume.
var(VolumeFog) color DistanceFogColor;
var(VolumeFog) float DistanceFogStart;
var(VolumeFog) float DistanceFogEnd;

var()		float WaterEffectIntensity;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( bPainCausing )
		PainTimer = Spawn(class'VolumeTimer', self);
}

event ActorEnteredVolume(Actor Other);
event ActorLeavingVolume(Actor Other);

event PawnEnteredVolume(Pawn Other)
{
	if ( Other.IsPlayerPawn() )
		TriggerEvent(Event,Other, Other);
}

event PawnLeavingVolume(Pawn Other)
{
	if ( Other.IsPlayerPawn() )
		UntriggerEvent(Event,Other, Other);
}

/*
TimerPop
damage touched actors if pain causing.
since PhysicsVolume is static, this function is actually called by a volumetimer
*/
function TimerPop(VolumeTimer T)
{
	local actor A;

	if ( T == PainTimer )
	{
		if ( !bPainCausing )
			return;

		ForEach TouchingActors(class'Actor', A)
			CausePainTo(A);
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	// turn zone damage on and off
	if (DamagePerSec != 0)
	{
		bPainCausing = !bPainCausing;
		if ( bPainCausing && (PainTimer == None) )
			PainTimer = spawn(class'VolumeTimer', self);
	}
}

event touch(Actor Other)
{
//    Log("VOLUME touched "$other);
    Super.Touch(Other);
    if ( bNoInventory && Other.IsA('Inventory') && (Other.Owner == None) )
    {
      Other.LifeSpan = 1.5;
      return;
    }
    if ( bMoveProjectiles && (ZoneVelocity != vect(0,0,0)) )
    {
      if ( Other.Physics == PHYS_Projectile )
        Other.Velocity += ZoneVelocity;
      else if ( Other.IsA('Effects') && (Other.Physics == PHYS_None) )
      {
        Other.SetPhysics(PHYS_Projectile);
        Other.Velocity += ZoneVelocity;
      }
    }
    if ( bPainCausing )
    {
      if ( Other.bDestroyInPainVolume )
      {
        Other.Destroy();
        return;
      }
      CausePainTo(Other);
    }
    if ( bWaterVolume && Other.CanSplash() )
    {
//      Log("Calling PlayEntrySplash EntryActor="$EntryActor);
      PlayEntrySplash(Other);
    }
}

function PlayEntrySplash(Actor Other)
{
    local float SplashSize;
    local actor splash;
    local vector HitLoc, HitNorm;
    local material HitMat;
    local Actor A;

    splashSize = FClamp(0.00003 * Other.Mass * (250 - 0.5 * FMax(-600,Other.Velocity.Z)), 0.1, 1.0 );
    if( EntrySound != None )
    {
      Other.PlaySound(EntrySound, vSize(Other.Velocity));
      if ( Other.Instigator != None )
        MakeNoise(SplashSize);
    }
//    Log("Splash other="$Other@"splashSize="$splashSize);
    if( EntryActor != None )
    {
      A = IntersectWaterPlane( Other.Location + vect(0,0,1)*(10+Other.CollisionHeight), Other.Location - vect(0,0,1)*(10+Other.CollisionHeight), HitLoc );
      if (A == self )
      {
        if ( Pawn(other) != none )
          splash = Spawn(EntryActor,,,HitLoc+vect(0,0,1), Other.rotation);
        else
          splash = Spawn(EntryNonPawnActor,,,HitLoc+vect(0,0,1), Other.rotation);
      }
/*
      ForEach Other.TraceActors(class'Actor', A, HitLoc, HitNorm, Other.Location - vect(0,0,1)*(10+Other.CollisionHeight), Other.Location + vect(0,0,1)*(10+Other.CollisionHeight))
      {
//      A = Other.trace(HitLoc, HitNorm, Other.Location - vect(0,0,1)*(10+Other.CollisionHeight), Other.Location + vect(0,0,1)*(10+Other.CollisionHeight), false, vect(0,0,0), HitMat, 0x008);
//        Log("Trace A="$A);
        if (A == self )
        {
          if ( pawn(other) != none )
          { // ::E3:: MOD, because we don't want splashes on SubMariners when they are generated
            if ( Pawn(Other).IsPlayerPawn() )
              splash = Spawn(EntryActor,,,HitLoc, Other.rotation);
          }
          else
            splash = Spawn(EntryNonPawnActor,,,HitLoc, Other.rotation);
//          Log("Splash spawning at HITLOC");
          break;
        }
*/
/*
        else
        {
          if ( pawn(other) != none )
            splash = Spawn(EntryActor,,,other.Location, Other.rotation);
          else
            splash = Spawn(EntryNonPawnActor,,,other.Location, Other.rotation);
//          Log("Splash spawning at ACTOR LOCATION");
        }
      }
*/
      if ( splash != None )
        splash.SetDrawScale(Other.CollisionRadius / 34);
    }
}

event untouch(Actor Other)
{
	if ( bWaterVolume && Other.CanSplash() )
		PlayExitSplash(Other);
}

function PlayExitSplash(Actor Other)
{
    local float SplashSize;
    local actor splash;
    local vector HitLoc, HitNorm;
    local material HitMat;
    local Actor A;

    splashSize = FClamp(0.003 * Other.Mass, 0.1, 1.0 );
    if( ExitSound != None )
      Other.PlaySound(ExitSound);
    if( ExitActor != None )
    {
      A = IntersectWaterPlane( Other.Location + vect(0,0,1)*(10+Other.CollisionHeight), Other.Location - vect(0,0,1)*(10+Other.CollisionHeight), HitLoc );
      if ( A == self )
        splash = Spawn(ExitActor,,,HitLoc+vect(0,0,1), Other.rotation);
/*
      ForEach Other.TraceActors(class'Actor', A, HitLoc, HitNorm, Other.Location - vect(0,0,1)*(10+Other.CollisionHeight), Other.Location + vect(0,0,1)*(10+Other.CollisionHeight))
      {
      //      A = Other.trace(HitLoc, HitNorm, Other.Location - vect(0,0,100)*(1+Other.CollisionHeight), Other.Location + vect(0,0,100)*(1+Other.CollisionHeight), false, vect(0,0,0), HitMat, 0x008);
      //      Log("Trace A="$A);
        if (A == self )
        {
          splash = Spawn(ExitActor,,,HitLoc, Other.rotation);
      //        Log("ExitSplash spawning at HITLOC");
        }
      }
*/
      if ( splash != None )
        splash.SetDrawScale(splashSize);
    }
}

function CausePainTo(Actor Other)
{
	local float depth;
	local Pawn P;

	// FIXMEZONE figure out depth of actor, and base pain on that!!!
	depth = 1;
	P = Pawn(Other);

	if ( DamagePerSec > 0 )
	{
		if ( (P != None) && (P.Controller != None) )
			P.TakeDamage(int(DamagePerSec * depth), P, Location, vect(0,0,0), DamageType);
		else
		   Other.TakeDamage(int(DamagePerSec * depth), None, Location, vect(0,0,0), DamageType);
	}
	else
	{
		if ( (P != None) && (P.Health < P.Default.Health) )
		P.Health = Min(P.Default.Health, P.Health - depth * DamagePerSec);
	}
}

/* Called when an actor in this PhysicsVolume changes its physics mode */
event PhysicsChangedFor(Actor Other); //FAB


simulated function BeingHitByProjectile(vector HitLocation)
{
}


function Emitter BeingHitByBullets(vector HitLocation, rotator Orientation, int HitSoundType)
{
    return none;
}

defaultproperties
{
     Gravity=(Z=-950.000000)
     GroundFriction=8.000000
     TerminalVelocity=2500.000000
     FluidFriction=0.300000
     WaterEffectIntensity=1.000000
     bAlwaysRelevant=True
}
