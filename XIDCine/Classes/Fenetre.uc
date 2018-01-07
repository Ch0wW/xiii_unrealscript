//-----------------------------------------------------------
// Fenetre
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class Fenetre extends BreakableMover;

VAR(BreakableMover)	float	DelayBump;

EVENT Bump( actor Other )
{
	Super.Bump(Other);

	if (!bBroken)
	{
		Walker=Pawn(Other);
		if (Walker!=none)
			GotoState('STA_CheckBase');
	}
	else
		disable('Bump');
}

STATE STA_CheckBase
{
Begin:
	if (Walker.Base==self)
		Breaking(DelayBump);
	else
		GotoState('');
}



defaultproperties
{
     DelayBump=1.000000
     bMustShakeWhileDelay=True
     bVulnerableToFist=False
     FragmentTextureUSubdivisions=2
     FragmentTextureVSubdivisions=2
     bTraversable=True
}
