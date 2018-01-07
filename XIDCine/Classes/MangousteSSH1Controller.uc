
//     =============================================================================
//
//     dMMMMMMMMb .aMMMb   dMMMMb .aMMMMP  aMMMb   dMP dMP .dMMMb dMMMMMMP dMMMMMP --------
//    dMP"dMP"dMP dMP"dMP dMP dMP dMP"    dMP"dMP dMP dMP  MP" VP   dMP   dMP     ---
//   dMP dMP dMP dMMMMMP dMP dMP dMP MMP"dMP dMP dMP dMP  VMMMb    dMP   dMMMP   -----
//  dMP dMP dMP dMP dMP dMP dMP dMP.dMP dMP.dMP dMP.dMP dP .dMP   dMP   dMP     ---
// dMP dMP dMP dMP dMP dMP dMP  VMMMP"  VMMMP"  VMMMP"  VMMMP"   dMP   dMMMMMP -------- CONTROLLER
//                                                                             by iKi
//=============================================================================

class MangousteSSH1Controller extends CineController2;

//        ###########################################################################
//       ##                                                                       ####
//      ##  dMP dMP .aMMMb  dMMMMb  dMP .aMMMb  dMMMMb  dMP     dMMMMMP .dMMMb   ####
//     ##  dMP dMP dMP"dMP dMP.dMP amr dMP"dMP dMP"dMP dMP     dMP     dMP" VP  ####
//    ##  dMP dMP dMMMMMP dMMMMK" dMP dMMMMMP dMMMMK" dMP     dMMMP    VMMMb   #### 
//   ##   YMvAP" dMP dMP dMP"AMF dMP dMP dMP dMP.aMF dMP     dMP     dP .dMP  #### 
//  ##     VP"  dMP dMP dMP dMP dMP dMP dMP dMMMMP" dMMMMMP dMMMMMP  VMMMP"  ####
// ##                                                                       ####  
//#############################################################################
//  ##########################################################################

// My Pawn actor
VAR MangousteSSH1Pawn			Mangouste;

VAR TRANSIENT bool				bInvicible, bSwitchAttackSide, bAntiFuite, bTextFinished;
VAR TRANSIENT VECTOR			DesiredPosition, DesiredOrientation;
VAR TRANSIENT MissileFakeSSH1	MangousteNearestMissile,
								PlayerNearestMissile,
								Missiles[5]; // CT, NE, NW, SE, SW
VAR TRANSIENT float				PlayerNearestMissileDistance,
								MangousteNearestMissileDistance,
								LastTimeShoot,
								VaporTroubleEndTime,
								ReloadingEndTime,
								UnseenTime,
								XIIIHiddenTime,
								NextTauntTime;
VAR TRANSIENT int				PlayerNearestMissileIndex, 
								MangousteWantedMissileIndex,
								AttackNumber, CurrentSide, Phase,
								TauntIndex;
VAR TRANSIENT name				AntiFuite_PreviousStateName,
								Vapor_PreviousStateName;

CONST SideAttackCount=5;
CONST DifficultyRate=0.20;
VAR int							AttackSides[SideAttackCount];


CONST HoleRadius=512;// real 512
//CONST MissileRadius=256;
//CONST PlatformRadius=1800; // real 1824 or 1750

//        #####################################################
//       ##                                                  ####
//      ##  .aMMMMP dMP    .aMMMb  dMMMMb  .aMMMb  dMP      ####
//     ##  dMP"    dMP    dMP"dMP dMP"dMP dMP"dMP dMP      ####
//    ##  dMP MMP"dMP    dMP dMP dMMMMK" dMMMMMP dMP      ####
//   ##  dMP.dMP dMP    dMP.aMP dMP.aMF dMP dMP dMP      ####
//  ##   VMMMP" dMMMMMP VMMMP" dMMMMP" dMP dMP dMMMMMP  ####
// ##                                                  ####
//########################################################
//  #####################################################

EVENT BeginState()
{
	LOG( "###################################" );
	LOG( self@"is in STATE :"@GetStateName( ) );
	LOG( "-----------------------------------" );
}

FUNCTION Initialize()	
{
	LOCAL MissileFakeSSH1 mis;

	Mangouste=MangousteSSH1Pawn(Pawn);

	foreach DynamicActors(class'MissileFakeSSH1',mis)
	{
		switch(mis.tag)
		{
		case 'Central':	Missiles[0]=mis;	break;
		case 'NE':		Missiles[1]=mis;	break;
		case 'NW':		Missiles[2]=mis;	break;
		case 'SE':		Missiles[3]=mis;	break;
		case 'SW':		Missiles[4]=mis;	break;
		default:		Log("Unknown missile tag"@mis.tag);
		}
	}
	Super.Initialize();
}


EVENT SeePlayer( Pawn Seen ); //{}

FUNCTION CineWarn(actor other)
{
//	Log( "GLOBAL::CineWarn(...) => STA_Phase01_A_HideOut" );
//	Mangouste.KillVignettes();
//	GotoState('STA_Phase01_Start');
	GotoState('STA_Phase00_To_Phase01');
}

