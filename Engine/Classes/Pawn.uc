//=============================================================================
// Pawn, the base class of all actors that can be controlled by players or AI.
//
// Pawns are the physical representations of players and creatures in a level.
// Pawns have a mesh, collision, and physics.  Pawns can take damage, make sounds,
// and hold weapons and other inventory.  In short, they are responsible for all
// physical interaction between the player or AI and the world.
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Pawn extends Actor
    abstract
    native
    placeable
    nativereplication;

#exec Texture Import File=Textures\Pawn.pcx Name=S_Pawn Mips=Off MASKED=1 COMPRESS=DXT1

//_____________________________________________________________________________
// Pawn variables.
enum DamageLocations
{
    LOC_Head,
    LOC_Body,
    LOC_HeadSide,
};
enum EGameOver
{
	GO_Never, GO_TakeDamageFromPlayer, GO_KillByPlayer, GO_AnyDeath
};

var Controller Controller;

// Physics related flags.
var bool bJustLanded;           // used by eyeheight adjustment
var bool bUpAndOut;             // used by swimming
var bool bIsWalking;            // currently walking (can't jump, affects animations)
//var bool bWarping;              // Set when travelling through warpzone (so shouldn't telefrag)
var bool bWantsToCrouch;        // if true crouched (physics will automatically reduce collision height to CrouchHeight)
var const bool bIsCrouched;     // set by physics to specify that pawn is currently crouched
var const bool bTryToUncrouch;  // when auto-crouch during movement, continually try to uncrouch
var() bool bCanCrouch;          // if true, this pawn is capable of crouching
var bool bCrawler;              // crawling - pitch and roll based on surface pawn is on
var const bool bReducedSpeed;   // used by movement natives
var bool bCanJump;              // movement capabilities - used by AI
var bool bCanWalk;
var bool bCanSwim;
var bool bCanFly;
var bool bCanClimbLadders;
var bool bCanStrafe;
var bool bAvoidLedges;          // don't get too close to ledges
var bool bStopAtLedges;         // if bAvoidLedges and bStopAtLedges, Pawn doesn't try to walk along the edge at all
//var bool bNoJumpAdjust;         // set to tell controller not to modify velocity of a jump/fall
//var bool bCountJumps;           // if true, inventory wants message whenever this pawn jumps
var const bool bSimulateGravity;// simulate gravity for this pawn on network clients when predicting position (true if pawn is walking or falling)
var bool bUpdateEyeheight;      // if true, UpdateEyeheight will get called every tick
//var bool bIgnoreForces;         // if true, not affected by external forces
var const bool bNoVelocityUpdate; // used by C++ physics
var bool bCanWalkOffLedges;     // Can still fall off ledges, even when walking (for Player Controlled pawns)
//var bool bSteadyFiring;         // used for third person weapon anims/effects
// used by dead pawns (for bodies landing and changing collision box)
var bool bThumped;              // Used when falling/dying
var bool bInvulnerableBody;     // used when dying
var() bool bBoss;               // this is a boss,used to show name & health bar if target
var() bool bCanBeStunned;       // This pawn can be stunned using deco weapons

// AI related flags
var bool bIsFemale;
var bool bAutoActivate;         // if true, automatically activate Powerups which have their bAutoActivate==true
var bool bCanPickupInventory;   // if true, will pickup inventory when touching pickup actors
var bool bUpdatingDisplay;      // to avoid infinite recursion through inventory setdisplay
var bool bAmbientCreature;      // AIs will ignore me
var(AI) bool bLOSHearing;       // can hear sounds from line-of-sight sources (which are close enough to hear)
                                  // bLOSHearing=true is like UT/Unreal hearing
var(AI) bool bSameZoneHearing;        // can hear any sound in same zone (if close enough to hear)
var(AI) bool bAdjacentZoneHearing;    // can hear any sound in adjacent zone (if close enough to hear)
var(AI) bool bMuffledHearing;         // can hear sounds through walls (but muffled - sound distance increased to double plus 4x the distance through walls
var(AI) bool bAroundCornerHearing;    // Hear sounds around one corner (slightly more expensive, and bLOSHearing must also be true)
var(AI) bool bDontPossess;            // if true, Pawn won't be possessed at game start
var bool bIsDead;                     // if true, the pawn is considered as dead

var bool bSpineControl;         // if true and bPhysicsAnimUpdate, then orient upper part of pawn's body in controller direction
var bool bHeadControl;         // if true and bPhysicsAnimUpdate, then orient the Head of the pawn
var bool bSpineYaw;             // enable the Spine Yaw Control ( only if bPhysicsAnimUpdate & bSpineControl )
var bool bHeadYaw;             // enable the Spine Yaw Control ( only if bPhysicsAnimUpdate & bSpineControl )

var bool bHaveOnlyOneHandFree;  // Used to allow selection of 2H weapons (mean LHAnd is Active holding someone)

var bool bPrisonner;              // We have a prisonner in LaftHand to handle slower speed
var bool bDrawBreathtimer;        // For hud to draw timer
var bool bDBAnim;                 // ::DBUG:: Info
var bool bDBShowAutoAim;          // ::DBUG:: Info
var bool bDBCartoon;              // ::DBUG:: Info
var bool bEnTrainTirer;           //[FRD] Allo shooting after dying (last burst)
var bool bEnableSpineControl;     // to allow spine control
var bool bMoving;                 // we are moving
var bool bChangingWeapon;         // used for third person weapon anims/effects
var bool bReloadingWeapon;        // used for third person weapon anims/effects
var bool bWeaponFiring;           // used for third person weapon anims/effects
var bool bJumpImpulse;            // used for playing jump impulsion
var bool bAllowJump;              // to disable jump while holding prisonner
var() bool bDestroyWhenDead;      // i should be destroyed wxhen dead to optimize
var bool bPaf, bIsPafable;        // true if the player is hit by some weapon (Paf(fr) == Hit(En))
var() bool bCanBeGrabbed;         // to allow grab of myself like Corpse/Prisonner
var() bool bCauseEventOnStun;     // to allow event triggering when only stunned & not dead
var() bool bStunnedIfJumpedOn;    // to allow dogs not being stunned by jumping on their head (too easy)

var int BaffeCount, MemBaffeCount;// to play takehit on clients
var float BaffeTimer;             // to reset Baffe(tm) Channel

var int MaxSpineYaw;            // max range of the spine yaw
var int SpineYaw;               // current value of the spine yaw
var float SpineYawRotationSpeed;  // rotation speed in rad/s

var int MaxHeadYaw;            // max range of the spine Head
var int HeadYaw;               // current value of the spine Head
var float HeadYawRotationSpeed;  // rotation speed in rad/s

var float Angle;                // current angle (sin) for the SpineYaw

var byte FlashCount;            // used for third person weapon anims/effects
var byte AltFlashCount;         // used for third person weapon anims/effects
var byte ReloadClientCount;     // used for third person weapon anims/effects

// AI basics.
var byte Visibility;            //How visible is the pawn? 0=invisible, 128=normal, 255=highly visible
var float DesiredSpeed;
var float MaxDesiredSpeed;
//var(AI) name AIScriptTag;       // tag of AIScript which should be associated with this pawn
var(AI) float HearingThreshold; // max distance at which a makenoise(1.0) loudness sound can be heard
var(AI) float Alertness;        // -1 to 1 ->Used within specific states for varying reaction to stimuli
var(AI) float SightRadius;      // Maximum seeing distance.
var(AI) float PeripheralVision; // Cosine of limits of peripheral vision.
var const float AvgPhysicsTime; // Physics updating time monitoring (for AI monitoring reaching destinations)
//var float MeleeRange;           // Max range for melee attack (not including collision radii)
var NavigationPoint Anchor;     // current nearest path;
var const float UncrouchTime;   // when auto-crouch during movement, continually try to uncrouch once this decrements to zero

// Movement.
var float GroundSpeed;          // The maximum ground speed.
var float WaterSpeed;           // The maximum swimming speed.
var float AirSpeed;             // The maximum flying speed.
var float LadderSpeed;          // Ladder climbing speed
var float AccelRate;            // max acceleration rate
var float JumpZ;                // vertical acceleration w/ jump
var float AirControl;           // amount of AirControl available to the pawn
var float WalkingPct;           // pct. of running speed that walking speed is
var float CrouchingPct;         // pct. of running speed (GroundSpeed) that crouching speed is
var float MaxFallSpeed;         // max speed pawn can land without taking damage (also limits what paths AI can use)

