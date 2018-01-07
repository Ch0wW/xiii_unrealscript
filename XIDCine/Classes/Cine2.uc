//-=-=-=-=-=-=-=-=-=-=-=-
// Cine2 Created by iKi
//-=-=-=-=-=-=-=-=-=-=-=-
class Cine2 extends BaseSoldier
	HideCategories(AnimTweaks, Force, LightColor, Lightning)
	placeable
	native;

ENUM ECineStimulus
{
	CS_None, CS_SeeCadaver, CS_Trigger, CS_SeePlayer, CS_TakeDamage, CS_MapStart,
	CS_HearNoise, CS_OutOfOrder_PlayerMove, CS_OutOfOrder_SeenByPlayer
};

STRUCT StructReaction
{
	VAR()	ECineStimulus	eCS_Stimulus;
	VAR()	int				TabActionIndex; // 0 or 1 : tabActions, 2 : tabActions2, etc...
	VAR()	bool			bUneSeuleFois, bInterruptive;
};

STRUCT StructSave
{
	VAR()	Actor Position;
	VAR()	Actor Target;
	VAR()	int tabAction;
	VAR()	string Label;
};

VAR(Cine_Save)	Array<StructSave>		CheckPoints;

VAR(Cine_Anim)	name					DefaultAnim, WalkAnim, RunAnim, WaitAnim;
VAR(Cine_Anim)	Array<MeshAnimation>	SpecificAnimations;
VAR(Cine_Anim)	float					TweenTime;
VAR(Cine_Anim)	float					WalkAnimVelocity, WalkRunLimitVelocity, RunAnimVelocity;

VAR(Cine_Script)	Array<StructReaction>	Reaction;
VAR(Cine_Script)	Array<string>			tabActions, tabActions2, tabActions3;

VAR(Cine_Sound)		Array<Sound>	Musics, Sounds, Onomatops;

VAR(Cine_Misc)		Array< class<SMAttached> >	AttachedArtefacts;
VAR(Cine_Shoot)		float	InitialShootDispersion;
VAR(Cine_Movement)	float	InitialSpeed,InitialRotationSpeed,InitialAccelerationFactor,InitialDetectionDistance;
VAR(Cine_Movement)	vector	vMoveconstraint;
//VAR(Cine_Movement)	bool	bUseRotationAnimations;

VAR			class<CineController2>	CineControllerClass;

VAR			int						CurrentScript;

VAR TRANSIENT	MapInfo				mi;

// boolean variables
VAR(Cine_Movement)	bool	bPauseMovementIfBumped, ImposedEndMovePosition;
VAR(Cine_Misc)		bool	Invisible, bBlindWhenInvisible, bDeafWhenInvisible;
VAR(Cine_Shoot)		bool	bArmed;
VAR					bool	bPaused, MemoColActors, MemoBlockActors, MemoBlockPlayers, bBlinking, bInitialized;
VAR					int		cpn; // CheckPointNumber

VAR TRANSIENT	CineController2			CineController;
VAR TRANSIENT	Canvas					MyCanvas;
VAR TRANSIENT	float					MyYL, MyYPos, BlinkEndTime;
VAR TRANSIENT	XIIIPlayerController	PC;
VAR TRANSIENT	int						CurrentTabActionIndex, MyOldRotYaw, HeadYaw;
VAR TRANSIENT	actor					BumpedActor, PeeredActor;
//VAR TRANSIENT	DialogueManager			MyDialogueManager;
VAR TRANSIENT	SMAttached				mycasm;

native FUNCTION OnTheSpotRotation( /*float dt*/ );

