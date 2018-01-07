//=============================================================================
// exclamation.
//=============================================================================
class exclamation extends Effects;

var float grandissement;
var bool bMonte;
var bool bCreation;

function PostBeginPlay()
{
	bCreation=true;
   bMonte=true;
   grandissement=-0.1;
	settimer2(0.28,false);
}

event tick(float dt)
{
  	super.tick(dt);
  	if (bCreation)
	{
		if (bMonte)
		  	grandissement+=3*dt;
		else
			grandissement-=3*dt;
  		self.setdrawscale(1+grandissement);
	}
}

event timer2()
{
   if (bMonte)
	{
		settimer2(0.25,false);
		bMonte=false;
	}
	else
		bCreation=false;
}

function timer()
{
	 destroy();
}



defaultproperties
{
     Texture=Texture'XIIIMenu.HUD.exclamation'
}
