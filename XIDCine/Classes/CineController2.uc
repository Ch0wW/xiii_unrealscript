//-----------------------------------------------------------
// CineController2
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class CineController2 extends Controller
	native;

// On event goto xx && on warn goto xx
VAR int		nReturnIndex[16], nReturnIndexIndex;
VAR	bool	bMoving, bMovePaused, bAnimOnce, bAnimDev, bSubAnim, bInitialized, bCineControlAnims,
			bDying, bConstrainedToGround, bFrozenPlayer;

VAR TRANSIENT	Actor					FPCTarget, FPCLocation;
VAR	TRANSIENT	Cine2					MyPawn;
VAR	TRANSIENT	string					MemoError;
VAR	TRANSIENT	XIIIPlayerController	PC;
VAR	TRANSIENT	XIIIPawn				Player;
VAR TRANSIENT	name					CurrentAnim;
VAR	TRANSIENT	int						LinesCount, Counter[4], ScriptedActionIndex, flagsPaused;
VAR				float					JumpHeight;


CONST WT_PlayerProximity= 0x00000001;
CONST WT_Event			= 0x00000002;
CONST WT_Warn			= 0x00000004;
CONST WT_DialEnd		= 0x00000008;
CONST WT_SequenceEnd	= 0x00000010;
CONST WT_SeePlayer		= 0x00000020;
CONST WT_SeenByPlayer	= 0x00000040;
CONST WT_Time			= 0x00000080;
CONST WT_AnimEnd		= 0x00000100;
CONST WT_NotSeenByPlayer= 0x00000200;
CONST WT_PlayerAway		= 0x00000400;
CONST WT_SeeCadaver		= 0x00000800;

CONST WT_Mask			= 0x00000FFF;

CONST ON_PlayerProximity= 0;
CONST ON_Event			= 1;
CONST ON_Warning		= 2;
CONST ON_DialEnd		= 3;
CONST ON_SequenceEnd	= 4;
CONST ON_SeePlayer		= 5;
CONST ON_SeenByPlayer	= 6;
CONST ON_Time			= 7;
CONST ON_AnimEnd		= 8;
CONST ON_NotSeenByPlayer= 9;
CONST ON_PlayerAway		= 10;
CONST ON_SeeCadaver		= 11;

CONST ON_Max			= 12;

VAR int		nOnJump[ON_Max];

// Move Sequence variables
VAR TRANSIENT	string	MoveSequence;
VAR	TRANSIENT	Actor	Target, LockedActor, NextTarget;
VAR TRANSIENT	vector	Plane, AdjustAiming;
VAR	TRANSIENT	float	wantedspeed, rotationspeed, AccelerationFactor, DetectionDistance, ShootDispersion, MyPawnGroundSpeed;

VAR TRANSIENT	float	TimeStamp, WaitTimeEnd, JumpHight;
VAR	TRANSIENT	DialogueManager dm;
VAR TRANSIENT	rotator rWantedRotation;

VAR TRANSIENT	Actor JumpTarget;

CONST MAX_EVENT=8;
CONST MAX_EVENTHISTORYTIME=10;
VAR TRANSIENT	NAME	EventNamesTab[MAX_EVENT];
VAR TRANSIENT	ACTOR	EventOthersTab[MAX_EVENT];
VAR TRANSIENT	PAWN	EventInstigatorsTab[MAX_EVENT];
VAR TRANSIENT	float	EventDatesTab[MAX_EVENT];
VAR TRANSIENT	int		WarnMemory;

CONST PlayerLinearSpeed=600;
CONST PlayerRotationSpeed=180;
CONST RotationAcceleration=145;
VAR TRANSIENT	float	ActualPlayerRotationSpeed;

FUNCTION Initialize( )
{
	LOCAL int i;

//	LOG("CineController2 INITIALIZE :"@self);
	MyPawn = Cine2( Pawn );
	MyPawnGroundSpeed = Pawn.GroundSpeed;
	AccelerationFactor = MyPawn.InitialAccelerationFactor;
	SetWantedSpeed( MyPawn.InitialSpeed );
	SetRotationSpeed( MyPawn.InitialRotationSpeed );
	DetectionDistance = MyPawn.InitialDetectionDistance;
	ShootDispersion = MyPawn.InitialShootDispersion;
	Pawn.RotationRate.Yaw = rotationspeed * 182;
	bConstrainedToGround = ( MyPawn.vMoveconstraint.Z == 0 );
	rWantedRotation = Pawn.Rotation;

	bInitialized=true;
}

event SeeDeadPawn(pawn other)
{
	MyPawn.SeeCadaver();
}

FUNCTION ROTATOR AdjustAim(Ammunition FiredAmmunition, vector Start, int aimerror)
{
	LOCAL Rotator r;

	if ( LockedActor != none )
		r = ROTATOR( LockedActor.Location + AdjustAiming + ShootDispersion * VRand( ) - Start );
	else
		if ( Focus != none )
			r = ROTATOR( Focus.Location + AdjustAiming + ShootDispersion * VRand( ) - Start );
		else
			r = ROTATOR( vector( rotation ) + AdjustAiming + ShootDispersion * VRand( ) );

	return r;
}

//##########################################################################################################################

/***********************/ 
/**                   **/ 
/** Steering behavior **/ 
/**                   **/ 
/***********************/ 

native FUNCTION Steering(
				vector	vTargetLocation,	// wanted location
				float	dt,					// time since previous frame
				float	fDetectionDistance,	// detection distance
	optional	bool	bDisableAvoidance,	// 
	optional	bool	bFinalLocation		// pawn must slow down to reach this point
);

//native FUNCTION bool IsTargetReached(vector TargetPos,float fDectectionDistance, optional vector BorderPlaneNormal);

// Event called to avoid obstacle
event AvoidObstacle( vector TargetLocation, out vector wanted_acceleration )
{
}

//##########################################################################################################################

/********************/ 
/**                **/ 
/** Tool Functions **/ 
/**                **/ 
/********************/ 

native static final FUNCTION Actor FindAnActor(string strActorName);
native static final FUNCTION string GetFirstWord(out string s);
native static final FUNCTION bool CharIsNum(out string s);


FUNCTION DevAni(coerce name ani)
{
	AnimBlendToAlpha( 1, 0.0, 0.5 );	// Stop any animation blending smoothly
	bAnimOnce = false; // ??
	bAnimDev = true;
	Pawn.PlayAnim( ani, , MyPawn.TweenTime );
	bCineControlAnims = true;
}

FUNCTION LoopAni(coerce name ani,optional coerce float spd,optional coerce float ttime)
{
//	Log (self@"LoopAni"@ani);
	if (spd==0) spd=1;
	AnimBlendToAlpha( 1, 0.0, 0.5 );	// Stop any animation blending smoothly
	bAnimOnce = false;
	bAnimDev = false;
	Pawn.LoopAnim( ani, spd , ttime );
	bCineControlAnims = true;
	CurrentAnim=ani;
}

FUNCTION PlayAni(coerce name ani,optional coerce float spd,optional coerce float ttime,optional int channel)
{
//	Log (self@"PlayAni"@ani);
	if (spd==0) spd=1;
	if (ttime==0) ttime=MyPawn.TweenTime;
	if ( ani!='' )
	{
		AnimBlendToAlpha(1, 0.0, 0.5);	// Stop any animation blending smoothly
		bAnimOnce=true;
		CurrentAnim=ani;
		bAnimDev = false;
		Pawn.PlayAnim(ani, spd ,ttime,channel);
		bCineControlAnims=true;
	}
	else
		if ( (flagsPaused & WT_AnimEnd)!=0 ) flagsPaused = 0;

}

FUNCTION SetWantedSpeed(float wspeed)
{
	wantedspeed=wspeed;
	Pawn.GroundSpeed=MyPawnGroundSpeed * wantedspeed;	// MaximumSpeed
	Pawn.AirSpeed=Pawn.GroundSpeed;
}

FUNCTION SetRotationSpeed(float rspeed)
{
	RotationSpeed=rspeed;
}

FUNCTION ErrorScript(string s,optional bool bShowDebug)
{
	LOCAL int iTemp;

	if (bShowDebug)
		MemoError=MemoError$"#R";
	MemoError=MemoError$s$"#N";

	if (LinesCount==10)
	{
		iTemp=InStr(MemoError,"#N");
		MemoError=Mid(MemoError,iTemp+2);
	}
	else
		LinesCount+=1;
	if (bShowDebug && (XIIIGameInfo(Level.Game).PlateForme==PF_PC))
	{
		PC.myHud.bShowDebugInfo=true;
		XIIIBaseHud(PC.myHud).ShowDebugActor=MyPawn;
	}
}

FUNCTION WarnActor(Actor act)
{
	LOCAL cine2 c2;
	c2=Cine2(act);
	if (c2!=none)
		c2.CineController.CineWarn(Pawn);
}

