//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Sanc02bMutator extends XIIISoloMutator;

//_____________________________________________________________________________
function bool CheckRelevance(Actor Other)
{
	log (Other);
	if ( Other.IsA('XIIIScorch') || Other.IsA('Trail'))
		Sanc02b(XIIIGameInfo(Level.Game).MapInfo).SomeoneShoots( Pawn(Other.Owner) );
    return Super.CheckRelevance(other);
}



defaultproperties
{
}
