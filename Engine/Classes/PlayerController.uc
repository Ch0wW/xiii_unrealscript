//=============================================================================
// PlayerController
//
// PlayerControllers are used by human players to control pawns.
//
// This is a built-in Unreal class and it shouldn't be modified.
// CHANGENOTE: All Changes since v739 in this class are related to the Weapon code update, except
// for the change in Possess().
//=============================================================================
class PlayerController extends Controller
  config(user)
  native
  nativereplication;

// Player info.
var const player Player;

// player input control
var globalconfig bool bLookUpStairs;  // look up/down stairs (player)
var globalconfig bool bSnapToLevel;   // Snap to level eyeheight when not mouselooking
var globalconfig bool bAlwaysMouseLook;
var globalconfig bool bKeyboardLook;  // no snapping when true
var bool bCenterView;

// Player control flags
var bool bBehindView;                 // Outside-the-player view.
var bool bFrozen;                     // set when game ends or player dies to temporarily prevent player from restarting (until cleared by timer)
var bool bPressedJump;
var bool bUpdatePosition;
var bool bIsTyping;
var bool bFixedCamera;                // used to fix camera in position (to view animations)
var bool bJumpStatus;                 // used in net games
var bool bUpdating;
var globalconfig bool bNeverSwitchOnPickup;  // if true, don't automatically switch to picked up weapon

var bool bZooming;
var bool bOnlySpectator;              // This controller is not allowed to possess pawns

var globalconfig bool bAlwaysLevel;
var bool bSetTurnRot;
var bool bCheatFlying;                // instantly stop in flying mode
var bool bFreeCamera;                 // free camera when in behindview mode (for checking out player models and animations)
var bool bZeroRoll;

// XIII Added
//var config bool bAltDuckMode;         // True = Crouch toggle, False = Crouch on/off
var bool bLocked;                     // adjustaim locked someone (to handle transitions between crosshair pos

var bool bDontUseVolumeFog;
var bool bIsInMenu;

var globalconfig bool bAutoPickup;    // AutoPickup objects.
var globalconfig int iAutoAimMode;    // 0 = off, 1 = on.

// XIIIUNUSED var float AimingHelp;
var float WaitDelay;                  // Delay time until can restart

var input float
  aBaseX, aBaseY, aBaseZ,  aMouseX, aMouseY,
  aForward, aTurn, aStrafe, aUp, aLookUp;

var input byte
  bStrafe, bSnapLevel, bLook, bFreeLook, bTurn180, bTurnToNearest;

// XIII Additional inputs
var input byte bUp, bDown, bLeft, bRight;   // check if KEYs are pressed and not pad.
var input byte b90Left, b90Right, b180Turn; // To make us turn fast to left or right.
var input byte bAltDuck;                    // To enable the AltDuck Mode
var input byte bAltJump;                    // To be used for Hook Mode using Duck/Jump
var input byte bAltRun;                     //
var globalconfig bool bInverseLook;   // Inverse FlightSim/Std Pad look axis
var globalconfig bool bWalkCenterView;// auto center view afer walking a while
//var float Ym,Lm,Sm,Tm;  // DBUG used to check max value of inputs
enum eConfigType
{
  CT_StrafeLookSameAxis,
  CT_StrafeLookNotSameAxis,
};
var config eConfigType ConfigType;
var config float fLookSpeed;
var config bool bUseRumble;
var config int UserPadConfig;
//
var EDoubleClickDir DoubleClickDir;   // direction of movement key double click (for special moves)

// Camera info.
var int ShowFlags;
var int Misc1,Misc2;
var int RendMap;
var float OrthoZoom;                  // Orthogonal/map view zoom factor.
var const actor ViewTarget;
var float CameraDist;                 // multiplier for behindview camera dist

var float DesiredFOV;
var globalconfig float DefaultFOV;
var float ZoomLevel;

// Screen flashes
var vector FlashScale, FlashFog;
var float DesiredFlashScale, ConstantGlowScale, InstantFlash;
var vector DesiredFlashFog, ConstantGlowFog, InstantFog;

// Filter.
var color FilterColor;
var color FilterColorWanted;
var float FilterColorSpeed;
var int FilterInternalInc;

// Remote Pawn ViewTargets
var rotator TargetViewRotation;
var float TargetEyeHeight;
var vector TargetWeaponViewOffset;

var HUD myHUD;  // heads up display info

var float LastPlaySound;
var globalconfig int AnnouncerVolume;

// Move buffering for network games.  Clients save their un-acknowledged moves in order to replay them
// when they get position updates from the server.
var SavedMove SavedMoves;  // buffered moves pending position updates
var SavedMove FreeMoves;  // freed moves, available for buffering
var SavedMove PendingMove;
var float CurrentTimeStamp,LastUpdateTime,ServerTimeStamp,TimeMargin, ClientUpdateTime;
var globalconfig float MaxTimeMargin;
var Weapon OldClientWeapon;
var int WeaponUpdate;

// Progess Indicator - used by the engine to provide status messages (HUD is responsible for displaying these).
var string ProgressMessage[4];
var color ProgressColor[4];
var float ProgressTimeOut;

// Localized strings
var localized string QuickSaveString;
var localized string NoPauseMessage;
var localized string ViewingFrom;
var localized string OwnCamera;

// ReplicationInfo
var GameReplicationInfo GameReplicationInfo;

// ngWorldStats Logging
var globalconfig private string ngWorldSecret;
var globalconfig bool ngSecretSet;
var bool ReceivedSecretChecksum;
var PlayerStats PlayerStat;   // Used to store everything that should be usefull for on-line ladder/rankings
                              // Server side only (no replication).

var class<LocalMessage> LocalMessageClass;

var globalconfig float Bob;
var float LandBob, AppliedBob;
var float bobtime;
var vector WalkBob;

// view shaking (affects roll, and offsets camera position)
var float MaxShakeRoll; // max magnitude to roll camera
var vector MaxShakeOffset; // max magnitude to offset camera position
var float ShakeRollRate;  // rate to change roll
var vector ShakeOffsetRate;
var vector ShakeOffset; //current magnitude to offset camera from shake
var float ShakeRollTime; // how long to roll.  if value is < 1.0, then MaxShakeOffset gets damped by this, else if > 1 then its the number of times to repeat undamped
var vector ShakeOffsetTime;
/* iKi=> */
var vector MaxShakeFrame, ShakeFrame, ShakeFrameRate;
var float ShakeFrameTime;
/* <=iKi */

var Pawn TurnTarget;
var config int EnemyTurnSpeed;
var int GroundPitch;
var rotator TurnRot180;

var vector OldFloor;    // used by PlayerSpider mode - floor for which old rotation was based;

// Components ( inner classes )
var CheatManager  CheatManager;  // Object within playercontroller that manages "cheat" commands
var class<CheatManager> CheatClass;    // class of my CheatManager
var transient PlayerInput PlayerInput;  // Object within playercontroller that manages player input.
var class<PlayerInput> InputClass;    // class of my PlayerInput

// Demo recording view rotation
var int DemoViewPitch;
var int DemoViewYaw;

// Use alpha filter.
var byte UseVignetteFilter;
// Use highlight filter.
var byte UseVignetteHighlight;
// Alpha filter color.
var color VignetteColor;
// Highlight intensity.
var float VignetteHighLight;
// Alpha filter texture.
var material VignetteMaterial;

var vector OldAdjustAim;          // Used to smooth autoaim, Aim to use when firing non-projectiles
var vector ViewAdjustAim;         // Used to smooth Weapon rot on screen
//var float LastOldAdjustAimUpdate; // to update it only once per frame (if called by interaction and weapon at the same frame don't update twice)
var float fAdjustAimTrans;        // to handle crosshair/Adjust aim transition
var vector MemAim;                // memorize aim when switching bLocked
var vector AdjustedAimForFiring;  // Aim to use when firing Projectiles (because display don't show anticipation
var actor BestTarget;             // to memorize the best target and use it in interaction
var actor OldBestTarget;          // to memorize the best target and use it in interaction

var float DeltaT;                 // to enable using it anywhere (needed for death camera sfxs  at least)

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
		ViewTarget, GameReplicationInfo;
	unreliable if ( bNetOwner && Role==ROLE_Authority && (ViewTarget != Pawn) && (Pawn(ViewTarget) != None) )
		TargetViewRotation, TargetEyeHeight, TargetWeaponViewOffset;
	reliable if( bDemoRecording && Role==ROLE_Authority )
		DemoViewPitch, DemoViewYaw;

	// Functions server can call.
	reliable if( Role==ROLE_Authority )
		ClientSetHUD,ClientReliablePlaySound, FOV, StartZoom,
		ToggleZoom, StopZoom, EndZoom, ClientRestart,
		ClientReplicateSkins, ClientAdjustGlow,
		ClientSetBehindView, ClientSetFixedCamera, ClearProgressMessages,
		SetProgressMessage, SetProgressTime,
		GivePawn, ClientGotoState;
	reliable if ( (Role == ROLE_Authority) && (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc)) )
		ClientMessage, TeamMessage, ReceiveLocalizedMessage;
	unreliable if( Role==ROLE_Authority && !bDemoRecording )
		ClientPlaySound;
	reliable if( Role==ROLE_Authority && !bDemoRecording )
		ClientTravel;
	unreliable if( Role==ROLE_Authority )
		SetFOVAngle, ClientShake, ClientFlash, ClientInstantFlash, ClientFilter, ClientHighLight,
		ClientAdjustPosition, ShortClientAdjustPosition, VeryShortClientAdjustPosition, LongClientAdjustPosition;

	// Functions client can call.
	unreliable if( Role<ROLE_Authority )
		ShortServerMove, ServerMove, Say, TeamSay, ServerSetHandedness;
	reliable if( Role<ROLE_Authority )
		Speech, Pause, SetPause,
		PrevItem, ActivateItem, ServerReStartGame, AskForPawn,
		ChangeName, ChangeTeam, Suicide,
		ThrowWeapon, BehindView, Typing;
}

// Pad management
native(538) static final function int GetPadNumber();
native(537) static final function AttribPadToViewport();

// "Compile" the commands associated with each input key
native(535) static final function OptimizeInputBindings();

native(519) static final function string GetPlayerNetworkAddress();
native static function string ConsoleCommand( string Command );
native(515) static final function LevelInfo GetEntryLevel();
native(544) static final function ResetKeyboard();
native(513) static final function SetViewTarget(Actor NewViewTarget);
native static function event ClientTravel( string URL, ETravelType TravelType, bool bItems );
native(546) static final function UpdateURL(string NewOption, string NewValue, bool bSaveDefault);
native(510) static final function string GetDefaultURL(string Option);
// Execute a console command in the context of this player, then forward to Actor.ConsoleCommand.
native(507) static final function CopyToClipboard( string Text );
native(506) static final function string PasteFromClipboard();

/* FindStairRotation()
returns an integer to use as a pitch to orient player view along current ground (flat, up, or down)
*/
native(524) static final function int FindStairRotation(float DeltaTime);

event PostBeginPlay()
{
	Super.PostBeginPlay();
	SpawnDefaultHUD();
	if (Level.LevelEnterText != "" )
		ClientMessage(Level.LevelEnterText);

	DesiredFOV = DefaultFOV;
	SetViewTarget(self);  // MUST have a view target!
	if ( Level.NetMode == NM_Standalone )
		CheatManager = new CheatClass;
}

/* SpawnDefaultHUD()
Spawn a HUD (make sure that PlayerController always has valid HUD, even if \
ClientSetHUD() hasn't been called\
*/
function SpawnDefaultHUD()
{
	myHUD = spawn(class'HUD',self);
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	PawnDied();
	Super.Reset();
	SetViewTarget(self);
	bBehindView = false;
	WaitDelay = Level.TimeSeconds + 2;
	GotoState('PlayerWaiting');
}

/* InitInputSystem()
Spawn the appropriate class of PlayerInput
Only called for playercontrollers that belong to local players
*/
event InitInputSystem()
{
	PlayerInput = new InputClass;
}

/* ClientGotoState()
server uses this to force client into NewState
*/
function ClientGotoState(name NewState, name NewLabel)
{
	GotoState(NewState,NewLabel);
}

function AskForPawn()
{
  Log(self@"AskForPawn"@Pawn@"InState"@GetStateName());
	if ( Pawn != None )
		GivePawn(Pawn);
	else if ( IsInState('GameEnded') )
		ClientGotoState('GameEnded', 'Begin');
	else if ( IsInState('Dead') )
	{
		bFrozen = false;
		ServerRestartPlayer();
	}
}

