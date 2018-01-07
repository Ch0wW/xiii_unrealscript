//-----------------------------------------------------------
// Telepherique (cable-car)
// Created by iKi
//-----------------------------------------------------------
class Telepherique extends XIIIMover;

VAR()			TelepheriquePoint	PremierPoint;		// first point
VAR	TRANSIENT	TelepheriquePoint	PointCourant;		// current point
VAR(Crash)		TelepheriquePoint	CrashPoint;
VAR()			float				VitesseParDefaut;	// Default speed
VAR(Crash)		float				MaxInCabTime, MaxOnCabTopTime, OnCabTopCrashWarningTime, OnCabTopTimeBonus, DownTime;
VAR				float				OscillationAmplitude, OscillationRate, Temps, TempsFinal;
VAR TRANSIENT	float				Rouli, RouliDelta, VitesseCourante, VitesseVoulue, RatioPhysAlpha;
VAR(Crash)		StaticMesh			BrokenMesh;
VAR(Crash)		Actor				XIIIEjectionPoint;
VAR(Crash)		XIIIMover			GroundTrapDoor, TopTrapDoor, Ground, RopeTrapDoor, CableHook;
VAR(Crash)		Sound				FakeDropOutSound, RealDropOutSound, LandingSound, FakeDropOutMusic, RealDropOutMusic;
VAR(Crash)		name				CrashEvent, FakeDropOutEvent, SoldiersDeadTag, RealDropOutEvent, RocketTag;
VAR(Crash)		Mover				RocketActor;
VAR				BazookRocketTrail	RocketTrail;
VAR	TRANSIENT	Vector				StartFallingLocation, PlayerLocation, PosInitial;
VAR	TRANSIENT	Rotator				StartFallingRotation, RotInitial;
VAR TRANSIENT	Cine2				Carrington;
VAR				bool				bSoldiersDead, bFakeDropOutSoundPlayed, bForcedView;
VAR				CineRope			Corde;
CONST	HalfZGravity=1000;
CONST	rotationspeed=90;

VAR TRANSIENT	Array<actor>		Parts;
VAR TRANSIENT	XIIIPlayerController PC;

