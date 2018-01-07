//=============================================================================
// SafePoint.
//=============================================================================
class SafePoint extends NavigationPoint
placeable;


//var      vector lookdir; //direction to look while stopped
var() bool bAccroupi;

event timer()
{
   bAlreadyTargeted=false;
}

function Occupe()
{
   bAlreadyTargeted=true;
   //settimer(3, false);
}



defaultproperties
{
     Texture=Texture'Engine.S_Inventory'
     bDirectional=True
}
