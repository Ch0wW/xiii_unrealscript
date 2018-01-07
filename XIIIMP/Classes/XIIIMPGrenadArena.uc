//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPGrenadArena extends XIIIMPSniperArena;

//_____________________________________________________________________________
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if ( DBMutator ) Log("MUTATOR CheckReplacement for"@Other);

    if( ( XIIIWeaponPickup(Other) != none ) && (Other.Class != DefaultAmmoPickupClass) )
      ReplaceWith(Other, DefaultAmmoPickupName);
    else if( (XIIIAmmoPick(Other) != none) )
      ReplaceWith(Other, DefaultAmmoPickupName);

    return true;
}



defaultproperties
{
     defaultAmmoPickupName="XIII.GrenadPick"
     DefaultWeaponName="XIIIMP.BerettaMulti"
}
