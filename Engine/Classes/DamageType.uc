//=============================================================================
// DamageType, the base class of all damagetypes.
// this and its subclasses are never spawned, just used as information holders
//=============================================================================
class DamageType extends Actor
    config
    native
    abstract;

// Description of a type of damage.
var() localized string DeathString;         // string to describe death by this type of damage
var() localized string FemaleSuicide, MaleSuicide;
//var() float ViewFlash;                    // View flash to play.
//var() vector ViewFog;                     // View fog to play.
//var() class<effects> DamageEffect;        // Special effect.
var() string DamageWeaponName;              // weapon that caused this damage

var() bool bArmorStops;                     // does regular armor provide protection against this damage
var() bool bSpawnDeathOnomatop;               // do this damage type involves spawning an onomatop ?
var() bool bDieInSilencePlease;               // HAHA have we the only game where a silenced weapon have silent impacts ?? ;;))
var() bool bSpawnBloodFX;                     // do this damage type involves spawning blood sfx
var() bool bGlobalDamages;                    // to use all armor / damage all location
var() bool bAllowHeadShotSFXTrigger;
var() bool bBloodSplash;                      // Make blood splashes on walls
var() bool bCanKillStunnedCorspes;          // this type a damages kill stunned people (thus gameover if must not be killed when shot as corpses lying).

//var() bool bInstantHit;                   // done by trace hit weapon
//var() bool bFastInstantHit;               // done by fast repeating trace hit weapon
var() float GibModifier;
var() int SoundType;
  /* Sound Type :
        case class'DTH2HBlade' :
        case class'DTBite' :
        case class'DTBladeCut' : PlaySound(hHitSound, 1, Damage, int(bIsDead) ); break;
        case class'DTDrowned' : PlaySound(hHitSound, 2, Damage, int(bIsDead) ); break;
        case class'DTGrenaded' :
        case class'DTRocketed' : PlaySound(hHitSound, 3, Damage, int(bIsDead) ); break;
        case class'DTSniped' :
        case class'DTGunnedSilenced' :
        case class'DTGunned' : PlaySound(hHitSound, 4, Damage, int(bIsDead) ); break;
        case class'DTPierced' : PlaySound(hHitSound, 6, Damage, int(bIsDead) ); break;
        case class'DTShotGunned' : PlaySound(hHitSound, 7, Damage, int(bIsDead) ); break;
        case class'DTCouDCross':
        case class'DTFisted' : PlaySound(hHitSound, 8, Damage, int(bIsDead) ); break;
        case class'DTHeadShot' : PlaySound(hHitSound, 10, Damage, int(bIsDead) ); break;
        case class'DTElectroChoc' : PlaySound(hHitSound, 11, Damage, int(bIsDead) ); break;
        case class'DTFell' : PlaySound(hHitSound, 12, Damage, int(bIsDead) ); break;
  */

// these effects should be none if should use the pawn's blood effects
/*
var() class<Effects>		PawnDamageEffect;	// effect to spawn when pawns are damaged by this damagetype
var() class<Effects>		LowGoreDamageEffect; // effect to spawn when low gore
var() class<Effects>		LowDetailEffect;
*/

//var() float	FlashScale;		//for flashing victim's screen
//var() vectorFlashFog;

var config class<Emitter> HeadBloodTrailEmitterClass;
var config class<ImpactEmitter> BloodShotEmitterClass;

//_____________________________________________________________________________
static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
    return Default.DeathString;
}

//_____________________________________________________________________________
static function string SuicideMessage(PlayerReplicationInfo Victim)
{
    if ( Victim.bIsFemale )
      return Default.FemaleSuicide;
    else
      return Default.MaleSuicide;
}

/*
static function class<Effects> GetPawnDamageEffect( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	if ( class'GameInfo'.Default.GoreLevel > 0 )
	{
		if ( Default.LowGoreDamageEffect != None )
			return Default.LowGoreDamageEffect;
		else
			return Victim.LowGoreBlood;
	}
	else if ( bLowDetail )
	{

		if ( Default.LowDetailEffect != None )
			return Default.LowDetailEffect;
		else
			return Victim.LowDetailBlood;
	}
	else
	{
		if ( Default.PawnDamageEffect != None )
			return Default.PawnDamageEffect;
		else
			return Victim.BloodEffect;
	}
}
*/

//	 bArmorStops=true
//	 FlashScale=-0.019
//	 FlashFog=(X=26.500000,Y=4.500000,Z=4.500000)

defaultproperties
{
     DeathString="%o was killed by %k."
     FemaleSuicide="%o killed herself."
     MaleSuicide="%o killed himself."
     GibModifier=1.000000
     bInteractive=False
}
