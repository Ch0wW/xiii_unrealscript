//-----------------------------------------------------------
//
//-----------------------------------------------------------
class USA02HelicoBossController extends AIController;

var bool bHaveSeenXIII;             // used to force the boss to advance on his rail until he see XIII
var bool bExploDone;                // to make HExplo only once
var bool bTrace;

var XIIIPawn XIII;                  // Our main target
var USA02HelicoBossPoint NavPoint1, NavPoint2;  // The points making a line we must stay on
var USA02HelicoBossPoint EndPoint;  // The location the HExplo effect must be made
var USA02HelicoBossPoint CrashPoint;// The location the HCrash effect must be made

var float fLocationFactor;          // percent of our potential target location on the rail
var int BossState;                  // memory of the boss current action
var vector vFocalPointOffset;       // to change this before firing
var vector vFiringLocation;         // target for missile
var float FiringTimer;              // Duration of MachineGunning phase
var() float DefaultFiringTimer;           // Duration of MachineGunning phase
var() float fStabilityBeforeMissileDelay; // duration of stability for firing missile aquisition.
var float fEndRotationFactor;       // to make Helico spin on himself progressivly

var sound hFireSound;               // firing sound for machinegun
var sound hMissileFireSound;        // firing sound for missiles
var class<BulletScorch> DecalProjectorClass;// Visual Impact to leave on geometry
var BulletScorch DecalProjector;              // projector to update (to avoid spawn each time)
var class<DamageType> MyDamageType; // Damage type for machinegun

var USA02HelicoMuzzleFlash Muzzle;  // The muzzleflash for machine gun

var() float MinAcquisitionTime;     // min time before lock-on for firing missiles

var const vector VMACHINEGUNOFFSET;
var const vector VMISSILEOFFSET;

var sound hBeginFightMusic;
var sound hHelicoTouchMusic;
var sound hSnapShotSound;
var sound hDestructsound;

var class<Trail> TraceClass;    // Class of BulletTrace to spawn
var Trail BT;                   // BulletTrail once spawned to handle update
var Vector BTEndLocation;       // To make traces accurate

var bool bStabiliteEntreTirs;

VAR Array<PositionInfo> UnsafePoints;

// BossState ==
  // -1 = Initialisation, wait for Cartoon window sfx
  // 0 = After Init
  // 1,3 = AcquireforMissile 1 & 2
  // 2,4 = PrepareMissile 1 & 2
  // 5 = Acquire for MachineGun
  // 6 = Firing Machinegun
  // 7 = End of Me (before explo)
  // 8 = Very End of me (after explo, before crash)

//_____________________________________________________________________________
event PostBeginPlay()
{
	LOCAL PositionInfo pi;

    DebugLog("\ HelicoBoss -- PostBeginPlay");
	//Pawn.PlaySound(hBeginFightSound);
	PlayMusic(hBeginFightMusic);
    BossState = -1;
    XIII = XIIIPlayerPawn(XIIIGameInfo(Level.Game).Mapinfo.XIIIpawn);
    SetTimer(1.5, true);
    Pawn.AirSpeed = 10000.0;

	foreach DynamicActors(class'PositionInfo',pi,'HiddenXIII')
	{
		LOG( "UNSAFE POINT :"@pi );
		UnsafePoints.Insert(0,1);
		UnsafePoints[0]=pi;
	}
}

FUNCTION bool CheckUnsafePoints()
{
	LOCAL int i;
	LOCAL Vector v;

	for ( i=0; i<UnsafePoints.Length; i++ )
	{
		v=(UnsafePoints[i].Location-XIII.Location);
		v.Z=0;
		if ( vSize(v)<UnsafePoints[i].CollisionRadius )
			return true;
	}
	return false;
}

//_____________________________________________________________________________
event Tick(float dT)
{
    // Move there
//    DebugLog("\ HelicoBoss -- Tick");
	//log(self@" ---> STABILITE OR NOT :"@bStabiliteEntreTirs);
	if ( CheckUnsafePoints() )
		SeePlayer(XIII);
	if ( !bStabiliteEntreTirs )
		Pawn.Acceleration = 0.25*(Destination - Pawn.Location)/dT*0.5;
	else
		Pawn.Acceleration = 0.25*(Destination - Pawn.Location)/dT*0.01;
    FocalPoint = (FocalPoint * 5.0 + XIII.Location + vFocalPointOffset)/6.0;
}

