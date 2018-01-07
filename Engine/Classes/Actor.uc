//=============================================================================
// Actor: The base class of all actors.
// Actor is the base class of all gameplay objects.
// A large number of properties, behaviors and interfaces are implemented in Actor, including:
//
// -	Display
// -	Animation
// -	Physics and world interaction
// -	Making sounds
// -	Networking properties
// -	Actor creation and destruction
// -	Triggering and timers
// -	Actor iterator functions
// -	Message broadcasting
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Actor extends Object
	abstract
	native
	nativereplication;

// Imported data (during full rebuild).
#exec Texture Import File=Textures\S_Actor.pcx Name=S_Actor Mips=Off MASKED=1 COMPRESS=DXT1

// Be very carefull if you add variable just before or after LastRenderTime.
// The engine assume that bDecor1Light folow LastRenderTime four byte next, and that LastRenderTime is four byte
// alligned.

var			float			LastRenderTime;	// last time this actor was rendered.

var(Lighting)		bool	     bDecor1Light;	 // Light decor 1
var(Lighting)		bool	     bDecor2Light;	 // Light decor 2
var(Lighting)		bool	     bDecor3Light;	 // Light decor 3
var(Lighting)		bool	     bActorLight;	 // Light actor
var(Lighting)		bool	     bDecor4Light;	 // Light decor 4
var(Lighting)		bool	     bDecor5Light;	 // Light decor 5
var(Lighting)		bool	     bDecor6Light;	 // Light decor 6
var(Lighting)		bool	     bDecor7Light;	 // Light decor 7
var(Lighting)		bool	     bDecor8Light;	 // Light decor 8
var(Lighting)		bool	     bDecor9Light;	 // Light decor 9
var(Lighting)		bool	     bDecor10Light;	 // Light decor 10

// Flags.
var			  const bool	bStatic;			// Does not move or change over time. Don't let L.D.s change this - screws up net play
var(Advanced)		bool	bHidden;			// Is hidden during gameplay.
var(Advanced) const bool	bNoDelete;			// Cannot be deleted during play.
var					bool	bAnimFinished;		// Unlooped animation sequence has finished.
var					bool	bAnimByOwner;		// Animation dictated by owner.
var			  const	bool	bDeleteMe;			// About to be deleted.
var			  const bool	bTicked;			// Actor has been updated.
var					bool	bDynamicLight;		// Temporarily treat this as a dynamic light.
var					bool	bTimerLoop;			// Timer loops (else is one-shot).
var					bool	bTimer2Loop;		// Timer2 loops (else is one-shot).
var(Advanced)		bool	bCanTeleport;		// This actor can be teleported.
var 				bool	bOwnerNoSee;		// Everything but the owner can see this actor.
var					bool    bOnlyOwnerSee;		// Only owner can see this actor.
var			  const	bool	bAlwaysTick;		// Update even when players-only.
var(Advanced)		bool    bHighDetail;		// Only show up on high-detail.
var(Advanced)		bool	bStasis;			// In StandAlone games, turn off if not in a recently rendered zone turned off if  bStasis  and physics = PHYS_None or PHYS_Rotating.
var					bool	bTrailerSameRotation; // If PHYS_Trailer and true, have same rotation as owner.
var					bool	bTrailerPrePivot;	// If PHYS_Trailer and true, offset from owner by PrePivot.
var					bool	bClientAnim;		// Don't replicate any animations - animation done client-side
var(Collision)		bool	bWorldGeometry;		// Collision and Physics treats this actor as world geometry
var(Display)		bool    bAcceptsProjectors;	// Projectors can project onto this actor
var					bool	bOrientOnSlope;		// when landing, orient base on slope of floor
var(Display)		Bool	bEaseInteract;		// Used to make object easily interacted with (even if not just in the crosshair, rather interactive if on screen)
var(Display)		Bool	bInteractive;		// Can be interactive (used to speed up/debug the iteraction icons/functions)
//var					bool    bWasSNFiltered;      // Mainly for debugging - the way this actor was inserted into Octree.

// Networking flags
var			  const	bool	bNetTemporary;				// Tear-off simulation in network play.
var			  const	bool	bNetOptional;				// Actor should only be replicated if bandwidth available.
var			  const	bool	bNetDirty;					// set when any attribute is assigned a value in unrealscript, reset when the actor is replicated
var					bool	bAlwaysRelevant;			// Always relevant for network.
var					bool	bReplicateInstigator;		// Replicate instigator to client (used by bNetTemporary projectiles).
var					bool	bReplicateMovement;			// if true, replicate movement/location related properties
var					bool	bSkipActorPropertyReplication; // if true, don't replicate actor class variables for this actor
var					bool	bUpdateSimulatedPosition;	// if true, update velocity/location after initialization for simulated proxies
var					bool	bTearOff;					// if true, this actor is no longer replicated to new clients, and
														// is "torn off" (becomes a ROLE_Authority) on clients to which it was being replicated.
var					bool	bOnlyDirtyReplication;		// if true, only replicate actor if bNetDirty is true - useful if no C++ changed attributes (such as physics)
														// bOnlyDirtyReplication only used with bAlwaysRelevant actors
var					bool	bReplicateAnimations;		// Should replicate SimAnim
var(Advanced)		bool    bIgnoreVignetteAlpha;       // Ignore alpha filter for screen shot.
var(Advanced)		bool    bDelayDisplay;				// Draw this object without Z buffer just before the hud.
var(Advanced)		bool	bSpecialDelayFov;   		// If bDelayDisplay is also True, use a fov equal to 50.

// Display.
var(Display)		bool      bUnlit;					// Lights don't affect actor.
var(Display)		bool      bNoSmooth;				// Don't smooth actor's texture.
var(Display)		bool      bShadowCast;			// Casts static shadows.
var(Display)		bool		bStaticLighting;		// Uses raytraced lighting.
var(Display)		bool		bNoAmbientLight;		// Don't use the ambient light.
var(Display)		bool		bNoImpact;				// Don't project impact on this actor.
var(Display)		bool		bIgnoreFog;				// Ignore fog, for sprite only.
var(Display)		bool		bForceInUniverse;		// Force the actor to be in the universe zone.
var(Display)		bool      bIgnoreDynLight;	    // Ignore dynamic lighting.

// Advanced.
var					bool		bHurtEntry;				// keep HurtRadius from being reentrant
var(Advanced)		bool		bGameRelevant;			// Always relevant for game
var(Advanced)		bool		bCollideWhenPlacing;	// This actor collides with the world when placing.
var					bool		bTravel;				// Actor is capable of travelling among servers.
var(Advanced)		bool		bMovable;				// Actor can be moved.
// XIIIUNUSED var(Events)			bool		bLocalGameEvent;		// this event should be saved as a local saved game event
// XIIIUNUSED var(Events)			bool		bTravelGameEvent;		// this event should travel across levels as a saved game event
var					bool		bDestroyInPainVolume;	// destroy this actor if it enters a pain volume
var					bool		bPendingDelete;			// set when actor is about to be deleted (since endstate and other functions called

var(Sound)			bool			bHasRollOff;				// Disable rolloff if false.
var(Sound)			bool			bHasPosition;				// Actor has no position if false.
var(Sound)			bool			bUnderwater;
var					bool bLeftFoot;
												// during deletion process before bDeleteMe is set).
// Collision flags.
var(Collision) const bool bCollideActors;		// Collides with other actors.
var(Collision)		bool       bCollideWorld;		// Collides with the world.
var(Collision)		bool       bBlockActors;			// Blocks other nonplayer actors.
var(Collision)		bool       bBlockPlayers;		// Blocks other player actors.
var(Collision)		bool       bProjTarget;			// Projectiles should potentially target this actor.
var(Collision)		bool	   bBlockZeroExtentTraces; // block zero extent actors/traces
var(Collision)		bool	   bBlockNonZeroExtentTraces;	// block non-zero extent actors/traces
var(Collision)		bool	   bUseCylinderCollision;// Force axis aligned cylinder collision (useful for static mesh pickups, etc.)

var(Collision)		bool	   bCanSeeThrough;                       // if true, it is possible to see through the actor (like a window)
var(Collision)		bool	   bCanShootThroughWithRayCastingWeapon; // if true, it is possible to shoot through the actor with a ray casting weapon
var(Collision)		bool	   bCanShootThroughWithProjectileWeapon; // if true, it is possible to shoot through the actor with a projectile weapon