function GivePawn(Pawn NewPawn)
{
	if ( NewPawn == None )
		return;
	Pawn = NewPawn;
	NewPawn.Controller = self;
	ClientRestart();
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
	local vector X,Y,Z, Dir;

	GetAxes(Pawn.Rotation, X,Y,Z);
	Dir = Normal(Pawn.Acceleration);
	if ( Y Dot Dir > 0 )
		return ( 49152 + 16384 * (X Dot Dir) );
	else
		return ( 16384 - 16384 * (X Dot Dir) );
}

// Possess a pawn
function Possess(Pawn aPawn)
{
	if ( bOnlySpectator )
		return;

	SetRotation(aPawn.Rotation);
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	Pawn.bStasis = false;
	PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
	ServerSetHandedness(Handedness);
	Restart();
}

// unpossessed a pawn (not because pawn was killed)
function UnPossess()
{
	if ( Pawn != None )
	{
		SetLocation(Pawn.Location);
		Pawn.RemoteRole = ROLE_SimulatedProxy;
		Pawn.UnPossessed();
		if ( Viewtarget == Pawn )
			SetViewTarget(self);
	}
	Pawn = None;
	GotoState('Spectating');
}

// unpossessed a pawn (because pawn was killed)
function PawnDied()
{
	StopZoom();
	if ( Pawn != None )
		Pawn.RemoteRole = ROLE_SimulatedProxy;
	if ( ViewTarget == Pawn )
		bBehindView = true;

	Super.PawnDied();
}

// called when kicked
simulated event IAmKicked();


function ClientSetHUD(class<HUD> newHUDType, class<Scoreboard> newScoringType)
{
	local HUD NewHUD;

	if ( (myHUD == None) || ((newHUDType != None) && (newHUDType != myHUD.Class)) )
	{
		NewHUD = spawn(newHUDType, self);
		if ( NewHUD != None )
		{
			if ( myHUD != None )
				myHUD.Destroy();
			myHUD = NewHUD;
		}
	}
	if ( (myHUD != None) && (newScoringType != None) )
		MyHUD.SpawnScoreBoard(newScoringType);
}

function HandlePickup(Pickup pick)
{
	ReceiveLocalizedMessage( pick.MessageClass, 0, None, None, pick.Class );
}

/*function ViewFlash(float DeltaTime)
{
	local vector goalFog;
	local float goalscale, delta;

	delta = FMin(0.1, DeltaTime);
	goalScale = 1 + DesiredFlashScale + ConstantGlowScale;
	goalFog = DesiredFlashFog + ConstantGlowFog;

	if ( Pawn != None )
	{
		goalScale += Pawn.HeadVolume.ViewFlash.X;
		goalFog += Pawn.HeadVolume.ViewFog;
	}

	DesiredFlashScale -= DesiredFlashScale * 2 * delta;
	DesiredFlashFog -= DesiredFlashFog * 2 * delta;
	FlashScale.X += (goalScale - FlashScale.X + InstantFlash) * 10 * delta;
	FlashFog += (goalFog - FlashFog + InstantFog) * 10 * delta;
	InstantFlash = 0;
	InstantFog = vect(0,0,0);

	if ( FlashScale.X > 0.981 )
		FlashScale.X = 1;
	FlashScale = FlashScale.X * vect(1,1,1);

	if ( FlashFog.X < 0.019 )
		FlashFog.X = 0;
	if ( FlashFog.Y < 0.019 )
		FlashFog.Y = 0;
	if ( FlashFog.Z < 0.019 )
		FlashFog.Z = 0;
}*/
native(505) static final function ViewFlash(float DeltaTime);

event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	Message.Static.ClientReceive( Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

event ClientMessage( coerce string S, optional Name Type )
{
	if (Type == '')
		Type = 'Event';
	TeamMessage(PlayerReplicationInfo, S, Type);
}

event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type  )
{
	local string ConsoleString;

	//log("Teammessage with PRI "$PRI$" hud "$myHud$" Player "$Player$" console "$Player.console$" string "$S);
	ConsoleString = S;
	if ( (Type == 'Say') || (Type == 'TeamSay') )
		ConsoleString = PRI.PlayerName$": "$ConsoleString;

	Player.Console.Message( ConsoleString, 6.0 );
	myHUD.Message( PRI, S, Type );
}

simulated function PlayBeepSound();

//Play a sound client side (so only client will hear it
simulated function ClientPlaySound(sound ASound, optional bool bVolumeControl )
{
	local int i;

	if ( !bVolumeControl )
		ViewTarget.PlaySound(ASound);
	else
		for ( i=0; i<AnnouncerVolume; i++ )
			ViewTarget.PlaySound(ASound);
}

simulated function ClientReliablePlaySound(sound ASound, optional bool bVolumeControl )
{
	ClientPlaySound(ASound, bVolumeControl);
}

simulated event Destroyed()
{
	local SavedMove Next;

	if ( Pawn != None )
	{
		Pawn.Health = 0;
		Pawn.Died( self, class'Suicided', Pawn.Location );
	}
	Super.Destroyed();
	myHud.Destroy();

	while ( FreeMoves != None )
	{
		Next = FreeMoves.NextMove;
		FreeMoves.Destroy();
		FreeMoves = Next;
	}
	while ( SavedMoves != None )
	{
		Next = SavedMoves.NextMove;
		SavedMoves.Destroy();
		SavedMoves = Next;
	}
}

// ------------------------------------------------------------------------
// Zooming/FOV change functions

function ToggleZoom()
{
	if ( DefaultFOV != DesiredFOV )
		EndZoom();
	else
		StartZoom();
}

function StartZoom()
{
	ZoomLevel = 0.0;
	bZooming = true;
}

function StopZoom()
{
	bZooming = false;
}

function EndZoom()
{
	bZooming = false;
	DesiredFOV = DefaultFOV;
}

function FixFOV()
{
	FOVAngle = Default.DefaultFOV;
	DesiredFOV = Default.DefaultFOV;
	DefaultFOV = Default.DefaultFOV;
}

function SetFOV(float NewFOV)
{
	DesiredFOV = NewFOV;
	FOVAngle = NewFOV;
}

function ResetFOV()
{
	DesiredFOV = DefaultFOV;
	FOVAngle = DefaultFOV;
}

exec function FOV(float F)
{
	if( (F >= 80.0) || (Level.Netmode==NM_Standalone) )
	{
		DefaultFOV = FClamp(F, 1, 170);
		DesiredFOV = DefaultFOV;
		SaveConfig();
	}
}

exec function ForceReload()
{
	if ( (Pawn != None) && (Pawn.Weapon != None) )
		Pawn.Weapon.ForceReload();
}

// ------------------------------------------------------------------------
// Messaging functions

// Send a message to all players.
exec function Say( string Msg )
{
	Level.Game.Broadcast(self, Msg, 'Say');
}

exec function TeamSay( string Msg )
{
	Level.Game.BroadcastTeam(self, Msg, 'Say');
}
// ------------------------------------------------------------------------

function ServerSetHandedness( float hand)
{
	Handedness = hand;
	if ( Pawn.Weapon != None )
		Pawn.Weapon.SetHand(Handedness);
}

function SetHand()
{
	Pawn.Weapon.SetHand(Handedness);
	ServerSetHandedness(Handedness);
}

function ChangeSetHand( string S )
{
	if ( S ~= "Left" )
		Handedness = -1;
	else if ( S~= "Right" )
		Handedness = 1;
	else if ( S ~= "Center" )
		Handedness = 0;
	else if ( S ~= "Hidden" )
		Handedness = 2;
	SetHand();
}

event PreClientTravel()
{
}

function ClientSetFixedCamera(bool B)
{
	bFixedCamera = B;
}

function ClientSetBehindView(bool B)
{
	bBehindView = B;
}

function ClientReplicateSkins(Material Skin1, optional Material Skin2, optional Material Skin3, optional Material Skin4)
{
	// do nothing (just loading other player skins onto client)
	log("Getting "$Skin1$", "$Skin2$", "$Skin3$", "$Skin4);
	return;
}

/*function CheckBob(float DeltaTime, float Speed2D, vector Y)
{
	if ( Speed2D < 10 )
		BobTime += 0.2 * DeltaTime;
	else
		BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/Pawn.GroundSpeed);
	WalkBob = Y * 0.4 * Bob * Speed2D * sin(8 * BobTime);
	AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
	if ( Speed2D < 10 )
		WalkBob.Z = AppliedBob;
	else
		WalkBob.Z = AppliedBob + 0.3 * Bob * Speed2D * sin(16 * BobTime);
	if ( LandBob > 0.01 )
	{
		AppliedBob += FMin(1, 16 * deltatime) * LandBob;
		LandBob *= (1 - 8*Deltatime);
	}
}*/
native(504) static final function CheckBob(float DeltaTime, float Speed2D, vector Y);


/* --> Become a 100% C++ virtual function
function vector WeaponBob(float BobDamping)
{
	Local Vector WBob;

	WBob = BobDamping * WalkBob;
	WBob.Z = (0.45 + 0.55 * BobDamping) * WalkBob.Z;

	return (WBob + 0.9 * ShakeOffset);
}*/


function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	local VoicePack V;

	if ( (Sender == None) || (Sender.voicetype == None) || (Player.Console == None) )
		return;

	V = Spawn(Sender.voicetype, self);
	if ( V != None )
		V.ClientInitialize(Sender, Recipient, messagetype, messageID);
}

/* ForceDeathUpdate()
Make sure ClientAdjustPosition immediately informs client of pawn's death
*/
function ForceDeathUpdate()
{
	LastUpdateTime = Level.TimeSeconds - 10;
}

/* ShortServerMove()
compressed version of server move for bandwidth saving
*/
function ShortServerMove
(
	float TimeStamp,
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus,
	byte ClientRoll,
	int View
)
{
	ServerMove(TimeStamp,vect(0,0,0),ClientLoc,NewbRun,NewbDuck,NewbJumpStatus,DCLICK_None,ClientRoll,View);
}