EVENT bool EncroachingOn( actor Other )
{
	if ( Level.Title == "Hual04c" )
		return false;
	return Super.EncroachingOn( Other );
}
/*
EVENT BeginState()
{
	Log( "BEGINSTATE"@GetStateName() );
}
*/
AUTO STATE STA_Init
{
	EVENT BeginState()
	{
		Global.BeginState();
		SetTimer( 0.1, false );
	}

	EVENT Timer()
	{
		LOCAL int i;
		LOCAL Actor act;

		if ( Level.Title == "Hual04c" && XIIIGameInfo(Level.Game).CheckPointNumber>1 )
		{
//			LOG("STA_Init::BeginState IN");
			ForEach DynamicActors(class'Actor',act,'TelepheriquePart')
			{
				if ( act!=CableHook )
					act.Destroy();
			}
			SetLocation( CrashPoint.Location );
			SetRotation( CrashPoint.Rotation );
			StaticMEsh=BrokenMesh;
			Disable('Tick');
			Disable('Trigger');
			SetCollision(true,true,true);
			bBlockZeroExtentTraces=true;
			bBlockNonZeroExtentTraces=true;
			return;
		}
		XIIIEjectionPoint.bHidden=false;
		XIIIEjectionPoint.RefreshDisplaying();
		XIIIEjectionPoint.SetBase( self );
		PointCourant=PremierPoint;
		PosInitial=Location;
		RotInitial=Rotation;
		RouliDelta=15;
		MoverGlideType=MV_MoveByTime;
		SetPhysics(PHYS_MovingBrush);
		KeyNum= 1;

		ForEach DynamicActors(class'Actor',act,'TelepheriquePart')
		{
			act.SetPhysics(PHYS_None);
			act.SetBase(self);
			Parts.Insert(0,1);
			Parts[0]=act;
			if ( act.IsA('BreakableMover') )
			{
				if ( act.bBlockZeroExtentTraces )
					act.bBlockPlayers=false;
			}
			else
			{
				act.Tag='Telepherique';
				act.RotationRate=rot(65535,65535,65535);
			}
			
		}
		TopTrapDoor.bBlockPlayers = false;
		RopeTrapDoor.bBlockPlayers = false;
	}

	EVENT Trigger( actor Other, pawn EventInstigator )
	{
//		LOCAL cine2 c;
//		LOG("STA_Init::Trigger IN");
		if ( Level.Title == "Hual04c" )
		{
			PC=XIIIGameInfo(Level.Game).MapInfo.XIIIController;
			foreach RadiusActors(class'cine2',Carrington,512)
			{
//				LOG( "TELEPHERIQUE : CARRINGTON IS"@Carrington );
				break;
			}
			if ( Carrington!=none )
			{
				Carrington.SetPhysics( PHYS_None );
				Carrington.SetCollision( true, false, false );
			}
		}
		SetTimer2( 0.25, false ); // Postpone start 
	}

	EVENT Timer2( )
	{
		GotoState('Moving');
	}
}
/*
EVENT Tick(float dt)
{
	Super.Tick(dt);

//	Log( Rotation );
}
*/
STATE Moving
{
	IGNORES Bump;

	EVENT BeginState()
	{
		Global.BeginState();
        KeyFrameReached();
		if ( RocketActor!=none )
		{
			Tag=RocketTag;
		}
	}

	EVENT Trigger( actor Other, pawn EventInstigator )
	{
		if (RocketTrail==none)
		{
			RocketTrail = Spawn(class'BazookRocketTrail',RocketActor,,RocketActor.Location,RocketActor.Rotation);
			RocketTrail.Init();
		}
		SetTimer( 0.5, false );
	}

	EVENT Timer( )
	{
		if ( !bForcedView && !PC.bCheatFlying ) // TODO: Disable cheat
		{
			bForcedView=true;
			PC.GotoState( 'NoControl' );
			PC.Pawn.bCanClimbLadders=false;
			PC.Pawn.bHaveOnlyOneHandFree=true;
		}
	}

	EVENT Tick(float dt)
	{
		LOCAL rotator r;
		Global.Tick(dt);

		if ( PC!=none && !PC.bCheatFlying ) // TODO: Disable cheat
			PC.Pawn.SetBase( self );
	
		if (VitesseCourante<VitesseVoulue)
		{
			VitesseCourante = FMin( VitesseVoulue, VitesseCourante + 1000 * dt );
			PhysRate = VitesseCourante * RatioPhysAlpha;
		}

		r=Rotation;
		if (r.Pitch<-120 || r.Pitch>120)
			RouliDelta=-RouliDelta;
		r.Pitch += RouliDelta * VitesseCourante / 1600;
//		LOG( "SR Moving Tick"@r);
		SetRotation(r);
		
		KeyRot[1].Pitch= r.Pitch;
		OldRot.Pitch = r.Pitch;

		if ( bForcedView && !PC.bCheatFlying ) // TODO: Disable cheat
		{
			CONST rotspeed=270;
			r=rotator(RocketActor.Location-(PC.Pawn.Location+PC.Pawn.EyePosition()))-PC.Rotation;
			r.Yaw= ((r.Yaw+32768)&65535)-32768;
			r.Roll= ((r.Roll+32768)&65535)-32768;
			r.Pitch= ((r.Pitch+32768)&65535)-32768;

			PC.SetRotation(r*0.02+PC.Rotation);
		}
	}

	EVENT KeyFrameReached()
	{
		if ( PointCourant == None )
		{
			GotoState('EndMove');
			return;
		}
		KeyPos[1]= PointCourant.location-PosInitial;
		KeyRot[1]= PointCourant.rotation-RotInitial;
		KeyRot[1].Yaw = ((KeyRot[1].Yaw+32768)&65535)-32768;
		KeyRot[1].Pitch = ((KeyRot[1].Pitch+32768)&65535)-32768;

		OldPos    = Location;
		OldRot    = Rotation;
		PhysAlpha = 0.0;

		bInterpolating   = true;

		if (PointCourant.bVitesseSpecifique==true)
			VitesseVoulue = PointCourant.Vitesse;
		else
			VitesseVoulue = VitesseParDefaut;

		RatioPhysAlpha = 1.0 / VSize(PointCourant.location-OldPos);
		PhysRate = VitesseCourante * RatioPhysAlpha;

		PointCourant=PointCourant.PointSuivant;
	}
}


STATE EndMove
{
	Ignores Bump;

	EVENT BeginState()
	{
		Global.BeginState();

		if ( Level.Title~="hual04c" )
		{
			GotoState('DangerouslySwinging');
		}
		else
		{
			TriggerEvent( event, self, none );
			GotoState('');
		}
	}
}

