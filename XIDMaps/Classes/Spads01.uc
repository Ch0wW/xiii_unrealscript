//-----------------------------------------------------------
// Spads01.
// Created by iKi on Dec ??th 2001
// Last Modification ELR Jul 03rd 2002
// Last Modification iKI Jun 16th 2003
//-----------------------------------------------------------
class Spads01 extends Map09_Spads;

//VAR(Spads01SetUp)	Spads01LightPos SpotPos1, SpotPos2;
VAR(Spads01SetUp)	float fTimeBeforeSpotLightAlarm;
VAR					float TimeStamp;
VAR(Spads01SetUp)	BreakableMover Projo;
VAR(Spads01SetUp)	XIIIMover SurfaceLightCircleMover;
VAR(Spads01SetUp)	Projector DepthLightProjection;
VAR(Spads01SetUp)	XIIIMover LightBeamMover;
VAR					vector SpotOffset;
VAR					Spads01SpotLight Beam;
VAR					bool bSpotLighted;

//_____________________________________________________________________________
function FirstFrame()
{
    Local Spads01LightPos SP;
    local Float fTime;
	LOCAL BOX BBox;

	BBox = SurfaceLightCircleMover.GetBoundingBox();
	SpotOffset = 0.5 * ( BBox.Min + BBox.Max ) - SurfaceLightCircleMover.Location;
	log( "SpotOffset"@SpotOffset );
    Super.FirstFrame();

    TriggerEvent('helico', Self, none);
    TriggerEvent('sousmarin', Self, none);
/*
    if ( (SpotPos1 != none) && (SpotPos2 != none) )
    {
      if (SpotPos1.Location.z < SpotPos2.Location.z)
      {
        SP = SpotPos1;
        SpotPos1 = SpotPos2;
        SpotPos2 = SP;
      }
      // compute time to reach spot to optimize timer
      fTime = vSize( (SpotPos1.Location+SpotPos2.Location)/2.0 - XIIIPawn.Location) / XIIIPawn.Default.GroundSpeed;
      SetTimer2(fmax(fTime/1.5, 0.3), false);
    }
    else
      Log("### ERROR :: Missing SpotPosx in mapinfo.");*/
	Beam=spawn(class'Spads01SpotLight',,,Projo.Location,Projo.Rotation);
	Beam.SetBase(Projo);
	GotoState( 'STA_Check' );
}

STATE STA_Check
{
	EVENT BeginState()
	{
		SetTimer2( 0.1, true );
	}

	EVENT Tick( float dt)
	{
//		LOG( SurfaceLightCircleMover.Location );
		DepthLightProjection.DetachProjector(true);
		Projo.SetRotation( Rotator( SurfaceLightCircleMover.Location + SpotOffset - Projo.Location ) );
		DepthLightProjection.SetRotation( Projo.Rotation );
		DepthLightProjection.SetLocation( SurfaceLightCircleMover.Location + SpotOffset+ 64*Vector( Projo.Rotation ) );
		DepthLightProjection.AttachProjector( );

		if ( Projo==none || DepthLightProjection==none || SurfaceLightCircleMover==none )
		{
			GotoState('');
			return;
		}

		if ( Projo.bBroken )
		{
			DepthLightProjection.Destroy();
			SurfaceLightCircleMover.Destroy();
			Beam.Destroy();
			GotoState('');
			return;
		}

		if ( Normal(XIIIPawn.Location - Projo.Location) dot Vector(Projo.Rotation)>0.9987 /* cos(3°)*/)
		{
			if ( !bSpotLighted )
			{
				bSpotLighted=true;
				TimeStamp=0;
			}
			else
			{
				TimeStamp+=dt;
				if (TimeStamp>fTimeBeforeSpotLightAlarm)
				{
					TriggerEvent(event, Self, none);
//				  Level.Game.EndGame( XIIIController.PlayerReplicationInfo, "GoalIncomplete" );
				  return;
				}
			}
		}
		else
			bSpotLighted=false;
	}
}



//_____________________________________________________________________________
/*event Timer2()
{
    Local float fTime;
    Local vector vT;

    if ( bSpotLighted )
    {
      Level.Game.EndGame( XIIIController.PlayerReplicationInfo, "GoalIncomplete" );
      return;
    }

    fTime = vSize( (SpotPos1.Location+SpotPos2.Location)/2.0 - XIIIPawn.Location) / XIIIPawn.Default.GroundSpeed;
//    Log("Timer2 running fTime="$fTime$" seconds / Nextcheck="$fmax(fTime/1.5, 0.3));
    // Check player in SpotLight
    SetTimer2(fmax(fTime/1.5, 0.3), false);
    // Project player pos on spot 'spine'

    vT = SpotPos2.Location + (SpotPos1.Location - SpotPos2.Location) * (XIIIPawn.Location.z - SpotPos2.Location.z) / (SpotPos1.Location.z - SpotPos2.Location.z);
    if ( vSize(XIIIPawn.Location - vT) < 240.0 )
    {
//      Log("-> SpotLight Alert !!!");
      bSpotLighted = true;
      SetTimer2(fmax(0.1, fTimeBeforeSpotLightAlarm), false);
    }

}*/

//_____________________________________________________________________________
function SetGoalComplete(int N)
{
    switch(N)
    {
      Case 98:
        Level.Game.EndGame( XIIIController.PlayerReplicationInfo, "GoalIncomplete" );
        break;
    }
    Super.SetGoalComplete(N);
}



defaultproperties
{
     fTimeBeforeSpotLightAlarm=1.000000
}
