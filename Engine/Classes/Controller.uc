//=============================================================================
// Controller, the base class of players or AI.
//
// Controllers are non-physical actors that can be attached to a pawn to control
// its actions.  PlayerControllers are used by human players to control pawns, while
// AIControFllers implement the artificial intelligence for the pawns they control.
// Controllers take control of a pawn using their Possess() method, and relinquish
// control of the pawn by calling UnPossess().
//
// Controllers receive notifications for many of the events occuring for the Pawn they
// are controlling.  This gives the controller the opportunity to implement the behavior
// in response to this event, intercepting the event and superceding the Pawn's default
// behavior.
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Controller extends Actor
	native
	nativereplication
	abstract
	noexport;

var Pawn Pawn;

// Ticked pawn timers
var		float		SightCounter;		// Used to keep track of when to check player visibility

var		float		FovAngle;			// X field of view angle in degrees, usually 90.
var		globalconfig float Handedness;
var		bool        bIsPlayer;			// Pawn is a player or a player-bot.
var		bool        bIsBot;			// Pawn is player-bot.
var		bool		bGodMode;			// cheat - when true, can't be killed or hurt

//AI flags
var const bool		bLOSflag;			// used for alternating LineOfSight traces
var		bool		bAdvancedTactics;	// used during movement between pathnodes
var		bool		bCanOpenDoors;
var		bool		bCanDoSpecial;
var const bool		bAdjusting;
var		bool		bNoTact;
var     bool		bTacticalDir;		// used during movement between pathnodes
var		bool		bPreparingMove;		// set true while pawn sets up for a latent move
var		bool		bControlAnimations;	// take control of animations from pawn (don't let pawn play animations based on notifications)
var     bool        bDisableEventSeeMonster;    // if true, the event SeeMonster() is not called, whatever the state the controller is in
var     bool        bDisableEventSeeDeadPawn;   // if true, the event SeeDeadPawn() is not called, whatever the state the controller is in
var     bool        bTimer3Loop;        // Timer3 loops (else is one-shot).

var vector AdjustLoc;

// Input buttons.
var input byte
	bRun, bDuck, bFire, bAltFire;

var const	Controller		nextController; // chained Controller list

var		float 		Stimulus;			// Strength of stimulus - Set when stimulus happens
var     float		Skill;				// skill, scaled by game difficulty (add difficulty to this value)
var		float		TacticalOffset;		// C++ timer used if bAdvancedTactics is true (to call UpdateTactics)


// Navigation AI
var 	float		MoveTimer;
var 	Actor		MoveTarget;		// set by movement natives
var 	Actor		NextMoveTarget;		// set by movement natives
var		vector	 	Destination;	// set by Movement natives
var	 	vector		FocalPoint;		// set by Movement natives
var		Actor		Focus;

var		vector		LastSeenPos; 	// enemy position when I last saw enemy (auto updated if EnemyNotVisible() enabled)
var		vector		LastSeeingPos;	// position where I last saw enemy (auto updated if EnemyNotVisible enabled)
var		float		LastSeenTime;
var	 	Pawn    	Enemy;
var		Actor		Target;
var		Mover		PendingMover;	// mover pawn is waiting for to complete its move
var		Actor		GoalList[4];	// used by navigation AI - list of intermediate goals

var NavigationPoint home;			// set when begin play, used for retreating and attitude checks
var	 	float		MinHitWall;		// Minimum HitNormal dot Velocity.Normal to get a HitWall from the physics

var byte VoicePitch; //for speech
var string VoiceType; //for speech
var float OldMessageTime; //to limit frequency of voice messages

// Route Cache for Navigation
var Actor RouteCache[16];

//var ReachSpec CurrentPath; //FAB
var	transient int		CurrentPath;

var Actor	RouteGoal; //final destination for current route
var float	RouteDist;	// total distance for current route