FUNCTION Died(Controller Killer, class<DamageType> damageType, vector HitLocCode)
{
	LOCAL xiiigameinfo gameinf;
	LOCAL int i;

	ReleaseAnimControl();

	if ( class<XIIIDamageType>(damageType).default.bDieInSilencePlease )
		PlaySndDeathOno(deathono'Onomatopees.hPNJDeath2',CodeMesh,NumeroTimbre);
	else
		//PlaySndDeathOno(deathono'Onomatopees.hPNJDeath1',CodeMesh,NumeroTimbre)
        ;

	if (Controller!=none && Controller.IsA('IAController'))
	{
		gameinf=xiiigameinfo(level.game);
		switch (IAController(controller).NiveauALerte)
		{
		case 0:
			level.decattente();
			// Iacontroller(controller).genalerte.nbattente--;
			//log("decattente "$Iacontroller(controller).genalerte.nbattente@Iacontroller(controller).genalerte.nbalerte@Iacontroller(controller).genalerte.nbattaque);
			break;
		case 1:
			level.decAlerte();
			// Iacontroller(controller).genalerte.nbalerte--;
			// log("decalerte "$Iacontroller(controller).genalerte.nbattente@Iacontroller(controller).genalerte.nbalerte@Iacontroller(controller).genalerte.nbattaque);
			break;
		case 2:
			level.decAttaque();
			//Iacontroller(controller).genalerte.nbattaque--;
			//log("decattaque "$Iacontroller(controller).genalerte.nbattente@Iacontroller(controller).genalerte.nbalerte@Iacontroller(controller).genalerte.nbattaque);
			break;
		}
		//suprresion de la liste des basesoldiers
		for (i = 0; i < gameinf.BaseSoldierList.Length; i++)
		{
			if (gameinf.BaseSoldierList[i] == self )
			{
				gameinf.BaseSoldierList.Remove(i,1);
				break;
			}
		}
		controller.gotostate('mort');
	}
	Super(XIIIPAwn).Died( Killer, damageType, HitLocCode);
}

function RenderOverlays(Canvas Canvas)
{
	LOCAL HUD h;
	LOCAL Vector Start, End;

	h=mi.XIIIController.MyHud;

	if ( CineController!=none)
	{
		if ( CineController.Target!=none)
		{
			h.Draw3DLine( Location, CineController.Target.Location, class'Canvas'.Static.MakeColor(255,255,255));
			if ( CineController.NextTarget!=none)
				h.Draw3DLine( CineController.Target.Location, CineController.Target.Location , class'Canvas'.Static.MakeColor(255,0,255));

		}
		if ( CineController.Focus!=none)
			h.Draw3DLine( Location, CineController.Focus.Location, class'Canvas'.Static.MakeColor(255,0,0));
		else
			h.Draw3DLine( Location, CineController.FocalPoint, class'Canvas'.Static.MakeColor(255,128,128));

		if ( Weapon!=none && CineController.LockedActor!=none )
		{
			Start = Location + EyePosition() + ( Weapon.FireOffset >> GetViewRotation( ) );
			End = CineController.LockedActor.Location + CineController.AdjustAiming;
			h.Draw3DLine( Start, End, class'Canvas'.Static.MakeColor(255,128,0));
		}
	}
}

EVENT SetInitialState( )
{
	MemoColActors =		bCollideActors;
	MemoBlockActors =	bBlockActors;
	MemoBlockPlayers =	bBlockPlayers;

	bScriptInitialized = true;
	MyOldRotYaw = Rotation.Yaw;
//	AnimBlendParams( 2, 0.0, 0.0, 0.0, 'X R THIGH' );
//	AnimBlendParams( 3, 0.0, 0.0, 0.0, 'X L THIGH' );
	AnimBlendParams( 2, 0.0, 0.0, 0.0, 'X PELVIS' );
	AnimBlendParams( 3, 0.0, 0.0, 0.0, 'X PELVIS' );

	GotoState( 'CineInit' );
}

FUNCTION Play( ECineStimulus CS_Key )
{
	LOCAL int i;

	if ( !bInitialized )
		return;

	for (i=0;i<Reaction.Length;++i)
	{
		if  (
				( ( CurrentScript == -1 ) || ( ( Reaction[ i ].bInterruptive ) && ( i >= CurrentScript ) ) )
			&&
				( Reaction[ i ].eCS_Stimulus == CS_Key )
			)
		{
// Interrupt previous script if there is one: TODO save current script context
			if ( CurrentScript != -1 )
				CineController.StopMove();
			CurrentScript=i;

// Start my cine controller sequence
			CurrentTabActionIndex = Reaction[ i ].TabActionIndex;

			if ( CurrentTabActionIndex == -1)
			{
/*::iKi::=>*/
/*				switch ( CS_Key )
				{
				case CS_None:
					LOG ("TIS CS_None");
					break;
				case CS_SeeCadaver:
					LOG ("TIS CS_SeeCadaver");
					break;
				case CS_Trigger:
					LOG ("TIS CS_Trigger");
					break;
				case CS_SeePlayer:
					LOG ("TIS CS_SeePlayer");
					break;
				case CS_TakeDamage:
					LOG ("TIS CS_TakeDamage");
					break;
				case CS_MapStart:
					LOG ("TIS CS_MapStart");
					break;
				case CS_HearNoise:
					LOG ("TIS CS_HearNoise");
					break;
				case CS_OutOfOrder_PlayerMove:
					LOG ("TIS CS_OutOfOrder_PlayerMove");
					break;
				case CS_OutOfOrder_SeenByPlayer:
					LOG ("TIS CS_OutOfOrder_SeenByPlayer");
					break;
				}
*/
/*<=::iKi::*/
				ConvertToSoldier( );
			}
			else if ( CurrentTabActionIndex < 4 )
			{
//				LOG( self@"PLAY REACTION n°"$i@", STIMULUS CODE :"@CS_Key @", TabAction :"@Reaction[ i ].TabActionIndex);
				if ( Reaction[ i ].bUneSeuleFois )
					Reaction[ i ].eCS_Stimulus = CS_None;
				CineController.StartSequence( );
			}

		}
	}
}

