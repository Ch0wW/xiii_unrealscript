//-----------------------------------------------------------
// BreakableMover
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class BreakableMover extends XIIIMover
	hidecategories(Force,LightColor,Lighting,Mover,Porte,MoverSound);

ENUM E_BreakType	{	BT_Always, BT_TriggerOnly, BT_DamageOnly };

ENUM E_FireType		{	FT_None, FT_DontUseIt1, FT_DontUseIt2, FT_DontUseIt3 };

ENUM E_SmokeType	{	ST_None, ST_DontUseIt1, ST_DontUseIt2, ST_DontUseIt3, ST_DontUseIt4, ST_DontUseIt5 };

ENUM E_OnomatopType	{	OT_None, OT_Baommm, OT_Aahh, OT_Crac, OT_Cling, OT_Blam };

STRUCT C_MeshParticles
{
	VAR() class<Emitter>	Type;
	VAR() Vector			Eparpillement;
	VAR() int				Number;
	VAR() float				ScaleMin;
	VAR() float				ScaleMax;
	VAR() Vector			Offset;
	VAR() StaticMesh		StaticMesh;
	VAR() Vector			Blow;
	VAR() bool				FadeOut;
	VAR() float				FadeOutBegin;
	VAR() float				FadeOutEnd;
};

STRUCT BMState
{
	VAR() int			DamagePercentage;
	VAR() StaticMesh	StateStaticMesh;
	VAR() Texture		StateTexture;
	VAR() Sound			StateSound;
	VAR() name			StateEvent;
};

STRUCT C_FireSprites
{
	VAR() E_FireType							Type;
	VAR() Vector								Dispersal;
	VAR() int									Number;
	VAR() float									ScaleMin;
	VAR() float									ScaleMax;
	VAR() Vector								Offset;
	VAR() ParticleEmitter.EParticleDrawStyle	DrawStyle;
	VAR() float									LifeTime;
	VAR() bool									OneTextureAnimOnly;
	VAR() bool									FadeOut;
	VAR() float									FadeOutBegin;
};

STRUCT C_SmokeSprites
{
	VAR() E_SmokeType							Type;
	VAR() Vector								Dispersal;
	VAR() int									Number;
	VAR() float									ScaleMin;
	VAR() float									ScaleMax;
	VAR() Vector								Offset;
	VAR() ParticleEmitter.EParticleDrawStyle	DrawStyle;
	VAR() float									LifeTime;
	VAR() bool									OneTextureAnimOnly;
	VAR() bool									FadeOut;
	VAR() float									FadeOutBegin;
};

STRUCT C_OnomatopSprites
{
	VAR() E_OnomatopType						Type;
	VAR() Vector								Dispersal;
	VAR() int									Number;
	VAR() float									ScaleMin;
	VAR() float									ScaleMax;
	VAR() Vector								Offset;
	VAR() ParticleEmitter.EParticleDrawStyle	DrawStyle;
	VAR() float									LifeTime;
	VAR() bool									OneTextureAnimOnly;
};

VAR()					bool	CollisionWhenBreaked;
VAR()					bool	ParticlesUseCollision;
VAR()					bool	bMustShakeWhileDelay;
VAR()					bool	bDisperseInBoundingBox;
VAR(BM_Vulnerability)	bool	bVulnerableBladeCut;
VAR(BM_Vulnerability)	bool	bVulnerableGrenade;
VAR(BM_Vulnerability)	bool	bVulnerableGun;
VAR(BM_Vulnerability)	bool	bVulnerableShotgun;
VAR(BM_Vulnerability)	bool	bVulnerableStunning;
VAR(BM_Vulnerability)	bool	bVulnerablePiercing;
VAR(BM_Vulnerability)	bool	bVulnerableToFist;
VAR(Fragments2D)		bool	Fragments_FadeOut;
VAR(Fragments3D)		bool	Fragments3DIgnoreDynLight;
VAR(Fragments3D)		bool	CollisionTime;
VAR						bool	bBreaking;
VAR						bool	bBroken;
VAR						bool	bToBeDestroyed;
VAR(ShakeCamera)		bool	SC_bActive;
VAR(ShakeCamera)		bool	SC_StartAfterBreakingAnim;
VAR						bool	SC_bRunning;
VAR(FlashDazzle)		bool	FD_bActive;
VAR(FlashDazzle)		bool	FD_StartAfterBreakingAnim;
VAR						bool	FD_bRunning;
VAR						bool	bMemoColActors;
VAR						bool	bMemoBlockActors;
VAR						bool	bMemoBlockPlayers;

