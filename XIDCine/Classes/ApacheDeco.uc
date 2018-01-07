//
//-----------------------------------------------------------
class ApacheDeco extends HelicoDeco;

//	SMApacheCab=StaticMesh'Meshes_Vehicules.ApacheBoss'
//	SMApacheTop=StaticMesh'Meshes_Vehicules.ApacheBosstop'
//	SMApacheBck=StaticMesh'Meshes_Vehicules.ApacheBossback'
	//VehicleParts[1].StaticMesh=StaticMesh'Meshes_Vehicules.helicomangousteback';


defaultproperties
{
     RotationMustBeCorrected=False
     StabilityThreshold=250.000000
     PartClass(0)=Class'XIDCine.ApacheTopRotor'
     PartClass(1)=Class'XIDCine.ApacheRearRotor'
     PartOffset(0)=(X=155.000000,Y=0.000000,Z=40.000000)
     PartOffset(1)=(X=-720.000000,Y=-25.000000,Z=95.000000)
     BrokenSM=StaticMesh'Meshes_Vehicules.apachebreak'
     StaticMesh=StaticMesh'Meshes_Vehicules.apacheBoss'
     DrawScale=1.200000
}
