//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SharkController extends AIController;

var array<NavigationPoint> PathNodeSharkList;
var bool CHARGE_LES_LOGS; // Pour voir mes logs
var bool bMove;

//-----------------------------------------------------
// init PathNodeJohan List
function InitPathNodeSharkList()
{
	local navigationpoint nav;

	nav = Level.NavigationPointList;
   while (nav != None)
   {
      if (nav.tag==pawn.tag)
		{
			PathNodeSharkList.Length = PathNodeSharkList.Length + 1;
   		PathNodeSharkList[PathNodeSharkList.Length - 1] = nav;
		}
      nav = nav.nextNavigationPoint;
	}
}

//-----------------------------------------------------
// troouve le point le plus pres pour commencer
function NavigationPoint PickStartPoint()
{
   local int i;
   local NavigationPoint BestPoint;

	for (i=0;i<PathNodeSharkList.Length;i++)
   {
		if (BestPoint==none)
		{
			BestPoint=PathNodeSharkList[i];
		}
		else
		{
			if (vsize(PathNodeSharkList[i].location-pawn.location)<vsize(BestPoint.location-pawn.location))
				BestPoint=PathNodeSharkList[i];
		}
   }
	return BestPoint;
}

//_________________________________________________________________________
// ETAT INIT
auto state init
{
begin:
   //CHARGE_LES_LOGS=true;
InitShark:
   InitPathNodeSharkList();
	if (PickStartPoint()==none)
	{
		log("WARNING PAS DE POINTS POUR LE REQUIN:"@pawn.tag);
		stop;
	}
   pawn.rotationrate.yaw=9000;
	pawn.velocity=vect(0,0,0);
	pawn.acceleration=vect(0,0,0);
	pawn.PlayMoving();
	pawn.bcanswim=true;
   //bRotateToDesired = false;
   pawn.SetPhysics(PHYS_Swimming);
   gotostate('PathWandering');
}


//_________________________________________________________________________
// ETAT PathWandering
State PathWandering
{
   event tick(float dt) //steering
	{
	   super.tick(dt);

	   if (vsize((movetarget.location-pawn.location)*vect(1,1,0))>150)
	   {
			pawn.acceleration=shark(pawn).fFacteurvitesse*( 150*normal((movetarget.location-pawn.location)*vect(1,1,0)) + 350*(1-(normal(movetarget.location-pawn.location) dot vector(pawn.rotation)))*vector(pawn.rotation)*vect(1,1,0));
			if (CHARGE_LES_LOGS)  log("...suite"@vsize(pawn.acceleration)@vsize(pawn.velocity));
	   }
		else
			gotostate('PathWandering','move');
	}
	event timer()
	{
		focalpoint=10000*(movetarget.location-pawn.location)*vect(1,1,0)+pawn.Location;
	}
	function NavigationPoint LookForNextPoint()
   {
   	local int i;
		local NavigationPoint BestPoint;
		local float Proba;

		for (i=0;i<PathNodeSharkList.Length;i++)
      {
			if (vSize(PathNodeSharkList[i].location-pawn.location)<2000)
			{
				Proba=0.5*normal(PathNodeSharkList[i].location-pawn.location) dot vector(pawn.rotation);
		   	if (frand()<proba*0.7)
				{
					 BestPoint=PathNodeSharkList[i];
					 break;
				}
			}
      }
		if (BestPoint==none)
		{
         if (CHARGE_LES_LOGS) log("jai pas selectionne de points j'en prend un au hasard");
			BestPoint=PathNodeSharkList[rand(i-2)];
		}
		return  BestPoint;
   }
begin:
	bmove=true;
Move:
	MoveTarget=LookForNextPoint();
   timer(); //actualisation vision
	settimer(2,true); //actualisation vision
	focus=none;
	destination=MoveTarget.location; //juste pour avoir visuel dans debug
	stop;
}



defaultproperties
{
}
