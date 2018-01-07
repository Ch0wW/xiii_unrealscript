class ScriptedImpacts extends Info
	ShowCategories(Movement)
	placeable;

//  abstract;
//
//var float ShortRange;           // Range at wich we do SRDamages (decreasing)
//var float LongRange;            // Range at wich we do LRDamages (decreasing)
//var int SRDamages, LRDamages;   // ShortRange and LongRange damages

ENUM E_TransitionType
{
	TT_Cut,
	TT_Smooth,
};

STRUCT SImpact
{
	VAR() Actor TargetedActor;
	VAR() int NumberOfImpacts;
	VAR() class<ImpactEmitter> NoMoreUsed; //ImpactEmitterMem;  // Visual Impact SFX to run when impacting
	VAR() class<Projector> NoMoreUsed2;  // Visual Impact to leave on geometry
	VAR() float ImpactNoise;              // Noise made by the ammo when hitting something
	VAR() float BulletsInterval;
	VAR() float TimeBeforeNextTarget;
	VAR() E_TransitionType Transition;
};

VAR() SImpact Impacts[16];
VAR() float ExtraTraceDistance;
VAR() float Dispersion;
VAR() int BulletTrailRate;
VAR() class<ImpactEmitter> ImpactEmitterMem;
VAR() class<BulletScorch> DecalProjectorClass;
VAR BulletScorch DecalProjector;
VAR() Sound ShootSound;
VAR sound HitSoundMem;
VAR bool bPlayHitSound;
VAR() bool bDoTatata;
VAR TaEmitter Tatata;

//VAR() Actor Targets[16];
//VAR() int NumberOfImpactsByTarget[16];
//VAR() float Dispersion;
//VAR() float SoftImpactNoise;          // Noise made by the ammo when hitting someone
VAR() class<BulletTrail> TraceClass;    // Class of BulletTrace to spawn

VAR BulletTrail BT;                   // BulletTrail once spawned to handle update
VAR int CurrentTarget, CurrentNumberOfImpacts, BulletCounter;
VAR vector CurrentTargetLocation, NextTargetDeltaLocation;


//_____________________________________________________________________________
/*function PostBeginPlay()
{
    Super.PostBeginPlay();
}

//_____________________________________________________________________________
function ProcessTraceHitNoAmmo(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    if (AmmoAmount > 0)
    {
      AmmoAmount += 1;
      ProcessTraceHit(W, Other, HitLocation, HitNormal, X, Y, Z);
    }
}*/

//_____________________________________________________________________________
EVENT Trigger(Actor Other,Pawn EventInstigator)
{
	CurrentTarget=0;
	BulletCounter=0;
	if ( Impacts[CurrentTarget].TargetedActor==none )
	{
//		DebugLog( "ScriptedImpacts::Trigger::Destroy");
		Destroy();
		return;
	}
	GotoState('Burst');
}

FUNCTION NewTarget( )
{
//	DebugLog( self@"ScriptedImpacts::NewTarget : CurrentTarget="@CurrentTarget@", TargetedActor="@Impacts[CurrentTarget].TargetedActor );
	if ( CurrentTarget<8 && Impacts[CurrentTarget].TargetedActor !=none )
	{
		CurrentTargetLocation = Impacts[CurrentTarget].TargetedActor.Location;
		if ( Impacts[CurrentTarget].Transition == TT_Smooth )
		{
			if ( CurrentTarget==7 || Impacts[CurrentTarget+1].TargetedActor==none || Impacts[CurrentTarget].NumberOfImpacts==0 )
			{
//				Log("TRY TO SMOOTH BUT CUT : CurrentTarget="@CurrentTarget@", NextTargetedActor="@Impacts[CurrentTarget+1].TargetedActor@", NumberOfImpacts="@Impacts[CurrentTarget].NumberOfImpacts );
				Impacts[CurrentTarget].Transition = TT_Cut;
			}
			else
			{
//				Log("OK SMOOTH");
				NextTargetDeltaLocation = Impacts[CurrentTarget+1].TargetedActor.Location - CurrentTargetLocation;
			}

		}
/*		else
		{
			Log("OK CUT");
		}*/
		CurrentNumberOfImpacts=0;
	}
	else
	{
//		DebugLog( "ScriptedImpacts::NewTarget::GotoState('')");
		if ( Tatata!=none )
			Tatata.Emitters[0].RespawnDeadParticles=false;

		TriggerEvent( event, self, none );
		GotoState('');
	}
}

