//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GrenadPathNode extends PathNode;

var() BotGrenadTarget Target;
var() NavigationPoint HidePoint;
var() byte Team;
var float LastUsedTime;



defaultproperties
{
     LastUsedTime=-1.000000
     bCollideActors=True
}