// Player info.
//var  string      OwnerName;   // Name of owning player (for save games, coop)
var(Cine_Vars) string PawnName; // ELR to replace string above
var travel Weapon Weapon;       // The pawn's current weapon.
var Weapon PendingWeapon;       // Will become weapon once current weapon is put down
var travel Powerups SelectedItem;  // currently selected inventory item
var float BaseEyeHeight;        // Base eye height above collision center.
var float EyeHeight;            // Current eye height, adjusted for bobbing and stairs.
var const vector Floor;         // Normal of floor pawn is standing on (only used by PHYS_Spider and PHYS_Walking)
var float SplashTime;           // time of last splash
var float CrouchHeight;         // CollisionHeight when crouching
var float CrouchRadius;         // CollisionRadius when crouching
var float OldZ;                 // Old Z Location - used for eyeheight smoothing
var PhysicsVolume HeadVolume;   // physics volume of head
var(BaseSoldier) travel int Health;  // Health: 100 = normal maximum
var  float BreathTime;          // used for getting BreathTimer() messages (for no air, etc.)
var float UnderWaterTime;       // how much time pawn can go without air (in seconds)
var  float LastPainTime;        // last time pawn played a takehit animation (updated in PlayHit())
//var class<DamageType> ReducedDamageType; // which damagetype this creature is protected from (used by AI)

// Sound and noise management
// remember location and position of last noises propagated
var const vector noise1spot;
var const float noise1time;
var const pawn noise1other;
var const float noise1loudness;
var const vector noise2spot;
var const float noise2time;
var const pawn noise2other;
var const float noise2loudness;
var float LastPainSound;

// Common sounds
var sound HitSound[4];
var(Sound) int SoundStepCategory;

//var float SoundDampening;
//var float DamageScaling;

// ::TODO:: delete this
var localized string MenuName; // Name used for this pawn type in menus (e.g. player selection)

// shadow decal
var ShadowProjector Shadow;

// blood effect
/*
var class<Effects> BloodEffect;
var class<Effects> LowDetailBlood;
var class<Effects> LowGoreBlood;
*/

var class<AIController> ControllerClass;  // default class to use when pawn is controlled by AI (can be modified by an AIScript)

var float CarcassCollisionHeight;   // collision height of dead body lying on the ground
var PlayerReplicationInfo PlayerReplicationInfo;

var LadderVolume OnLadder;          // ladder currently being climbed

var name LandMovementState;         // PlayerControllerState to use when moving on land or air
var name WaterMovementState;        // PlayerControllerState to use when moving in water

// Animation status
var name AnimStatus;
var name AnimAction;                // use for replicating anims
var name WeaponAnim;                // Sub-animation to be played on SUBWEAPONCHANNEL
var name WaitWeaponAnim;            // Sub-animation to be played on SUBWEAPONCHANNEL

// Animation updating by physics FIXME - this should be handled as an animation object
// Note that animation channels 2 through 11 are used for animation updating
var vector TakeHitLocation;         // location of last hit (for playing hit/death anims)
var class<DamageType> HitDamageType;  // damage type of last hit (for playing hit/death anims)
var vector TearOffMomentum;         // momentum to apply when torn off (bTearOff == true)
var bool bPhysicsAnimUpdate;        // engine animation update using physics params
var bool bWasCrouched;
var bool bWasWalking;
var bool bWasFalling;
var bool bWasOnGround;
var bool bInitializeAnimation;
var bool bPlayedDeath;
var EPhysics OldPhysics;
var float OldRotYaw;                // used for determining if pawn is turning
var vector OldAcceleration;
var name MovementAnims[4];          // Forward, Left, Back, Right
var name TurnLeftAnim;              // turning left anim
var name TurnRightAnim;             // turning right anim when standing in place (scaled by turn speed)
var float MovementAnimRate[4];      // anim rate scaling for each direction (rate will be blended)
var(AnimTweaks) float BlendChangeTime;  // time to blend between animations
var float MovementBlendStartTime;   // used for delaying the start of run blending

var Actor ControlledActor;          // Actor being controlled by Pawn e.g. KVehicle, WeaponTurret
var byte ControllerPitch;            // used for the net spine control

var Material LastCollidedMaterial;

// ::TO DELETE::
var PowerUps PendingItems;          // NOT USED ANYMORE, NEED TO BE COMMENTED (but full engine rebuild necessary after).

var(Cine_Behavior) EGameOver GameOver;    // Do shooting this guy will make pbs ?
var(Alliances) name Alliance;             // Alliance, used to make diff between factions.
Var(BaseSoldier) int Skill;               // niveau du pawn 1 a 5
var float SpeedFactorLimit;               // speed limit, used in one map only but need this (Plage01 == Beach01)
var travel powerups PendingItem;          // To switch between weapon and items modes.

var float DrownTimer;             // Time underwater
var float DTimerStep;             // Steps for Breathtimer

const FIRINGCHANNEL=14;           // To blend Fire anims
const FIRINGBLENDBONE='X Spine'; // Bone to blend firing anims

var EDrawType DTMemorize;         // Used when taken as a corpse
//var bool bWarnedByDoor;           // For enemies, to memorize that we already have checked an opened door

//var rotator rSpineRotation;       // to be replicated to all clients ?

var name WeaponMode;              // Got by weapon to play right anims

var int CrouchedVisibility;       // Visibility to give a pawn if crouched
var sound hStunFromAboveSound;

var vector MyOldAcceleration;     // Because can't use OldAcceleration != Acceleration (engine modified)

var sound hJumpSound;             // Jump Sound
var sound hHitSound;              // Hit Sound for XIII in solo game, else use Hitsound of the Skin
var sound hLadderSound;           // Climbing sound
var sound hCrouchSound;           // Crouching sound
var sound hUnCrouchSound;         // UnCrouching sound
var sound hBodyFallSound;         // falling body touched ground

var(sound) sound hSNDNotSound[30];    // Sounds for SNDNotif animation events
var sound hSwimmingSound;
var sound hNotifSwimSound;
//var class<DamageType> DiedByDamage;
var sound hBubbleSound;

var bool bRndAnimM16;             // used for the Random Choice For the M16 Firing Animation
var int AnimM16;                  // used for the Random Choice for the M16 Firing Animation
var float HeadShotFactor;         //damage multiplicator for the headshot
var name LastBoneHit;             // Used for Damage location
var TriggerParticleEmitter UnderWaterSFX;
var Emitter DrowningSFX;
var Emitter MyDeathOno; // maybe used by CWndSFX to use same texture.
var Projector MyBloodPool;

var float DeadPawnSightCounter;   // once dead, this is the delay before the pawn signal himself to the other controllers

var travel Armor Vest;            // The pawn's current armor.
var travel Armor Helm;            // The pawn's current Helm.

var() float DelayBeforeDestroyWhenDead;
var() float DistanceBeforeDestroyWhenDead;
var Pawn PawnKiller;

var int SkinID, OldSkinID;        // Used to replicate skins

var const Pawn nextPawn;          // chained Pawn list

//_____________________________________________________________________________
replication
{
    // Variables the server should send to the client.
    reliable if( bNetDirty && (Role==ROLE_Authority) )
      bSimulateGravity, bIsCrouched, bIsWalking, PlayerReplicationInfo, Controller, AnimStatus, AnimAction, HitDamageType, TakeHitLocation ;
    reliable if( bTearOff && bNetDirty && (Role==ROLE_Authority) )
      TearOffMomentum;
//    reliable if ( bNetDirty && !bNetOwner && (Role==ROLE_Authority) )
//      bSteadyFiring;
    reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
      SelectedItem, GroundSpeed, WaterSpeed, AirSpeed, AccelRate, JumpZ, AirControl;

    // replicated functions sent to server by owning client
    reliable if( Role<ROLE_Authority )
      ServerChangedWeapon;

    // Variables the server should send to the client.
    reliable if( bNetDirty && (Role==ROLE_Authority) )
      bIsDead, WeaponMode, SkinID, Health;
    unreliable if( !bNetOwner && bNetDirty && (Role==ROLE_Authority) )
      ControllerPitch, BaffeCount;
}

native final function AddPawnToList();      // Used to handle Level.PawnList
native final function RemovePawnFromList(); // Used to handle Level.PawnList

simulated event ChangeSkin(); // Prototype, will use SkinID

//_____________________________________________________________________________
// reset actor to initial state - used when restarting level without reloading.
function Reset()
{
    if ( (Controller == None) || Controller.bIsPlayer )
      Destroy();
    else
      Super.Reset();
}

//_____________________________________________________________________________
function String GetHumanReadableName()
{
    if ( PlayerReplicationInfo != None )
      return PlayerReplicationInfo.PlayerName;
    return PawnName;
}