VAR()					float	DelayDamage;
VAR()					float	DelayTrigger;
VAR()					float	RelativeBlow; // Blow induce from player location
VAR(Fragments2D)		float	Fragments_ScaleMin;
VAR(Fragments2D)		float	Fragments_ScaleMax;
VAR(Fragments2D)		float	Fragments_FadeOutBegin;
VAR(Fragments2D)		float	Fragments_FadeOutEnd;
VAR TRANSIENT			float	DelayToUse;
VAR TRANSIENT			float	TempsContact;
VAR	TRANSIENT			float	TimeStamp;
VAR(ShakeCamera)		float	SC_lifetime;
VAR(ShakeCamera)		float	SC_delay;
VAR(ShakeCamera)		float	SC_intensity;
VAR(ShakeCamera)		float	SC_distance_start;
VAR(ShakeCamera)		float	SC_distance_end;
VAR						float	SC_localintensity;
VAR						float	SC_starttime;
VAR(FlashDazzle)		float	FD_lifetime;
VAR(FlashDazzle)		float	FD_delay; // TODEL : Always be ZERO
VAR(FlashDazzle)		float	FD_intensity;
VAR(FlashDazzle)		float	FD_distance_start;
VAR(FlashDazzle)		float	FD_distance_end;
VAR						float	FD_localintensity;
VAR						float	FD_starttime;

VAR(Fragments2D)		int		FragmentTextureUSubdivisions;
VAR(Fragments2D)		int		FragmentTextureVSubdivisions;
VAR(Fragments2D)		int		Fragments_Number;
VAR(Save)				int		BreakPoint;
VAR(Sound)				int		ExplosiveType; // for SoundWhenBreaked parameter
VAR TRANSIENT			int		InitialHealth;
VAR TRANSIENT			int		LastDamage;

VAR(Fragments2D)		VECTOR	Fragments_Eparpillement;
VAR(Fragments2D)		VECTOR	Fragments_Offset;
VAR(Fragments2D)		VECTOR	Fragments_Blow;
VAR TRANSIENT			VECTOR	particles_speed;
VAR TRANSIENT			VECTOR	Fragment_Center;
VAR						VECTOR	ExplosiveEmitterOffset;
VAR						VECTOR	FD_vectorcolor;

VAR(Fragments2D)		TEXTURE	FragmentTexture;
VAR(Explosif)			TEXTURE	FireTexture;
VAR(Explosif)			TEXTURE	SmokeTexture;
VAR(Explosif)			TEXTURE	OnomatopTexture;
VAR CONST				TEXTURE	OnomatopTextures[6];

VAR()					STATICMESH	BreakedStaticMesh;
VAR						STATICMESH	InitialStaticMesh;

VAR()			E_BreakType	BreakType;
VAR()			Name		BreakedMeshAnim;
VAR(Sound)		Sound		SoundWhenBroken;

VAR(FlashDazzle) color	FD_color;

VAR TRANSIENT	Pawn	Walker;

VAR TRANSIENT	mesh	breakingmesh;

VAR(Fragments2D)	class<Emitter>						Fragments_Type;

VAR(Fragments2D)	ParticleEmitter.EParticleDrawStyle	FragmentDrawStyle;

VAR TRANSIENT		EDrawType							MemoDrawType;

VAR(Fragments3D)	C_MeshParticles Fragments3D;

VAR() array<BMState>	BreakedMiddleStateSM;

VAR(Explosif) C_FireSprites Fire;

VAR(Explosif) C_SmokeSprites Smoke;

VAR(Explosif) C_OnomatopSprites Onomatop;

VAR(Explosif) class<Emitter> ExplosiveEmitter;

VAR() class<XIIIDecoPickup> DecoPickupGenerated;

VAR() class<Emitter>		StruckEmitter;

VAR XIIIPlayerController PC;


replication
{
  reliable if( Role==ROLE_Authority )
    bBroken, Walker, SoundWhenBroken, ExplosiveType;
}

FUNCTION Reset()
{
	if ( bBroken )
	{
		StaticMesh=InitialStaticMesh;
		bHidden=false;
		RefreshDisplaying();
		SetCollision(bMemoColActors,bMemoBlockActors,bMemoBlockPlayers);
		bBroken=false;
		bBreaking=false;
		bToBeDestroyed=false;
	}
}

simulated EVENT Tick(float dt)
{
	LOCAL float time;

	TimeStamp+=dt;

	if ( Level.NetMode == NM_Client )
	{
		if ( bBroken )
		{
			Breaked();
			Disable('Tick');
		}
	}
	else
		if (FD_bRunning)
		{
			time=(TimeStamp-FD_starttime)/FD_lifetime;
			if (time>=0 && time<=1.0)
				PC.ClientInstantFlash( Lerp(time,-FD_localintensity,0), FD_VectorColor);/*vect(1000,1000,1000));*/
			else
			{
				if (time>1)
				{
					if (bToBeDestroyed)
						Destroy();
					FD_bRunning=false;
				}
			}
		}
}

