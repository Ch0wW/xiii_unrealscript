//=============================================================================
// Emitter: An Unreal Sprite Particle Emitter.
//=============================================================================
class SpriteEmitter extends ParticleEmitter
	native;


enum EParticleDirectionUsage
{
	PTDU_View,
	PTDU_MoveAndViewUp,
	PTDU_MoveAndViewRight,
	PTDU_MoveAndViewForward,
	PTDU_Normal,
	PTDU_ViewAndNormalUp,
	PTDU_ViewAndNormalRight,
	PTDU_MoveAndNormalUp,
	PTDU_MoveAndNormalRight
};


var (Sprite)		EParticleDirectionUsage		UseDirectionAs;
var (Sprite)		vector						ProjectionNormal;

var transient		vector						RealProjectionNormal;

defaultproperties
{
     ProjectionNormal=(Z=1.000000)
}