/* ServerMove()
- replicated function sent by client to server - contains client movement and firing info
Passes acceleration in components so it doesn't get rounded.
*/
function ServerMove
(
	float TimeStamp,
	vector InAccel,
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus,
	eDoubleClickDir DoubleClickMove,
	byte ClientRoll,
	int View,
	optional byte OldTimeDelta,
	optional int OldAccel
)
{
	local float DeltaTime, clientErr, OldTimeStamp;
	local rotator DeltaRot, Rot, ViewRot;
	local vector Accel, LocDiff, ClientVel, ClientFloor;
	local int maxPitch, ViewPitch, ViewYaw;
	local bool NewbPressedJump, OldbRun, OldbDuck;
	local eDoubleClickDir OldDoubleClickMove;
	local actor ClientBase;
	local ePhysics ClientPhysics;

	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= TimeStamp )
		return;

	// if OldTimeDelta corresponds to a lost packet, process it first
	if (  OldTimeDelta != 0 )
	{
		OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
		if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
		{
			// split out components of lost move (approx)
			Accel.X = OldAccel >>> 23;
			if ( Accel.X > 127 )
				Accel.X = -1 * (Accel.X - 128);
			Accel.Y = (OldAccel >>> 15) & 255;
			if ( Accel.Y > 127 )
				Accel.Y = -1 * (Accel.Y - 128);
			Accel.Z = (OldAccel >>> 7) & 255;
			if ( Accel.Z > 127 )
				Accel.Z = -1 * (Accel.Z - 128);
			Accel *= 20;

			OldbRun = ( (OldAccel & 64) != 0 );
			OldbDuck = ( (OldAccel & 32) != 0 );
			NewbPressedJump = ( (OldAccel & 16) != 0 );
			if ( NewbPressedJump )
				bJumpStatus = NewbJumpStatus;

			switch (OldAccel & 7)
			{
				case 0:
					OldDoubleClickMove = DCLICK_None;
					break;
				case 1:
					OldDoubleClickMove = DCLICK_Left;
					break;
				case 2:
					OldDoubleClickMove = DCLICK_Right;
					break;
				case 3:
					OldDoubleClickMove = DCLICK_Forward;
					break;
				case 4:
					OldDoubleClickMove = DCLICK_Back;
					break;
			}
			//log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
			MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, OldbDuck, NewbPressedJump, OldDoubleClickMove, Accel, rot(0,0,0));
			CurrentTimeStamp = OldTimeStamp;
		}
	}

	// View components
	ViewPitch = View/32768;
	ViewYaw = 2 * (View - 32768 * ViewPitch);
	ViewPitch *= 2;
	// Make acceleration.
	Accel = InAccel/10;

	NewbPressedJump = (bJumpStatus != NewbJumpStatus);
	bJumpStatus = NewbJumpStatus;

	// Save move parameters.
	DeltaTime = TimeStamp - CurrentTimeStamp;
	if ( ServerTimeStamp > 0 )
	{
		// allow 1% error
		TimeMargin += DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp);
		if ( TimeMargin > MaxTimeMargin )
		{
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = Default.MaxTimeMargin;
			else
				MaxTimeMargin = 0.5;
			DeltaTime = 0;
		}
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	ViewRot.Pitch = ViewPitch;
	ViewRot.Yaw = ViewYaw;
	ViewRot.Roll = 0;
	SetRotation(ViewRot);

	if ( Pawn != None )
	{
		Rot.Roll = 256 * ClientRoll;
		Rot.Yaw = ViewYaw;
		if ( (Pawn.Physics == PHYS_Swimming) || (Pawn.Physics == PHYS_Flying) )
			maxPitch = 2;
		else
			maxPitch = 1;
		If ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
		{
			If (ViewPitch < 32768)
				Rot.Pitch = maxPitch * RotationRate.Pitch;
			else
				Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
		}
		else
			Rot.Pitch = ViewPitch;
		DeltaRot = (Rotation - Rot);
		Pawn.SetRotation(Rot);
    if ( Pawn.ControllerPitch != Rotation.Pitch / 256 ) // test to avoid bNetDirtied by useless change
  		Pawn.ControllerPitch = ViewPitch / 256;
//		Log("Setting Pawn.controllerPitch="$Pawn.ControllerPitch);
	}

	// Perform actual movement.
	if ( (Level.Pauser == None) && (DeltaTime > 0) )
		MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, DoubleClickMove, Accel, DeltaRot);

	// Accumulate movement error.
	if ( Level.TimeSeconds - LastUpdateTime > 0.3 )
		ClientErr = 10000;
	else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
	{
		if ( Pawn == None )
			LocDiff = Location - ClientLoc;
		else
			LocDiff = Pawn.Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}

	// If client has accumulated a noticeable positional error, correct him.
	if ( ClientErr > 3 )
	{
		if ( Pawn == None )
		{
			ClientPhysics = Physics;
			ClientLoc = Location;
			ClientVel = Velocity;
		}
		else
		{
			ClientPhysics = Pawn.Physics;
			ClientVel = Pawn.Velocity;
			ClientBase = Pawn.Base;
			if ( Mover(Pawn.Base) != None )
				ClientLoc = Pawn.Location - Pawn.Base.Location;
			else
				ClientLoc = Pawn.Location;
			ClientFloor = Pawn.Floor;
		}
		//log("Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Pawn.Physics);
		LastUpdateTime = Level.TimeSeconds;

		if ( (Pawn == None) || (Pawn.Physics != PHYS_Spider) )
		{
			if ( ClientVel == vect(0,0,0) )
			{
				if ( IsInState('PlayerWalking') && (Pawn != None) && (Pawn.Physics == PHYS_Walking) )
				{
					VeryShortClientAdjustPosition
					(
						TimeStamp,
						ClientLoc.X,
						ClientLoc.Y,
						ClientLoc.Z,
						ClientBase
					);
				}
				else
					ShortClientAdjustPosition
					(
						TimeStamp,
						GetStateName(),
						ClientPhysics,
						ClientLoc.X,
						ClientLoc.Y,
						ClientLoc.Z,
						ClientBase
					);
			}
			else
				ClientAdjustPosition
				(
					TimeStamp,
					GetStateName(),
					ClientPhysics,
					ClientLoc.X,
					ClientLoc.Y,
					ClientLoc.Z,
					ClientVel.X,
					ClientVel.Y,
					ClientVel.Z,
					ClientBase
				);
		}
		else
			LongClientAdjustPosition
			(
				TimeStamp,
				GetStateName(),
				ClientPhysics,
				ClientLoc.X,
				ClientLoc.Y,
				ClientLoc.Z,
				ClientVel.X,
				ClientVel.Y,
				ClientVel.Z,
				ClientBase,
				ClientFloor.X,
				ClientFloor.Y,
				ClientFloor.Z
			);
	}
	//log("Server moved stamp "$TimeStamp$" location "$Pawn.Location$" Acceleration "$Pawn.Acceleration$" Velocity "$Pawn.Velocity);

    /*  To track down some multiplayer problems...
    //debuglog("In ServerMove()");
    //DumpContent(TimeStamp, 2);
    DumpChosenContent(TimeStamp);
    */
}

