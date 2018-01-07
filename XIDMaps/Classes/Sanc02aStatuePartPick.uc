//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Sanc02aStatuePartPick extends EventItemPick;

//    InvActivateSound=Sound'XIIIsound.Items.PassFire1'


defaultproperties
{
     FpsMeshToUse=SkeletalMesh'XIIIDeco.fpsSA2laclefM'
     InvSelectItemSound=Sound'XIIIsound.Items.PassSel1'
     bCauseEventOnPick=True
     InventoryType=Class'XIDMaps.Sanc02aStatuePart'
     PickupMessage="Part of a Statue"
     PickupSound=Sound'XIIIsound.Items.PassPick1'
     Tag="EventItemPick"
     Event="StatuePartPicked"
     StaticMesh=StaticMesh'MeshObjetsPickup.SA2laclef'
}
