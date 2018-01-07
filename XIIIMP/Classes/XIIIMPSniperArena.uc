//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPSniperArena extends XIIIMPMutator;

var string DefaultAmmoPickupName; // to replace ammo picks by default one
var class<Actor> DefaultAmmoPickupClass;

//_____________________________________________________________________________
event PreBeginPlay()
{
    DefaultAmmoPickupClass = Class<Actor>(DynamicLoadObject(DefaultAmmoPickupName, class'class'));
}

//_____________________________________________________________________________
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if ( DBMutator ) Log("MUTATOR CheckReplacement for"@Other);

    // replace all weapons by ammo
    if ( XIIIWeaponPickup(Other) != none )
      ReplaceWith(Other, DefaultAmmoPickupName);
    // delete all ammo except for the weapon.
    if ( (XIIIAmmoPick(Other) != none) && (Other.Class != DefaultAmmoPickupClass) )
      Other.Destroy();

    return true;
}



defaultproperties
{
     defaultAmmoPickupName="XIII.Bmg50AmmoClip"
     DefaultWeaponName="XIII.FusilSnipe"
}