function ProcessMove ( float DeltaTime, vector newAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
{
	if ( Pawn != None )
		Pawn.Acceleration = newAccel;
}

final function MoveAutonomous
(
	float DeltaTime,
	bool NewbRun,
	bool NewbDuck,
	bool NewbPressedJump,
	eDoubleClickDir DoubleClickMove,
	vector newAccel,
	rotator DeltaRot
)
{
	if ( NewbRun )
		bRun = 1;
	else
		bRun = 0;

	if ( NewbDuck )
		bDuck = 1;
	else
		bDuck = 0;
	bPressedJump = NewbPressedJump;

	HandleWalking();
	ProcessMove(DeltaTime, newAccel, DoubleClickMove, DeltaRot);
	if ( Pawn != None )
		Pawn.AutonomousPhysics(DeltaTime);
	else
		AutonomousPhysics(DeltaTime);
	//log("Role "$Role$" moveauto time "$100 * DeltaTime$" ("$Level.TimeDilation$")");
}

/* VeryShortClientAdjustPosition
bandwidth saving version, when velocity is zeroed, and pawn is walking
*/
function VeryShortClientAdjustPosition
(
	float TimeStamp,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	Actor NewBase
)
{
	local vector Floor;

	if ( Pawn != None )
		Floor = Pawn.Floor;
	LongClientAdjustPosition(TimeStamp,'PlayerWalking',PHYS_Walking,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* ShortClientAdjustPosition
bandwidth saving version, when velocity is zeroed
*/
function ShortClientAdjustPosition
(
	float TimeStamp,
	name newState,
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	Actor NewBase
)
{
	local vector Floor;

	if ( Pawn != None )
		Floor = Pawn.Floor;
	LongClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* ClientAdjustPosition
- pass newloc and newvel in components so they don't get rounded
*/
function ClientAdjustPosition
(
	float TimeStamp,
	name newState,
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	float NewVelX,
	float NewVelY,
	float NewVelZ,
	Actor NewBase
)
{
	local vector Floor;

	if ( Pawn != None )
		Floor = Pawn.Floor;
	LongClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,NewVelX,NewVelY,NewVelZ,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* LongClientAdjustPosition
long version, when care about pawn's floor normal
*/
function LongClientAdjustPosition
(
	float TimeStamp,
	name newState,
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	float NewVelX,
	float NewVelY,
	float NewVelZ,
	Actor NewBase,
	float NewFloorX,
	float NewFloorY,
	float NewFloorZ
)
{
	local vector NewLocation, NewFloor;
	local Actor MoveActor;

	if ( Pawn != None )
	{
		if ( Pawn.bTearOff )
		{
			Pawn = None;
			GotoState('Dead');
			return;
		}
		MoveActor = Pawn;
	}
	else
		MoveActor = self;

	if ( CurrentTimeStamp > TimeStamp )
		return;
	CurrentTimeStamp = TimeStamp;

	NewLocation.X = NewLocX;
	NewLocation.Y = NewLocY;
	NewLocation.Z = NewLocZ;
	MoveActor.Velocity.X = NewVelX;
	MoveActor.Velocity.Y = NewVelY;
	MoveActor.Velocity.Z = NewVelZ;

	NewFloor.X = NewFloorX;
	NewFloor.Y = NewFloorY;
	NewFloor.Z = NewFloorZ;
	MoveActor.SetBase(NewBase, NewFloor);
	if ( Mover(NewBase) != None )
		NewLocation += NewBase.Location;

	//log("Client "$Role$" adjust "$self$" stamp "$TimeStamp$" location "$MoveActor.Location);
	MoveActor.bCanTeleport = false;
	MoveActor.SetLocation(NewLocation);
	MoveActor.bCanTeleport = true;
	MoveActor.SetPhysics(newPhysics);

	if( GetStateName() != newstate )
		GotoState(newstate);

	bUpdatePosition = true;

    /*  To track down some multiplayer problems...
    //debuglog("In LongClientAdjustPosition():");
    //DumpContent(TimeStamp, 2);
    DumpChosenContent(TimeStamp);
    */
}

function ClientUpdatePosition()
{
	local SavedMove CurrentMove;
	local int realbRun, realbDuck;
	local bool bRealJump;
	local float TotalTime;

	bUpdatePosition = false;
	realbRun= bRun;
	realbDuck = bDuck;
	bRealJump = bPressedJump;
	CurrentMove = SavedMoves;
	bUpdating = true;
	while ( CurrentMove != None )
	{
		if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;
		}
		else
		{
			if ( (TotalTime > 0) && (Pawn != None) )
				AdjustRadius(CurrentMove.Delta * Pawn.GroundSpeed);
			TotalTime += CurrentMove.Delta;
			MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.bPressedJump, CurrentMove.DoubleClickMove, CurrentMove.Acceleration, rot(0,0,0));
			CurrentMove = CurrentMove.NextMove;
		}
	}
	//log("Client updated position to "$Pawn.Location);
	bUpdating = false;
	bDuck = realbDuck;
	bRun = realbRun;
	bPressedJump = bRealJump;
}

function AdjustRadius(float MaxMove)
{
	local Pawn P;
	local vector Dir;

	// if other pawn moving away from player, push it away if its close
	// since the client-side position is behind the server side position
	ForEach DynamicActors(class'Pawn', P)
		if ( (P != Pawn) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
		{
			Dir = Normal(P.Location - Pawn.Location);
			if ( (Pawn.Velocity Dot Dir > 0) && (P.Velocity Dot Dir > 0) )
			{
				if ( VSize(P.Location - Pawn.Location) < P.CollisionRadius + Pawn.CollisionRadius + MaxMove )
					P.MoveSmooth(P.Velocity * 0.5 * PlayerReplicationInfo.Ping);
			}
		}
}

final function SavedMove GetFreeMove()
{
	local SavedMove s, first;
	local int i;

	if ( FreeMoves == None )
	{
		// don't allow more than 30 saved moves
		For ( s=SavedMoves; s!=None; s=s.NextMove )
		{
			i++;
			if ( i > 30 )
			{
				first = SavedMoves;
				SavedMoves = SavedMoves.NextMove;
				first.Clear();
				first.NextMove = None;
				// clear out all the moves
				While ( SavedMoves != None )
				{
					s = SavedMoves;
					SavedMoves = SavedMoves.NextMove;
					s.Clear();
					s.NextMove = FreeMoves;
					FreeMoves = s;
				}
				return first;
			}
		}
		return Spawn(class'SavedMove');
	}
	else
	{
		s = FreeMoves;
		FreeMoves = FreeMoves.NextMove;
		s.NextMove = None;
		return s;
	}
}

function int CompressAccel(int C)
{
	if ( C >= 0 )
		C = Min(C, 127);
	else
		C = Min(abs(C), 127) + 128;
	return C;
}

/*
========================================================================
Here's how player movement prediction, replication and correction works in network games:

Every tick, the PlayerTick() function is called.  It calls the PlayerMove() function (which is implemented
in various states).  PlayerMove() figures out the acceleration and rotation, and then calls ProcessMove()
(for single player or listen servers), or ReplicateMove() (if its a network client).

ReplicateMove() saves the move (in the PendingMove list), calls ProcessMove(), and then replicates the move
to the server by calling the replicated function ServerMove() - passing the movement parameters, the client's
resultant position, and a timestamp.

ServerMove() is executed on the server.  It decodes the movement parameters and causes the appropriate movement
to occur.  It then looks at the resulting position and if enough time has passed since the last response, or the
position error is significant enough, the server calls ClientAdjustPosition(), a replicated function.

ClientAdjustPosition() is executed on the client.  The client sets its position to the servers version of position,
and sets the bUpdatePosition flag to true.

When PlayerTick() is called on the client again, if bUpdatePosition is true, the client will call
ClientUpdatePosition() before calling PlayerMove().  ClientUpdatePosition() replays all the moves in the pending
move list which occured after the timestamp of the move the server was adjusting.
*/

//
// Replicate this client's desired movement to the server.
//
function ReplicateMove
(
	float DeltaTime,
	vector NewAccel,
	eDoubleClickDir DoubleClickMove,
	rotator DeltaRot
)
{
	local SavedMove NewMove, OldMove, LastMove;
	local byte ClientRoll;
	local float OldTimeDelta, NetMoveDelta;
	local int i, OldAccel;
	local vector BuildAccel, AccelNorm, MoveLoc;

	// Get a SavedMove actor to store the movement in.
	if ( PendingMove != None )
		PendingMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);

	if ( SavedMoves != None )
	{
		NewMove = SavedMoves;
		AccelNorm = Normal(NewAccel);
		while ( NewMove.NextMove != None )
		{
			// find most recent interesting move to send redundantly
			if ( NewMove.bPressedJump || ((NewMove.DoubleClickMove != DCLICK_NONE) && (NewMove.DoubleClickMove < 5))
				|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
				OldMove = NewMove;
			NewMove = NewMove.NextMove;
		}
		if ( NewMove.bPressedJump || ((NewMove.DoubleClickMove != DCLICK_NONE) && (NewMove.DoubleClickMove < 5))
			|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
			OldMove = NewMove;
	}

	LastMove = NewMove;
	NewMove = GetFreeMove();
	if ( NewMove == None )
		return;
	NewMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);

	// adjust radius of nearby players with uncertain location
	if ( Pawn != None )
		AdjustRadius(NewMove.Delta * Pawn.GroundSpeed);

	// Simulate the movement locally.
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DoubleClickMove, DeltaRot);
	if ( Pawn != None )
		Pawn.AutonomousPhysics(NewMove.Delta);
	else
		AutonomousPhysics(DeltaTime);

	//log("Role "$Role$" repmove at "$Level.TimeSeconds$" Move time "$100 * DeltaTime$" ("$Level.TimeDilation$")");

	// Decide whether to hold off on move
	// send if double click move, jump, or fire unless really too soon, or if newmove.delta big enough
	// on client side, save extra buffered time in LastUpdateTime
	if ( PendingMove == None )
		PendingMove = NewMove;
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}
	NetMoveDelta = FMax(64.0/Player.CurrentNetSpeed, 0.011);

	if ( !PendingMove.bPressedJump && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
		// save as pending move
		return;
	}
	else if ( (ClientUpdateTime < 0) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
		return;
	else
	{
		ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
		if ( SavedMoves == None )
			SavedMoves = PendingMove;
		else
			LastMove.NextMove = PendingMove;
		PendingMove = None;
	}

	// check if need to redundantly send previous move
	if ( OldMove != None )
	{
		// log("Redundant send timestamp "$OldMove.TimeStamp$" accel "$OldMove.Acceleration$" at "$Level.Timeseconds$" New accel "$NewAccel);
		// old move important to replicate redundantly
		OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
		BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
		OldAccel = (CompressAccel(BuildAccel.X) << 23)
					+ (CompressAccel(BuildAccel.Y) << 15)
					+ (CompressAccel(BuildAccel.Z) << 7);
		if ( OldMove.bRun )
			OldAccel += 64;
		if ( OldMove.bDuck )
			OldAccel += 32;
		if ( OldMove.bPressedJump )
			OldAccel += 16;
		OldAccel += OldMove.DoubleClickMove;
	}
	//else
	//	log("No redundant timestamp at "$Level.TimeSeconds$" with accel "$NewAccel);
	//log("Replicate move at "$NewMove.TimeStamp$" location "$Pawn.Location);
	// Send to the server
	ClientRoll = (Rotation.Roll >> 8) & 255;
	if ( NewMove.bPressedJump )
		bJumpStatus = !bJumpStatus;

	if ( Pawn == None )
		MoveLoc = Location;
	else
		MoveLoc = Pawn.Location;

	if ( (NewMove.Acceleration == vect(0,0,0)) && (NewMove.DoubleClickMove == DCLICK_None) )
		ShortServerMove
		(
			NewMove.TimeStamp,
			MoveLoc,
			NewMove.bRun,
			NewMove.bDuck,
			bJumpStatus,
			ClientRoll,
			(32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2))
		);
	else
		ServerMove
		(
			NewMove.TimeStamp,
			NewMove.Acceleration * 10,
			MoveLoc,
			NewMove.bRun,
			NewMove.bDuck,
			bJumpStatus,
			NewMove.DoubleClickMove,
			ClientRoll,
			(32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)),
			OldTimeDelta,
			OldAccel
		);
}

/*function HandleWalking()
{
	if ( Pawn != None )
		Pawn.SetWalking(((bRun != 0) || (bDuck != 0)) && !Region.Zone.IsA('WarpZoneInfo'));
}*/
native(499) static final function HandleWalking();

function ServerRestartGame()
{
}

function SetFOVAngle(float newFOV)
{
	FOVAngle = newFOV;
}

function ClientFlash( float scale, vector fog )
{
	DesiredFlashScale = scale;
	DesiredFlashFog = 0.001 * fog;
}

function ClientInstantFlash( float scale, vector fog )
{
	InstantFlash = scale;
	InstantFog = 0.001 * fog;
}

function ClientAdjustGlow( float scale, vector fog )
{
	ConstantGlowScale = scale;
	ConstantGlowFog = 0.001 * fog;
}

function ClientFilter( Color FC, color FCW, float FCS )
{
	FilterColor = FC;
	FilterColorWanted = FCW;
	FilterColorSpeed = FCS;
}

function ClientHighLight( color TargetColor, float TargetHighLight, optional Material Mat )
{
/*
var byte UseVignetteFilter;
var byte UseVignetteHighlight;
var color VignetteColor;
var float VignetteHighLight;
var material VignetteMaterial;
*/
    if (TargetHighLight != 0)
    {
      UseVignetteFilter = 1;
      UseVignetteHighlight = 1;
      VignetteColor = TargetColor;
      VignetteHighLight = TargetHighLight;
      VignetteMaterial = Mat;
    }
    else
    {
      UseVignetteFilter = 0;
      UseVignetteHighlight = 0;
    }
}

/* ClientShake()
Function called on client to shake view.
Only ShakeView() should call ClientShake()
*/
private function ClientShake(vector ShakeRoll, vector OffsetMag, vector ShakeRate, float OffsetTime)
{
	if ( (MaxShakeRoll < ShakeRoll.X) || (ShakeRollTime < 0.01 * ShakeRoll.Y) )
	{
		MaxShakeRoll = ShakeRoll.X;
		ShakeRollTime = 0.01 * ShakeRoll.Y;
		ShakeRollRate = 0.01 * ShakeRoll.Z;
	}
	if ( VSize(OffsetMag) > VSize(MaxShakeOffset) )
	{
		ShakeOffsetTime = OffsetTime * vect(1,1,1);
		MaxShakeOffset = OffsetMag;
		ShakeOffsetRate = ShakeRate;
	}
//	if (MaxShakeFrame < ShakeFrameMag)
//	{
/*		MaxShakeFrame.X = 0.08;
		MaxShakeFrame.Y = 0.06;
		ShakeFrameTime = 10;
		ShakeFrameRate.X = 0.4;
		ShakeFrameRate.Y = 0.25;*/
//	}

}


/* ShakeView()
Call this function to shake the player's view
shaketime = how long to roll view
RollMag = how far to roll view as it shakes
OffsetMag = max view offset
RollRate = how fast to roll view
OffsetRate = how fast to offset view
OffsetTime = how long to offset view (number of shakes)
*/
function ShakeView( float shaketime, float RollMag, vector OffsetMag, float RollRate, vector OffsetRate, float OffsetTime)
{
	local vector ShakeRoll;

	ShakeRoll.X = RollMag;
	ShakeRoll.Y = 100 * shaketime;
	ShakeRoll.Z = 100 * rollrate;
	ClientShake(ShakeRoll, OffsetMag, OffsetRate, OffsetTime);
}

function damageAttitudeTo(pawn Other, float Damage)
{
	if ( (Other != None) && (Other != Pawn) && (Damage > 0) )
		Enemy = Other;
}

function Typing( bool bTyping )
{
	bIsTyping = bTyping;
	if ( bTyping && (Pawn != None) && !Pawn.bTearOff )
		Pawn.ChangeAnimation();

	if (Level.Game.StatLog != None)
		Level.Game.StatLog.LogTypingEvent(bTyping, Self);
}

//*************************************************************************************
// Normal gameplay execs
// Type the name of the exec function at the console to execute it

exec function Jump( optional float F )
{
	if ( Level.Pauser == PlayerReplicationInfo )
		SetPause(False);
	else
		bPressedJump = true;
}

// Send a voice message of a certain type to a certain player.
exec function Speech( int Type, int Index, int Callsign )
{
	local VoicePack V;

	V = Spawn( PlayerReplicationInfo.VoiceType, Self );
	if (V != None)
		V.PlayerSpeech( Type, Index, Callsign );
}

exec function RestartLevel()
{
	if( Level.Netmode==NM_Standalone )
		ClientTravel( "?restart", TRAVEL_Relative, false );
}

exec function LocalTravel( string URL )
{
	if( Level.Netmode==NM_Standalone )
		ClientTravel( URL, TRAVEL_Relative, true );
}

// ------------------------------------------------------------------------
// Loading and saving

/* QuickSave()
Save game to slot 9
*/
exec function QuickSave()
{
	if ( (Pawn.Health > 0)
		&& (Level.NetMode == NM_Standalone) )
	{
		ClientMessage(QuickSaveString);
		ConsoleCommand("SaveGame 9");
	}
}

/* QuickLoad()
Load game from slot 9
*/
exec function QuickLoad()
{
	if ( Level.NetMode == NM_Standalone )
		ClientTravel( "?load=9", TRAVEL_Absolute, false);
}

/* SetPause()
 Try to pause game; returns success indicator.
 Replicated to server in network games.
 */
function bool SetPause( BOOL bPause )
{
	local bool ret;

	if( bPause )
		ret = Level.Game.SetPause(True, self);
	else
		ret = Level.Game.SetPause(False, self);
	return ret;
}

/* Pause()
Command to try to pause the game.
*/
exec function Pause()
{
	if( !SetPause(Level.Pauser==None) )
		ClientMessage(NoPauseMessage);
}

// Activate specific inventory item
exec function ActivateInventoryItem( class InvItem )
{
	local Powerups Inv;

	Inv = Powerups(Pawn.FindInventoryType(InvItem));
	if ( Inv != None )
		Inv.Activate();
}

// ------------------------------------------------------------------------
// Weapon changing functions

/* ThrowWeapon()
Throw out current weapon, and switch to a new weapon
*/
exec function ThrowWeapon()
{
	if( Level.NetMode == NM_Client )
		return;
	if( Pawn.Weapon==None || !Pawn.Weapon.bCanThrow )
		return;
	Pawn.Weapon.bTossedOut = true;
	Pawn.TossWeapon(Vector(Rotation) * 500 + vect(0,0,220));
	if ( Pawn.Weapon == None )
		SwitchToBestWeapon();
}

/* PrevWeapon()
- switch to previous inventory group weapon
*/
exec function PrevWeapon()
{
	if( Level.Pauser!=None )
		return;
	if ( Pawn.Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	if ( Pawn.PendingWeapon != None )
		Pawn.PendingWeapon = Pawn.Inventory.PrevWeapon(None, Pawn.PendingWeapon);
	else
		Pawn.PendingWeapon = Pawn.Inventory.PrevWeapon(None, Pawn.Weapon);

	if ( Pawn.PendingWeapon != None )
		Pawn.Weapon.PutDown();
}

/* NextWeapon()
- switch to next inventory group weapon
*/
exec function NextWeapon()
{
	if( Level.Pauser!=None )
		return;
	if ( Pawn.Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	if ( Pawn.PendingWeapon != None )
		Pawn.PendingWeapon = Pawn.Inventory.NextWeapon(None, Pawn.PendingWeapon);
	else
		Pawn.PendingWeapon = Pawn.Inventory.NextWeapon(None, Pawn.Weapon);

	if ( Pawn.PendingWeapon != None )
		Pawn.Weapon.PutDown();
}

// The player wants to switch to weapon group number F.
exec function SwitchWeapon (byte F )
{
	local weapon newWeapon;

	if ( (Level.Pauser!=None) || (Pawn == None) || (Pawn.Inventory == None) )
		return;
	if ( (Pawn.Weapon != None) && (Pawn.Weapon.Inventory != None) )
		newWeapon = Pawn.Weapon.Inventory.WeaponChange(F);
	else
		newWeapon = None;
	if ( newWeapon == None )
		newWeapon = Pawn.Inventory.WeaponChange(F);

	if ( newWeapon == None )
		return;

	if ( Pawn.Weapon == None )
	{
		Pawn.PendingWeapon = newWeapon;
		Pawn.ChangedWeapon();
	}
	else if ( Pawn.Weapon != newWeapon )
	{
		Pawn.PendingWeapon = newWeapon;
		if ( !Pawn.Weapon.PutDown() )
			Pawn.PendingWeapon = None;
	}
}

exec function GetWeapon(class<Weapon> NewWeaponClass )
{
	local Inventory Inv;

	if ( (Pawn.Inventory == None) || (NewWeaponClass == None)
		|| ((Pawn.Weapon != None) && (Pawn.Weapon.Class == NewWeaponClass)) )
		return;

	for ( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Inv.Class == NewWeaponClass )
		{
			Pawn.PendingWeapon = Weapon(Inv);
			if ( !Pawn.PendingWeapon.HasAmmo() )
			{
				ClientMessage( Pawn.PendingWeapon.ItemName$Pawn.PendingWeapon.MessageNoAmmo );
				Pawn.PendingWeapon = None;
				return;
			}
			Pawn.Weapon.PutDown();
			return;
		}
}

// The player wants to select previous item
exec function PrevItem()
{
	local Inventory Inv;
	local Powerups LastItem;

	if ( Level.Pauser!=None )
		return;
	if (Pawn.SelectedItem==None)
	{
		Pawn.SelectedItem = Inventory.SelectNext();
		Return;
	}
	if (Pawn.SelectedItem.Inventory!=None)
		for( Inv=Pawn.SelectedItem.Inventory; Inv!=None; Inv=Inv.Inventory )
		{
			if (Inv==None) Break;
			if ( Inv.IsA('Powerups') && Powerups(Inv).bActivatable) LastItem=Powerups(Inv);
		}
	for( Inv=Pawn.Inventory; Inv!=Pawn.SelectedItem; Inv=Inv.Inventory )
	{
		if (Inv==None) Break;
		if ( Inv.IsA('Powerups') && Powerups(Inv).bActivatable) LastItem=Powerups(Inv);
	}
	if (LastItem!=None)
		Pawn.SelectedItem = LastItem;
}

// The player wants to active selected item
exec function ActivateItem()
{
	if( Level.Pauser!=None )
		return;
	if ( (Pawn != None) && (Pawn.SelectedItem!=None) )
		Pawn.SelectedItem.Activate();
}

// The player wants to fire.
exec function Fire( optional float F )
{
	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}
	if( Pawn.Weapon!=None )
		Pawn.Weapon.Fire(F);
}

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}
	if( Pawn.Weapon!=None )
		Pawn.Weapon.AltFire(F);
}

