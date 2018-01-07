class InventoryAttachment extends Actor
	native
	nativereplication;

var string StaticMeshName;            // to dynamicload it.

//_____________________________________________________________________________
// this function is called when the class if given to enemy as initial inventory (but need to dynamiload everything)
Static function StaticParseDynamicLoading(LevelInfo MyLI)
{
    Log("InventoryAttach StaticParseDynamicLoading class="$default.class);
    if ( default.StaticMeshName != "" )
      MyLI.ForcedStaticMeshes[MyLI.ForcedStaticMeshes.Length] =
        StaticMesh(DynamicLoadObject(default.StaticMeshName, class'StaticMesh'));
}

//_____________________________________________________________________________
simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    if ( (StaticMesh == none) && (StaticMeshName != "") )
    {
      StaticMesh = StaticMesh(dynamicloadobject(StaticMeshName, class'StaticMesh')); // ParseDynLoad made
      default.StaticMesh = StaticMesh;
    }
    SetDrawType(DT_StaticMesh);
}

//_____________________________________________________________________________
simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    if ( (StaticMesh == none) && (StaticMeshName != "") )
    {
      StaticMesh = StaticMesh(dynamicloadobject(StaticMeshName, class'StaticMesh'));
      default.StaticMesh = StaticMesh;
    }
    SetDrawType(DT_StaticMesh);
}

//_____________________________________________________________________________
simulated function InitFor(Inventory I)
{
//	SetDrawScale(I.ThirdPersonScale);
	Instigator = I.Instigator;
}

defaultproperties
{
     bHidden=True
     bAcceptsProjectors=True
     bInteractive=False
     bReplicateInstigator=True
     bIgnoreVignetteAlpha=True
     bIgnoreDynLight=False
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
}
