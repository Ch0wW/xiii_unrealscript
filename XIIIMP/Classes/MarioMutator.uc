//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MarioMutator extends XIIIMPMutator;

var class<Inventory> HeavyWeaponInventoryType[7];
var localized string HeavyWeaponPickupMessage[7];
var sound HeavyWeaponPickupSound[7];

var class<Inventory> SmallWeaponInventoryType[7];
var localized string SmallWeaponPickupMessage[7];
var sound SmallWeaponPickupSound[7];

var class<Inventory> ArmorAndMedKitInventoryType[7];
var localized string ArmorAndMedKitPickupMessage[7];
var sound ArmorAndMedKitPickupSound[7];

var int ArmorAndMedKitNumber,SmallWeaponNumber,HeavyWeaponNumber;

var string HeavyWeaponPickupName;
var string SmallWeaponPickupName;
var string ArmorAndMedKitPickupName;
var string MarioSuperBonusName;

//______________________________________________________________________________
function bool IsItemInTheList( int ListId, PickUp Test )
{
    local int Loop;
    local bool Result;

    Result = false;

    switch( ListId )
    {
        case 0 : //Heavy Weapon
            for( Loop = 0; Loop<HeavyWeaponNumber;Loop++)
            {
                if( HeavyWeaponInventoryType[ Loop ] == Test.InventoryType )
                {
                    Result = true;
                    break;
                }
            }

            break;
        case 1 : //Small Weapon
            for( Loop = 0; Loop<SmallWeaponNumber;Loop++)
            {
                if( SmallWeaponInventoryType[ Loop ] == Test.InventoryType )
                {
                    Result = true;
                    break;
                }
            }

            break;
        case 2 : //Armor And MedKit
            for( Loop = 0; Loop<ArmorAndMedKitNumber;Loop++)
            {
                if( ArmorAndMedKitInventoryType[ Loop ] == Test.InventoryType )
                {
                    Result = true;
                    break;
                }
            }

            break;
    }

    return Result;
}

//______________________________________________________________________________

function InitItemsLists()
{
    local PickUp A;

    foreach DynamicActors(class'PickUp', A)
    {
        if( XIIIWeaponPickUp(A) != none )
        {
            if( XIIIWeaponPickUp(A).MaxDesireability != 10 ) // Fusil de Chasse present pour les dynamic loading
            {
                if( XIIIWeaponPickUp(A).MaxDesireability < 3 )
                {
                    if( ! IsItemInTheList( 0 , A ) )
                    {
                        HeavyWeaponInventoryType[ HeavyWeaponNumber ] = A.InventoryType;
                        HeavyWeaponPickupMessage[ HeavyWeaponNumber ] = A.PickupMessage;
                        HeavyWeaponPickupSound[ HeavyWeaponNumber ] = A.PickupSound;
                        HeavyWeaponNumber++;
                    }
                }
                else
                {
                    if( ! IsItemInTheList( 1 , A ) )
                    {
                        SmallWeaponInventoryType[ SmallWeaponNumber ] = A.InventoryType;
                        SmallWeaponPickupMessage[ SmallWeaponNumber ] = A.PickupMessage;
                        SmallWeaponPickupSound[ SmallWeaponNumber ] = A.PickupSound;
                        SmallWeaponNumber++;
                    }
                }
            }
        }
        else if( ( XIIIArmorPickUp(A) != none ) || ( MultiPlayerMedPickUp(A) != none ) )
        {
            if( ! IsItemInTheList( 2 , A ) )
            {
                ArmorAndMedKitInventoryType[ ArmorAndMedKitNumber ] = A.InventoryType;
                ArmorAndMedKitPickupMessage[ ArmorAndMedKitNumber ] = A.PickupMessage;
                ArmorAndMedKitPickupSound[ ArmorAndMedKitNumber ] = A.PickupSound;
                ArmorAndMedKitNumber++;
            }
        }
    }
}

//______________________________________________________________________________

event PreBeginPlay()
{
    local int Loop;

    InitItemsLists();
}

//______________________________________________________________________________

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if ( DBMutator ) Log("MUTATOR CheckReplacement for"@Other);

    if ( (Level.Game != none) && Level.Game.bWaitingToStartMatch )
    {
      if ( XIIIWeaponPickup(Other) != none )
      {
        if( XIIIWeaponPickUp(Other).MaxDesireability > 2 )
          ReplaceWith(Other, SmallWeaponPickupName);
        else
          ReplaceWith(Other, HeavyWeaponPickupName);
      }
      else if( XIIIArmorPickUp(Other) != none )
      {
        ReplaceWith(Other, ArmorAndMedKitPickupName);
      }
      else if( MultiPlayerMedPickUp(Other) != none )
      {
        ReplaceWith(Other, MarioSuperBonusName);
      }
      else if( XIIIAmmoPick(Other) != none )
      {
        Other.Destroy();
      }
    }

    return true;
}

//______________________________________________________________________________



defaultproperties
{
     HeavyWeaponPickupName="XIIIMP.MarioHeavyWeaponPickUp"
     SmallWeaponPickupName="XIIIMP.MarioSmallWeaponPickUp"
     ArmorAndMedKitPickupName="XIIIMP.MarioArmorAndMedKitPickUp"
     MarioSuperBonusName="XIIIMP.MarioSuperBonusPickUp"
}