// The player wants to use something in the level.
exec function Use()
{
	local Actor A;

	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}

	// Send the 'DoUse' event to each actor player is touching.
	ForEach Pawn.TouchingActors(class'Actor', A)
	{
		A.UsedBy(Pawn);
	}
}

exec function Suicide()
{
	Pawn.KilledBy( Pawn );
}

function Name( coerce string S )
{
	S = Left(S,15);

    ChangeName(S);
	UpdateURL("Name", S, true);
	SaveConfig();
}

function ChangeName( coerce string S )
{
	if ( Len(S) > 28 )
		S = left(S,28);
	ReplaceText(S, " ", "_");
	Level.Game.ChangeName( self, S, false );
}

exec function SwitchTeam()
{
	if ( (PlayerReplicationInfo.Team == None) || (PlayerReplicationInfo.Team.TeamIndex == 1) )
		ChangeTeam(0);
	else
		ChangeTeam(1);
}

function ChangeTeam( int N )
{
	local TeamInfo OldTeam;

	OldTeam = PlayerReplicationInfo.Team;
	Level.Game.ChangeTeam(self, N);
	if ( Level.Game.bTeamGame && (PlayerReplicationInfo.Team != OldTeam) )
		Pawn.Died( self, class'DamageType', Pawn.Location );
}


exec function SwitchLevel( string URL )
{
	if( Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
		Level.ServerTravel( URL, false );
}

exec function ClearProgressMessages()
{
	local int i;

	for (i=0; i<ArrayCount(ProgressMessage); i++)
	{
		ProgressMessage[i] = "";
		ProgressColor[i] = class'Canvas'.Static.MakeColor(255,255,255);
	}
}

exec event SetProgressMessage( int Index, string S, color C )
{
	if ( Index < ArrayCount(ProgressMessage) )
	{
		ProgressMessage[Index] = S;
		ProgressColor[Index] = C;
	}
}

exec event SetProgressTime( float T )
{
	ProgressTimeOut = T + Level.TimeSeconds;
}

function Restart()
{
	ServerTimeStamp = 0;
	TimeMargin = 0;
	Enemy = None;
	EnterStartState();
	SetViewTarget(Pawn);
	bBehindView = Pawn.PointOfView();
	ClientRestart();
}

function EnterStartState()
{
	local name NewState;

	if ( Pawn.PhysicsVolume.bWaterVolume )
	{
		if ( Pawn.HeadVolume.bWaterVolume )
			Pawn.BreathTime = Pawn.UnderWaterTime;
		NewState = Pawn.WaterMovementState;
	}
	else
		NewState = Pawn.LandMovementState;

	if ( IsInState(NewState) )
		BeginState();
	else
		GotoState(NewState);
}

function ClientRestart()
{
/*
	if ( Pawn == None )
	{
		GotoState('WaitingForPawn');
		return;
	}
	Pawn.ClientRestart();
	SetViewTarget(Pawn);
	bBehindView = Pawn.PointOfView();
	EnterStartState();
*/
}

exec function BehindView( Bool B )
{
	bBehindView = B;
	ClientSetBehindView(bBehindView);
}

function UpdateBob(float F)
{
	Bob = FClamp(F,0,0.032);
}


//=============================================================================
// functions.

// Just changed to pendingWeapon
function ChangedWeapon()
{
	if ( Pawn.PendingWeapon != None )
		Pawn.PendingWeapon.SetHand(Handedness);
}

event TravelPostAccept()
{
	if ( Pawn.Health <= 0 )
		Pawn.Health = Pawn.Default.Health;
}

event PlayerTick( float DeltaTime )
{
	if ( bUpdatePosition )
		ClientUpdatePosition();

	PlayerMove(DeltaTime);
}

function PlayerMove(float DeltaTime);


//
/* AdjustAim()
Calls this version for player aiming help.
Aimerror not used in this version.
Only adjusts aiming at pawns
*/
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror);
/*
{
	local vector FireDir, AimSpot, HitNormal, HitLocation, OldAim, AimOffset;
	local actor BestTarget;
	local float bestAim, bestDist, projspeed;
	local actor HitActor;
	local bool bNoZAdjust, bLeading;
	local rotator AimRot;

	FireDir = vector(Rotation);
	if ( FiredAmmunition.bInstantHit )
		HitActor = Trace(HitLocation, HitNormal, projStart + 10000 * FireDir, projStart, true);
	else
		HitActor = Trace(HitLocation, HitNormal, projStart + 4000 * FireDir, projStart, true);
	if ( (HitActor != None) && HitActor.bProjTarget )
	{
		FiredAmmunition.WarnTarget(Target,Pawn,FireDir);
		BestTarget = HitActor;
		bNoZAdjust = true;
		OldAim = HitLocation;
		BestDist = VSize(BestTarget.Location - Pawn.Location);
	}
	else
	{
		// adjust aim based on FOV
		bestAim = 0.95;
		if ( AimingHelp == 1 )
		{
			bestAim = 0.93;
			if ( FiredAmmunition.bInstantHit )
				bestAim = 0.97;
			if ( FOVAngle < DefaultFOV - 8 )
				bestAim = 0.99;
		}
		else
		{
			if ( FiredAmmunition.bInstantHit )
				bestAim = 0.98;
			if ( FOVAngle != DefaultFOV )
				bestAim = 0.995;
		}
		BestTarget = PickTarget(bestAim, bestDist, FireDir, projStart);
		if ( BestTarget == None )
			return Rotation;
		FiredAmmunition.WarnTarget(Target,Pawn,FireDir);
		OldAim = projStart + FireDir * bestDist;
	}
	if ( AimingHelp == 0 )
		return Rotation;

	// aim at target - help with leading also
	if ( !FiredAmmunition.bInstantHit )
	{
		projspeed = FiredAmmunition.ProjectileClass.default.speed;
		BestDist = vsize(BestTarget.Location + BestTarget.Velocity * FMin(2, 0.02 + BestDist/projSpeed) - projStart);
		bLeading = true;
		FireDir = BestTarget.Location + BestTarget.Velocity * FMin(2, 0.02 + BestDist/projSpeed) - projStart;
		AimSpot = projStart + bestDist * Normal(FireDir);
		// if splash damage weapon, try aiming at feet - trace down to find floor
	}
	else
	{
		FireDir = BestTarget.Location - projStart;
		AimSpot = projStart + bestDist * Normal(FireDir);
	}
	AimOffset = AimSpot - OldAim;

	// adjust Z of shooter if necessary
	if ( bNoZAdjust || (bLeading && (Abs(AimOffset.Z) < BestTarget.CollisionHeight)) )
		AimSpot.Z = OldAim.Z;
	else if ( AimOffset.Z < 0 )
		AimSpot.Z = BestTarget.Location.Z + 0.4 * BestTarget.CollisionHeight;
	else
		AimSpot.Z = BestTarget.Location.Z - 0.7 * BestTarget.CollisionHeight;

	if ( !bLeading )
	{
		// if not leading, add slight random error ( significant at long distances )
		if ( !bNoZAdjust )
		{
			AimRot = rotator(AimSpot - projStart);
			if ( FOVAngle < DefaultFOV - 8 )
				AimRot.Yaw = AimRot.Yaw + 200 - Rand(400);
			else
				AimRot.Yaw = AimRot.Yaw + 375 - Rand(750);
			return AimRot;
		}
	}
	else if ( !FastTrace(projStart + 0.9 * bestDist * Normal(FireDir), projStart) )
	{
		FireDir = BestTarget.Location - projStart;
		AimSpot = projStart + bestDist * Normal(FireDir);
	}

	return rotator(AimSpot - projStart);
}
*/

native(498) static final function rotator AdjustAimForDisplay(Ammunition FiredAmmunition, vector projStart);

function bool NotifyLanded(vector HitNormal)
{
	if ( bUpdating )
		return true;
	LandBob = FMin(50, 0.055 * Pawn.Velocity.Z);
	return false;
}

function eAttitude AttitudeTo(Pawn Other)
{
	if ( Other.Controller == None )
		return ATTITUDE_Ignore;
	if ( Other.IsPlayerPawn() )
		return AttitudeToPlayer;
	return Other.Controller.AttitudeToPlayer;
}

//=============================================================================
// Player Control

// Player view.
// Compute the rendering viewpoint for the player.
//

function AdjustView(float DeltaTime )
{
	// teleporters affect your FOV, so adjust it back down
	if ( FOVAngle != DesiredFOV )
	{
		if ( FOVAngle > DesiredFOV )
			FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
		else
			FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
		if ( Abs(FOVAngle - DesiredFOV) <= 10 )
			FOVAngle = DesiredFOV;
	}

	// adjust FOV for weapon zooming
	if ( bZooming )
	{
		ZoomLevel += DeltaTime * 1.0;
		if (ZoomLevel > 0.9)
			ZoomLevel = 0.9;
		DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
	}
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	CameraRotation = Rotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View;
}

/*function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
{
	// First-person view.
	CameraRotation = Rotation;
	CameraLocation = CameraLocation + Pawn.EyePosition() + WalkBob + ShakeOffset;
}*/
native(497) static final function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation );

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local Pawn PTarget;

	if ( (ViewTarget == None) || ViewTarget.bDeleteMe )
	{
		if ( (Pawn != None) && !Pawn.bDeleteMe )
			SetViewTarget(Pawn);
		else
			SetViewTarget(self);
	}

	ViewActor = ViewTarget;
	CameraLocation = ViewTarget.Location;

	if ( ViewTarget == Pawn )
	{
		if( bBehindView ) //up and behind
			CalcBehindView(CameraLocation, CameraRotation, CameraDist * Pawn.Default.CollisionRadius);
		else
			CalcFirstPersonView( CameraLocation, CameraRotation );
		return;
	}
	if ( ViewTarget == self )
	{
		CameraRotation = Rotation;
		return;
	}
	CameraRotation = ViewTarget.Rotation;
	PTarget = Pawn(ViewTarget);
	if ( PTarget != None )
	{
		if ( Level.NetMode == NM_Client )
		{
			if ( PTarget.IsPlayerPawn() )
			{
				PTarget.SetViewRotation(TargetViewRotation);
				CameraRotation = TargetViewRotation;
			}
			PTarget.EyeHeight = TargetEyeHeight;
			if ( PTarget.Weapon != None )
				PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
		}
		else if ( PTarget.IsPlayerPawn() )
			CameraRotation = PTarget.GetViewRotation();
		if ( !bBehindView )
			CameraLocation += PTarget.EyePosition();
	}
	if ( bBehindView )
	{
		CameraLocation = CameraLocation + (ViewTarget.Default.CollisionHeight - ViewTarget.CollisionHeight) * vect(0,0,1);
		CalcBehindView(CameraLocation, CameraRotation, CameraDist * ViewTarget.Default.CollisionRadius);
	}
}

