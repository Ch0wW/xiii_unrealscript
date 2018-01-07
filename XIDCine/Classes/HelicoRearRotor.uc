//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HelicoRearRotor extends Decoration;

VAR bool bTurning, bChanging;
VAR float Angle,RotationSpeed;


EVENT PostBeginPlay()
{
	if( (Owner!=none) && (Owner.bActorShadows) && (Shadow==None) )
	{
		Shadow = Spawn(class'ShadowProjector',Self,'',Location/*+vect(0,0,150)*/);
		Shadow.ShadowScale = 4.4;
		Shadow.MaxTraceDistance=2500;
		Shadow.ShadowIntensity=64;
//		LOG ("SHADOW :"@Shadow);
	}
	if ( HelicoDeco(Owner)!=none && HelicoDeco(Owner).bInitiallyOn )
	{
		bTurning=true;
		RotationSpeed=250000;
	}

	SetCollision(false,false,false);
}

EVENT Trigger(actor Other, Pawn EventInstigator)
{
	bTurning=!bTurning;
	bChanging=true;

}
//_____________________________________________________________________________
EVENT Tick( float dT )
{
    Local rotator R;

	if (bChanging)
	{
		if (bTurning)
		{
			RotationSpeed+=0.25*250000*dt;
			if (RotationSpeed>=250000)
			{
				RotationSpeed=250000;
				bChanging=false;
			}
		}
		else
		{
			RotationSpeed-=0.25*250000*dt;
			if (RotationSpeed<=0)
			{
				RotationSpeed=0;
				bChanging=false;
			}
		}
	}
	R=RelativeRotation;
	Angle -= RotationSpeed*dT;
	R.Roll = Angle;
	R.Yaw = 0;
	R.Pitch = 0;
    SetRelativeRotation( R );
}

EVENT Bump( actor Other)
{
	if ( Other.IsA( 'XIIIPlayerPawn' ) && RotationSpeed>50000 )
		Other.TakeDamage( 2000, none, Other.Location, vect(0,0,0), class'DTSuicided' );
}



defaultproperties
{
     bStatic=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Meshes_Vehicules.helicomangousteback'
}