simulated FUNCTION InitDazzleAndShake(bool bBroken)
{
	LOCAL float dist;

	if ( !Level.bLonePlayer )
		return;

	PC=XIIIGameInfo(Level.Game).MapInfo.XIIIController;

	dist=VSize(Location-XIIIGameInfo(Level.Game).MapInfo.XIIIPawn.Location);

	if (FD_bActive && (FD_StartAfterBreakingAnim==bBroken))
	{
		FD_starttime=TimeStamp+FD_delay;

		FD_VectorColor.X=FD_Color.R*3.9;
		FD_VectorColor.Y=FD_Color.G*3.9;
		FD_VectorColor.Z=FD_Color.B*3.9;

		if (dist<FD_distance_start)
		{
			FD_bRunning=true;
			FD_localintensity=FD_intensity;
		}
		else
		{
			if (dist<FD_distance_end)
			{
				FD_localintensity=(FD_distance_end-dist)/(FD_distance_end-FD_distance_start)*FD_intensity;
				FD_bRunning=true;
			}
			else
				FD_bRunning=false;
		}
	}

	if (SC_bActive && (SC_StartAfterBreakingAnim==bBroken))
	{
		if (dist<SC_distance_start)
		{
			SC_bRunning=true;
			SC_localintensity=SC_intensity;
		}
		else
		{
			if (dist<SC_distance_end)
			{
				SC_localintensity=(SC_distance_end-dist)/(SC_distance_end-SC_distance_start)*SC_intensity;
				SC_bRunning=true;
			}
			else
			{
				SC_bRunning=false;
			}
		}
		if (SC_bRunning)
		{
			PC.ShakeView( SC_LifeTime*25.6, SC_localintensity*1600.000000, vect(0,0,30), SC_localintensity*120000, vect(0,0,0), 0) ;
			SC_bRunning=false;
		}

	}

	if (FD_bRunning)
		enable('Tick');
}

//_____________________________________________________________________________
simulated FUNCTION NonDestructiveParticles(vector pos)
{
	LOCAL emitter e;

	if ( StruckEmitter!=none )
		e = SPAWN( StruckEmitter, self, ,pos );
}

FUNCTION MakeGroupReturn()
{
}

EVENT TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	LOCAL int i,stage;

	if ( BreakType == BT_TriggerOnly )
		return;

	Instigator=EventInstigator;

	switch (DamageType)
	{
	case class'DTBladeCut':
		if (!bVulnerableBladeCut)
		{
			NonDestructiveParticles(HitLocation);
			return;
		}
		break;
	case class'DTGrenaded':
		if (!bVulnerableGrenade)
		{
			NonDestructiveParticles(HitLocation);
			return;
		}
		break;
	case class'DTRocketed':
		if (!bVulnerableGrenade)
		{
			NonDestructiveParticles(HitLocation);
			return;
		}
		break;
	case class'DTGunned':
		if (!bVulnerableGun)
		{
			NonDestructiveParticles(HitLocation);
			return;
		}
		break;
	case class'DTShotgunned':
		if (!bVulnerableShotgun)
		{
			NonDestructiveParticles(HitLocation);
			return;
		}
		break;
	case class'DTSniped':
		if (!bVulnerableShotgun)
		{
			NonDestructiveParticles(HitLocation);
			return;
		}
		break;
	case class'DTStunned':
		if (!bVulnerableStunning)
		{
			NonDestructiveParticles(HitLocation);
			return;
		}
		break;
	case class'DTPierced':
		if (!bVulnerablePiercing)
		{
			NonDestructiveParticles(HitLocation);
			return;
		}
		break;
	case class'DTFisted':
		if (!bVulnerableToFist)
		{
			NonDestructiveParticles(HitLocation);
			return;
		}
		break;
	}

	LastDamage = Damage;
	Health -= Damage;

	if ( Health <= 0 )
	{
		Walker=EventInstigator;
//		DebugLog("BreakableMover::TakeDamage Instigator : "$EventInstigator);
		particles_speed=Normal(HitLocation - Walker.Location);

		if (IsA('Explosif') && ((DamageType == class'DTGrenaded')||(DamageType == class'DTRocketed')))
		{
			SetTimer2(fRand()*0.8, false);
		}
		else
		{
			EffectiveTakeDamage();
		}
	}
	else
	{
		stage=-1;
		for (i=0;i<BreakedMiddleStateSM.Length;++i)
		{
			if ( ( BreakedMiddleStateSM[i].DamagePercentage * InitialHealth < ( InitialHealth - Health ) * 100 ) && ( stage==-1 || BreakedMiddleStateSM[stage].DamagePercentage<BreakedMiddleStateSM[i].DamagePercentage) )
				stage=i;
		}
		if ( stage!=-1 )
		{
			if ( BreakedMiddleStateSM[stage].StateStaticMesh!=none )
				StaticMesh = BreakedMiddleStateSM[stage].StateStaticMesh;
			if ( BreakedMiddleStateSM[stage].StateEvent!='' && BreakedMiddleStateSM[stage].StateEvent!='none' )
				TriggerEvent(BreakedMiddleStateSM[stage].StateEvent,self,EventInstigator);
			if ( BreakedMiddleStateSM[stage].StateSound!=none )
				PlaySound( BreakedMiddleStateSM[stage].StateSound );
		}
		NonDestructiveParticles(HitLocation);
	}
}