FUNCTION CancelReaction(int i)
{
	if ( i>=0 && i<Reaction.Length )
		Reaction[ i ].eCS_Stimulus = CS_None;
}

FUNCTION int GetTabActionLength()
{
	switch (CurrentTabActionIndex)
	{
	case 0: case 1:
		return tabActions.Length;
	case 2:
		return tabActions2.Length;
	case 3:
		return tabActions3.Length;
	}
	return 0;
}

FUNCTION bool GetAction(int i,out string str)
{
	if (CurrentTabActionIndex==0 || CurrentTabActionIndex==1)
	{
		if (i<tabActions.Length)	{	str=tabActions[i];	return true;	}
		else return false;
	}
	else if (CurrentTabActionIndex==2)
	{
		if (i<tabActions2.Length)	{	str=tabActions2[i];	return true;	}
		else	return false;
	}
	else if (CurrentTabActionIndex==3)
	{
		if (i<tabActions3.Length)	{	str=tabActions3[i];	return true;	}
		else	return false;
	}
}

FUNCTION HearSound() {}
FUNCTION SeeXIII()	{}
FUNCTION SeeCadaver() { }

FUNCTION SetInvisibility(bool B)
{
	bHidden = B;
	Invisible = B;
	if (B)
	{
		Visibility = 0;
		SetCollision( false, false, false );
		Velocity = vect( 0, 0, 0 );
		Acceleration = vect( 0, 0, 0 );
	}
	else
	{
		Visibility = Default.Visibility;
		SetCollision( MemoColActors, MemoBlockActors, MemoBlockPlayers );
		bBlockActors = MemoBlockActors;
	}
	RefreshDisplaying( );
}

FUNCTION CollisionActivity(bool B)
{
	bCollideWorld=B;
	if (B)
		SetCollision(MemoColActors,MemoBlockActors,MemoBlockPlayers);
	else
		SetCollision(false,false,false);
}

FUNCTION InitCheckPoint()
{
	cpn=XIIIGameInfo(Level.Game).CheckPointNumber-2;
//	LOG ( self@"("$PawnName$") -> CHECKPOINT NUMBER"@cpn );
	if ( cpn>=0 && cpn<CheckPoints.Length)
	{
//		LOG ( self@"LOADING CHECKPOINT"@cpn );

		if ( CheckPoints[cpn].Position!=none )
			SetLocation( CheckPoints[cpn].Position.Location );
		if ( CheckPoints[cpn].Target!=none )
		{
			SetRotation( ROTATOR( CheckPoints[cpn].Target.Location - Location ) );
			CineController.SetRotation( rotation ) ;
		}
	}
	else
	{
		cpn=-1;
//		LOG ( self@"FAILS TO LOAD CHECKPOINT"@cpn );
	}
}