FUNCTION CinePlayMusic(int MusicIndex)
{
	LOCAL sound snd;

	if ( MusicIndex < MyPawn.Musics.Length )
		snd=MyPawn.Musics[MusicIndex];
	if (snd==none)
		ErrorScript("Can't found music at index #C"$MusicIndex,true);
	else
		PlayMusic( snd );
}

FUNCTION CinePlaySound(coerce int SoundIndex,coerce string ActorName)
{
	LOCAL Actor act;
	LOCAL sound snd;
	if ( SoundIndex < MyPawn.Sounds.Length )
		snd=MyPawn.Sounds[SoundIndex];
	if (snd==none)
		ErrorScript("Can't found sound at index #C"$SoundIndex,true);
	else
	{
		if (ActorName=="") 
			act=MyPawn;
		else
			act=FindAnActor(ActorName);
		act.PlaySound( snd );
	}
}

FUNCTION CinePlayVoice(coerce int OnoIndex,coerce string ActorName)
{
	LOCAL Actor act;
	LOCAL sound snd;

	if ( OnoIndex < MyPawn.Onomatops.Length )
		snd=MyPawn.Onomatops[OnoIndex];
	if (snd==none)
		ErrorScript("Can't found onomatop at index #C"$OnoIndex,true);
	else
	{
		if (ActorName=="") 
			act=MyPawn;
		else
			act=FindAnActor(ActorName);
		act.PlayVoice( snd, MyPawn.CodeMesh, MyPawn.numerotimbre );
	}
}

FUNCTION CineMoveTo(Actor TmpTarget,optional bool bDontUseMovingAutomaticMovingAnim)//name TmpAnim)
{

	bCineControlAnims=bDontUseMovingAutomaticMovingAnim;

	Target=TmpTarget;

	if (Target!=none)
	{
		if ( Pawn.Physics == PHYS_None )
			Pawn.SetPhysics( PHYS_Walking ); // Walk physics is default
		Plane=Normal(Target.Location-Pawn.Location);
		bMoving=true;
	}
}

FUNCTION PauseMovement()
{
	LOCAL name Seq0;
	LOCAL float Frame0, Rate0;

	if (bMoving && !bMovePaused)
	{
		Pawn.GetAnimParams( 0, Seq0, Frame0, Rate0 );
		CurrentAnim = Seq0;
		Pawn.Acceleration=vect(0,0,0);
		Pawn.Velocity=vect(0,0,0);
		bMovePaused=true;
		Pawn.RotationRate.Yaw = 0;
//		MyPawn.LoopAnim( MyPawn.WaitAnim, , 0.5 );
		if ( !bCineControlAnims )
			MyPawn.PlayMoving();
	}
}

FUNCTION UnpauseMovement()
{
	if (bMoving && bMovePaused)
	{
		bMovePaused=false;
		MyPawn.LoopAnim( CurrentAnim, , MyPawn.TweenTime );
		Pawn.RotationRate.Yaw = rotationspeed * 182;
	}
}

FUNCTION TeleportTo(Actor act)
{				
	if (act!=none)
	{
		StopMove();
		MyPawn.SetLocation(act.Location);
		MyPawn.SetRotation(act.Rotation);
		rWantedRotation=act.Rotation;
		FocalPoint=act.Location+51200*vector(act.Rotation);
		Focus=none;
		LockedActor=none;

	}
}

FUNCTION TeleportInFrontOf(Actor act,int distance)
{				
	if (act!=none)
	{
		StopMove();
		MyPawn.SetLocation(act.Location+distance*vector(act.Rotation)+vect(0,0,30));
		MyPawn.SetRotation(rotator(act.Location-MyPawn.Location));
		MyPawn.SetPhysics( PHYS_Walking );
		rWantedRotation=MyPawn.Rotation;
		FocalPoint=MyPawn.Location+51200*vector(MyPawn.Rotation);
		Focus=none;
		LockedActor=none;

	}
}

//##########################################################################################################################

/*******************/ 
/**               **/ 
/** Initial State **/ 
/**               **/ 
/*******************/ 
STATE STA_init
{
begin:
	do
	{
		if (XIIIGameInfo(Level.Game).MapInfo!=none)
		{
			PC=XIIIGameInfo(Level.Game).MapInfo.XIIIController;
			if (PC!=none)
				break;
		}
		sleep(0.01);
	} until (PC!=none);
	Player = XIIIPawn( PC.Pawn );
	Initialize();
	stop;
}

EVENT EndOfDial(actor Other)
{
}

// Replicate some events to my pawn
EVENT SeePlayer( Pawn Seen )
{
	MyPawn.SeeXIII( );
}

EVENT HearNoise( float Loudness, Actor NoiseMaker )
{
	LOCAL bool b;
	LOCAL Actor a;

	a=NoiseMaker;

	while ( a!=none )
	{
		if ( a.IsA('XIIIPlayerPawn') )
		{
			b=true;
			break;
		}
		a = a.Owner;
	}
	if( b )//&& Pawn(NoiseMaker).IsPlayerPawn() )
		MyPawn.HearSound(  );
//	else
//		LOG(self@"IGNORE NOISE"@NoiseMaker);
}

EVENT CineWarn(actor Other) {}

//##########################################################################

FUNCTION StartDialogue(coerce name DialTag,coerce float firstline)
{
	if ( dm!=none && dm.OriginalTag==DialTag )
		dm.ForceLine( firstline );
	else
	{
		foreach DynamicActors( class'DialogueManager', dm )
		{
			if ( DialTag == dm.OriginalTag )
			{
//				LOG ( self@MyPawn.PawnName@"STARTING DIALOGUE"@DialTag@dm@"AT LINE"@firstline );
				dm.StartDialogue(firstline);
				return;	// First one is the good one :)
			}
		}
	}
}

FUNCTION StopDialogue(coerce name DialTag)
{
	LOCAL DialogueManager dial;

	if (DialTag=='')
	{
		if (dm!=none)
			dm.Destroy();
	}
	else
	{
		foreach DynamicActors(class'DialogueManager',dial,DialTag)
		{
			dial.Destroy();
		}
	}
}

//##########################################################################
// My events
// Event called when current target is reached
EVENT EndOfMove( )
{
	if ( ! NextMove( ) )
	{
		bMoving=false;
		Pawn.Acceleration = vect( 0, 0, 0 );
		Pawn.Velocity = vect( 0, 0, 0 );
		Focus = LockedActor;
//		log ( self@"EndOfMove"@Target);
		if ( Target != none )
		{
			LockedActor=none;
			Focus = none;
			FocalPoint = Pawn.Location + Vector ( Target.Rotation ) * 51200;
			rWantedRotation = Target.Rotation;
			bCineControlAnims=true;

		}
		else
		{
			rWantedRotation = Pawn.Rotation;
		}
		if (!bCineControlAnims)
			MyPawn.PlayMoving( );

		EndOfSeq( );
	}
}

EVENT EndOfSeq( )
{
}

EVENT MayFall( )
{
}

FUNCTION StopMove( )
{
	FocalPoint = Pawn.Location + 51200 * vector( Pawn.Rotation );
	Focus = none;
	Pawn.Velocity = vect( 0, 0, 0 );
	Pawn.Acceleration = vect( 0, 0, 0 );
//	bMoving = false;
	if (!bCineControlAnims)
		MyPawn.PlayMoving( );
	MoveSequence = "";
	bMoving=false;
//	EndOfMove( );
}

FUNCTION PauseMove( )
{
	FocalPoint = Pawn.Location + 51200 * vector( Pawn.Rotation );
	Focus = none;
	Pawn.Velocity = vect( 0, 0, 0 );
	Pawn.Acceleration = vect( 0, 0, 0 );
//	bMoving = false;
	if (!bCineControlAnims)
		MyPawn.PlayMoving( );
//	MoveSequence = "";
	bMoving=false;
//	EndOfMove( );
}

FUNCTION ResumeMove( )
{
	bMoving = true;
}

FUNCTION StartSequence( )
{
	LOCAL int line,i;
	
	for (i=0;i<ON_Max;i++)
		nOnJump[i]=-1;

	flagsPaused = 0;

	ScriptedActionIndex = 0;
	GotoState( 'PrePlayingSequence', 'Begin' );
}

FUNCTION int FindLabel(string Label)
{
	LOCAL string action;
	LOCAL int i;

	for (i=0;i<MyPawn.GetTabActionLength();i++)
	{
		MyPawn.GetAction(i,action);
		if (GetFirstWord(action)=="'")
		{
			if (GetFirstWord(action)~=Label)
				return i;
		}
	}
	return -1;
}

STATE PrePlayingSequence
{
begin:
	while (!bScriptInitialized)
		sleep(0.016);
	GotoState('PlayingSequence');
}