EVENT Timer2()
{
	EffectiveTakeDamage();
}

SIMULATED FUNCTION bool IsBreakableByPlayer()
{
	return ( BreakType != BT_TriggerOnly );
}

EVENT Bump( actor Other )
{
}

EVENT SetInitialState()
{
//	Dont't touch my state
	bScriptInitialized = true;
	InitialHealth = Health;
	breakingmesh=mesh;
	mesh=none;
	if ( Level.NetMode == NM_Client )
		enable( 'Tick' );
	else
		Disable('Tick');
	Disable('Bump');

	if ( BreakType==BT_DamageOnly )
		Disable('Trigger');
/*
	switch(BreakType)
	{
	case BT_TriggerOnly:
//		Disable('TakeDamage');
		break;
	case BT_DamageOnly:
		Disable('Trigger');
		break;
	}*/
}

EVENT PostBeginPlay()
{
	Super.PostBeginPlay();
	InitialStaticMesh=StaticMesh;
	bMemoColActors = bCollideActors;
	bMemoBlockActors = bBlockActors;
	bMemoBlockPlayers = bBlockPlayers;

	if ( Level.bLonePlayer )
		SetTimer( 0.06, false );
	else
		LOG( self@"POSTBEGINPLAY called" );
}

EVENT Timer( )
{
	if ( (BreakPoint>=0) && (XIIIGameInfo(Level.Game).CheckPointNumber-2>=BreakPoint) )
		FastBreak();
}

FUNCTION EffectiveTakeDamage()
{
	if (((BreakType==BT_Always) || (BreakType==BT_DamageOnly)) && !bBroken)
	{
//		DebugLog("BreakableMover::EffectiveTakeDamage Calling Breaking");
 		Breaking(DelayDamage);
	}
//	else
//		LOG("ERROR : TAKEDAMAGE on a TriggerOnly BreakableMover !!");
}

EVENT Trigger(actor Other, pawn EventInstigator)
{
	if (((BreakType==BreakType) || (BreakType==BT_TriggerOnly)) && !bBroken)
		Breaking(DelayTrigger);
}

SIMULATED FUNCTION ComputeDispersal()
{
	LOCAL Box MyBoundingBox;

	if (bDisperseInBoundingBox)
	{
		MyBoundingBox=GetBoundingBox();
		if ( MyBoundingBox.IsValid!=0)
		{
			Fragment_Center=0.5*(MyBoundingBox.Min+MyBoundingBox.Max);
			Fragments_Eparpillement=0.5*(MyBoundingBox.Max-MyBoundingBox.Min);
			return;
		}
	}
	Fragment_Center=Location;
}

