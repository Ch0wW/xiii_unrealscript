//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPGameRules extends GameRules;

//_____________________________________________________________________________
// ELR Return True to cancel the GameRestart and force the player to go into the menu to Reload
function bool HandleRestartGame()
{
    return true;
}

//_____________________________________________________________________________
/* OverridePickupQuery()
when pawn wants to pickup something, gamerules given a chance to modify it.  If this function
returns true, bAllowPickup will determine if the object can be picked up.
*/
function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup)
{
//    log("CALL to OverridePickupQuery for "$other$" picking "$item);

    /*if (MultiplayerMedPickup(Item) != none)
    {
      if ( XIIIPawn(Other).IsWounded() )
        bAllowPickup=1.0;
      return true;
    }   */

    if ( (NextGameRules != None) &&  NextGameRules.OverridePickupQuery(Other, item, bAllowPickup) )
      return true;
    return false;
}



defaultproperties
{
}
