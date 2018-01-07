//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HarnaisBomb extends XIIIMPSpecialMatos;

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
            MyPlayerHud.MarioBonus = 1024;
        }

        if ( Level.NetMode != NM_Standalone )
        {
            MyPlayerLAN = XIIIMPPlayerPawn(Other);
            MyPlayerLAN.MarioBonusLAN = 1024;
        }
    }
}

//__________________________________________________________________________

function RemoveIconInPlayerHud()
{
    if( MyPlayerHud != none )
    {
        MyPlayerHud.MarioBonus = 0;
    }

    if ( Level.NetMode != NM_Standalone )
    {
        log("Remove from"@MyPlayerLAN);
        MyPlayerLAN.MarioBonusLAN = 0;
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
     BonusIconId=1024
     BoneToAttach="X Spine1"
     PickupClassName="XIII.GiletMk1Pick"
     ThirdPersonRelativeLocation=(X=5.000000,Y=27.000000)
     ThirdPersonRelativeRotation=(Pitch=4000,Yaw=-16384)
     AttachmentClass=Class'XIIIMP.HarnaisBombAttachment'
     ItemName="Harnais Bomb"
}
