//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Banque01BombePick extends EventItemPick;



defaultproperties
{
     FpsMeshToUse=SkeletalMesh'XIIIArmes.fpsbombemagnetM'
     InvSelectItemSound=Sound'XIIIsound.Items.PassSel1'
     InvActivateSound=Sound'XIIIsound.Items.PassFire1'
     bCauseEventOnPick=True
     InventoryType=Class'XIDMaps.Banque01Bombe'
     PickupMessage="Bomb"
     PickupSound=Sound'XIIIsound.Items.PassPick1'
     Tag="EventItemPick"
     Event="BombPicked"
     StaticMesh=StaticMesh'MeshArmesPickup.bombemagnet'
}
