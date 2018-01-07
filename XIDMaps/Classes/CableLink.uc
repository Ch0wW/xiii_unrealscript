//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CableLink extends Effects;

var CableStart StartPoint;
var CableEnd EndPoint;
var CableLink NextLink;
var CableLink PrevLink;
var float LinkLength;
var vector vEnd, OldvEnd, vStart;
var int iLinkIndex;         // Index of the link in the chain
var float fLinkIndex;       // Weight of the link (Index / LastIndex)
var vector vPerturbation;   // To avoid similar behaviours between cables

//_____________________________________________________________________________
// ELR create all the links, each doing nothing waiting the CableStart to be triggered
function CreateNextLink()
{
    if (PrevLink == none)
      iLinkIndex = 0;
    else
      iLinkIndex = PrevLink.iLinkIndex + 1;
    vStart = Location - 0.5 * LinkLength * vector(rotation);
    OldvEnd = Location + 0.5 * LinkLength * vector(rotation);
    vEnd = OldvEnd;
    vPerturbation = vRand() * 0.5 * LinkLength;

    if ( vSize(Location - EndPoint.Location) < LinkLength )
    {
      fLinkIndex = 1.0;
      if (PrevLink != none)
        PrevLink.SetUpfLinkIndex(iLinkIndex);
      return;
    }
    NextLink = spawn(class'CableLink',self,,Location + LinkLength * Normal(EndPoint.Location - Location), rotator(EndPoint.Location - Location));
    if ( NextLink != none )
    {
      NextLink.StartPoint = StartPoint;
      NextLink.EndPoint = EndPoint;
      NextLink.PrevLink = self;
      NextLink.CreateNextLink();
    }
}

//_____________________________________________________________________________
function SetUpfLinkIndex(int MaxLink)
{
    fLinkIndex = float(iLinkIndex / MaxLink);
    if (PrevLink != none)
      PrevLink.SetUpfLinkIndex(MaxLink);
}

//_____________________________________________________________________________
function FreeMove(float dT)
{
    local vector vDir;

    // If LinkIndex == 0 else get vEnd from prev link.
    if ( PrevLink == none )
      vStart = StartPoint.Location;
    else
      vStart = PrevLink.vEnd;

/*
    if (NextLink != none)
//      vEnd = (OldvEnd + ( OldvEnd + (NextLink.Location+Location)/2.0 )/2.0)/2.0 - vect(0,0,2) * dT * LinkLength * fLinkIndex;
      vEnd = ( OldvEnd + (NextLink.Location+Location)/2.0 )/2.0 - vect(0,0,5) * dT * LinkLength * fLinkIndex;
    else
    {
      vEnd = OldvEnd - vect(0,0,2) * dT * LinkLength;
//      Log(iLinkIndex$"# OldvEnd="$OldvEnd@"vEnd="$vEnd);
    }
*/
    if ( PrevLink == none )
    {
      vEnd = (vStart - vect(0,0,1)*LinkLength + vPerturbation) + OldvEnd * (0.2/dT);
      vEnd /= (0.2/dT + 1.0);
      vPerturbation *= 0.95; // no need to make it slowly return to 0,0,0
    }
    else
    {
      vEnd = (vStart - normal(PrevLink.Location-vStart)*LinkLength) + OldvEnd * (0.3/dT);
      vEnd /= (0.3/dT + 1.0);
    }
    OldvEnd = vEnd;

    vDir = vEnd - vStart;
    vEnd = vStart + normal(vDir) * LinkLength;

    OldvEnd = vEnd;
    SetRotation( rotator(vDir) );
    SetLocation( vStart + normal(vDir) * LinkLength * 0.5);

    if ( NextLink != none )
      NextLink.FreeMove(dT);
}

//_____________________________________________________________________________
event Destroyed()
{
  if ( NextLink != none )
    NextLink.Destroy();
}



defaultproperties
{
     LinkLength=200.000000
     bUnlit=False
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'MeshArmesPickup.Telecable'
     DrawScale=2.000000
     DrawScale3D=(Y=6.000000,Z=6.000000)
}
