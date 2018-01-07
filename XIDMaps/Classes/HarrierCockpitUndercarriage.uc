//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HarrierCockpitUndercarriage extends Decoration;

Event PostBeginPlay()
{
/*	if( (Owner!=none) && (Owner.bActorShadows) && (Shadow==None) )
	{
		Shadow = Spawn(class'ShadowProjector',Self,'',Location);
//		Shadow.ShadowScale = 4.4;
		Shadow.MaxTraceDistance=2500;
		Shadow.ShadowIntensity=64;
	}
*/
	SetCollision(false,false,false);
}



defaultproperties
{
     bStatic=False
     bHighDetail=True
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Meshes_Vehicules.harrier_roue'
}