FUNCTION ROTATOR AdjustAim(Ammunition FA, VECTOR PS, INT AE) { return rotation; }

static final FUNCTION vector HVector(vector A,vector B) { return (B-A)*vect(1,1,0); }

EVENT HearNoise(float Loudness, Actor NoiseMaker);

FUNCTION ComputePlayerNearestMissile()
{
	LOCAL float d;
	LOCAL int i;

	PlayerNearestMissileDistance = 1000000;

	for ( i=0; i<5; ++i )
	{
		if ( Missiles[i].bIsUp )
		{
			d = vSize( HVector( Missiles[i].Location, PC.Pawn.Location ) );
			if ( PlayerNearestMissileDistance>d )
			{
				PlayerNearestMissile = Missiles[i];
				PlayerNearestMissileDistance = d;
				PlayerNearestMissileIndex = i;
			}
		}
	}
}

FUNCTION ComputeMangousteNearestMissile()
{
	LOCAL float d;
	LOCAL int i;

	MangousteNearestMissileDistance=1000000;

	for (i=0;i<5;++i)
	{
		if ( Missiles[i].bIsUp )
		{
			d = vSize( HVector( Missiles[i].Location, Pawn.Location ) );
			if ( MangousteNearestMissileDistance>d )
			{
				MangousteNearestMissile = Missiles[i];
				MangousteNearestMissileDistance = d;
			}
		}
	}
}

FUNCTION BurstFirePlayer( float BurstTime, float PauseTime, optional bool bLeftOnly)
{
	LOCAL float TimeCorrection;

	TimeCorrection = DifficultyRate * BurstTime;
	BurstTime -= TimeCorrection;
	PauseTime += TimeCorrection;

	if ( NextTauntTime==0 )
		NextTauntTime = Level.TimeSeconds + 10 + 5*FRand();
	else
	{
		if ( Level.TimeSeconds > NextTauntTime && !Mangouste.DM.bSpeaking/* && TauntIndex<3 */ )
		{
			Mangouste.DM.StartDialogue( Min ( 7+TauntIndex, 9 ) ); // ...
			NextTauntTime = Level.TimeSeconds + 20 + 5*FRand();
			TauntIndex = (TauntIndex+1)&7;
		}
	}

	if ( Level.TimeSeconds >= ReloadingEndTime )
		Mangouste.bReloadingWeapon = false;

	if ( Level.TimeSeconds < VaporTroubleEndTime )
	{
		bFire=0;
	}
	else
	{
		if ( ( bFire==0 ) && ( Level.TimeSeconds-LastTimeShoot>(BurstTime+PauseTime) ) && CanSee( PC.Pawn )  )
		{
			bFire=1;
			LastTimeShoot = Level.TimeSeconds;
		}
	//Mangouste.ControlSpineRotation(true);
		if ( bFire==1 && Level.TimeSeconds-LastTimeShoot>BurstTime )
		{
			if ( CanSee(PC.Pawn) )
			{
				if ( !Mangouste.bReloadingWeapon )
				{
	//				Mangouste.bFireLeft = true;
	//				Mangouste.bFireRight = true;
					Mangouste.LeftUziFire(PC.Pawn.Location);
					if (!bLeftOnly)
						Mangouste.RightUziFire(PC.Pawn.Location);
				}
				else
				{
					ReloadingEndTime = Level.TimeSeconds + 2.0;
					bFire=0;
					LastTimeShoot = 0; //Level.TimeSeconds;
				}
			}
			else
			{
				bFire=0;
			}
		}
	}
}

FUNCTION SimpleSteering( float dt, float tmpDetectionDistance, optional bool tmpAvoid )
{
	Plane = HVector( Pawn.Location, DesiredPosition );
	Steering( DesiredPosition, dt, tmpDetectionDistance, tmpAvoid );
}

FUNCTION AvoidObstacle( vector TargetLocation,out vector wanted_acceleration )
{
	LOCAL vector vTemp, vTemp2, MissileLocation;
	LOCAL float a, mini, emergency_factor;
	LOCAL int i,n;

	mini=1750000;
	n=-1;

	for (i=0;i<5;i++)
	{
		vTemp = HVector( Missiles[i].Location, Pawn.Location );
		if ( vTemp dot Hvector( TargetLocation, Pawn.Location ) < 0 )
			continue;
		a=vSize(vTemp)-HoleRadius;
		if (a<mini)
		{
			mini=a;
			n=i;
			MissileLocation = Missiles[i].Location;
		}
	}

	if ( n==-1 )
		return;

	if ( mini>64 )
		return;

	vTemp = HVector( MissileLocation, Pawn.Location );
	
	if ( ( vTemp cross HVector( TargetLocation, Pawn.Location ) ).Z > 0 )
	{
		vTemp2.X=vTemp.Y;
		vTemp2.Y=-vTemp.X;
		vTemp2.Z=0;
	}
	else
	{
		vTemp2.X=-vTemp.Y;
		vTemp2.Y=vTemp.X;
		vTemp2.Z=0;
	}
	vTemp2 = Normal(vTemp2);

//	Mangouste.DEBUG_TargetDirection = Mangouste.Location + 100 * vTemp2;

	Pawn.Velocity = fmax( /*0.6*MyPawnGroundSpeed*/Pawn.GroundSpeed,vSize(Pawn.Velocity)) * vTemp2; // annule la composante radiale
}

