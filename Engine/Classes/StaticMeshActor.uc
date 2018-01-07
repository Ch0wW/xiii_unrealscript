//=============================================================================
// StaticMeshActor.
// An actor that is drawn using a static mesh(a mesh that never changes, and
// can be cached in video memory, resulting in a speed boost).
//=============================================================================

class StaticMeshActor extends Actor
	native
	placeable;

defaultproperties
{
     bStatic=True
     bWorldGeometry=True
     bAcceptsProjectors=True
     bInteractive=False
     bShadowCast=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     DrawType=DT_StaticMesh
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bEdShouldSnap=True
}
