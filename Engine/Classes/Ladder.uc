/*=============================================================================
// Ladders are associated with the LadderVolume that encompasses them, and provide AI navigation
// support for ladder volumes.  Direction should be the direction that climbing pawns
// should face
============================================================================= */

class Ladder extends NavigationPoint
	placeable
	native;

#exec Texture Import File=Textures\Ladder.pcx Name=S_Ladder Mips=Off MASKED=1 COMPRESS=DXT1

var LadderVolume MyLadder;
var Ladder LadderList;

defaultproperties
{
     bNotBased=True
     //Texture=Texture'Engine.S_Ladder'
     CollisionRadius=35.000000
     CollisionHeight=80.000000
     bDirectional=True
}
