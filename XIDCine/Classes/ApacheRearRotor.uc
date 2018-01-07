//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ApacheRearRotor extends HelicoRearRotor;

//_____________________________________________________________________________
/*event tick(float dT)
{
    Local rotator R;

    R.Pitch = Level.TimeSeconds * -250000;
    SetRelativeRotation( R );
}*/
event tick(float dT)
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
	R.Pitch = Angle;
	R.Roll = 0;
	R.Yaw = 0;

    SetRelativeRotation( R );
}



defaultproperties
{
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bBlockZeroExtentTraces=True
     bBlockNonZeroExtentTraces=True
     StaticMesh=StaticMesh'Meshes_Vehicules.apacheBossBack'
}
