//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Neon extends BreakableMover;

var() ScriptedLight AttachedLight;

function PostBeginPlay()
{
    if (AttachedLight!=none)
    {
        if (AttachedLight.bInitiallyOn)
            bUnlit=true;
        else
            bUnlit=false;
        Tag=AttachedLight.Tag;
    }
    else
    {
        Disable('Trigger');
    }
    Super.PostBeginPlay();
}

function Trigger( actor Other, pawn EventInstigator )
{
    bUnlit=!bUnlit;
}

event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    AttachedLight.InitialBrightness=0;
    AttachedLight.LightBrightness=0;
    AttachedLight.Destroy();
    super.TakeDamage( Damage, EventInstigator, HitLocation, Momentum, DamageType);
}








defaultproperties
{
}
