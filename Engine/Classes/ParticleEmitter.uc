//=============================================================================
// ParticleEmitter: Base class for sub- emitters.
//
// make sure to keep structs in sync in UnParticleSystem.h
//=============================================================================

class ParticleEmitter extends Object
	abstract
	editinlinenew
	native;

enum EBlendMode
{
	BM_MODULATE,
	BM_MODULATE2X,
	BM_MODULATE4X,
	BM_ADD,
	BM_ADDSIGNED,
	BM_ADDSIGNED2X,
	BM_SUBTRACT,
	BM_ADDSMOOTH,
	BM_BLENDDIFFUSEALPHA,
	BM_BLENDTEXTUREALPHA,
	BM_BLENDFACTORALPHA,
	BM_BLENDTEXTUREALPHAPM,
	BM_BLENDCURRENTALPHA,
	BM_PREMODULATE,
	BM_MODULATEALPHA_ADDCOLOR,
	BM_MODULATEINVALPHA_ADDCOLOR,
	BM_MODULATEINVCOLOR_ADDALPHA,
	BM_HACK	
};

enum EParticleDrawStyle
{
	PTDS_Regular,
	PTDS_AlphaBlend,
	PTDS_Modulated,
	PTDS_Translucent,
	PTDS_AlphaModulate_MightNotFogCorrectly,
	PTDS_Darken,
	PTDS_Brighten,
	PTDS_Masked
};

enum EParticleCoordinateSystem
{
	PTCS_Independent,
	PTCS_Relative,
	PTCS_Absolute
};

enum EParticleRotationSource
{
	PTRS_None,
	PTRS_Actor,
	PTRS_Offset,
	PTRS_Normal
};

enum EParticleVelocityDirection
{
	PTVD_None,
	PTVD_StartPositionAndOwner,
	PTVD_OwnerAndStartPosition
};

enum EParticleStartLocationShape
{
	PTLS_Box,
	PTLS_Sphere
};

enum EParticleEffectAxis
{
	PTEA_NegativeX,
	PTEA_PositiveZ
};

struct ParticleTimeScale
{
	var () float	RelativeTime;		// always in range [0..1]
	var () float	RelativeSize;
};

struct ParticleColorScale
{
	var () float	RelativeTime;		// always in range [0..1]
	var () color	Color;
};


struct Particle
{
	var vector	Location;
	var vector	OldLocation;
	var vector	Velocity;
	var vector	StartSize;
	var vector	SpinsPerSecond;
	var vector	StartSpin;
	var vector	Size;
	var vector  StartLocation;
	var rotator Rotation;
	var color   Color;
	var float	Time;
	var float	MaxLifetime;
	var float	Mass;
	var int		HitCount;
	var int		Flags;
	var int		Subdivision;
};


var (Acceleration)	vector				Acceleration;

var (Collision)		bool				UseCollision;
var (Collision)		bool				UseCollisionPlanes;
var	(Collision)		bool				UseMaxCollisions;
var (Collision)		bool				UseSpawnedVelocityScale;

var (Color)			bool				UseColorScale;

var (Fading)		bool				FadeOut;
var (Fading)		bool				FadeIn;

var (General)		bool				ResetAfterChange;

var (Local)			bool				RespawnDeadParticles;
var (Local)			bool				AutoDestroy;
var (Local)			bool				AutoReset;
var (Local)			bool				Disabled;
var (Local)			bool				DisableFogging;

var (Rotation)		bool				SpinParticles;
var (Rotation)		bool				DampRotation;

var (Size)			bool				UseSizeScale;
var (Size)			bool				UseRegularSizeScale;
var (Size)			bool				UniformSize;

var (Spawning)		bool				AutomaticInitialSpawning;

var (Texture)		bool				BlendBetweenSubdivisions;
var	(Texture)		bool				UseSubdivisionScale;
var (Texture)		bool				UseRandomSubdivision;
var (Texture)		bool				NoSynchroAnim;
var (Texture)		bool				OnceTextureAnim;
var (Texture)		bool				SymmetryU;
var (Texture)		bool				SymmetryV;
var (Texture)		bool				RandomSymmetryU;
var (Texture)		bool				RandomSymmetryV;

var					bool				Initialized;
var 				bool				Inactive;
var					bool				RealDisableFogging;
var 				bool				AllParticlesDead;
var					bool				WarmedUp;

var (Collision)		vector				ExtentMultiplier;
var (Collision)		rangevector			DampingFactorRange;
var (Collision)		array<plane>		CollisionPlanes;
var (Collision)		range				MaxCollisions;
var (Collision)		int					SpawnFromOtherEmitter;
var (Collision)		int					SpawnAmount;
var (Collision)		rangevector			SpawnedVelocityScaleRange;


