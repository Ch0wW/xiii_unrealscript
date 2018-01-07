//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MPBombAmmo extends XIIIProjectilesAmmo;

var sound sndBombIsDropped;

//_____________________________________________________________________________
function RemoveHarnaisBomb(XIIIPawn P)
{
    local Inventory NewItem;

    NewItem = P.FindInventoryType(Class'XIIIMP.HarnaisBomb');
    if( NewItem != none )
      NewItem.Destroy();

    NewItem = P.FindInventoryType(Class'XIIIMP.HarnaisBombAttachment');
    if( NewItem !=None )
      NewItem.Destroy();
}

//_____________________________________________________________________________
function SpawnProjectile(vector Start, rotator Dir)
{
    local XIIIProjectile XP;

    if (AmmoAmount > 0)
      AmmoAmount -= 1;  // Fire
    else
      return;  // Empty Shot
    XP = XIIIProjectile(Spawn(ProjectileClass,owner,,Start,Dir));
    //owner.PlayMenu(sndBombIsDropped);

    RemoveHarnaisBomb( XIIIPawn(owner) );

    if ( XP != none )
    {
      XP.SetImpactNoise(SoftImpactNoise, ImpactNoise);
//      if ( Pawn(Owner).IsPlayerPawn() )
//        GrenadFlying(XP).fLifeTime = GrenadB(Pawn(Owner).Weapon).ProjectileLifeTime - Level.TimeSeconds;
    }
}



defaultproperties
{
     sndBombIsDropped=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hBombArmored'
     fThrowDelay=1.150000
     MaxAmmo=15
     AmmoAmount=1
     ProjectileClass=Class'XIIIMP.MPBombFlying'
     ImpactNoise=5.000000
     SoftImpactNoise=5.000000
     PickupClassName="XIIIMP.XIIIMPBombPick"
     ItemName="Bomb"
}
