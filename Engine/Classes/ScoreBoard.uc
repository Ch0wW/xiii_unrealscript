//=============================================================================
// ScoreBoard
//=============================================================================
class ScoreBoard extends Info;

var font RegFont;
var HUD OwnerHUD;
var PlayerReplicationInfo Ordered[32];

function ShowScores( canvas Canvas, int ViewPortId , int PlayerNumber );
function PreBeginPlay();
simulated function UpdateScores();

defaultproperties
{
}