FUNCTION EndOfMove()
{
	Pawn.Acceleration = vect( 0, 0, 0 );
	Pawn.Velocity = vect( 0, 0, 0 );
	Pawn.PlayMoving( );
}

FUNCTION VaporHurts();

FUNCTION NotifyTakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType );

FUNCTION SetWantedSpeed(float wspeed)
{
	wantedspeed=wspeed;
	Pawn.GroundSpeed=600 * wantedspeed;	// MaximumSpeed
}

FUNCTION ChooseASide()
{
	LOCAL int side;

	side = AttackSides[ AttackNumber ];
	if ( bSwitchAttackSide )
		side = -side;
	AttackNumber++;
	if ( AttackNumber==SideAttackCount )
	{
		AttackNumber = 0;
		bSwitchAttackSide = !bSwitchAttackSide;
	}
	CurrentSide = side;
}

EVENT Tick(float dt)
{
	LOCAL VECTOR vTemp;

	FocalPoint = Pawn.Location + 256 * NORMAL( DesiredOrientation );

	if ( bAntiFuite /*Phase>0 && Phase<3*/ )
	{
		if ( GetStateName()!='STA_AntiFuite' )
		{
			vTemp = PC.Pawn.Location - Missiles[0].Location;
			vTemp.Z = 0;
			if ( vSize( vTemp )>1750 )
			{
				AntiFuite_PreviousStateName = GetStateName();
				GotoState( 'STA_AntiFuite' );
			}
		}

		if ( UnSeenTime>=0 )
		{
			if ( !PC.CanSee( Mangouste ) )
			{
				UnseenTime += dt;
				if ( UnseenTime > 8.0 && !Mangouste.DM.bSpeaking )
				{
					Mangouste.DM.StartDialogue( 1 ); // Alors on a peut le sens de l'orientation
					UnseenTime = -1;
				}

			}
			else
				UnseenTime = 0;
		}

		if ( XIIIHiddenTime>=0 )
		{
			if ( CanSee( PC.Pawn ) )
			{
				XIIIHiddenTime += dt;
				if ( XIIIHiddenTime > 8.0 && !Mangouste.DM.bSpeaking )
				{
					Mangouste.DM.StartDialogue( 4 ); // Espèce de lache, montre-toi
					XIIIHiddenTime = -1;
				}
			}
			else
				XIIIHiddenTime = 0;
		}
	
	}

}

STATE STA_AntiFuite
{
	EVENT BeginState( )
	{
		Global.BeginState();
		SetWantedSpeed(1.00);
//		PC.GotoState('PlayerWalking');
	}

	EVENT Tick( float dt )
	{
		LOCAL VECTOR vTemp;
		LOCAL FLOAT f;

		vTemp = PC.Pawn.Location - Missiles[0].Location;
		vTemp.Z = 0;
//		Log( vSize( (PC.Pawn.Location - Missiles[0].Location )*vect(1,1,0)) );

		f = vSize( vTemp )-1750;

		if ( f<0 )
		{
			LOG ( "RETURN"@AntiFuite_PreviousStateName );
			GotoState( AntiFuite_PreviousStateName );
			return;
		}

		
		DesiredPosition = PC.Pawn.Location;

		SimpleSteering( dt, f+500 );
		BurstFirePlayer( 1.0, 0.0 );
		BurstFirePlayer( 1.0, 0.0 );
		Global.Tick( dt );
	}

	EVENT EndState()
	{
		bFire=0;
	}
}

STATE STA_Phase00
{
	EVENT BeginState()
	{
//		LOCAL CWndFocusTrigger wnd;
		PC.Pawn.bCanClimbLadders=false;
		if ( PC.Pawn.OnLadder!=none )
			PC.Pawn.OnLadder.PawnLeavingVolume( PC.Pawn );
		XIIIBaseHud(PC.MyHud).AddHudCartoonFocus( Mangouste, 0, false, 5.0, false, /*zoomFOV*/ 10, /*zoomDistance*/ 1200, /*bDanger*/ true);

		Global.BeginState();
		SetWantedSpeed(0.48);
		Focus = PC.Pawn;
	}

	EVENT Tick(float dt)
	{
		PC.SetRotation( PC.Rotation + RotDiff( ROTATOR( Mangouste.Location-vect(0,0,25) - PC.Pawn.Location ), PC.Rotation, 90*182*dt ) );

		DesiredPosition = PC.Pawn.Location;

		SimpleSteering( dt, 1200 );

		Global.Tick( dt );
	}
}