// ################################################################################################################
AUTO STATE CineInit
{
	EVENT BeginState()
	{
		if ( Mesh!=none )
		{
			AnimBlendParams( 1, 0.0, 0.0, 0.0, 'X' );
			SetTimer(0.033,true);
		}
//		else
//		{
//			Disable('Tick');
//			return;
//		}
//		SetCollision( true, true, false );
	}

	EVENT EndState( )
	{
		SetTimer(0,false);
	}

	EVENT Tick( float dT )
	{
		LOCAL VECTOR vTemp;

		if ( !MemoBlockPlayers && !Invisible && PC!=none && PC.Pawn!=none )
		{
			vTemp= PC.Pawn.Location-Location;
			vTemp.Z= 0;
			bHidden = (vSize( vTemp )<24) && !bIsDead;
			RefreshDisplaying();
		}

		Super.Tick( dt );
	}

	EVENT Timer()
	{
		LOCAL Rotator rl, r;
		LOCAL int n;

		if ( bIsDead )
		{
			SetBoneScalePerAxis( 16, 1, , , 'x BLINK' );
			SetBoneRotation('X HEAD',rl,,0.0);
			SetTimer( 0.0, false );
			return;
		}
		if ( !bHidden )
		{
			if ( bBlinking )
			{
				if ( Level.TimeSeconds > BlinkEndTime )
				{
					SetBoneScalePerAxis( 16, 1, , , 'x BLINK' );
					bBlinking = false;
					BlinkEndTime = Level.TimeSeconds + 1 + 4*FRand( );
				}
			}
			else
			{
				if ( Level.TimeSeconds > BlinkEndTime )
				{
					SetBoneScalePerAxis( 16, 0, , , 'x BLINK' );
					bBlinking = true;
					BlinkEndTime = Level.TimeSeconds + 0.10 + 0.10*FRand( );
				}
			}

			if ( PeeredActor!=none )
			{
				rl=rotator(PeeredActor.Location-Location)-Rotation;

				n=rl.Yaw;//-16384;
				n=((n+32768)&65535)-32768;

				if ((15000>n) && (n>-15000))
				{
					HeadYaw = HeadYaw*0.9+0.1*n;
					rl.Yaw=0;
					rl.Pitch=0;
					rl.Roll=HeadYaw;
					SetBoneRotation('X HEAD',rl,,0.75);
				}
				else
				{
					HeadYaw = HeadYaw*0.98;
					rl.Yaw=0;
					rl.Pitch=0;
					rl.Roll= HeadYaw;
					SetBoneRotation('X HEAD',rl,,0.75);
				}
			}
			else
			{
				if ( HeadYaw!=0 )
				{
					HeadYaw = HeadYaw*0.98;
					if ( HeadYaw > 100 )
					{
						rl.Yaw=0;
						rl.Pitch=0;
						rl.Roll= HeadYaw;
						SetBoneRotation('X HEAD',rl,,0.75);
					}
					else
					{
						HeadYaw=0;
						rl.Yaw=0;
						rl.Pitch=0;
						rl.Roll= 0;
						SetBoneRotation('X HEAD',rl,,0.0);
					}
				}
			}
		}

	}
	EVENT Trigger( actor Other, pawn EventInstigator )
	{
		Play(CS_Trigger);
	}

	FUNCTION SeeXIII( )
	{
		if ( !bBlindWhenInvisible || !Invisible )
		Play(CS_SeePlayer);
	}

	FUNCTION SeeCadaver( )
	{
//		Log("CINEINIT::SeeCadaver");
		if ( !bBlindWhenInvisible || !Invisible )
			Play(CS_SeeCadaver);
	}

	EVENT Bump(Actor Other)
	{
		if (bPauseMovementIfBumped && CineController.bMoving && (Pawn(Other)!=none && Pawn(Other).IsPlayerPawn()) && !CineController.bMovePaused && ((Velocity dot (Other.Location-Location))>0))
		{
			CineController.PauseMovement();
		}
		BumpedActor=Other;
	}

	FUNCTION HearSound()
	{
		if ( !bDeafWhenInvisible || !Invisible )
			Play(CS_HearNoise);
	}

	EVENT TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
	{
		LOCAL bool bKilled;

		if (!CineController.bDying)
		{
			if ( !bHidden )
				Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
			if ( Health<=0 )
			{
				CineController.Pawn=none;
				CineController.MyPawn=none;
				CineController.GotoState('','');
			}
		}

		bKilled = (Health<=0) && ((DamageType != class'DTFisted') && (DamageType != class'DTCouDCross') && (DamageType != class'DTStunned') && (DamageType != class'DTSureStunned') && (DamageType != class'DTDropAfterStun'));

		if ( ( EventInstigator.IsPlayerPawn() && ( (GameOver==GO_TakeDamageFromPlayer) || ( GameOver==GO_KillByPlayer && bKilled ) ) ) || ( GameOver==GO_AnyDeath && bKilled ) )
		{
			if ( GameOverGoal>=0)
			{
			    if (GameOverGoal>=90)
				{
					mi.SetGoalComplete(GameOverGoal);
				}
				else
					if ( mi.Objectif[GameOverGoal].bPrimary )
					{
						mi.SetGoalComplete(GameOverGoal);
					}
			}
			else
				Level.Game.EndGame( PC.PlayerReplicationInfo, "GoalIncomplete" );
			return;
		}

		if ( EventInstigator!=self )
		{
			if ( Health>0 )
				Play( CS_TakeDamage );
		}
	}

	EVENT AnimEnd(int Channel){}

	simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
	{
		LOCAL float XL;
		LOCAL int i;

		Canvas.SetPos(4,4);
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.DrawColor.A=128;
		//Canvas.DrawTile( Texture'Engine.ConsoleBK', 400, 348, 0, 0, 8, 8 );

		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.StrLen("TEST", XL, YL);
		Canvas.SetPos(4,YPos);

		MyCanvas=Canvas;
		MyYL=YL;
		MyYPos=YPos;

		if ( bDeleteMe )
			PrintC("#R"$GetItemName(string(self))$" #YDELETED");
		else
			PrintC("#R"$GetItemName(string(self)));

		PrintC("#WName #Y"$Name$" #WControllerName #Y"$Controller.Name$" #WPawnname #Y"$PawnName);
		PrintC("#WTag #Y"$Tag$" #WState #Y"$GetStateName());
		PrintC("#WLocation #Y"$Location$" #WRotation #Y"$Rotation);
		PrintC("#WMoveSequence #Y"$CineController.MoveSequence);
		PrintC("#RCONTROLLER");
		PrintC("#WRotation #Y"$Controller.Rotation$" #WRotationSpeed #Y"$CineController.RotationSpeed);
		PrintC("#WFocus #Y"$CineController.Focus$" #WLockedActor #Y"$CineController.LockedActor);
		PrintC("#WScriptedActionIndex #Y"$CineController.ScriptedActionIndex);
		PrintC("#WLast Error #Y#N"$CineController.MemoError);

		YPos=MyYPos;
	}
	simulated event ChangeAnimation()
	{
		if (!bIsDead && !bHidden)
			PlayMoving();
	}
	Function PlayMoving()
	{
		LOCAL float fSpeed, TurnRate, StepSize;
		LOCAL bool bTurningRight, bTurningLeft;
		LOCAL float RotYaw;

		StepSize = 0.1; //0.033/0.25; //BlendChangeTime;

		if ( CurrentScript != -1 )
		{
			if ( Velocity!=vect(0,0,0) )
			{
				fSpeed=vSize(Velocity);

				if ( CineController.MyPawnGroundSpeed * CineController.wantedspeed > WalkRunLimitVelocity )
				{
// iKi :: Grrrrrrrr.... foutu bug de m.....
//					if (  SimAnim.AnimRate==0 || SimAnim.AnimSequence!=RunAnim )
						LoopAnim( RunAnim, fSpeed/RunAnimVelocity, 0.5 );
				}
				else
				{
//					if (  SimAnim.AnimRate==0 || SimAnim.AnimSequence!=WalkAnim )
						LoopAnim( WalkAnim, fSpeed/WalkAnimVelocity, 0.5 );
				}
			}
			else
			{
				RotYaw = ( ( Rotation.Yaw - MyOldRotYaw + 32768 ) & 65535 ) - 32768 ;

//				if ( bUseRotationAnimations )
//				{
					TurnRate = RotYaw*30;
					bTurningRight = ( TurnRate > 1000.f );
					bTurningLeft = ( TurnRate < -1000.f );

					if ( TurnRate > 1000.f )
						LoopAnim( 'RotationD', Abs(TurnRate)/10000.f, 0.2 );
					else if ( TurnRate < -1000.f )
						LoopAnim( 'RotationG', Abs(-TurnRate)/10000.f, 0.2 );
					else
						LoopAnim( WaitAnim, , 0.2 );
//				}
			}
		}
//RotationRate.Yaw=182*30;
		MyOldRotYaw = Rotation.Yaw;

	}
	FUNCTION bool ChangeToBestWeapon()
	{
		local float rating;

//		LOG( PawnName@"-> ChangeToBestWeapon at"@Level.TimeSeconds );

		if ( Inventory == None )
			return false;

		PendingWeapon = Inventory.RecommendWeapon(rating);
		if (PendingWeapon == Weapon )
			PendingWeapon = None;
		if (PendingWeapon == None )
			return false;


		if (Weapon == None )
			ChangedWeapon();
		else if ( Weapon != PendingWeapon )
			Weapon.PutDown();
		return true;
	}

	EVENT Destroyed()
	{
		if (CineController!=none)
			CineController.Destroy();
		if ( Shadow!=none )
			Shadow.Destroy();
		super.Destroyed();
	}

	EVENT PlayFootStep()
	{
		LOCAL material M;
		LOCAL actor A;
		LOCAL vector HitLoc, HitNorm;
		LOCAL int MemSoundStepCategory;

		if ( (base == none) || (CineController==none) || !CineController.bMoving )
		{
/*			if (base == none)
				Log( "&&& PlayFootStep"@Self@"BASE==none" );
			if (CineController == none)
				Log( "&&& PlayFootStep"@Self@"CineController==none" );
			if ( !CineController.bMoving )
				LOG ( "&&& PlayFootStep"@Self@"!CineController.bMoving" );*/
			return;
		}

		M = LastCollidedMaterial;

		if (M != none)
		{
			if ( Level.bReplaceHXScripts )
				PlaySndPNJStep(M.PNJSndStep, vsize(velocity), SoundStepCategory, false );
			else
				PlaySound(M.FootstepSound, int(vsize(velocity)), SoundStepCategory, 0 );
			Instigator = self;

			MakeNoise(1.0);
		}
/*		else
			LOG ( "&&& PlayFootStep"@Self@"M == none" );*/

	}

begin:
	do
	{
		sleep(0.03);
		if ( XIIIGameInfo(Level.Game) != none )
		{
			mi = XIIIGameInfo(Level.Game).MapInfo;
			if ( mi!=none )
				PC = mi.XIIIController;
		}
	} until (PC!=none);

	while (CineController==none || !CineController.bInitialized)	{	sleep(0.03);	}

	InitializeInventory();
	if (bArmed)
	{
		ChangeToBestWeapon();
		AnimBlendToAlpha(FIRINGCHANNEL,0.0,0.0);
	}

	InitCheckPoint();

	SetInvisibility(Invisible);

	if ( XIIIGameInfo(Level.Game).CheckPointNumber<2 )
		while ( ! mi.EndCartoonEffect )
			sleep( 0.03 );

	sleep( 0.03 );
	bInitialized = true;

	MyOldRotYaw = Rotation.Yaw;

	if ( XIIIGameInfo(Level.Game).CheckPointNumber<2 )
		Play(CS_MapStart);
	else
		if ( cpn>=0 && CheckPoints[cpn].Label!="")
		{
			CurrentScript=0;
			CurrentTabActionIndex=CheckPoints[cpn].tabAction;
			CineController.bCineControlAnims=false;
//		    LoopAnim(WaitAnim);
			CineController.CineGoto( CheckPoints[cpn].Label );
			CineController.GotoState( 'PrePlayingSequence', 'Begin' );
		}

	if (!bPauseMovementIfBumped)
		stop;


loop:
	if (CineController!=none && CineController.bMovePaused)
	{
		if (((BumpedActor==none) || !Collide(BumpedActor)))// || (Vector(Rotation) dot (BumpedActor.Location-Location)>0))
			CineController.UnPauseMovement();
	}
	sleep(0.20);
	goto('loop');
}

