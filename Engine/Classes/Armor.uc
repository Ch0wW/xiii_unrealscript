//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Armor extends Inventory
  native
  abstract;

var() int ArmorAbsorption;                // Percent of damage item absorbs 0-100.
/*
var() enum DamageLocations
{
    LOC_Head,
    LOC_Body,
} ProtectedArea;                          // Area protezcted by the armor
*/
var() Pawn.DamageLocations ProtectedArea;

var() name BoneToAttach;                  // bone to attach the armor

//_____________________________________________________________________________
// Network replication.
replication
{
  // Things the server should send to the client.
  reliable if( Role==ROLE_Authority )
    ClientSetUpArmor;
}

//_____________________________________________________________________________
function PickupFunction(Pawn Other)
{
    Super.PickupFunction(Other);
    AttachArmorToPawn(Other);
}

//_____________________________________________________________________________
function bool HandlePickupQuery( Pickup Item )
{
	if (Item.InventoryType == class)
	{
        if( Item.IsA('MarioArmorAndMedKitPickUp') )
            Charge = 100;
        else
            Charge = Min(Default.Charge, Charge + ArmorPickup(Item).ProtectionLevel);

		Item.AnnouncePickup(Pawn(Owner));
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

//_____________________________________________________________________________
function Transfer( pawn Other )
{
    Super.Transfer(Other);
    if ( PickupClass != none )
    {
      Other.PlaySound(PickupClass.default.PickupSound);
      Other.ReceiveLocalizedMessage( PickupClass.default.MessageClass, 0, None, None, PickupClass );
    }
}

//_____________________________________________________________________________
function GiveTo( pawn Other )
{
    local Armor A;

    DetachFromPawn(Pawn(Owner));
    A = Armor(Other.FindInventoryType(class));
    if ( A == none )
    { // GiveTo
      Super.GiveTo(other);
      AttachArmorToPawn(Other);
      if ( ProtectedArea == LOC_Head )
        Other.Helm = self;
      else if ( ProtectedArea == LOC_Body )
        Other.Vest = self;
      ClientSetUpArmor(Other);
    }
    else
    { // Just get charges
		  A.Charge = Min(A.Default.Charge, A.Charge + class<ArmorPickup>(PickupClass).default.ProtectionLevel);
		  Destroy();
    }
}

//_____________________________________________________________________________
simulated function ClientSetUpArmor(Pawn Other)
{
    if (Other != none)
    {
//      Log(self@"ClientSetUpArmor for"@other);
      if ( ProtectedArea == LOC_Head )
        Other.Helm = self;
      else if ( ProtectedArea == LOC_Body )
        Other.Vest = self;
      Instigator = Other;
    }
    else
      SetTimer2(1.0, true);
}

//_____________________________________________________________________________
// Wait for pawn replication
simulated event Timer2()
{
    if ( Instigator != none )
    {
      if ( ProtectedArea == LOC_Head )
        Instigator.Helm = self;
      else if ( ProtectedArea == LOC_Body )
        Instigator.Vest = self;
      SetTimer2(0.0, false);
    }
    else if ( Pawn(Owner) != none )
    {
      if ( ProtectedArea == LOC_Head )
        Pawn(Owner).Helm = self;
      else if ( ProtectedArea == LOC_Body )
        Pawn(Owner).Vest = self;
      SetTimer2(0.0, false);
      Instigator = Pawn(Owner);
    }
}

//_____________________________________________________________________________
simulated function AttachArmorToPawn(Pawn P)
{
	local name BoneName;

	if ( ThirdPersonActor == None )
	{
		ThirdPersonActor = Spawn(AttachmentClass,Owner);
		InventoryAttachment(ThirdPersonActor).InitFor(self);
	}
	BoneName = BoneToAttach;
	if ( BoneName == '' )
	{
		ThirdPersonActor.SetLocation(P.Location);
		ThirdPersonActor.SetBase(P);
	}
	else
		P.AttachToBone(ThirdPersonActor,BoneName);

	ThirdPersonActor.SetRelativeLocation(ThirdPersonRelativeLocation);
	ThirdPersonActor.SetRelativeRotation(ThirdPersonRelativeRotation);
}

//_____________________________________________________________________________
// ELR Check if the armor should absorb damages with it's protectedarea
// Server function
function int ArmorAbsorbDamage(int Damage, class<DamageType> DamageType, vector HitLocation)
{
    local int ArmorDamage;

    if ( HitLocation.X == ProtectedArea )
    {
      //      Log(self@"ArmorAbsorbDamage charge="$Charge);
      ArmorDamage = (Damage * ArmorAbsorption) / 100;
      if( ArmorDamage >= Charge )
        ArmorDamage = Charge;

      Charge -= ArmorDamage;
      //      Log("    New charge="$Charge);
      if (Charge == 0)
      {
        if ( Pawn(Owner).Helm == self )
          Pawn(Owner).Helm = none;;
        if ( Pawn(Owner).Vest == self )
          Pawn(Owner).Vest = none;;
        /*
        if ( ProtectedArea == LOC_Head )
        Pawn(Owner).Helm = none;
        else if ( ProtectedArea == LOC_Body )
        Pawn(Owner).Vest = none;
        */
        Destroy();
      }
      return (Damage - ArmorDamage);
    }
    return Damage;
}

simulated event Destroyed()
{
    Super.Destroyed();
    //Log("ARMOR Destroyed for Instigator="@Instigator@"Owner="$Owner);
    if ( Instigator != none )
    {
      if ( ProtectedArea == LOC_Head )
        Instigator.Helm = none;
      else if ( ProtectedArea == LOC_Body )
        Instigator.Vest = none;
    }
}

defaultproperties
{
     bReplicateInstigator=True
}