//_____________________________________________________________________________
// Pawn is possessed by Controller
function PossessedBy(Controller C)
{
    Controller = C;
    NetPriority = 3;
    if ( C.PlayerReplicationInfo != None )
    {
      PlayerReplicationInfo = C.PlayerReplicationInfo;
      PawnName = PlayerReplicationInfo.PlayerName;
    }
    if ( C.IsA('PlayerController') )
    {
      if ( Level.NetMode != NM_Standalone )
        RemoteRole = ROLE_AutonomousProxy;
      BecomeViewTarget();
    }
    else
      RemoteRole = Default.RemoteRole;

    SetOwner(Controller);	// for network replication
    Eyeheight = BaseEyeHeight;
    ChangeAnimation();
}

//_____________________________________________________________________________
function UnPossessed()
{
    PlayerReplicationInfo = None;
    SetOwner(None);
    Controller = None;
}

//_____________________________________________________________________________
// called by controller when possessing this pawn
// false = 1st person, true = 3rd person
simulated function bool PointOfView()
{
    return false;
}

//_____________________________________________________________________________
function BecomeViewTarget()
{
    bUpdateEyeHeight = true;
}

//_____________________________________________________________________________
function DropToGround()
{
    bCollideWorld = True;
    bInterpolating = false;
    if ( Health > 0 )
    {
      SetCollision(true,true,true);
      SetPhysics(PHYS_Falling);
      AmbientSound = None;
      if ( IsHumanControlled() )
        Controller.GotoState(LandMovementState);
    }
}

//_____________________________________________________________________________
native function SetWalking(bool bNewIsWalking);
/*function SetWalking(bool bNewIsWalking)
{
	if ( bNewIsWalking != bIsWalking )
	{
		bIsWalking = bNewIsWalking;
		ChangeAnimation();
	}
}*/

//_____________________________________________________________________________
function bool CanSplash()
{
    if ( (Level.TimeSeconds - SplashTime > 0.25)
      && ((Physics == PHYS_Falling) || (Physics == PHYS_Flying))
      && (Abs(Velocity.Z) > 100) )
    {
      SplashTime = Level.TimeSeconds;
      return true;
    }
    return false;
}

//_____________________________________________________________________________
event EndClimbLadder(LadderVolume OldLadder)
{
    if (Controller != None)
      Controller.EndClimbLadder();
    if ( Physics == PHYS_Ladder )
      SetPhysics(PHYS_Falling);
}

//_____________________________________________________________________________
function ClimbLadder(LadderVolume L)
{
    OnLadder = L;
    SetPhysics(PHYS_Ladder);
    if ( IsHumanControlled() )
      Controller.GotoState('PlayerClimbing');
}