SIMULATED FUNCTION InitializeEmitters()
{
	LOCAL Emitter emit, emit2;
	LOCAL MeshEmitter meshemit;

	if ( Fragments_Type != None )
	{
		if ( Walker!=none)
			emit=Spawn(Fragments_Type,self,,Fragment_Center+Fragments_Offset,Walker.Rotation);
		else
			emit=Spawn(Fragments_Type,self,,Fragment_Center+Fragments_Offset);

		if (emit!=none)
		{
			emit.Emitters[0].StartVelocityRange.X.Min=-100+(3*LastDamage*particles_speed.X)*RelativeBlow+Fragments_Blow.X;
			emit.Emitters[0].StartVelocityRange.X.Max=100+(3*LastDamage*particles_speed.X)*RelativeBlow+Fragments_Blow.X;
			emit.Emitters[0].StartVelocityRange.Y.Min=-100+(3*LastDamage*particles_speed.Y)*RelativeBlow+Fragments_Blow.Y;
			emit.Emitters[0].StartVelocityRange.Y.Max=100+(3*LastDamage*particles_speed.Y)*RelativeBlow+Fragments_Blow.Y;
			emit.Emitters[0].StartVelocityRange.Z.Min=Fragments_Blow.Z;
			emit.Emitters[0].StartVelocityRange.Z.Max=Fragments_Blow.Z;

			emit.Emitters[0].StartLocationRange.X.Min=-Fragments_Eparpillement.X;
			emit.Emitters[0].StartLocationRange.X.Max=Fragments_Eparpillement.X;
			emit.Emitters[0].StartLocationRange.Y.Min=-Fragments_Eparpillement.Y;
			emit.Emitters[0].StartLocationRange.Y.Max=Fragments_Eparpillement.Y;
			emit.Emitters[0].StartLocationRange.Z.Min=-Fragments_Eparpillement.Z;
			emit.Emitters[0].StartLocationRange.Z.Max=Fragments_Eparpillement.Z;

			emit.Emitters[0].SetMaxParticles(Fragments_Number);

			emit.Emitters[0].StartSizeRange.X.Max=Fragments_ScaleMax;
			emit.Emitters[0].StartSizeRange.X.Min=Fragments_ScaleMin;
			emit.Emitters[0].StartSizeRange.Y.Max=Fragments_ScaleMax;
			emit.Emitters[0].StartSizeRange.Y.Min=Fragments_ScaleMin;

			emit.Emitters[0].Texture=FragmentTexture;
			emit.Emitters[0].TextureUSubdivisions=FragmentTextureUSubdivisions;
			emit.Emitters[0].TextureVSubdivisions=FragmentTextureVSubdivisions;
			emit.Emitters[0].DrawStyle=FragmentDrawStyle;

			emit.Emitters[0].UseCollision=ParticlesUseCollision;

			if ( Fragments_FadeOut )
			{
				emit.Emitters[0].FadeOut=true;
				emit.Emitters[0].FadeOutStartTime=Fragments_FadeOutBegin;
				emit.Emitters[0].LifeTimeRange.Min=Fragments_FadeOutEnd;
				emit.Emitters[0].LifeTimeRange.Max=Fragments_FadeOutEnd;
			}
		}
	}

	if ((Fragments3D.Type!=None) && (Fragments3D.StaticMesh!=none))
	{
		if (Walker!=none)
			emit2=Spawn(Fragments3D.Type,self,,Fragment_Center+Fragments3D.Offset,Walker.Rotation);
		else
			emit2=Spawn(Fragments3D.Type,self,,Fragment_Center+Fragments3D.Offset);

		if (emit2!=none)
		{
			emit2.Emitters[0].StartVelocityRange.X.Min=-100+(3*LastDamage*particles_speed.X)*RelativeBlow+Fragments3D.Blow.X;
			emit2.Emitters[0].StartVelocityRange.X.Max=100+(3*LastDamage*particles_speed.X)*RelativeBlow+Fragments3D.Blow.X;
			emit2.Emitters[0].StartVelocityRange.Y.Min=-100+(3*LastDamage*particles_speed.Y)*RelativeBlow+Fragments3D.Blow.Y;
			emit2.Emitters[0].StartVelocityRange.Y.Max=100+(3*LastDamage*particles_speed.Y)*RelativeBlow+Fragments3D.Blow.Y;
			emit2.Emitters[0].StartVelocityRange.Z.Max=Fragments3D.Blow.Z;
			emit2.Emitters[0].StartVelocityRange.Z.Min=Fragments3D.Blow.Z;

			emit2.Emitters[0].StartLocationRange.X.Min=-Fragments3D.Eparpillement.X;
			emit2.Emitters[0].StartLocationRange.X.Max=Fragments3D.Eparpillement.X;
			emit2.Emitters[0].StartLocationRange.Y.Min=-Fragments3D.Eparpillement.Y;
			emit2.Emitters[0].StartLocationRange.Y.Max=Fragments3D.Eparpillement.Y;
			emit2.Emitters[0].StartLocationRange.Z.Min=-Fragments3D.Eparpillement.Z;
			emit2.Emitters[0].StartLocationRange.Z.Max=Fragments3D.Eparpillement.Z;

			emit2.Emitters[0].SetMaxParticles(Fragments3D.Number);

			emit2.Emitters[0].StartSizeRange.X.Max=Fragments3D.ScaleMax;
			emit2.Emitters[0].StartSizeRange.X.Min=Fragments3D.ScaleMin;
			emit2.Emitters[0].StartSizeRange.Y.Max=Fragments3D.ScaleMax;
			emit2.Emitters[0].StartSizeRange.Y.Min=Fragments3D.ScaleMin;
			emit2.Emitters[0].StartSizeRange.Z.Max=Fragments3D.ScaleMax;
			emit2.Emitters[0].StartSizeRange.Z.Min=Fragments3D.ScaleMin;

			emit2.Emitters[0].UseCollision=ParticlesUseCollision;
			emit2.bIgnoreDynLight = Fragments3DIgnoreDynLight;

			meshemit= MeshEmitter(emit2.Emitters[0]);

			if (Fragments3D.FadeOut)
			{
				emit2.Emitters[0].FadeOut=true;
				emit2.Emitters[0].FadeOutStartTime=Fragments3D.FadeOutBegin;
				emit2.Emitters[0].LifeTimeRange.Min=Fragments3D.FadeOutEnd;
				emit2.Emitters[0].LifeTimeRange.Max=Fragments3D.FadeOutEnd;
				if (meshemit!=none)
					meshemit.UseMeshBlendMode=false;
				emit2.Emitters[0].DrawStyle=PTDS_AlphaBlend;
			}

			if (meshemit!=none)
				meshemit.StaticMesh=Fragments3D.StaticMesh;
		}
	}

	if (ExplosiveEmitter!=none)
	{
		if (ExplosiveEmitter!=class'XIIIExplosiveEmitter')
		{
			if ( Walker!=none )
				emit=Spawn(ExplosiveEmitter,self,,Location+ExplosiveEmitterOffset,Walker.Rotation);
			else
				emit=Spawn(ExplosiveEmitter,self,,Location+ExplosiveEmitterOffset);
		}
		else
		{
			if ((Fire.Type!=FT_None) || (Smoke.Type!=ST_None) || (Onomatop.Type!=OT_None)
				|| (FireTexture!=None) || (SmokeTexture!=None) || (OnomatopTexture!=None)
				)
			{
				if ( Walker!=none )
					emit=Spawn(ExplosiveEmitter,self,,Location+ExplosiveEmitterOffset,Walker.Rotation);
				else
					emit=Spawn(ExplosiveEmitter,self,,Location+ExplosiveEmitterOffset);
			}

			if ( FireTexture!=None )
			{
				emit.Emitters[0].Texture = FireTexture;
				emit.Emitters[0].StartLocationRange.X.Min=-Fire.Dispersal.X;
				emit.Emitters[0].StartLocationRange.X.Max=Fire.Dispersal.X;
				emit.Emitters[0].StartLocationRange.Y.Min=-Fire.Dispersal.Y;
				emit.Emitters[0].StartLocationRange.Y.Max=Fire.Dispersal.Y;
				emit.Emitters[0].StartLocationRange.Z.Min=-Fire.Dispersal.Z;
				emit.Emitters[0].StartLocationRange.Z.Max=Fire.Dispersal.Z;
				emit.Emitters[0].StartLocationOffset=Fire.Offset;

				emit.Emitters[0].SetMaxParticles(Fire.Number);
				emit.Emitters[0].NoSynchroAnim=true;
				emit.Emitters[0].RespawnDeadParticles=False;
				emit.Emitters[0].UseRotationFrom=PTRS_Actor;

				emit.Emitters[0].OnceTextureAnim=Fire.OneTextureAnimOnly;
				emit.Emitters[0].InitialParticlesPerSecond=10.0;
				emit.Emitters[0].AutomaticInitialSpawning=False;
				if (Fire.LifeTime==0.0)
					Fire.LifeTime=0.1;
				emit.Emitters[0].LifetimeRange.Min=Fire.LifeTime;
				emit.Emitters[0].LifetimeRange.Max=Fire.LifeTime;

				if (Fire.FadeOut)
				{
					emit.Emitters[0].FadeOut=true;
					emit.Emitters[0].FadeOutStartTime=Fire.FadeOutBegin;
				}

				emit.Emitters[0].DrawStyle=Fire.DrawStyle;

				emit.Emitters[0].StartSizeRange.X.Max=Fire.ScaleMax;
				emit.Emitters[0].StartSizeRange.X.Min=Fire.ScaleMin;
				emit.Emitters[0].Disabled=false;
			}
			if ( SmokeTexture!=None )
			{
				emit.Emitters[1].Texture = SmokeTexture;
				emit.Emitters[1].StartLocationRange.X.Min=-Smoke.Dispersal.X;
				emit.Emitters[1].StartLocationRange.X.Max=Smoke.Dispersal.X;
				emit.Emitters[1].StartLocationRange.Y.Min=-Smoke.Dispersal.Y;
				emit.Emitters[1].StartLocationRange.Y.Max=Smoke.Dispersal.Y;
				emit.Emitters[1].StartLocationRange.Z.Min=-Smoke.Dispersal.Z;
				emit.Emitters[1].StartLocationRange.Z.Max=Smoke.Dispersal.Z;
				emit.Emitters[1].StartLocationOffset=Smoke.Offset;

				emit.Emitters[1].SetMaxParticles(Smoke.Number);
				emit.Emitters[1].NoSynchroAnim=true;
				emit.Emitters[1].RespawnDeadParticles=False;
				emit.Emitters[1].UseRotationFrom=PTRS_Actor;

				emit.Emitters[1].OnceTextureAnim=Smoke.OneTextureAnimOnly;
				emit.Emitters[1].InitialParticlesPerSecond=10.0;
				emit.Emitters[1].AutomaticInitialSpawning=False;
				if (Smoke.LifeTime==0.0)
					Smoke.LifeTime=0.1;
				emit.Emitters[1].LifetimeRange.Min=Smoke.LifeTime;
				emit.Emitters[1].LifetimeRange.Max=Smoke.LifeTime;
				if (Smoke.FadeOut)
				{
					emit.Emitters[1].FadeOut=true;
					emit.Emitters[1].FadeOutStartTime=Smoke.FadeOutBegin;
				}

				emit.Emitters[1].DrawStyle=Smoke.DrawStyle;

				emit.Emitters[1].StartSizeRange.X.Max=Smoke.ScaleMax;
				emit.Emitters[1].StartSizeRange.X.Min=Smoke.ScaleMin;
				emit.Emitters[1].Disabled=false;
			}

			if ((Onomatop.Type!=OT_None) || (OnomatopTexture!=None))
			{
				if (OnomatopTexture!=None)
					emit.Emitters[2].Texture = OnomatopTexture;
				else
					emit.Emitters[2].Texture = OnomatopTextures[Onomatop.Type];
				emit.Emitters[2].StartLocationRange.X.Min=-Onomatop.Dispersal.X;
				emit.Emitters[2].StartLocationRange.X.Max=Onomatop.Dispersal.X;
				emit.Emitters[2].StartLocationRange.Y.Min=-Onomatop.Dispersal.Y;
				emit.Emitters[2].StartLocationRange.Y.Max=Onomatop.Dispersal.Y;
				emit.Emitters[2].StartLocationRange.Z.Min=-Onomatop.Dispersal.Z;
				emit.Emitters[2].StartLocationRange.Z.Max=Onomatop.Dispersal.Z;
				emit.Emitters[2].StartLocationOffset=Onomatop.Offset;

				emit.Emitters[2].SetMaxParticles(Onomatop.Number);
				if (Onomatop.LifeTime==0.0)
					Onomatop.LifeTime=0.1;
				emit.Emitters[2].LifetimeRange.Min=Onomatop.LifeTime;
				emit.Emitters[2].LifetimeRange.Max=Onomatop.LifeTime;

				emit.Emitters[2].DrawStyle=Onomatop.DrawStyle;

				emit.Emitters[2].StartSizeRange.X.Max=Onomatop.ScaleMax;
				emit.Emitters[2].StartSizeRange.X.Min=Onomatop.ScaleMin;
				emit.Emitters[2].Disabled=false;
			}
		}
	}
}

