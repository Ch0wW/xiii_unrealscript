//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Sanc02aMagneticCardPick extends EventItemPick;

// for this class overide the validtouch to be able to give it to any basesoldier
//_____________________________________________________________________________
// ELR Let's override the TriggerEvent.
auto state Pickup
{
    function bool ValidTouch( actor Other )
    {
      // make sure its a live player
      if ( (Pawn(Other)==none) || (Pawn(Other).Health <= 0) )
        return false;
      // make sure not touching through wall only for other than player
      if ( Pawn(Other).IsPlayerPawn() && !FastTrace(Other.Location+Pawn(Other).EyeHeight*vect(0,0,1), Location) )
        return false;
      // ELR Get rid of the line below for XIII Items !
      if ( bCauseEventOnPick )
        TriggerEvent(Event, self, Pawn(Other));
      return true;
    }

    // When touched by an actor.
    function Touch( actor Other )
    {
      local Inventory Copy;

      // If touched by a player pawn, let him pick this up.
      if( ValidTouch(Other) )
      {
        Copy = SpawnCopy(Pawn(Other));
        AnnouncePickup(Pawn(Other));
        Copy.PickupFunction(Pawn(Other));
      }
      // don't allow inventory to pile up (frame rate hit)
      else if ( (Inventory != None) && (Pickup(Other) != none)
        && (Pickup(Other).Inventory != None) )
        Destroy();
    }
}



defaultproperties
{
     FpsMeshToUse=SkeletalMesh'XIIIDeco.fpspasseM'
     InvSelectItemSound=Sound'XIIIsound.Items.PassSel1'
     InvActivateSound=Sound'XIIIsound.Items.PassFire1'
     InventoryType=Class'XIDMaps.Sanc02aMagneticCard'
     PickupMessage="Magnetic Card"
     PickupSound=Sound'XIIIsound.Items.PassPick1'
     Tag="EventItemPick"
     Event="opensanc02a"
     StaticMesh=StaticMesh'MeshObjetsPickup.magnetic_card'
}