//_____________________________________________________________________________
// list important actor variable on canvas.  Also show the pawn's controller and weapon info
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,255,255);

	Canvas.DrawText("Animation Action "$AnimAction$" Status "$AnimStatus);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	T = "Floor "$Floor$" DesiredSpeed "$DesiredSpeed$" Crouched "$bIsCrouched$" Try to uncrouch "$UncrouchTime;
	if ( (OnLadder != None) || (Physics == PHYS_Ladder) )
		T=T$" on ladder "$OnLadder;
	Canvas.DrawText(T);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("EyeHeight "$Eyeheight$" BaseEyeHeight "$BaseEyeHeight$" Physics Anim "$bPhysicsAnimUpdate);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,0,0);

	if ( Controller == None )
	{
		Canvas.DrawText("NO CONTROLLER");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
		Controller.DisplayDebug(Canvas,YL,YPos);

	Canvas.SetDrawColor(0,255,0);

	if ( Weapon == None )
	{
		Canvas.DrawText("NO WEAPON");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
	{
		Canvas.DrawText("WEAPON ::");
		YPos += YL;
		Canvas.SetPos(4,YPos);
		Weapon.DisplayDebug(Canvas,YL,YPos);
	}

	Canvas.SetDrawColor(0,255,255);
	if ( PendingWeapon == None )
	{
		Canvas.DrawText("NO PENDINGWEAPON");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
	{
		Canvas.DrawText("PENDINGWEAPON ::");
		YPos += YL;
		Canvas.SetPos(4,YPos);
		PendingWeapon.DisplayDebug(Canvas,YL,YPos);
	}

	Canvas.SetDrawColor(0,255,0);
	if ( SelectedItem == None )
	{
		Canvas.DrawText("NO ITEM");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
	{
		Canvas.DrawText("ITEM ::");
		YPos += YL;
		Canvas.SetPos(4,YPos);
		SelectedItem.DisplayDebug(Canvas,YL,YPos);
	}

	Canvas.SetDrawColor(0,255,255);
	if ( PendingItem == None )
	{
		Canvas.DrawText("NO PENDINGITEM");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
	{
		Canvas.DrawText("PENDINGITEM ::");
		YPos += YL;
		Canvas.SetPos(4,YPos);
		PendingItem.DisplayDebug(Canvas,YL,YPos);
	}
}

//_____________________________________________________________________________
// Compute offset for drawing an inventory item.
native simulated function vector CalcDrawOffset(inventory Inv);
/*simulated function vector CalcDrawOffset(inventory Inv)
{
	local vector DrawOffset;

	if ( Controller == None )
		return (Inv.PlayerViewOffset >> Rotation) + BaseEyeHeight * vect(0,0,1);

	DrawOffset = ((0.9/Controller.FOVAngle * 100 * Inv.PlayerViewOffset) >> GetViewRotation() );
	if ( !IsLocallyControlled() )
		DrawOffset.Z += BaseEyeHeight;
	else
	{
		DrawOffset.Z += EyeHeight;
		DrawOffset += Controller.WeaponBob(Inv.BobDamping);
	}
	return DrawOffset;
}*/


//***************************************
// Interface to Pawn's Controller

//_____________________________________________________________________________
// return true if controlled by a Player (AI or human)
/*simulated function bool IsPlayerPawn()
{
	return ( (Controller != None) && Controller.bIsPlayer );
}*/
native simulated function bool IsPlayerPawn();

//_____________________________________________________________________________
// return true if controlled by a real live human
/*simulated function bool IsHumanControlled()
{
	return ( PlayerController(Controller) != None );
}*/
native simulated function bool IsHumanControlled();

//_____________________________________________________________________________
// return true if controlled by local (not network) player
/*simulated function bool IsLocallyControlled()
{
	if ( Level.NetMode == NM_Standalone )
		return true;
	if ( Controller == None )
		return false;
	if ( PlayerController(Controller) == None )
		return true;

	return ( Viewport(PlayerController(Controller).Player) != None );
}*/
native simulated function bool IsLocallyControlled();

//_____________________________________________________________________________
/*simulated function rotator GetViewRotation()
{
	if ( Controller == None )
		return Rotation;
	else
		return Controller.Rotation;
}*/
native simulated function rotator GetViewRotation();

//_____________________________________________________________________________
simulated function SetViewRotation(rotator NewRotation )
{
    if ( Controller != None )
      Controller.SetRotation(NewRotation);
}

//_____________________________________________________________________________
final function bool InGodMode()
{
	return ( (Controller != None) && Controller.bGodMode );
}

//_____________________________________________________________________________
simulated function bool CanHoldDualWeapons()
{
    return false;
}

/* XIIIUNUSED
//_____________________________________________________________________________
function bool NearMoveTarget()
{
    if ( (Controller == None) || (Controller.MoveTarget == None) )
      return false;
    return NearSpot(Controller.MoveTarget.Location);
}
*/

//_____________________________________________________________________________
/*simulated final function bool PressingFire()
{
	return ( (Controller != None) && (Controller.bFire != 0) );
}*/
native simulated final function bool PressingFire();

//_____________________________________________________________________________
native function SpineYawControl(bool IsControlled,int MaxValue, float RotationSpeed);
native function HeadYawControl(bool IsControlled,int MaxValue, float RotationSpeed);

//_____________________________________________________________________________
simulated final function bool PressingAltFire()
{
	return ( (Controller != None) && (Controller.bAltFire != 0) );
}

/* XIIIUNUSED
function Actor GetMoveTarget()
{
    if ( Controller == None )
      return None;

    return Controller.MoveTarget;
}
*/

//_____________________________________________________________________________
function SetMoveTarget(Actor NewTarget )
{
    if ( Controller != None )
      Controller.MoveTarget = NewTarget;
}

//_____________________________________________________________________________
function bool LineOfSightTo(actor Other)
{
    return ( (Controller != None) && Controller.LineOfSightTo(Other) );
}

//_____________________________________________________________________________
simulated final function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
    if ( Controller == None )
      return Rotation;
    return Controller.AdjustAim(FiredAmmunition, projStart, aimerror);
}

//_____________________________________________________________________________
function Actor ShootSpecial(Actor A)
{
    if ( !Controller.bCanDoSpecial || (Weapon == None) )
      return None;

    Controller.FireWeaponAt(A);
    Controller.bFire = 0;
    return A;
}

//_____________________________________________________________________________
function HandlePickup(Pickup pick)
{
    if ( Controller != None )
      Controller.HandlePickup(pick);
}

//_____________________________________________________________________________
function ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
    if ( PlayerController(Controller) != None )
      PlayerController(Controller).ReceiveLocalizedMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

//_____________________________________________________________________________
event ClientMessage( coerce string S, optional Name Type )
{
    if ( PlayerController(Controller) != None )
      PlayerController(Controller).ClientMessage( S, Type );
}

//_____________________________________________________________________________
function Trigger( actor Other, pawn EventInstigator )
{
    if ( Controller != None )
      Controller.Trigger(Other, EventInstigator);
}

//_____________________________________________________________________________
function GiveWeapon(string aClassName )
{
    local class<Weapon> WeaponClass;
    local Weapon NewWeapon;

    if ( aClassName == "" )
      return;
    WeaponClass = class<Weapon>(DynamicLoadObject(aClassName, class'Class'));

    if( FindInventoryType(WeaponClass) != None )
      return;
    newWeapon = Spawn(WeaponClass);
    if( newWeapon != None )
      newWeapon.GiveTo(self);
}

//_____________________________________________________________________________
function SetDisplayProperties(ERenderStyle NewStyle, Material NewTexture, bool bLighting )
{
    Style = NewStyle;
    Texture = NewTexture;
    bUnlit = bLighting;
    if ( Weapon != None )
      Weapon.SetDisplayProperties(Style, Texture, bUnlit);

    if ( !bUpdatingDisplay && (Inventory != None) )
    {
      bUpdatingDisplay = true;
      Inventory.SetOwnerDisplay();
    }
    bUpdatingDisplay = false;
}

//_____________________________________________________________________________
function SetDefaultDisplayProperties()
{
    Style = Default.Style;
    texture = Default.Texture;
    bUnlit = Default.bUnlit;
    if ( Weapon != None )
      Weapon.SetDefaultDisplayProperties();

    if ( !bUpdatingDisplay && (Inventory != None) )
    {
      bUpdatingDisplay = true;
      Inventory.SetOwnerDisplay();
    }
    bUpdatingDisplay = false;
}

//_____________________________________________________________________________
function FinishedInterpolation(InterpolationPoint Other)
{
    DropToGround();
}

//_____________________________________________________________________________
function JumpOutOfWater(vector jumpDir)
{
    Falling();
    Velocity = jumpDir * WaterSpeed;
    Acceleration = jumpDir * AccelRate;
    velocity.Z = FMax(380,JumpZ); //set here so physics uses this for remainder of tick
    bUpAndOut = true;
}

//_____________________________________________________________________________
event FellOutOfWorld()
{
    if ( Role < ROLE_Authority )
      return;
    Health = -1;
    SetPhysics(PHYS_None);
    Weapon = None;
    Died(None, class'Gibbed', Location);
}

//_____________________________________________________________________________
// Controller is requesting that pawn crouch
function ShouldCrouch(bool Crouch)
{
	bWantsToCrouch = Crouch;
}


//_____________________________________________________________________________
event EndCrouch(float HeightAdjust)
{
    if ( bDBAnim )
      Log("@@@ EndCrouch call for "$self);

    EyeHeight -= HeightAdjust;
    OldZ += HeightAdjust;
    BaseEyeHeight = Default.BaseEyeHeight;
    Visibility = default.Visibility;
    if ( IsPlayerPawn() )
      PlaySound(hUnCrouchSound);
    if ( !bIsDead )
    {
      PlayWaiting();
      PlayMoving();
    }
}

//_____________________________________________________________________________
event StartCrouch(float HeightAdjust)
{
   if ( bDBAnim )
      Log("@@@ StartCrouch call for "$self);

    EyeHeight += HeightAdjust;
    OldZ -= HeightAdjust;
    BaseEyeHeight = 0.8 * CrouchHeight;
    if (Physics == PHYS_Walking)
      Visibility = CrouchedVisibility;
    if ( IsPlayerPawn() )
      PlaySound(hCrouchSound);
    if ( !bIsDead )
    {
      PlayWaiting();
      PlayMoving();
    }
}

//_____________________________________________________________________________
function RestartPlayer();

//_____________________________________________________________________________
function AddVelocity( vector NewVelocity)
{
    if ( (Physics == PHYS_Walking)
      || (((Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) && (NewVelocity.Z > Default.JumpZ)) )
      SetPhysics(PHYS_Falling);
    if ( (Velocity.Z > 380) && (NewVelocity.Z > 0) )
      NewVelocity.Z *= 0.5;
    Velocity += NewVelocity;
}

//_____________________________________________________________________________
function KilledBy( pawn EventInstigator )
{
    local Controller Killer;

    Health = 0;
    if ( EventInstigator != None )
      Killer = EventInstigator.Controller;
    Died( Killer, class'Suicided', Location );
}

function TakeFallingDamage()
{
	local float Shake;

	if (Velocity.Z < -0.5 * MaxFallSpeed)
	{
		MakeNoise(FMin(2.0,-0.5 * Velocity.Z/(FMax(JumpZ, 150.0))));
		if (Velocity.Z < -1 * MaxFallSpeed)
		{
			if ( Role == ROLE_Authority )
				TakeDamage(-100 * (Velocity.Z + MaxFallSpeed)/MaxFallSpeed, None, Location, vect(0,0,0), class'Fell');
		}
		if ( Controller != None )
		{
			Shake = FMin(1, -1 * Velocity.Z/MaxFallSpeed);
			Controller.ShakeView(0.175 + 0.1 * Shake, 850 * Shake, Shake * vect(0,0,1.5), 120000, vect(0,0,10), 1);
		}
	}
}

function ClientReStart()
{
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	BaseEyeHeight = Default.BaseEyeHeight;
	EyeHeight = BaseEyeHeight;
	PlayWaiting();
}

function ClientSetLocation( vector NewLocation, rotator NewRotation )
{
	if ( Controller != None )
		Controller.ClientSetLocation(NewLocation, NewRotation);
}

function ClientSetRotation( rotator NewRotation )
{
	if ( Controller != None )
		Controller.ClientSetRotation(NewRotation);
}

/*simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
	if ( Physics == PHYS_Ladder )
		SetRotation(OnLadder.WallDir);
	else
	{
		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
			NewRotation.Pitch = 0;
		SetRotation(NewRotation);
	}
}*/
native simulated function FaceRotation( rotator NewRotation, float DeltaTime );


function ClientDying(class<DamageType> DamageType, vector HitLocation)
{
	if ( Controller != None )
		Controller.ClientDying(DamageType, HitLocation);
}

//=============================================================================
// Inventory related functions.

// toss out the weapon currently held
function TossWeapon(vector TossVel)
{
    local vector X,Y,Z;

    Weapon.velocity = TossVel;
    GetAxes(Rotation,X,Y,Z);
    if ( Level.bLonePlayer && (Weapon.default.ReloadCount != 0) )
    {
      if ( Weapon.AmmoType != none )
      {
        Weapon.AmmoType.Velocity = TossVel*1.1 + vRand()*0.2*vSize(TossVel);
        Weapon.AmmoType.AmmoAmount -= Weapon.ReloadCount;
        if ( Weapon.AmmoType.AmmoAmount > 0 )
        {
          Weapon.AmmoType.DropFrom(Location);
          Weapon.AmmoType = none;
        }
        else
        {
          DeleteInventory(Weapon.AmmoType);
          Weapon.AmmoType = none;
        }
      }
/*
      if ( Weapon.AltAmmoType != none )
      {
        Weapon.AltAmmoType.Velocity = TossVel + vRand()*0.2*vSize(TossVel);
        Weapon.AltAmmoType.DropFrom(Location);
        Weapon.AltAmmoType = none;
      }
*/
    }
    debuglog("DROP weapon reloadcount="$Weapon.ReloadCount);
    Weapon.DropFrom(Location);
}

// The player/bot wants to select next item
exec function NextItem()
{
	local Inventory Inv;

	if (SelectedItem==None) {
		SelectedItem = Inventory.SelectNext();
		Return;
	}
	if (SelectedItem.Inventory!=None)
		SelectedItem = SelectedItem.Inventory.SelectNext();
	else
		SelectedItem = Inventory.SelectNext();

	if ( SelectedItem == None )
		SelectedItem = Inventory.SelectNext();
}

// FindInventoryType()
// returns the inventory item of the requested class
// if it exists in this pawn's inventory
/*
function Inventory FindInventoryType( class DesiredClass )
{
	local Inventory Inv;

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Inv.class == DesiredClass )
			return Inv;
	return None;
} */
native function Inventory FindInventoryType( class DesiredClass );
native function Inventory FindInventoryKind( Name DesiredClassName );

// Add Item to this pawn's inventory.
// Returns true if successfully added, false if not.
function bool AddInventory( inventory NewItem )
{
	// Skip if already in the inventory.
	local inventory Inv;
	local actor Last;

	Last = self;

	// The item should not have been destroyed if we get here.
	if (NewItem ==None )
		log("tried to add none inventory to "$self);

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if( Inv == NewItem )
			return false;
		Last = Inv;
	}

	// Add to back of inventory chain (so minimizes net replication effect).
	NewItem.SetOwner(Self);
	NewItem.Inventory = None;
	Last.Inventory = NewItem;

	if ( Controller != None )
		Controller.NotifyAddInventory(NewItem);
	return true;
}

// Remove Item from this pawn's inventory, if it exists.
simulated function DeleteInventory( inventory Item )
{
	// If this item is in our inventory chain, unlink it.
	local actor Link;

	if ( Item == Weapon )
		Weapon = None;
	if ( Item == SelectedItem )
		SelectedItem = None;
	for( Link = Self; Link!=None; Link=Link.Inventory )
	{
		if( Link.Inventory == Item )
		{
			Link.Inventory = Item.Inventory;
			Item.Inventory = none;
			break;
		}
	}
	Item.SetOwner(None);
}


//_____________________________________________________________________________
// insert/move Item to this pawn's inventory after RefItem
// Returns true if successfully added, false if not.
function bool InsertInventory( inventory NewItem , inventory RefItem)
{
    // Skip if already in the inventory.
    local inventory Inv;

//    Log("InsertInventory"@NewItem@"after"@RefItem@"(whos inv="$RefItem.Inventory);

    // The item should not have been destroyed if we get here.
    if (NewItem == None )
    {
      Warn("tried to add none inventory to "$self);
      return false;
    }
    else if ( NewItem == RefItem )
    {
      Warn("tried to InsertInventory "$RefItem$" after same");
      return false;
    }

//    for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
//    {
//      if( Inv == NewItem )
//      { // be sure we remove from own inventory, function can be used to move some inventory
//        // (moving ammo after weapon to make saves ok)
        DeleteInventory(NewItem);
//      }
//    }

    // Add to back of inventory chain (so minimizes net replication effect).
    NewItem.SetOwner(Self);
    NewItem.Inventory = RefItem.Inventory;
    RefItem.Inventory = NewItem;

    if ( Controller != None )
      Controller.NotifyAddInventory(NewItem);
    return true;
}

// Just changed to pendingWeapon
function ChangedWeapon();
/*
{
	local Weapon OldWeapon;

	OldWeapon = Weapon;

	if (Weapon == PendingWeapon)
	{
		if ( Weapon == None )
		{
			Controller.SwitchToBestWeapon();
			return;
		}
		else if ( Weapon.IsInState('DownWeapon') )
			Weapon.GotoState('Idle');
		PendingWeapon = None;
		ServerChangedWeapon(OldWeapon, Weapon);
		return;
	}
	if ( PendingWeapon == None )
		PendingWeapon = Weapon;

	Weapon = PendingWeapon;
	if ( (Weapon != None) && (Level.NetMode == NM_Client) )
		Weapon.BringUp();
	PendingWeapon = None;
	Weapon.Instigator = self;
	ServerChangedWeapon(OldWeapon, Weapon);
	if ( Controller != None )
		Controller.ChangedWeapon();
}
*/

function name GetWeaponBoneFor(Inventory I)
{
	return 'righthand';
}

function ServerChangedWeapon(Weapon OldWeapon, Weapon W)
{
	if ( OldWeapon != None )
	{
		OldWeapon.SetDefaultDisplayProperties();
		OldWeapon.DetachFromPawn(self);
	}
	Weapon = W;
	if ( Weapon == None )
		return;

	if ( Weapon != None )
	{
		//log("ServerChangedWeapon: Attaching Weapon to actor bone.");
		Weapon.AttachToPawn(self);
	}

	Weapon.SetRelativeLocation(Weapon.Default.RelativeLocation);
	Weapon.SetRelativeRotation(Weapon.Default.RelativeRotation);
	if ( OldWeapon == Weapon )
	{
		if ( Weapon.IsInState('DownWeapon') )
			Weapon.BringUp();
//		Inventory.OwnerEvent('ChangedWeapon'); // tell inventory that weapon changed (in case any effect was being applied)
		return;
	}
	else if ( Level.Game != None )
		MakeNoise(0.1 * Level.Game.Difficulty);
//	Inventory.OwnerEvent('ChangedWeapon'); // tell inventory that weapon changed (in case any effect was being applied)

	PlayWeaponSwitch(W);
	Weapon.BringUp();
}

//==============
// Encroachment
event bool EncroachingOn( actor Other )
{
	if ( (Other.Brush != None) || (Brush(Other) != None) )
		return true;

	if ( ((Controller == None) || !Controller.bIsPlayer) && (Pawn(Other) != None) )
		return true;

	return false;
}

event EncroachedBy( actor Other )
{
	if ( Pawn(Other) != None )
		gibbedBy(Other);
}

function gibbedBy(actor Other)
{
	local Controller Killer;

	if ( Role < ROLE_Authority )
		return;
	if ( Pawn(Other) != None )
		Killer = Pawn(Other).Controller;
	Died(Killer, class'Gibbed', Location);
}

//Base change - if new base is pawn or decoration, damage based on relative mass and old velocity
// Also, non-players will jump off pawns immediately
function JumpOffPawn()
{
	Velocity += (100 + CollisionRadius) * VRand();
	Velocity.Z = 200 + CollisionHeight;
	SetPhysics(PHYS_Falling);
	Controller.SetFall();
}

singular event BaseChange()
{
	local float decorMass;

	if ( bInterpolating )
		return;
	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	else if ( Pawn(Base) != None )
	{
		Base.TakeDamage( (1-Velocity.Z/400)* Mass/Base.Mass, Self,Location,0.5 * Velocity , class'Crushed');
		JumpOffPawn();
	}
	else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
	{
		decorMass = FMax(Decoration(Base).Mass, 1);
		Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, class'Crushed');
	}
}

//_____________________________________________________________________________
event UpdateEyeHeight( float DeltaTime )
{
    local float smooth;
    local float OldEyeHeight;

    if (Controller == None )
    {
      EyeHeight = 0;
      return;
    }

    // smooth up/down stairs
    smooth = FMin(1.0, 7.0 * DeltaTime/Level.TimeDilation);
    If( Controller.WantsSmoothedView() )
    {
//      Log("UpdateEyeHeigth Smooth call for "$self$" smooth="$smooth);
      OldEyeHeight = EyeHeight;
      EyeHeight = OldEyeHeight * (1 - smooth) + BaseEyeHeight * smooth;
    }
    else
    {
//      Log("UpdateEyeHeigth NOT Smooth call for "$self);
      bJustLanded = false;
      EyeHeight = EyeHeight * ( 1 - smooth ) + BaseEyeHeight * smooth;
    }
    Controller.AdjustView(DeltaTime);
}

/* EyePosition()
Called by PlayerController to determine camera position in first person view.  Returns
the offset from the Pawn's location at which to place the camera
*/
/*
function vector EyePosition()
{
	return EyeHeight * vect(0,0,1);
}
*/
native function vector EyePosition();

//=============================================================================

simulated event Destroyed()
{
    local Inventory I, Inv,Next;

    Log("PAWN DESTROY"@self);
    if ( Shadow != None )
      Shadow.Destroy();
    if ( Controller != None )
      Controller.PawnDied();
    RemovePawnFromList();

    if ( Role < ROLE_Authority )
      return;

/*
    Log("BEFDESTROY -- Begin Inventory List");
    I=Inventory;
    while ( I != none )
    {
      if ( Ammunition(I) != none )
        log("   Inv="$I$" Ammo="$Ammunition(I).AmmoAmount);
      else if ( I.Isa('PowerUps') )
        log("   Inv="$I$" charges="$PowerUps(I).Charge);
      else if ( I.Isa('Armor') )
        log("   Inv="$I$" charges="$Armor(I).Charge);
      else if ( Weapon(I) != none )
        log("   Inv="$I@" Ammo="$Weapon(I).AmmoType@"AltAmmo="$Weapon(I).AltAmmoType);
      else
        log("   Inv="$I);

      I=I.Inventory;
    }
    log(" -- End Inventory List");
*/

/*
    while (Inventory != none)
    { // we want to be sure ALL the inventory is destroyed
      //		Log("  Should destroy inventory"@Inventory);
      if ( Inventory.bDeleteMe )
        Inventory = Inventory.Inventory;
      //DeleteInventory(Inventory);
      Inventory.Destroy();
    }
*/
    Inv = Inventory;
    while ( Inv != None )
    {
      Next = Inv.Inventory;
//      Log("  Should destroy inventory"@Inv);
      Inv.bTossedOut = true; // this is to prevent destroying ammo for weapons thsu making Next unavailable.
      Inv.Destroy();
      Inv = Next;
    }
    Weapon = None;
    Inventory = None;
//    Super.Destroyed();
}

//=============================================================================
//
// Called immediately before gameplay begins.
//
simulated event PreBeginPlay()
{
	Super.PreBeginPlay();
	Instigator = self;
	DesiredRotation = Rotation;
	if ( bDeleteMe )
		return;

  AddPawnToList();
	PreSetMovement();
	if ( DrawScale != Default.Drawscale )
	{
		SetCollisionSize(CollisionRadius*DrawScale/Default.DrawScale, CollisionHeight*DrawScale/Default.DrawScale);
		Health = Health * DrawScale/Default.DrawScale;
	}

	if ( BaseEyeHeight == 0 )
		BaseEyeHeight = 0.8 * CollisionHeight;
	EyeHeight = BaseEyeHeight;

//	if ( menuname == "" )
//		menuname = GetItemName(string(class));
}

simulated event PostBeginPlay()
{
	local AIScript A;

	if ( bActorShadows && (Shadow==None) )
	{
		Shadow = Spawn(class'ShadowProjector',Self,'',Location);
	}

	Super.PostBeginPlay();
	SplashTime = 0;
	EyeHeight = BaseEyeHeight;
	OldRotYaw = Rotation.Yaw;

	// automatically add controller to pawns which were placed in level
	// NOTE: pawns spawned during gameplay are not automatically possessed by a controller
	if ( Level.bStartup && (Health > 0) && !bDontPossess )
	{
		// check if I have an AI Script
/*
		if ( (AIScriptTag != 'None') && (AIScriptTag != '') )
		{
			ForEach AllActors(class'AIScript',A,AIScriptTag)
				break;
			// let the AIScript spawn and init my controller
			if ( A != None )
			{
				A.SpawnControllerFor(self);
				if ( Controller != None )
					return;
			}
		}
*/
		if ( (ControllerClass != None) && (Controller == None) )
			Controller = spawn(ControllerClass);
		if ( Controller != None )
			Controller.Possess(self);
	}
}

// called after PostBeginPlay on net client
simulated event PostNetBeginPlay()
{
	if ( Role == ROLE_Authority )
		return;
	if ( Controller != None )
	{
		Controller.Pawn = self;
		bUpdateEyeHeight = true;
	}

	if ( (PlayerReplicationInfo != None)
		&& (PlayerReplicationInfo.Owner == None) )
		PlayerReplicationInfo.SetOwner(Controller);
	PlayWaiting();
}

/* PreSetMovement()
default for walking creature.  Re-implement in subclass
for swimming/flying capability
*/
function PreSetMovement()
{
	if (JumpZ > 0)
		bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = false;
}

simulated function SetMesh()
{
	mesh = default.mesh;
}

function Gasp();
function SetMovementPhysics();

//_____________________________________________________________________________
// ELR
function float HealthPercent()
{
    return (100.0 * Health / Default.Health);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local Controller Killer;

	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

	Health -= actualDamage;
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if ( bAlreadyDead )
	{
		Warn(self$" took regular damage "$damagetype$" from "$instigatedby$" while already dead at "$Level.TimeSeconds);
		ChunkUp(-1 * Health);
		return;
	}

	PlayHit(actualDamage, hitLocation, damageType, Momentum);
	if ( Health <= 0 )
	{
		// pawn died
		if ( instigatedBy != None )
			Killer = instigatedBy.Controller; //FIXME what if killer died before killing you
		if ( bPhysicsAnimUpdate )
			TearOffMomentum = momentum;
		Died(Killer, damageType, HitLocation);
	}
	else
	{
		AddVelocity( momentum );
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
	}
	MakeNoise(1.0);
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if ( bDeleteMe )
		return; //already destroyed

	// mutator hook to prevent deaths
	// WARNING - don't prevent bot suicides - they suicide when really needed
	if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}
	Health = Min(0, Health);
	Level.Game.Killed(Killer, Controller, self, damageType);

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	Velocity.Z *= 1.3;
	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();
	if ( (DamageType != None) && (DamageType.default.GibModifier >= 100) )
		ChunkUp(-1 * Health);
	else
	{
		PlayDying(DamageType, HitLocation);
		if ( Level.Game.bGameEnded )
			return;
		if ( !bPhysicsAnimUpdate && !IsLocallyControlled() )
			ClientDying(DamageType, HitLocation);
	}
}

function YouCantClimb(); // used to send message on-screen.

function bool Gibbed(class<DamageType> damageType)
{
	if ( damageType.default.GibModifier == 0 )
		return false;
	if ( damageType.default.GibModifier >= 100 )
		return true;
	if ( (Health < -80) || ((Health < -40) && (FRand() < 0.6)) )
		return true;
	return false;
}

event Falling()
{
	//SetPhysics(PHYS_Falling); //Note - physics changes type to PHYS_Falling by default
	if ( Controller != None )
		Controller.SetFall();
}

event HitWall(vector HitNormal, actor Wall);

event Landed(vector HitNormal)
{
	TakeFallingDamage();
	if ( Health > 0 )
		PlayLanded(Velocity.Z);
	if (Velocity.Z < -1.4 * JumpZ)
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
	bJustLanded = true;
}

event HeadVolumeChange(PhysicsVolume newHeadVolume)
{
	if ( (Level.NetMode == NM_Client) || (Controller == None) )
		return;
	if ( HeadVolume.bWaterVolume )
	{
		if (!newHeadVolume.bWaterVolume)
		{
			if ( Controller.bIsPlayer && (BreathTime > 0) && (BreathTime < 8) )
				Gasp();
			BreathTime = -1.0;
		}
	}
	else if ( newHeadVolume.bWaterVolume )
		BreathTime = UnderWaterTime;
}

function bool TouchingWaterVolume()
{
	local PhysicsVolume V;

	ForEach TouchingActors(class'PhysicsVolume',V)
		if ( V.bWaterVolume )
			return true;

	return false;
}

//Pain timer just expired.
//Check what zone I'm in (and which parts are)
//based on that cause damage, and reset BreathTime

function bool IsInPain()
{
	local PhysicsVolume V;

	ForEach TouchingActors(class'PhysicsVolume',V)
		if ( V.bPainCausing && (V.DamagePerSec > 0) )
			return true;
	return false;
}

event BreathTimer()
{
	if ( (Health < 0) || (Level.NetMode == NM_Client) )
		return;
	TakeDrowningDamage();
	if ( Health > 0 )
		BreathTime = 2.0;
}

function TakeDrowningDamage();

function bool CheckWaterJump(out vector WallNormal)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, checkpoint, start, checkNorm, Extent;

	checkpoint = vector(Rotation);
	checkpoint.Z = 0.0;
	checkNorm = Normal(checkpoint);
	checkPoint = Location + CollisionRadius * checkNorm;
	Extent = CollisionRadius * vect(1,1,0);
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, true, Extent);
	if ( (HitActor != None) && (Pawn(HitActor) == None) )
	{
		WallNormal = -1 * HitNormal;
		start = Location;
		start.Z += 1.1 * MAXSTEPHEIGHT;
		checkPoint = start + 2 * CollisionRadius * checkNorm;
		HitActor = Trace(HitLocation, HitNormal, checkpoint, start, true);
		if (HitActor == None)
			return true;
	}

	return false;
}

