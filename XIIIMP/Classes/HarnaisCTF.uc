//
//-----------------------------------------------------------
class HarnaisCTF extends XIIIMPSpecialMatos;

var int BonusIconId;
var XIIIMPHud MyPlayerHud;
var XIIIMPPlayerPawn MyPlayerLAN;

//__________________________________________________________________________

function AddIconInPlayerHud( Pawn Other )
{
    local int Loop;
    local controller C;

    if( ( XIIIMPPlayerPawn(Other) != none ) && ( BotPlayer(Other) == none ) )
    {
        C = XIIIMPPlayerPawn(Other).Controller;
        MyPlayerHud = XIIIMPHud(PlayerController(C).MyHUD);

        if( MyPlayerHud != none )
        {
            MyPlayerHud.MarioBonus += BonusIconId;
        }

        if ( Level.NetMode != NM_Standalone )
        {
            MyPlayerLAN = XIIIMPPlayerPawn(Other);
            MyPlayerLAN.MarioBonusLAN += BonusIconId;
        }
    }
}

//__________________________________________________________________________

function RemoveIconInPlayerHud()
{
    if( MyPlayerHud != none )
    {
        MyPlayerHud.MarioBonus -= BonusIconId;
    }

    if ( Level.NetMode != NM_Standalone )
    {
        MyPlayerLAN.MarioBonusLAN -= BonusIconId;
    }
}

//__________________________________________________________________________

event Destroyed()
{
    RemoveIconInPlayerHud();
    super.Destroyed();
}

//__________________________________________________________________________

function GiveTo( pawn Other )
{
    Super.GiveTo(other);
    AddIconInPlayerHud( Other );
}

//__________________________________________________________________________



defaultproperties
{
     BonusIconId=512
     BoneToAttach="X Spine1"
     PickupClassName="XIII.GiletMk1Pick"
     ThirdPersonRelativeLocation=(X=5.000000,Y=27.000000)
     ThirdPersonRelativeRotation=(Pitch=4000,Yaw=-16384)
     AttachmentClass=Class'XIIIMP.HarnaisCTFAttachment'
     ItemName="Harnais"
}