STATE Burst
{
	Ignores Trigger;

	EVENT BeginState()
	{
//		LOG(self@"BeginState");
		NewTarget();
		SetTimer( Impacts[CurrentTarget].BulletsInterval,true );
		Timer();
	}
	EVENT Timer()
	{
		if ( CurrentNumberOfImpacts<Impacts[CurrentTarget].NumberOfImpacts )
		{
			if ( bDoTatata && Tatata==none )
				Tatata=Spawn(class'TaEmitter');
			if ( Impacts[CurrentTarget].Transition == TT_Cut )
				Impact( Impacts[CurrentTarget].TargetedActor.Location );
			else // TT_Smooth
			{
				Impact( CurrentTargetLocation +  float(CurrentNumberOfImpacts)/Impacts[CurrentTarget].NumberOfImpacts * NextTargetDeltaLocation );
			}
		}

		CurrentNumberOfImpacts++;

		if ( CurrentNumberOfImpacts>=Impacts[CurrentTarget].NumberOfImpacts )
		{
			if (Impacts[CurrentTarget].TimeBeforeNextTarget!=0)
			{
//				Log(self@"PAUSE"@Impacts[CurrentTarget].TimeBeforeNextTarget);
				SetTimer(0,false);
				SetTimer2(Impacts[CurrentTarget].TimeBeforeNextTarget,false);
				CurrentTarget++;
				NewTarget();
				if ( Tatata!=none )
					Tatata.Emitters[0].RespawnDeadParticles=false;
			}
			else
			{
//				Log(self@"PAS DE PAUSE");
				CurrentTarget++;
				NewTarget();
			}
		}
	}
	EVENT Timer2()
	{
//		LOG(self@"TIMER2"@Impacts[CurrentTarget].BulletsInterval);
		Tatata.Emitters[0].RespawnDeadParticles=true;
		SetTimer( Impacts[CurrentTarget].BulletsInterval,true );
//		Timer();
	}
}

FUNCTION Impact( vector TargetedPosition )
{
	LOCAL ImpactEmitter B;

	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local material HitMat;
	local actor HitPawn, Target;
	LOCAL int i;
	LOCAL vector u,v,w;


	if ( Tatata!=none )
	{
		Tatata.SetLocation( Location+170*Normal(TargetedPosition-Location) );
	}

	if ( ShootSound!=none)
		PlaySound( ShootSound );
//	Log(" IMPACT "@TargetedPosition );
//	Log("*** IMPACT IMPACT IMPACT IMPACT IMPACT IMPACT IMPACT ***");
//	for (i=0;i<16;i++)
//	{
		u=Normal( TargetedPosition - Location );
		v=Normal(u cross vect(0,0,1));
		w=v cross u;
		EndTrace= TargetedPosition + v*Dispersion*(frand()*2-1)+w*Dispersion*(frand()*2-1)+ExtraTraceDistance*u;
//		Target=Targets[CurrentBullet];
//		if ( Target==none)
//			return;
//		EndTrace=Target.Location+ Normal(Target.Location-Location)*100;
		HitPawn = Trace(HitLocation,HitNormal,EndTrace,Location,True,vect(0,0,0),HitMat,TRACETYPE_DiscardIfCanShootThroughWithRayCastingWeapon);

		if ( HitPawn!=none)
		{
			if ( HitPawn.IsA('BreakableMover' ) )
				HitPawn.Trigger( self, none );
			if ( HitPawn.IsA('InteractiveCan' ) )
				HitPawn.TakeDamage( 0, none, HitLocation, 3000*Normal(HitLocation-Location), Class'XIII.DTGunned' );
			if ( Pawn(HitPawn)!=none )
			{
				ImpactEmitterMem=class'BloodShotEmitter';
//			  Spawn(class'BloodShotEmitter',Other,, HitLocation+HitNormal, Rotator(-X));
			}
		}
//		Log (HitPawn);
		if ( HitMat!=none )
		{
			HitSoundMem=HitMat.Hitsound;
			SetUpImpactEmitter( HitSoundMem );
			bPlayHitSound=true;
//			DebugLog( "_______SI::HitMaterial :"@HitMat@"=>"@HitSoundMem);
		}
		else
		{
			bPlayHitSound=false;
//			DebugLog( "_______SI::NoMaterialHit !!");
		}

		if ( BT == none && TraceClass!=none )
		{
			BT = Spawn( TraceClass,self, , Location, Rotation );
			BT.Instigator = Instigator;
			BT.bOwnerNoSee = true;
			//        BT.ActorOffset = MuzzleOffset - (Instigator.Weapon.ThirdPersonRelativeLocation << Instigator.Weapon.ThirdPersonRelativeRotation);
			BT.RibbonColor = BT.default.RibbonColor;// * fRand();
			BT.Init();
			//        Log("SPAWN TRAIL"@BT@"for"@self);
		}
		if ( BT != none )
		{
			//        Log("TRAIL Update after fire");
			BT.Reset( );
			// Add sections to draw bullet traces
			if ( BulletCounter==0 )
			{
				BT.AddSection( HitLocation ); //Target.Location /*+ vector(Rotation)*3000*/);
				BT.AddSection( Location );
			}
			BulletCounter++;
			if ( BulletCounter>=BulletTrailRate)
				BulletCounter=0;

		}

		if ( /*Impacts[CurrentTarget].*/ImpactEmitterMem != none )
		{
			B = Spawn(/*Impacts[CurrentTarget].*/ImpactEmitterMem, , , HitLocation+HitNormal, Rotator(HitNormal) );
			if (B!=none)
			{
				B.NoiseMake( XIIIPawn(Owner), Impacts[CurrentTarget].ImpactNoise );
				if ( bPlayHitSound )
				{
					bPlayHitSound = false;
					B.PlaySound(HitSoundMem, 0/*, HitSoundType*/);
				}
			}
		}
		if ( ( /*Impacts[CurrentTarget].*/DecalProjectorClass != None) /*&& (!Target.bNoImpact)*/ )
			//        ClientSpawnDecal(HitLocation, X);
		{
		  if ( DecalProjector == none )
		  {
  			DecalProjector = Spawn(/*Impacts[CurrentTarget].*/DecalProjectorClass,self,,HitLocation + HitNormal, rotator(-HitNormal));
  		}
  		else
  		{
        DecalProjector.SetLocation( HitLocation + HitNormal );
        DecalProjector.SetRotation( rotator(-HitNormal) );
        DecalProjector.UpdateScorch();
  		}
		}
//	}
}