//Player Jumped
function DoJump( bool bUpdating )
{
	if ( !bIsCrouched && !bWantsToCrouch && ((Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) )
	{
		if ( Role == ROLE_Authority )
		{
			if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
				MakeNoise(0.1 * Level.Game.Difficulty);
//			if ( bCountJumps && (Inventory != None) )
//				Inventory.OwnerEvent('Jumped');
		}
		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = JumpZ;
		if ( (Base != None) && !Base.bWorldGeometry )
			Velocity.Z += Base.Velocity.Z;
		SetPhysics(PHYS_Falling);
	}
}

function PlayHit(float Damage, vector HitLocation, class<DamageType> damageType, vector Momentum);
/*
{
	local vector BloodOffset, Mo;
	local class<Effects> DesiredEffect;

	if ( (Damage <= 0) && !Controller.bGodMode )
		return;
	if (Damage > 1) //spawn some blood
	{
		DesiredEffect = DamageType.static.GetPawnDamageEffect(HitLocation, Damage, Momentum, self, (Level.bDropDetail || !Level.bHighDetailMode));

		if ( DesiredEffect != None )
		{
			BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
			BloodOffset.Z = BloodOffset.Z * 0.5;

			Mo = Momentum;
			if ( Mo.Z > 0 )
				Mo.Z *= 0.5;

			spawn(DesiredEffect,self,,HitLocation + BloodOffset, rotator(Mo));
		}
	}
	if ( Health <= 0 )
	{
		if ( PhysicsVolume.bDestructive && (PhysicsVolume.ExitActor != None) )
			Spawn(PhysicsVolume.ExitActor);
		return;
	}
	if ( Level.TimeSeconds - LastPainTime > 0.1 )
	{
		PlayTakeHit(HitLocation,Damage,damageType);
		LastPainTime = Level.TimeSeconds;
	}
}
*/

/*
Pawn was killed - detach any controller, and die
*/

// blow up into little pieces (implemented in subclass)
simulated function ChunkUp(int Damage)
{
	if ( Controller != None )
	{
		if ( Controller.bIsPlayer )
			Controller.PawnDied();
		else
			Controller.Destroy();
	}
	destroy();
}

State Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, name FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}

	function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
	{
	}

	function Timer()
	{
		if ( !PlayerCanSeeMe() )
			Destroy();
		else
			SetTimer(2.0, false);
	}

	function Landed(vector HitNormal)
	{
		local rotator finalRot;
		local float OldHeight;

		if( Velocity.Z < -500 )
			TakeDamage( (1-Velocity.Z/30),Instigator,Location,vect(0,0,0) , class'Crushed');

		finalRot = Rotation;
		finalRot.Roll = 0;
		finalRot.Pitch = 0;
		setRotation(finalRot);
		SetPhysics(PHYS_None);
		SetCollision(true, false, false);

		if ( !IsAnimating(0) )
			LieStill();
	}

	// prone body should have low height, wider radius
	function ReduceCylinder()
	{
		local float OldHeight, OldRadius;
		local vector OldLocation;

		SetCollision(True,False,False);
		OldHeight = CollisionHeight;
		OldRadius = CollisionRadius;
		SetCollisionSize(1.5 * Default.CollisionRadius, CarcassCollisionHeight);
		PrePivot = vect(0,0,1) * (OldHeight - CollisionHeight); // FIXME - changing prepivot isn't safe w/ static meshes
		OldLocation = Location;
		if ( !SetLocation(OldLocation - PrePivot) )
		{
			SetCollisionSize(OldRadius, CollisionHeight);
			if ( !SetLocation(OldLocation - PrePivot) )
			{
				SetCollisionSize(CollisionRadius, OldHeight);
				SetCollision(false, false, false);
				PrePivot = vect(0,0,0);
				if ( !SetLocation(OldLocation) )
					ChunkUp(200);
			}
		}
		PrePivot = PrePivot + vect(0,0,3);
	}

	function LandThump()
	{
		// animation notify - play sound if actually landed, and animation also shows it
		if ( Physics == PHYS_None)
		{
			bThumped = true;
		}
	}

	event AnimEnd(int Channel)
	{
		if ( Channel != 0 )
			return;
		if ( Physics == PHYS_None )
			LieStill();
		else if ( PhysicsVolume.bWaterVolume )
		{
			bThumped = true;
			LieStill();
		}
	}

	function LieStill()
	{
		if ( !bThumped )
			LandThump();
		if ( CollisionHeight != CarcassCollisionHeight )
			ReduceCylinder();
	}

	singular function BaseChange()
	{
		if( base == None )
			SetPhysics(PHYS_Falling);
		else if ( Pawn(base) != None )
			ChunkUp(200); // don't let corpse ride around on someone's head
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType)
	{
		SetPhysics(PHYS_Falling);
		if ( (Physics == PHYS_None) && (Momentum.Z < 0) )
			Momentum.Z *= -1;
		Velocity += 3 * momentum/(Mass + 200);
		if ( bInvulnerableBody )
			return;
		Damage *= DamageType.Default.GibModifier;
		Health -=Damage;
		if ( ((Damage > 30) || !IsAnimating()) && (Health < -80) )
			ChunkUp(Damage);
	}

	function BeginState()
	{
		if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else
			SetTimer(18.0, false);
		SetPhysics(PHYS_Falling);
		bInvulnerableBody = true;
		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
				Controller.PawnDied();
			else
				Controller.Destroy();
		}
	}

