//=============================================================================
// Info, the root of all information holding classes.
//=============================================================================
class Info extends Actor
	abstract
	hidecategories(Movement,Collision,Lighting,LightColor,Force)
	native;

defaultproperties
{
     bHidden=True
     bInteractive=False
     bSkipActorPropertyReplication=True
     bOnlyDirtyReplication=True
}
