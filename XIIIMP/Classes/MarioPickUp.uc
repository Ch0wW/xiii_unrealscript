//-----------------------------------------------------------
class MarioPickUp extends Pickup;

var class<Inventory> RandomInventoryType[7];
var localized string RandomPickupMessage[7];
var sound RandomPickupSound[7];
var int ItemNumber;
var bool InitList;
var float ScaleValue;

//______________________________________________________________________________

function GetRandomItem()
{
    local int RandId;

    RandId=Rand(ItemNumber);

    InventoryType=RandomInventoryType[RandId];

    default.InventoryType=RandomInventoryType[RandId];
}

//______________________________________________________________________________

function InitItemList()
{
}

//______________________________________________________________________________

auto state Pickup
{
    event Touch( actor Other )
    {
        if( ! InitList )
            InitItemList();

        GetRandomItem();

        super.Touch( Other );
    }
}

//______________________________________________________________________________
//    texture=texture'XIIIMenu.UziIcon'


defaultproperties
{
     PickupMessage="Mario"
     PickupSound=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hCaisse'
     hRespawnSound=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hRespawnGun'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'MeshArmesPickup.uzi'
     CollisionHeight=28.000000
     MessageClass=Class'XIII.XIIIPickupMessage'
}