// In cab
STATE DangerouslySwinging
{
	EVENT BeginState()
	{
		LOCAL int i;
		LOCAL rotator r;

		Global.BeginState();

		PC.Pawn.SetPhysics( PHYS_None );

		CableHook.SetBase( none );

		r=Rotation;
		r.Roll=0;
//		LOG( "SR DangerouslySwinging BeginState"@r);
		SetRotation(r);

		OscillationAmplitude=1000; //1500;
		OscillationRate=-450*10; //-450*8;
		if ( !PC.bCheatFlying )  // TODO: Disable cheat
			PC.bGodMode = true;
		Temps=0;

		if ( RopeTrapDoor!=none )
		{
			RopeTrapDoor.Destroy();
		}

		if (GroundTrapDoor!=none)
		{
			GroundTrapDoor.Destroy();
		}

		if ( !PC.bCheatFlying )  // TODO: Disable cheat
		{
			PlayerLocation = PC.Pawn.Location;
			PC.SetViewTarget(PC.Pawn);
			if ( PC.bWeaponMode )
			{
				PC.OldWeap = PC.pawn.weapon.InventoryGroup;
				PC.Pawn.Weapon.PutDown();
			}
			else
			{
				PC.OldItem = XIIIItems(PC.Pawn.SelectedItem);
				PC.OldItem.PutDown();
			}
			PC.bWeaponBlock = true;
		}

		if (TopTrapDoor!=none)
		{
			TopTrapDoor.Destroy();
		}

		tag=SoldiersDeadTag;
		Corde = Spawn(class'cineRope',,,Location+vect(0,57,-287));
		if ( Carrington!=none )
		{
			Carrington.SetPhysics( PHYS_WAlking );
			Carrington.SetCollision( true, true, true );
		}
	}

	EVENT Trigger( actor Other, pawn EventInstigator )
	{
		bSoldiersDead=true;
	}

	EVENT Timer( )
	{
		GotoState('TheFall');
	}

	EVENT Timer2( )
	{
		if ( !PC.bCheatFlying ) // TODO: Disable cheat
			PC.ShakeView( 1.0*25.6, 0.3*1600.000000, vect(0,0,30), 0.3*120000, vect(0,0,0), 0) ;

		if (FakeDropOutSound!=none)
			PlaySound(FakeDropOutSound);

		if (FakeDropOutMusic!=none)
			PlayMusic(FakeDropOutMusic);
	}

	EVENT Tick(float dt)
	{
		LOCAL rotator r;
		LOCAL vector v;
		LOCAL int i;

		Global.Tick(dt);
		Temps+=dt;
		if ( Temps<6+5 )
		{
			if ( !PC.bCheatFlying ) // TODO: Disable cheat
			{
				r=rot(-604,-2192,7000); //XIIIEjectionPoint.Rotation;
				r.Pitch+=(FRand()-0.5)*512;
				r.Yaw+=(FRand()-0.5)*512;
				r-=PC.Rotation;
				r.Pitch = float( ( ( r.Pitch + 32768 ) & 65535 ) - 32768 );
				r.Yaw = float( ( ( r.Yaw + 32768 ) & 65535 ) - 32768 );
				r.Roll = float( ( ( r.Roll + 32768 ) & 65535 ) - 32768 );

/*::iKi::=>*/
				v = XIIIEjectionPoint.Location-PC.Pawn.Location;
				v = fMin( vSize(v), 420*dt ) * Normal( v );
				PC.Pawn.SetLocation( PC.Pawn.Location + v );
/*<=::iKi::*/
//				PC.Pawn.SetLocation(XIIIEjectionPoint.Location*0.07+0.93*PC.Pawn.Location);
				PC.SetRotation(r*0.07+PC.Rotation);
			}
			
			if ( Temps>5.5+5 )
			{
				if ( !Corde.IsInState('STA_Tight') )
				{
					Corde.GotoState('STA_Tight');// = true;
					if ( !PC.bCheatFlying ) // TODO: Disable cheat
						Level.SetInjuredEffect( false, 1.0);
				}
			}
			else
			{
				if ( !PC.bCheatFlying ) // TODO: Disable cheat
					Level.SetInjuredEffect( true, 1.0);
			}
		}
		else
		{
			if ( Temps>9+5)
			{
				if ( PC.GetStateName()=='NoControl' || PC.bCheatFlying) // TODO: Disable cheat
				{
//					if (Ground!=none)
//						Ground.Destroy();
					Corde.GotoState('STA_Break');
					if ( !PC.bCheatFlying ) // TODO: Disable cheat
					{
						PC.GotoState('PlayerWalking');
						PC.Pawn.bCanClimbLadders=true;
						PC.Pawn.bHaveOnlyOneHandFree=false;
						PC.bGodMode = false;
						PC.bWeaponBlock = false;
						PC.Pawn.PendingWeapon=XIIIWeapon(PC.Pawn.FindInventoryType(class'FusilSnipe'));
						PC.Pawn.ChangedWeapon();
					}
					SetTimer2( MaxInCabTime-5, false );
					SetTimer( MaxInCabTime, false );
				}
				else
				{
					if ( PC.Pawn.Location.Z-Location.Z> -172.0)
					{
						GotoState('Breaking');
						return;
					}
				}
			}
			else
			{
				if ( !PC.bCheatFlying ) // TODO: Disable cheat
				{
					r.Yaw = clamp(((-28000-PC.Rotation.Yaw + 32768 ) & 65535 ) - 32768, -90*182*dt, 90*182*dt) ;
					r.Pitch = clamp(((-4096/**sin((Temps-6-5)*3.14/3)*/-PC.Rotation.Pitch+32768)&65535)-32768 , -30*182*dt, 30*182*dt) ;
					r.Roll = clamp(float( ( ( -PC.Rotation.Roll + 32768 ) & 65535 ) - 32768 ), -180*182*dt, 180*182*dt) ;
					PC.SetRotation(r+PC.Rotation);

//					v=(PlayerLocation.Z-PC.Pawn.Location.z)*vect(0,0,1);
					v=fMin( PlayerLocation.Z-PC.Pawn.Location.z, 260*dt )*vect(0,0,1); //(PlayerLocation.Z-PC.Pawn.Location.z)*vect(0,0,1);
//					v.Z= Lerp(0.02, v.Z, PlayerLocation.Z);
					PC.Pawn.SetLocation( PC.Pawn.Location + v );
//					PC.Pawn.Velocity =  * Normal( v );
				}
			}

		}

		r=Rotation;
		if ( OscillationAmplitude!=0 )
		{
			if ( ( OscillationRate<0 && r.Pitch<-OscillationAmplitude ) 
				|| ( OscillationRate>0 && r.Pitch>OscillationAmplitude)	)// 384
			{
				OscillationRate=-OscillationRate*0.65;
				OscillationAmplitude*=0.65;
				if (OscillationAmplitude<200)
					OscillationAmplitude=0;
			}
			r.Pitch+=OscillationRate*dt; //*VitesseCourante/800; //400
//			LOG( "SR DangerouslySwinging Tick"@r@"I am in State"@GetStateName());
			SetRotation(r);
		}
	}
}

