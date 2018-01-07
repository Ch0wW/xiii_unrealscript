//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MarioSmallWeaponPickUp extends MarioPickUp;

var() bool	  bWeaponStay;

//_____________________________________________________________________________

function InitItemList()
{
    local MarioMutator MM;
    local int Loop;

    foreach DynamicActors(class'MarioMutator', MM)
    {
        ItemNumber = MM.SmallWeaponNumber;

        for( Loop=0;Loop<ItemNumber;Loop++)
        {
            RandomInventoryType[Loop]=MM.SmallWeaponInventoryType[Loop];
            RandomPickupMessage[Loop]=MM.SmallWeaponPickupMessage[Loop];
            RandomPickupSound[Loop]=MM.SmallWeaponPickupSound[Loop];
        }

        break;
    }

    InitList=true;
}

//_____________________________________________________________________________

event ParseDynamicLoading(LevelInfo MyLI)
{
    class<Weapon>(default.InventoryType).Static.StaticParseDynamicLoading(MyLI);
}

//_____________________________________________________________________________

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetWeaponStay();
}

//_____________________________________________________________________________

function SetWeaponStay()
{
	bWeaponStay = bWeaponStay || Level.Game.bCoopWeaponMode;
}

//_____________________________________________________________________________

function float BotDesireability(Pawn Bot)
{
    return MaxDesireability;
}

//_____________________________________________________________________________



defaultproperties
{
     MaxDesireability=4.000000
     RespawnTime=8.000000
     PickupMessage="Small Offensive Item"
     StaticMesh=StaticMesh'MeshArmesPickup.MultiBoxSmallarmes'
     DrawScale3D=(X=0.500000,Y=0.500000,Z=0.500000)
}
