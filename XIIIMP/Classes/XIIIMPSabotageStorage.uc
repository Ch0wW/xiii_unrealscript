//
//-----------------------------------------------------------
class XIIIMPSabotageStorage extends XIIIMPBotStorageParams;

var int CurrentDefendSpot[ 2 ];
var int CurrentAttackSpot[ 2 ];
var bool ForceDefenseTeamRole;
var bool ForceAttackTeamRole;
var int PossibilityChoice;
var GroupPathNode MyGPN;
var array<int> Possibility;
var array<float> Temporisation;
var XIIIMPBombPick TheBombPick;



defaultproperties
{
     CurrentDefendSpot(0)=-1
     CurrentDefendSpot(1)=-1
     CurrentAttackSpot(0)=-1
     CurrentAttackSpot(1)=-1
}