FUNCTION CineGoto( out string label )
{
	LOCAL int line,i;
	
	line = FindLabel( label );
//	DebugLog( "CineGoto"@label@"=>"@line );
	if (line!=-1)
	{
		ScriptedActionIndex=line;
		for (i=0;i<ON_Max;i++)
			nOnJump[i]=-1;
		flagsPaused=0;
	}
}

FUNCTION CineEvent(string Cine2Label)
{
	LOCAL CineController2 cc;

	if ( !( Cine2Label~="none" ) )
	{
		foreach DynamicActors(class'CineController2', cc)
		{
			if (cc!=self)
				cc.CineGoto( Cine2Label );
		}
	}
}

singular function DamageAttitudeTo(pawn Other, float Damage)
{
     //son
	MyPawn.PlaySndPNJOno(PNJOno'Onomatopees.hPNJHurt',MyPawn.CodeMesh,MyPawn.NumeroTimbre);
//     pawn.PlayVoice(Sound'XIIISound.PNJ__Onos_Pafs.Onos_Pafs__hPNJPafs',mypawn.CodeMesh,mypawn.numerotimbre);
}


FUNCTION OnGoto(out int labelindex)
{
//	LOG (self@"ON GOTO line"@labelindex );
	// Stacking old index
	nReturnIndex[nReturnIndexIndex]=ScriptedActionIndex-1;
	nReturnIndexIndex++;
	ScriptedActionIndex=labelindex;
	labelindex=-1;
	flagsPaused=0;
}

FUNCTION ROTATOR RotDiff( ROTATOR r1, ROTATOR r2, optional int fMax )
{
	r1 -= r2;
	if ( fMax == 0 )
	{
		r1.Yaw   = ( ( r1.Yaw   + 32768 ) & 65535 ) - 32768;
		r1.Roll  = ( ( r1.Roll  + 32768 ) & 65535 ) - 32768;
		r1.Pitch = ( ( r1.Pitch + 32768 ) & 65535 ) - 32768;
	}
	else
	{
		r1.Yaw   = Clamp( ( ( r1.Yaw   + 32768 ) & 65535 ) - 32768, -fMax, fMax );
		r1.Roll  = Clamp( ( ( r1.Roll  + 32768 ) & 65535 ) - 32768, -fMax, fMax );
		r1.Pitch = Clamp( ( ( r1.Pitch + 32768 ) & 65535 ) - 32768, -fMax, fMax );
	}

	return r1;
}

FUNCTION RestoreEvents( )
{
	LOCAL int i, n;
	LOCAL CineController2 C;

	ForEach DynamicActors( class 'CineController2', C )
	{
		if ( C==self)
			continue;

		for ( i=0; i<MAX_EVENT; i++ )
		{
			if ( C.EventNamesTab[i]==Tag )
			{
				Trigger( C.EventOthersTab[i], C.EventInstigatorsTab[i] );
			}

		}
	}
}