// Lighting.
var(Display)		bool	     bActorShadows; // Light casts actor shadows.
var(Lighting)		bool	     bIgnoredByShadows; // Light is ignored by  shadows.
var(Lighting)		bool	     bLensFlare;    // Whether to use zone lens flare.
var(Lighting)		bool	     bLightOwnZone; // The light affect only it's own zone.
var(Display)		bool	     bUseOnlyPivotAmbient;
var(Display)		bool		 bVisibleOnlyOwnZone;	// The actor is visible only from it's own zone.
var					bool		 bLightChanged;	// Recalculate this light's lighting now.

//-----------------------------------------------------------------------------
// Physics.

// Options.
var(Movement)		bool        bBounce;           // Bounces when hits ground fast.
var(Movement)		bool		  bFixedRotationDir; // Fixed direction of rotation.
var(Movement)		bool		  bRotateToDesired;  // Rotate to DesiredRotation.
var					bool        bInterpolating;    // Performing interpolating.
var			  const bool  bJustTeleported;   // Used by engine physics - not valid for scripts.

// Priority Parameters
// Actor's current physics mode.
var(Movement) const enum EPhysics
{
	PHYS_None,
	PHYS_Walking,
	PHYS_Falling,
	PHYS_Swimming,
	PHYS_Flying,
	PHYS_Rotating,
	PHYS_Projectile,
	PHYS_Interpolating,
	PHYS_MovingBrush,
	PHYS_Spider,
	PHYS_Trailer,
	PHYS_Ladder,
	PHYS_RootMotion,
} Physics;

// Collision category
enum EColCategory
{
	ColType_User,
	ColType_NoCol,
	ColType_StaticSolid,
	ColType_StaticGlass,
	ColType_StaticGrid,
	ColType_StaticSolidOnlyWeapon,
	ColType_MoverSolid,
	ColType_MoverGlass,
	ColType_MoverGrid,
	ColType_Pawn,
	ColType_Pickup,
	ColType_PickupArmeImpro
};

// Net variables.
enum ENetRole
{
	ROLE_None,              // No role at all.
	ROLE_DumbProxy,			// Dumb proxy of this actor.
	ROLE_SimulatedProxy,	// Locally simulated proxy of this actor.
	ROLE_AutonomousProxy,	// Locally autonomous proxy of this actor.
	ROLE_Authority,			// Authoritative control over the actor.
};
var ENetRole Role;
var ENetRole RemoteRole;

// Drawing effect.
var(Display) const enum EDrawType
{
	DT_None,
	DT_Sprite,
	DT_Mesh,
	DT_Brush,
	DT_RopeSprite,
	DT_VerticalSprite,
	DT_Terraform,
	DT_SpriteAnimOnce,
	DT_StaticMesh,
	DT_DrawType,
	DT_Particle,
	DT_AntiPortal,
	DT_Trail
} DrawType;

var const transient int		NetTag;
var			float			LastRenderDist;	// last distance this actor was rendered.
var(Events) name			Tag;			// Actor's tag name.

// Execution and timer variables.
var				float       TimerRate;		// Timer event, 0=no timer.
var		const	float       TimerCounter;	// Counts up until it reaches TimerRate.
var				float       Timer2Rate;     // Same for Timer 2
var		const	float       Timer2Counter;
var(Advanced)	float		LifeSpan;		// How old the object lives before dying, 0=forever.

// Animation variables. #SKEL: Left in for this build only to wrap up any backward compatibility - but not used. - Erik
var(Display) name         AnimSequence;  // Animation sequence we're playing.
var(Display) float        AnimFrame;     // Current animation frame, 0.0 to 1.0.
var(Display) float        AnimRate;      // Animation rate in frames per second, 0=none, negative=velocity scaled.
var          float        TweenRate;     // Tween-into rate.

var transient MeshInstance MeshInstance;	// Mesh instance.

// Owner.
var         const Actor   Owner;			// Owner actor.
var(Object) name InitialState;
var(Object) name Group;

//-----------------------------------------------------------------------------
// Structures.

// Identifies a unique convex volume in the world.
struct PointRegion
{
	var zoneinfo Zone;       // Zone.
	var int      iLeaf;      // Bsp leaf.
	var byte     ZoneNumber; // Zone number.
};

//-----------------------------------------------------------------------------
// Major actor properties.

// Scriptable.
var       const LevelInfo Level;         // Level this actor is on.
var transient const Level XLevel;        // Level object.
var(Events) name          Event;         // The event this actor causes.
var Pawn                  Instigator;    // Pawn responsible for damage caused by this actor.
var(Sound) sound          AmbientSound;  // Ambient sound effect.
var Inventory             Inventory;     // Inventory chain.
var const Actor           Base;          // Actor we're standing on.
var const PointRegion     Region;        // Region this actor is in.
var transient array<int>  Leaves;		 // BSP leaves this actor is in.

// Internal.
var const float						LatentFloat;   // Internal latent function use.
var transient const array<Actor>    Touching;		 // List of touching actors.

//var const transient array<int>		OctreeNodes;// Array of nodes of the octree Actor is currently in. Internal use only.
//var const transient Box				OctreeBox;     // Actor bounding box cached when added to Octree. Internal use only.
//var const transient vector			OctreeBoxCenter;
//var const transient vector			OctreeBoxRadii;
var const actor						Deleted;       // Next actor in just-deleted chain.

// Internal tags.
//var const native int CollisionTag, ActorTag;
var const transient int CollisionInfo;

// The actor's position and rotation.
var const	PhysicsVolume	PhysicsVolume;	// physics volume this actor is currently in
var(Movement) const vector	Location;		// Actor's location; use Move to set.
var(Movement) const rotator Rotation;		// Rotation.
var(Movement) vector		Velocity;		// Velocity.
var			  vector        Acceleration;	// Acceleration.

// Attachment related variables
var(Movement)	name	AttachTag;
var const array<Actor>  Attached;			// array of actors attached to this actor.
var const vector		RelativeLocation;	// location relative to base/bone (valid if base exists)
var const rotator		RelativeRotation;	// rotation relative to base/bone (valid if base exists)
var const name			AttachmentBone;		// name of bone to which actor is attached (if attached to center of base, =='')

// Projectors
struct InstanceProjectorInfo { var int a,b,c; };	// Hack to to fool C++ header generation...
var const transient array<InstanceProjectorInfo> Projectors;// Projected textures on this actor

//-----------------------------------------------------------------------------
// Display properties.

var(Display) Material		Texture;			// Sprite texture.if DrawType=DT_Sprite
var(Display) mesh			Mesh;				// Mesh if DrawType=DT_Mesh.
var(Display) StaticMesh		StaticMesh;			// StaticMesh if DrawType=DT_StaticMesh
var StaticMeshInstance		StaticMeshInstance; // Contains per-instance static mesh data, like static lighting data.
var const export model		Brush;				// Brush if DrawType=DT_Brush.
var(Display) const float	DrawScale;			// Scaling factor, 1.0=normal size.
var(Display) const vector	DrawScale3D;		// Scaling vector, (1.0,1.0,1.0)=normal size.
var			 vector			PrePivot;			// Offset from box center for drawing.
var(Display) array<Material> Skins;				// Multiple skin support - not replicated.

//-----------------------------------------------------------------------------
// MC for HarmonX integration
// Sound.
// Ambient sound.
var(Sound)	  float	PanCoeff;					// Coefficient to compute pan for this actor : ( 0 for	no pan )
var(RollOff)  float	SaturationDistance;			// Saturation Radius of actor sounds.
var(RollOff)  float	StabilisationDistance;		// Stabilisation Radius of actor sounds.
var(RollOff)  float	StabilisationVolume;		// Volume of actors sounds at stabilisation radius.
var(RollOff)  float	VoicesSaturationDistance;			// Saturation Radius of actor sounds for voices.
var(RollOff)  float	VoicesStabilisationDistance;		// Stabilisation Radius of actor sounds for voices.
var(RollOff)  float	VoicesStabilisationVolume;		// Volume of actors sounds at stabilisation radius for voices.

const SNDType_Effect     = 0x00000001;
const SNDType_Voice	     = 0x00000002;
const SNDType_StrVoice   = 0x00000004;
const SNDType_StrAmb     = 0x00000008;
const SNDType_Music      = 0x00000010;
const SNDType_Menu       = 0x00000020;
const SNDType_Ryan       = 0x00000040;
const SNDType_MicroCanon = 0x00000080;
const SNDType_UnderWater = 0x00000100;
const SNDType_SFXOnly	 = 0x00000200;
const SNDType_All	     = 0x00000FFF;

