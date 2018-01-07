//
//-----------------------------------------------------------
class HelicoDeco extends VehicleDeco;

VAR(Crash) bool bDamagedByAllPawns;
VAR() bool bInitiallyOn, bExplodeIfDead;
VAR bool RotationMustBeCorrected, bDying;
VAR() float StabilityThreshold, PitchSlope;
VAR(Crash) string CrashLabel;
VAR(Crash) int Health, DamageAmount, DamageRadius;
VAR int InitialHealth;
VAR(Sound) Sound SoundExplosion;
VAR(Events) name CrashEvent, DeadEvent;
VAR	Emitter SmokeEmitter, ExploEmitter;

//_____________________________________________________________________________
FUNCTION PostBeginPlay()
{
	LOCAL int i;

	InitialHealth=Health;
	if( bActorShadows && (Shadow==None) )
	{
		Shadow = Spawn(class'ShadowProjector',Self,'',Location/*+vect(0,0,150)*/);
		Shadow.ShadowScale = 8; //4.4;
		Shadow.MaxTraceDistance=2500;
		Shadow.ShadowIntensity=196;
	}

	for ( i=0; i<2; i++ )
	{
		if ( PartClass[i] != None )
		{
			VehicleParts[i] = spawn(PartClass[i],self,,Location+((PartOffset[i]/**scale*/)>>Rotation),Rotation);
			if ( VehicleParts[i] == None )
				log("WARNING - "$PartClass[i]$" failed to spawn for "$self);
			else
			{
				log(self@"HELICO SPAWN - "$VehicleParts[i]);
				VehicleParts[i].SetRotation(Rotation);
				VehicleParts[i].SetBase(self);
				VehicleParts[i].SetDrawScale(DrawScale);
				VehicleParts[i].bForceInUniverse = bForceInUniverse;
			}
		}
		else
			break;
	}
	
	if ( LinkedTo == none )
	{
		Disable('Tick');
	}
	else
	{
		YawOffset=Rotation.Yaw-LinkedTo.Rotation.Yaw;
		PositionOffset=(Location-LinkedTo.Location)<<Rotation;
	}
}

FUNCTION RefreshDisplaying()
{
	LOCAL int i;

	for ( i=0; i<2; i++ )
	{
		if ( PartClass[i] != None )
		{
			VehicleParts[i].bHidden=bHidden;
			VehicleParts[i].RefreshDisplaying();
		}
	}
	if ( SmokeEmitter!=none )
	{
		SmokeEmitter.Emitters[0].Disabled=bHidden;
	}
	Super.RefreshDisplaying();
}

STATE() InvisibleUntilTriggered
{
	EVENT BeginState( )
	{
		DebugLog( self@"InvisibleUntilTriggered::BeginState" );
		SetTimer( 0.1, false );
	}

	EVENT Timer( )
	{
		DebugLog( self@"InvisibleUntilTriggered::Timer" );
		Tag=LinkedTo.Tag;
		bHidden=true;
		RefreshDisplaying();
		if ( VehicleParts[0] != None )
		{
			VehicleParts[0].bHidden=bHidden;
			VehicleParts[0].RefreshDisplaying( );
			VehicleParts[0].Disable( 'Tick' );
		}
		if ( VehicleParts[1] != None )
		{
			VehicleParts[1].bHidden=bHidden;
			VehicleParts[1].RefreshDisplaying( );
			VehicleParts[1].Disable( 'Tick' );
		}
	}

	EVENT Trigger(actor Other, Pawn EventInstigator)
	{
		DebugLog( self@"InvisibleUntilTriggered::Trigger" );
		GotoState( '' );
	}

	EVENT EndState( )
	{
		DebugLog( self@"InvisibleUntilTriggered::EndState" );
		bHidden=false;
		RefreshDisplaying();
		if ( VehicleParts[0] != None )
		{
			VehicleParts[0].bHidden=bHidden;
			VehicleParts[0].RefreshDisplaying( );
			VehicleParts[0].Enable( 'Tick' );
		}
		if ( VehicleParts[1] != None )
		{
			VehicleParts[1].bHidden=bHidden;
			VehicleParts[1].RefreshDisplaying( );
			VehicleParts[1].Enable( 'Tick' );
		}
	}

	EVENT Tick(float dt) {}
}

EVENT Trigger(actor Other, Pawn EventInstigator)
{
	LOCAL int i;
	for ( i=0; i<2; i++ )
	{
		if ( VehicleParts[i] != None )
		{
			VehicleParts[i].Trigger(none,none);
		}
	}
}

EVENT Destroyed( )
{
	LOCAL int i;

	DebugLog( self@"Destroyed" );
	LinkedTo.Destroy();
	for ( i=0; i<2; i++ )
	{
		if ( VehicleParts[i]!=none )
			VehicleParts[i].Destroy();
	}
	if ( SmokeEmitter!=none )
	{
		SmokeEmitter.Destroy();
	}

	Super.Destroyed( );
}

FUNCTION Collapse()
{
	LOCAL int i;

	if ( BrokenSM!=none )
	{
		LinkedTo.Destroy();
		for ( i=0; i<2; i++ )
		{
			if ( VehicleParts[i]!=none )
			{
				VehicleParts[i].Destroy();
//				VehicleParts[i].SetBase( none );
//				VehicleParts[i].bCollideWorld=true;
//				VehicleParts[i].SetPhysics( PHYS_Falling );
			}
		}
		if ( SmokeEmitter!=none )
		{
			SmokeEmitter.Destroy();
		}
		StaticMesh=BrokenSM;
		SetPhysics( PHYS_FALLING );
	}
}