//    bDrawTracingBullets=true
//    TBTexture=texture'XIIIMenu.SFX.TraceBullet1'
//    fTraceFrequency=0.33333
//    HitSoundType=0
//    Tracetype=16384
/*
function PlayImpactSound(vector Normal, actor Wall)
{
    local Material M;
    local actor A;
    local vector HitLoc, HitNorm;
    local ImpactEmitter B;

    if ( Level.NetMode == NM_DedicatedServer )
      return;

    A = Trace(HitLoc, HitNorm, Location - Normal * 50, Location + Normal, false, vect(0,0,0), M);

    if ( Wall.bWorldGeometry || (Mover(Wall) != none) || (StaticMeshActor(Wall) != none) )
    {
      if ( (M != none) && (M.HitSound != none) )
        SetUpImpactEmitter(M.HitSound);
      else if ( TerrainInfo(Wall) != none )
        SetUpImpactEmitter(TerrainInfo(Wall).HitSound);
      if ( ImpactEmitterMem != none )
      {
        B = Spawn(ImpactEmitterMem,,, HitLoc+HitNorm, Rotator(HitNorm));
        if ( (B != none) && (HitSoundType >= 0) )
        {
          if ( (M != none) && (M.HitSound != none) )
            B.PlaySound(M.HitSound, HitSoundType);
          else if ( TerrainInfo(Wall) != none )
            B.PlaySound(TerrainInfo(Wall).HitSound, HitSoundType);
        }
      }
    }
}*/

