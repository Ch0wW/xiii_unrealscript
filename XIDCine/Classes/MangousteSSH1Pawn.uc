
//     =============================================================================
//
//     dMMMMMMMMb .aMMMb   dMMMMb .aMMMMP  aMMMb   dMP dMP .dMMMb dMMMMMMP dMMMMMP --------
//    dMP"dMP"dMP dMP"dMP dMP dMP dMP"    dMP"dMP dMP dMP  MP" VP   dMP   dMP     ---
//   dMP dMP dMP dMMMMMP dMP dMP dMP MMP"dMP dMP dMP dMP  VMMMb    dMP   dMMMP   -----
//  dMP dMP dMP dMP dMP dMP dMP dMP.dMP dMP.dMP dMP.dMP dP .dMP   dMP   dMP     ---
// dMP dMP dMP dMP dMP dMP dMP  VMMMP"  VMMMP"  VMMMP"  VMMMP"   dMP   dMMMMMP -------- PAWN
//                                                                             by iKi
//=============================================================================

class MangousteSSH1Pawn extends Cine2
	hidecategories(Alliances,BaseSoldier,BaseSoldier_Advanced,Cine_Behavior,Cine_Misc,
		Cine_Script,Cine_Shoot,Cine_Sound,GroupeAlarme,Lighting,Pawn);

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

VAR(Mangouste) CWndSFXTrigger SFXVapor;
VAR(Mangouste) CWndSFXTrigger SFXSpeach;
VAR(Mangouste) CWndSFXTrigger SFXRun;
VAR(Mangouste) CWndSFXTrigger SFXDeath;
VAR(Mangouste) CWndSFXTrigger SFXBody;
VAR(Mangouste) CWndSFXTrigger SFXBody2;
VAR(Mangouste) DialogueManager DM;

VAR XIIIWeapon		Uzis[2];
VAR bool			bFireLeft, bFireRight;
VAR Vector			vLeftTarget, vRightTarget;
VAR MeshAnimation	GenericAnimations;
VAR MeshAnimation	SpecificAnimations, SpecificAnimations2, SpecificAnimations3, SpecificAnimations4;
const LEFTARMCHANNEL=12;
const RIGHTARMCHANNEL=13;
const ALPHAON=0.75;
VAR TRANSIENT MangousteSSH1Controller MangousteController;

CONST PHASE_LIMIT1=0.65; // 0.65
CONST PHASE_LIMIT2=0.13; // 0.15
CONST PHASE_LIMIT3=0.03; // 0.03

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

auto STATE STA_Init
{
begin:
	do
	{
		sleep(0.1);
		if ( XIIIGameInfo(Level.Game) != none )
		{
			mi = XIIIGameInfo(Level.Game).MapInfo;
			if ( mi!=none )
				PC = mi.XIIIController;
		}
	} until (PC!=none);
	sleep(1);
	bHidden=true;
	RefreshDisplaying();
	MangousteController = MangousteSSH1Controller(Controller);
	SetCollision(false,false,false);
	stop;
}
/*
FUNCTION KillVignettes( )
{
	LOCAL CWndOnTrigger w;
	
	XIIIBaseHUD( XIIIGameInfo( Level.Game ).MapInfo.XIIIController.MyHud ).EraseCartoonWindows();
	
	foreach DynamicActors ( class'CWndOnTrigger', w )
	{
		w.Timer();
	}
}
*/
EVENT Trigger(Actor Other, Pawn EventInstigator)
{
	GotoState( 'STA_WaitRealStart' );
//	MangousteController.GotoState( 'STA_AntiCharge' );
}

