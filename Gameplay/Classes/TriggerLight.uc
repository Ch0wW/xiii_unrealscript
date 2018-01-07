//=============================================================================
// TriggerLight.
// A lightsource which can be triggered on or off.
//=============================================================================
class TriggerLight extends Light;

//-----------------------------------------------------------------------------
// Variables.

var() float ChangeTime;        // Time light takes to change from on to off.
var() bool  bInitiallyOn;      // Whether it's initially on.
var() bool  bDelayFullOn;      // Delay then go full-on.
var() float RemainOnTime;      // How long the TriggerPound effect lasts
VAR	 bool	ShowIcon;

var   float InitialBrightness; // Initial brightness.
var   float Alpha, Direction;
var   actor SavedTrigger;
var   float poundTime;

//-----------------------------------------------------------------------------
// Engine functions.

// Called at start of gameplay.
simulated function BeginPlay()
{
	// Remember initial light type and set new one.
	ShowIcon=!bHidden;
	if (bHidden)
		SetDrawType(DT_None);

	InitialBrightness = LightBrightness;
	if( bInitiallyOn )
	{
		Alpha     = 1.0;
		Direction = 1.0;
		if (ShowIcon)
			bHidden=False;
	}
	else
	{
		Alpha     = 0.0;
		Direction = -1.0;
		if (ShowIcon)
			bHidden=True;
	}
}

// Called whenever time passes.
FUNCTION Tick( float DeltaTime )
{
//	log("bDelayFullOn "$bDelayFullOn$" LightBrightness "$LightBrightness$" Direction "$Direction$" Alpha "$Alpha);
	if (bDelayFullOn)
	{
		Alpha += Direction * DeltaTime / ChangeTime;
		if( Alpha > 1.0 )
		{
			Alpha = 1.0;
			Disable( 'Tick' );
			if( SavedTrigger != None )
				SavedTrigger.EndEvent();
		}
		else if( Alpha < 0.0 )
		{
			Alpha = 0.0;
			Disable( 'Tick' );
			if( SavedTrigger != None )
				SavedTrigger.EndEvent();
		}
	}
	else
	{
		if( Direction<0 ) //(Direction>0 && Alpha!=1) || Alpha==0 )
		{
			Alpha=0.0;
			LightBrightness = 0;
			if (ShowIcon)
				bHidden=True;
		}
		else
		{
			Alpha=1.0;
			LightBrightness = InitialBrightness;
			if (ShowIcon)
				bHidden=False;
		}
		Disable( 'Tick' );
	}
	LightBrightness = Alpha * InitialBrightness;
}

//-----------------------------------------------------------------------------
// Public states.

// Trigger turns the light on.
state() TriggerTurnsOn
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		Direction = 1.0;
		if (ShowIcon)
			bHidden=False;
		Enable( 'Tick' );
	}
}

// Trigger turns the light off.
state() TriggerTurnsOff
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		Direction = -1.0;
		if (ShowIcon)
			bHidden=True;
		Enable( 'Tick' );
	}
}

// Trigger toggles the light.
state() TriggerToggle
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		Direction *= -1;
		if (ShowIcon)
			bHidden=!bHidden;
		Enable( 'Tick' );
	}
}

// Trigger controls the light.
state() TriggerControl
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		if( bInitiallyOn ) Direction = -1.0;
		else               Direction = 1.0;
		if (ShowIcon)
			bHidden=bInitiallyOn;
		Enable( 'Tick' );
	}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		if( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		if( bInitiallyOn ) Direction = 1.0;
		else               Direction = -1.0;
		if (ShowIcon)
			bHidden=!bInitiallyOn;
		Enable( 'Tick' );
	}
}

state() TriggerPound {

	function Timer () {

		if (poundTime >= RemainOnTime) {

			Disable ('Timer');
		}
		poundTime += ChangeTime;
		Direction *= -1;
		if (ShowIcon)
			bHidden=!bHidden;
		SetTimer (ChangeTime, false);
	}

	function Trigger( actor Other, pawn EventInstigator )
	{

		if( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		SavedTrigger.BeginEvent();
		Direction = 1;
		if (ShowIcon)
			bHidden=False;
		poundTime = ChangeTime;			// how much time will pass till reversal
		SetTimer (ChangeTime, false);		// wake up when it's time to reverse
		Enable   ('Timer');
		Enable   ('Tick');
	}
}


defaultproperties
{
     bStatic=False
     bHidden=False
     bNoDelete=False
     bDynamicLight=True
     bMovable=True
     RemoteRole=ROLE_SimulatedProxy
}
