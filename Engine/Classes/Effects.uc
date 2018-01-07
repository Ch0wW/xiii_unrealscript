//=============================================================================
// Effects, the base class of all gratuitous special effects.
// 
//=============================================================================
class Effects extends Actor;

var() sound 	EffectSound1;

defaultproperties
{
     bNetTemporary=True
     bUnlit=True
     bGameRelevant=True
     RemoteRole=ROLE_None
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