SIMULATED FUNCTION Breaking( float fDelay )
{
	Disable('Bump');

	DelayToUse=fDelay;

	if (Level.NetMode == NM_StandAlone)
		InitDazzleAndShake(false);

	if ( ((DrawType==DT_StaticMesh) && (breakingmesh!=none)) || (DrawType==DT_Mesh) )
	{
		GotoState('STA_BreakingAnim');
		return;
	}

	if (fDelay==0.0)
		Breaked();
	else
		GotoState('STA_Breaking');
}

FUNCTION FastBreak()
{
	LOG( "FASTBREAK"@self );
	bBreaking = false;
	bBroken = true;
	bNoInteractionIcon = true;
	if(BreakedStaticMesh!=none)
	{
		StaticMesh=BreakedStaticMesh;
	}
	else
		Destroy();
}

simulated FUNCTION Breaked()
{
	Local Pickup TheDecoPickupGenerated;   // ELR the deco thing to pickup

	ComputeDispersal();
	if (event!='')
		TriggerEvent(event,self,none);

	bBreaking = false;
	bBroken = true;
	bNoInteractionIcon = true;
	PlaySound( SoundWhenBroken, ExplosiveType );
	if (Level.NetMode == NM_StandAlone)
		InitDazzleAndShake(true);
	InitializeEmitters();

	if ( DecoPickupGenerated != none )
	{
		TheDecoPickupGenerated = Spawn(DecoPickupGenerated,,,Location);
		TheDecoPickupGenerated.InitDroppedPickupFor(none);
	}

	switch (DrawType)
	{
	case DT_StaticMesh:
		if(BreakedStaticMesh!=none)
		{
			StaticMesh=BreakedStaticMesh;
		}
		else
			if (FD_bRunning || Level.NetMode != NM_StandAlone)
			{
				bHidden=true;
				RefreshDisplaying();
//				SetCollision(false,false,false);
				bToBeDestroyed=true;
			}
			else
				Destroy();
		break;
	default:
		if (FD_bRunning || Level.NetMode != NM_StandAlone)
		{
			bHidden=true;
			RefreshDisplaying();
//			SetCollision(false,false,false);
			bToBeDestroyed=true;
		}
		else
			Destroy();
		break;
	}

//	if (CollisionWhenBreaked==false)
		SetCollision(CollisionWhenBreaked,CollisionWhenBreaked,CollisionWhenBreaked);

	if ( Walker!=none && Walker.Base==self )
	{
		Walker.DropToGround();
		Walker.Acceleration = vect(0,0,0);
	}

	GotoState('');
}