// Execution and timer 3 variables.
var				float       Timer3Rate;         // Timer event, 0=no timer.
var		const	float       Timer3Counter;      // Counts up until it reaches TimerRate.

// Replication Info
var() class<PlayerReplicationInfo> PlayerReplicationInfoClass;
var PlayerReplicationInfo PlayerReplicationInfo;

var(AI) enum EAttitude  //order in decreasing importance
{
	ATTITUDE_Fear,		//will try to run away
	ATTITUDE_Hate,		// will attack enemy
	ATTITUDE_Frenzy,	//will attack anything, indiscriminately
	ATTITUDE_Threaten,	// animations, but no attack
	ATTITUDE_Ignore,
	ATTITUDE_Friendly,
	ATTITUDE_Follow 	//accepts player as leader
} AttitudeToPlayer;	//determines how creature will react on seeing player (if in human form)

var class<Pawn> PawnClass;	// class of pawn to spawn (for players)

var float GroundPitchTime;
var vector ViewX, ViewY, ViewZ;	// Viewrotation encoding for PHYS_Spider

var NavigationPoint StartSpot;  // where player started the match

replication
{
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		PlayerReplicationInfo, Pawn;
	reliable if( bNetDirty && (Role== ROLE_Authority) && bNetOwner )
		PawnClass;

	// Functions the server calls on the client side.
	reliable if( RemoteRole==ROLE_AutonomousProxy )
		ClientGameEnded, ClientDying, ClientSetRotation, ClientSetLocation;
	reliable if ( (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc)) && Role == ROLE_Authority )
		ClientVoiceMessage;

	// Functions the client calls on the server.
	unreliable if( Role<ROLE_Authority )
		SendVoiceMessage;
	reliable if ( Role < ROLE_Authority )
		ServerRestartPlayer;
}

// Latent Movement.
//Note that MoveTo sets the actor's Destination, and MoveToward sets the
//actor's MoveTarget.  Actor will rotate towards destination unless the optional ViewFocus is specified.

native(500) final latent function MoveTo( vector NewDestination, optional Actor ViewFocus, optional float speed);
native(502) final latent function MoveToward(actor NewTarget, optional Actor ViewFocus, optional float speed,optional Actor NextTarget);
native(508) final latent function FinishRotation();

// native AI functions
/* LineOfSightTo() returns true if any of several points of Other is visible
  (origin, top, bottom)
*/
native(514) final function bool LineOfSightTo(actor Other);

/* CanSee() similar to line of sight, but also takes into account Pawn's peripheral vision
*/
native(533) final function bool CanSee(Pawn Other);

//Navigation functions - return the next path toward the goal
native(518) final function Actor FindPathTo(vector aPoint, optional bool bClearPaths);
native(517) final function Actor FindPathToward(actor anActor, optional bool bClearPaths);
native final function Actor FindPathTowardNearest(class<NavigationPoint> GoalClass);
native(525) final function NavigationPoint FindRandomDest(optional bool bClearPaths);

native(522) final function ClearPaths();
native(523) final function vector EAdjustJump(float BaseZ, float XYSpeed);

//Reachable returns whether direct path from Actor to aPoint is traversable
//using the current locomotion method
native(521) final function bool pointReachable(vector aPoint);
native(520) final function bool actorReachable(actor anActor);

/* PickWallAdjust()
Check if could jump up over obstruction (only if there is a knee height obstruction)
If so, start jump, and return current destination
Else, try to step around - return a destination 90 degrees right or left depending on traces
out and floor checks
*/
native(526) final function bool PickWallAdjust(vector HitNormal);

/* WaitForLanding()
latent function returns when pawn is on ground (no longer falling)
*/
native(527) final latent function WaitForLanding();

native(540) final function actor FindBestInventoryPath(out float MinWeight, bool bPredictRespawns);

native(529) final function AddController();
native(530) final function RemoveController();

// Pick best pawn target
native(531) final function pawn PickTarget(out float bestAim, out float bestDist, vector FireDir, vector projStart, optional int TraceType);
native(534) final function actor PickAnyTarget(out float bestAim, out float bestDist, vector FireDir, vector projStart);