FUNCTION bool Collide(Actor p)
{
	LOCAL vector	v;
	LOCAL float		f;

	v=p.Location-Location;
	f=p.CollisionRadius+CollisionRadius+20;
	f*=f;

	return ((v.X*v.X+v.Y*v.Y)<f);

}

FUNCTION PostBeginPlay()
{
	LOCAL int i;
	LOCAL SMAttached casm;

	Super.PostBeginPlay();

// LOAD SPECIFIC ANIMATIONS
	for (i=0;i<SpecificAnimations.Length;++i)
		LinkSkelAnim ( SpecificAnimations[i] );

    LoopAnim(DefaultAnim);

	if ( (CineControllerClass != None) && (CineController == None) )
		CineController = spawn(CineControllerClass);
	if ( CineController != None )
		CineController.Possess(self);

	Controller = CineController;
	CineController.Pawn=Self;
	CineController.MyPawn=Self;
	CineController.PC=XIIIPlayerController(Level.ControllerList);

	for (i=0;i<AttachedArtefacts.Length;++i)
	{
		if (AttachedArtefacts[i]!=none)
		{
			casm=Spawn(AttachedArtefacts[i]);
			casm.AttachTo(self);
		}
	}
}

FUNCTION ConvertToSoldier()
{
	LOCAL XIIIGameInfo xgi;

	if ( (ControllerClass != None) && !bisdead && (Controller==none || Controller.IsA('CineController2')) )
	{
		if ( bHidden )
		{
			bHidden=false;
			RefreshDisplaying();
//			LOG( self@"TIS SUR UN PERSO INVISIBLE : FORCING DISPLAY !!" );
		}

		SetBoneRotation('X HEAD',rot(0,0,0),,0);

		Controller = spawn(ControllerClass);
		if (Controller!=none)
		{
			Controller.Possess(self);
			if ( CineController != none )
			{
				CineController.Destroy();
			}

			xgi = XIIIGameInfo(Level.Game);
			xgi.BaseSoldierList.Insert( 0, 1 );
			xgi.BaseSoldierList[0] = self;
			bPhysicsAnimUpdate=true;
			GotoState('');
		}
//		else
//			Log(name@"can not be convert to a soldier");
	}
}

