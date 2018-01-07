//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FlashBangFlying extends XIIIProjectile;

var bool bCanHitOwner, bHitWater;
var bool bArmed;
var bool bCleanFlash;

var float Count, SmokeRate;
var int NumExtraGrenades;
var float fLifeTime;                // duration before explosion
var array<Controller> FlashController;

replication
{
    Reliable if ( Role == ROLE_Authority )
      fLifeTime;
}

//_____________________________________________________________________________
// Set up speed
simulated function PostBeginPlay()
{
    local vector X,Y,Z;
    local rotator RandRot;

    Super.PostBeginPlay();
    bArmed=false;
    fLifeTime = 5.0;        // Set this just in case it will be thrown by no player thus intialized after postbeginplay
    SetTimer(0.1,false);    // Call it again later with the right intialized lifetime

    if ( Role == ROLE_Authority )
    {
      GetAxes(Instigator.GetViewRotation(),X,Y,Z);
      Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed + FRand() * 100);
      Velocity.z += 210;
      MaxSpeed = 1000;
      RandSpin(50000);
      bCanHitOwner = False;
      if (Instigator.HeadVolume.bWaterVolume)
      {
        bHitWater = True;
        Disable('Tick');
        Velocity=0.6*Velocity;
      }
    }
    //FRD   appel GenAlerte pour gestion grenade
    // ELR No use for FlashBangs as multi only
//    if (level.bLonePlayer) XIIIGameInfo(level.game).genalerte.trigger(self, instigator);

    MyTrail = Spawn(MyTrailClass,self,,Location);
    MyTrail.Init();
}

//_____________________________________________________________________________
simulated function BeginPlay()
{
    SmokeRate = 0.15;
}

//_____________________________________________________________________________
simulated function Timer()
{
//    Log("GRENAD"@self@"Timer");

    if ( !bArmed )
    { // set the timer back one the fLifeTime has been initialized by the weapon
      bArmed=true;
      fLifeTime = fMax(0.05, fLifeTime);
      SetTimer(fLifeTime, false);
      return;
    }

    if ( bSpawnDecal )
    {
      if ( bCleanFlash )
      {
        UnFlash();
        Destroy();
      }
      else
      {
        if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
          Spawn(ExplosionDecal,self,,Location, rotator(vect(0,0,-1)));
        bCleanFlash = true;
        SetTimer(4.8, false);
      }
    }
    else
    {
      Explosion(Location+Vect(0,0,1)*16);
      bSpawnDecal = true;
      SetTimer(0.2, false);
    }
}

//_____________________________________________________________________________
simulated function Landed( vector HitNormal )
{
//    Log("GRENAD"@self@"Landed");
    HitWall( HitNormal, Base );
}

//_____________________________________________________________________________
simulated function ProcessTouch( actor Other, vector HitLocation )
{
    Local vector vt;

    if ( Pawn(Other) != none )
    {
      vT = Location - Other.Location;
      if ( VT.Z > Other.CollisionRadius * 0.9 )
      {
//        Log("GRENAD should bounce off pawn"@other@"head");
        vt = HitLocation - Other.Location;
        vT.Z = 0;
        Velocity = 0.3*Speed*(normal(vT) + vect(0,0,1));
//        Velocity = normal(vT)*vSize(Velocity);
        Speed = vSize(Velocity);
//        HitWall( normal(normal(vt) + vect(0,0,1)), Other );
        return;
      }
//      else
//        Log("GRENAD Hit pawn side, std bounce");
    }
    if ( (Other!=instigator) || bCanHitOwner )
    {
      Velocity = 0.2*Velocity;
      vt = HitLocation - Other.Location;
      HitWall( normal(vt), None );
    }
}

//_____________________________________________________________________________
simulated function HitWall( vector HitNormal, actor Wall )
{
//    Log("GRENAD"@self@"HitWall"@Wall@"HitNormal="@HitNormal);
    Local vector vt;

    MakeNoise(ImpactNoise);
    MyTrail.RotationSpeed *= 2.0;

    if ( Pawn(Wall) != none )
    {
      vT = Location - Wall.Location;
      if ( VT.Z > Wall.CollisionRadius * 0.9 )
      {
//        Log("GRENAD should bounce off pawn"@Wall@"head");
        vt = Location - Wall.Location;
        vT.Z = 0;
        Velocity = 0.3*Speed*(normal(vT) + vect(0,0,1));
//        Velocity = normal(vT)*vSize(Velocity);
        Speed = vSize(Velocity);
//        HitWall( normal(normal(vt) + vect(0,0,1)), Other );
        return;
      }
//      else
//        Log("GRENAD Hit pawn side, std bounce");
    }

    if (Wall != none)
      PlayImpactSound(-normal(velocity), Wall);

    bCanHitOwner = True;
    Velocity = 0.25*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
    speed = VSize(Velocity);
    if ( Velocity.Z > 400 )
      Velocity.Z = 0.5 * (400 + Velocity.Z);
    else if ( (speed < 10) && (Wall != none) ) // don't stop of touching and not hitting real wall.
    {
      bBounce = False;
      SetPhysics(PHYS_None);
    }
}