STATE STA_Phase00_To_Phase01
{
	EVENT BeginState()
	{
		Pawn.RotationRate.Yaw=270*182;
		Global.BeginState();
		SetWantedSpeed(1.09);
		Mangouste.GotoState( '' );
		Phase++;
//		GotoState( 'STA_Dying');
	}

	EVENT EndState()
	{
//		SetTimer( 0, false );
//		bFire=0;
		XIIIBaseHud(PC.MyHud).AddBossBar( Pawn );
		Level.AdjustDifficulty = -(Level.Game.Difficulty)*10;
		PC.GotoState( 'PlayerWalking' );
		bAntiFuite=true;
	}

	EVENT Tick(float dt)
	{
		LOCAL VECTOR vTemp;

//		DesiredOrientation = Pawn.Velocity;

//		ComputePlayerNearestMissile();

		DesiredPosition = Missiles[0].Location+620*Normal(Hvector(PC.Pawn.Location,Missiles[0].Location));

		SimpleSteering( dt, 100 );
		
//		BurstFirePlayer( 0.1, 2.9, true );

		Global.Tick( dt );
	}

	EVENT EndOfMove()
	{
		GotoState( 'STA_Phase01_A_HideOut' );
	}
}

//     =======================================================
//
//      dMMMMb  dMP dMP  .aMMMb  .dMMMb  dMMMMMP       aMP
//     dMP.dMP dMP.dMP  dMP"dMP dMP" VP dMP         adMMP
//    dMMMMP" dMMMMK"  dMMMMMP  VMMMb  dMMMP   dMMP  dMP
//   dMP     dMP"AMF  dMP dMP dP .dMP dMP           dMP
//  dMP     dMP dMP  dMP dMP  VMMMP" dMMMMMP     dMMMMMP
//
//=======================================================
/*
STATE STA_Phase01_Start
{
	EVENT BeginState( )
	{
		Phase++;
		GotoState( 'STA_Phase01_A_HideOut' );
	}
}*/

STATE STA_Phase01_A_HideOut
{
	EVENT BeginState()
	{
//		Pawn.bDelayDisplay=true;
		Pawn.RotationRate.Yaw=270*182;
		Global.BeginState();
		SetWantedSpeed(1.09);
		Pawn.GotoState( '' );
		if (TimerRate==0.0)
			SetTimer(5.0,false);
//		Focus = PC.Pawn;
		Mangouste.PeripheralVision=0.70;
	}

	EVENT EndState()
	{
		SetTimer( 0, false );
		bFire=0;
	}

	EVENT Tick(float dt)
	{
		LOCAL VECTOR vTemp;

		DesiredOrientation = Pawn.Velocity;

		ComputePlayerNearestMissile();

		DesiredPosition = Missiles[0].Location+620*Normal(Hvector(PC.Pawn.Location,Missiles[0].Location));

		SimpleSteering( dt, 100 );
		
		BurstFirePlayer( 0.2, 0.8, true );

		Global.Tick( dt );
	}

	FUNCTION VaporHurts()
	{
		GotoState('STA_Phase01_C_VaporTrouble');
	}

	EVENT Timer()
	{
		GotoState('STA_Phase01_B_FastAttack');
	}

}

STATE STA_Phase01_B_FastAttack
{
	EVENT BeginState()
	{
		Global.BeginState();
		SetWantedSpeed(1.00);
		Pawn.GotoState( '' );
		ChooseASide();
		XIIIBaseHud(PC.MyHud).AddHudCartoonFocus( Mangouste, 0, false, 4.0, false, 10, 1200, true);
	}

	EVENT EndState()
	{
//		Mangouste.KillVignettes();
		SetTimer( 0, false );
//		SetTimer2( 0, false );
		bFire=0;
	}

	EVENT Tick(float dt)
	{
		if (CanSee(PC.Pawn) /*&& !Mangouste.bReloadingWeapon*/ )
		{
			if (TimerRate==0.0)
			{
				SetTimer( 0.8, false );
			}
		}
		BurstFirePlayer( 0.4, 0.6 );

/*			bFire=1;
			Mangouste.LeftUziFire(PC.Pawn.Location);
			Mangouste.RightUziFire(PC.Pawn.Location);
		}
*/
		DesiredOrientation = PC.Pawn.Location - Pawn.Location;
		DesiredPosition = PC.Pawn.Location + CurrentSide*128 * Normal( vect(0,0,1) cross HVector( Mangouste.Location, PC.Pawn.Location ) );

		SimpleSteering( dt, HoleRadius*1.8 );
	
		Global.Tick( dt );
	}

	EVENT EndOfMove()
	{
		ChooseASide();
	}

	EVENT Timer()
	{
		GotoState('STA_Phase01_A_HideOut');
	}

	FUNCTION VaporHurts()
	{
		GotoState('STA_Phase01_C_VaporTrouble');
	}
/*
	EVENT ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
	{
		SetTimer( 0.15, false );
	}*/
}

