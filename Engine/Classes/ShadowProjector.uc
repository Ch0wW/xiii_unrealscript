//
//	ShadowProjector
//

class ShadowProjector extends Projector
	native;

var vector					LightDirection;
var ShadowBitmapMaterial	ShadowTexture;
var FinalBlend				ShadowMaterial;
var int						ShadowIntensity;   // 0=invisible   255=black
var int						UpdateCount;
var float					ShadowScale;
var float					ShadowMaxDist;
var float					ShadowTransDist;
var bool					bShadowIsStatic;

//
//	PostBeginPlay
//

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	ShadowTexture = new(None) class'ShadowBitmapMaterial';
	ShadowTexture.ShadowActor = Owner;

	ShadowMaterial = new(None) class'FinalBlend';
	ShadowMaterial.FrameBufferBlending = FB_Darken;
	ShadowMaterial.Material = ShadowTexture;

	ProjTexture = ShadowMaterial;

	SetCollision(false,false,false);
}

//
//	Default properties
//

defaultproperties
{
     ShadowIntensity=196
     ShadowScale=1.000000
     ShadowMaxDist=1500.000000
     ShadowTransDist=1000.000000
     MaxTraceDistance=250
     bProjectActor=False
     bClipBSP=True
     bFade=True
     bProjectOnAlpha=True
     bProjectOnParallelBSP=True
     AttachPriority=20
}