enum ESNDMusicVolume
{
	SNDMusic_Off,
	SNDMusic_Light,
	SNDMusic_Normal
};
//end MC

//-----------------------------------------------------------------------------
// Collision.

// Collision size.
var(Collision) const float CollisionRadius;		// Radius of collision cyllinder.
var(Collision) const float CollisionHeight;		// Half-height cyllinder.

//-----------------------------------------------------------------------------
// Lighting.

var(Display) byte			AmbientGlow;		// Ambient brightness, or 255=pulsing.

// Style for rendering sprites, meshes.
var(Display) enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
	STY_Alpha,
	STY_Particle
} Style;

var enum ESNDMaterial
{
	SND_FootStep,
	SND_XIIIFootStep,
	SND_PNJStep,
	SND_XIIIStep,
	SND_Jump,
	SND_XIIIJump,
	SND_Hit
} SNDMaterial;

// Light modulation.
var(Lighting) enum ELightType
{
	LT_None,
	LT_Steady,
	LT_Pulse,
	LT_Blink,
	LT_Flicker,
	LT_Strobe,
	LT_BackdropLight,
	LT_SubtlePulse,
} LightType;

// Spatial light effect to use.
var(Lighting) enum ELightEffect
{
	LE_None,
	LE_TorchWaver,
	LE_FireWaver,
	LE_WateryShimmer,
	LE_Searchlight,
	LE_SlowWave,
	LE_FastWave,
	LE_CloudCast,
	LE_StaticSpot,
	LE_Shock,
	LE_Disco,
	LE_Warp,
	LE_Spotlight,
	LE_NonIncidence,
	LE_Shell,
	LE_OmniBumpMap,
	LE_Interference,
	LE_Cylinder,
	LE_Rotor,
	LE_Unused,
	LE_Sunlight
} LightEffect;

// Lighting info.
var(LightColor) byte
	LightBrightness,
	LightHue,
	LightSaturation;

// Light properties.
var(Lighting) byte
	LightRadius,
	LightPeriod,
	LightPhase,
	LightCone;

var const byte IterationCategory;        // used by ActorInIterationCategory() iterator, to iterate actors in a given range of IterationCategory

// Lighting group.
var(Display) enum ELightingGroup
{
	LG_Decor1,
	LG_Decor2,
	LG_Decor3,
	LG_Actor,
	LG_Decor4,
	LG_Decor5,
	LG_Decor6,
	LG_Decor7,
	LG_Decor8,
	LG_Decor9,
	LG_Decor10
} bSLightGroup;

// Collision category.
var(Collision) EColCategory ColCategory;

// Physics properties.
var(Movement) float       Mass;				// Mass of this actor.
var(Movement) float       Buoyancy;			// Water buoyancy.
var(Movement) rotator	  RotationRate;		// Change in rotation per second.
var(Movement) rotator     DesiredRotation;	// Physics will smoothly rotate actor to this rotation if bRotateToDesired.
var			  Actor		  PendingTouch;		// Actor touched during move which wants to add an effect after the movement completes
var       const vector    ColLocation;		// Actor's old location one move ago. Only for debugging

const MAXSTEPHEIGHT = 35.0; // Maximum step height walkable by pawns

//-----------------------------------------------------------------------------
// Animation replication (can be used to replicate channel 0 anims for dumb proxies)
struct AnimRep
{
	var name AnimSequence;
	var bool bAnimLoop;
	var byte AnimRate;		// note that with compression, max replicated animrate is 4.0
	var byte AnimFrame;
	var byte TweenRate;		// note that with compression, max replicated tweentime is 4 seconds
};

var transient AnimRep		  SimAnim;		   // only replicated if bReplicateAnimations is true

// AnimStruct used for scripted sequences
struct AnimStruct
{
	var() name AnimSequence;
	var() name BoneName;
	var() float AnimRate;
	var() byte alpha;
	var() byte LeadIn;
	var() byte LeadOut;
	var() bool bLoopAnim;
};


//-----------------------------------------------------------------------------
// Networking.

// Network control.
var float NetPriority; // Higher priorities means update it more frequently.
var float NetUpdateFrequency; // How many seconds between net updates.

// Symmetric network flags, valid during replication only.
var const bool bNetInitial;       // Initial network update.
var const bool bNetOwner;         // Player owns this actor.
var const bool bNetRelevant;      // Actor is currently relevant. Only valid server side, only when replicating variables.
var const bool bDemoRecording;	  // True we are currently demo recording
var const bool bClientDemoRecording;// True we are currently recording a client-side demo
var const bool bClientDemoNetFunc;// True if we're client-side demo recording and this call originated from the remote.


//Editing flags
var(Advanced) bool        bHiddenEd;     // Is hidden during editing.
var(Advanced) bool        bHiddenEdGroup;// Is hidden by the group brower.
var(Advanced) bool        bDirectional;  // Actor shows direction arrow during editing.
var const bool            bSelected;     // Selected in UnrealEd.
var bool                  bEdLocked;     // Locked in editor (no movement or rotation).
var(Advanced) bool        bEdShouldSnap; // Snap to grid in editor.
var			  bool        bEdSnap;       // Should snap to grid in UnrealEd.
var           const bool  bTempEditor;   // Internal UnrealEd.
var	bool				  bObsolete;	 // actor is obsolete - warn level designers to remove it
var(Advanced) bool        bPathColliding;// this actor should collide (if bWorldGeometry && bBlockActors is true) during path building (ignored if bStatic is true, as actor will always collide during path building)
var           bool		  bPathTemp;	 // Internal/path building

var	bool				  bScriptInitialized; // set to prevent re-initializing of actors spawned during level startup

var class<LocalMessage> MessageClass;

//-----------------------------------------------------------------------------
// Enums.

// Travelling from server to server.
enum ETravelType
{
	TRAVEL_Absolute,	// Absolute URL.
	TRAVEL_Partial,		// Partial (carry name, reset server).
	TRAVEL_Relative,	// Relative URL.
};


// double click move direction.
enum EDoubleClickDir
{
	DCLICK_None,
	DCLICK_Left,
	DCLICK_Right,
	DCLICK_Forward,
	DCLICK_Back,
	DCLICK_Active,
	DCLICK_Done
};

//-----------------------------------------------------------------------------
// natives.

// Execute a console command in the context of the current level and game engine.
native static function string ConsoleCommand( string Command );

//-----------------------------------------------------------------------------
// Network replication.

replication
{
	// Location
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& (((RemoteRole == ROLE_AutonomousProxy) && bNetInitial)
						|| ((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition) && ((Base == None) || Base.bWorldGeometry))
						|| ((RemoteRole == ROLE_DumbProxy) && ((Base == None) || Base.bWorldGeometry))) )
		Location;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& ((DrawType == DT_Mesh) || (DrawType == DT_StaticMesh))
					&& (((RemoteRole == ROLE_AutonomousProxy) && bNetInitial)
						|| ((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition) && ((Base == None) || Base.bWorldGeometry))
						|| ((RemoteRole == ROLE_DumbProxy) && ((Base == None) || Base.bWorldGeometry))) )
		Rotation;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& RemoteRole<=ROLE_SimulatedProxy )
		Base;

	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& RemoteRole<=ROLE_SimulatedProxy && (Base != None) && !Base.bWorldGeometry)
		RelativeRotation, RelativeLocation, AttachmentBone;

	// Physics
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& (((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition))
						|| ((RemoteRole == ROLE_DumbProxy) && (Physics == PHYS_Falling))) )
		Velocity;

	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& (((RemoteRole == ROLE_SimulatedProxy) && bNetInitial)
						|| (RemoteRole == ROLE_DumbProxy)) )
		Physics, bMovable;

	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& (RemoteRole <= ROLE_SimulatedProxy) && (Physics == PHYS_Rotating) )
		bFixedRotationDir, bRotateToDesired, RotationRate, DesiredRotation;

//MC for HarmonX integration
	// Sound.
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && (!bNetOwner || !bClientAnim) )
		AmbientSound, bHasPosition, bHasRollOff, PanCoeff, SaturationDistance, StabilisationDistance, StabilisationVolume;