STATE STA_Phase01_C_VaporTrouble
{
	EVENT BeginState()
	{
		Global.BeginState();
//		SetWantedSpeed(0.15);

		Pawn.velocity = vect(0,0,0);
		Pawn.acceleration = vect(0,0,0);
		Pawn.GotoState( 'STA_Phase01_VaporPaf' );
		SetTimer( 5.0, false );
	}

	EVENT EndState()
	{
		SetTimer( 0, false );
	}

	FUNCTION NotifyTakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType )
	{
		Log( "STA_Phase01_C_VaporTrouble::NotifyTakeDamage() => STA_Phase01_A_HideOut" );
		if ( TimerRate!=0.25 )
			SetTimer( 0.25, false );
//		GotoState('STA_Phase01_A_HideOut');
	}

	EVENT Timer()
	{
		Log( "STA_Phase01_C_VaporTrouble::Timer() => STA_Phase01_A_HideOut" );
		VaporTroubleEndTime = Level.TimeSeconds + 0.5;
		GotoState('STA_Phase01_A_HideOut');
	}
}

STATE STA_Phase01_To_Phase02
{
	EVENT BeginState()
	{
		Global.BeginState();
		bAntiFuite=false;
		bInvicible=true;
		Phase++;
		Missiles[0].GoDown( );
		Pawn.GotoState( '' );
		ComputePlayerNearestMissile();
		MangousteWantedMissileIndex = 5-PlayerNearestMissileIndex;
		TriggerEvent( 'Jones_Fight', self, Mangouste );
		SetWantedSpeed(1.09);
		Mangouste.DM.StartDialogue( 2 ); // Trouve-moi si tu es si malin
		SetTimer( 20.0, false );
//		GotoState( 'STA_Phase02_A_HideOut' );
	}

	EVENT EndState()
	{
		bAntiFuite=true;
		bInvicible=false;
	}

	EVENT Timer( )
	{
		Mangouste.DM.StartDialogue( 6 ); // Surprise !!
		SetTimer2( 1.0, false );
	}

	EVENT Timer2( )
	{
		GotoState( 'STA_Phase02_D_FastAttack' );
	}

	EVENT Tick( float dt )
	{
		DesiredPosition =
			Missiles[ MangousteWantedMissileIndex ].Location
		+
			620
		*
			Normal(
				Hvector(
					PC.Pawn.Location,
					Missiles[ MangousteWantedMissileIndex ].Location
					)
				);

		SimpleSteering( dt, 100 );
		
		Global.Tick( dt );
	}
}

//     =======================================================
//
//      dMMMMb  dMP dMP  .aMMMb  .dMMMb  dMMMMMP     aMMMb
//     dMP.dMP dMP.dMP  dMP"dMP dMP" VP dMP             dP
//    dMMMMP" dMMMMK"  dMMMMMP  VMMMb  dMMMP   dMMP  aMMP
//   dMP     dMP"AMF  dMP dMP dP .dMP dMP          dMP
//  dMP     dMP dMP  dMP dMP  VMMMP" dMMMMMP      dMMMMP
//
//=======================================================

STATE STA_Phase02_A_HideOut
{
	EVENT BeginState()
	{
		Global.BeginState();
		SetWantedSpeed(1.09);
		Mangouste.PeripheralVision=0.70;
	}

	EVENT EndState()
	{
		bFire=0;
//		SetTimer( 0, false );
	}

	EVENT Tick(float dt)
	{
		BurstFirePlayer( 0.3, 0.7, true );

		DesiredOrientation = Pawn.Velocity;

		DesiredPosition = Missiles[ MangousteWantedMissileIndex ].Location ;
		DesiredPosition = DesiredPosition + 1.08 * HoleRadius * Normal( Hvector( Missiles[0].Location,DesiredPosition ) );

		SimpleSteering( dt, 100 );

		Global.Tick( dt );
	}

	EVENT EndOfMove()
	{
		Global.EndOfMove();

		if ( FRand()>0.25 )
			GotoState( 'STA_Phase02_B_WaitAndSee' );
		else
			GotoState( 'STA_Phase02_C_StayHidden' );
	}

	FUNCTION VaporHurts()
	{
		Vapor_PreviousStateName = GetStateName();
		GotoState( 'STA_Phase02_E_Vapor' );
	}

}

FUNCTION Reflex()
{
//	if ( FRand()<0.5 )
//	{
	Missiles[ MangousteWantedMissileIndex ].bIsUp=false;
	Missiles[ 5-MangousteWantedMissileIndex ].bIsUp=false;
	ComputePlayerNearestMissile();
	Missiles[ MangousteWantedMissileIndex ].bIsUp=true;
	Missiles[ 5-MangousteWantedMissileIndex ].bIsUp=true;
	MangousteWantedMissileIndex=5-PlayerNearestMissileIndex;
//	}
//	else
//		MangousteWantedMissileIndex=5-MangousteWantedMissileIndex;
	GotoState( 'STA_Phase02_A_HideOut' );
}

