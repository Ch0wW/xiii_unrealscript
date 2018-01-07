//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Hual02MagneticCardPick extends EventItemPick;

//    Mesh=VertMesh'XIIIDeco.magnetic_cardM'


defaultproperties
{
     FpsMeshToUse=SkeletalMesh'XIIIDeco.fpspasseM'
     InvSelectItemSound=Sound'XIIIsound.Items.PassSel1'
     InvActivateSound=Sound'XIIIsound.Items.PassFire1'
     InventoryType=Class'XIDMaps.Hual02MagneticCard'
     PickupMessage="Magnetic Card"
     PickupSound=Sound'XIIIsound.Items.PassPick1'
     Tag="EventItemPick"
     Event="portedecl"
     StaticMesh=StaticMesh'MeshObjetsPickup.magnetic_card'
}
