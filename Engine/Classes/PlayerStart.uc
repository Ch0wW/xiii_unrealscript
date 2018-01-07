//=============================================================================
// Player start location.
//=============================================================================
class PlayerStart extends NavigationPoint 
	placeable
	native;

#exec Texture Import File=Textures\S_Player.pcx Name=S_Player Mips=Off MASKED=1 COMPRESS=DXT1

// Players on different teams are not spawned in areas with the
// same TeamNumber unless there are more teams in the level than
// team numbers.
var() byte TeamNumber;			// what team can spawn at this start
var() bool bSinglePlayerStart;	// use first start encountered with this true for single player
var() bool bCoopStart;			// start can be used in coop games	
var() bool bEnabled;

defaultproperties
{
     bSinglePlayerStart=True
     bCoopStart=True
     bEnabled=True
     Texture=Texture'Engine.S_Player'
     CollisionRadius=40.000000
     CollisionHeight=80.000000
     bDirectional=True
}