STATE PlayingSequence
{
	EVENT Tick(  float dt )
	{
		LOCAL vector Plane, v;
		LOCAL rotator r, Roto;
		LOCAL int i;
		LOCAL string Argument;

		Player = XIIIPawn( PC.Pawn );

		if ( bFrozenPlayer && !PC.IsInState( 'NoControl') )
		{
			bFrozenPlayer = false;
			PC.bWeaponBlock = false;
			if ( PC.bWeaponMode )
			{
				PC.Switchweapon( PC.OldWeap );
				PC.Pawn.ChangedWeapon();
			}
			else
			{
				PC.cNextItem();
				XIIIPawn(PC.Pawn).PendingItem = PC.OldItem;
				PC.Pawn.ChangedWeapon();
			}
		}

		if ( WarnMemory>0 && ( ( (flagsPaused & WT_Warn )!=0 ) || ( nOnJump[ON_Warning]!=-1 ) ) )
		{
//			LOG( MyPawn.Name@"  ** REPEAT WARNING **" );
			RealCineWarn( );
		}

		TimeStamp+=dt;

		SetLocation( Pawn.Location );

		if ( PC.IsInState('NoControl') )
		{
			if ( FPCLocation!=none )
			{
//				PC.Pawn.SetLocation( PC.Pawn.Location + ( 1 - ( ( 1 - 0.01 )** (150*dt) ) ) * ( FPCLocation.Location - PC.Pawn.Location ) );
				v = FPCLocation.Location-PC.Pawn.Location;
				v.Z = 0;
				v = fMin( vSize(v)/dt, PlayerLinearSpeed ) * Normal( v );
				v.Z = PC.Pawn.Velocity.Z;
				PC.Pawn.Velocity = v ;
				if ( vSize( v )==0 )
					FPCLocation=none;
			}
			if ( FPCTarget!=none )
			{
//				PC.SetRotation( PC.Rotation + ( 1 - ( ( 1 - 0.01 )** (150*dt) ) ) * RotDiff( ROTATOR( FPCTarget.Location - PC.Pawn.Location ), PC.Rotation ) );
				ActualPlayerRotationSpeed= fMin( PlayerRotationSpeed, ActualPlayerRotationSpeed+RotationAcceleration*dt );
				Roto=ROTATOR( FPCTarget.Location+vect(0,0,10)-PC.Pawn.Location );

				r.Yaw   = Clamp( ( ( Roto.Yaw   - PC.Rotation.Yaw   + 32768 ) & 65535 ) - 32768, -ActualPlayerRotationSpeed*dt*182,ActualPlayerRotationSpeed*dt*182 );
				r.Roll  = Clamp( ( ( Roto.Roll  - PC.Rotation.Roll  + 32768 ) & 65535 ) - 32768, -ActualPlayerRotationSpeed*dt*182,ActualPlayerRotationSpeed*dt*182 );
				r.Pitch = Clamp( ( ( Roto.Pitch - PC.Rotation.Pitch + 32768 ) & 65535 ) - 32768, -ActualPlayerRotationSpeed*dt* 41,ActualPlayerRotationSpeed*dt* 41 );

				PC.SetRotation( r + PC.Rotation );
//				LOG ( "ROTOTO"@r );
				if ( r.Yaw==0 && r.Pitch==0 && r.Roll==0)
				{
					ActualPlayerRotationSpeed=0;
//					FPCTarget=none;
				}
			}
		}
		else
		{
			ActualPlayerRotationSpeed=0;
		}


		switch ( flagsPaused & ( WT_SeenByPlayer | WT_NotSeenByPlayer ) )
		{
		case WT_SeenByPlayer:
			if ( Level.TimeSeconds-Pawn.LastRenderTime<0.1 && PC.CanSee( Pawn ) )
				flagsPaused = 0;
			break;
		case WT_NotSeenByPlayer:
			if	(
					( MyPawn.MemoBlockPlayers || MyPawn.Invisible || !MyPawn.bHidden )
				&&
					(
						( MyPawn.Invisible &&	! PC.CanSee( Pawn ) )
					||
						( Level.TimeSeconds-Pawn.LastRenderTime>0.5 )
					)
				)
				flagsPaused = 0;
			break;
		case WT_SeenByPlayer | WT_NotSeenByPlayer:
			flagsPaused = 0;
			break;
		case 0:
			break;
		}

		if ( nOnJump[ON_SeenByPlayer]!=-1 && nOnJump[ON_NotSeenByPlayer]!=-1 )
		{
			nOnJump[ON_SeenByPlayer]=-1;
			nOnJump[ON_NotSeenByPlayer]=-1;
		}
		else
		{
			if ( nOnJump[ON_SeenByPlayer]!=-1 && PC.CanSee( Pawn ) )
			{
				OnGoto( nOnJump[ON_SeenByPlayer] );
			}
			else if ( nOnJump[ON_NotSeenByPlayer]!=-1 && !PC.CanSee( Pawn ) )
			{
				OnGoto( nOnJump[ON_NotSeenByPlayer] );
			}

		}
//		if ( ( (  flagsPaused & WT_PlayerProximity ) != 0 || nOnJump[ON_PlayerProximity]!=-1 ) ||
//			( (  flagsPaused & WT_PlayerAway ) != 0 || nOnJump[ON_PlayerAway]!=-1 ) )
//			SetLocation( Pawn.Location );

		if ( bMoving && !bMovePaused )
		{
			if ( bool( NextTarget ) )
				Plane = NextTarget.Location - Target.Location;
			else
				Plane = vector( Target.Rotation );

			Pawn.RotationRate.Yaw = rotationspeed*182;//*3/(1+VSize(Pawn.Velocity)/(MyPawnGroundSpeed * wantedspeed));
			Focus = LockedActor;
			FocalPoint=FocalPoint*0.80+0.20*(Pawn.Location+Normal(Pawn.Velocity)*51200);
			Steering( Target.Location, dt, DetectionDistance /*+ Target.CollisionRadius*/ , true, !bool(NextTarget) && MyPawn.ImposedEndMovePosition);
///* TODEL */	EndOfMove(); /* TODEL */
		}
		else
		{
			if (bool(LockedActor))
				Focus=LockedActor;
			if ( ( Focus == none ) && ! bMovePaused && ( Target != none ) )
			{
				r = rWantedRotation - rotation;
				if (r!=rot(0,0,0))
				{
					r.Yaw   = Clamp( ( ( r.Yaw   + 32768 ) & 65535 ) - 32768, -rotationspeed * dt * 182, rotationspeed * dt * 182 );
					r.Roll  = Clamp( ( ( r.Roll  + 32768 ) & 65535 ) - 32768, -rotationspeed * dt * 182, rotationspeed * dt * 182 );
					r.Pitch = Clamp( ( ( r.Pitch + 32768 ) & 65535 ) - 32768, -rotationspeed * dt * 182, rotationspeed * dt * 182 );
					r += rotation;
					FocalPoint = ( Pawn.Location + Vector ( r ) * 51200 );
//					Focus = none;
				}
			}
			if ( !bCineControlAnims )
				Pawn.ChangeAnimation( );
//				FocalPoint = Pawn.Location + Vector ( Target.Rotation ) * 250;
		}

		if ( ( flagsPaused & WT_Time ) != 0 && ( TimeStamp >= WaitTimeEnd ) )
			flagsPaused = 0;

		if ( ( flagsPaused & WT_Mask ) ==0 )
			if ( MyPawn.GetAction(ScriptedActionIndex,Argument) )
			{
				for (i=0;i<ON_Max;i++)
					if (ScriptedActionIndex==nOnJump[i])
						nOnJump[i]=-1;

				ErrorScript("#M"$string(ScriptedActionIndex)$" - #Y"$Argument);
//Log(MyPawn.PawnName@"("@MyPawn@")"@string(ScriptedActionIndex)$" - "$Argument);
				Interpret( Argument );
			}
/*			else
			{
				MyPawn.CurrentScript=-1;
				GotoState('');
			}
*/		
	}

	EVENT Trigger( actor Other, pawn EventInstigator )
	{
//		LOG ( self@"TRIGGERED, nOnJump[ON_Event]="@nOnJump[ON_Event]@", flagsPaused="@flagsPaused );
// Handle "ON EVENT ..."
		if (nOnJump[ON_Event]!=-1)
			OnGoto( nOnJump[ON_Event] );
// Handle "WAIT EVENT ... OR ..."
		else
			if ( bool( flagsPaused & WT_Event ) ) flagsPaused = 0;
	}

	EVENT CineWarn(actor Other)
	{
//		LOG( MyPawn.Name@"** RECEIVE WARNING FROM"@Other@"**" );
		WarnMemory++;
		RealCineWarn( );
	}

	EVENT RealCineWarn( )
	{
// Handle "ON WARNING ..."
		if (nOnJump[ON_Warning]!=-1)
		{
//			LOG( MyPawn.Name@"  ** WARNING ACCEPT **.." );
			OnGoto( nOnJump[ON_Warning] );
			WarnMemory--;
		}
// Handle "WAIT WARNING OR ..."
		else
			if ( bool( flagsPaused & WT_Warn) ) 
			{
//				LOG( MyPawn.Name@"  ** WARNING ACCEPT **." );
				WarnMemory--;
				flagsPaused = 0;
			}
//			else
//				LOG( MyPawn.Name@"  ** WARNING NON EXPECTED **" );

	}

	EVENT TriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
	{
		LOCAL ACTOR A;
		LOCAL bool b;

//		LOG(self@"** TriggerEvent( '"$EventName$"', '"$Other$"', '"$EventInstigator$"' );" );
		if ( (EventName == '') || (EventName == 'None') )
			return;

		ForEach DynamicActors( class 'Actor', A, EventName )
		{
			A.Trigger( Other, EventInstigator );
			b=true;
		}

		if ( !b )
			RecordEvent( EventName, Other, EventInstigator);
	}

	FUNCTION RecordEvent( Name EventName, Actor Other, Pawn EventInstigator )
	{
		LOCAL int i;
		for ( i=0; i<MAX_EVENT; i++ )
		{
			if ( EventNamesTab[i]=='' )
			{
//				LOG( MyPawn.Name@"** RECORDING EVENT :"@EventName@"AT"@Level.TimeSeconds );
				EventNamesTab[i]=EventName;
				EventOthersTab[i]=Other;
				EventInstigatorsTab[i]=EventInstigator;
				EventDatesTab[i]=Level.TimeSeconds+MAX_EVENTHISTORYTIME;
				break;
			}
		}
		
		if ( i==MAX_EVENT )
		{
			for ( i=0; i<MAX_EVENT; i++ )
			{
				if ( Level.TimeSeconds>EventDatesTab[i] )
				{
//					LOG( MyPawn.Name@"** FORGETTING OBSOLETE EVENT :"@EventNamesTab[i]@"AT"@Level.TimeSeconds );
//					LOG( MyPawn.Name@"** RECORDING EVENT :"@EventName@"AT"@Level.TimeSeconds );
					EventNamesTab[i]=EventName;
					EventOthersTab[i]=Other;
					EventInstigatorsTab[i]=EventInstigator;
					EventDatesTab[i]=Level.TimeSeconds+MAX_EVENTHISTORYTIME;
					break;
				}
			}
//			if ( i==MAX_EVENT )
//				LOG( MyPawn.Name@"** TOO MANY RECORDED EVENTS"@"AT"@Level.TimeSeconds );
		}
	}

	EVENT EndOfDial(actor Other)
	{
// Handle "WAIT ENDOFDIAL OR ..."
		if ( bool( flagsPaused & WT_DialEnd) ) flagsPaused = 0;
//		else
//			LOG ( MyPawn.Name@"** MESSAGE ENDOFDIAL RECU MAIS NON GERE" );
	}

	EVENT Touch(actor Other)
	{
// Handle "WAIT PLAYER OR ..."
		if (Other.isA('XIIIPlayerPawn'))
		{
			if ( bool( flagsPaused & WT_PlayerProximity ) )
			{
				flagsPaused = 0;
				SetCollision(false,false,false);
			}
			else if ( nOnJump[ON_PlayerProximity]!=-1 )
				OnGoto( nOnJump[ON_PlayerProximity] );
		}
	}

	EVENT UnTouch(actor Other)
	{
// Handle "WAIT PLAYERAWAY OR ..."
		if (Other.isA('XIIIPlayerPawn'))
		{
			if ( bool( flagsPaused & WT_PlayerAway ) )
			{
				flagsPaused = 0;
				SetCollision(false,false,false);
			}
			else if ( nOnJump[ON_PlayerAway]!=-1 )
				OnGoto( nOnJump[ON_PlayerAway] );
		}
	}

// Handle "WAIT SEEPLAYER OR ..."
	EVENT SeePlayer( Pawn Seen )
	{
		if ( nOnJump[ON_SeePlayer]!=-1)
			OnGoto( nOnJump[ON_SeePlayer] );
		else 
			if ( bool( flagsPaused & WT_SeePlayer ) )
				flagsPaused = 0;

		MyPawn.SeeXIII( );
	}

	event SeeDeadPawn(pawn other)
	{
		Global.SeeDeadPawn(other);

		if ( nOnJump[ON_SeeCadaver]!=-1)
			OnGoto( nOnJump[ON_SeeCadaver] );
		else 
			if ( bool( flagsPaused & WT_SeeCadaver ) )
				flagsPaused = 0;
	}
// Handle "WAIT SEENBYPLAYER OR ..."
/*	EVENT SeenByPlayer()
	{
		if ( bool( flagsPaused & WT_SeenByPlayer ) ) flagsPaused = 0;
	}*/

// Handle "WAIT ENDOFSEQ OR ..."
	EVENT EndOfSeq()
	{
		if ( bool( flagsPaused & WT_SequenceEnd ) )
			flagsPaused = 0;
	}

// Handle "ANIM ONCE ..."
	EVENT AnimEnd( int Channel )
	{
		LOCAL vector v;
//		log(pawn@"animend"@CurrentAnim@bAnimOnce);
		if ( bDying && Channel==15 )
		{
//			Log (MyPawn.PawnName@"("@self@") CC2::AnimEnd"@name@": end of dying");
			MyPawn.ReduceMyCylinder();
			MyPawn.GotoState('Dying');
			MyPawn.bIsDead=true;
			MyPawn.Health=0;
			MyPawn.SetCollision(true,false,false);
			MyPawn.SetPhysics( PHYS_None );
//			v=MyPawn.GetBoneCoords('X').Origin-MyPawn.Location;
//			v.Z=0;
//			MyPawn.SetLocation(MyPawn.Location+v);
//
//			MyPawn.PrePivot-=v;
//			MyPawn.RecomputeBoundingVolume(true);

			MyPawn.TakeDamage( 2000, MyPawn, MyPawn.Location, vect(0,0,0), Class'XIII.DTSureStunned'/*class<DamageType> damageType*/);	
		}
		else
			if ( bAnimDev )
			{
//				DebugLog (MyPawn.PawnName@"("@self@") CC2::AnimEnd"@name@": end of DevAnim");
				if ( bool( flagsPaused & WT_AnimEnd ) ) flagsPaused = 0;
				bAnimDev = false;
				bCineControlAnims = false;
				Pawn.SetLocation( Pawn.GetBoneCoords( 'X' ).Origin );
				Pawn.SetRotation( Pawn.GetBoneRotation( 'X' ) );
			}
			else
				if (bAnimOnce && Channel==0)
				{
//					DebugLog (MyPawn.PawnName@"("@self@") CC2::AnimEnd"@name@": end of AnimOnce");
					if ( bool( flagsPaused & WT_AnimEnd ) ) flagsPaused = 0;
//					LoopAni( MyPawn.WaitAnim );
					bCineControlAnims = false;
				}
				else
					if (bSubAnim && Channel==3)
					{
//						DebugLog (MyPawn.PawnName@"("@self@") CC2::AnimEnd"@name@": end of SubAnim");
						if ( bool( flagsPaused & WT_AnimEnd ) ) flagsPaused = 0;
						bSubAnim = false;
					}
					else
						if ( Channel==14 /*FIRINGCHANNEL*/ )
						{
							Pawn.AnimBlendToAlpha(14/*FIRINGCHANNEL*/,0,0.2);
	//						bCineControlAnims=false;
	//						Log (self@"CC2::AnimEnd channel"@Channel);
						}
	}
}

