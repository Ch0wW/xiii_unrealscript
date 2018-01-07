//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MovableLight extends Light;

Var vector OldLocation;

//_____________________________________________________________________________
event Tick(float dT)
{
    if ( Location != OldLocation )
    {
      OldLocation = Location;
    }
}



defaultproperties
{
     bStatic=False
     bNoDelete=False
     bMovable=True
}
