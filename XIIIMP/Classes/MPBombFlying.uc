//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MPBombFlying extends XIIIProjectile;

var bool bCanHitOwner, bHitWater;
var bool bArmed;
var float Count, SmokeRate;
var int NumExtraGrenades;
var float fLifeTime;                // duration before explosion

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
      Velocity.z += 20;
      MaxSpeed = 100;
//      RandSpin(50000);
      bCanHitOwner = False;
      if (Instigator.HeadVolume.bWaterVolume)
      {
        bHitWater = True;
        Disable('Tick');
        Velocity=0.6*Velocity;
      }
    }
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
    if ( !bArmed )
    { // set the timer back one the fLifeTime has been initialized by the weapon
      bArmed=true;
      fLifeTime = fMax(0.05, fLifeTime);
      SetTimer(fLifeTime, false);
      return;
    }

    if ( bSpawnDecal )
    {
      if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
        Spawn(ExplosionDecal,self,,Location, rotator(vect(0,0,-1)));
      Destroy();
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
    HitWall( HitNormal, None );
}

//_____________________________________________________________________________
simulated function ProcessTouch( actor Other, vector HitLocation )
{
    Local vector vt;

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
    MyTrail.RotationSpeed *= 2.0;

    if (Wall != none)
      PlayImpactSound(-normal(velocity), Wall);
    bCanHitOwner = True;
//    Velocity = 0.25*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
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
    //FRD   appel GenAlerte pour gestion grenade
    if (level.bLonePlayer) XIIIGameInfo(level.game).genalerte.untrigger(self,instigator);

    BlowUp(HitLocation);
    TriggerEvent('MPBombingBase', self, Instigator); // trigger all the bombing bases to activate goal if necessary
    if ( Level.NetMode != NM_DedicatedServer )
    {
      spawn(class'XIII.GrenadExplosionEmitter',,,Location + vect(0,0,1)*50,rotator(vect(0,0,1)));
    }
}



defaultproperties
{
     fLifeTime=-5.000000
     bSpawnDecal=False
     HitSoundType=4
     MyTrailClass=Class'XIII.GrenadTrail'
     StaticMeshName="MeshArmesPickup.BombeMagnet"
     ShakeMag=900.000000
     shaketime=7.000000
     ShakeVert=(X=5.000000,Y=10.000000,Z=-25.000000)
     ShakeSpeed=(X=300.000000,Y=300.000000,Z=300.000000)
     ShakeCycles=2.000000
     Speed=80.000000
     MaxSpeed=100.000000
     Damage=1000.000000
     DamageRadius=1200.000000
     MomentumTransfer=80000.000000
     MyDamageType=Class'XIII.DTGrenaded'
     ExplosionDecal=Class'XIII.GrenadBlast'
     bBlockActors=True
     bFixedRotationDir=True
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     LifeSpan=7.000000
     SaturationDistance=600.000000
     StabilisationDistance=3500.000000
     StabilisationVolume=-10.000000
}