//end MC

    unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && bNetDirty && (DrawType == DT_StaticMesh) )
      StaticMesh;

	// Animation.
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial)
				&& (Role==ROLE_Authority) && (DrawType==DT_Mesh) && bReplicateAnimations )
		SimAnim;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) )
		bHidden;

	// Properties changed using accessor functions (Owner, rendering, and collision)
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && bNetDirty )
		Owner, DrawScale, DrawScale3D, DrawType, bCollideActors,bCollideWorld,bOnlyOwnerSee,Texture,Style;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && bNetDirty
					&& (bCollideActors || bCollideWorld) )
		bProjTarget, bBlockActors, bBlockPlayers, CollisionRadius, CollisionHeight;

	// Properties changed only when spawning or in script (relationships, rendering, lighting)
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) )
		Role,RemoteRole,bNetOwner,LightType,bTearOff;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority)
					&& bNetDirty && bNetOwner )
		Inventory;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority)
					&& bNetDirty && bReplicateInstigator )
		Instigator;

	// Infrequently changed mesh properties
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority)
					&& bNetDirty && (DrawType == DT_Mesh) )
		AmbientGlow,bUnlit,PrePivot,Mesh;

	// Infrequently changed lighting properties.
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority)
					&& bNetDirty && (LightType != LT_None) )
		LightEffect, LightBrightness, LightHue, LightSaturation,
		LightRadius, LightPeriod, LightPhase,
		bDecor1Light, bDecor2Light, bDecor3Light, bActorLight, bDecor4Light, bDecor5Light,
		bDecor6Light, bDecor7Light, bDecor8Light, bDecor9Light, bDecor10Light;

}

//=============================================================================
// Actor error handling.

// Handle an error and kill this one actor.
native(233) static final function Error( coerce string S );

//=============================================================================
// General functions.

// Latent functions.
native(256) final latent function Sleep( float Seconds );

// Collision.
native(262) static final function SetCollision( optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers );
native(283) static final function bool SetCollisionSize( float NewRadius, float NewHeight );
native(424) static final function SetDrawScale(float NewScale);
native(423) static final function SetDrawScale3D(vector NewScale3D);
native(422) static final function SetDrawType(EDrawType NewDrawType);

// Movement.
native(266) static final function bool Move( vector Delta );
native(267) static final function bool SetLocation( vector NewLocation );
native(299) static final function bool SetRotation( rotator NewRotation );

// SetRelativeRotation() sets the rotation relative to the actor's base
native(421) static final function bool SetRelativeRotation( rotator NewRotation );
native(420) static final function bool SetRelativeLocation( vector NewLocation );

native(3969) static final function bool MoveSmooth( vector Delta );
native(3971) static final function AutonomousPhysics(float DeltaSeconds);

// Relations.
native(298) static final function SetBase( actor NewBase, optional vector NewFloor );
native(272) static final function SetOwner( actor NewOwner );

native(419) static final function Box GetBoundingBox();

native(418) static final function Material GetMaterial( int Index );

native static final function actor IntersectWaterPlane( vector Start, vector End, out vector Intersection );

native static final function ResetInputs();

//=============================================================================
event ParseDynamicLoading(LevelInfo pLevelInfo);
// Animation.

// Animation functions.
native(259) static final function PlayAnim( name Sequence, optional float Rate, optional float TweenTime, optional int Channel );
native(260) static final function LoopAnim( name Sequence, optional float Rate, optional float TweenTime, optional int Channel );
native(294) static final function TweenAnim( name Sequence, float Time, optional int Channel );
native(282) static final function bool IsAnimating(optional int Channel);
native(261) static final latent function FinishAnim(optional int Channel);
native(263) static final function bool HasAnim( name Sequence );
native(417) static final function StopAnimating();
native(416) static final function bool IsTweening(int Channel);

// Animation notifications.
event AnimEnd( int Channel );
native(415) static final function EnableChannelNotify ( int Channel, int Switch );
native(414) static final function int GetNotifyChannel();

//MC
//Sound notifications
event EndOfVoice();
event PauseVoice();
event UnPauseVoice();
event BeginBeginFlash();	//beginning of the transition of begin of a flash
event EndBeginFlash();		//end of the transition of begin of a flash
event BeginEndFlash();		//beginning of the transition of end of a flash
event EndEndFlash();		//end of the transition of end of a flash
event OnoStartNotif();

//end MC

// Skeletal animation.
native(413) static final function LinkSkelAnim( MeshAnimation Anim );

native(412) static final function AnimBlendParams( int Stage, optional float BlendAlpha, optional float InTime, optional float OutTime, optional name BoneName );
native(411) static final function AnimBlendToAlpha( int Stage, float TargetAlpha, float TimeInterval );

native(410) static final function coords  GetBoneCoords(   name BoneName );
native(409) static final function rotator GetBoneRotation( name BoneName, optional int Space );

native(408) static final function vector  GetRootLocation();
native(407) static final function rotator GetRootRotation();
native(406) static final function vector  GetRootLocationDelta();
native(405) static final function rotator GetRootRotationDelta();

native(404) static final function bool  AttachToBone( actor Attachment, name BoneName );
native(403) static final function bool  DetachFromBone( actor Attachment );

native(402) static final function LockRootMotion( int Lock );
native(401) static final function SetBoneScale( int Slot, optional float BoneScale, optional name BoneName );
native(400) static final function SetBoneScalePerAxis( int Slot, optional float BoneScaleX, optional float BoneScaleY, optional float BoneScaleZ, optional name BoneName );

native(399) static final function SetBoneDirection( name BoneName, rotator BoneTurn, optional vector BoneTrans, optional float Alpha );
native(398) static final function SetBoneLocation( name BoneName, optional vector BoneTrans, optional float Alpha );
native(397) static final function SetBoneRotation( name BoneName, optional rotator BoneTurn, optional int Space, optional float Alpha );
native(396) static final function GetAnimParams( int Channel, out name OutSeqName, out float OutAnimFrame, out float OutAnimRate );
native(395) static final function bool AnimIsInGroup( int Channel, name GroupName );


//=========================================================================
// Rendering.

native(394) static final function plane GetRenderBoundingSphere();
native(393) static final function vector GetCartoonLightDir();
native(392) static final function bool CheckWasVisible(float time);
native(391) static final function RecomputeBoundingVolume(bool Static);

native function RefreshDisplaying();
native(389) static final function RefreshLighting();

native static final function ReplaceATextureByAnOther( Texture SrcTexture, Texture DestTexture );

//=========================================================================
// Physics.

// Physics control.
native(301) final latent function FinishInterpolation();
native(3970) final function SetPhysics( EPhysics newPhysics );


//=========================================================================
// PSX2 Demo.

// Gameplay Timeout
native static final function float PSX2BootstrapDemoGetGamePlayTimeout();


//=========================================================================
// Engine notification functions.

//
// Major notifications.
//
event Destroyed();
event GainedChild( Actor Other );
event LostChild( Actor Other );
event Tick( float DeltaTime );

//
// Triggers.
//
event Trigger( Actor Other, Pawn EventInstigator );
event UnTrigger( Actor Other, Pawn EventInstigator );
event BeginEvent();
event EndEvent();

//
// Physics & world interaction.
//
event Timer();
event Timer2();
event HitWall( vector HitNormal, actor HitWall );
event Falling();
event Landed( vector HitNormal );
event ZoneChange( ZoneInfo NewZone );
event PhysicsVolumeChange( PhysicsVolume NewVolume );
event Touch( Actor Other );
event PostTouch( Actor Other ); // called for PendingTouch actor after physics completes
event UnTouch( Actor Other );
event Bump( Actor Other );
event BaseChange();
event Attach( Actor Other );
event Detach( Actor Other );
event Actor SpecialHandling(Pawn Other);
event bool EncroachingOn( actor Other );
event EncroachedBy( actor Other );
event FinishedInterpolation(InterpolationPoint Other);
event EndedRotation();			// called when rotation completes
event UsedBy( Pawn user ); // called if this Actor was touching a Pawn who pressed Use

event FellOutOfWorld()
{
	SetPhysics(PHYS_None);
	Destroy();
}

//
// Damage and kills.
//
event KilledBy( pawn EventInstigator );
event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType);




// Masks to discard some collisions
// Used by Trace and FastTrace.
const TRACETYPE_Standard                                        = 0x000000; // by default
const TRACETYPE_DiscardIfCanSeeThrough                          = 0x002000; // with this option, trace and fasttrace will not report collision with objects that have CanSeeThrough flag set. Practical consequence: it is possible to see through transparent windows.
const TRACETYPE_DiscardIfCanShootThroughWithRayCastingWeapon    = 0x004000; // with this option, trace and fasttrace will not report collision with objects that have CanShootThroughWithRayCastingWeapon flag set. Practical consequence: you can know if it is possible to shoot through a door with a magnum.
const TRACETYPE_DiscardIfCanShootThroughWithProjectileWeapon    = 0x008000; // with this option, trace and fasttrace will not report collision with objects that have CanShootThroughWithProjectileWeapon flag set. Practical consequence: you can know if it is possible to shoot through something with a knife.
const TRACETYPE_RequestBones 									= 0x010000; // Request the bone check.


