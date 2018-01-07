//-----------------------------------------------------------
//
//-----------------------------------------------------------
class PRock03MagneticCardPick extends EventItemPick;



defaultproperties
{
     FpsMeshToUse=SkeletalMesh'XIIIDeco.fpspasseM'
     InvSelectItemSound=Sound'XIIIsound.Items.PassSel1'
     InvActivateSound=Sound'XIIIsound.Items.PassFire1'
     InventoryType=Class'XIDMaps.PRock03MagneticCard'
     PickupMessage="Magnetic Card"
     PickupSound=Sound'XIIIsound.Items.PassPick1'
     Tag="EventItemPick"
     Event="Pass2"
     StaticMesh=StaticMesh'MeshObjetsPickup.magnetic_card'
}
