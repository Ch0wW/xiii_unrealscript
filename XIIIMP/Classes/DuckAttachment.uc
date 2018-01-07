//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DuckAttachment extends InventoryAttachment;

var string MeshName;

//_____________________________________________________________________________

simulated event PostBeginPlay()
{
    Super(Actor).PostBeginPlay();
    if ( (Mesh == none) && (MeshName != "") )
    {
      mesh = Mesh(dynamicloadobject(MeshName, class'Mesh')); // ParseDynLoad made
    }
}

//_____________________________________________________________________________

simulated event PostNetBeginPlay()
{
    Super(Actor).PostNetBeginPlay();
    if ( (Mesh == none) && (MeshName != "") )
    {
      mesh = Mesh(dynamicloadobject(MeshName, class'Mesh')); // ParseDynLoad made
    }
}

//_____________________________________________________________________________



defaultproperties
{
     MeshName="XIIIpersos.MouetSolM"
}