//
// Trace a line and see what it collides with first.
// Takes this actor's collision properties into account.
// Returns first hit actor, Level if hit level, or None if hit nothing.
// An AdditionalTraceType parameter can be used to discard some kinds of hit (to be able to see through window for example). It
// can be a combination (bitwise or) of TRACETYPE_xxx constants. In this case, it is possible to know afterwards which kind of hits
// was discarded by examining DiscardedHitMask. For example, if you choose to trace with an additional trace type TRACETYPE_DiscardIfCanSeeThrough,
// if a hit was rejected because of it, DiscardedHitMask will contains TRACETYPE_DiscardIfCanSeeThrough.
//
native(277) static final function Actor Trace
(
    out vector              HitLocation,
    out vector              HitNormal,
    vector                  TraceEnd,
    optional vector         TraceStart,
    optional bool           bTraceActors,
    optional vector         Extent,
    optional out material   Material,
    optional int            AdditionalTraceType,    // TRACETYPE_Standard is the default value
    optional out int        DiscardedHitMask        // none is the default value
);

// Get the last bone name, intersected during the last Trace call with the flag TRACETYPE_RequestBones.
native(364) static final function name GetLastTraceBone();


// returns true if did not hit world geometry
// An AdditionalTraceType parameter can be used to discard some kinds of hit (to be able to see through window for example). It
// can be a combination (bitwise or) of TRACETYPE_xxx constants. In this case, it is possible to know afterwards which kind of hits
// was discarded by examining DiscardedHitMask. For example, if you choose to trace with an additional trace type TRACETYPE_DiscardIfCanSeeThrough,
// if a hit was rejected because of it, DiscardedHitMask will contains TRACETYPE_DiscardIfCanSeeThrough.
native(548) static final function bool FastTrace
(
    vector              TraceEnd,
    optional vector     TraceStart,
    optional int        AdditionalTraceType,        // TRACETYPE_Standard is the default value
    optional out int    DiscardedHitMask            // none is the default value
);

//
// Spawn an actor. Returns an actor of the specified class, not
// of class Actor (this is hardcoded in the compiler). Returns None
// if the actor could not be spawned (either the actor wouldn't fit in
// the specified location, or the actor list is full).
// Defaults to spawning at the spawner's location.
//
native(278) static final function actor Spawn
(
	class<actor>      SpawnClass,
	optional actor	  SpawnOwner,
	optional name     SpawnTag,
	optional vector   SpawnLocation,
	optional rotator  SpawnRotation
);

//
// Destroy this actor. Returns true if destroyed, false if indestructable.
// Destruction is latent. It occurs at the end of the tick.
//
native(279) static final function bool Destroy();

//=============================================================================
// Timing.

// Causes Timer() events every NewTimerRate seconds.
native(280) static final function SetTimer( float NewTimerRate, bool bLoop );

// Causes Timer2() events every NewTimerRate seconds.
native(363) static final function SetTimer2( float NewTimerRate, bool bLoop );

//=============================================================================
// Sound functions.
//MC for HarmonX integration


native static final function SetSoundMode
(
	int SoundMode
);
native(362) static final function SetMusicSliderPos
(
	int MusicVolume
);
native(361) static final function SetVolume
(
	float volume
);


// Play a sound effect.
native(264) static final function PlaySound
(
	sound				Sound,
	optional  int		Param1,
	optional  int		Param2,
	optional  int		Param3,
	optional  int		Param4,
	optional  int		Param5
);
// Play a music
native(358) static final function PlayMusic
(
	sound				Sound,
	optional  int		Param1,
	optional  int		Param2,
	optional  int		Param3,
	optional  int		Param4,
	optional  int		Param5
);
native(357) static final function float GetWaveDuration
(//get wave duration (for voices  only)
	string				SoundName
);
native(356) static final function bool WaveHasPosition
(//to know if wave is localized or not (for voices  only)
	string				SoundName
);
//native(355) static final function bool CanHearFootstepSound
//(//to know if footsteps can be heard...
//);
//Play a streamed voice
native(354) static final function bool PlayStrVoice
(
	string				SoundName,
	optional actor		RollOffActor
);
// Play a voice (wave or handler)
native(353) static final function PlayVoice
(
	sound				Sound,
	optional  int		Param1,
	optional  int		Param2,
	optional  int		Param3,
	optional  int		Param4,
	optional  int		Param5
);
// Play a streamed ambient sound
native(352) static final function PlayStrAmb
(
	sound				Sound
);
// Play a sound
native(351) static final function PlayMenu
(//soundisn't puton "SoundDesign" volume line.
	sound				Sound,
	optional int		Type,		//default : SndType_Menu (for Menu actor)
	optional  int		Param1,
	optional  int		Param2,
	optional  int		Param3,
	optional  int		Param4,
	optional  int		Param5
);
// Play a sound
native(350) static final function PlayRolloffSound
(
	sound				Sound,
	actor				RolloffActor,
	optional  int		Param1,
	optional  int		Param2,
	optional  int		Param3,
	optional  int		Param4,
	optional  int		Param5
);
// Play footstepsounds
native(349) static final function PlaySndPNJStep
(
	sndpnjstep	Sound,
	float	Speed,
	int		SndStepCategory,
	bool	bSilent
);
native(348) static final function PlaySndXIIIStep
(
	sndxiiistep	Sound,
	float	Speed,
	int		EndStep,
	bool	bSilent
);

//Play sndono
native(347) static final function PlaySndPNJOno
(
	sndono	Sound,
	int		CodeMesh,
	int		Timbre
);

//Play deathono
native(346) static final function PlaySndDeathOno
(
	deathono	Sound,
	int		CodeMesh,
	int		Timbre
);

// Stop a sound effect.
native(265) static final function StopSound
(
	sound				Sound
);
// Stop musics and streamed ambient sounds
native(345) static final function StopMusic();
// Stop voices
native(344) static final function StopVoice();
// Stop all actor sounds
native(343) static final function StopActorSounds();
// Stop all sounds
native(342) static final function StopAllSounds();

//Pause music and streamed ambient sounds
native(341) static final function PauseMusic();
//Pause all sounds
native(340) static final function PauseAllSounds();

//Kill all sounds
native static final function KillAllSounds();

//Resume music and streamed ambient sounds
native(339) static final function ResumeMusic();
//Resume all sounds
native(338) static final function ResumeAllSounds();

//end MC
//=============================================================================
// AI functions.

/* Inform other creatures that you've made a noise
 they might hear (they are sent a HearNoise message)
 Senders of MakeNoise should have an instigator if they are not pawns.
*/
native(512) static final function MakeNoise( float Loudness );

/* PlayerCanSeeMe returns true if any player (server) or the local player (standalone
or client) has a line of sight to actor's location.
*/
native(532) static final function bool PlayerCanSeeMe();

//=============================================================================
// Regular engine functions.

// Teleportation.
event bool PreTeleport( Teleporter InTeleporter );
event PostTeleport( Teleporter OutTeleporter );

// Level state.
event BeginPlay();

//========================================================================
// Disk access.

// Find files.
native(539) static final function string GetMapName( string NameEnding, string MapName, int Dir );
native(545) static final function GetNextSkin( string Prefix, string CurrentSkin, int Dir, out string SkinName, out string SkinDesc );
native(547) static final function string GetURLMap();
native(337) static final function string GetNextInt( string ClassName, int Num );
native(336) static final function GetNextIntDesc( string ClassName, int Num, out string Entry, out string Description );
native(335) static final function bool GetCacheEntry( int Num, out string GUID, out string Filename );
native(334) static final function bool MoveCacheEntry( string GUID, optional string NewFilename );

//=============================================================================
// Iterator functions.

// Iterator functions for dealing with sets of actors.

/* AllActors() - avoid using AllActors() too often as it iterates through the whole actor list and is therefore slow
*/
native(304) final iterator function AllActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag );

/* DynamicActors() only iterates through the non-static actors on the list (still relatively slow, bu
 much better than AllActors).  This should be used in most cases and replaces AllActors in most of
 Epic's game code.
*/
native(313) final iterator function DynamicActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag );

/* ChildActors() returns all actors owned by this actor.  Slow like AllActors()
*/
native(305) final iterator function ChildActors   ( class<actor> BaseClass, out actor Actor );

