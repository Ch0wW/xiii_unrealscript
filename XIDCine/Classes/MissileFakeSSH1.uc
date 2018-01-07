
//      =====================================================
//                                                          
//      dMMMMMMMMb  dMP .dMMMb  .dMMMb  dMP dMP     dMMMMMP
//     dMP"dMP"dMP amr dMP" VP dMP" VP amr dMP     dMP     
//    dMP dMP dMP dMP  VMMMb   VMMMb  dMP dMP     dMMMP    
//   dMP dMP dMP dMP dP .dMP dP .dMP dMP dMP     dMP       
//  dMP dMP dMP dMP  VMMMP"  VMMMP" dMP dMMMMMP dMMMMMP    
//                                                      by iKi
//=====================================================

class MissileFakeSSH1 extends Mover 
	placeable
	showcategories(Collision);

VAR(VaporEffect) float VEMaxIntensity;
VAR(VaporEffect) Color VEHue;
VAR(VaporEffect) float VETime;
VAR float Delay;

//VAR TRANSIENT XIIIPlayerController PC;
//VAR TRANSIENT MangousteSSH1Controller MangousteController;
VAR TRANSIENT StaticMeshActor MyMissileSM;
VAR bool bIsUp;

EVENT TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	LOCAL vector vTemp, vTemp2;
	LOCAL float fTemp;
	LOCAL MissileVaporEmitter mve;

	vTemp=HitLocation-Location;
	vTemp.Z=0;

	mve=spawn(class'MissileVaporEmitter',,,HitLocation/*Location + 256*Normal(vTemp)*/,rotator(vTemp));
	mve.SetBase(self);
	mve.Instigator=EventInstigator;

//	MangousteController.Vapor( HitLocation /*Location + 256*Normal(vTemp)*/, Normal(vTemp) );

//	if ( PC==none )
//		PC = XIIIGameInfo( Level.Game ).MapInfo.XIIIController;
//	if ( PC!=none )
//	vTemp2 = PC.Pawn.Location - HitLocation;
	// I assume that VaporDIr is normal

/*	if ( vSize(vTemp2)<512 && ((Normal(vTemp)) dot Normal(vTemp2))>cos(12/57.3) )
	{
		mve.PlayerFeedBack( XIIIGameInfo( Level.Game ).MapInfo.XIIIController, VEMaxIntensity, VEHue, VETime );
//		LOG( "TOUCHED BY VAPOR" );
	}*/
}


EVENT Trigger( actor Other, pawn EventInstigator )
{
}

EVENT PostBeginPlay( )
{
}

EVENT BeginPlay()
{
}

EVENT Timer()
{
}


FUNCTION GoDown( optional float tmpDelay )
{
	tmpDelay = Delay;

	if ( !IsInState('STA_GoingDown') )
		GotoState( 'STA_GoingDown' );
}

STATE STA_GoingDown
{
	EVENT BeginState()
	{
		if ( Delay>0 )
			SetTimer2( Delay, false );
		else
			Timer2();
	}

	EVENT Timer2()
	{
		PlaySound(MoveAmbientSound);
		bIsUp=false;
		Velocity = vect(0,0,-150);
		SetPhysics( PHYS_Projectile );
		setTimer( 1.0, true );
	}

	EVENT Timer()
	{
		if (Location.Z<=-3000)
		{
			SetPhysics( PHYS_None );
			SetTimer( 0.0, false );
			StopSound(MoveAmbientSound);
			TriggerEvent( event, self, none );
		}
	}

/*	EVENT Tick( float dt)
	{
		SetLocation( Location + dt*vect(0,0,10) );
	//	MyMissileSM.SetPhysics( PHYS_Projectile );
	}*/
}



defaultproperties
{
     VEMaxIntensity=0.100000
     VEHue=(B=160,G=255,R=255)
     VETime=1.500000
     bIsUp=True
     bBlockNonZeroExtentTraces=False
     InitialState="None"
}
