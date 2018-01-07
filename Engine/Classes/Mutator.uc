//=============================================================================
// Mutator.
//
// Mutators allow modifications to gameplay while keeping the game rules intact.
// Mutators are given the opportunity to modify player login parameters with
// ModifyLogin(), to modify player pawn properties with ModifyPlayer(), to change
// the default weapon for players with GetDefaultWeapon(), or to modify, remove,
// or replace all other actors when they are spawned with CheckRelevance(), which
// is called from the PreBeginPlay() function of all actors except those (Decals,
// Effects and Projectiles for performance reasons) which have bGameRelevant==true.
//=============================================================================
class Mutator extends Info
	native;

var Mutator NextMutator;
var class<Weapon> DefaultWeapon;
var string DefaultWeaponName;

//_____________________________________________________________________________
// Don't call Actor PreBeginPlay() for Mutator
event PreBeginPlay();

//_____________________________________________________________________________
// Modify the login (add option if not present...) before it is treated
function ModifyLogin(out string Portal, out string Options)
{
    if ( NextMutator != None )
    NextMutator.ModifyLogin(Portal, Options);
}

//_____________________________________________________________________________
// called by GameInfo.RestartPlayer()
//	change the players jumpz, etc. here
// call isAddDefaultInventory -> SetPlayerDefaults -> ModifyPlayer
function ModifyPlayer(Pawn Other)
{
    if ( NextMutator != None )
      NextMutator.ModifyPlayer(Other);
}

//_____________________________________________________________________________
// return what should replace the default weapon
// mutators further down the list override earlier mutators
function Class<Weapon> GetDefaultWeapon()
{
    local Class<Weapon> W;

    if ( NextMutator != None )
    {
      W = NextMutator.GetDefaultWeapon();
      if ( W == None )
        W = MyDefaultWeapon();
    }
    else
      W = MyDefaultWeapon();
    return W;
}

//_____________________________________________________________________________
function class<Weapon> MyDefaultWeapon()
{
    if ( (DefaultWeapon == None) && (DefaultWeaponName != "") )
      DefaultWeapon = class<Weapon>(DynamicLoadObject(DefaultWeaponName, class'Class'));

    return DefaultWeapon;
}

//_____________________________________________________________________________
function AddMutator(Mutator M)
{
    if ( NextMutator == None )
      NextMutator = M;
    else
      NextMutator.AddMutator(M);
}

//_____________________________________________________________________________
// ReplaceWith()
// Call this function to replace an actor Other with an actor of aClass.
function bool ReplaceWith(actor Other, string aClassName)
{
    local Actor A;
    local class<Actor> aClass;

    if ( Other.IsA('Inventory') && (Other.Location == vect(0,0,0)) )
      return false;
    aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
    if ( aClass != None )
      A = Spawn(aClass,Other.Owner,Other.tag,Other.Location, Other.Rotation);
    if ( Other.IsA('Pickup') )
    {
      if ( Pickup(Other).MyMarker != None )
      {
        Pickup(Other).MyMarker.markedItem = Pickup(A);
        if ( Pickup(A) != None )
        {
          Pickup(A).MyMarker = Pickup(Other).MyMarker;
          A.SetLocation(A.Location
            + (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
        }
        Pickup(Other).MyMarker = None;
      }
      else if ( A.IsA('Pickup') )
        Pickup(A).Respawntime = 0.0;
    }
    if ( A != None )
    {
      A.event = Other.event;
      A.tag = Other.tag;
      return true;
    }
    return false;
}

//_____________________________________________________________________________
// the function called in each Actor PreBeginPlay
function bool CheckRelevance(Actor Other)
{
    local bool bResult;
    local byte bSuperRelevant;

    if ( AlwaysKeep(Other) )
      return true;

    // allow mutators to remove actors
    bResult = IsRelevant(Other, bSuperRelevant);
    return bResult;
}

//_____________________________________________________________________________
// Force game to always keep this actor, even if other mutators want to get rid of it
function bool AlwaysKeep(Actor Other)
{
    if ( NextMutator != None )
      return ( NextMutator.AlwaysKeep(Other) );
    return false;
}

//_____________________________________________________________________________
function bool IsRelevant(Actor Other, out byte bSuperRelevant)
{
    local bool bResult;

    bResult = CheckReplacement(Other, bSuperRelevant);
    if ( bResult && (NextMutator != None) )
      bResult = NextMutator.IsRelevant(Other, bSuperRelevant);

    return bResult;
}

//_____________________________________________________________________________
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    return true;
}

defaultproperties
{
}
