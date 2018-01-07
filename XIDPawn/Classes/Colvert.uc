//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Colvert extends XIIIAmbientPawn;

var vector direction;
var xiiiplayerpawn XIII;
var Xiiigameinfo gameinf;
var float AltitudeDepart;
var float AltitudeMax;


State DuckDying
{
ignores Trigger, animend, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;
	function Landed(vector HitNormal)
	{
		if (vsize(velocity)<50)
		{
			SetPhysics(PHYS_None);
			SetCollision(false, false, false);
		}
	}
	event timer()
	{
		if ((self.location-xiii.location) dot vector(xiii.rotation)<0 || !Fasttrace(xiii.location))
			destroy();
	}
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType) {}
Begin:
	settimer(2,true);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	if (health<=0)
		return;
	spawn(class'DeadDuckEmitter');
	health=0;
	Died(none, damageType, HitLocation);
	AddVelocity(momentum/Mass);
}

//_____________________________________________________________________________
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    PlayDying(DamageType, HitLocation);
	 bCollideWorld=true;
	 playanim('plane',5);
    GotoState('DuckDying');
}


function PlayFlying()
{
   loopanim('vole',1.5);
}

event timer()
{
	if (!Fasttrace(xiii.location))
		destroy();
	else if (abs(location.z-AltitudeDepart)>AltitudeMax)
	{
		velocity=300*direction*vect(1,1,0);
		acceleration=velocity;
		setrotation(rotator(velocity));
		loopanim('plane');
	}
}
// ----------------------------------------------------------------------
// ETAT INIT
//
//
// ----------------------------------------------------------------------
auto state init
{

begin:
	setphysics(PHYS_Flying);
	direction=vector(rotation);
	velocity=300*direction;
	acceleration=velocity;
	direction=10000*direction+location;
	settimer(3,true);
	AltitudeDepart=location.z;
	XIII=XIIIPlayerpawn(xiiigameinfo(level.game).mapinfo.XIIIpawn);
	if (XIII==none || xiii.bisdead)
		destroy();
	PlayFlying();
}

	 //bBlockZeroExtentTraces=false
    //bBlockNonZeroExtentTraces=false


defaultproperties
{
     AltitudeMax=800.000000
     Health=1
     ControllerClass=None
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     Mesh=SkeletalMesh'XIIIPersos.CanardM'
     SaturationDistance=800.000000
     StabilisationDistance=2500.000000
     CollisionHeight=20.000000
}