//_____________________________________________________________________________
simulated function Explosion(vector HitLocation)
{
//    Log("GRENAD"@self@"Explosion");
    //FRD   appel GenAlerte pour gestion grenade
    // ELR No use for FlashBangs as multi only
//    if (level.bLonePlayer) XIIIGameInfo(level.game).genalerte.untrigger(self,instigator);

//    BlowUp(HitLocation);
// FlashBangs don't blow up but set flashes on controllers.
    Flash(Location);
    SetDrawType(DT_None);
    SetPhysics(PHYS_none);
    Velocity = vect(0,0,0);
    if ( Level.NetMode != NM_DedicatedServer )
    {
      spawn(ExplosionEmitterClass,,,Location + vect(0,0,1)*50,rotator(vect(0,0,1)));
    }
    PlaySound(hExploSound,0,1,2);
}

//_____________________________________________________________________________
function Flash(vector Loc)
{
    local Controller C;
    local actor A;
    local vector hitLoc, HitNorm;
    local material HitMat;

    Log("FLASH");
    for (C=Level.ControllerList; C!=none; C=C.NextController)
    {
      if ( (PlayerController(C) != none) )
      {
        Log("  test on flashing "$C);
        if ( FastTrace(Location, C.Pawn.Location + C.Pawn.EyePosition()) )
        {
//          Log("FlashBang angle="$vector(C.Rotation) dot normal(Location - C.Pawn.Location + C.Pawn.EyePosition()));
          if ( vector(C.Rotation) dot normal(Location - C.Pawn.Location - C.Pawn.EyePosition()) > 0.68 )
          {
            Log("   Flashing "$C);
            FlashController[FlashController.Length] = C; // Add C to UnFlash list, optimize the unflash process
            PlayerController(C).ClientFilter(
              class'Canvas'.Static.MakeColor(255,255,255,255),
              class'Canvas'.Static.MakeColor(255,255,255,255),
              0.5
              );
            PlayerController(C).ClientHighLight( class'Canvas'.Static.MakeColor(255,255,255,75), 0.75);
            XIIIPlayerController(C).ClientTargetHighLight( 75, 0.0, 16.0);
          }
        }
        else
        { // long trace because CanSeeThrough
          A = Trace(HitLoc, HitNorm, Location, C.Pawn.Location + C.Pawn.EyePosition(), true, vect(0,0,0), HitMat, TRACETYPE_DiscardIfCanSeeThrough);
          if ( A == none )
          {
            if ( vector(C.Rotation) dot normal(Location - C.Pawn.Location - C.Pawn.EyePosition()) > 0.68 )
            {
              Log("   Flashing "$C);
              FlashController[FlashController.Length] = C; // Add C to UnFlash list, optimize the unflash process
              PlayerController(C).ClientFilter(
                class'Canvas'.Static.MakeColor(255,255,255,255),
                class'Canvas'.Static.MakeColor(255,255,255,255),
                0.5
                );
                PlayerController(C).ClientHighLight( class'Canvas'.Static.MakeColor(255,255,255,75), 0.75);
                XIIIPlayerController(C).ClientTargetHighLight( 75, 0.0, 16.0);
            }
          }
        }
      }
      else if( BotController(C) != none  )
      {
        if ( FastTrace(Location, C.Pawn.Location + C.Pawn.EyePosition()) )
        {
          if ( vector(C.Rotation) dot normal(Location - C.Pawn.Location + C.Pawn.EyePosition()) > 0.707 )
          {
            FlashController[FlashController.Length] = C; // Add C to UnFlash list, optimize the unflash process
            BotController(C).Flashed();
          }
        }
      }
    }
}

//_____________________________________________________________________________
function UnFlash()
{
    local Controller C;
    local int i;

    Log("UNFLASH");
    for (i=0; i<FlashController.Length; i++)
    {
      C = FlashController[i];
      Log("  unflashing "$C);
      if ( (PlayerController(C) != none) )
      {
        PlayerController(FlashController[i]).ClientFilter(
          class'Canvas'.Static.MakeColor(255,255,255,255),
          class'Canvas'.Static.MakeColor(128,128,128,255),
          0.15
        );
        XIIIPlayerController(C).ClientTargetHighLight( 0, 0, 2.0);
      }
      else if( BotController(C) != none  )
        BotController(C).DamnedImFlashed = False;
    }
}




defaultproperties
{
     fLifeTime=-5.000000
     bSpawnDecal=False
     HitSoundType=4
     hExploSound=Sound'XIIIsound.Multi.flashbang'
     MyTrailClass=Class'XIIIMP.FlashBangTrail'
     StaticMeshName="MeshArmesPickup.FlashBang"
     ShakeMag=900.000000
     shaketime=7.000000
     ShakeVert=(X=5.000000,Y=10.000000,Z=-25.000000)
     ShakeSpeed=(X=300.000000,Y=300.000000,Z=300.000000)
     ShakeCycles=2.000000
     ExplosionEmitterClass=Class'XIII.GrenadExplosionEmitter'
     Speed=800.000000
     MaxSpeed=1000.000000
     Damage=350.000000
     DamageRadius=1200.000000
     MomentumTransfer=80000.000000
     MyDamageType=Class'XIII.DTGrenaded'
     ExplosionDecal=Class'XIII.GrenadBlast'
     bBlockActors=True
     bBounce=True
     bFixedRotationDir=True
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     LifeSpan=15.000000
     SaturationDistance=600.000000
     StabilisationDistance=3500.000000
     StabilisationVolume=-10.000000
}