/* BasedActors() returns all actors based on the current actor (slow, like AllActors)
*/
native(306) final iterator function BasedActors   ( class<actor> BaseClass, out actor Actor );

/* TouchingActors() returns all actors touching the current actor (fast)
*/
native(307) final iterator function TouchingActors( class<actor> BaseClass, out actor Actor );

/* TraceActors() return all actors along a traced line.  Reasonably fast (like any trace)
*/
native(309) final iterator function TraceActors   ( class<actor> BaseClass, out actor Actor, out vector HitLoc, out vector HitNorm, vector End, optional vector Start, optional vector Extent, optional int TraceType );

/* RadiusActors() returns all actors within a give radius.  Slow like AllActors().  Use CollidingActors() or VisibleCollidingActors() instead if desired actor types are visible
(not bHidden) and in the collision hash (bCollideActors is true)
*/
native(310) final iterator function RadiusActors  ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );

/* VisibleActors() returns all visible actors within a radius.  Slow like AllActors().  Use VisibleCollidingActors() instead if desired actor types are
in the collision hash (bCollideActors is true)
*/
native(311) final iterator function VisibleActors ( class<actor> BaseClass, out actor Actor, optional float Radius, optional vector Loc );

/* VisibleCollidingActors() returns visible (not bHidden) colliding (bCollideActors==true) actors within a certain radius.
Much faster than AllActors() since it uses the collision hash
*/
native(312) final iterator function VisibleCollidingActors ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc, optional bool bIgnoreHidden );

/* VisibleDamageableActors() returns visible (not bHidden) colliding (bCollideActors==true) actors within a certain radius.
Much faster than AllActors() since it uses the collision hash.
// Same as VisibleCollidingActors but remove all StaticMeshActors
*/
native final iterator function VisibleDamageableActors ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc, optional bool bIgnoreHidden );

/* CollidingActors() returns colliding (bCollideActors==true) actors within a certain radius.
Much faster than AllActors() for reasonably small radii since it uses the collision hash
*/
native(321) final iterator function CollidingActors ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );

/* ActorInInterationCategory() returns actors that have an IterationCategory between MinCategory and MaxCategory, included.
*/
native(333) final iterator function ActorInIterationCategory( byte MinCategory, byte MaxCategory, out actor Actor);

//=============================================================================
// Color functions
native(549) static final operator(20) color -     ( color A, color B );
native(550) static final operator(16) color *     ( float A, color B );
native(551) static final operator(20) color +     ( color A, color B );
native(552) static final operator(16) color *     ( color A, float B );


//=============================================================================
native static final function bool SaveAtCheckpoint(string TeleporterName, string ContentDescription);


//=============================================================================
// Scripted Actor functions.

/* RenderOverlays()
called by player's hud to request drawing of actor specific overlays onto canvas
*/
function RenderOverlays(Canvas Canvas);

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	// Handle autodestruction if desired.
	if( !bGameRelevant && (Level.NetMode != NM_Client) && !Level.Game.BaseMutator.CheckRelevance(Self) )
		Destroy();
}

//
// Broadcast a localized message to all players.
// Most message deal with 0 to 2 related PRIs.
// The LocalMessage class defines how the PRI's and optional actor are used.
//
event BroadcastLocalizedMessage( class<LocalMessage> MessageClass, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	Level.Game.BroadcastLocalized( self, MessageClass, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

// Called immediately after gameplay begins.
//
event PostBeginPlay();

// Called after PostBeginPlay.
//
simulated event SetInitialState()
{
	bScriptInitialized = true;
	if( InitialState!='' )
		GotoState( InitialState );
	else
		GotoState( 'Auto' );
}

// called after PostBeginPlay.  On a net client, PostNetBeginPlay() is spawned after replicated variables have been initialized to
// their replicated values
event PostNetBeginPlay();

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated final function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleDamageableActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( (Victims != self) && (Victims.Role == ROLE_Authority) )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if (level.bLonePlayer && !Instigator.IsPlayerPawn() &&  Victims.IsA('BaseSoldier') ) //test bloneplayer to avoid heavy cast in multi-mode
			  DamageScale *= 0.2;
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
		}
	}
	bHurtEntry = false;
}

// Called when carried onto a new level, before AcceptInventory.
//
event TravelPreAccept();

// Called when carried into a new level, after AcceptInventory.
//
event TravelPostAccept();

// Called by PlayerController when this actor becomes its ViewTarget.
//
function BecomeViewTarget();

// Returns the string representation of the name of an object without the package
// prefixes.
//
function String GetItemName( string FullName )
{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 )
	{
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
	}

	return FullName;
}

// Returns the human readable string representation of an object.
//
// CHANGED function name from GetHumanName()
function String GetHumanReadableName()
{
	return GetItemName(string(class));
}

final function ReplaceText(out string Text, string Replace, string With)
{
	local int i;
	local string Input;

	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	while(i != -1)
	{
		Text = Text $ Left(Input, i) $ With;
		Input = Mid(Input, i + Len(Replace));
		i = InStr(Input, Replace);
	}
	Text = Text $ Input;
}

// Set the display properties of an actor.  By setting them through this function, it allows
// the actor to modify other components (such as a Pawn's weapon) or to adjust the result
// based on other factors (such as a Pawn's other inventory wanting to affect the result)
function SetDisplayProperties(ERenderStyle NewStyle, Material NewTexture, bool bLighting )
{
	Style = NewStyle;
	texture = NewTexture;
	bUnlit = bLighting;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
}

// Get localized message string associated with this actor
static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return "";
}

function MatchStarting(); // called when gameplay actually starts

