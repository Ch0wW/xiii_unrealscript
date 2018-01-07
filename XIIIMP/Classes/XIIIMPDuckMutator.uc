//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPDuckMutator extends MPBombMutator;

var string defaultAmmoPickupName; // to replace ammo picks by default one
var string GrenadPickupName; // to replace ammo picks by default one
var class<Actor> defaultAmmoPickupClass;
var string DuckPickupName;
var bool DuckWasAdded;


//_____________________________________________________________________________

function AddTheDuck()
{
    local NavigationPoint Nav;
    local TheDuck MyDuck;
    local XIIIMPDuckController DC;;
    local Array<NavigationPoint> NavPointList;

    Nav = Level.NavigationPointList;

    while( Nav != none)
    {
        if( CrouchPathNode(Nav) == none )
        {
            NavPointList.Length = NavPointList.Length+1;
            NavPointList[ NavPointList.Length-1 ] = Nav;
        }

        Nav = Nav.NextNavigationPoint;
    }

    Nav = NavPointList[ Rand(NavPointList.Length) ];

    MyDuck = Spawn(class'TheDuck',,, Nav.Location);

    XIIIMPDuckGameInfo(Level.Game).TheDuck=MyDuck;

    DuckWasAdded = true;
}

//_____________________________________________________________________________

event PreBeginPlay()
{
    DefaultAmmoPickupClass = Class<Actor>(DynamicLoadObject(DefaultAmmoPickupName, class'class'));
}

//_____________________________________________________________________________

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if ( DBMutator ) Log("MUTATOR CheckReplacement for"@Other);

    if( ( ( XIIIWeaponPickup(Other) != none ) && ( FGrenadPick(Other) == none ) ) && ( FusilChassePick(Other) == none ) )
    {
        if( ! DuckWasAdded )
            AddTheDuck();

        ReplaceWith(Other, GrenadPickupName);
    }
    else if ( (XIIIAmmoPick(Other) != none) && ( PumpAmmoBox(Other) == none ) )
        ReplaceWith(Other, DefaultAmmoPickupName);

    return true;
}

//_____________________________________________________________________________

function ModifyPlayer(Pawn Other)
{
    local XIIIMPPlayerPawn MPPlayer;
    Local Weapon Inv;

    MPPlayer = XIIIMPPlayerPawn(Other);

    Inv = Weapon(GiveSomething(class'FGrenadB', MPPlayer));
    Inv.AmmoType.AmmoAmount = 1;
    Inv = Weapon(GiveSomething(class'FusilChasse', MPPlayer));
    Inv.AmmoType.AmmoAmount = 20;

    if ( NextMutator != None )
      NextMutator.ModifyPlayer(Other);
}




defaultproperties
{
     defaultAmmoPickupName="XIII.PumpAmmoBox"
     GrenadPickupName="XIII.FGrenadPick"
     DuckPickupName="XIIIMP.XIIIMPDuckPickUp"
}