// Force end to sleep
native function StopWaiting();

native function EndClimbLadder(); //FAB

event MayFall(); //return true if allowed to fall - called by engine when pawn is about to fall


//=============================================================================
// Timing.

// Causes Timer3() events every NewTimerRate seconds.
native final function SetTimer3( float NewTimerRate, bool bLoop );

event Timer3();



/* DisplayDebug()
list important controller attributes on canvas
*/
function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Canvas.DrawText("PAWN "$Pawn);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	if ( Pawn == None )
	{
		Super.DisplayDebug(Canvas,YL,YPos);
		return;
	}
	Canvas.DrawText("CONTROLLER "$GetItemName(string(self)));
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("     STATE: "$GetStateName()$" Timer: "$TimerCounter$" Enemy "$Enemy, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	if ( PlayerReplicationInfo == None )
		Canvas.DrawText("     NO PLAYERREPLICATIONINFO", false);
	else
		PlayerReplicationInfo.DisplayDebug(Canvas,YL,YPos);

	YPos += YL;
	Canvas.SetPos(4,YPos);
}

/* Reset()
reset actor to initial state
*/
function Reset()
{
	Super.Reset();
	Enemy = None;
	LastSeenTime = 0;
	StartSpot = None;
}

/* ClientSetLocation()
replicated function to set location and rotation.  Allows server to force new location for
teleports, etc.
*/
function ClientSetLocation( vector NewLocation, rotator NewRotation )
{
	SetRotation(NewRotation);
	If ( (Rotation.Pitch > RotationRate.Pitch)
		&& (Rotation.Pitch < 65536 - RotationRate.Pitch) )
	{
		If (Rotation.Pitch < 32768)
			NewRotation.Pitch = RotationRate.Pitch;
		else
			NewRotation.Pitch = 65536 - RotationRate.Pitch;
	}
	if ( Pawn != None )
	{
		NewRotation.Roll  = 0;
		Pawn.SetRotation( NewRotation );
		Pawn.SetLocation( NewLocation );
	}
}

/* ClientSetRotation()
replicated function to set rotation.  Allows server to force new rotation.
*/
function ClientSetRotation( rotator NewRotation )
{
	SetRotation(NewRotation);
	if ( Pawn != None )
	{
		NewRotation.Pitch = 0;
		NewRotation.Roll  = 0;
		Pawn.SetRotation( NewRotation );
	}
}

function ClientDying(class<DamageType> DamageType, vector HitLocation)
{
	if ( Pawn != None )
	{
		Pawn.PlayDying(DamageType, HitLocation);
		Pawn.GotoState('Dying');
	}
}

/* AIHearSound()
Called when AI controlled pawn would hear a sound.  Default AI implementation uses MakeNoise()
interface for hearing appropriate sounds instead
*/
event AIHearSound (
	actor Actor,
	int Id,
	sound S,
	vector SoundLocation,
	vector Parameters,
	bool bNoFPHack
);

function Possess(Pawn aPawn)
{
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
	// preserve Pawn's rotation initially for placed Pawns
	FocalPoint = Pawn.Location + 512*vector(Pawn.Rotation);
	Restart();
}

/* PawnDied()
 unpossess a pawn (because pawn was killed)
 */
function PawnDied()
{
	if ( Pawn != None )
	{
		SetLocation(Pawn.Location);
		Pawn.UnPossessed();
	}
	Pawn = None;
	PendingMover = None;
	if ( bIsPlayer )
		GotoState('Dead'); // can respawn
	else
		Destroy();
}

function Restart()
{
	Enemy = None;
}

event LongFall(); // called when latent function WaitForLanding() doesn't return after 4 seconds