FUNCTION OpenDoor(XIIIPorte door)
{
	if (door!=none)
	{
		if (!door.IsInState('PlayerTriggerToggle' ))
		{
			door.GotoState( 'PlayerTriggerToggle' );
		}
		if (!door.bOpened)
		{
			door.PlayerTrigger(self,self);
		}
	}
}

FUNCTION CloseDoor(XIIIPorte door)
{
	if ( door!=none && !door.bClosed )
			door.PlayerTrigger(self,self);
}

static FUNCTION UnlockDoor(XIIIPorte door)
{
	if (door!=none && door.IsInState('Locked' ))
		door.GotoState( 'PlayerTriggerToggle' );
}

static FUNCTION LockDoor(XIIIPorte door)
{
	if (door!=none && door.IsInState('PlayerTriggerToggle' ))
		door.GotoState( 'Locked' );
}

//#################################################################
FUNCTION PrintC(string str)
{
	LOCAL int i;
	LOCAL string buff;

	i=InStr( str, "#" );

	if (i!=-1)
	{
		if (i!=0)
		{
			buff = Left(str, i);
			MyCanvas.DrawText(buff, false);
			MyCanvas.CurY -= MyYL;
		}
		switch(Mid(str, i+1,1))
		{
			Case "W":	MyCanvas.SetDrawColor(255,255,255);	break;
			Case "Y":	MyCanvas.SetDrawColor(255,255,000);	break;
			Case "R":	MyCanvas.SetDrawColor(255,000,000);	break;
			Case "M":	MyCanvas.SetDrawColor(255,000,255);	break;
			Case "C":	MyCanvas.SetDrawColor(000,255,255);	break;
			Case "N":	MyYPos += MyYL;	MyCanvas.SetPos(4,MyYPos);	break;
		}
		PrintC(Mid(str, i+2));
	}
	else
	{
		MyCanvas.DrawText(str);
		MyYPos += MyYL;
		MyCanvas.SetPos(4,MyYPos);
	}
}
//#################################################################