final function Interpret(string Argument)
{
	LOCAL float fTemp,fTemp2;
	LOCAL name nTemp;
	LOCAL vector vTemp;
	LOCAL bool bWait;

//	Log( MyPawn.Name@">> INTERPRET : "$ScriptedActionIndex$" -> '"$Argument$"'" );
	switch ( GetFirstWord( Argument ) )
	{
// skip this line or label
	case "REM": case "'":	break;
// freeze player control
	case "FPC": case "FreezePlayer":
		PC.GotoState('NoControl');
		PC.StopFiring();
		FPCTarget = none;
		FPCLocation = none;
		PC.Velocity = vect(0,0,0);
		if ( Argument!="" )
		{
			FPCTarget=FindAnActor(GetFirstWord(Argument));
//			LOG ("Target  ==>"@FPCTarget);
			if ( Argument!="" )
			{
				FPCLocation=FindAnActor(GetFirstWord(Argument));
//				LOG ("Location==>"@FPCLocation);
			}
		}
		if ( !bFrozenPlayer )
		{
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
			bFrozenPlayer = true;
		}
		break;
// freeze player control
	case "FPL": case "FreezePlayerLocation":
		PC.GotoState('NoMove');
		break;
	case "PV":
		Pawn.PeripheralVision=float(GetFirstWord( Argument ));
		break;
	case "SR":
		Pawn.SightRadius=float(GetFirstWord( Argument ));
		break;
	case "DUCK":
	    PC.PlayerInput.bForceCrouch = true;
		PC.Pawn.bCanCrouch = true;
		break;
// release player control
	case "RPC": case "ReleasePlayer":
		PC.GotoState('PlayerWalking');
	    PC.PlayerInput.bForceCrouch = false;
		FPCTarget=none;
		FPCLocation=none;
		break;
	case "ForceCrouch":
	    PC.PlayerInput.bForceCrouch = true;
		break;
// the actor must die
	case "Faint":
	case "Die":
		if ( Argument!="")
		{
			bDying=true;
			Pawn.AnimBlendParams(15,0.0,0,0,'X');
			PlayAni( '' );
			nTemp = name( GetFirstWord( Argument ) );
			if ( Argument!="" )
			{
				fTemp = float( GetFirstWord( Argument ) );
				if ( fTemp==0 )
					fTemp=1;
			}
			else
				fTemp = 1.0;
			Pawn.AnimBlendToAlpha(15,fTemp,MyPawn.TweenTime);
			PlayAni( nTemp, fTemp, MyPawn.TweenTime, 15 );
		}
		else
			MyPawn.TakeDamage( 2000, MyPawn, MyPawn.Location, vect(0,0,0), Class'XIII.DTSureStunned'/*class<DamageType> damageType*/);	
		break;
	case "BeDead":
		MyPawn.Health= 0;
		MyPawn.bIsDead= true;
		break;
//	case "Faint":
//		MyPawn.TakeDamage( 0, MyPawn, MyPawn.Location, vect(0,0,0), Class'XIII.DTSureStunned'/*class<DamageType> damageType*/);
//		break;
	case "Fall":
		GoFall(FindAnActor(GetFirstWord(Argument)),float(GetFirstWord(Argument)),float(GetFirstWord(Argument)));
		break;
	case "Jump":
		GoJump(FindAnActor(GetFirstWord(Argument)),float(GetFirstWord(Argument)));
		break;

// the actor will become invisibility
	case "BeInvisible":	MyPawn.SetInvisibility(true);	break;
	case "BeVisible":	MyPawn.SetInvisibility(false);	break;
// set the actor collisionnability
	case "ColOn": case "CollisionOn": MyPawn.CollisionActivity(true); break;
	case "ColOff": case "CollisionOff": MyPawn.CollisionActivity(false); break;
	case "ColHeight":
		fTemp=float(GetFirstWord(Argument));
		Pawn.PrePivot.Z+= Pawn.CollisionHeight-fTemp;
		Pawn.SetLocation(Pawn.Location-(Pawn.CollisionHeight-fTemp)*vect(0,0,1));
		Pawn.SetCollisionSize( Pawn.CollisionRadius, fTemp );
		break;
	case "PeerAt":
		MyPawn.PeeredActor=FindAnActor(GetFirstWord(Argument));
		break;
// impose a focus on this actor
	case "LookAtNR":
		Pawn.RotationRate.Yaw = rotationspeed * 182;
		LockedActor=none;
		Focus=FindAnActor(GetFirstWord(Argument));
		if (Focus==self)
			Focus=none;
		break;
	case "LookAt":
		Pawn.RotationRate.Yaw = rotationspeed * 182;
		LockedActor=none;
		Focus=FindAnActor(GetFirstWord(Argument));
		bCineControlAnims=false;
		if (Focus==self)
			Focus=none;
		break;
// start/stop a move sequence (parallel process)
	case "MovSeq":	MoveSequence=Argument;	NextMove(); break;
	case "MovSeqB":	MoveSequence=Argument;	NextMove(); flagsPaused=flagsPaused | WT_SequenceEnd;	break;
	case "StopSeq":	StopMove();				break;
	case "ResumeSeq":	ResumeMove();	break;
	case "PauseSeq":	PauseMove();	break;

	//case "Mesh":	Mesh=Mesh(Name(GetFirstWord(Argument))); break;

// warn a Cine2 actor
	case "Warn":
		while (Argument!="")
			WarnActor(FindAnActor(GetFirstWord(Argument)));
		break;

// Script waits before moving to next action
	case "On":
		switch(GetFirstWord(Argument))
		{
		case "Player":
			if (CharIsNum(Argument))
				SetCollisionSize(float(GetFirstWord(Argument)),Pawn.CollisionHeight);
			if (vSize(Pawn.Location-PC.Pawn.Location)>CollisionRadius)
			{
//				SetLocation(Pawn.Location);
				SetCollision(true,false,false);
//				flagsPaused=flagsPaused | WT_PlayerProximity;
				if (CharIsNum(Argument))
					nOnJump[ON_PlayerProximity]=int(GetFirstWord(Argument));
				else
					nOnJump[ON_PlayerProximity]=FindLabel(GetFirstWord(Argument));
			}
			else
			{
				// Already near player
				if (CharIsNum(Argument))
					ScriptedActionIndex=int(GetFirstWord(Argument))-1;
				else
					ScriptedActionIndex=FindLabel(GetFirstWord(Argument))-1;
			}

			break;
		case "PlayerAway":
			if (CharIsNum(Argument))
				SetCollisionSize(float(GetFirstWord(Argument)),Pawn.CollisionHeight);
			if (vSize(Pawn.Location-PC.Pawn.Location)<CollisionRadius)
			{
//				SetLocation(Pawn.Location);
				SetCollision(true,false,false);
//				flagsPaused=flagsPaused | WT_PlayerProximity;
				if (CharIsNum(Argument))
					nOnJump[ON_PlayerAway]=int(GetFirstWord(Argument));
				else
					nOnJump[ON_PlayerAway]=FindLabel(GetFirstWord(Argument));
			}
			else
			{
				// Already near player
				if (CharIsNum(Argument))
					ScriptedActionIndex=int(GetFirstWord(Argument))-1;
				else
					ScriptedActionIndex=FindLabel(GetFirstWord(Argument))-1;
			}

			break;
		case "Event":
			Tag = Name(GetFirstWord(Argument));
			if (CharIsNum(Argument))
				nOnJump[ON_Event]=int(GetFirstWord(Argument));
			else
				nOnJump[ON_Event]=FindLabel(GetFirstWord(Argument));
			RestoreEvents( );
			break;
		case "Warning":
			if (CharIsNum(Argument))
				nOnJump[ON_Warning]=int(GetFirstWord(Argument));
			else
				nOnJump[ON_Warning]=FindLabel(GetFirstWord(Argument));
			break;
		case "SeePlayer":
			if (CharIsNum(Argument))
				nOnJump[ON_SeePlayer]=int(GetFirstWord(Argument));
			else
				nOnJump[ON_SeePlayer]=FindLabel(GetFirstWord(Argument));
			break;
		case "SeenByPlayer":
			if (CharIsNum(Argument))
				nOnJump[ON_SeenByPlayer]=int(GetFirstWord(Argument));
			else
				nOnJump[ON_SeenByPlayer]=FindLabel(GetFirstWord(Argument));
			break;
		case "NotSeenByPlayer":
			if (CharIsNum(Argument))
				nOnJump[ON_NotSeenByPlayer]=int(GetFirstWord(Argument));
			else
				nOnJump[ON_NotSeenByPlayer]=FindLabel(GetFirstWord(Argument));
			break;
		case "SeeCadaver":
			if (CharIsNum(Argument))
				nOnJump[ON_SeeCadaver]=int(GetFirstWord(Argument));
			else
				nOnJump[ON_SeeCadaver]=FindLabel(GetFirstWord(Argument));
			break;
		case "Time":
			if (CharIsNum(Argument))
				nOnJump[ON_Time]=int(GetFirstWord(Argument));
			else
				nOnJump[ON_Time]=FindLabel(GetFirstWord(Argument));
			break;
		}
		break;
	case "return":
		if ( nReturnIndexIndex != 0 )
		{
			nReturnIndexIndex--;
			ScriptedActionIndex=nReturnIndex[nReturnIndexIndex]-1;
		}
		break;
// Script waits before moving to next action
	case "Wait":
		bWait = true;
		while (bWait)
		{
			switch(GetFirstWord(Argument))
			{
			case "Player":
				nOnJump[ON_PlayerProximity]=-1;
				if (CharIsNum(Argument))
				{
					SetCollisionSize(float(GetFirstWord(Argument)),Pawn.CollisionHeight);
//					DebugLog( "WAIT PLAYER"@CollisionRadius );
				}
				vTemp = Pawn.Location-PC.Pawn.Location;
				vTemp.Z = 0;
				if (vSize(vTemp)>CollisionRadius || Abs((Pawn.Location-PC.Pawn.Location).Z)>Pawn.CollisionHeight)
				{
//					SetLocation(Pawn.Location);
					SetCollision(true,false,false);
					flagsPaused=flagsPaused | WT_PlayerProximity;
				}
				else
				{
					bWait=false;
					flagsPaused=0;
				}
				break;
			case "PlayerAway":
				nOnJump[ON_PlayerAway]=-1;
				if (CharIsNum(Argument))
				{
					SetCollisionSize(float(GetFirstWord(Argument)),Pawn.CollisionHeight);
//					DebugLog( "WAIT PLAYERWAIT"@CollisionRadius );
				}
				vTemp = Pawn.Location-PC.Pawn.Location;
				vTemp.Z = 0;
				if (vSize(vTemp)<CollisionRadius && Abs((Pawn.Location-PC.Pawn.Location).Z)<Pawn.CollisionHeight)
				{
//					SetLocation(Pawn.Location);
					SetCollision(true,false,false);
					flagsPaused=flagsPaused | WT_PlayerAway;
				}
				else
				{
					bWait=false;
					flagsPaused=0;
				}
				break;
			case "Event":
				Tag = Name(GetFirstWord(Argument));
				if ( Tag!='')
				{
					nOnJump[ON_Event]=-1;
					flagsPaused=flagsPaused | WT_Event;
				}
				else
					ErrorScript ("Unknown WAIT EVENT argument.",true);
				
				RestoreEvents( );

				break;
			case "Warning":
				nOnJump[ON_Warning]=-1; 
				flagsPaused=flagsPaused | WT_Warn;
//				Log( "CINE2"@self@"Wait warning" );
				break;
			case "EndOfSpeech":
			case "EndOfDial":
				nOnJump[ON_DialEnd]=-1; 
				flagsPaused=flagsPaused | WT_DialEnd;
				break;
			case "EndOfMove":
			case "EndOfSeq":
				if ( bMoving )
				{
					nOnJump[ON_SequenceEnd]=-1; 
					flagsPaused=flagsPaused | WT_SequenceEnd;
				}
				break;
			case "Time":
				nOnJump[ON_Time]=-1; 
				WaitTimeEnd = TimeStamp + float( GetFirstWord( Argument ) );
				flagsPaused=flagsPaused | WT_Time;
				break;
			case "SeePlayer":
				nOnJump[ON_SeePlayer]=-1; 
				flagsPaused=flagsPaused | WT_SeePlayer;
				break;
			case "BeSeenByPlayer":
				nOnJump[ON_SeenByPlayer]=-1; 
				flagsPaused=flagsPaused | WT_SeenByPlayer;
				break;
			case "NotBeSeenByPlayer":
				nOnJump[ON_NotSeenByPlayer]=-1; 
				flagsPaused=flagsPaused | WT_NotSeenByPlayer;
				break;
			case "SeeCadaver":
				nOnJump[ON_SeeCadaver]=-1; 
				flagsPaused=flagsPaused | WT_SeeCadaver;
				break;
			default:
				ErrorScript ("Unknown WAIT argument '"@Argument@"'.",true);
			}
			if (!(GetFirstWord(Argument)~="or"))
			{
				break;
			}
		}
		break;

	case "Music": case "msk":	CinePlayMusic(int(GetFirstWord(Argument)));	break; // Play music
	case "Sound": case "snd":	CinePlaySound(GetFirstWord(Argument),GetFirstWord(Argument));	break; // Play sound
	case "Onomatop": case "ono":	CinePlayVoice(GetFirstWord(Argument),GetFirstWord(Argument));	break; // Play onomatopeia ( voice slider )

	case "Anim":
//		Log(self@"ANIM"@Argument);
		switch(GetFirstWord(Argument))
		{
/*		case "Special":
			nTemp= name( GetFirstWord( Argument ) );
			fTemp= float( GetFirstWord( Argument ) ); if (fTemp==0.0) fTemp=1.0;
			if (Argument=="") fTemp2=MyPawn.TweenTime; else fTemp2= float( GetFirstWord( Argument ) ); 
			Pawn.AnimBlendParams(3,1.0,0,0,'x Spine1');
			Pawn.LoopAnim( nTemp,fTemp,fTemp2,3 );
			break;*/
		case "sperot":
			Pawn.SetBoneRotation(
				name( "x"@GetFirstWord( Argument) ),
				rot(1,0,0)*float(GetFirstWord( Argument))+rot(0,1,0)*float(GetFirstWord( Argument))+rot(0,0,1)*float(GetFirstWord( Argument)),
				,
				1.0 );
			break;
		case "sperotoff":
			Pawn.SetBoneRotation(
				name( "x"@GetFirstWord( Argument) ),
				rot(0,0,0),
				,
				0.0 );
			break;
		case "speinit":
			Pawn.AnimBlendParams(3,0.0,0,0,name( Argument ));
			break;
		case "speloop":
			Pawn.AnimBlendToAlpha(3,1.0,0.5);
			nTemp= name( GetFirstWord( Argument ) );
			fTemp= float( GetFirstWord( Argument ) ); if (fTemp==0.0) fTemp=1.0;
			if (Argument=="") fTemp2=MyPawn.TweenTime; else fTemp2= float( GetFirstWord( Argument ) ); 
			Pawn.LoopAnim( nTemp, fTemp, fTemp2,3 );
			break;
		case "speonce":
			Pawn.AnimBlendToAlpha(3,1.0,0.5);
			nTemp= name( GetFirstWord( Argument ) );
			fTemp= float( GetFirstWord( Argument ) ); if (fTemp==0.0) fTemp=1.0;
			if (Argument=="") fTemp2=MyPawn.TweenTime; else fTemp2= float( GetFirstWord( Argument ) ); 
			Pawn.PlayAnim( nTemp, fTemp, fTemp2,3 );
			flagsPaused=flagsPaused | WT_AnimEnd;
			bSubAnim=true;
			break;
		case "speoncenb":
			Pawn.AnimBlendToAlpha(3,1.0,0.5);
			nTemp= name( GetFirstWord( Argument ) );
			fTemp= float( GetFirstWord( Argument ) ); if (fTemp==0.0) fTemp=1.0;
			if (Argument=="") fTemp2=MyPawn.TweenTime; else fTemp2= float( GetFirstWord( Argument ) ); 
			Pawn.PlayAnim( nTemp, fTemp, fTemp2,3 );
			break;
		case "speoff":
			Pawn.AnimBlendToAlpha(3, 0.0, 0.5);
			break;
		case "tweentime":
			MyPawn.TweenTime= float( GetFirstWord( Argument ) );
			break;

			//			PlayAni( GetFirstWord(Argument) );	flagsPaused=flagsPaused | WT_AnimEnd;	break;
		case "Once":
			flagsPaused=flagsPaused | WT_AnimEnd;
			nTemp= name( GetFirstWord( Argument ) );
			fTemp= float( GetFirstWord( Argument ) ); if (fTemp==0.0) fTemp=1.0;
			if (Argument=="") fTemp2=MyPawn.TweenTime; else fTemp2= float( GetFirstWord( Argument ) ); 
			PlayAni( nTemp, fTemp, fTemp2 );
			break;
		case "OnceNB":
			nTemp= name( GetFirstWord( Argument ) );
			fTemp= float( GetFirstWord( Argument ) ); if (fTemp==0.0) fTemp=1.0;
			if (Argument=="") fTemp2=MyPawn.TweenTime; else fTemp2= float( GetFirstWord( Argument ) ); 
			PlayAni( nTemp, fTemp, fTemp2 );
			break;
		case "Loop":
			nTemp= name( GetFirstWord( Argument ) );
			fTemp= float( GetFirstWord( Argument ) ); if (fTemp==0.0) fTemp=1.0;
			if (Argument=="") fTemp2=MyPawn.TweenTime; else fTemp2= float( GetFirstWord( Argument ) );
//			log (self@"ANIM LOOP"@nTemp);
			LoopAni( nTemp, fTemp, fTemp2 );
			break;
		case "SetWait":	MyPawn.WaitAnim= Name(GetFirstWord(Argument)) ;	break;
		case "SetWalk":	MyPawn.WalkAnim= Name(GetFirstWord(Argument)) ;	break;
		case "SetRun":	MyPawn.RunAnim= Name(GetFirstWord(Argument)) ;	break;
		case "Dev":		flagsPaused=flagsPaused | WT_AnimEnd;	DevAni( GetFirstWord(Argument) );	break;
		default:		ErrorScript ("Unknown PLAYANIM argument '"$Argument$"'.");
		}
		break;

	case "AL":	LoopAni( GetFirstWord(Argument), 1.0, MyPawn.TweenTime );	break; // Anim loop
	case "DD":	DetectionDistance=float(GetFirstWord(Argument));	break; // Set detection distance
	case "AF":	AccelerationFactor=float(GetFirstWord(Argument));	break;
	case "SP":	SetWantedSpeed(float(GetFirstWord(Argument)));		break; // Set linear speed
	case "RS":	SetRotationSpeed(float(GetFirstWord(Argument)));	break; // Set rotation speed
	case "TP": case "TeleportTo":
		TeleportTo(FindAnActor(GetFirstWord(Argument)));
		break;
	case "TPInFrontOf":
// This function is only use in Plage00 so I assume that Actor is always XIII
		GetFirstWord(Argument);
		XIIIGameInfo(Level.Game).MapInfo.XIIIPawn.SetRotation( XIIIGameInfo(Level.Game).MapInfo.XIIIController.Rotation );
		TeleportInFrontOf(XIIIGameInfo(Level.Game).MapInfo.XIIIPawn,int(GetFirstWord(Argument)));
		break;
	case "TurnIntoSoldier": case "TIS":
		MyPawn.ConvertToSoldier();
		Pawn=none;
		MyPawn=none;
		GotoState('','');
		break;
	case "TIAS":
		MyPawn.bTurnIntoAgressiveSoldier=true;
		MyPawn.ConvertToSoldier();
		Pawn=none;
		MyPawn=none;
		GotoState('','');
		break;
	 case "TINAS":
		MyPawn.bTurnIntoAgressiveSoldier=false;
		MyPawn.ConvertToSoldier();
		Pawn=none;
		MyPawn=none;
		GotoState('','');
		break;
	case "Event": case "EV":
		while (Argument!="")
			TriggerEvent( Name(GetFirstWord(Argument)) , self , MyPawn );
		break;
	case "PlayerEvent":
		while (Argument!="")
			TriggerEvent( Name(GetFirstWord(Argument)) , self , PC.Pawn );
		break;
	case "CineEvent":
		while (Argument!="")
			CineEvent( Argument );
		break;
	case "Dial":	if (CharIsNum(Argument))
					{
						if (dm!=none)
						{
							dm.ForceLine(GetFirstWord(Argument));
						}
					}
					else
					{
						StartDialogue(GetFirstWord(Argument),GetFirstWord(Argument));
					}
					break;
	case "DialMan":
					dm = DialogueManager(FindAnActor("DialogueManager"$GetFirstWord(Argument)));

					if (dm!=none)
					{
						if ( dm.IsSpeaking( ) )
							dm.ForceLine(GetFirstWord(Argument));
						else
							dm.StartDialogue(int(GetFirstWord(Argument)));
					}
					break;
	case "StopDial":StopDialogue(GetFirstWord(Argument));
					break;
	case "OpenDoor":
	case "OD":		MyPawn.OpenDoor(XIIIPorte(FindAnActor(GetFirstWord(Argument))));	break;
	case "CloseDoor":
	case "CD":		MyPawn.CloseDoor(XIIIPorte(FindAnActor(GetFirstWord(Argument))));	break;
	case "UnlockDoor":
	case "UD":		MyPawn.UnlockDoor(XIIIPorte(FindAnActor(GetFirstWord(Argument))));	break;
	case "LockDoor":
	case "LD":		MyPawn.LockDoor(XIIIPorte(FindAnActor(GetFirstWord(Argument))));	break;
	case "Leave":	MyPawn.CurrentScript=-1; GotoState('');	break;
	case "Give":	MyPawn.GiveObject( int(GetFirstWord(Argument)), PC.Pawn );	break;
	case "Drop":	MyPawn.DropObject( int(GetFirstWord(Argument)), PC.Pawn );	break;
	case "Take":	/*MyPawn.GiveObject( int(GetFirstWord(Argument)), PC.Pawn );*/	break;
	case "Destroy":	FindAnActor(GetFirstWord(Argument)).Destroy();		break;
	case "ViewFocus":
	case "VF":
		Pawn.RotationRate.Yaw = rotationspeed * 182;
		LockedActor=FindAnActor(GetFirstWord(Argument));
		bCineControlAnims=false;
		break;
	case "Link":	
		FindAnActor(GetFirstWord(Argument)).SetBase( Pawn );
		break;
	case "SetVar":
		Counter[int( GetFirstWord( Argument ) )] = int( GetFirstWord( Argument ) );
		break;
	case "IncVar":
		Counter[int( GetFirstWord( Argument ) )]++;
		break;
	case "IfVarEqual":
		if ( Counter[int( GetFirstWord( Argument ) )] == int( GetFirstWord( Argument ) ) )
		{
			if (CharIsNum(Argument))
					ScriptedActionIndex=int(GetFirstWord(Argument))-1;
				else
					ScriptedActionIndex=FindLabel(GetFirstWord(Argument))-1;
		}
		break;
	case "Attach":	AttachSM(class<SMAttached>(DynamicLoadObject(GetFirstWord(Argument),class'class')));	break;
	case "Detach":	if (MyPawn.mycasm!=none) { MyPawn.mycasm.Destroy();	MyPawn.mycasm=none; } break;
	case "Goto":	if (CharIsNum(Argument))
						ScriptedActionIndex=int(GetFirstWord(Argument))-1;
					else
						ScriptedActionIndex=FindLabel(GetFirstWord(Argument))-1;
					break;
//	case "ShadowScale":Pawn.Shadow.ShadowScale=float(GetFirstWord(Argument));
//					break;
	case "RW": case "ReadyWeapon": MyPawn.ReadyWeapon( int( GetFirstWord( Argument ) ) );	break;
	case "Shoot":
		if (CharIsNum(Argument))
			ShootDispersion = float(GetFirstWord(Argument));
		MyPawn.Shoot( );
		break;
	case "AltShoot":
		if (CharIsNum(Argument))
			ShootDispersion = float(GetFirstWord(Argument));
		MyPawn.AltShoot( );
		break;
	case "StopShoot":
		MyPawn.StopShoot( );
		break;
	case "AdjustZShoot":
		AdjustAiming.Z=float(GetFirstWord(Argument));
		break;
//	case "Crouch": Pawn.ShouldCrouch( true ); break;
//	case "Uncrouch": Pawn.ShouldCrouch( false ); break;
	case "CancelReaction":
		while (Argument!="")
			MyPawn.CancelReaction(int(GetFirstWord(Argument)));
		break;
	case "GameOverType":
		switch( int(GetFirstWord(Argument)) )
		{
		case 0:
			Pawn.GameOver = GO_Never ;
			break;
		case 1:
			Pawn.GameOver = GO_TakeDamageFromPlayer ;
			break;
		case 2:
			Pawn.GameOver = GO_KillByPlayer ;
			break;
		case 3:
			Pawn.GameOver = GO_AnyDeath ;
			break;
		}
		break;

	case "":		break;
	default:		ErrorScript ("Unknown instruction",true);
	}
	++ScriptedActionIndex;
}

