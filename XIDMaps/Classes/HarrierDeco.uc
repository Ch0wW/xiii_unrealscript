//
//-----------------------------------------------------------
class HarrierDeco extends VehicleDeco;

//VAR vector OldLocation;
VAR(Vehicle) bool bStarter;
VAR(Vehicle) float Pitch;
VAR Rotator IniRot;

function PostBeginPlay()
{
	LOCAL int i;

	if (!bStarter)
		PartClass[2]=none;
	
	if(bActorShadows && (Shadow==None) )
	{
		Shadow = Spawn( class'ShadowProjector', Self, '', Location );
		Shadow.ShadowScale = 8;
		Shadow.MaxTraceDistance=2500;
		Shadow.ShadowIntensity=196;
//		LOG ("SHADOW :"@Shadow);
	}
	
	for ( i=0; i<3; i++ )
	{
//		log ("-->"@PartClass[i]);
		if ( PartClass[i] != None )
		{
			VehicleParts[i] = spawn(PartClass[i],self,,Location+(PartOffset[i]>>Rotation)); //.X * X + PartOffset[i].Y * Y + PartOffset[i].Z * Z);
			if ( VehicleParts[i] == None )
				log("WARNING - "$PartClass[i]$" failed to spawn for "$self);
			else
			{
//				log("==> new vehicle part spawned"@VehicleParts[i]);
				VehicleParts[i].SetRotation(Rotation);
				VehicleParts[i].SetBase(self);
//				VehicleParts[i].AttachTag=Tag;
				NumParts++;
			}
		}
		else
			break;
	}
//	log ("########################################################################");
	
	if (LinkedTo==none)
	{
		Disable('Tick');
	}
	else
	{
		YawOffset=Rotation.Yaw-LinkedTo.Rotation.Yaw;
		PositionOffset=(Location-LinkedTo.Location)<<Rotation;
	}
//	Super.PostBeginPlay();
	IniRot=Rotation;
}

EVENT Tick(float dt)
{
	LOCAL vector vTmp,gSpot, X, Y, Z;
	LOCAL rotator r;
	LOCAL float SpeedZ, SpeedH;

//	LOCAL Pawn HitPawn;
//	LOCAL Vector HitLocation,HitNormal,MemHit;

	if (LinkedTo==none)
	{
		Disable('Tick');
		return;
	}
	gSpot = LinkedTo.Location + PositionOffset;
//	gSpot.z += ZOffset;

	vTmp=gSpot-Location;
	SpeedZ=vTmp.Z/dt;
	SpeedH=sqrt(vTmp.X*vTmp.X+vTmp.Y*vTmp.Y)/dt;
	if ( bStarter )
	{
		r = LinkedTo.Rotation;
		if ( SpeedH<500 )
		{
			if ( SpeedZ<300 )
				r.Pitch= SpeedZ*(SpeedZ-300)*0.25;
			else
				r.Pitch=0;
		}

		GetAxes( r, x, y, z);
		r=OrthoRotation(y,-x,z) - Rotation;
		r = r * (1-inertia) + Rotation;
		SetRotation(r);
//		log( "STARTER"@r );
	}
	else
	{
//		vTmp=vTmp>>IniRot;
//		log (vTmp );
		if (SpeedH>500)
		{
			r.Pitch = Pitch;
			r.Roll = 0;
			r.Yaw = IniRot.Yaw;
			r = r * (1-inertia) + inertia * Rotation;
		}
		else
		{
			r.Pitch = 0;
			r.Roll = 0;
			r.Yaw = IniRot.Yaw;
//			r = LinkedTo.Rotation;
//			GetAxes( r, x, y, z);
//			r=OrthoRotation(y,-x,z) - Rotation;
//			r = r * (1-inertia) + Rotation;
		}
		SetRotation(r);
//		log( "NO STARTER"@r );
	}
	SetLocation( gSpot );
//	if (!bStarter)
//		log (LinkedTo.Location+PositionOffset-gSpot);

}

// up StaticMesh'Meshes_Vehicules.cokpit'
// down StaticMesh'Meshes_Vehicules.cokpit_stat'
// wheels StaticMesh'Meshes_Vehicules.harrier_roue'



defaultproperties
{
     PartClass(0)=Class'XIDMaps.HarrierMovingCockpit'
     PartClass(1)=Class'XIDMaps.HarrierStaticCockpit'
     PartClass(2)=Class'XIDMaps.HarrierCockpitUndercarriage'
     bHighDetail=True
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Meshes_Vehicules.Harrier'
     CollisionHeight=10.000000
}
