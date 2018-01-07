//=============================================================================
// Keypoint, the base class of invisible actors which mark things.
//=============================================================================
class Keypoint extends Actor
	abstract
	placeable
	native;

// Sprite.
#exec Texture Import File=Textures\Keypoint.pcx Name=S_Keypoint Mips=Off Flags=2 COMPRESS=DXT1

defaultproperties
{
     bStatic=True
     bHidden=True
     bInteractive=False
     //Texture=Texture'Engine.S_Keypoint'
     CollisionRadius=10.000000
     CollisionHeight=10.000000
}