Begin:
	Sleep(0.2);
	bInvulnerableBody = false;
}

//=============================================================================
// Animation interface for controllers

/* SetAnimStatus()
Called by controller to set animation status (e.g. relaxed, alert, combat, etc.
*/
simulated function SetAnimStatus(name NewStatus)
{
	if ( NewStatus != AnimStatus )
	{
		// anim status change
		AnimStatus = NewStatus;
		ChangeAnimation();
	}
}

/* PlayXXX() function called by controller to play transient animation actions
*/
simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	GotoState('Dying');
	if ( bPhysicsAnimUpdate )
	{
		bReplicateMovement = false;
		bTearOff = true;
		Velocity += TearOffMomentum;
		SetPhysics(PHYS_Falling);
	}
	bPlayedDeath = true;
}

simulated function PlayFiring(float Rate, name FiringMode);
function PlayWeaponSwitch(Weapon NewWeapon);
/*
simulated event StopPlayFiring()
{
    bSteadyFiring = false;
}
*/

//_____________________________________________________________________________
// network call from APawn::PostNetReceive on BaffeCount change
simulated event PlayBaffed()
{
    BaffeTimer = 0.2;
    PlayTakehit(vect(0,0,0), 1, none);
}


simulated function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	if ( Level.TimeSeconds - LastPainSound < 0.25 )
		return;