// notifications of pawn events (from C++)
// if return true, then pawn won't get notified
event bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume);
event bool NotifyHeadVolumeChange(PhysicsVolume NewVolume);
event bool NotifyLanded(vector HitNormal);
event bool NotifyHitWall(vector HitNormal, actor Wall);
event bool NotifyBump(Actor Other);
event NotifyHitMover(vector HitNormal, mover Wall);

// notifications called by pawn in script
function NotifyAddInventory(inventory NewItem);
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	if ( (instigatedBy != None) && (instigatedBy != pawn) )
		damageAttitudeTo(instigatedBy, Damage);
}

// Notification called by weapon to inform pawn controller.
function NotifyFiring();

function SetFall();	//about to fall

event PreBeginPlay()
{
	AddController();
	Super.PreBeginPlay();
	if ( bDeleteMe )
		return;

	SightCounter = 0.2 * FRand();  //offset randomly
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (bIsPlayer)
	{
		PlayerReplicationInfo = Spawn(PlayerReplicationInfoClass, Self,,vect(0,0,0),rot(0,0,0));
		InitPlayerReplicationInfo();
	}
}

function InitPlayerReplicationInfo()
{
	if (PlayerReplicationInfo.PlayerName == "")
		PlayerReplicationInfo.SetPlayerName(class'GameInfo'.Default.DefaultPlayerName);
}

/*  --> became purely C++ virtual function
function vector WeaponBob(float BobDamping)
{
	return vect(0,0,0);
}
*/

function HandlePickup(Pickup pick)
{
	if ( MoveTarget == pick )
		MoveTimer = -1.0;
}

simulated event Destroyed()
{
	if ( Role < ROLE_Authority )
		return;

	RemoveController();

	if ( bIsPlayer && (Level.Game != None) )
		Level.Game.logout(self);
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.Destroy();
	Super.Destroyed();
}

/* AdjustView()
by default, check and see if pawn still needs to update eye height
(only if some playercontroller still has pawn as its viewtarget)
Overridden in playercontroller
*/
function AdjustView( float DeltaTime )
{
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('PlayerController') && (PlayerController(C).ViewTarget == Pawn) )
			return;

	Pawn.bUpdateEyeHeight =false;
	Pawn.Eyeheight = Pawn.BaseEyeHeight;
}

/*function bool WantsSmoothedView()
{
	return ( ((Pawn.Physics==PHYS_Walking) || (Pawn.Physics==PHYS_Spider)) && !Pawn.bJustLanded );
}*/
native function bool WantsSmoothedView();


function ClientGameEnded()
{
	GotoState('GameEnded');
}

simulated event RenderOverlays( canvas Canvas )
{
	if ( Pawn.Weapon != None )
		Pawn.Weapon.RenderOverlays(Canvas);
}

/* GetFacingDirection()
returns direction faced relative to movement dir

0 = forward
16384 = right
32768 = back
49152 = left
*/
function int GetFacingDirection()
{
	return 0;
}

//------------------------------------------------------------------------------
// Speech related

function SendMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait, name BroadcastType)
{
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, BroadcastType);
}

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
	local Controller P;
	local bool bNoSpeak;

	if ( Level.TimeSeconds - OldMessageTime < 2.5 )
		bNoSpeak = true;
	else
		OldMessageTime = Level.TimeSeconds;

	for ( P=Level.ControllerList; P!=None; P=P.NextController )
	{
		if ( PlayerController(P) != None )
		{
			if ( !bNoSpeak )
			{
				if ( (broadcasttype == 'GLOBAL') || !Level.Game.bTeamGame )
					P.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
				else if ( Sender.Team == P.PlayerReplicationInfo.Team )
					P.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
			}
		}
		else if ( (P.PlayerReplicationInfo == Recipient) || ((messagetype == 'ORDER') && (Recipient == None)) )
			P.BotVoiceMessage(messagetype, messageID, self);
	}
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID);
function BotVoiceMessage(name messagetype, byte MessageID, Controller Sender);

//***************************************************************
// interface used by ScriptedControllers to query pending controllers