/*function CheckShake(out float MaxOffset, out float Offset, out float Rate, out float Time)
{
	if ( abs(Offset) < abs(MaxOffset) )
		return;

	Offset = MaxOffset;
	if ( Time > 1 )
	{
		if ( Time * abs(MaxOffset/Rate) <= 1 )
			MaxOffset = MaxOffset * (1/Time - 1);
		else
			MaxOffset *= -1;
		Time -= 1;
		Rate *= -1;
	}
	else
	{
		MaxOffset = 0;
		Offset = 0;
		Rate = 0;
	}
}

function ViewShake(float DeltaTime)
{
	local Rotator ViewRotation;
	local float FRoll;

	if ( ShakeOffsetRate != vect(0,0,0) )
	{
		// modify shake offset
		ShakeOffset.X += DeltaTime * ShakeOffsetRate.X;
		CheckShake(MaxShakeOffset.X, ShakeOffset.X, ShakeOffsetRate.X, ShakeOffsetTime.X);

		ShakeOffset.Y += DeltaTime * ShakeOffsetRate.Y;
		CheckShake(MaxShakeOffset.Y, ShakeOffset.Y, ShakeOffsetRate.Y, ShakeOffsetTime.Y);

		ShakeOffset.Z += DeltaTime * ShakeOffsetRate.Z;
		CheckShake(MaxShakeOffset.Z, ShakeOffset.Z, ShakeOffsetRate.Z, ShakeOffsetTime.Z);
	}

	ViewRotation = Rotation;

	if ( ShakeRollRate != 0 )
	{
		ViewRotation.Roll = ((ViewRotation.Roll & 65535) + ShakeRollRate * DeltaTime) & 65535;
		if ( ViewRotation.Roll > 32768 )
			ViewRotation.Roll -= 65536;
		FRoll = ViewRotation.Roll;
		CheckShake(MaxShakeRoll, FRoll, ShakeRollRate, ShakeRollTime);
		ViewRotation.Roll = FRoll;
	}
	else if ( bZeroRoll )
		ViewRotation.Roll = 0;
	SetRotation(ViewRotation);
}*/
native(496) static final function ViewShake(float DeltaTime);

function bool TurnTowardNearestEnemy();

function TurnAround()
{
	if ( !bSetTurnRot )
	{
		TurnRot180 = Rotation;
		TurnRot180.Yaw += 32768;
		bSetTurnRot = true;
	}

	DesiredRotation = TurnRot180;
	bRotateToDesired = ( DesiredRotation.Yaw != Rotation.Yaw );
}

function UpdateRotation(float DeltaTime, float maxPitch)
{
	local rotator newRotation, ViewRotation;

	if ( bInterpolating || ((Pawn != None) && Pawn.bInterpolating) )
	{
		ViewShake(deltaTime);
		return;
	}
	ViewRotation = Rotation;
	DesiredRotation = ViewRotation; //save old rotation
	if ( bTurnToNearest != 0 )
		TurnTowardNearestEnemy();
	else if ( bTurn180 != 0 )
		TurnAround();
	else
	{
		TurnTarget = None;
		bRotateToDesired = false;
		bSetTurnRot = false;
		ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
		ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
	}
	ViewRotation.Pitch = ViewRotation.Pitch & 65535;
	If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
	{
		If (aLookUp > 0)
			ViewRotation.Pitch = 18000;
		else
			ViewRotation.Pitch = 49152;
	}

	SetRotation(ViewRotation);
	ViewShake(deltaTime);
	ViewFlash(deltaTime);

	NewRotation = ViewRotation;
	NewRotation.Roll = Rotation.Roll;

	if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
		Pawn.FaceRotation(NewRotation, deltatime);
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, Bump;

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector OldAccel;
		local bool OldCrouch;

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		if ( bPressedJump )
			Pawn.DoJump(bUpdating);
		if ( Pawn.Physics != PHYS_Falling )
		{
			OldCrouch = Pawn.bWantsToCrouch;
			if (bDuck == 0)
				Pawn.ShouldCrouch(false);
			else if ( Pawn.bCanCrouch )
				Pawn.ShouldCrouch(true);
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local eDoubleClickDir DoubleClickMove;
		local rotator OldRotation, ViewRotation;
		local float Speed2D;
		local bool	bSaveJump;

		GetAxes(Pawn.Rotation,X,Y,Z);

		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y;
		NewAccel.Z = 0;
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);
		DoubleClickMove = PlayerInput.CheckForDoubleClickMove(DeltaTime);

		GroundPitch = 0;
		ViewRotation = Rotation;
		if ( Pawn.Physics == PHYS_Walking )
		{
			// tell pawn about any direction changes to give it a chance to play appropriate animation
			//if walking, look up/down stairs - unless player is rotating view
			GroundPitch = FindStairRotation(deltaTime);
			if ( (bLook == 0)
				&& (((Pawn.Acceleration != Vect(0,0,0)) && bAlwaysLevel && bSnapToLevel) || !bKeyboardLook) )
			{
				if ( bLookUpStairs || bSnapToLevel )
				{
					ViewRotation.Pitch = GroundPitch;
				}
				else if ( bCenterView )
				{
					ViewRotation.Pitch = ViewRotation.Pitch & 65535;
					if (ViewRotation.Pitch > 32768)
						ViewRotation.Pitch -= 65536;
					ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
					if ( Abs(ViewRotation.Pitch) < 1000 )
						ViewRotation.Pitch = 0;
				}
			}

			Speed2D = Sqrt(Pawn.Velocity.X * Pawn.Velocity.X + Pawn.Velocity.Y * Pawn.Velocity.Y);
			//add bobbing when walking
			CheckBob(DeltaTime, Speed2D, Y);
		}
		else
		{
			if ( !bKeyboardLook && (bLook == 0) && bCenterView )
			{
				ViewRotation.Pitch = ViewRotation.Pitch & 65535;
				if (ViewRotation.Pitch > 32768)
					ViewRotation.Pitch -= 65536;
				ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
				if ( Abs(ViewRotation.Pitch) < 1000 )
					ViewRotation.Pitch = 0;
			}
			BobTime = 0;
			WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
		}

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( bPressedJump && Pawn.CannotJumpNow() )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{
		if ( Pawn.Mesh == None )
			Pawn.SetMesh();
		WalkBob = vect(0,0,0);
		DoubleClickDir = DCLICK_None;
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		if (Pawn.Physics != PHYS_Falling)
			Pawn.SetPhysics(PHYS_Walking);
		GroundPitch = 0;
	}

	function EndState()
	{
		GroundPitch = 0;
		WalkBob = vect(0,0,0);
		if ( Pawn != None )
			Pawn.ShouldCrouch(false);
	}
}

// player is climbing ladder
state PlayerClimbing
{
ignores SeePlayer, Bump;

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		else
			GotoState(Pawn.LandMovementState);
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector OldAccel;

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;

		if ( bPressedJump )
		{
			Pawn.DoJump(bUpdating);
			if ( Pawn.Physics == PHYS_Falling )
				GotoState('PlayerWalking');
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local eDoubleClickDir DoubleClickMove;
		local rotator OldRotation, ViewRotation;
		local float Speed2D;
		local bool	bSaveJump;

		GetAxes(Rotation,X,Y,Z);

		// Update acceleration.
		//if ( Pawn.OnLadder != None )
		//	NewAccel = aForward*Pawn.OnLadder.ClimbDir;
		//else
			NewAccel = aForward*X + aStrafe*Y;
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);

		ViewRotation = Rotation;

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
	}

	function EndState()
	{
		if ( Pawn != None )
			Pawn.ShouldCrouch(false);
	}
}


// Player movement.
// Player walking on walls
state PlayerSpidering
{
ignores SeePlayer, Bump;

	event bool NotifyHitWall(vector HitNormal, actor HitActor)
	{
		// FIXME - pawn should have bool identifying if this was a voluntary jump
		Pawn.SetPhysics(PHYS_Spider);
		Pawn.SetBase(HitActor, HitNormal);
		return true;
	}

	// if spider mode, update rotation based on floor
	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		local rotator TempRot, ViewRotation;
		local vector MyFloor, CrossDir, FwdDir, OldFwdDir, OldX, RealFloor;

		if ( bInterpolating || Pawn.bInterpolating )
		{
			ViewShake(deltaTime);
			return;
		}

		TurnTarget = None;
		bRotateToDesired = false;
		bSetTurnRot = false;

		if ( (Pawn.Base == None) || (Pawn.Floor == vect(0,0,0)) )
			MyFloor = vect(0,0,1);
		else
			MyFloor = Pawn.Floor;

		if ( MyFloor != OldFloor )
		{
			// smoothly change floor
			RealFloor = MyFloor;
			MyFloor = Normal(6*DeltaTime * MyFloor + (1 - 6*DeltaTime) * OldFloor);
			if ( (RealFloor Dot MyFloor) > 0.999 )
				MyFloor = RealFloor;

			// translate view direction
			CrossDir = Normal(RealFloor Cross OldFloor);
			FwdDir = CrossDir Cross MyFloor;
			OldFwdDir = CrossDir Cross OldFloor;
			ViewX = MyFloor * (OldFloor Dot ViewX)
						+ CrossDir * (CrossDir Dot ViewX)
						+ FwdDir * (OldFwdDir Dot ViewX);
			ViewX = Normal(ViewX);

			ViewZ = MyFloor * (OldFloor Dot ViewZ)
						+ CrossDir * (CrossDir Dot ViewZ)
						+ FwdDir * (OldFwdDir Dot ViewZ);
			ViewZ = Normal(ViewZ);
			OldFloor = MyFloor;
			ViewY = Normal(MyFloor Cross ViewX);
		}

		if ( (aTurn != 0) || (aLookUp != 0) )
		{
			// adjust Yaw based on aTurn
			if ( aTurn != 0 )
				ViewX = Normal(ViewX + 2 * ViewY * Sin(0.0005*DeltaTime*aTurn));

			// adjust Pitch based on aLookUp
			if ( aLookUp != 0 )
			{
				OldX = ViewX;
				ViewX = Normal(ViewX + 2 * ViewZ * Sin(0.0005*DeltaTime*aLookUp));
				ViewZ = Normal(ViewX Cross ViewY);

				// bound max pitch
				if ( (ViewZ Dot MyFloor) < 0.707   )
				{
					OldX = Normal(OldX - MyFloor * (MyFloor Dot OldX));
					if ( (ViewX Dot MyFloor) > 0)
						ViewX = Normal(OldX + MyFloor);
					else
						ViewX = Normal(OldX - MyFloor);

					ViewZ = Normal(ViewX Cross ViewY);
				}
			}

			// calculate new Y axis
			ViewY = Normal(MyFloor Cross ViewX);
		}
		ViewRotation =  OrthoRotation(ViewX,ViewY,ViewZ);
		SetRotation(ViewRotation);
		ViewShake(deltaTime);
		ViewFlash(deltaTime);
		Pawn.FaceRotation(ViewRotation, deltaTime );
	}

	function bool NotifyLanded(vector HitNormal)
	{
		Pawn.SetPhysics(PHYS_Spider);
		if ( bUpdating )
			return true;
		LandBob = FMin(50, 0.055 * Pawn.Velocity.Z);
		return false;
	}

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector OldAccel;

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;

		if ( bPressedJump )
			Pawn.DoJump(bUpdating);
	}

	function PlayerMove( float DeltaTime )
	{
		local vector NewAccel;
		local eDoubleClickDir OldDoubleClick;
		local eDoubleClickDir DoubleClickMove;
		local rotator OldRotation, ViewRotation;
		local float Speed2D;
		local bool	bSaveJump;

		GroundPitch = 0;
		ViewRotation = Rotation;

		if ( !bKeyboardLook && (bLook == 0) && bCenterView )
		{
			// FIXME - center view rotation based on current floor
		}
		BobTime = 0;
		WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		// Update acceleration.
		NewAccel = aForward*Normal(ViewX - OldFloor * (OldFloor Dot ViewX)) + aStrafe*ViewY;
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);

		if ( bPressedJump && Pawn.CannotJumpNow() )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{
		local Rotator NewRot;

		if ( Pawn.Mesh == None )
			Pawn.SetMesh();
		OldFloor = vect(0,0,1);
		GetAxes(Rotation,ViewX,ViewY,ViewZ);
		WalkBob = vect(0,0,0);
		DoubleClickDir = DCLICK_None;
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		if (Pawn.Physics != PHYS_Falling)
			Pawn.SetPhysics(PHYS_Spider);
		GroundPitch = 0;
		Pawn.bCrawler = true;
		Pawn.SetCollisionSize(Pawn.Default.CollisionHeight,Pawn.Default.CollisionHeight);
	}

	function EndState()
	{
		GroundPitch = 0;
		WalkBob = vect(0,0,0);
		if ( Pawn != None )
		{
			Pawn.SetCollisionSize(Pawn.Default.CollisionRadius,Pawn.Default.CollisionHeight);
			Pawn.ShouldCrouch(false);
			Pawn.bCrawler = Pawn.Default.bCrawler;
		}
	}
}

