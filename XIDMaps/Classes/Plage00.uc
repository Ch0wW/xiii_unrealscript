//=============================================================================
// Plage00.
//=============================================================================
class Plage00 extends Map01_Plage
     placeable;

var(PlageSetup) float XIIISpeedFactorLimitBeforeHeal; // To limit XIII Speed at the beginning
var(PlageSetup) bool InjuredEffectInitiallyOn;
var bool InjuredEffectOn;
var(PlageSetup) float InjuredEffectTransitionDelay;

EVENT PostBeginPlay()
{
	local mutator m;

	Super.PostBeginPlay();

	// prise en compte d un mutator qui retire les poings au joueur
	m = Spawn( class'PRock01aMutator' );
	m.NextMutator = Level.Game.BaseMutator.NextMutator;
	Level.Game.BaseMutator = m; //.AddMutator(m);
}

//FUNCTION bool SaveInventoryForFlash(XIIIPawn P){ return true; }

//FUNCTION bool RestoreInventoryAfterFlash(XIIIPawn P){ return true; }

//_____________________________________________________________________________
FUNCTION FirstFrame()
{
    Super.FirstFrame();

    // Trigger clouds
    TriggerEvent('PL_nuages', Self, none);

    // ::TODO:: SHOULD NOT BE DONE WHEN LOADING AT A CHECKPOINT
    if ( Caps(XIIIGameInfo(Level.Game).StartSpotEvent) != "LOAD" )
    {
      // Change MainCharacter HitPoints
      XIIIPawn.Health = XIIIPawn.Default.Health*0.50;

      // Change Main character Speed
      XIIIPawn.SpeedFactorLimit = XIIISpeedFactorLimitBeforeHeal;
      XIIIPawn.SetGroundSpeed(1.0);
    }

    XIIIPawn.SoundStepCategory=1;
	
	InjuredEffectOn = InjuredEffectInitiallyOn;
	Level.SetInjuredEffect( InjuredEffectOn, InjuredEffectTransitionDelay );
}

event Trigger(actor a,pawn p)
{
	InjuredEffectOn = ! InjuredEffectOn;
	Level.SetInjuredEffect( InjuredEffectOn, InjuredEffectTransitionDelay );

}
//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    Switch ( N )
    {
      Case 91:
        SetPrimaryGoal(0);
        Break;
      Case 92:
        SetPrimaryGoal(1);
        Break;
      Case 93:
        SetPrimaryGoal(2);
        Super.SetGoalComplete(2);
        Break;
    }
    Super.SetGoalComplete(N);
}

//_____________________________________________________________________________



defaultproperties
{
     InjuredEffectInitiallyOn=True
     InjuredEffectTransitionDelay=1.000000
}
