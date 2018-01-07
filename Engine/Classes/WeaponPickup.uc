// CHANGENOTE:  All changes to this class since v739 are related to the Weapon code updates.

class WeaponPickup extends Pickup
	abstract;

var() bool	  bWeaponStay;

//_____________________________________________________________________________
event ParseDynamicLoading(LevelInfo MyLI)
{
    Log("ParseDynamicLoading Actor="$self);
    class<Weapon>(default.InventoryType).Static.StaticParseDynamicLoading(MyLI);
//    MyLI.ForcedMeshes[MyLI.ForcedMeshes.Length] = mesh(DynamicLoadObject(class<Weapon>(default.InventoryType).default.MeshName, class'mesh'));
}

//_____________________________________________________________________________
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetWeaponStay();
    MaxDesireability = 1.2 * class<Weapon>(InventoryType).Default.AIRating;
}

function SetWeaponStay()
{
	bWeaponStay = bWeaponStay || Level.Game.bCoopWeaponMode;
}

// tell the bot how much it wants this weapon pickup
// called when the bot is trying to decide which inventory pickup to go after next
function float BotDesireability(Pawn Bot)
{
	local Weapon AlreadyHas;
	local float desire;

	// bots adjust their desire for their favorite weapons
	desire = MaxDesireability + Bot.Controller.AdjustDesireFor(self);

	// see if bot already has a weapon of this type
	AlreadyHas = Weapon(Bot.FindInventoryType(InventoryType));
	if ( AlreadyHas != None )
	{
		if ( (RespawnTime < 10)
			&& ( bHidden || (AlreadyHas.AmmoType == None)
				|| (AlreadyHas.AmmoType.AmmoAmount < AlreadyHas.AmmoType.MaxAmmo)) )
			return 0;

		// can't pick it up if weapon stay is on
		if ( bWeaponStay && ((Inventory == None) || Inventory.bTossedOut) )
			return 0;

		// bot wants this weapon for the ammo it holds
		if ( AlreadyHas.HasAmmo() )
			return FMax( 0.25 * desire,
					AlreadyHas.AmmoType.PickupClass.Default.MaxDesireability
					 * FMin(1, 0.15 * AlreadyHas.AmmoType.MaxAmmo/AlreadyHas.AmmoType.AmmoAmount) );
		else
			return 0.05;
	}

	// incentivize bot to get this weapon if it doesn't have a good weapon already
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating <= 0.4) )
		return 2*desire;

	return desire;
}

defaultproperties
{
     MaxDesireability=0.500000
     RespawnTime=30.000000
     PickupMessage="You got a weapon"
     Texture=Texture'Engine.S_Weapon'
}
