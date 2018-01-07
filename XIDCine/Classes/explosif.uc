//-----------------------------------------------------------
// Explosif
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class Explosif extends BreakableMover;


VAR(Damage) float DamageRadius;
VAR(Damage) float DamageAmount;

//_____________________________________________________________________________
// ELR added damages when exploding
function BlowUp(vector HitLocation)
{
	HurtRadius( DamageAmount, DamageRadius, class'DTGrenaded', 0, HitLocation );
	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

FUNCTION Breaked()
{
	BlowUp(Location);	// ELR Added Damages when exploding
	Super.Breaked();
}



defaultproperties
{
     DamageRadius=1000.000000
     DamageAmount=150.000000
     SoundWhenBroken=Sound'XIIIsound.Explo__MoverExplo.MoverExplo__hMoverExplo'
}