// Player movement.
// Player Swimming
state PlayerSwimming
{
ignores SeePlayer, Bump;

	function bool WantsSmoothedView()
	{
		return ( !Pawn.bJustLanded );
	}

	function bool NotifyLanded(vector HitNormal)
	{
		if ( Pawn.PhysicsVolume.bWaterVolume )
			Pawn.SetPhysics(PHYS_Swimming);
		else
			GotoState(Pawn.LandMovementState);
		return bUpdating;
	}

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, checkpoint;

		if ( !NewVolume.bWaterVolume )
		{
			Pawn.SetPhysics(PHYS_Falling);
			if (Pawn.bUpAndOut && Pawn.CheckWaterJump(HitNormal)) //check for waterjump
			{
				Pawn.velocity.Z = 330 + 2 * Pawn.CollisionRadius; //set here so physics uses this for remainder of tick
				GotoState(Pawn.LandMovementState);
			}
			else if ( (Pawn.Velocity.Z > 160) || !Pawn.TouchingWaterVolume() )
				GotoState(Pawn.LandMovementState);
			else //check if in deep water
			{
				checkpoint = Pawn.Location;
				checkpoint.Z -= (Pawn.CollisionHeight + 6.0);
				HitActor = Trace(HitLocation, HitNormal, checkpoint, Pawn.Location, false);
				if (HitActor != None)
					GotoState(Pawn.LandMovementState);
				else
				{
					Enable('Timer');
					SetTimer(0.7,false);
				}
			}
		}
		else
		{
			Disable('Timer');
			Pawn.SetPhysics(PHYS_Swimming);
		}
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector X,Y,Z, OldAccel;

		GetAxes(Rotation,X,Y,Z);
		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		Pawn.bUpAndOut = ((X Dot Pawn.Acceleration) > 0) && ((Pawn.Acceleration.Z > 0) || (Rotation.Pitch > 2048));
		if ( !Pawn.PhysicsVolume.bWaterVolume ) //check for waterjump
			NotifyPhysicsVolumeChange(Pawn.PhysicsVolume);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator oldRotation;
		local vector X,Y,Z, NewAccel;
		local float Speed2D;

		GetAxes(Rotation,X,Y,Z);

		NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1);
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);

		//add bobbing when swimming
		Speed2D = Sqrt(Pawn.Velocity.X * Pawn.Velocity.X + Pawn.Velocity.Y * Pawn.Velocity.Y);
		WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * Level.TimeSeconds);
		WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * Level.TimeSeconds);

		// Update rotation.
		oldRotation = Rotation;
		UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		bPressedJump = false;
	}

	function Timer()
	{
		if ( !Pawn.PhysicsVolume.bWaterVolume && (Role == ROLE_Authority) )
			GotoState(Pawn.LandMovementState);

		Disable('Timer');
	}

	function BeginState()
	{
		Disable('Timer');
		Pawn.SetPhysics(PHYS_Swimming);
	}
}

state PlayerFlying
{
ignores SeePlayer, Bump;

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		Pawn.Acceleration = aForward*X + aStrafe*Y;
		if ( VSize(Pawn.Acceleration) < 1.0 )
			Pawn.Acceleration = vect(0,0,0);
		if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
			Pawn.Velocity = vect(0,0,0);
		// Update rotation.
		UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
	}

	function BeginState()
	{
		Pawn.SetPhysics(PHYS_Flying);
	}
}

state PlayerHelicoptering extends PlayerFlying
{
	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		Pawn.Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);
		if ( VSize(Pawn.Acceleration) < 1.0 )
			Pawn.Acceleration = vect(0,0,0);
		if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
			Pawn.Velocity = vect(0,0,0);
		// Update rotation.
		UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
	}
}

state BaseSpectating
{
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		Acceleration = 0.02 * (aForward*X + aStrafe*Y + aUp*vect(0,0,1));

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
	}
}

state Spectating extends BaseSpectating
{
	ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
	 ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange;

	exec function NextWeapon()
	{
		Fire();
	}

	exec function PrevWeapon()
	{
		if ( ViewTarget == self )
			bBehindView = false;
		else
			bBehindView = true; //bChaseCam;
	}

	exec function Fire( optional float F )
	{
		local Controller C, Pick;
		local bool bFound;

		if ( Role == ROLE_Authority )
		{
			// view next player
			for ( C=Level.ControllerList; C!=None; C=C.NextController )
				if ( (C.Pawn != None) && Level.Game.CanSpectate(self,C.Pawn) )
				{
					if ( Pick == None )
						Pick = C;
					if ( bFound )
					{
						Pick = C;
						break;
					}
					else
						bFound = ( ViewTarget == C.Pawn );
				}
			SetViewTarget(Pick.Pawn);
			if ( ViewTarget == self )
				bBehindView = false;
			else
				bBehindView = true; //bChaseCam;
		}
	}

	// Return to spectator's own camera.
	exec function AltFire( optional float F )
	{
		bBehindView = false;
		SetViewtarget(self);
		ClientMessage(OwnCamera, 'Event');
	}

	function BeginState()
	{
		if ( Pawn != None )
		{
			SetLocation(Pawn.Location);
			UnPossess();
		}
		bCollideWorld = true;
	}

	function EndState()
	{
		PlayerReplicationInfo.bIsSpectator = false;
		bCollideWorld = false;
	}
}

//_____________________________________________________________________________
auto state PlayerWaiting extends BaseSpectating
{
    ignores SeePlayer, NotifyBump, TakeDamage, PhysicsVolumeChange;
    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot);
    function PlayerMove(float DeltaTime);
    exec function Jump( optional float F );
    exec function Suicide();

    function ChangeTeam( int N )
    {
      Level.Game.ChangeTeam(self, N);
    }

    function ServerReStartPlayer()
    {
      Log("PlayerWaiting ServerReStartPlayer"@self);
      if ( Level.TimeSeconds < WaitDelay )
      {
        Log("  Cancel ServerReStartPlayer because WaitDelay"@WaitDelay@">Level.TimeSeconds"@Level.TimeSeconds);
        return;
      }
      if ( Level.NetMode == NM_Client )
      {
        Log("  Cancel ServerReStartPlayer because Client");
        return;
      }
      if ( Level.Game.bWaitingToStartMatch )
      {
        Log("  Set PRI"@PlayerReplicationInfo@"ReadyToPlay");
        PlayerReplicationInfo.bReadyToPlay = true;
      }
      else
      {
        Log("  Restart Player"@self);
        Level.Game.RestartPlayer(self);
      }
    }

    exec function Fire(optional float F)
    {
      Log("PlayerWaiting Fire"@self);
      ServerReStartPlayer();
    }

    exec function AltFire(optional float F);

    function EndState()
    {
      if ( Pawn != None )
        Pawn.SetMesh();
      PlayerReplicationInfo.SetWaitingPlayer(false);
      bCollideWorld = false;
      Log("PlayerWaiting EndState"@self);
    }

    function BeginState()
    {
      if ( PlayerReplicationInfo != None )
        PlayerReplicationInfo.SetWaitingPlayer(true);
      bCollideWorld = true;
      myHUD.bShowScores = false;
      Log("PlayerWaiting BeginState"@self);
    }
}
/*
auto state PlayerWaiting
{
    function EndState()
    {
      if ( Pawn != None )
        Pawn.SetMesh();
      PlayerReplicationInfo.SetWaitingPlayer(false);
      bCollideWorld = false;
      Log("PlayerWaiting EndState Player="$player);
    }

    function BeginState()
    {
      Super.BeginState();
      Log("PlayerWaiting BeginState Player="$player);
    }
    exec function Fire(optional float F)
    {
      if (!Player.LocalInteractions[0].IsInState('UWindows'))
        ServerReStartPlayer();
    }
    exec function UnFire(optional float F);
}*/

state WaitingForPawn extends BaseSpectating
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon;

	exec function Fire( optional float F )
	{
	}

	exec function AltFire( optional float F )
	{
	}

	function LongClientAdjustPosition
	(
		float TimeStamp,
		name newState,
		EPhysics newPhysics,
		float NewLocX,
		float NewLocY,
		float NewLocZ,
		float NewVelX,
		float NewVelY,
		float NewVelZ,
		Actor NewBase,
		float NewFloorX,
		float NewFloorY,
		float NewFloorZ
	)
	{
	}

	function PlayerTick(float DeltaTime)
	{
//    Log(self@"WaitingForPawn PlayerTick");
		Global.PlayerTick(DeltaTime);

    if ( !bTimerLoop )
    {
      Log("   WaitingForPawn PlayerTick, Timer not activated ?");
      SetTimer(0.2, true);
    }

		if ( Pawn != None )
		{
      Log("   WaitingForPawn PlayerTick, Found Pawn");
			Pawn.Controller = self;
			ClientRestart();
		}
	}

	function Timer()
	{
    Log(self@"WaitingForPawn Timer");
		AskForPawn();
		MyHud.bShowScores = true;
	}

	function BeginState()
	{
    Log(self@"WaitingForPawn BeginState");
		SetTimer(0.2, true);
		MyHud.bShowScores = true;
	}

	function EndState()
	{
    Log(self@"WaitingForPawn EndState");
		SetTimer(0.0, false);
		MyHud.bShowScores = false;
	}
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide;

	exec function ThrowWeapon()
	{
	}

	function ServerReStartGame()
	{
		Level.Game.RestartGame();
	}

	exec function Fire( optional float F )
	{
		if ( Role < ROLE_Authority)
			return;
		if ( !bFrozen )
			ServerReStartGame();
		else if ( TimerRate <= 0 )
			SetTimer(1.5, false);
	}

	exec function AltFire( optional float F )
	{
		Fire(F);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local Rotator ViewRotation;

		GetAxes(Rotation,X,Y,Z);
		// Update view rotation.

		if ( !bFixedCamera )
		{
			ViewRotation = Rotation;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0)
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
			SetRotation(ViewRotation);
		}
		else if ( ViewTarget != None )
			SetRotation(ViewTarget.Rotation);

		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		bPressedJump = false;
	}

	function ServerMove
	(
		float TimeStamp,
		vector InAccel,
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus,
		eDoubleClickDir DoubleClickMove,
		byte ClientRoll,
		int View,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.ServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbJumpStatus,
							DoubleClickMove, ClientRoll, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)) );

	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot, ViewRotation;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;

		ViewRotation = Rotation;
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;

		for (tries=0; tries<16; tries++)
		{
			cameraLoc = ViewTarget.Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - ViewTarget.Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}

		ViewRotation.Yaw = startYaw + besttry * 4096;
		SetRotation(ViewRotation);
	}

	function Timer()
	{
		bFrozen = false;
	}

	function BeginState()
	{
		local Pawn P;

		EndZoom();
		bFire = 0;
		bAltFire = 0;
		if ( Pawn != None )
		{
			Pawn.SimAnim.AnimRate = 0;
			Pawn.bPhysicsAnimUpdate = false;
			Pawn.StopAnimating();
			Pawn.SetCollision(false,false,false);
		}
		myHUD.bShowScores = true;
		bFrozen = true;
		if ( !bFixedCamera )
		{
			FindGoodView();
			bBehindView = true;
		}
		SetTimer(1.5, false);
		SetPhysics(PHYS_None);
		ForEach DynamicActors(class'Pawn', P)
		{
			P.Velocity = vect(0,0,0);
			P.SetPhysics(PHYS_None);
		}
	}
}