//  Log(self@"PlayTakeHit"@BaffeCount);
	if (HitSound[0] == None)return;
	LastPainSound = Level.TimeSeconds;
	if (FRand() < 0.5)
		PlaySound(HitSound[0]);
	else
		PlaySound(HitSound[1]);
}

//=============================================================================
// Pawn internal animation functions

simulated event ChangeAnimation()
{
	if ( (Controller != None) && Controller.bControlAnimations )
		return;
	// player animation - set up new idle and moving animations
	PlayWaiting();
	PlayMoving();
}

simulated event AnimEnd(int Channel)
{
	if ( Channel == 0 )
		PlayWaiting();
}

// Animation group checks (usually implemented in subclass)

function bool CannotJumpNow()
{
	return false;
}

simulated event PlayJump();
simulated event PlayFalling();
simulated function PlayMoving();
simulated function PlayWaiting();
simulated function PlayReLoading(float Rate, name FiringMode);

function PlayLanded(float impactVel)
{
	local float landVol;

	//default - do nothing (keep playing existing animation)
	landVol = impactVel/JumpZ;
	landVol = 0.005 * Mass * landVol * landVol;
	//PlaySound(Land, SLOT_Interact, FMin(20, landVol)); MC : use PlayMaterialSound
	if ( !bPhysicsAnimUpdate )
		PlayLandingAnimation(impactvel);
}

simulated event PlayLandingAnimation(float ImpactVel);


simulated event SetAnimAction(name NewAnimAction);