FUNCTION ReadyWeapon( int WeaponIndex )
{
	LOCAL class<XIIIWeapon> WeaponClass;
	LOCAL Inventory inv;

	if ( WeaponIndex >= 0 && WeaponIndex < 8 )
	{
		WeaponClass = class<XIIIWeapon>( InitialInventory[ WeaponIndex ].Inventory );

		if ( WeaponClass!=none )
		{
			inv = FindInventoryType( WeaponClass );

			if ( inv.IsA( 'XIIIWeapon' ) )
			{
				PendingWeapon = XIIIWeapon( inv );

				if ( Weapon!=none )
				{
					if ( Weapon != PendingWeapon )
						Weapon.PutDown( );
				}
				else
				{
					ChangedWeapon( );
				}
			}
		}
	}
	else
	{
		PendingWeapon = XIIIWeapon( FindInventoryType( class'fists' ) );
	    if ( Weapon != PendingWeapon )
		{
			Weapon.PutDown( );
		}
	}
	AnimBlendToAlpha( FIRINGCHANNEL, 0.0, 0.0 );
}

FUNCTION Shoot( )
{
	if ( Weapon!=none )
	{
		Controller.bFire=1;
		Weapon.Fire(0);
	}
}

FUNCTION AltShoot( )
{
	if ( Weapon!=none )
	{
		Controller.bAltFire=1;
		Weapon.AltFire(0);
	}
}

FUNCTION StopShoot( )
{
	if ( Weapon!=none )
	{
		Controller.bAltFire=0;
		Controller.bFire=0;
		AnimBlendToAlpha( FIRINGCHANNEL, 0.0, 0.5 );
	}
}

