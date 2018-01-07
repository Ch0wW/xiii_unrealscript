//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MarioHeavyWeaponPickUp extends MarioPickUp;

var() bool	  bWeaponStay;

//_____________________________________________________________________________

function InitItemList()
{
    local MarioMutator MM;
    local int Loop;

    foreach DynamicActors(class'MarioMutator', MM)
    {
        ItemNumber = MM.HeavyWeaponNumber;

        for( Loop=0;Loop<ItemNumber;Loop++)
        {
            RandomInventoryType[Loop]=MM.HeavyWeaponInventoryType[Loop];
            RandomPickupMessage[Loop]=MM.HeavyWeaponPickupMessage[Loop];
            RandomPickupSound[Loop]=MM.HeavyWeaponPickupSound[Loop];
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
     MaxDesireability=1.000000
     RespawnTime=15.000000
     PickupMessage="Heavy Offensive Item"
     StaticMesh=StaticMesh'MeshArmesPickup.MultiBoxBigarmes'
     DrawScale3D=(X=0.500000,Y=0.500000,Z=0.500000)
}
