class Projector extends Actor
	placeable
	native;

#exec Texture Import File=Textures\Proj_IconMasked.pcx Name=Proj_Icon Mips=Off MASKED=1 COMPRESS=DXT1
#exec Texture Import File=Textures\ProjGradient.tga Name=ProjGradient Mips=Off MASKED=0 COMPRESS=DXT3 UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP
#exec Texture Import File=Textures\ProjClip.tga Name=ProjClip Mips=Off MASKED=0 COMPRESS=DXT3 UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP

// public properties
var transient Matrix GradientMatrix;
var transient Matrix Matrix;
var transient Vector OldLocation;
var() Material	ProjTexture;
var() int		FOV;
var() int		MaxTraceDistance;
var() bool		bProjectBSP;
var() bool		bProjectTerrain;
var() bool		bProjectStaticMesh;
var() bool		bProjectActor;
var() bool		bLevelStatic;
var() bool		bClipBSP;
var() bool		bProjectOnUnlit;
var() bool		bFade;
var() bool		bProjectOnAlpha;
var() bool		bProjectOnParallelBSP;
var() name		ProjectTag;
var() float		VScale;
var   byte		AttachPriority;

var const transient plane FrustumPlanes[6];
var const transient vector FrustumVertices[8];
var const transient Box Box;
struct ProjectorRenderInfoPtr { var int Ptr; };	// Hack to to fool C++ header generation...
var const transient ProjectorRenderInfoPtr RenderInfo;


// functions
native function AttachProjector();
native function DetachProjector(optional bool Force);
native function AbandonProjector(optional float Lifetime);

//native function AttachActor( Actor A );
//native function DetachActor( Actor A );

event PostBeginPlay()
{
	AttachProjector();
	if( bLevelStatic )
	{
		AbandonProjector();
		Destroy();
	}
/*	if( bProjectActor )
	{
		SetCollision(True, False, False);
		// GotoState('ProjectActors');  //FIXME - state doesn't exist
	}*/
}

/*event Touch( Actor Other )
{
	//if( Other.bAcceptsProjectors && (ProjectTag=='' || Other.Tag==ProjectTag) )
		AttachActor(Other);
}
event Untouch( Actor Other )
{
	DetachActor(Other);
}*/

defaultproperties
{
     MaxTraceDistance=1000
     bProjectBSP=True
     bProjectTerrain=True
     bProjectStaticMesh=True
     bProjectActor=True
     VScale=1.000000
     AttachPriority=5
     bHidden=True
     bInteractive=False
     RemoteRole=ROLE_None
     Texture=Texture'Engine.Proj_Icon'
     bDirectional=True
}