state Dead
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon;

	function ServerRestartPlayer()
	{
		if ( bFrozen )
			return;
		Super.ServerRestartPlayer();
	}

	exec function Fire( optional float F )
	{
		if ( !bFrozen )
			ServerReStartPlayer();
	}

	exec function AltFire( optional float F )
	{
		Fire(F);
	}

	function ServerMove
	(
		float TimeStamp,
		vector Accel,
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus,
		eDoubleClickDir DoubleClickMove,
		byte ClientRoll,
		int View,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.ServerMove(
					TimeStamp,
					Accel,
					ClientLoc,
					false,
					false,
					false,
					DoubleClickMove,
					ClientRoll,
					View);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local rotator ViewRotation;

        if ( !bFrozen )
		{
			if ( bPressedJump )
			{
				Fire(0);
				bPressedJump = false;
			}
			GetAxes(Rotation,X,Y,Z);
			// Update view rotation.
			ViewRotation = Rotation;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0)
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
			SetRotation(ViewRotation);
			if ( Role < ROLE_Authority ) // then save this move and replicate it
				ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		}
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot, ViewRotation;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;

		////log("Find good death scene view");
		ViewRotation = Rotation;
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;

		for (tries=0; tries<16; tries++)
		{
			cameraLoc = ViewTarget.Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - ViewTarget.Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}

		ViewRotation.Yaw = startYaw + besttry * 4096;
		SetRotation(ViewRotation);
	}

	function Timer()
	{
		myHUD.bShowScores = true;
		bPressedJump = false;
//		SetTimer2(5.0,false);
		bFrozen = false;
	}

	function Timer2()
	{
    	bFrozen = false;
	}

	function BeginState()
	{
		local SavedMove Next;

		Enemy = None;
		bBehindView = true;
		bFrozen = true;
		bPressedJump = false;
		FindGoodView();
		SetTimer(1.0, false);

		// clean out saved moves
		while ( SavedMoves != None )
		{
			Next = SavedMoves.NextMove;
			SavedMoves.Destroy();
			SavedMoves = Next;
		}
		if ( PendingMove != None )
		{
			PendingMove.Destroy();
			PendingMove = None;
		}
	}

	function EndState()
	{
		local SavedMove Next;

		// clean out saved moves
		while ( SavedMoves != None )
		{
			Next = SavedMoves.NextMove;
			SavedMoves.Destroy();
			SavedMoves = Next;
		}
		if ( PendingMove != None )
		{
			PendingMove.Destroy();
			PendingMove = None;
		}
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		bBehindView = false;
		myHUD.bShowScores = false;
		bPressedJump = false;
		//Log(self$" exiting dying with remote role "$RemoteRole$" and role "$Role);
	}
}

//------------------------------------------------------------------------------
// ngStats Accessors
function string GetNGSecret()
{
	return ngWorldSecret;
}

function SetNGSecret(string newSecret)
{
	ngWorldSecret = newSecret;
}

//------------------------------------------------------------------------------
// Control options
function ChangeStairLook( bool B )
{
	bLookUpStairs = B;
	if ( bLookUpStairs )
		bAlwaysMouseLook = false;
}

function ChangeAlwaysMouseLook(Bool B)
{
	bAlwaysMouseLook = B;
	if ( bAlwaysMouseLook )
		bLookUpStairs = false;
}

debugonly simulated function DumpContent(float TimeStamp, int tabulation)
{
    local int j;
    local string Tab;

    for (j=0; j<tabulation; j++) Tab = Tab$" ";

    log(Tab$"PlayerController's dump at "$TimeStamp$":");
    //log(Tab$"  bLookUpStairs:"$bLookUpStairs$" bSnapToLevel:"$bSnapToLevel$" bAlwaysMouseLook:"$bAlwaysMouseLook$" bKeyboardLook:"$bKeyboardLook$" bCenterView:"$bCenterView);
    //log(Tab$"  bBehindView:"$bBehindView$" bFrozen:"$bFrozen$" bPressedJump:"$bPressedJump$" bUpdatePosition:"$bUpdatePosition$" bIsTyping:"$bIsTyping);
    //log(Tab$"  bFixedCamera:"$bFixedCamera$" bJumpStatus:"$bJumpStatus$" bUpdating:"$bUpdating$" bNeverSwitchOnPickup:"$bNeverSwitchOnPickup);
    //log(Tab$"  bZooming:"$bZooming$" bOnlySpectator:"$bOnlySpectator$" bAlwaysLevel:"$bAlwaysLevel$" bSetTurnRot:"$bSetTurnRot);
    //log(Tab$"  bCheatFlying:"$bCheatFlying$" bFreeCamera:"$bFreeCamera$" bZeroRoll:"$bZeroRoll);
    //log(Tab$"  AimingHelp:"$AimingHelp$" WaitDelay:"$WaitDelay);
    //log(Tab$"  aBaseX:"$aBaseX$" aBaseY:"$aBaseY$" aBaseZ:"$aBaseZ$" aMouseX:"$aMouseX$" aMouseY:"$aMouseY$" aForward:"$aForward$" aTurn:"$aTurn$" aStrafe:"$aStrafe$" aUp:"$aUp$" aLookUp:"$aLookUp);
    //log(Tab$"  bStrafe:"$bStrafe$" bSnapLevel:"$bSnapLevel$" bLook:"$bLook$" bFreeLook:"$bFreeLook$" bTurn180:"$bTurn180$" bTurnToNearest:"$bTurnToNearest);
    //log(Tab$"  DoubleClickDir:"$DoubleClickDir);
    //log(Tab$"  ShowFlags:"$ShowFlags$" Misc1:"$Misc1$" Misc2:"$Misc2$" RendMap:"$RendMap$" OrthoZoom:"$OrthoZoom$" ViewTarget:"$ViewTarget$" CameraDist:"$CameraDist);
    //log(Tab$"  DesiredFOV:"$DesiredFOV$" DefaultFOV:"$DefaultFOV$" ZoomLevel:"$ZoomLevel);
    //log(Tab$"  FlashScale:"$FlashScale$" FlashFog:"$FlashFog);
    //log(Tab$"  DesiredFlashScale:"$DesiredFlashScale$" ConstantGlowScale:"$ConstantGlowScale);
    //log(Tab$"  InstantFlash:"$InstantFlash$" DesiredFlashFog:"$DesiredFlashFog$" ConstantGlowFog:"$ConstantGlowFog$" InstantFog:"$InstantFog);
    //log(Tab$"  FilterColor:"$FilterColor.B$","$FilterColor.G$","$FilterColor.R$","$FilterColor.A$" FilterColorWanted:"$FilterColorWanted.B$","$FilterColorWanted.G$","$FilterColorWanted.R$","$FilterColorWanted.A$" FilterColorSpeed:"$FilterColorSpeed$" FilterInternalInc:"$FilterInternalInc);
    //log(Tab$"  TargetViewRotation:"$TargetViewRotation$" TargetEyeHeight:"$TargetEyeHeight$" TargetWeaponViewOffset:"$TargetWeaponViewOffset);
    //log(Tab$"  myHUD:"$myHUD$" LastPlaySound:"$LastPlaySound$" AnnouncerVolume:"$AnnouncerVolume);
    //log(Tab$"  SavedMoves:"$SavedMoves$" FreeMoves:"$FreeMoves$" PendingMove:"$PendingMove);
    //log(Tab$"  CurrentTimeStamp:"$CurrentTimeStamp$" LastUpdateTime:"$LastUpdateTime$" ServerTimeStamp:"$ServerTimeStamp$" TimeMargin:"$TimeMargin$" ClientUpdateTime:"$ClientUpdateTime$" MaxTimeMargin:"$MaxTimeMargin);
        log(Tab$"  LastUpdateTime:"$LastUpdateTime$" ServerTimeStamp:"$ServerTimeStamp$" TimeMargin:"$TimeMargin$" ClientUpdateTime:"$ClientUpdateTime);
    //log(Tab$"  OldClientWeapon:"$OldClientWeapon$" WeaponUpdate:"$WeaponUpdate);
    //log(Tab$"  ProgressMessage[0]:"$ProgressMessage[0]$" ProgressMessage[1]:"$ProgressMessage[1]$" ProgressMessage[2]:"$ProgressMessage[2]$" ProgressMessage[3]:"$ProgressMessage[3]);
    // discarded log(Tab$"  ProgressColor[0]:"$ProgressColor[0]$" ProgressColor[1]:"$ProgressColor[1]$" ProgressColor[2]:"$ProgressColor[2]$" ProgressColor[3]:"$ProgressColor[3]);
    //log(Tab$"  ProgressTimeOut:"$ProgressTimeOut$" QuickSaveString:"$QuickSaveString$" NoPauseMessage:"$NoPauseMessage$" ViewingFrom:"$ViewingFrom$" OwnCamera:"$OwnCamera);
    //log(Tab$"  QuickSaveString:"$QuickSaveString$" NoPauseMessage:"$NoPauseMessage$" ViewingFrom:"$ViewingFrom$" OwnCamera:"$OwnCamera);
    //log(Tab$"  ngWorldSecret:"$ngWorldSecret$" ngSecretSet:"$ngSecretSet$" ReceivedSecretChecksum:"$ReceivedSecretChecksum$" LocalMessageClass:"$LocalMessageClass);
    log(Tab$"  Bob:"$Bob$" LandBob:"$LandBob$" AppliedBob:"$AppliedBob$" bobtime:"$bobtime$" WalkBob:"$WalkBob);
    //log(Tab$"  MaxShakeRoll:"$MaxShakeRoll$" MaxShakeOffset:"$MaxShakeOffset$" ShakeRollRate:"$ShakeRollRate$" ShakeOffsetRate:"$ShakeOffsetRate);
    //log(Tab$"  ShakeOffset:"$ShakeOffset$" ShakeRollTime:"$ShakeRollTime$" ShakeOffsetTime:"$ShakeOffsetTime);
    //log(Tab$"  TurnTarget:"$TurnTarget$" EnemyTurnSpeed:"$EnemyTurnSpeed$" GroundPitch:"$GroundPitch$" TurnRot180:"$TurnRot180);
    //log(Tab$"  OldFloor:"$OldFloor);
    //log(Tab$"  CheatManager:"$CheatManager$" CheatClass:"$CheatClass$" PlayerInput:"$PlayerInput$" InputClass:"$InputClass);
    //log(Tab$"  DemoViewPitch:"$DemoViewPitch$" DemoViewYaw:"$DemoViewYaw);
    //log(Tab$"  GameReplicationInfo:"$GameReplicationInfo);
    //log(Tab$"  GameReplicationInfo:");
    //GameReplicationInfo.DumpContent(TimeStamp, tabulation)

    Super.DumpContent(TimeStamp, tabulation);
}


debugonly simulated function DumpChosenContent(float TimeStamp)
{
    log("At "$TimeStamp$":");
    if (pawn!=none)
    {
        if (pawn.velocity.z>0.0)
        {
            log("GroundSpeed:"$pawn.GroundSpeed$"  jumping:"$pawn.velocity.z);
        }
        else
        {
            log("GroundSpeed:"$pawn.GroundSpeed);
        }
    }
}

//    AimingHelp=0.0

defaultproperties
{
     bAlwaysMouseLook=True
     bKeyboardLook=True
     bZeroRoll=True
     bAutoPickup=True
     ConfigType=CT_StrafeLookNotSameAxis
     OrthoZoom=40000.000000
     CameraDist=9.000000
     DesiredFOV=85.000000
     DefaultFOV=85.000000
     FlashScale=(X=1.000000,Y=1.000000,Z=1.000000)
     FilterColor=(B=128,G=128,R=128)
     FilterColorWanted=(B=128,G=128,R=128)
     FilterColorSpeed=1.000000
     AnnouncerVolume=4
     MaxTimeMargin=1.000000
     QuickSaveString="Quick Saving"
     NoPauseMessage="Game is not pauseable"
     ViewingFrom="Now viewing from"
     OwnCamera="Now viewing from own camera"
     LocalMessageClass=Class'Engine.LocalMessage'
     Bob=0.016000
     EnemyTurnSpeed=45000
     CheatClass=Class'Engine.CheatManager'
     InputClass=Class'Engine.PlayerInput'
     FovAngle=85.000000
     Handedness=1.000000
     bIsPlayer=True
     bCanOpenDoors=True
     bCanDoSpecial=True
     bTravel=True
     NetPriority=3.000000
}
