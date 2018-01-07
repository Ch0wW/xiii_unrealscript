//=============================================================================
// ZoneInfo, the built-in Unreal class for defining properties
// of zones.  If you place one ZoneInfo actor in a
// zone you have partioned, the ZoneInfo defines the 
// properties of the zone.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ZoneInfo extends Info
	native
	placeable;

#exec Texture Import File=Textures\ZoneInfo.pcx Name=S_ZoneInfo Mips=Off MASKED=1 COMPRESS=DXT1

//-----------------------------------------------------------------------------
// Zone properties.

var skyzoneinfo SkyZone; // Optional sky zone containing this zone's sky.
var() name ZoneTag;
var() skyzoneinfo SkyZoneUser; // Sky zone defined by the user.

//-----------------------------------------------------------------------------
// Zone flags.

var() const bool   bFogZone;     // Zone is fog-filled.
var()		bool   bTerrainZone;	// There is terrain in this zone.
var()		bool   bDistanceFog;	// There is distance fog in this zone.
var()		bool   bFogPerZone;		// Apply to each visible zone its own fog.
var()		bool   bForceClear;		// Force clear to be done.

var const array<TerrainInfo> Terrains;

//-----------------------------------------------------------------------------
// Zone light.

var(ZoneLight) byte AmbientBrightness, AmbientHue, AmbientSaturation;

var(ZoneLight) color DistanceFogColor;
var(ZoneLight) float DistanceFogStart;
var(ZoneLight) float DistanceFogEnd;

var(ZoneLight) const texture EnvironmentMap;
var(ZoneLight) float TexUPanSpeed, TexVPanSpeed;

//-----------------------------------------------------------------------------
// Zone cartoon.

var(ZoneCartoon) byte LightCurveShadow, LightCurveBright, AmbientIntensity;

//-----------------------------------------------------------------------------
// Flash effect.

struct FlashEffectStruct
{
	var() bool     IsActivated;
	var() bool     NoGrey;
	var() byte     Contrast;
	var() byte     Brightness;
	var() byte     LayerBrightness;
	var() color    LayerColor;
	var() float    LayerSampling[8];
};

var (FlashEffect) FlashEffectStruct FlashEffectDesc;

//-----------------------------------------------------------------------------
// Reverb.

// Settings.
var(Reverb) bool bReverbZone;
var(Reverb) bool bRaytraceReverb;
var(Reverb) float SpeedOfSound;
var(Reverb) byte MasterGain;
var(Reverb) int  CutoffHz;
var(Reverb) byte Delay[6];
var(Reverb) byte Gain[6];

//LEGEND:begin
//-----------------------------------------------------------------------------
// Lens flare.

var(LensFlare) texture LensFlare[12];
var(LensFlare) float LensFlareOffset[12];
var(LensFlare) float LensFlareScale[12];

//-----------------------------------------------------------------------------
// per-Zone mesh LOD lighting control
 
// the number of lights applied to the actor mesh is interpolated between the following
// properties, as a function of the MeshPolyCount for the previous frame.
var() byte MinLightCount; // minimum number of lights to use (when MaxLightingPolyCount is exceeded)
var() byte MaxLightCount; // maximum number of lights to use (when MeshPolyCount drops below MinLightingPolyCount)
var() int MinLightingPolyCount;
var() int MaxLightingPolyCount;
// (NOTE: the default LOD properties (below) have no effect on the mesh lighting behavior)
//LEGEND:end

//=============================================================================
// Iterator functions.

// Iterate through all actors in this zone.
native(308) final iterator function ZoneActors( class<actor> BaseClass, out actor Actor );

simulated function LinkToSkybox()
{
	local skyzoneinfo TempSkyZone;

	if ( SkyZoneUser != None )
	{
		SkyZone = SkyZoneUser;
	}
	else
	{
		// SkyZone.
		foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
			SkyZone = TempSkyZone;
		foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
			if( TempSkyZone.bHighDetail == Level.bHighDetailMode )
				SkyZone = TempSkyZone;
	}
}

//=============================================================================
// Engine notification functions.

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// call overridable function to link this ZoneInfo actor to a skybox
	LinkToSkybox();
}

// When an actor enters this zone.
event ActorEntered( actor Other );

// When an actor leaves this zone.
event ActorLeaving( actor Other );

defaultproperties
{
     AmbientSaturation=255
     DistanceFogColor=(B=128,G=128,R=128)
     DistanceFogStart=3000.000000
     DistanceFogEnd=8000.000000
     TexUPanSpeed=1.000000
     TexVPanSpeed=1.000000
     LightCurveShadow=144
     LightCurveBright=255
     AmbientIntensity=128
     FlashEffectDesc=(Contrast=128,Brightness=64,LayerBrightness=128,LayerColor=(B=255,G=204,R=204,A=255),LayerSampling[0]=0.400000,LayerSampling[1]=0.400000,LayerSampling[2]=0.550000,LayerSampling[3]=0.550000,LayerSampling[4]=0.750000,LayerSampling[5]=0.750000)
     MasterGain=100
     CutoffHz=6000
     Delay(0)=20
     Delay(1)=34
     Gain(0)=150
     Gain(1)=70
     MinLightCount=6
     MaxLightCount=6
     MinLightingPolyCount=1000
     MaxLightingPolyCount=5000
     bStatic=True
     bNoDelete=True
     Texture=Texture'Engine.S_ZoneInfo'
}
