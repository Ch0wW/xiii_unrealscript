//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FlashBangAmmo extends XIIIProjectilesAmmo;

//_____________________________________________________________________________
function SpawnProjectile(vector Start, rotator Dir)
{
    local XIIIProjectile XP;

    if (AmmoAmount > 0)
      AmmoAmount -= 1;  // Fire
    else
      return;  // Empty Shot
    XP = XIIIProjectile(Spawn(ProjectileClass,owner,,Start,Dir));

    if ( XP != none )
    {
      XP.SetImpactNoise(SoftImpactNoise, ImpactNoise);
      if ( Pawn(Owner).IsPlayerPawn() )
        FlashBangFlying(XP).fLifeTime = FlashBang(Pawn(Owner).Weapon).ProjectileLifeTime - Level.TimeSeconds;
    }
}



defaultproperties
{
     fThrowDelay=0.090000
     MaxAmmo=15
     AmmoAmount=1
     ProjectileClass=Class'XIIIMP.FlashBangFlying'
     ImpactNoise=5.000000
     SoftImpactNoise=5.000000
     PickupClassName="XIIIMP.FlashBangPick"
     ItemName="FlashBang"
}
