//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WaterVolume extends PhysicsVolume;



simulated function BeingHitByProjectile(vector HitLocation)
{
    spawn(class'WaterImpactEmitter',,,HitLocation);
}


function Emitter BeingHitByBullets(vector HitLocation, rotator Orientation, int HitSoundType)
{
    local WaterRingsEmitter WaterRing;
    WaterRing = spawn(class'WaterRingsEmitter',,,HitLocation,Orientation);
    if ( WaterRing != none )
    {
       WaterRing.PlayImpactSound(HitSoundType);
       WaterRing.Emitters[1].UseRotationFrom = PTRS_Actor;
    }
    return WaterRing;
}


defaultproperties
{
     EntrySound=Sound'XIIIsound.XIIIPerso__WaterIO.WaterIO__WaterGetIn'
     ExitSound=Sound'XIIIsound.XIIIPerso__WaterIO.WaterIO__WaterGetOut'
     EntryActor=Class'Gameplay.WaterImpactEmitter'
     EntryNonPawnActor=Class'Gameplay.WaterRingsEmitter'
     FluidFriction=2.400000
     bWaterVolume=True
     bDistanceFog=True
     DistanceFogColor=(B=128,G=64,R=32,A=64)
     DistanceFogStart=8.000000
     DistanceFogEnd=2000.000000
     LocationName="under water"
     bCanShootThroughWithRayCastingWeapon=False
     bCanShootThroughWithProjectileWeapon=False
}