debugonly simulated function DumpContent(float TimeStamp, int tabulation)
{
    local int j;
    local string Tab;

    for (j=0; j<tabulation; j++) Tab = Tab$" ";

    log(Tab$"Pawn's dump at "$TimeStamp$":");
    //log(Tab$"  bJustLanded:"$bJustLanded$" bUpAndOut:"$bUpAndOut$" bIsWalking:"$bIsWalking$" bWarping:"$bWarping$" bWantsToCrouch:"$bWantsToCrouch);
    //log(Tab$"  bIsCrouched:"$bIsCrouched$" bTryToUncrouch:"$bTryToUncrouch$" bCanCrouch:"$bCanCrouch$" bCrawler:"$bCrawler$" bReducedSpeed:"$bReducedSpeed);
    //log(Tab$"  bCanJump:"$bCanJump$" bCanWalk:"$bCanWalk$" bCanSwim:"$bCanSwim$" bCanFly:"$bCanFly$" bCanClimbLadders:"$bCanClimbLadders$" bCanStrafe:"$bCanStrafe);
        log(Tab$"  bCanWalk:"$bCanWalk);
    //log(Tab$"  bAvoidLedges:"$bAvoidLedges$" bStopAtLedges:"$bStopAtLedges$" bNoJumpAdjust:"$bNoJumpAdjust$" bCountJumps:"$bCountJumps$" bSimulateGravity:"$bSimulateGravity$" bUpdateEyeheight:"$bUpdateEyeheight);
    //log(Tab$"  bIgnoreForces:"$bIgnoreForces$" bNoVelocityUpdate:"$bNoVelocityUpdate$" bCanWalkOffLedges:"$bCanWalkOffLedges$" bSteadyFiring:"$bSteadyFiring$" bThumped:"$bThumped$" bInvulnerableBody:"$bInvulnerableBody);
    //log(Tab$"  bIsFemale:"$bIsFemale$" bAutoActivate:"$bAutoActivate$" bCanPickupInventory:"$bCanPickupInventory$" bUpdatingDisplay:"$bUpdatingDisplay$" bAmbientCreature:"$bAmbientCreature$" bLOSHearing:"$bLOSHearing);
    //log(Tab$"  bSameZoneHearing:"$bSameZoneHearing$" bAdjacentZoneHearing:"$bAdjacentZoneHearing$" bMuffledHearing:"$bMuffledHearing$" bAroundCornerHearing:"$bAroundCornerHearing$" bDontPossess:"$bDontPossess$" FlashCount:"$FlashCount);
    //log(Tab$"  Visibility:"$Visibility$" DesiredSpeed:"$DesiredSpeed$" MaxDesiredSpeed:"$MaxDesiredSpeed$" AIScriptTag:"$AIScriptTag);
    //log(Tab$"  HearingThreshold:"$HearingThreshold$" Alertness:"$Alertness$" SightRadius:"$SightRadius$" PeripheralVision:"$PeripheralVision);
    //log(Tab$"  AvgPhysicsTime:"$AvgPhysicsTime$" MeleeRange:"$MeleeRange$" Anchor:"$Anchor$" UncrouchTime:"$UncrouchTime);
        log(Tab$"  AvgPhysicsTime:"$AvgPhysicsTime);
    log(Tab$"  GroundSpeed:"$GroundSpeed$" WaterSpeed:"$WaterSpeed$" AirSpeed:"$AirSpeed$" LadderSpeed:"$LadderSpeed);
    log(Tab$"  AccelRate:"$AccelRate$" JumpZ:"$JumpZ$" AirControl:"$AirControl$" WalkingPct:"$WalkingPct);
    //log(Tab$"  CrouchingPct:"$CrouchingPct$" MaxFallSpeed:"$MaxFallSpeed$" PawnName:"$PawnName$" Weapon:"$Weapon);
    //log(Tab$"  PendingWeapon:"$PendingWeapon$" SelectedItem:"$SelectedItem$" BaseEyeHeight:"$BaseEyeHeight$" EyeHeight:"$EyeHeight$" Floor:"$Floor);
        log(Tab$"  BaseEyeHeight:"$BaseEyeHeight);
    //log(Tab$"  SplashTime:"$SplashTime$" CrouchHeight:"$CrouchHeight$" CrouchRadius:"$CrouchRadius$" OldZ:"$OldZ$" HeadVolume:"$HeadVolume);
        log(Tab$"  OldZ:"$OldZ);
    //log(Tab$"  Health:"$Health$" BreathTime:"$BreathTime$" UnderWaterTime:"$UnderWaterTime$" LastPainTime:"$LastPainTime$" ReducedDamageType:"$ReducedDamageType);
    //log(Tab$"  noise1spot:"$noise1spot$" noise1time:"$noise1time$" noise1other:"$noise1other$" noise1loudness:"$noise1loudness$" oise2spot:"$noise2spot$" noise2time:"$noise2time$" noise2other:"$noise2other$" noise2loudness:"$noise2loudness$" LastPainSound:"$LastPainSound);
    //log(Tab$"  HitSound[0]:"$HitSound[0]$" HitSound[1]:"$HitSound[1]$" HitSound[2]:"$HitSound[2]$" HitSound[3]:"$HitSound[3]);
    //log(Tab$"  SoundStepCategory:"$SoundStepCategory$" SoundDampening:"$SoundDampening$" DamageScaling:"$DamageScaling$" MenuName:"$MenuName);
    //log(Tab$"  Shadow:"$Shadow$" BloodEffect:"$BloodEffect$" LowDetailBlood:"$LowDetailBlood$" LowGoreBlood:"$LowGoreBlood);
    //log(Tab$"  ControllerClass:"$ControllerClass$" CarcassCollisionHeight:"$CarcassCollisionHeight$" OnLadder:"$OnLadder$" LandMovementState:"$LandMovementState$" WaterMovementState:"$WaterMovementState);
    //log(Tab$"  AnimStatus:"$AnimStatus$" AnimAction:"$AnimAction$" TakeHitLocation:"$TakeHitLocation$" HitDamageType:"$HitDamageType$" TearOffMomentum:"$TearOffMomentum$" bPhysicsAnimUpdate:"$bPhysicsAnimUpdate);
    //log(Tab$"  bWasCrouched:"$bWasCrouched$" bWasWalking:"$bWasWalking$" bWasFalling:"$bWasFalling$" bWasOnGround:"$bWasOnGround$" bInitializeAnimation:"$bInitializeAnimation);
        log(Tab$"  bWasWalking:"$bWasWalking);
    //log(Tab$"  bPlayedDeath:"$bPlayedDeath$" OldPhysics:"$OldPhysics$" OldRotYaw:"$OldRotYaw$" OldAcceleration:"$OldAcceleration);
        log(Tab$"  OldRotYaw:"$OldRotYaw$"  OldAcceleration:"$OldAcceleration);
    //log(Tab$"  MovementAnims[0]:"$MovementAnims[0]$" MovementAnims[1]:"$MovementAnims[1]$" MovementAnims[2]:"$MovementAnims[2]$" MovementAnims[3]:"$MovementAnims[3]$" TurnLeftAnim:"$TurnLeftAnim$" TurnRightAnim:"$TurnRightAnim);
    //log(Tab$"  MovementAnimRate[0]:"$MovementAnimRate[0]$" MovementAnimRate[1]:"$MovementAnimRate[1]$" MovementAnimRate[2]:"$MovementAnimRate[2]$" MovementAnimRate[3]:"$MovementAnimRate[3]$" BlendChangeTime:"$BlendChangeTime$" MovementBlendStartTime:"$MovementBlendStartTime);
    //log(Tab$"  ControlledActor:"$ControlledActor);

    /*
var Controller Controller;
var PlayerReplicationInfo PlayerReplicationInfo;
    */

    Super.DumpContent(TimeStamp, tabulation+2);
}



//     SoundDampening=+00001.000000
//     DamageScaling=+00001.000000

defaultproperties
{
     bCanBeStunned=True
     bLOSHearing=True
     Visibility=128
     DesiredSpeed=1.000000
     MaxDesiredSpeed=1.000000
     HearingThreshold=2800.000000
     SightRadius=5000.000000
     AvgPhysicsTime=0.100000
     GroundSpeed=600.000000
     WaterSpeed=300.000000
     AirSpeed=600.000000
     LadderSpeed=200.000000
     AccelRate=2048.000000
     JumpZ=420.000000
     AirControl=0.050000
     MaxFallSpeed=1200.000000
     BaseEyeHeight=64.000000
     EyeHeight=54.000000
     CrouchHeight=40.000000
     CrouchRadius=34.000000
     Health=100
     noise1time=-10.000000
     noise2time=-10.000000
     ControllerClass=Class'Engine.AIController'
     CarcassCollisionHeight=23.000000
     LandMovementState="PlayerWalking"
     WaterMovementState="PlayerSwimming"
     MovementAnimRate(0)=1.000000
     MovementAnimRate(1)=1.000000
     MovementAnimRate(2)=1.000000
     MovementAnimRate(3)=1.000000
     BlendChangeTime=0.250000
     DeadPawnSightCounter=1.000000
     DelayBeforeDestroyWhenDead=5.000000
     DistanceBeforeDestroyWhenDead=2362.000000
     OldSkinID=-1
     bCanTeleport=True
     bOwnerNoSee=True
     bStasis=True
     bAcceptsProjectors=True
     bUpdateSimulatedPosition=True
     bIgnoreVignetteAlpha=True
     bIgnoreDynLight=False
     bTravel=True
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
     bRotateToDesired=True
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     //Texture=Texture'Engine.S_Pawn'
     CollisionRadius=34.000000
     CollisionHeight=78.000000
     RotationRate=(Pitch=4096,Yaw=50000,Roll=3072)
     NetPriority=2.000000
     bDirectional=True
}