//_____________________________________________________________________________
event Timer()
{
    local vector vT, vT2;

    if ( Muzzle == none )
    {
      if ( Pawn != none )
      {
        Muzzle = Spawn(class'USA02HelicoMuzzleFlash',Pawn);
        Muzzle.SetBase(Pawn);
        Muzzle.SetRelativeLocation(-VMACHINEGUNOFFSET*DrawScale);
        Muzzle.SetRelativeRotation(rot(0,0,0));
      }
    }
    if ( !bHaveSeenXIII )
    {
      fLocationFactor = 0.1;
      Destination = NavPoint2.Location*fLocationFactor + NavPoint1.Location*(1.0-fLocationFactor);
      return;
    }
    else
    {
      vT = NavPoint2.Location*fLocationFactor + NavPoint1.Location*(1.0-fLocationFactor);
      vT2 = normal(FocalPoint - Pawn.Location);
  //      DebugLog("\ HelicoBoss -- Dist="$vSize(vT-XIII.Location)@"fLocationFactor="$fLocationFactor);
      if ( (vSize(vT-XIII.Location) < 1700) || (vT2.Z < -0.7) )
      { // must change fLocationfactor to increase medium distance between XIII and my pawn
        if ( (NavPoint2.Location - NavPoint1.Location) dot (XIII.location - vT) < 0 )
        {
          DebugLog("\            -- INC fLocationFactor");
          fLocationFactor += 0.1;
          if ( fLocationFactor > 1.0 )
            fLocationFactor = 0.3;
        }
        else
        {
          DebugLog("\            -- DEC fLocationFactor");
          fLocationFactor -= 0.1;
          if ( fLocationFactor < 0.0 )
            fLocationFactor = 0.7;
        }
      }
      else if ( vSize(vT-XIII.Location) > 3200 )
      {
        if ( (NavPoint2.Location - NavPoint1.Location) dot (XIII.location - vT) > 0 )
        {
          DebugLog("\            -- INC fLocationFactor");
          fLocationFactor += 0.1;
          if ( fLocationFactor > 1.0 )
            fLocationFactor = 1.0;
        }
        else
        {
          DebugLog("\            -- DEC fLocationFactor");
          fLocationFactor -= 0.1;
          if ( fLocationFactor < 0.0 )
            fLocationFactor = 0.0;
        }
      }
    }

    // Update Destination there ?
    Destination = NavPoint2.Location*fLocationFactor + NavPoint1.Location*(1.0-fLocationFactor);
    Destination += vect(0,0,1)*(fRand()-0.5)*NavPoint1.CollisionHeight;
    Destination += vect(1,0,0)*(fRand()-0.5)*NavPoint1.CollisionRadius;
    Destination += vect(0,1,0)*(fRand()-0.5)*NavPoint1.CollisionRadius;
}

//_____________________________________________________________________________
singular event SeePlayer(pawn Seen)
{
    //local CWndUSA02BossIntro CWnd;

//    DebugLog("\ HelicoBoss -- SeePlayer BossState="$BossState);
    if ( BossState == -1 ) // add Cartoon window
    {
      /*Level.Game.SetGameSpeed(0.1);
      CWnd = Spawn(class'CWndUSA02BossIntro', Pawn);
      if (CWnd != none)
        CWnd.MyHudForFX = XIIIBaseHUD(XIIIPlayerController(XIII.controller).MyHud);*/
      BossState ++;
      bHaveSeenXIII = true;
      Pawn.AirSpeed = Pawn.Default.AirSpeed;
    }
    else if ( (BossState == 0) || (BossState == 2) )
    {
      GotoState('AcquisitionPhase');
    }
    else if ( BossState == 4 )
    {
      GotoState('MachineGunPhase');
    }
}

//_____________________________________________________________________________
function NotifyTakeDamage()
{
	// gestion du son à chaque fois que l helico est touche
	PlayMusic(hHelicoTouchMusic);
	Pawn.PlaySound(hSnapShotSound);
}

//_____________________________________________________________________________
state AcquisitionPhase
{
    event BeginState()
    {
      //DebugLog("\ HelicoBoss -AcquisitionPhase BeginState");

	  //Pawn.Acceleration *= 0.2;
      SetTimer2(MinAcquisitionTime, false);
    }
    singular event SeePlayer(pawn Seen)
    {
      if ( (BossState == 1) || (BossState == 3) )
      { // Prepare to launch missile
        vFiringLocation = Seen.Location - Seen.CollisionHeight*vect(0,0,0.5);
        GotoState('FiringMissilePhase');
      }
    }
    event Timer2()
    {
      //DebugLog("\ HelicoBoss -- Timer2 BossState="$BossState);

      if ( (BossState == 0) || (BossState == 2) )
        BossState ++;
    }
}

