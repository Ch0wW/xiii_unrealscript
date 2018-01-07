//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GuardPathNode extends PathNode;

var() byte Team;
var() byte BotLevel;
var bool Closed;
var() bool CanBeUsedByTheAttackTeam;



defaultproperties
{
     bDirectional=True
}