EVENT Tick(float dt)
{
	if ( !bool( LinkedTo ) )
	{
		Disable('Tick');
		return;
	}
	
	HelicoTick( dt );
}

FUNCTION HelicoTick( float dt )
{
	LOCAL rotator r;
	LOCAL vector vTmp,gSpot,X,Y,Z;
	LOCAL float SpeedZ, SpeedH;
//	LOCAL bool bTeleport;

	gSpot = LinkedTo.Location + (PositionOffset>>Rotation) - Location;
	gSpot = gSpot*(1-inertia)+Location;
	vTmp=gSpot-Location;
	SpeedZ=vTmp.Z/dt;
	SpeedH=sqrt(vTmp.X*vTmp.X+vTmp.Y*vTmp.Y)/dt;
	r = LinkedTo.Rotation;
	
	if ( SpeedH < StabilityThreshold )
		r.Pitch= -SpeedH * PitchSlope;
	else
		r.Pitch= -StabilityThreshold * PitchSlope;
	SetLocation(gSpot);
	if ( RotationMustBeCorrected )
	{
		GetAxes( r, x, y, z);
		r=OrthoRotation(y,-x,z);
	}
	r.Yaw  = (((r.Yaw  -Rotation.Yaw  +32768)&65535)-32768);
	r.Roll = (((r.Roll -Rotation.Roll +32768)&65535)-32768);
	r.Pitch= (((r.Pitch-Rotation.Pitch+32768)&65535)-32768);
	r = r * (1-inertia**(dt*100)) + Rotation;
	SetRotation(r);
}

FUNCTION TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType )
{
	LOCAL Rotator r;
	LOCAL Float f;

	switch (DamageType)
	{
	case class'DTBladeCut':
	case class'DTStunned':
	case class'DTPierced':
	case class'DTFisted':
		return;
	case class'DTRocketed':
	case class'DTGrenaded':
		Damage*=5;
	}
	
	if ( !bDying && ( bDamagedByAllPawns || instigatedBy.IsPlayerPawn() ) )
	{
		Health= Max(0,Health-Damage);
		if (SmokeEmitter==none)
		{
			SmokeEmitter=Spawn(class'HelicoHSEmitter');
			r=SmokeEmitter.Rotation;
			r.Yaw-=16384;
			SmokeEmitter.SetRotation(r);
			SmokeEmitter.SetBase(self);
		}
		if ( SmokeEmitter!=none )
		{
			f = 1-float(Health)/InitialHealth;
			SmokeEmitter.Emitters[0].InitialParticlesPerSecond = 25*f; // PS2 E3 sinon 50 * f;	
//			SmokeEmitter.Emitters[0].ParticlesPerSecond = 25*f; // PS2 E3 sinon 50 * f;	
			SmokeEmitter.Emitters[0].Acceleration.X=-100-900*f;
			SmokeEmitter.Emitters[0].Acceleration.Z=30+270*f;
			SmokeEmitter.Emitters[0].StartSizeRange.X.Max=50+50*f;
			SmokeEmitter.Emitters[0].LifetimeRange.Min=3-2*f;
			SmokeEmitter.Emitters[0].LifetimeRange.Max=3-2*f;
		}
		if (Health==0)
		{
			bDying=true;

			if ( bExplodeIfDead )
			{
				ExploEmitter= spawn(class'HelicoExploEMitter',,,HitLocation+400*Normal(instigatedBy.Location-HitLocation));
//				HurtRadius( 5000/*DamageAmount*/, 500/*DamageRadius*/, class'DTGrenaded', 0, HitLocation );	
				
				if ( LinkedTo!=none )
					LinkedTo.PlaySound( SoundExplosion );
				else
					PlaySound( SoundExplosion );

				if ( SmokeEmitter!=none)
					SmokeEmitter.Destroy();
				GotoState( 'Dying' );
			}
			else
				if ( Cine2(LinkedTo)!=none )
				{
					DebugLog( self@"CRASH sent to cine2" );
					Cine2(LinkedTo).CineController.CineGoto( CrashLabel );
				}
		}
	}
}

STATE Dying
{
	EVENT Tick(float dt) {}

	FUNCTION TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType )
	{
	}
Begin:
	SetCollision(false,false,false);
	TriggerEvent( CrashEvent, self, none );
	Sleep( 0.1 );
	TriggerEvent( DeadEvent, self, none );
	if ( BrokenSM==none )
		Destroy( );
	else
		Collapse( );
}

//	SMMangHelCab=StaticMesh'Meshes_Vehicules.helicomangouste'
//	SMMangHelTop=StaticMesh'Meshes_Vehicules.helicomangoustetop'
//	SMMangHelBck=StaticMesh'Meshes_Vehicules.helicomangousteback'
//    PartOffset(0)=(X=0,Y=-165,Z=48)
//    PartOffset(1)=(X=0,Y=475,Z=0)



defaultproperties
{
     bInitiallyOn=True
     bExplodeIfDead=True
     RotationMustBeCorrected=True
     StabilityThreshold=500.000000
     PitchSlope=10.000000
     CrashLabel="Crash"
     Health=350
     SoundExplosion=Sound'XIIIsound.Explo__GenExplo.GenExplo__hGenExplo'
     CrashEvent="Crash"
     PartClass(0)=Class'XIDCine.HelicoTopRotor'
     PartClass(1)=Class'XIDCine.HelicoRearRotor'
     PartOffset(0)=(Y=-324.000000)
     PartOffset(1)=(Y=755.000000,Z=100.000000)
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Meshes_Vehicules.helicomangouste'
     CollisionHeight=140.000000
}
