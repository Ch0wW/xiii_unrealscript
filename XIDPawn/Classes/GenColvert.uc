//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GenColvert extends GenFRD;

var (GenColvert) int NbColvertGen;
var (GenColvert) float TempsEntreGen;
var (GenColvert) array<pathnode> Liste_PointsDeGen;
var (GenColvert) int NbMorts_A_Attendre;

var Colvert SpawnDuck;
var xiiiplayerpawn xiii;
var int NbMorts;
var int NbColverts;
var int NbPoints;
var int iNumPoint;
var bool bFirstDuck;

function PostBeginPlay()
{
	if (Liste_PointsDeGen.length<=0)
	{
		log("************* PAS DE POINT ASSOCIE DESTROY **************"@self);
		destroy();
	}
	settimer2(0.5+0.5*frand(),false);

}

event Trigger( actor Other, pawn EventInstigator )
{
}

event timer()
{
	if (NbMorts_A_Attendre<=NbMorts)
		gotostate('actif');
	else
		gotostate('inactif');
}
event timer2()
{
	xiii=XIIIplayerpawn(xiiigameinfo(level.game).mapinfo.XIIIpawn);
}

// ----------------------------------------------------------------------
//   Etat Inactif
//
// ----------------------------------------------------------------------
state() Inactif
{
   event Trigger( actor Other, pawn EventInstigator )
	{
		local vector vVect;

		NbMorts++;
		if (NbMorts>=NbMorts_A_Attendre)
		{
			tag='';
			disable('trigger');
			vVect=location-xiii.location;
			if (abs(vVect.z)<collisionheight && vsize(vVect*vect(1,1,0))<collisionradius)
			{
				disable('touch');
				gotostate('actif','genere');
			}
			else
				gotostate('actif');
		}
	}
	event timer()
	{
	}
begin:
	//log(self@"state inactif");
}

// ----------------------------------------------------------------------
//   Etat Actif
//
// ----------------------------------------------------------------------
state() Actif
{
	event timer()
	{
	}
	event touch(actor other)
	{
		if (other==xiii && xiii.weapon.isa('fusilchasse'))
		{
			disable('touch');
			gotostate('Actif','genere');
		}
	}
begin:
	//log(self@"state actif");
	stop;
genere:
	iNumPoint=rand(Liste_PointsDeGen.length);
	//log("genese"@Liste_PointsDeGen[iNumPoint]@NbColvertGen@NbColverts);
	SpawnDuck=spawn(class'Colvert',self,,Liste_PointsDeGen[iNumPoint].location,Liste_PointsDeGen[iNumPoint].rotation);
	if (SpawnDuck!=none)
	{
		if (!bFirstDuck)
		{

			SpawnDuck.PlaySound(Sound'XIIIsound.Ambient__Kello1a_Duck.Kello1a_Duck__hBirdTakeOff1');
       	bfirstduck=true;
			SpawnDuck.PlaySound(Sound'XIIIsound.Ambient__Kello1a_Duck.Kello1a_Duck__hDuck1');
		}
		if (Liste_PointsDeGen[iNumPoint].collisionradius!=0)
			SpawnDuck.AltitudeMax=Liste_PointsDeGen[iNumPoint].collisionradius;
		NbColverts++;
		if (NbColverts>=NbColvertGen)
		{
			destroy();
		}
	}
	Settimer(TempsEntreGen,false);
	gotostate('');
}





defaultproperties
{
     NbColvertGen=1
     TempsEntreGen=10.000000
     bCollideActors=True
     InitialState="Inactif"
}
