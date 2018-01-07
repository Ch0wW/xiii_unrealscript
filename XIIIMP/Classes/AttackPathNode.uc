//-----------------------------------------------------------
//
//-----------------------------------------------------------
class AttackPathNode extends PathNode;

var() int Group;
var() bool MustBeCrouched;
var() bool DoNotCrouch ;
var bool Closed;



defaultproperties
{
     bDirectional=True
}
