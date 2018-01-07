//=============================================================================
// Emitter: An Unreal Mesh Particle Emitter.
//=============================================================================
class MeshEmitter extends ParticleEmitter
	native;


var (Mesh)		staticmesh		StaticMesh;
var (Mesh)		bool			UseMeshBlendMode;
var (Mesh)		bool			RenderTwoSided;

enum EScaleAxis
{
	ScaleAxisNone,
	ScaleAxisX,
	ScaleAxisY,
	ScaleAxisXY,
	ScaleAxisZ,
	ScaleAxisXZ,
	ScaleAxisYZ,
	ScaleAxisXYZ
};
var (Mesh)		EScaleAxis		ScaleAxis;

var	transient	vector			MeshExtent;

defaultproperties
{
     UseMeshBlendMode=True
     ScaleAxis=ScaleAxisXYZ
}