STATE STA_WaitRealStart
{
	EVENT BeginState()
	{
		LOCAL VECTOR vTemp;
		
		vTemp = MangousteController.Missiles[0].Location+560*Normal(MangousteController.Missiles[0].Location-PC.Pawn.Location);
		vTemp.Z = Location.Z;
		SetLocation( vTemp );
	}

	EVENT EndState()
	{
		LOCAL int i;

		AnimBlendParams(LEFTARMCHANNEL,0.00,0,0,'x L Clavicle');
		AnimBlendParams(RIGHTARMCHANNEL,0.00,0,0,'x R Clavicle');
		bHidden=false;
		RefreshDisplaying();
		SetCollision(true,true,false);
		Loopanim('Acquiesce'); //waitpistoletaccroupi');
		SFXSpeach.CWndDuration[0] = GetWaveDuration( "SSH102B_Mangouste_00" );
		SFXSpeach.animationDuration[0] = SFXSpeach.CWndDuration[0];
		SFXSpeach.Trigger( none, Self );
		TriggerEvent( 'CombatMangouste', self, self );
		for ( i=0; i<DM.Lines.Length; i++ )
		{
			DM.Lines[i].ExpectedEventBeforeNext=name;
		}
	
		DM.StartDialogue( 0 );
		bReloadingWeapon=false;
		
		MangousteController.GotoState( 'STA_Phase00' );
	}

	EVENT Tick( float dt )
	{
		LOCAL VECTOR vTemp;

		vTemp = PC.Pawn.Location - MangousteController.Missiles[0].Location;
		vTemp.Z = 0;
//		Log( vSize( (PC.Pawn.Location - Missiles[0].Location )*vect(1,1,0)) );

		if ( vSize( vTemp )<1750 )
		{
			PC.GotoState( 'NoControl' );
			GotoState( 'STA_Phase00' );
		}
/*		if ( PC.IsInState( 'NoControl' ) )
			PC.SetRotation( PC.Rotation + RotDiff( ROTATOR( Mangouste.Location - PC.Pawn.Location ), PC.Rotation, 90*182*dt ) );

		Global.Tick( dt );*/
	}
}

STATE STA_Phase00
{
	FUNCTION PlayMoving()
	{
		LOCAL VECTOR vTemp;

		if (velocity==vect(0,0,0))
			LoopAnim( 'WaitNeutre4', , 0.25 );
		else
			LoopAnim( 'Run', vSize(Velocity)/RunAnimVelocity , 0.25 );
	}
}

STATE STA_STAGGERING
{
	EVENT BeginState()
	{
		LOG ( "STA_STAGGERING :: BeginState(" );
	}

	EVENT EndState()
	{
		LOG ( "STA_STAGGERING :: EndState(" );
	}

	FUNCTION PlayMoving()
	{
		AnimBlendToAlpha(LEFTARMCHANNEL,0.00,0.25);
		AnimBlendToAlpha(RIGHTARMCHANNEL,0.00,0.25);
		LoopAnim('morttitube',,0.25);
	}
/*
	EVENT Hitwall( vector v, actor a )
	{
		MangousteController.Hitwall( v,a );
	}*/
}


FUNCTION TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	MangousteController.NotifyTakeDamage( Damage, EventInstigator, HitLocation, Momentum, DamageType );
	if (!MangousteController.bInvicible)
	{
		if ( ( Health-PHASE_LIMIT1*MaxHealth ) * ( Health-Damage-PHASE_LIMIT1*MaxHealth ) < 0 || ( Health-Damage-PHASE_LIMIT1*MaxHealth==0 ))
		{
		//	Log ( "REQUEST PHASE CHANGE 1->2" );
			Health=PHASE_LIMIT1*MaxHealth;
			Controller.GotoState('STA_Phase01_To_Phase02');
		}
		else
		{ //Log( "==>"@( Health-PHASE_LIMIT2*MaxHealth ) * ( Health-Damage-PHASE_LIMIT2*MaxHealth ) );
			if ( ( Health-PHASE_LIMIT2*MaxHealth ) * ( Health-Damage-PHASE_LIMIT2*MaxHealth ) < 0 || (Health-Damage-PHASE_LIMIT2*MaxHealth==0) )
			{
			//	Log ( "REQUEST PHASE CHANGE 2->3" );
				Health=PHASE_LIMIT2*MaxHealth;
				Controller.GotoState('STA_Phase02_To_Phase03');
			}
			else
			{ //Log( "==>"@( Health-PHASE_LIMIT2*MaxHealth ) * ( Health-Damage-PHASE_LIMIT2*MaxHealth ) );
				if ( ( Health-PHASE_LIMIT3*MaxHealth ) * ( Health-Damage-PHASE_LIMIT3*MaxHealth ) < 0 || (Health-Damage-PHASE_LIMIT3*MaxHealth==0) )
				{
				//	Log ( "REQUEST PHASE CHANGE 2->3" );
					Health=PHASE_LIMIT3*MaxHealth;
					Controller.GotoState('STA_Phase03_To_Fall');
				}
			}
		}

		if (!MangousteController.bInvicible)
		{
			if ( MangousteController.IsInState('STA_AntiFuite') )
				Health-=0.3*Damage;
			else
				Health-=Damage;

			if (Health<0)
			{
				Log ( 1/0 );
				Controller.GotoState('STA_Dying');
			}
			else
				Super.TakeDamage(0, EventInstigator, HitLocation, Momentum, DamageType );
		}
	}

}