/* DisplayDebug()
list important actor variable on canvas.  HUD will call DisplayDebug() on the current ViewTarget when
the ShowDebug exec is used
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	local float XL;
	local int i;
	local Actor A;
	local name anim;
	local float frame,rate;

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.StrLen("TEST", XL, YL);
	YPos = YPos + YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,0,0);
	T = GetItemName(string(self));
	if ( bDeleteMe )
		T = T$" DELETED (bDeleteMe == true)";

	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,255,255);

	if ( Level.NetMode != NM_Standalone )
	{
		// networking attributes
		T = "ROLE ";
		Switch(Role)
		{
			case ROLE_None: T=T$"None"; break;
			case ROLE_DumbProxy: T=T$"DumbProxy"; break;
			case ROLE_SimulatedProxy: T=T$"SimulatedProxy"; break;
			case ROLE_AutonomousProxy: T=T$"AutonomousProxy"; break;
			case ROLE_Authority: T=T$"Authority"; break;
		}
		T = T$" REMOTE ROLE ";
		Switch(RemoteRole)
		{
			case ROLE_None: T=T$"None"; break;
			case ROLE_DumbProxy: T=T$"DumbProxy"; break;
			case ROLE_SimulatedProxy: T=T$"SimulatedProxy"; break;
			case ROLE_AutonomousProxy: T=T$"AutonomousProxy"; break;
			case ROLE_Authority: T=T$"Authority"; break;
		}
		if ( bTearOff )
			T = T$" Tear Off";
		Canvas.DrawText(T, false);
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	T = "Physics ";
	Switch(PHYSICS)
	{
		case PHYS_None: T=T$"None"; break;
		case PHYS_Walking: T=T$"Walking"; break;
		case PHYS_Falling: T=T$"Falling"; break;
		case PHYS_Swimming: T=T$"Swimming"; break;
		case PHYS_Flying: T=T$"Flying"; break;
		case PHYS_Rotating: T=T$"Rotating"; break;
		case PHYS_Projectile: T=T$"Projectile"; break;
		case PHYS_Interpolating: T=T$"Interpolating"; break;
		case PHYS_MovingBrush: T=T$"MovingBrush"; break;
		case PHYS_Spider: T=T$"Spider"; break;
		case PHYS_Trailer: T=T$"Trailer"; break;
		case PHYS_Ladder: T=T$"Ladder"; break;
	}
	T = T$" in physicsvolume "$GetItemName(string(PhysicsVolume))$" on base "$GetItemName(string(Base));
	if ( bBounce )
		T = T$" - will bounce";
	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Location: "$Location, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Rotation: "$Rotation, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Velocity: "$Velocity$" Speed "$VSize(Velocity), false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Acceleration: "$Acceleration, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawColor.B = 0;
	Canvas.DrawText("Collision Radius "$CollisionRadius$" Height "$CollisionHeight);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Collides with Actors "$bCollideActors$", world "$bCollideWorld$", and proj. target "$bProjTarget);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Blocks Actors "$bBlockActors$", players "$bBlockPlayers);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	T = "Touching ";
	ForEach TouchingActors(class'Actor', A)
		T = T$GetItemName(string(A))$" ";
	if ( T == "Touching ")
		T = "Touching nothing";
	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawColor.R = 0;
	T = "Rendered: ";
	Switch(Style)
	{
		case STY_None: T=T; break;
		case STY_Normal: T=T$"Normal"; break;
		case STY_Masked: T=T$"Masked"; break;
		case STY_Translucent: T=T$"Translucent"; break;
		case STY_Modulated: T=T$"Modulated"; break;
		case STY_Alpha: T=T$"Alpha"; break;
	}

	Switch(DrawType)
	{
		case DT_None: T=T$" None"; break;
		case DT_Sprite: T=T$" Sprite "; break;
		case DT_Mesh: T=T$" Mesh "; break;
		case DT_Brush: T=T$" Brush "; break;
		case DT_RopeSprite: T=T$" RopeSprite "; break;
		case DT_VerticalSprite: T=T$" VerticalSprite "; break;
		case DT_Terraform: T=T$" Terraform "; break;
		case DT_SpriteAnimOnce: T=T$" SpriteAnimOnce "; break;
		case DT_StaticMesh: T=T$" StaticMesh "; break;
	}

	if ( DrawType == DT_Mesh )
	{
		T = T$Mesh;
		if ( Skins.length > 0 )
		{
			T = T$" skins: ";
			for ( i=0; i<Skins.length; i++ )
			{
				if ( skins[i] == None )
					break;
				else
					T =T$skins[i]$", ";
			}
		}

		Canvas.DrawText(T, false);
		YPos += YL;
		Canvas.SetPos(4,YPos);

		// mesh animation
		GetAnimParams(0,Anim,frame,rate);
		T = "AnimSequence "$Anim$" Frame "$frame$" Rate "$rate;
		if ( bAnimByOwner )
			T= T$" Anim by Owner";
	}
	else if ( (DrawType == DT_Sprite) || (DrawType == DT_SpriteAnimOnce) )
		T = T$Texture;
	else if ( DrawType == DT_Brush )
		T = T$Brush;

	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawColor.B = 255;
	Canvas.DrawText("Tag: "$Tag$" Event: "$Event$" STATE: "$GetStateName(), false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Instigator "$GetItemName(string(Instigator))$" Owner "$GetItemName(string(Owner)));
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Timer: "$TimerCounter$" Timer2: "$Timer2Counter$" LifeSpan "$LifeSpan);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("AmbientSound "$AmbientSound);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

// NearSpot() returns true is spot is within collision cylinder
// FIXME - make intrinsic

simulated final function bool NearSpot(vector Spot)
{
	local vector Dir;

	Dir = Location - Spot;

	if ( abs(Dir.Z) > CollisionHeight )
		return false;

	Dir.Z = 0;
	return ( VSize(Dir) <= CollisionRadius );
}

simulated final function bool TouchingActor(Actor A)
{
	local vector Dir;

	Dir = Location - A.Location;

	if ( abs(Dir.Z) > CollisionHeight + A.CollisionHeight )
		return false;

	Dir.Z = 0;
	return ( VSize(Dir) <= CollisionRadius + A.CollisionRadius );
}


// returns true if shortest rotation direction is in the positive (clockwise) direction
// from A to B
function bool PlusDir(int A, int B)
{
	A = A & 65535;
	B = B & 65535;

	if ( Abs(A - B) > 32768 )
		return ( A - B < 0 );
	return ( A - B > 0 );
}

/* StartInterpolation()
when this function is called, the actor will start moving along an interpolation path
beginning at Dest
*/
simulated function StartInterpolation()
{
	GotoState('');
	SetCollision(True,false,false);
	bCollideWorld = False;
	bInterpolating = true;
	SetPhysics(PHYS_None);
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset();

/*
Trigger an event
*/
event TriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	local Actor A;

	if ( (EventName == '') || (EventName == 'None') )
		return;

	ForEach DynamicActors( class 'Actor', A, EventName )
		A.Trigger(Other, EventInstigator);

/*
	// if triggered event is actor's event, check if it should be registered as persistent game event
	if ( (EventName == Event) && (Level.Game != None) )
	{
		if ( bTravelGameEvent )
			Level.Game.AddTravelGameEvent(EventName);
		else if ( bLocalGameEvent )
			Level.Game.AddLocalGameEvent(EventName);
	}
*/
}

/*
Untrigger an event
*/
function UntriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	local Actor A;

	if ( (EventName == '') || (EventName == 'None') )
		return;

	ForEach DynamicActors( class 'Actor', A, EventName )
		A.Untrigger(Other, EventInstigator);
}

function bool IsInVolume(Volume aVolume)
{
	local Volume V;

	ForEach TouchingActors(class'Volume',V)
		if ( V == aVolume )
			return true;
	return false;
}

function bool IsInPain()
{
	local PhysicsVolume V;

	ForEach TouchingActors(class'PhysicsVolume',V)
		if ( V.bPainCausing && (V.DamagePerSec > 0) )
			return true;
	return false;
}

function bool CanSplash()
{
	return false;
}

