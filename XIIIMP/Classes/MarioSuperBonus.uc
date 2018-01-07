//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MarioSuperBonus extends Inventory;

var int BonusIconId;
var XIIIMPHud MyPlayerHud;
var XIIIMPPlayerPawn MyPlayerLAN;

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

function RemoveIconInPlayerHud()
{
    if( MyPlayerHud != none )
    {
        MyPlayerHud.MarioBonus -= BonusIconId;
    }

    if( MyPlayerLAN != none )
    {
        MyPlayerLAN.MarioBonusLAN -= BonusIconId;
    }
}



defaultproperties
{
}
