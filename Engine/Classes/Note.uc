//=============================================================================
// A sticky note.  Level designers can place these in the level and then
// view them as a batch in the error/warnings window.
//=============================================================================
class Note extends Actor
	placeable
	native;

#exec Texture Import File=Textures\Note.pcx  Name=S_Note Mips=Off MASKED=1 COMPRESS=DXT1

var() string Text;

defaultproperties
{
     bStatic=True
     bHidden=True
     bNoDelete=True
     bMovable=False
     Texture=Texture'Engine.S_Note'
}