function bool WouldReactToNoise( float Loudness, Actor NoiseMaker)
{
	return false;
}

function bool WouldReactToSeeing(Pawn Seen)
{
	return false;
}

//***************************************************************
// AI related

function FearThisSpot(Actor ASpot);
event PrepareForMove(NavigationPoint Goal, ReachSpec Path);
function WaitForMover(Mover M);
function MoverFinished();
function UnderLift(Mover M);

event float Desireability(Pickup P)
{
	return P.BotDesireability(Pawn);
}

event HearNoise( float Loudness, Actor NoiseMaker);
event SeePlayer( Pawn Seen );	// called when a player (bIsPlayer==true) pawn is seen
event SeeMonster( Pawn Seen );	// called when a non-player (bIsPlayer==false) pawn is seen and bDisableEventSeeMonster==false
event SeeDeadPawn( Pawn Seen ); // called when a dead pawn (bIsDead==true) is seen and bDisableEventSeeDeadPawn==false

event UpdateTactics(); // for advanced tactics
event EnemyNotVisible();

function ShakeView( float shaketime, float RollMag, vector OffsetMag, float RollRate, vector OffsetRate, float OffsetTime);

function NotifyKilled(Controller Killer, Controller Killed, pawn Other)
{
	if ( Enemy == Other )
		Enemy = None;
}

function damageAttitudeTo(pawn Other, float Damage);

function eAttitude AttitudeTo(Pawn Other)
{
	if ( Other.IsPlayerPawn() )
		return AttitudeToPlayer;
	else
		return ATTITUDE_Ignore;
}

function float AdjustDesireFor(Pickup P);
function FireWeaponAt(Actor A);

function StopFiring()
{
	bFire = 0;
	bAltFire = 0;
}

function float WeaponPreference(Weapon W);


/* AdjustAim()
AIController version does adjustment for non-controlled pawns.
PlayerController version does the adjustment for player aiming help.
Only adjusts aiming at pawns
allows more error in Z direction (full as defined by AutoAim - only half that difference for XY)
CHANGENOTE: This function change is related to the Weapon code updates
*/
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	return Rotation;
}

/* ReceiveWarning()  *** CHANGENOTE: RENAMED (WAS WARNTARGET())***
 AI controlled creatures may duck
 if not falling, and projectile time is long enough
 often pick opposite to current direction (relative to shooter axis)
*/
function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
{
}

/* CHANGENOTE: Changes in this function related to the Weapon code updates
*/
exec function SwitchToBestWeapon()
{
	local float rating;

	if ( Pawn.Inventory == None )
		return;

	StopFiring();
	Pawn.PendingWeapon = Pawn.Inventory.RecommendWeapon(rating);
	if ( Pawn.PendingWeapon == Pawn.Weapon )
		Pawn.PendingWeapon = None;
	if ( Pawn.PendingWeapon == None )
		return;

	if ( Pawn.Weapon == None )
		Pawn.ChangedWeapon();

	if ( Pawn.Weapon != Pawn.PendingWeapon )
		Pawn.Weapon.PutDown();
}

function bool CheckFutureSight(float DeltaTime)
{
	return true;
}

function ChangedWeapon();
function ServerReStartPlayer()
{
}

// **********************************************
// Controller States

State Dead
{
ignores SeePlayer, HearNoise, KilledBy;

	function PawnDied() {}

	function ServerReStartPlayer()
	{
		//log("calling restartplayer in dying with netmode "$Level.NetMode);
		if ( Level.NetMode == NM_Client )
			return;
		Level.Game.RestartPlayer(self);
	}
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, TakeDamage, ReceiveWarning;

	function BeginState()
	{
		if ( Pawn != None )
		{
			Pawn.bPhysicsAnimUpdate = false;
			Pawn.StopAnimating();
			Pawn.SimAnim.AnimRate = 0;
			Pawn.SetCollision(false,false,false);
			Pawn.Velocity = vect(0,0,0);
			Pawn.SetPhysics(PHYS_None);
			Pawn.UnPossessed();
		}
		if ( !bIsPlayer )
			Destroy();
	}
}


