//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Prock03_Fioles extends TKnifeFlying;

var int NbDegats;
var vector PointDExplosion;

//_____________________________________________________________________________
// Set up speed
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    Velocity = Vector(Rotation) * Speed;
    Velocity.z += 100;
    RotationRate.Pitch = -80000;
	 SetPhysics(PHYS_Falling);
}


simulated function Explode(vector HitLocation, vector HitNormal)
{
    BlowUp(HitLocation);
    Spawn(class'Prock03FioleExploEmitter');
    SetPhysics(PHYS_None);
    Velocity = vect(0,0,0);
    bHidden = true;
	 SetDrawtype(DT_none);
	 settimer(0.7,true);
    //destroy();
}

//_____________________________________________________________________________
simulated function BlowUp(vector HitLocation)
{
    if ( bHaveBlownUp )
      return;

    bHaveBlownUp=true;
    PointDExplosion=HitLocation;
    HurtRadius1(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
    PlaySound(hExploSound);
}

event timer()
{
	if (NbDegats<10)
	{
		HurtRadius1(10,DamageRadius, MyDamageType, MomentumTransfer, PointDExplosion );
		NbDegats++;
	}
	else
	{
		destroy();
	}
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated final function HurtRadius1( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
     local actor Victims;
     local float damageScale, dist;
     local vector dir;

     if( bHurtEntry )
          return;

     bHurtEntry = true;
     foreach VisibleDamageableActors( class 'Actor', Victims, DamageRadius, HitLocation )
     {
          if(Victims != self)
          {
               //FRD
               /*if (xiiiplayerpawn(victims)!=none)
               {
                   JOhansson(instigator).GenEffects.XIIIBurned();
               }
               else */if (victims.isa('johansson'))
                  continue;
               //
               dir = Victims.Location - HitLocation;
               dist = FMax(1,VSize(dir));
               dir = dir/dist;
               damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
               Victims.TakeDamage
               (
                    damageScale * DamageAmount,
                    Instigator,
                    Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                    (damageScale * Momentum * dir),
                    DamageType
               );
          }
     }
     bHurtEntry = false;
}



defaultproperties
{
     MyTrailClass=Class'XIII.GrenadTrail'
     Speed=900.000000
     MaxSpeed=2000.000000
     DamageRadius=350.000000
     bFixedRotationDir=True
     StaticMesh=StaticMesh'MeshArmesPickup.fiole'
     Mass=400.000000
}
