//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPGRInstaKill extends GameRules;

//_____________________________________________________________________________
function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
    Log("GameRule modify NetDamage to instaKill");
  	return 10000;
}



defaultproperties
{
}