debugonly simulated function DumpContent(float TimeStamp, int tabulation)
{
    local int j;
    local string Tab;

    for (j=0; j<tabulation; j++) Tab = Tab$" ";

    log(Tab$"Controller's dump at "$TimeStamp$":");
    //log(Tab$"  SightCounter:"$SightCounter$" FovAngle:"$FovAngle$" Handedness:"$Handedness$" bIsPlayer:"$bIsPlayer$" bGodMode:"$bGodMode);
        log(Tab$"  SightCounter:"$SightCounter);
    //log(Tab$"  bLOSflag:"$bLOSflag$" bAdvancedTactics:"$bAdvancedTactics$" bCanOpenDoors:"$bCanOpenDoors$" bCanDoSpecial:"$bCanDoSpecial$" bAdjusting:"$bAdjusting$" bNoTact:"$bNoTact$" bTacticalDir:"$bTacticalDir$" bPreparingMove:"$bPreparingMove$" bControlAnimations:"$bControlAnimations);
    //log(Tab$"  AdjustLoc:"$AdjustLoc);
    //log(Tab$"  bRun:"$bRun$" bDuck:"$bDuck$" bFire:"$bFire$" bAltFire:"$bAltFire);
    //log(Tab$"  nextController:"$nextController);
    //log(Tab$"  Stimulus:"$Stimulus$" Skill:"$Skill$" TacticalOffset:"$TacticalOffset);
    //log(Tab$"  MoveTimer:"$MoveTimer$" MoveTarget:"$MoveTarget$" Destination:"$Destination$" FocalPoint:"$FocalPoint$" Focus:"$Focus);
        log(Tab$"  MoveTimer:"$MoveTimer);
    //log(Tab$"  LastSeenPos:"$LastSeenPos$" LastSeeingPos:"$LastSeeingPos$" LastSeenTime:"$LastSeenTime$" Enemy:"$Enemy$" Target:"$Target$" PendingMover:"$PendingMover);
    //log(Tab$"  MinHitWall:"$MinHitWall$" VoicePitch:"$VoicePitch$" VoiceType:"$VoiceType$" OldMessageTime:"$OldMessageTime);
    //log(Tab$"  AttitudeToPlayer:"$AttitudeToPlayer$" PawnClass:"$PawnClass$" GroundPitchTime:"$GroundPitchTime);
        log(Tab$"  GroundPitchTime:"$GroundPitchTime);
    //log(Tab$"  ViewX:"$ViewX$" ViewY:"$ViewY$" ViewZ:"$ViewZ);
    //log(Tab$"  PlayerReplicationInfoClass:"$PlayerReplicationInfoClass$" PlayerReplicationInfo:"$PlayerReplicationInfo);

    if (PlayerReplicationInfo != none)
    {
        PlayerReplicationInfo.DumpContent(TimeStamp, tabulation+2);
    }
    else
    {
        log(Tab$"  PlayerReplicationInfo: none");
    }
    if (Pawn != none)
    {
        Pawn.DumpContent(TimeStamp, tabulation+2);
    }
    else
    {
        log(Tab$"  Pawn: none");
    }

/*
//var Actor RouteCache[16]
//var ReachSpec CurrentPath
//var Actor	RouteGoal
//var float	RouteDist
//GoalList[4]

//var NavigationPoint home

//var NavigationPoint StartSpot
*/


    Super.DumpContent(TimeStamp, tabulation);
}

defaultproperties
{
     FovAngle=90.000000
     MinHitWall=-1.000000
     PlayerReplicationInfoClass=Class'Engine.PlayerReplicationInfo'
     AttitudeToPlayer=ATTITUDE_Hate
     bHidden=True
     bInteractive=False
     bHiddenEd=True
}