STATE STA_BreakingAnim
{
	EVENT AnimEnd(int Channel)
	{
		SetDrawType(MemoDrawType);
		Breaked();
		Mesh=none;
	}
begin:
	Sleep(DelayToUse);
	Mesh=breakingmesh;
	StaticMesh=none;
	MemoDrawType=DrawType;
	SetDrawType(DT_Mesh);
	PlayAnim( BreakedMeshAnim );
	stop;

}

STATE STA_Breaking
{
	IGNORES Bump,TakeDamage;

	EVENT BeginState()
	{
		bBreaking=true;
		TempsContact=0;
	}

	EVENT Tick(float dt)
	{
		LOCAL ROTATOR r;

		Global.Tick(dt);

		if ( bMustShakeWhileDelay )
		{
			r.Yaw=0;
			r.Pitch=FRand()*128-64;
			r.Roll=FRand()*128-64;
			SetRotation(r);
		}
		TempsContact+=dt;
		if (TempsContact>DelayToUse)
			Breaked();
	}
}



defaultproperties
{
     ParticlesUseCollision=True
     bDisperseInBoundingBox=True
     bVulnerableBladeCut=True
     bVulnerableGrenade=True
     bVulnerableGun=True
     bVulnerableShotgun=True
     bVulnerableStunning=True
     bVulnerablePiercing=True
     bVulnerableToFist=True
     Fragments_FadeOut=True
     Fragments3DIgnoreDynLight=True
     RelativeBlow=1.000000
     Fragments_ScaleMin=10.000000
     Fragments_ScaleMax=10.000000
     Fragments_FadeOutBegin=3.000000
     Fragments_FadeOutEnd=5.000000
     SC_lifetime=3.000000
     SC_intensity=1.000000
     SC_distance_end=1024.000000
     FD_lifetime=0.400000
     FD_intensity=1.100000
     FD_distance_start=512.000000
     FD_distance_end=1024.000000
     FragmentTextureUSubdivisions=1
     FragmentTextureVSubdivisions=1
     Fragments_Number=50
     BreakPoint=-1
     Fragments_Eparpillement=(X=100.000000,Y=100.000000,Z=100.000000)
     FragmentTexture=Texture'XIIICine.effets.glass13'
     OnomatopTextures(1)=Texture'XIIICine.effets.Baommm'
     OnomatopTextures(3)=Texture'XIIICine.effets.crac'
     OnomatopTextures(4)=Texture'XIIICine.effets.cling'
     OnomatopTextures(5)=Texture'XIIICine.effets.Blam'
     FD_color=(B=255,G=255,R=255)
     Fragments_Type=Class'XIDCine.XIIIBreakingGlassEmitter'
     FragmentDrawStyle=PTDS_Translucent
     Fragments3D=(Number=10,ScaleMin=1.000000,ScaleMax=1.000000,FadeOutBegin=1.000000,FadeOutEnd=2.000000)
     Fire=(Number=1,ScaleMin=100.000000,ScaleMax=100.000000)
     Smoke=(Number=1,ScaleMin=100.000000,ScaleMax=100.000000)
     Onomatop=(Number=1,ScaleMin=100.000000,ScaleMax=100.000000)
     ExplosiveEmitter=Class'XIDCine.XIIIExplosiveEmitter'
     Health=10
     bBreakable=True
     bNoDelete=False
     bMovable=False
     Physics=PHYS_None
     InitialState="None"
     bPathColliding=True
}
