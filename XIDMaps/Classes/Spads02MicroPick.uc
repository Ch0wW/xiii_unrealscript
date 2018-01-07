//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Spads02MicroPick extends EventItemPick;



defaultproperties
{
     FpsMeshToUse=SkeletalMesh'XIIIArmes.fpsmicrospyM'
     InvSelectItemSound=Sound'XIIIsound.Items.PassSel1'
     InvActivateSound=Sound'XIIIsound.Items.PassFire1'
     bCauseEventOnPick=True
     InventoryType=Class'XIDMaps.Spads02Micro'
     PickupMessage="Spying Micro"
     PickupSound=Sound'XIIIsound.Items.PassPick1'
     Tag="EventItemPick"
     Event="MicroPicked"
     StaticMesh=StaticMesh'MeshArmesPickup.microspy'
}