//_____________________________________________________________________________
state FiringMissilePhase
{
    event BeginState()
    {
      //DebugLog("\ HelicoBoss -FiringMissilePhase BeginState BossState="$BossState);

      vFocalPointOffset = vect(0,0,0);
      Pawn.AirSpeed = 20.0;
      SetTimer2(fStabilityBeforeMissileDelay, false);
    }
    event EndState()
    {
      Pawn.AirSpeed = Pawn.Default.AirSpeed;
    }
    event Timer2()
    {
//      Local USA02HelicoMissile MyMissile;
      Local USA02HelicoMissileSpawnEmitter Emit;
      local vector X,Y,Z;

      GetAxes(Pawn.Rotation, X,Y,Z);

      /* MyMissile = */
      Spawn(class'USA02HelicoMissile', pawn,, Pawn.Location - X*VMISSILEOFFSET.X*DrawScale - Z*VMISSILEOFFSET.Z*DrawScale + (BossState-2)*Y*VMISSILEOFFSET.Y*DrawScale, rotator(vFiringLocation - Pawn.Location));
      Emit = Spawn(class'USA02HelicoMissileSpawnEmitter', none,, Pawn.Location - X*VMISSILEOFFSET.X*DrawScale - Z*VMISSILEOFFSET.Z*DrawScale + (BossState-2)*Y*VMISSILEOFFSET.Y*DrawScale, rotator(-vFiringLocation + Pawn.Location));
//      Emit.SetBase(Pawn);
//      Emit.SetRelativeLocation(vect(-1,0,0)*VMISSILEOFFSET.X*DrawScale + vect(0,0,-1)*VMISSILEOFFSET.Z*DrawScale + vect(0,1,0)*(BossState-2)*VMISSILEOFFSET.Y*DrawScale);
//      Emit.SetRelativeRotation(rot(0,32768,0));
      PlayFiringSound();
      BossState ++;
      vFocalPointOffset = default.vFocalPointOffset;
	  if (BossState == 2)
	      bStabiliteEntreTirs = true;
	  else
		  bStabiliteEntreTirs = false;
      GotoState('');
    }
    simulated function PlayFiringSound()
    {
      Pawn.MakeNoise(1.0);
      Pawn.PlaySound(hMissileFireSound, 0, 0);
    }
}