FUNCTION InitJump(Actor FallTarget,float deltaZ,float Gamma)
{
	LOCAL vector v;
	LOCAL float zM, d, tf;
	LockedActor=none;
	Focus=none;
	if (Gamma==0) Gamma=950;
	zM=Pawn.Location.Z+deltaZ;

	v.z= sqrt(2.0*Gamma*deltaZ);

	d= 2*Gamma*(zM-FallTarget.Location.Z);

	tf = (v.z + sqrt(d))/Gamma;

	v.x=(FallTarget.Location.X-Pawn.Location.X)/tf;
	v.y=(FallTarget.Location.Y-Pawn.Location.Y)/tf;

	Pawn.AirSpeed=vSize(v);
	Pawn.SetPhysics(PHYS_Falling);
	Pawn.Velocity=v;
	Pawn.Acceleration=-Gamma*vect(0,0,1);
	WaitTimeEnd=tf;
	MyPawn.StopShoot();
}

FUNCTION GoFall(Actor FallTarget,float deltaZ,float Gamma)
{
	InitJump( FallTarget, deltaZ, Gamma );
	GotoState('STA_Falling');
}

STATE Idle
{
	EVENT Timer()
	{
		LOCAL float fTemp;

		Pawn.SetPhysics(PHYS_Falling);

		bControlAnimations=false;
		Pawn.SetCollision(true,true,true);
		Pawn.bCollideWorld=true;
		if (Pawn.Event!='')
			TriggerEvent(Pawn.Event,self,pawn);
		bDying=true;
		Pawn.AnimBlendParams(15,0.0,0,0,'X');
		Pawn.AnimBlendToAlpha(15,1.0,0.0);
		PlayAni( 'DeathFalaiseFin', 1.0, MyPawn.TweenTime, 15 );
		Pawn.bIsDead = true;
		TriggerEvent(Event, self, none);
		MyPawn.ReduceMyCylinder();
		Pawn.GotoState('Dying');
		Destroy();
	}
	EVENT AnimEnd( int Channel )
	{
		if ( bDying && Channel==15 )
		{
			MyPawn.ReduceMyCylinder();
			MyPawn.TakeDamage( 2000, MyPawn, MyPawn.Location, vect(0,0,0), Class'XIII.DTSureStunned'/*class<DamageType> damageType*/);	
			return;
		}
	}
	EVENT BeginState()
	{
		SetTimer(WaitTimeEnd,false);
	}
}

