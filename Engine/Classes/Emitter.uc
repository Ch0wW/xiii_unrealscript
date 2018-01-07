//=============================================================================
// Emitter: An Unreal Emitter Actor.
//=============================================================================
class Emitter extends Actor
	native
	placeable;

#exec Texture Import File=Textures\S_Emitter.pcx  Name=S_Emitter Mips=Off MASKED=1 COMPRESS=DXT1


var ()	export	editinline	array<ParticleEmitter>	Emitters;

var		(Global)	bool			AutoDestroy;
var		(Global)	bool			AutoReset;
var		(Global)	bool			DisableFogging;
var		(Global)	rangevector		GlobalOffsetRange;
var		(Global)	range			TimeTillResetRange;

var		transient	float			EmitterRadius;
var		transient	float			EmitterHeight;
var		transient	bool			ActorForcesEnabled;
var		transient	vector			GlobalOffset;
var		transient	float			TimeTillReset;

defaultproperties
{
     AutoDestroy=True
     bInteractive=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     DrawType=DT_Particle
     Texture=Texture'Engine.S_Emitter'
     Style=STY_Particle
}
