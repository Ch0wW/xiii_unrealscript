//-----------------------------------------------------------
//
//-----------------------------------------------------------
class StrategicPoint extends NavigationPoint placeable;

var() bool bAccroupi;
var int TempsPause;
var() Strategicpoint FinishJumpPoint;   //point d'arrivee pour  saut
var() int JumpHeight;

event timer()
{
   bAlreadyTargeted=false;
}
event timer2()
{
   enable('touch');
}

event touch(actor other)
{
	local controller SoldierController;

	if (basesoldier(other)==none)
		return;
	else
		SoldierController=basesoldier(other).controller;
    if (!bAlreadyTargeted && SoldierController!=none && SoldierController.isinstate('attaque'))
    {
       SoldierController.trigger(self,none);
       disable('touch');
       settimer2(2,false);
    }
}

function Libere()
{
   settimer(3, false);
}

function Occupe()
{
   bAlreadyTargeted=true;
}




defaultproperties
{
     JumpHeight=200
     bCollideActors=True
     Texture=Texture'Engine.S_LiftExit'
     bDirectional=True
}
