//-----------------------------------------------------------
//
//-----------------------------------------------------------
class USA02HelicoBoss extends Pawn;

var float MemTime; // to avoid 2 takedamages from same rocket
var USA02HelicoRotorAbove RotorA;
var USA02HelicoRotorBack RotorR;
var USA02HelicoHSEmitter Emit;

var sound hBeginFightSound;
var sound hCrashSound;
var sound hVictorySound;

//_____________________________________________________________________________
event PostBeginPlay()
{
    Super.PostBeginPlay();
	PlaySound(hBeginFightSound);
    RotorA = Spawn(class'USA02HelicoRotorAbove', self);
    if ( RotorA != none )
    {
      RotorA.SetBase(self);
      RotorA.SetRelativeLocation(vect(155,0,20)*DrawScale);
      RotorA.SetRelativeRotation(rot(0,0,0));
      RotorA.SetDrawScale(DrawScale);
    }
    RotorR = Spawn(class'USA02HelicoRotorBack', self);
    if ( RotorR != none )
    {
      RotorR.SetBase(self);
      RotorR.SetRelativeLocation(vect(-720,-25,95)*DrawScale);
      RotorR.SetRelativeRotation(rot(0,0,0));
      RotorR.SetDrawScale(DrawScale);
    }
}

//_____________________________________________________________________________
event Destroyed()
{
    RotorA.Destroy();
    RotorR.Destroy();
    Emit.Destroy();
}

//_____________________________________________________________________________
function Notify()
{
	//gestion du son en crash
	PlaySound(hCrashSound);
}

//_____________________________________________________________________________
// Special Boss damages, need 3 rockets to blow up.
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    if ( (DamageType != class'DTRocketed') || (Level.TimeSeconds <= MemTime+0.3) || (Damage<200) )
      return;
	USA02HelicoBossController(Controller).NotifyTakeDamage();
    MemTime = Level.TimeSeconds;
    Health -= 1;
    DebugLog("\ HelicoBoss -- LOSING ONE LIFE, Damages="$Damage);
    if ( Health <= 0 )
    {
      PlaySound(hVictorySound);
	  Controller.GotoState('EndOfMe');
      Emit = Spawn(class'USA02HelicoHSEmitter', none);
      Emit.SetBase(self);
      Emit.SetRelativeLocation(vect(155,0,20)*DrawScale);
      Emit.SetRelativeRotation(rot(0,0,0));
	  XIIIBaseHud(XIIIGameInfo(Level.Game).MapInfo.XIIIController.MyHud).AddBossBar( none );

    }
}

/*
//_____________________________________________________________________________
auto state Initialize
{
}
*/

//    hFlightSound=Sound'XIIIsound.Vehicles__USABossHelico.USABossHelico__hBeginFight'


defaultproperties
{
     hBeginFightSound=Sound'XIIIsound.Vehicles__USABossHelico.USABossHelico__hBeginFight'
     hCrashSound=Sound'XIIIsound.Vehicles__USABossHelico.USABossHelico__hCrash'
     hVictorySound=Sound'XIIIsound.Vehicles__USABossHelico.USABossHelico__hVictory'
     bCanStrafe=True
     bBoss=True
     PawnName="Chopper"
     Health=3
     bProjTarget=False
     Physics=PHYS_Flying
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Meshes_Vehicules.apacheBoss'
     DrawScale=1.200000
     StabilisationDistance=15000.000000
     StabilisationVolume=-25.000000
}
