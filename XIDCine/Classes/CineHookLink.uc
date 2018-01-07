//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CineHookLink extends Effects;

VAR Vector vHandPos;
VAR CineHook Crochet;
VAR CineHookLink NextLink, PrevLink;
VAR int LinkIndex;


/*
var Hook HStart;
var HookProjectile HEnd;
var int LinkIndex;
var HookLink NextLink;
var HookLink PrevLink;
*/
//_____________________________________________________________________________
EVENT Tick(float deltatime)
{

}
/*
//_____________________________________________________________________________
event Destroyed()
{
  if (NextLink != none)
    NextLink.Destroy();
}

//     DrawType=DT_Mesh
//     Mesh=VertMesh'XIIIArmes.GrappinCordeM'
     DrawScale3D=(X=1.0,Y=0.35,Z=0.35)

*/


defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'MeshArmesPickup.grappincorde'
     DrawScale3D=(Y=3.000000,Z=3.000000)
}