debugonly simulated function DumpContent(float TimeStamp, int tabulation)
{
    local int j;
    local string Tab;

    for (j=0; j<tabulation; j++) Tab = Tab$" ";
    log(Tab$"Actor's dump at "$TimeStamp$":");
    //log(Tab$"  bStatic:"$bStatic$" bHidden:"$bHidden$" bNoDelete:"$bNoDelete$" bAnimFinished:"$bAnimFinished$" bAnimByOwner:"$bAnimByOwner$" bDeleteMe:"$bDeleteMe);
    //log(Tab$"  bTicked:"$bTicked$" bDynamicLight:"$bDynamicLight$" bTimerLoop:"$bTimerLoop$" bTimer2Loop:"$bTimer2Loop$" bCanTeleport:"$bCanTeleport$" bOwnerNoSee:"$bOwnerNoSee);
        log(Tab$"  bTicked:"$bTicked$" bTimerLoop:"$bTimerLoop$" bCanTeleport:"$bCanTeleport);
    //log(Tab$"  bOnlyOwnerSee:"$bOnlyOwnerSee$" bAlwaysTick:"$bAlwaysTick$" bHighDetail:"$bHighDetail$" bStasis:"$bStasis$" bTrailerSameRotation:"$bTrailerSameRotation);
        log(Tab$"  bStasis:"$bStasis);
    //log(Tab$"  bTrailerPrePivot:"$bTrailerPrePivot$" bClientAnim:"$bClientAnim$" bWorldGeometry:"$bWorldGeometry$" bAcceptsProjectors:"$bAcceptsProjectors$" bOrientOnSlope:"$bOrientOnSlope);
    //log(Tab$"  bNetTemporary:"$bNetTemporary$" bNetOptional:"$bNetOptional$" bNetDirty:"$bNetDirty$" bAlwaysRelevant:"$bAlwaysRelevant);
        log(Tab$"  bNetDirty:"$bNetDirty);
    //log(Tab$"  bReplicateInstigator:"$bReplicateInstigator$" bReplicateMovement:"$bReplicateMovement$" bSkipActorPropertyReplication:"$bSkipActorPropertyReplication$" bUpdateSimulatedPosition:"$bUpdateSimulatedPosition);
    //log(Tab$"  bTearOff:"$bTearOff$" bOnlyDirtyReplication:"$bOnlyDirtyReplication$" bReplicateAnimations:"$bReplicateAnimations$" Role:"$Role$" RemoteRole:"$RemoteRole);

    //log(Tab$"  Physics:"$Physics$" DrawType:"$DrawType$" NetTag:"$NetTag$" LastRenderTime:"$LastRenderTime$" Tag:"$Tag);
        log(Tab$"  Physics:"$Physics$" NetTag:"$NetTag);
    log(Tab$"  TimerRate:"$TimerRate$" TimerCounter:"$TimerCounter$" Timer2Rate:"$Timer2Rate$" Timer2Counter:"$Timer2Counter$" LifeSpan:"$LifeSpan);
    //log(Tab$"  AnimSequence:"$AnimSequence$" AnimFrame:"$AnimFrame$" AnimRate:"$AnimRate$" TweenRate:"$TweenRate);
    //log(Tab$"  MeshInstance:"$MeshInstance$" Owner:"$Owner$" InitialState:"$InitialState$" Group:"$Group);
    //log(Tab$"  Level:"$Level$" XLevel:"$XLevel$" Event:"$Event$" Instigator:"$Instigator$" AmbientSound:"$AmbientSound$" Inventory:"$Inventory$" Base:"$Base$" Region.ZoneNumber:"$Region.ZoneNumber);
    //log(Tab$"  LatentFloat:"$LatentFloat$" CollisionTag:"$CollisionTag$" LightingTag:"$LightingTag$" ActorTag:"$ActorTag$" PhysicsVolume:"$PhysicsVolume);
    log(Tab$"  Location:"$Location$" Rotation:"$Rotation$" Velocity:"$Velocity$" Acceleration:"$Acceleration);
    //log(Tab$"  AttachTag:"$AttachTag$" RelativeLocation:"$RelativeLocation$" RelativeRotation:"$RelativeRotation$" AttachmentBone:"$AttachmentBone);

    //log(Tab$"  Texture:"$Texture$" Mesh:"$Mesh$" StaticMesh:"$StaticMesh$" StaticMeshInstance:"$StaticMeshInstance$" Brush:"$Brush$" DrawScale:"$DrawScale);
    //log(Tab$"  DrawScale3D:"$DrawScale3D$" PrePivot:"$PrePivot$" AmbientGlow:"$AmbientGlow$" AntiPortal:"$AntiPortal$" Style:"$Style);
    //log(Tab$"  bUnlit:"$bUnlit$" bNoSmooth:"$bNoSmooth$" bShadowCast:"$bShadowCast$" bStaticLighting:"$bStaticLighting$" bNoAmbientLight:"$bNoAmbientLight$" bNoImpact:"$bNoImpact);
    //log(Tab$"  bHurtEntry:"$bHurtEntry$" bGameRelevant:"$bGameRelevant$" bCollideWhenPlacing:"$bCollideWhenPlacing$" bTravel:"$bTravel);
    //log(Tab$"  bMovable:"$bMovable$" bLocalGameEvent:"$bLocalGameEvent$" bTravelGameEvent:"$bTravelGameEvent$" bDestroyInPainVolume:"$bDestroyInPainVolume$" bPendingDelete:"$bPendingDelete);

    //log(Tab$"  bHasRollOff:"$bHasRollOff$" bHasPosition:"$bHasPosition$" PanCoeff:"$PanCoeff$" SaturationDistance:"$SaturationDistance$" StabilisationDistance:"$StabilisationDistance$" StabilisationVolume:"$StabilisationVolume$" SNDMaterial:"$SNDMaterial);

    //log(Tab$"  CollisionRadius:"$CollisionRadius$" CollisionHeight:"$CollisionHeight$" bCollideActors:"$bCollideActors$" bCollideWorld:"$bCollideWorld);
    //log(Tab$"  bBlockActors:"$bBlockActors$" bBlockPlayers:"$bBlockPlayers$" bProjTarget:"$bProjTarget$" bBlockZeroExtentTraces:"$bBlockZeroExtentTraces$" bBlockNonZeroExtentTraces:"$bBlockNonZeroExtentTraces$" bUseCylinderCollision:"$bUseCylinderCollision);
    //log(Tab$"  LightType:"$LightType$" LightEffect:"$LightEffect$" LightBrightness:"$LightBrightness$" LightHue:"$LightHue$" LightSaturation:"$LightSaturation);
    //log(Tab$"  LightRadius:"$LightRadius$" LightPeriod:"$LightPeriod$" LightPhase:"$LightPhase$" LightCone:"$LightCone$");
    //log(Tab$"  bSLightGroup:"$bSLightGroup$" bDecor1Light:"$bDecor1Light$" bDecor2Light:"$bDecor2Light$" bDecor3Light:"$bDecor3Light$" bActorLight:"$bActorLight$" bDecor4Light:"$bDecor4Light$" bDecor5Light:"$bDecor5Light$" bDecor6Light:"$bDecor6Light$" bDecor7Light:"$bDecor7Light$" bDecor8Light:"$bDecor8Light$" bDecor9Light:"$bDecor9Light$" bDecor10Light:"$bDecor10Light);
    //log(Tab$"  bActorShadows:"$bActorShadows$" bCorona:"$bCorona$" bLensFlare:"$bLensFlare$" bLightOwnZone:"$bLightOwnZone$" bLightChanged:"$bLightChanged);

    //log(Tab$"  bBounce:"$bBounce$" bFixedRotationDir:"$bFixedRotationDir$" bRotateToDesired:"$bRotateToDesired$" bInterpolating:"$bInterpolating$" bJustTeleported:"$bJustTeleported);
        log(Tab$"  bJustTeleported:"$bJustTeleported);
    //log(Tab$"  Mass:"$Mass$" Buoyancy:"$Buoyancy$" RotationRate:"$RotationRate$" DesiredRotation:"$DesiredRotation$" PendingTouch:"$PendingTouch$" ColLocation:"$ColLocation);
        log(Tab$"  DesiredRotation:"$DesiredRotation);
    log(Tab$"  SimAnim.AnimSequence:"$SimAnim.AnimSequence$" SimAnim.bAnimLoop:"$SimAnim.bAnimLoop$" SimAnim.AnimRate:"$SimAnim.AnimRate$" SimAnim.AnimFrame:"$SimAnim.AnimFrame$" SimAnim.TweenRate:"$SimAnim.TweenRate);
    //log(Tab$"  ForceType:"$ForceType$" ForceRadius:"$ForceRadius$" ForceScale:"$ForceScale);
    //log(Tab$"  NetPriority:"$NetPriority$" NetUpdateFrequency:"$NetUpdateFrequency$" bNetInitial:"$bNetInitial$" bNetOwner:"$bNetOwner$" bNetRelevant:"$bNetRelevant$" bDemoRecording:"$bDemoRecording$" bClientDemoRecording:"$bClientDemoRecording$" bClientDemoNetFunc:"$bClientDemoNetFunc);
        log(Tab$"  NetPriority:"$NetPriority);
    //log(Tab$"  bHiddenEd:"$bHiddenEd$" bHiddenEdGroup:"$bHiddenEdGroup$" bDirectional:"$bDirectional$" bSelected:"$bSelected$" bEdLocked:"$bEdLocked$" bEdShouldSnap:"$bEdShouldSnap$" bEdSnap:"$bEdSnap);
    //log(Tab$"  bTempEditor:"$bTempEditor$" bObsolete:"$bObsolete$" bPathColliding:"$bPathColliding$" bPathTemp:"$bPathTemp$" bScriptInitialized:"$bScriptInitialized$" MessageClass:"$MessageClass);

/*
var transient array<int>  Leaves;
var const array<Actor>    Touching;		 // List of touching actors.
var const actor           Deleted;       // Next actor in just-deleted chain.
var const array<Actor>  Attached;			// array of actors attached to this actor.
var const transient array<ProjectorRenderInfoPtr> Projectors;// Projected textures on this actor
var(Display) array<Material> Skins;				// Multiple skin support - not replicated.
*/
    log(Tab$"End Actor's dump at "$TimeStamp$":");
}

defaultproperties
{
     bDecor1Light=True
     bDecor2Light=True
     bDecor3Light=True
     bDecor4Light=True
     bDecor5Light=True
     bDecor6Light=True
     bDecor7Light=True
     bDecor8Light=True
     bDecor9Light=True
     bDecor10Light=True
     bInteractive=True
     bReplicateMovement=True
     bIgnoreDynLight=True
     bMovable=True
     bHasRollOff=True
     bHasPosition=True
     bBlockZeroExtentTraces=True
     bBlockNonZeroExtentTraces=True
     bJustTeleported=True
     Role=ROLE_Authority
     RemoteRole=ROLE_DumbProxy
     DrawType=DT_Sprite
     Texture=Texture'Engine.S_Actor'
     DrawScale=1.000000
     DrawScale3D=(X=1.000000,Y=1.000000,Z=1.000000)
     PanCoeff=0.600000
     SaturationDistance=400.000000
     StabilisationDistance=1392.000000
     StabilisationVolume=-40.000000
     VoicesSaturationDistance=250.000000
     VoicesStabilisationDistance=1986.000000
     VoicesStabilisationVolume=-40.000000
     CollisionRadius=22.000000
     CollisionHeight=22.000000
     Style=STY_Normal
     bSLightGroup=LG_Actor
     Mass=100.000000
     NetPriority=1.000000
     NetUpdateFrequency=100.000000
     MessageClass=Class'Engine.LocalMessage'
}
