//-----------------------------------------------------------
//
//-----------------------------------------------------------
class USA02HelicoMissile extends XIIIProjectile;

#exec OBJ LOAD FILE=XIIICine.utx PACKAGE=XIIICine

var rotator rHit;
var MovableLight ML1, ML2, ML3, ML4;
var USA02HelicoMissileTrailEmitter MT;
var bool bDestroyMT;

//_____________________________________________________________________________
// Set up speed
simulated function PostBeginPlay()
{
    //Log("--> Spawn projectile"@self);
    Super.PostBeginPlay();
//    spawn(class'XIII.GrenadExplosionEmitter',,,Location);

    ML1 = Spawn(class'MovableLight', self,, Location - vector(rotation) * 30.0);
    ML1.SetRelativeLocation(vect(-30,0,0));
    ML1.SetBase(self);
    ML1.Texture = Texture'XIIICine.Hjaune04';
    ML1.SetDrawScale(4.0);
    ML1.Style = STY_Translucent;
    ML1.bHidden = false;
    ML1.bDynamicLight = True;

    ML2 = Spawn(class'MovableLight', self,, Location - vector(rotation) * 60.0);
    ML2.SetRelativeLocation(vect(-60,0,0));
    ML2.SetBase(self);
    ML2.Texture = Texture'XIIICine.Hred03';
    ML2.SetDrawScale(5.0);
    ML2.Style = STY_Translucent;
    ML2.bHidden = false;
    ML2.bDynamicLight = True;

    ML3 = Spawn(class'MovableLight', self,, Location - vector(rotation) * 90.0);
    ML3.SetRelativeLocation(vect(-90,0,0));
    ML3.SetBase(self);
    ML3.Texture = Texture'XIIICine.Hred03';
    ML3.SetDrawScale(5.0);
    ML3.Style = STY_Translucent;
    ML3.bHidden = false;
    ML3.bDynamicLight = True;

    ML4 = Spawn(class'MovableLight', self,, Location - vector(rotation) * 120.0);
    ML4.SetRelativeLocation(vect(-120,0,0));
    ML4.SetBase(self);
    ML4.Texture = Texture'XIIICine.Hred03';
    ML4.SetDrawScale(3.0);
    ML4.Style = STY_Translucent;
    ML4.bHidden = false;
    ML4.bDynamicLight = True;

    MT = spawn(class'USA02HelicoMissileTrailEmitter', self);
    MT.SetBase(Self);
    MT.SetRelativeLocation(vect(0,0,0));
    MT.SetRelativeRotation(rot(0,0,0));

	//Cho 30/04/03 : on diminue la vitesse de la roquette
    Velocity = Vector(Rotation) * Speed*0.75;
    SetTimer2(0.5, false);
}

//_____________________________________________________________________________
simulated event Timer2()
{
    SetCollision(true,true,true);
}

//_____________________________________________________________________________
simulated event Timer()
{
    if ( bDestroyMT )
    {
      MT.Destroy();
      Destroy();
    }
    else
    {
      if ( bSpawnDecal && (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
        Spawn(ExplosionDecal,self,,Location, rHit);
      bDestroyMT = true;
      SetTimer(1.1, false);
    }
}

//_____________________________________________________________________________
simulated function Explode(vector HitLocation, vector HitNormal)
{
    BlowUp(HitLocation);
    if ( Level.NetMode != NM_DedicatedServer )
    {
      Spawn(class'BazookExplosionEmitter',,,HitLocation + HitNormal*50,rotator(HitNormal));
    }
    rHit = rotator(-HitNormal);
    SetPhysics(PHYS_None);
    Velocity = vect(0,0,0);
    bHidden = true;
    ML1.Destroy();
    ML2.Destroy();
    ML3.Destroy();
    ML4.Destroy();
/*
    MT.AutoDestroy=true;
    MT.AutoReset=false;
*/
    SetTimer(0.8, false);
}

//_____________________________________________________________________________
// Override ProcessTouch
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    Instigator = Pawn(Owner);
    Super.Processtouch(other, HitLocation);
}



defaultproperties
{
     hExploSound=Sound'XIIIsound.Explo__ExploBaz.ExploBaz__hExploBaz'
     Speed=2000.000000
     MaxSpeed=4000.000000
     Damage=250.000000
     DamageRadius=750.000000
     MomentumTransfer=80000.000000
     MyDamageType=Class'XIII.DTGrenaded'
     ExplosionDecal=Class'XIII.BazookBlast'
     bCollideActors=False
     DrawType=DT_StaticMesh
     LifeSpan=6.000000
     StaticMesh=StaticMesh'Meshes_Vehicules.Missile'
     SaturationDistance=600.000000
     StabilisationDistance=3500.000000
     StabilisationVolume=-10.000000
}