function SetUpImpactEmitter(Sound S)
{
    local string Str;
    local int i;

    // First get rid of the beginning of the sound name just to keep whet is needed
    Str = string(S);
    i = InStr(S, 'hPlay');
    Str = Right(Str, Len(Str) - i - 5);
//    Log("SetUpImpactEmitter Bullet --'"$Str$"'--");

    // Then switch/case the result to setup the SFX class
    switch (Str)
    {
      case "ImpBtE":
      case "ImpBtI":
      case "ImpCar":
      case "ImpMar":
      case "ImpTil":
      case "ImpPie":
        // Concrete type

        if ( (DecalProjector != none) && (DecalProjector.Class != Class'XIII.BulletScorch') )
        {
          DecalProjector.LifeSpan = 2.0+fRand();
          DecalProjector = none;
        }
        DecalProjectorClass = Class'XIII.BulletScorch';
        ImpactEmitterMem = class'BulletDustEmitter';
        break;
      case "ImpGra":
        // Gravel type
        if ( (DecalProjector != none) && (DecalProjector.Class != Class'XIII.BulletScorch') )
        {
          DecalProjector.LifeSpan = 2.0+fRand();
          DecalProjector = none;
        }
        DecalProjectorClass = Class'XIII.BulletScorch';
        ImpactEmitterMem = class'GravelDustEmitter';
        break;
      case "ImpBoiC":
      case "ImpBoiP":
      case "ImpPar":
      case "ImpFeu":
        // Wood type
        if ( (DecalProjector != none) && (DecalProjector.Class != Class'XIII.BulletScorchWood') )
        {
          DecalProjector.LifeSpan = 2.0+fRand();
          DecalProjector = none;
        }
        DecalProjectorClass = Class'XIII.BulletScorchWood';
        ImpactEmitterMem = class'WoodDustEmitter';
        break;
      case "ImpEau":
        // Water type (should not happen but maybe....)
        if ( (DecalProjector != none) && (DecalProjector.Class != Class'XIII.BulletScorch') )
        {
          DecalProjector.LifeSpan = 2.0+fRand();
          DecalProjector = none;
        }
        DecalProjectorClass = Class'XIII.BulletScorch';
        ImpactEmitterMem = class'BulletDustEmitter';
        break;
      case "ImpGla":
      case "ImpVer":
        // Glass type
        if ( (DecalProjector != none) && (DecalProjector.Class != Class'XIII.BulletScorchGlass') )
        {
          DecalProjector.LifeSpan = 2.0+fRand();
          DecalProjector = none;
        }
        DecalProjectorClass = Class'XIII.BulletScorchGlass';
        ImpactEmitterMem = class'GlassImpactEmitter';
        break;
      case "ImpGri":
      case "ImpMet":
      case "ImpTol":
        // Metal type
        if ( (DecalProjector != none) && (DecalProjector.Class != Class'XIII.BulletScorchMetal') )
        {
          DecalProjector.LifeSpan = 2.0+fRand();
          DecalProjector = none;
        }
        DecalProjectorClass = Class'XIII.BulletScorchMetal';
        ImpactEmitterMem = class'BulletMetalEmitter';
        break;
      case "ImpHrb":
        // Grass Type
        if ( DecalProjector != none )
          DecalProjector.LifeSpan = 2.0+fRand();
        DecalProjector = none;
        DecalProjectorClass = none;
        ImpactEmitterMem = class'GrassDustEmitter';
        break;
      case "ImpTer":
        // Earth type
        if ( (DecalProjector != none) && (DecalProjector.Class != Class'XIII.BulletScorch') )
        {
          DecalProjector.LifeSpan = 2.0+fRand();
          DecalProjector = none;
        }
        DecalProjectorClass = Class'XIII.BulletScorch';
        ImpactEmitterMem = class'EarthDustEmitter';
        break;
      case "ImpNei":
        // Snow
        if ( DecalProjector != none )
          DecalProjector.LifeSpan = 2.0+fRand();
        DecalProjector = none;
        DecalProjectorClass = none;
        ImpactEmitterMem = class'SnowDustEmitter';
        break;
      case "ImpMol":
      case "ImpMoq":
        // Soft Types
        if ( DecalProjector != none )
          DecalProjector.LifeSpan = 2.0+fRand();
        DecalProjector = none;
        DecalProjectorClass = Class'XIII.BulletScorch';
        ImpactEmitterMem = class'MoqDustEmitter';
        break;
      case "ImpCdvr":
        // Body Type
        if ( (DecalProjector != none) && (DecalProjector.Class != Class'XIII.BulletScorchMetal') )
        {
          DecalProjector.LifeSpan = 2.0+fRand();
          DecalProjector = none;
        }
        DecalProjectorClass = Class'XIII.BulletScorchMetal';
        ImpactEmitterMem = class'BloodShotEmitter';
        break;
      case "ImpLin":
      default:
        // other types, not spawn any SFX
        if ( (DecalProjector != none) && (DecalProjector.Class != Class'XIII.BulletScorch') )
        {
          DecalProjector.LifeSpan = 2.0+fRand();
          DecalProjector = none;
        }
        DecalProjectorClass = Class'XIII.BulletScorch';
        ImpactEmitterMem = class'BulletDustEmitter';
        break;
    }
}


//,ImpactEmitterMem=class'BulletDustEmitter',DecalProjector=Class'XIII.BulletScorch',


defaultproperties
{
     Impacts(0)=(NumberOfImpacts=16,ImpactNoise=0.500000,BulletsInterval=0.100000)
     ExtraTraceDistance=100.000000
     Dispersion=100.000000
     TraceClass=Class'XIII.BulletTrail'
     Texture=Texture'Engine.S_Weapon'
}