STATE Breaking
{
	EVENT BeginState()
	{
		Global.BeginState();
		bInterpolating = false;
//		LOG ("REDRESSE LA CABINE !!!");
//		LOG ("Ancienne rotation"@Rotation );
		SetRotation( rot(0,0,0) );
//		LOG ("Nouvelle rotation"@Rotation );
		OscillationRate=2048*30;
		OscillationAmplitude=1750;
		Temps=0;
		if (!bSoldiersDead)
		{
			MaxOnCabTopTime+=OnCabTopTimeBonus;
			OnCabTopCrashWarningTime+=0.5*OnCabTopTimeBonus;
		}
		tag='';
	}

	EVENT Tick(float dt)
	{
		LOCAL rotator r;
		LOCAL int i;

		Global.Tick(dt);
		Temps+=dt;
		if ( Temps>OnCabTopCrashWarningTime-0.2)
		{
			if ( !bFakeDropOutSoundPlayed )
			{
				if (FakeDropOutSound!=none)
					PlaySound(FakeDropOutSound);
				if (FakeDropOutMusic!=none)
					PlayMusic(FakeDropOutMusic);
				TriggerEvent( FakeDropOutEvent, self, none ); 
				PC.ShakeView( 1.0*25.6, 0.3*1600.000000, vect(0,0,30), 0.3*120000, vect(0,0,0), 0) ;
				bFakeDropOutSoundPlayed=true;
			}
			if (Temps>MaxOnCabTopTime)
			{
				GotoState('TheFall');
			}
		}
		if ( PC.bHooked && PC.HookUsed.MyHook!=none && PC.HookUsed.MyHook.IsInState('Locked')/*&& (PC.Pawn.Base == none)*/ )
		{
			GotoState('TheFall');
		}
	}

}