STATE STA_Falling extends Idle
{
	EVENT AnimEnd( int Channel )
	{
	}
}

/* ############################################################################################################### */

FUNCTION GoJump(Actor JTarget,float deltaZ)
{
	JumpTarget=JTarget;
	JumpHight=deltaZ;
	GotoState('STA_Jumping_Impetus');
}

STATE STA_Jumping_Impetus
{
	EVENT BeginState()
	{
		InitJump( JumpTarget, JumpHight, 950 );
		SetTimer(WaitTimeEnd,false);
		Pawn.AnimBlendToAlpha( 15, 1.0, 0.25 );
//		PlayAni( 'JumpUp', 1.0, 0.3 );
		PlayAni( 'JumpAir', 1.0, 0.3 );
//		Log(Level.TimeSeconds@GetStateName()@"BeginState()");
	}
/*	EVENT AnimEnd( int Channel )
	{
		Log(Level.TimeSeconds@GetStateName()@"AnimEnd("@Channel@")");
		GotoState('STA_Jumping_Up');
	}
}

STATE STA_Jumping_Up
{
	EVENT BeginState()
	{
		PlayAni( 'Jump', 1.0, 0.3 );
		Log(Level.TimeSeconds@GetStateName()@"BeginState()");
	}
	EVENT Tick( float dt )
	{
		if ( Pawn.Velocity.Z<0 )
			GotoState('STA_Jumping_Down');
	}
	EVENT Timer()
	{
	}
	EVENT AnimEnd( int Channel )
	{
		Log(GetStateName()@"AnimEnd("@Channel@")");
	}
}

STATE STA_Jumping_Down
{
	EVENT BeginState()
	{
		PlayAni( 'JumpDown', 1.0, 0.3 );
		Log(Level.TimeSeconds@GetStateName()@"BeginState()");
	}*/
	EVENT Tick( float dt )
	{
		if ( Pawn.Velocity.Z==0 )
		{
			LoopAni( MyPawn.WaitAnim, 1.0, 0.5 );
			FocalPoint=MyPawn.Location+51200*vector(MyPawn.Rotation);
			GotoState('PlayingSequence');
		}
	}


}