var (Color)			array<ParticleColorScale> ColorScale;
var (Color)			float				ColorScaleRepeats;

var (Fading)		plane				FadeOutFactor;
var (Fading)		float				FadeOutStartTime;
var (Fading)		plane				FadeInFactor;
var (Fading)		float				FadeInEndTime;

var (General)		EParticleCoordinateSystem CoordinateSystem;
var (General)		const int			MaxParticles;
var (General)		EParticleEffectAxis EffectAxis;

var (Local)			range				AutoResetTimeRange;
var (Local)			string				Name;

var (Location)		vector				StartLocationOffset;
var (Location)		rangevector			StartLocationRange;
var (Location)		int					AddLocationFromOtherEmitter;
var (Location)		EParticleStartLocationShape StartLocationShape;
var (Location)		range				SphereRadiusRange;

var (Mass)			range				StartMassRange;

var (Rotation)		EParticleRotationSource	UseRotationFrom;
var (Rotation)		rotator				RotationOffset;
var (Rotation)		vector				SpinCCWorCW;
var (Rotation)		rangevector			SpinsPerSecondRange;
var (Rotation)		rangevector			StartSpinRange;
var (Rotation)		rangevector			RotationDampingFactorRange;
var (Rotation)		vector				RotationNormal;

var (Size)			array<ParticleTimeScale> SizeScale;
var (Size)			float				SizeScaleRepeats;
var (Size)			rangevector			StartSizeRange;
var (Size)			float				CenterU;
var (Size)			float				CenterV;

var (Spawning)		float				ParticlesPerSecond;
var (Spawning)		float				InitialParticlesPerSecond;

var (Texture)		EParticleDrawStyle	DrawStyle;
var (Texture)		texture				Texture;
var (Texture)		int					TextureUSubdivisions;
var (Texture)		int					TextureVSubdivisions;
var (Texture)		array<float>		SubdivisionScale;
var (Texture)		int					SubdivisionStart;
var (Texture)		int					SubdivisionEnd;

var (Tick)			float				SecondsBeforeInactive;
var (Tick)			float				MinSquaredVelocity;

var	(Time)			range				InitialTimeRange;
var (Time)			range				LifetimeRange;
var (Time)			range				InitialDelayRange;

var (Velocity)		rangevector			StartVelocityRange;
var (Velocity)		vector				MaxAbsVelocity;
var (Velocity)		rangevector			VelocityLossRange;
var (Velocity)		int					AddVelocityFromOtherEmitter;
var (Velocity)		EParticleVelocityDirection GetVelocityDirectionFrom;

var (Warmup)		float				WarmupTicksPerSecond;
var (Warmup)		float				RelativeWarmupTime;

var transient		emitter				Owner;
var transient		float				InactiveTime;
var transient		array<Particle>		Particles;
var transient		int					ParticleIndex;			// index into circular list of particles
var transient		int					ActiveParticles;		// currently active particles
var transient		float				PPSFraction;			// used to keep track of fractional PPTick

var transient		vector				RealExtentMultiplier;
var	transient		int					OtherIndex;
var transient		float				InitialDelay;
var transient		vector				GlobalOffset;
var transient		float				TimeTillReset;
var transient		int					PS2Data;

var transient		texture				CurAnimTexture;
var transient		float				CurAnimTime;
var	transient		int					CurLastUpdateTime[2];

native function SpawnParticle( int Amount );
native function SetMaxParticles( int NewMaxParticles );

defaultproperties
{
     RespawnDeadParticles=True
     UseRegularSizeScale=True
     UniformSize=True
     AutomaticInitialSpawning=True
     ExtentMultiplier=(X=1.000000,Y=1.000000,Z=1.000000)
     DampingFactorRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
     SpawnFromOtherEmitter=-1
     FadeOutFactor=(W=1.000000,X=1.000000,Y=1.000000,Z=1.000000)
     FadeInFactor=(W=1.000000,X=1.000000,Y=1.000000,Z=1.000000)
     AddLocationFromOtherEmitter=-1
     StartMassRange=(Min=1.000000,Max=1.000000)
     SpinCCWorCW=(X=0.500000,Y=0.500000,Z=0.500000)
     StartSizeRange=(X=(Min=100.000000,Max=100.000000),Y=(Min=100.000000,Max=100.000000),Z=(Min=100.000000,Max=100.000000))
     DrawStyle=PTDS_Translucent
     Texture=Texture'Engine.S_Emitter'
     SecondsBeforeInactive=1.000000
     LifetimeRange=(Min=4.000000,Max=4.000000)
     AddVelocityFromOtherEmitter=-1
}
