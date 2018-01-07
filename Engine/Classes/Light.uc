//=============================================================================
// The light class.
//=============================================================================
class Light extends Actor
	placeable
	native;

#exec Texture Import File=Textures\S_Light.pcx  Name=S_Light Mips=Off MASKED=1 COMPRESS=DXT1

defaultproperties
{
     bStatic=True
     bHidden=True
     bNoDelete=True
     bInteractive=False
     bMovable=False
     Texture=Texture'Engine.S_Light'
     CollisionRadius=24.000000
     CollisionHeight=24.000000
     LightType=LT_Steady
     LightBrightness=150
     LightSaturation=255
     LightRadius=64
     LightPeriod=32
     LightCone=128
}