EVENT PostBeginPlay()
{
	LOCAL int i;

	LinkSkelAnim ( GenericAnimations );
	LinkSkelAnim ( SpecificAnimations );
	LinkSkelAnim ( SpecificAnimations2 );
	LinkSkelAnim ( SpecificAnimations3 );
	LinkSkelAnim ( SpecificAnimations4 );

	if ( (CineControllerClass != None) && (CineController == None) )
		CineController = spawn( CineControllerClass );
	if ( CineController != None )
		CineController.Possess( self );

	Controller = CineController;
	CineController.Pawn=Self;
	CineController.MyPawn=Self;
	CineController.PC=XIIIPlayerController(Level.ControllerList);

	InitializeInventory();

	MaxHealth = Health;
}

function InitializeInventory()
{
	LOCAL Weapon inv;
	LOCAL rotator r;
	LOCAL vector l;
	
	//initialize two uzis
	inv = spawn(class'XIII.MiniUziPlus', self);
	if (inv != None)
	{
		inv.gotostate('');
		inv.GiveTo(Self);
		inv.SetBase(Self);     
		Uzis[0]=XIIIWeapon(inv);
		inv.AttachToPawn(self);
	} 
	inv = spawn(class'XIII.MiniUziPlus', self);
	if (inv != None)
	{
		inv.gotostate('');
		inv.Instigator = Self;
		AddInventory( inv );
	
		inv.bTossedOut = false;
		inv.GiveAmmo(self); // include GiveAltAmmo(Other);
		inv.AmmoType.AddAmmo(inv.ReloadCount);
		inv.ClientWeaponSet(true);
		inv.bHidden = true;
		inv.RefreshDisplaying();
		
		inv.SetBase(Self);     
		Uzis[1]=XIIIWeapon(inv);
		inv.AttachToPawn(self);
		r=inv.ThirdPersonActor.RelativeRotation;
		r.Roll+=32768;
		inv.ThirdPersonActor.SetRelativeRotation(r);
		l=inv.ThirdPersonActor.RelativeLocation;
		l.Z-=5;
		inv.ThirdPersonActor.SetRelativeLocation(l);
	} 
}

simulated function PlayFiring(float Rate, name FiringMode)
{
    WeaponMode = FiringMode;
    bWeaponFiring=true;
}

FUNCTION LeftUziFire(vector pos)
{
	vLeftTarget = pos;
	bFireLeft = true;
}	

FUNCTION RightUziFire(vector pos)
{
	vRightTarget = pos;
	bFireRight = true;
}	

EVENT Tick(float dt)
{
	Uzis[0].MySlave=none;
	Uzis[1].MySlave=none;
	Uzis[0].SlaveOf=none;
	Uzis[1].SlaveOf=none;
	Uzis[0].bEnableSlave=false;
	Uzis[1].bEnableSlave=false;

	if ( bFireLeft ) 
	{
		Controller.SetRotation( ROTATOR( vLeftTarget - Uzis[1].Location ) );
		AnimBlendToAlpha(LEFTARMCHANNEL,ALPHAON,0.1);
		LoopAnim('TirUziG',,0.1,LEFTARMCHANNEL);
		Uzis[1].Fire(0.0);
		bFireLeft = false;
	}
	else
	{
		AnimBlendToAlpha(LEFTARMCHANNEL,0,0.1);
	}

	if ( bFireRight )
	{
		Controller.SetRotation( ROTATOR( vRightTarget - Uzis[0].Location ) );
		AnimBlendToAlpha(RIGHTARMCHANNEL,ALPHAON,0.1);
		LoopAnim('TirUziD',,0.1,RIGHTARMCHANNEL);
		Uzis[0].Fire(0.0);
		bFireRight = false;
	}
	else
	{
		AnimBlendToAlpha(RIGHTARMCHANNEL,0,0.1);
	}
}

EVENT SetInitialState( )
{
	MemoColActors =		bCollideActors;
	MemoBlockActors =	bBlockActors;
	MemoBlockPlayers =	bBlockPlayers;

	bScriptInitialized = true;
//	MyOldRotYaw = Rotation.Yaw;

	GotoState( 'Auto' );
}

EVENT SeePlayer( Pawn Seen )
{
    Controller.SeePlayer(Seen);
}

FUNCTION name GetWeaponBoneFor(Inventory I)
{
	if (Uzis[0]==XIIIWeapon(I))
		return 'X R Hand';
	else if (Uzis[1]==XIIIWeapon(I))
		return 'X L Hand';
	return '';
}

