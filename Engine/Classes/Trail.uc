//=============================================================================
// Trail: An trail Actor.
// David Fournier
//=============================================================================
class Trail extends Actor
	native
	noexport;

// Call the Init function after each change of these variables :
var()				float			SpawnFreq;     // Number of new sections per second.
var()				float			FadePeriod;    // Time lenght of a section fade.
// Following variables can be changed at any time without call to Init.
var()				float			Width;         // Initial width.
var()				float			ScaleLin;      // Lenght added to the ribbon width each second (can be negative).
var()				float			UVScale;       // Texture per Unreal unit.
var()				float			CurRotation;   // Current section rotation.
var()				float			RotationSpeed; // Rotation speed in turn per second.
var()				vector			ActorOffset;   // Offset from the attached actor in its coordinates.
var()				color			RibbonColor;   // Color used for the ribbons.
var()				color			OutlineColor;  // Color used for the outline.
var()				bool			CrossMode;     // Use a cross instead the simple line for each section.
var()				bool			DrawOutline;   // Draw the outline in addition to the ribbons.
var()				bool			BeginPoint;    // The first section has a null width.
var					bool			AutoDestroy;   // Automatic destroy when there is no more sections and when the attached actor is unlinked.

var		transient	int				PrivateData[9];// Internal.

// Initialise the trail when all parameters are set.
native(601) static final function Init();

// Reset the trail.
native function Reset();

// Add manually a new section to the trail.
native(603) static final function AddSection( vector Position );

defaultproperties
{
     SpawnFreq=20.000000
     FadePeriod=2.000000
     width=10.000000
     ScaleLin=-5.000000
     UVScale=0.100000
     RotationSpeed=2.000000
     RibbonColor=(B=64,G=128,R=128)
     DrawOutline=True
     AutoDestroy=True
     bInteractive=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     RemoteRole=ROLE_None
     DrawType=DT_Trail
     Texture=None
     Style=STY_Translucent
}
