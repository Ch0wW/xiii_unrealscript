//=============================================================================
// Interro.
//=============================================================================
class Interro extends Effects;


/*function timer()
{
	if (owner==none)
	  destroy();
}*/

function PostBeginPlay()
{
	super.PostBeginPlay();
	//settimer(0.8,true);
}



defaultproperties
{
     Texture=Texture'XIIIMenu.HUD.Interrogation'
     DrawScale3D=(X=0.900000,Y=0.700000,Z=0.700000)
}
