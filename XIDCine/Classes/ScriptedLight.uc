//=============================================================================
// ScriptedLight.
// A lightsource which can be triggered on or off using a complex script.
//=============================================================================
class ScriptedLight extends Light;

//-----------------------------------------------------------------------------
// Variables.

var() bool  bInitiallyOn;      // Whether it's initially on.

var   float InitialBrightness; // Initial brightness.
var   actor SavedTrigger;
var int index;
struct SLightScript
{
    var() ELightType    LightType;
    var() int           Time;
};

var() array<SLightScript> TurnOnScript;
var() array<SLightScript> TurnOffScript;
var name    CurrentState;
var bool    bOnOff;

//-----------------------------------------------------------------------------
// Engine functions.

// Called at start of gameplay.
simulated function BeginPlay()
{
    InitialBrightness = LightBrightness;
    bOnOff = bInitiallyOn;
    if (!bOnOff)
      LightBrightness=0;
    SetDrawType(DT_None);
}

// Trigger toggles the light.
state() TriggerToggle
{
/*	EVENT BeginState()
	{
		DebugLog("ScriptedLight::TriggerToggle::BeginState");
		enable('Trigger');
	}
*/
	FUNCTION Trigger( actor Other, pawn EventInstigator )
	{
		DebugLog("ScriptedLight::TriggerToggle::Trigger");
		if( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		bOnOff=!bOnOff;
		if (bOnOff)
			GotoState( 'TriggerToggle', 'TurnOff' );
		else
			GotoState( 'TriggerToggle', 'TurnOn' );
	}
TurnOn:
	DebugLog("ScriptedLight::PlayTurnOnScript::Begin");
	LightBrightness = InitialBrightness;
  RefreshLighting();
	index=0;
	while (index<TurnOnScript.Length)
	{
		DebugLog("ScriptedLight::PlayTurnOnScript::in loop");
//		LightType=TurnOnScript[index].LightType;
		Sleep(TurnOnScript[index].Time);
		++index;
	}
	stop;

TurnOff:
	DebugLog("ScriptedLight::PlayTurnOffScript::Begin");
  index=0;
  while (index<TurnOffScript.Length)
  {
		DebugLog("ScriptedLight::PlayTurnOffScript::in loop");
//        LightType=TurnOffScript[index].LightType;
    Sleep(TurnOffScript[index].Time);
    ++index;
  }
  LightBrightness = 0;
  RefreshLighting();
	stop;
}

//	bNoDelete=false



defaultproperties
{
     bStatic=False
     bHidden=False
     bNoDelete=False
     bDynamicLight=True
     bMovable=True
     RemoteRole=ROLE_SimulatedProxy
     InitialState="TriggerToggle"
}