/* ############################################################################################################### */

FUNCTION AttachSM(class<SMAttached> sm)
{
	if (sm!=none)
	{
		MyPawn.mycasm=Spawn(sm,Pawn);
		MyPawn.mycasm.AttachTo(Pawn);
	}
}

FUNCTION bool NextMove()
{
	LOCAL String Func,Arg;

//	LOG( self@"NEXTMOVE '"$MoveSequence$"' at"@Level.TimeSeconds );
	while (true)
	{
		Func = GetFirstWord( MoveSequence );
		Arg = GetFirstWord( MoveSequence );
		switch( Func )
		{
// Walk or Run
		case "W": case "R":
//			LOG( self @ Func @ Arg @ Level.TimeSeconds );
			NextTarget=SearchNextWaypoint();
			CineMoveTo( FindAnActor(Arg) );
			return true;
 // Move
		case "M":
//			LOG( self @ Func @ Arg @ Level.TimeSeconds );
			NextTarget=SearchNextWaypoint();
			CineMoveTo(FindAnActor(Arg),true);
			return true;
		case "J":
//			LOG( self @ Func @ Arg @ Level.TimeSeconds );
			Target=FindAnActor(Arg);
			NextTarget=SearchNextWaypoint();
			GoJump(Target,JumpHeight);
		
			bCineControlAnims=false;

			if (Target!=none)
			{
//				if ( Pawn.Physics == PHYS_None )
//					Pawn.SetPhysics( PHYS_Walking ); // Walk physics is default
				Plane=Normal(Target.Location-Pawn.Location);
				bMoving=true;
			}

			return true;
		case "":
			if (!bCineControlAnims)
				LoopAni( MyPawn.WaitAnim, 1.0, MyPawn.TweenTime );
			return false;

		case "SP":	SetWantedSpeed(float(Arg));	break; // Set speed
		case "RS":	SetRotationSpeed(float(Arg)); break; // Set rotationspeed
		case "EV":	TriggerEvent( Name(Arg) , self , MyPawn );	break;
		case "OD":	MyPawn.OpenDoor(XIIIPorte(FindAnActor(Arg)));	break;
		case "CD":	MyPawn.CloseDoor(XIIIPorte(FindAnActor(Arg)));	break;
		case "LD":	MyPawn.LockDoor(XIIIPorte(FindAnActor(Arg)));	break;
		case "UD":	MyPawn.UnlockDoor(XIIIPorte(FindAnActor(Arg)));	break;
		case "WARN":WarnActor(Cine2(FindAnActor(Arg)));	break;
		case "DD":	DetectionDistance=float(Arg);	break;
		case "AF":	AccelerationFactor=float(Arg);	break;
		case "AL":	LoopAni( name(Arg), 1.0, MyPawn.TweenTime );	break;
		case "TP":	TeleportTo(FindAnActor(Arg));	break;
		case "VF":	LockedActor=FindAnActor(Arg);	break;
		case "FS":	Pawn.Velocity = float(Arg)*Vector(Pawn.Rotation); break;
		case "msk":	CinePlayMusic(int(Arg));	break; // Play music
		case "snd":	CinePlaySound(Arg,"");	break; // Play sound
		case "ono":	CinePlayVoice(Arg,"");	break; // Play onomatopeia ( voice slider )
		case "JH":	JumpHeight=float(Arg); break;

		default:	ErrorScript("Unknown function '"$Func$"' in move sequence",true);
					return false;
		}
	}
	
}

FUNCTION actor SearchNextWaypoint()
{
	LOCAL String Func,Arg,MovSeq;

	MovSeq=MoveSequence;

	while (true) 
	{
// Found next waypoint
		Func=GetFirstWord(MovSeq);
		Arg=GetFirstWord(MovSeq);
		switch(Func)
		{
		case "": return none;
		case "M":
		case "W":
		case "R":
		case "J":
			return FindAnActor(Arg);
		}
	}
}



defaultproperties
{
     bCineControlAnims=True
     JumpHeight=80.000000
     bControlAnimations=True
     InitialState="STA_init"
     CollisionRadius=250.000000
}