STATE STA_Phase02_B_WaitAndSee
{
	EVENT BeginState()
	{
		Global.BeginState();
		Pawn.velocity = vect(0,0,0);
		Pawn.acceleration = vect(0,0,0);
		DesiredOrientation = Missiles[ MangousteWantedMissileIndex ].Location - Mangouste.Location;
//		Mangouste.LoopAnim( 'Attente' );
//		Mangouste.SFXVapor.CWndDuration[0]=10000;
//		Mangouste.SFXVapor.AnimationDuration[0]=10000;
//		Mangouste.SFXVapor.Trigger( self, Mangouste );
		Mangouste.PeripheralVision=0.86;
//		if (TimerRate==0.0)
			SetTimer( 5.0, false );
	}

	EVENT EndState()
	{
		LOCAL Rotator rl;
//		Mangouste.KillVignettes( );
		SetTimer( 0.0, false );
		Mangouste.SetBoneRotation('X HEAD',rl,0,0.0);
		SetRotation( Mangouste.Rotation );
	}

	EVENT Tick( float dt )
	{
		LOCAL Rotator rl;
		LOCAL int n;

		n = 10000 * ( cos( 1.5*Level.TimeSeconds ) - 0.5 );

		rl.Yaw=0;
		rl.Pitch=0;
		rl.Roll=n+10000;

		Mangouste.SetBoneRotation('X HEAD',rl,1,0.75);

		rl = Mangouste.Rotation;
		rl.Yaw = n;
		SetRotation( Mangouste.Rotation+rl );
//		if ( CanSee( PC.Pawn ) /*&& !Mangouste.bReloadingWeapon*/ )
//		{
			BurstFirePlayer( 0.2, 0.8 );
//
//			GotoState( 'STA_Phase02_C_Attack' );
//		}

		Mangouste.ChangeAnimation();

		Global.Tick( dt );
	}


	EVENT HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( NoiseMaker.IsA( 'XIIIPlayerPawn' ) || NoiseMaker.Instigator.IsA( 'XIIIPlayerPawn' ) )
		{
//			Log( "STA_Phase02_B_WaitAndSee::HearNoise() => STA_Phase02_A_HideOut" );
			Reflex( );
		}
	}

	EVENT SeePlayer( Pawn Seen )
	{
		if ( Seen.IsA( 'XIIIPlayerPawn' ) && vSize(Seen.Location-Mangouste.Location)<512 )
		{
			Reflex( );
		}
	}

	FUNCTION NotifyTakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType )
	{
		Reflex( );
	}

	FUNCTION CineWarn( actor Other );

	EVENT Timer()
	{
		GotoState('STA_Phase02_D_FastAttack');
	}

	FUNCTION VaporHurts()
	{
		Vapor_PreviousStateName = GetStateName();
		GotoState( 'STA_Phase02_E_Vapor' );
	}
}

STATE STA_Phase02_D_FastAttack
{
	EVENT BeginState()
	{
		Global.BeginState();
		SetWantedSpeed(1.00);
		Pawn.GotoState( '' );
		ChooseASide();
	}

	EVENT EndState()
	{
//		SetTimer( 0, false );
		bFire=0;
	}

	EVENT Tick(float dt)
	{
		BurstFirePlayer( 0.4, 0.6 );

		DesiredOrientation = PC.Pawn.Location - Pawn.Location;
		DesiredPosition = PC.Pawn.Location + CurrentSide*128 * Normal( vect(0,0,1) cross HVector( Mangouste.Location, PC.Pawn.Location ) );

		SimpleSteering( dt, 800 );
	
		Global.Tick( dt );
	}

	EVENT EndOfMove()
	{
		GotoState( 'STA_Phase02_A_HideOut' );
	}

	EVENT Timer()
	{
		GotoState( 'STA_Phase02_A_HideOut' );
	}

	FUNCTION VaporHurts()
	{
		Vapor_PreviousStateName = GetStateName();
		GotoState( 'STA_Phase02_E_Vapor' );
	}
}

STATE STA_Phase02_C_StayHidden
{
	EVENT BeginState()
	{
		Global.BeginState();
		bAntiFuite=false;
		SetTimer( 5.0, false );
	}

	EVENT EndState()
	{
		bAntiFuite=true;
	}

	EVENT Timer( )
	{
		Mangouste.DM.StartDialogue( 6 ); // Surprise !!
		SetTimer2( 1.0, false );
	}

	EVENT Timer2( )
	{
		GotoState( 'STA_Phase02_D_FastAttack' );
	}

	EVENT Tick( float dt )
	{
		DesiredPosition =
			Missiles[ MangousteWantedMissileIndex ].Location
		+
			620
		*
			Normal(
				Hvector(
					PC.Pawn.Location,
					Missiles[ MangousteWantedMissileIndex ].Location
					)
				);

		SimpleSteering( dt, 100 );
		
		Global.Tick( dt );
	}

	FUNCTION NotifyTakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType )
	{
		Reflex( );
	}
}

