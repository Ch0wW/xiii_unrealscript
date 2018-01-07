//-----------------------------------------------------------
//
//-----------------------------------------------------------
class USA02HelicoRotorBack extends effects;

//_____________________________________________________________________________
event tick(float dT)
{
    Local rotator R;

//    R = RelativeRotation;
    R.Pitch = Level.TimeSeconds*150000;
    SetRelativeRotation(R);
}



defaultproperties
{
     bUnlit=False
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Meshes_Vehicules.apacheBossBack'
}
