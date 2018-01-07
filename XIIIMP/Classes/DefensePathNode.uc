//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DefensePathNode extends PathNode;

var() byte BotLevel;
var() int DefensePointID;
var() bool MustBeCrouched ;
var() bool DoNotCrouch ;
var() bool SnipeSpot;
var bool Closed;



defaultproperties
{
     bDirectional=True
}