STATE STA_Phase02_E_Vapor
{
	EVENT BeginState()
	{
		Global.BeginState();

		Pawn.velocity = vect(0,0,0);
		Pawn.acceleration = vect(0,0,0);
		Pawn.GotoState( 'STA_Phase01_VaporPaf' );
		SetTimer( 3.0, false );
	}

	EVENT EndState()
	{
		SetTimer( 0, false );
	}

	FUNCTION NotifyTakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType )
	{
		if ( TimerRate!=0.25 )
			SetTimer( 0.25, false );
	}

	EVENT Timer()
	{
		VaporTroubleEndTime = Level.TimeSeconds + 0.5;
		GotoState('STA_Phase02_C_StayHidden');
	}
}

STATE STA_Phase02_To_Phase03
{
	EVENT BeginState()
	{
		bAntiFuite=false;
		bInvicible=true;
		Phase++;
		Global.BeginState();

		Pawn.velocity = vect(0,0,0);
		Pawn.acceleration = vect(0,0,0);
		Mangouste.DM.StartDialogue( 5 ); // C'est ça qu' l'on appelle un héros
		GotoState( 'STA_Phase03_A_StayHidden' );

		Missiles[1].GoDown( 0.0 );
		Missiles[2].GoDown( 1.8 );
		Missiles[3].GoDown( 1.8 * 2);
		Missiles[4].GoDown( 1.8 * 3);
	}

	EVENT EndState()
	{
	}
}

//     =======================================================
//
//      dMMMMb  dMP dMP  .aMMMb  .dMMMb  dMMMMMP     aMMMb
//     dMP.dMP dMP.dMP  dMP"dMP dMP" VP dMP             dP
//    dMMMMP" dMMMMK"  dMMMMMP  VMMMb  dMMMP   dMMP  aMMb
//   dMP     dMP"AMF  dMP dMP dP .dMP dMP              dP
//  dMP     dMP dMP  dMP dMP  VMMMP" dMMMMMP       dMMMP
//
//=======================================================

STATE STA_Phase03_A_StayHidden
{
	EVENT BeginState()
	{
		Global.BeginState();
		SetTimer( 10.0, false );
		bAntiFuite=false;
	}

	EVENT EndState()
	{
		bInvicible=false;
//		bAntiFuite=true;
	}

	EVENT Timer( )
	{
		Mangouste.DM.StartDialogue( 3 ); // On va arreter de jouer maintenant
		SetTimer2( 1.0, false );
	}

	EVENT Timer2( )
	{
		GotoState( 'STA_Phase03_B_FreeFight' );
	}

	EVENT Tick( float dt )
	{
		DesiredPosition =
			Missiles[ MangousteWantedMissileIndex ].Location
		+
			620
		*
			Normal(
				Hvector(
					PC.Pawn.Location,
					Missiles[ MangousteWantedMissileIndex ].Location
					)
				);

		SimpleSteering( dt, 100 );
		
		Global.Tick( dt );
	}
}

STATE STA_Phase03_B_FreeFight
{
	EVENT BeginState()
	{
		SetWantedSpeed(0.50);
		Global.BeginState();
		Mangouste.PeripheralVision=0.70;
	}

	EVENT EndState()
	{
//		SetTimer( 0, false );
		bFire=0;
	}

	EVENT Tick(float dt)
	{
		LOCAL VECTOR vTemp;
		LOCAL FLOAT f;

		vTemp = PC.Pawn.Location - Missiles[0].Location;
		vTemp.Z = 0;
//		Log( vSize( (PC.Pawn.Location - Missiles[0].Location )*vect(1,1,0)) );

		f = FMax( 0, vSize( vTemp )-1750 );

		DesiredPosition = PC.Pawn.Location;
		DesiredOrientation = PC.Pawn.Location - Mangouste.Location;

		BurstFirePlayer( 0.45, 0.55 );

		SimpleSteering( dt, 800+f );

		Global.Tick( dt );
	}
}

STATE STA_Phase03_To_Fall
{
	EVENT BeginState()
	{
		Global.BeginState();
		Phase++;
		Pawn.velocity = vect(0,0,0);
		Pawn.acceleration = vect(0,0,0);

		PC.GotoState( 'NoControl' );
		Level.bCineFrame=false;
		bInvicible=true;
		XIIIBaseHud(PC.MyHud).AddBossBar( none );
		Level.AdjustDifficulty = 0;
		GotoState( 'STA_Dying' );

	}
}

//      ==========================================================================
//
//      dMMMMMP .aMMMb  dMP dMP dMMMMMP     dMMMMb  dMP dMP dMP dMMMMb  .aMMMMP
//     dMP     dMP"dMP dMP.dMP dMP         dMP VMP dMP.dMP amr dMP dMP dMP"
//    dMMMP   dMMMMMP dMMMMK" dMMMP       dMP dMP  VMMMMP dMP dMP dMP dMP MMP"
//   dMP     dMP dMP dMP"AMF dMP         dMP.aMP dA .dMP dMP dMP dMP dMP.dMP
//  dMP     dMP dMP dMP dMP dMMMMMP     dMMMMP"  VMMMP" dMP dMP dMP  VMMMP"
//  
//==========================================================================