//_____________________________________________________________________________
state MachineGunPhase
{
    event SeePlayer(Pawn Seen);
    event Timer3 ()
    {
      if ( bTrace )
      {
        if (BT == none)
        {
          BT = Spawn(TraceClass,Pawn,,Location, Pawn.Rotation);
          BT.Instigator = Pawn;
          BT.ActorOffset = -(VMACHINEGUNOFFSET.X*vect(1,0,0) + vect(0,0,1)*VMACHINEGUNOFFSET.Z)/1.2;
          BT.Init();
        }
        if ( BT != none )
        {
          BT.Reset();
          BT.RibbonColor = BT.default.RibbonColor * fRand();
          BT.OutlineColor = BT.default.OutlineColor * fRand();
          BT.SetDrawType(DT_Trail);
          // Add sections to draw bullet traces
          BT.AddSection(BTEndLocation);
          BT.AddSection(BT.Location);
        }
        bTrace = false;
        SetTimer3(0.5, true);
      }
      else
      { // bullet traces should be reseted often to avoid presence in lot of Leaves & crash the engine
        if ( BT != none )
        {
          BT.SetDrawType(DT_None);
          BT.Reset();
        }
        SetTimer3(1.0+fRand(), true);
      }
    }
    function FireMachinegun()
    {
      local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
      local material HitMat;
      local actor Other;

      GetAxes(Pawn.Rotation,X,Y,Z);
      StartTrace = Pawn.Location + 100*VRand() - X*VMACHINEGUNOFFSET.X - Z*VMACHINEGUNOFFSET.Z;
      EndTrace = StartTrace + (10000 * X);
//      EndTrace += vRand() * fRand() * (TraceAccuracy/100.0) * TraceDist;
      Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True,vect(0,0,0),HitMat,TRACETYPE_DiscardIfCanShootThroughWithRayCastingWeapon);
      Muzzle.Flash();
      ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
    }
    function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
    {
      Local int ActualDamages;
//      local XIIITrajectoireBalle xtb;
//      local vector DepartTrajectoire;
      local ImpactEmitter B;

      PlayFiringSound();

//      DepartTrajectoire = Pawn.Location - VMACHINEGUNOFFSET.X*X - Z*VMACHINEGUNOFFSET.Z;
//      xtb=Spawn(class'XIIITrajectoireBalle',self,,DepartTrajectoire,rotator(HitLocation-DepartTrajectoire)); //Instigator.GetViewRotation());
//      xtb.Longueur= VSize(HitLocation-DepartTrajectoire);
      bTrace = true;
      BTEndLocation = HitLocation;
      Timer3();


      if ( Other == None )
        return;

      ActualDamages = 25;

      if ( ActualDamages <= 0)
        return;

      if ( Other.bWorldGeometry )
      {
        B = Spawn(class'BulletDustEmitter',,, HitLocation+HitNormal, Rotator(HitNormal));
        if (B!=none)
          B.NoiseMake(Pawn, 0.4);
        if ( (DecalProjectorClass != None) && (Level.NetMode != NM_DedicatedServer) )
        {
          if ( DecalProjector == none )
          {
            DecalProjector = Spawn(DecalProjectorClass,self,,HitLocation + HitNormal, rotator(X-HitNormal));
          }
          else
          {
            DecalProjector.SetLocation( HitLocation + HitNormal );
            DecalProjector.SetRotation( rotator(X-HitNormal) );
            DecalProjector.UpdateScorch();
          }
        }
      }
      else if ( (Other != self) && (Other != Pawn) && (Other != Owner) )
      {
        Other.TakeDamage(ActualDamages, Pawn, HitLocation, 30000.0*X, MyDamageType);
        if ( Pawn(Other)!=none )
          Spawn(class'BloodShotEmitter',,, HitLocation+HitNormal, Rotator(-X));
        else
        {
          B = Spawn(class'BulletDustEmitter',,, HitLocation+HitNormal, Rotator(HitNormal));
          if (B!=none)
            B.NoiseMake(Pawn, 0.15);
        }
      }
    }
    simulated function PlayFiringSound()
    {
      Pawn.MakeNoise(1.0);
      Pawn.PlaySound(hFireSound, 0, 0);
    }
    event Timer2()
    {
//      DebugLog("\ HelicoBoss -MachinegunPhase Timer2 vFocalPointOffset="$vFocalPointOffset);
      FireMachinegun();
      FiringTimer -= 0.1;
      if ( Firingtimer < 0.0 )
      {
        BossState = 0;
        GotoState('');
      }
    }
    event BeginState()
    {
      DebugLog("\ HelicoBoss -MachineGunPhase BeginState");
      vFocalPointOffset = vect(0,0,-380);
      FiringTimer = DefaultFiringTimer;
//      SetTimer2(0.1, true);

    }
    event Tick(float dT)
    {
		if ( CheckUnsafePoints() )
			SeePlayer(XIII);

		Pawn.Acceleration = 0.25*(Destination - Pawn.Location)/dT*0.5;
		vFocalPointOffset *= 0.95;
		FocalPoint = (FocalPoint * 5 + XIII.Location + vect(0,0,50) + vFocalPointOffset)/6.0;
    }
Begin:
  Sleep(1.5);
  DebugLog("\ HelicoBoss -MachineGunPhase Setting Timer2 to 0.1,true, Starting Firing");
  SetTimer2(0.1, true);
}

