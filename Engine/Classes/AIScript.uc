//=============================================================================
// AIScript - used by Level Designers to specify special AI scripts for pawns 
// placed in a level, and to change which type of AI controller to use for a pawn.
// AIScripts can be shared by one or many pawns. 
// Game specific subclasses of AIScript will have editable properties defining game specific behavior and AI
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class AIScript extends Keypoint 
	native
	placeable;

var() class<AIController> ControllerClass;
var()	float	SkillModifier;		// skill modifier (same scale as game difficulty)	
var() name NextScriptTag;	// Tag of next ScriptedSequence
var AIScript NextScript;


/* SpawnController()
Spawn and initialize an AI Controller (called by a non-player controlled Pawn at level startup)
*/
function SpawnControllerFor(Pawn P)
{
	local AIController C;

	if ( ControllerClass == None )
	{
		if ( P.ControllerClass == None )
			return;
		C = Spawn(P.ControllerClass);
	}
	else
		C = Spawn(ControllerClass);
	C.MyScript = self;
	C.Skill += SkillModifier;
	C.Possess(P);
}

defaultproperties
{
}