STATE STA_Dying
{
	EVENT BeginState()
	{
		Global.BeginState();
		Missiles[0].bIsUp=true;
		Missiles[1].bIsUp=true;
		Missiles[2].bIsUp=true;
		Missiles[3].bIsUp=true;
		Missiles[4].bIsUp=true;
		ComputeMangousteNearestMissile();
		SetWantedSpeed(0.08);
		Focus=MangousteNearestMissile;
		if ( Mangouste.DM.bSpeaking )
		{
			StopVoice( );
			XIIIBaseHud( PC.MyHud ).HudDlg.RemoveMe();
			Mangouste.DM.EndOfVoice( );
		}

		Mangouste.DM.Lines[10].SpeakersToWarnAtTheEndOfThisLine="0";
		Mangouste.DM.StartDialogue( 10 ); // ...
		Mangouste.GotoState( 'STA_STAGGERING' );
		bTextFinished=false;
//		Mangouste.SetCollision(false, false, false );
	}

	EVENT EndState()
	{
		PC.GotoState( 'PlayerWalking' );
		PC.Pawn.bCanClimbLadders=true;
	}

	EVENT Tick(float dt)
	{
//		Focus=none;
//		FocalPoint=FocalPoint*0.75+0.25*(Pawn.Location+Normal(Pawn.Velocity)*250);

		DesiredOrientation = HVector(Pawn.Location,MangousteNearestMissile.Location);
		FocalPoint = MangousteNearestMissile.Location; //Pawn.Location + 256 * NORMAL( DesiredOrientation );

		DesiredPosition = MangousteNearestMissile.Location-500*Normal(DesiredOrientation);
		SimpleSteering( dt, 10, true );
		PC.SetRotation( PC.Rotation + RotDiff( ROTATOR( Mangouste.Location - PC.Pawn.Location ), PC.Rotation, 90*182*dt ) );
	}
/*
	EVENT Hitwall( vector v, actor a )
	{
		GotoState('STA_StartFalling');
//		Hitwall( v,a ),
	}
*/
	FUNCTION CineWarn( actor Other )
	{
		bTextFinished = true;
		GotoState( 'STA_Falling' );
	}

	FUNCTION EndOfMove()
	{
		Global.EndOfMove();
		GotoState('STA_StartFalling');
	}
}

STATE STA_StartFalling
{
	EVENT BeginState( )
	{
		Global.BeginState();
//		SetTimer(3,false);
		Pawn.LoopAnim('MortMangousteDebut',,0.1);
//		Mangouste.SetCollision(false, false, false );
		Mangouste.SetCollisionSize( 24, Mangouste.CollisionHeight );
		SetWantedSpeed(0.15);
		DesiredPosition=Pawn.Location;
	}

	EVENT Tick( float dt )
	{
		if ( vSize( DesiredPosition-Pawn.Location )>5 )
			Pawn.ChangeAnimation();
		else
			if ( bTextFinished )
				GotoState( 'STA_Falling' );

		DesiredPosition=Pawn.Location;
		Pawn.Velocity=vect(15.0,0,0)>>Pawn.Rotation;
	}

	FUNCTION CineWarn( actor Other )
	{
		bTextFinished = true;
	}
}

STATE STA_Falling
{
	EVENT BeginState()
	{
		Global.BeginState();
		TriggerEvent( Pawn.Event, self, Pawn );
		Pawn.PlayAnim('MortMangousteFin',,0.1);
		Pawn.SetCollision( false, false, false );
//		Pawn.Acceleration=vect(0,0,-10);
	}

	EVENT AnimEnd( int Channel )
	{
		if ( Channel==0 && Mangouste.SimAnim.AnimSequence=='MortMangousteFin' )
		{
/*			LOG ( "ANIMEND" );
			LOG ( "Channel"@Channel );
			LOG ( "Mangouste.SimAnim.AnimSequence"@Mangouste.SimAnim.AnimSequence );
			LOG ( "Mangouste.SimAnim.AnimFrame"@Mangouste.SimAnim.AnimFrame );
			Log( "gna gna");*/
			Mangouste.SetInvisibility( true );
			Mangouste.DM.StartDialogue( 11 ); // ...
//			GotoState( '' );
//			GotoState( 'Final' );
		}
	}

}
/*
STATE STA_Final
{
	EVENT BeginState( )
	{
		Enable( 'Tick' );
	}

	EVENT Tick(float dt)
	{
//		if ( !Mangouste.DM.bSpeaking )
//		{
//		}
	}
}
*/

//      ======================================= 
// 
//      dMMMMMMMMb  dMP .dMMMb  .aMMMb  
//     dMP"dMP"dMP amr dMP" VP dMP"VMP  
//    dMP dMP dMP dMP  VMMMb  dMP       
//   dMP dMP dMP dMP dP .dMP dMP.aMP amr
//  dMP dMP dMP  MP  VMMMP"  VMMMP" dMP 
// 
//======================================= 




defaultproperties
{
     AttackSides(0)=-1
     AttackSides(1)=-1
     AttackSides(2)=1
     AttackSides(3)=1
     AttackSides(4)=-1
     bCineControlAnims=False
}