STATE TheFall
{
	EVENT BeginState()
	{
//		LOCAL Actor act;
		LOCAL int i;

//		LOG ("THE FALL");
		Corde.Destroy();

		if (RealDropOutSound!=none)
			PlaySound(RealDropOutSound);
		if (RealDropOutMusic!=none)
			PlayMusic(RealDropOutMusic);
		TriggerEvent(RealDropOutEvent,self,none);
		Global.BeginState();
		StartFallingLocation = Location;
		StartFallingRotation = Rotation;
		Temps=0;
		TempsFinal= sqrt( (StartFallingLocation.Z-CrashPoint.Location.Z)/HalfZGravity ); // 472

		SetCollision(false,false,false);
		bBlockZeroExtentTraces=false;
		bBlockNonZeroExtentTraces=false;
		bCollideWorld=false;
		if ( !PC.bHooked )
		{
//			PC.SetBase( none );
			PC.Pawn.DropToGround();
//			Destroy();
		}
		else
		{
			PC.GotoState('NoControl');
		}
		
		for ( i=0; i<Parts.Length;i++)
		{
			if ( Parts[i]!=CableHook )
				Parts[i].Destroy();
		}
	}
	EVENT Trigger( actor Other, pawn EventInstigator )
	{
	}

	EVENT Tick(float dt)
	{
		LOCAL Vector pos;
		LOCAL Rotator rot;

		Global.Tick(dt);

		Temps+=dt;
		if (Temps>TempsFinal)
			Temps=TempsFinal;
		pos.Z=StartFallingLocation.Z-HalfZGravity*Temps*Temps;
		pos.X=Lerp(Temps/TempsFinal,StartFallingLocation.X,CrashPoint.Location.X);
		pos.Y=Lerp(Temps/TempsFinal,StartFallingLocation.Y,CrashPoint.Location.Y);
		rot.Yaw=Lerp(Temps/TempsFinal,StartFallingRotation.Yaw,CrashPoint.Rotation.Yaw);
		rot.Roll=Lerp(Temps/TempsFinal,StartFallingRotation.Roll,CrashPoint.Rotation.Roll);
		rot.Pitch=Lerp(Temps/TempsFinal,StartFallingRotation.Pitch,CrashPoint.Rotation.Pitch);
		SetLocation(pos);
		SetRotation(rot);
		if (Temps==TempsFinal)
		{
			StaticMEsh=BrokenMesh;
			Disable('Tick');
			SetCollision(true,true,true);
			bBlockZeroExtentTraces=true;
			bBlockNonZeroExtentTraces=true;
			PlaySound(LandingSound);
			TriggerEvent(CrashEvent,self,none);
			if ( PC.IsInState( 'NoControl' ) )
				PC.GotoState( 'PlayerWalking' );
			PC.ShakeView( 1.0*25.6, 0.9*1600.000000, vect(0,0,30), 0.9*120000, vect(0,0,0), 0) ;
		}

		if ( PC.IsInState( 'NoControl' ) )
		{
			rot=rotator(Location-(PC.Pawn.Location+PC.Pawn.EyePosition()))-PC.Rotation;
			rot.Yaw=Clamp( ((rot.Yaw+32768)&65535)-32768, -rotationspeed*dt*182,rotationspeed*dt*182 );
			rot.Roll=Clamp( ((rot.Roll+32768)&65535)-32768, -rotationspeed*dt*182,rotationspeed*dt*182 );
			rot.Pitch=Clamp( ((rot.Pitch+32768)&65535)-32768, -rotationspeed*dt*182,rotationspeed*dt*182 );
			PC.SetRotation(PC.Rotation+rot);
			PC.Pawn.SetRotation(PC.Rotation+rot);
		}
	}
}
/*
STATE End
{
	Ignores Bump, Tick;

	EVENT BeginState()
	{
		LOCAL int i;
		LOCAL rotator r;

		Global.BeginState();
		for (i=0;i<Parts.Length;i++)
		{
			Parts[i].SetLocation(Location+(RelativeLocations[i]>>Rotation));
			Parts[i].SetRotation(Rotation+RelativeRotations[i]);
		}

		r=Rotation;
		r.Roll=0;
		SetRotation(r);
	}
}*/



defaultproperties
{
     VitesseParDefaut=500.000000
     MaxInCabTime=40.000000
     MaxOnCabTopTime=25.000000
     OnCabTopCrashWarningTime=2.000000
     OnCabTopTimeBonus=15.000000
     DownTime=8.000000
     BrokenMesh=StaticMesh'Telephstatic.TLcabine_cassee'
     CrashEvent="CabCrash"
     SoldiersDeadTag="We_are_dead"
     bNoInteractionIcon=True
     MoverGlideType=MV_MoveByTime
     bInteractive=False
     InitialState="STA_init"
}
