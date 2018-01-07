//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPCatchableDuckMutator extends XIIIMPDuckMutator;


function AddTheDuck()
{
    local NavigationPoint Nav;
    local TheDuck MyDuck;
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

    MyDuck = Spawn(class'TheCatchableDuck',,, Nav.Location);

    XIIIMPDuckGameInfo(Level.Game).TheDuck=MyDuck;

    DuckWasAdded = true;
}



defaultproperties
{
}
