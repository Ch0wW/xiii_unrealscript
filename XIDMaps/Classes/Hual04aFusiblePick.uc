//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Hual04aFusiblePick extends EventItemPick;



defaultproperties
{
     FpsMeshToUse=SkeletalMesh'XIIIDeco.fpsTLfusibleM'
     InvSelectItemSound=Sound'XIIIsound.Items.PassSel1'
     InvActivateSound=Sound'XIIIsound.Items.PassFire1'
     bCauseEventOnPick=True
     InventoryType=Class'XIDMaps.Hual04aFusible'
     PickupMessage="Fuse"
     PickupSound=Sound'XIIIsound.Items.PassPick1'
     Tag="EventItemPick"
     Event="FusibleRamasse"
     StaticMesh=StaticMesh'MeshObjetsPickup.TLfusible'
}