EVENT Bump(actor a)
{
}

EVENT ChangeAnimation()
{
	PlayMoving();
}

FUNCTION PlayMoving()
{
	LOCAL float fSpeed,fAngle,fFrontBack,fLeftRight;
	LOCAL VECTOR vTemp;

//	if (health>0)
//	{
		if (velocity==vect(0,0,0))
			LoopAnim( 'WaitNeutre4', , 0.25 );
		else
		{
			fSpeed=vSize(Velocity);
			
			if ( Controller.Focus!=none )
				fAngle = ( ( ( ROTATOR( PC.Pawn.Location - Controller.Focus.Location ).Yaw - ROTATOR( Velocity ).Yaw ) + 32768 ) & 65535 ) - 32768;
			else
				fAngle = ( ( ( ROTATOR( PC.Pawn.Location - Controller.FocalPoint ).Yaw - ROTATOR( Velocity ).Yaw ) + 32768 ) & 65535 ) - 32768;

			if ( -12288<fAngle && fAngle<12288 )
			{
				LoopAnim( 'Run', fSpeed/RunAnimVelocity , 0.25 );
			}
			else
				if ( 12288<fAngle && fAngle<20480 )
				{
					LoopAnim( 'StrafeGSpeed', 1, 0.25 );
				}
				else
					if ( -12288<fAngle && fAngle<-20480 )
					{
						LoopAnim( 'StrafeDSpeed', 1, 0.25);
					}
					else
					{
						LoopAnim( 'BackPaddle', fSpeed/RunAnimVelocity, 0.25);
					}

/*
			if ( fFrontBack>=0 )
				LoopAnim( 'Run', fSpeed/RunAnimVelocity , 0.25 );
			else
				LoopAnim( 'BackPaddle', fSpeed/RunAnimVelocity , 0.25 );
*/
/*			if ( Abs( fLeftRight )>100 )
			{
				AnimBlendToAlpha(STRAFFECHANNEL,1.0,0.25);

				if ( fLeftRight>=0 )
					LoopAnim( 'StrafeGSpeed' , 1  , 0.25, STRAFFECHANNEL );
				else
					LoopAnim( 'StrafeDSpeed' , 1  , 0.25, STRAFFECHANNEL );
			}
			else
				AnimBlendToAlpha(STRAFFECHANNEL,0.00,0.25);
*/

//			AnimBlendToAlpha(STRAFFECHANNEL,0.00,0.25);
		}
//	}
//	else
//	{
//		AnimBlendToAlpha(LEFTARMCHANNEL,0.00,0.25);
//		AnimBlendToAlpha(RIGHTARMCHANNEL,0.00,0.25);
//		LoopAnim(WalkAnim,,0.25);
//	}
}

STATE STA_Phase01_VaporPaf
{
	EVENT BeginState( )
	{
		AnimBlendToAlpha( LEFTARMCHANNEL,  0.00, 0.25 );
		AnimBlendToAlpha( RIGHTARMCHANNEL, 0.00, 0.25 );
		LoopAnim( 'paf1', , 0.25, 0 );
	}

/*	EVENT EndState( )
	{
		KillVignettes( );
	}*/
Begin:
//	KillVignettes( );
	Sleep(0.25);
	SFXVapor.CWndDuration[0]=3;
	SFXVapor.Trigger( none, self );
}



defaultproperties
{
     GenericAnimations=MeshAnimation'XIIIPersosG.MigA'
     SpecificAnimations=MeshAnimation'XIIIPersos.MANGOUSTEspeA'
     SpecificAnimations2=MeshAnimation'XIIIPersos.MCCALLspeA'
     SpecificAnimations3=MeshAnimation'XIIIPersos.willardspeA'
     SpecificAnimations4=MeshAnimation'XIIIPersos.JOHANSSONspeA'
     DefaultAnim="TirUziGD"
     Reaction(0)=(eCS_Stimulus=CS_MapStart,TabActionIndex=1,bUneSeuleFois=True)
     InitialSpeed=1.800000
     InitialRotationSpeed=450.000000
     InitialAccelerationFactor=3.000000
     CineControllerClass=Class'XIDCine.MangousteSSH1Controller'
     ImposedEndMovePosition=False
     SightRadius=3000.000000
     PawnName="Mangoose"
     Health=3000
     bBlockPlayers=False
     Mesh=SkeletalMesh'XIIIPersos.MangousteM'
}
