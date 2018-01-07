//=============================================================================
// Engine: The base class of the global application object classes.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Engine extends Subsystem
	native
	noexport
	transient;

// Drivers.
var(Drivers) config class<AudioSubsystem> AudioDevice;
var(Drivers) config class<Interaction>    Console;				// The default system console
var(Drivers) config class<Interaction>	  DefaultMenu;			// The default system menu
var(Drivers) config class<Interaction>	  DefaultPlayerMenu;	// The default player menu
var(Drivers) config class<NetDriver>      NetworkDevice;
var(Drivers) config class<Language>       Language;

// Variables.
var primitive Cylinder;
var primitive CylinderNS;
var const client Client;
var const audiosubsystem Audio;
var const int AudioSaver;
var const renderdevice GRenDev;
var const matchmakingsubsystem MatchMakingSubsystem;
var const  videoplayerdevice   VideoPlayerDevice;
var const  savegamedevice   SaveGameDevice;
var const  forcefeedbackcontroller   ForceFeedbackController;
var const xboxlive XboxLive;


// Stats.
var const int Stats;
var int bShowFrameRate;
var int bShowAnimStats;		 // Show animation statistics.
var int bShowNetStats;
var int bShowOctreeBox;
var int bAccumulateStats;
var int bShowXboxMemStats;
var int bSkipAntiPortal;
var int bShowVolumes;
var config int XIIIStatX, XIIIStatY;

var Texture	ProjGradientTexture;
var Texture	ProjClipTexture;

var int TickCycles, GameCycles, ClientCycles;
var(Settings) config int CacheSizeMegs;
var(Settings) config bool UseSound;
var(Settings) float CurrentTickRate;

var bool DisplaySelSize;
var vector SelSize;
var Actor SelActor;
var float FrameLenght;
var int CurrentFrameCount;

var const int ConnectionStatus;         // To know the status of a connection between a client and a server
var const string ConnectionError;

var const int dummy;	//m_hDlxMem;
var const float dummy1; //m_fDeltaTime;
var const float dummy2; //m_fTotalTime


var int GamepadErrorCount;
var int GamepadErrorPlayer[4];
var int GamepadErrorPort[4];

// Color preferences.
var(Colors) config color
	C_WorldBox,
	C_GroundPlane,
	C_GroundHighlight,
	C_BrushWire,
	C_Pivot,
	C_Select,
	C_Current,
	C_AddWire,
	C_SubtractWire,
	C_GreyWire,
	C_BrushVertex,
	C_BrushSnap,
	C_Invalid,
	C_ActorWire,
	C_ActorHiWire,
	C_Black,
	C_White,
	C_Mask,
	C_SemiSolidWire,
	C_NonSolidWire,
	C_WireBackground,
	C_WireGridAxis,
	C_ActorArrow,
	C_ScaleBox,
	C_ScaleBoxHi,
	C_ZoneWire,
	C_Mover,
	C_OrthoBackground,
	C_StaticMesh,
	C_VolumeBrush,
	C_ConstraintLine,
	C_AnimMesh,
	C_LockedActor,
	C_XIIIStat,
	C_AntiPortal;

var Material WhiteTextureMaterial;
var Material WhiteTextureMaterialA255;
var Material WhiteTextureMaterialA128;

defaultproperties
{
     ProjGradientTexture=Texture'Engine.ProjGradient'
     ProjClipTexture=Texture'Engine.ProjClip'
     CacheSizeMegs=2
     UseSound=True
     C_WorldBox=(B=107,A=255)
     C_GroundPlane=(B=63,A=255)
     C_GroundHighlight=(B=127,A=255)
     C_BrushWire=(B=63,G=63,R=255,A=255)
     C_Pivot=(G=255,A=255)
     C_Select=(B=127,A=255)
     C_Current=(A=255)
     C_AddWire=(B=255,G=127,R=127,A=255)
     C_SubtractWire=(B=63,G=192,R=255,A=255)
     C_GreyWire=(B=163,G=163,R=163,A=255)
     C_BrushVertex=(A=255)
     C_BrushSnap=(A=255)
     C_Invalid=(B=163,G=163,R=163,A=255)
     C_ActorWire=(G=63,R=127,A=255)
     C_ActorHiWire=(G=127,R=255,A=255)
     C_Black=(A=255)
     C_White=(B=255,G=255,R=255,A=255)
     C_Mask=(A=255)
     C_SemiSolidWire=(G=255,R=127,A=255)
     C_NonSolidWire=(B=32,G=192,R=63,A=255)
     C_WireBackground=(A=255)
     C_WireGridAxis=(B=119,G=119,R=119,A=255)
     C_ActorArrow=(R=163,A=255)
     C_ScaleBox=(B=11,G=67,R=151,A=255)
     C_ScaleBoxHi=(B=157,G=149,R=223,A=255)
     C_ZoneWire=(A=255)
     C_Mover=(B=255,R=255,A=255)
     C_OrthoBackground=(B=163,G=163,R=163,A=255)
     C_StaticMesh=(B=255,G=255,A=255)
     C_VolumeBrush=(B=225,G=196,R=255,A=255)
     C_ConstraintLine=(G=255,A=255)
     C_AnimMesh=(B=28,G=221,R=221,A=255)
     C_LockedActor=(B=102,G=102,R=102,A=255)
     C_XIIIStat=(B=255,G=255,R=255,A=255)
     C_AntiPortal=(B=100,R=200,A=255)
}