//_____________________________________________________________________________
// Should start to go to the end position and create necessary events
state EndOfMe
{
    event SeePlayer(Pawn Seen);
    event Tick(float dT)
    {
      local CWndUSA02BossEnd CWnd;
      local vector tV, tV2, tV3;
      local float tF;

      // Update Acceleration
      Pawn.Acceleration = 1.0*(Destination - Pawn.Location)/dT;

      // Update FocalPoint to make Helico turn on himself
      if ( BossState == 7 )
      {
        fEndRotationFactor += dT * 5;
        FocalPoint = Pawn.Location + normal(vector(Pawn.Rotation) * 100 - (Vector(Pawn.rotation) cross vect(0,0,1)) * fEndRotationFactor)*100;
      }
      else if ( BossState == 8 )
      { // Should continue turning until aligned
        tV2 = FocalPoint - Pawn.Location;
        tV3 = vector(CrashPoint.Rotation);
//        tV = tV2 cross tV3;
        tV2.z = 0.0;
        tV3.z = 0.0;
        tF = normal(tV2) dot normal(tV3);
//        if ( (tv.z > 0) || tF < 0.95) // keep turning
        if ( tF < 0.95 ) // keep turning
        {
//          fEndRotationFactor += dT * 5;
          FocalPoint = Pawn.Location + normal(vector(Pawn.Rotation) * 100 - (Vector(Pawn.rotation) cross vect(0,0,1)) * fEndRotationFactor)*100;
        }
        else
          FocalPoint = CrashPoint.Location + vector(CrashPoint.Rotation)*5000.0;

//        tV = Vector(Pawn.rotation) cross vect(0,0,1);
//        fEndRotationFactor += dT * 5;
//        FocalPoint = Pawn.Location + normal(vector(Pawn.Rotation) * 100 + tV * fEndRotationFactor)*100;
//        FocalPoint = CrashPoint.Location + vector(CrashPoint.Rotation)*5000.0;
      }

      // triggering events
      if ( (BossState==7) && !bExploDone && (vSize(Destination - Pawn.Location) < 350.0) )
      {
        DebugLog("\ HelicoBoss -EndOfMe hExplo event");
        TriggerEvent('hExplo', self, Pawn);
        bExploDone = true;
      }
      if ( vSize(Destination - Pawn.Location) < 250.0 )
      {
        if (BossState == 7)
        {
          /*CWnd = Spawn(class'CWndUSA02BossEnd', Pawn);
          if (CWnd != none)
            CWnd.MyHudForFX = XIIIBaseHUD(XIIIPlayerController(XIII.controller).MyHud);*/
          BossState ++;
          Destination = CrashPoint.Location;
//          FocalPoint = CrashPoint.Location + vector(CrashPoint.Rotation)*5000;
          Pawn.Velocity=vect(0,0,0);
          Pawn.AirSpeed = 12000;
          Pawn.PlaySound(hDestructSound);
        }
        else
        {
          DebugLog("\ HelicoBoss -EndOfMe hCrash event");
          TriggerEvent('hCrash', self, Pawn);
          USA02HelicoBoss(Pawn).Notify();
          Pawn.Destroy();
          Destroy();
        }
      }
    }
    event BeginState()
    {
	  SetTimer(0.0, false);
      Pawn.AirSpeed = 1200;
      Pawn.SetCollision(false,false,false); // Clear colls to avoid anything being stuck in some background
      Pawn.bCollideWorld = false;
      Destination = EndPoint.Location;
      FocalPoint = Pawn.Location + vector(Pawn.Rotation) * 100;
      BossState = 7;
      DebugLog("\ HelicoBoss -EndOfMe BeginState");
	  //XIIIGameInfo(Level.Game).MapInfo.SetGoalComplete(91);
   }
}



defaultproperties
{
     vFocalPointOffset=(Z=380.000000)
     DefaultFiringTimer=4.000000
     fStabilityBeforeMissileDelay=1.000000
     hFireSound=Sound'XIIIsound.Guns__M60Fire.M60Fire__hM60Fire'
     hMissileFireSound=Sound'XIIIsound.Guns__BazFire.BazFire__hBazFire'
     DecalProjectorClass=Class'XIII.BulletScorch'
     MyDamageType=Class'XIII.DTGunned'
     MinAcquisitionTime=1.500000
     VMACHINEGUNOFFSET=(X=-640.000000,Z=90.000000)
     VMISSILEOFFSET=(X=-130.000000,Y=205.000000,Z=100.000000)
     hBeginFightMusic=Sound'XIIIsound.Music__USA02.USA02__hBeginFight'
     hHelicoTouchMusic=Sound'XIIIsound.Music__USA02.USA02__hHelicoTouch'
     hSnapShotSound=Sound'XIIIsound.Vehicles__USABossHelico.USABossHelico__hSnapShot'
     hDestructsound=Sound'XIIIsound.Vehicles__USABossHelico.USABossHelico__hDestruct'
     TraceClass=Class'XIDMaps.USA02HelicoBulletTrail'
     bControlAnimations=True
     bRotateToDesired=True
}