FUNCTION Inventory GiveObject(int ItemIndex, Pawn P)
{
	LOCAL Inventory NewItem;
	LOCAL class<Inventory> ItemClass;
	LOCAL class<Ammunition> AmmunitionClass;
	LOCAL Inventory inv;

	ItemClass=InitialInventory[ItemIndex].Inventory;

//	log ( "===========================================================" );
//	log ( "ItemClass :"@ItemClass );

	if (ItemClass!=none)
	{
		inv=FindInventoryType(ItemClass);
		if (inv!=none)
		{
			if( P.FindInventoryType(ItemClass)==None )
			{
	/*				if( inv.IsA( 'Weapon' ) )
					{
						NewItem = Spawn(ItemClass,,,P.Location);
						Weapon(NewItem).GiveAmmo(P);
	//					Weapon(NewItem).AmmoType.AmmoAmount = Weapon(Inv).AmmoType.AmmoAmount;
						NewItem.GiveTo(P);
	//					log ( "inv       :"@inv@Weapon(inv).AmmoType@Weapon(inv).AmmoType.AmmoAmount );
	//					log ( "NewItem   :"@NewItem@Weapon(NewItem).AmmoType@Weapon(NewItem).AmmoType.AmmoAmount );
	//					Weapon(NewItem).AmmoType = Weapon(inv).AmmoType;
					}
					else
					{*/
					NewItem = Spawn(ItemClass,,,P.Location);

					if( NewItem != None )
					{
						NewItem.GiveTo(P);
/* ELR NOT OK
						if( inv.IsA( 'Weapon' ) )
						{
							NewItem = Spawn(ItemClass,,,P.Location);
							Weapon(NewItem).GiveAmmo(P);
							if ( Weapon(NewItem).AmmoType!=none && Weapon(Inv).AmmoType!=none )
								Weapon(NewItem).AmmoType.AmmoAmount = Weapon(Inv).AmmoType.AmmoAmount;
						}
   ELR END*/
	  					if ( NewItem.IsA('Weapon') && (Weapon(NewItem).AmmoType!=none) && (Weapon(Inv).AmmoType!=none) )
		    					Weapon(NewItem).AmmoType.AmmoAmount = Weapon(Inv).AmmoType.AmmoAmount;
					}
//				}
			}
			else
			{
				AmmunitionClass = Class<Ammunition>(ItemClass);

				if ( AmmunitionClass != none )
				{
					NewItem = P.FindInventoryType(ItemClass);
					if (NewItem != None)
						Ammunition(NewItem).AmmoAmount += AmmunitionClass.default.AmmoAmount;
				}
			}
			inv.Destroy();	// Destroy my item
		}
//		else
//		{
//			LOG ("Sorry, but I ("$name$") don't have any object of kind '"$ItemClass$"' to give :-/");
//		}
	}
//	log ( "===========================================================" );
	PC.ReceiveLocalizedMessage( NewItem.PickupClass.default.MessageClass, 0, None, None, NewItem.PickupClass );
	return NewItem;
}

FUNCTION Inventory DropObject(int ItemIndex, Pawn P)
{
	LOCAL Inventory NewItem;
	LOCAL class<Inventory> ItemClass;
	LOCAL Inventory inv;

	ItemClass=InitialInventory[ItemIndex].Inventory;

	if (ItemClass!=none)
	{
		inv=FindInventoryType(ItemClass);
		if (inv!=none)
		{
			inv.DropFrom( Location + 20 * Vector( Rotation ) );
		}
//		else
//		{
//			LOG ("Sorry, but I ("$name$") don't have any object of kind '"$ItemClass$"' to drop :-/");
//		}
	}
	PC.ReceiveLocalizedMessage( NewItem.PickupClass.default.MessageClass, 0, None, None, NewItem.PickupClass );
	return NewItem;
}



defaultproperties
{
     DefaultAnim="WaitNeutre"
     WalkAnim="Walk"
     RunAnim="Run"
     WaitAnim="WaitNeutre"
     TweenTime=0.500000
     WalkAnimVelocity=140.000000
     WalkRunLimitVelocity=280.000000
     RunAnimVelocity=472.000000
     Reaction(0)=(eCS_Stimulus=CS_MapStart,TabActionIndex=1,bUneSeuleFois=True)
     InitialShootDispersion=100.000000
     InitialSpeed=0.320000
     InitialRotationSpeed=180.000000
     InitialAccelerationFactor=1.000000
     vMoveconstraint=(X=1.000000,Y=1.000000)
     CineControllerClass=Class'XIDCine.CineController2'
     CurrentScript=-1
     ImposedEndMovePosition=True
     bCanStrafe=True
     bDontPossess=True
     bIsPafable=False
     bCanBeGrabbed=False
     PeripheralVision=0.700000
     GroundSpeed=600.000000
     bPhysicsAnimUpdate=False
     Physics=PHYS_Walking
     RotationRate=(Pitch=0,Yaw=32768,Roll=0)
}
