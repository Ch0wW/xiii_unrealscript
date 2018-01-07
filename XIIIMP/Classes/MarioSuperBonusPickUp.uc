//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MarioSuperBonusPickUp extends Pickup;

var class<Inventory> RandomInventoryType[9];
var localized string RandomPickupMessage[9];
var sound RandomPickupSound[9];
var int PlayerRank;

//______________________________________________________________________________

function GetRank( Actor P)
{
    local int Loop;
    local controller C;
    local HUD D;

    if( XIIIMPPlayerPawn(P) != none )
    {
        C = XIIIMPPlayerPawn(P).Controller;
        D = PlayerController(C).MyHUD;

        if( D != none )
        {
            for( Loop = 0 ; Loop < 32 ; Loop++ )
            {
                if(  XIIIMPScoreBoard(D.Scoring).Ordered[ Loop ] == XIIIMPPlayerPawn(P).PlayerReplicationInfo )
                {
                    PlayerRank = Loop+1;
                    break;
                }
            }
        }
    }
}

//______________________________________________________________________________

function GetRandomItem()
{
    local int RandId;

    RandId=Rand(9)-Rand(PlayerRank);

    if( RandId < 0 )
        RandId = 0;

    InventoryType=RandomInventoryType[RandId];

    default.InventoryType=RandomInventoryType[RandId];
}

//______________________________________________________________________________

auto state Pickup
{
    event Touch( actor Other )
    {
        GetRank( Other );
        GetRandomItem();

        super.Touch( Other );
    }
}

//______________________________________________________________________________

function float BotDesireability( pawn Bot )
{
    return MaxDesireability;
}

//_____________________________________________________________________________



defaultproperties
{
     RandomInventoryType(0)=Class'XIIIMP.Invulnerability'
     RandomInventoryType(1)=Class'XIIIMP.Invisibility'
     RandomInventoryType(2)=Class'XIIIMP.SuperDamage'
     RandomInventoryType(3)=Class'XIIIMP.Regeneration'
     RandomInventoryType(4)=Class'XIIIMP.SuperArmor'
     RandomInventoryType(5)=Class'XIIIMP.Teleport'
     RandomInventoryType(6)=Class'XIIIMP.SuperBoost'
     RandomInventoryType(7)=Class'XIIIMP.LoseArmor'
     RandomInventoryType(8)=Class'XIIIMP.LoseLife'
     MaxDesireability=1.000000
     RespawnTime=20.000000
     PickupMessage="Bonus Item"
     PickupSound=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hCaisse'
     hRespawnSound=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hRespawnGun'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'MeshArmesPickup.MultiBoxBonus'
     DrawScale3D=(X=0.500000,Y=0.500000,Z=0.500000)
     CollisionHeight=32.000000
     MessageClass=Class'XIII.XIIIPickupMessage'
}
