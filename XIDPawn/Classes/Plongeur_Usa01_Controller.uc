//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Plongeur_Usa01_Controller extends AIController;

var bool   bTire;
var bool   btemp_bool;
var bool	  bTempsPause; //temps de pause entre anim de tir et tir
var bool   CHARGE_LES_LOGS; // Pour voir mes logs
var int    numHuntPaths;
var int    NiveauAlerte;
var int iCompteur; //compteur utilise dans les boucle sur routecache
var float  Timer_RefreshEnemyPos;
var float  Temps_RefreshEnemyPos;
var float  Angle_Visee;
var float  Temp_Float;
var vector PersoTargetPos;
var vector PersoTargetVelocity;
var vector RealLastSeenPos;
var vector MoveTargetPosition;
var vector PosRelative;

//acteurs
var XiiiPlayerPawn XIII;
var Plongeur_Usa01 Plongeur;

//patrouille
var NavigationPoint DestNavPoint; //point de destination


function bool NotifyHeadVolumeChange( PhysicsVolume NewVolume )
{
	if (plongeur.bWaitToTouchWaterVolume && NewVolume.bWaterVolume)
	{
      return true;
   }
	return false;
}
//function PatrolPoint PickStartPoint()

//------------------------------------------------
// TRIGGER: Fonction Trigger declenchee par detectionvolume ou trigger alarme
//------------------------------------------------
function Trigger( actor Other, pawn EventInstigator)
{
    if (!isinstate('attente'))
     return;
    gotostate('SuitReseau');
}
singular event bool NotifyBump(actor Other)
{
    return false;
}
singular function DamageAttitudeTo(pawn Other, float Damage)
{
}
event SeePlayer (pawn seenplayer)
{
}
event SeeMonster(pawn seenplayer)
{
}
event HearNoise(float Loudness, Actor NoiseMaker)
{
}
event Tick(float DeltaTime)
{
    super.tick(DeltaTime);
}
event Timer2()
{
   if (XIII.PhysicsVolume.bWaterVolume) //si XIII plus dans l'eau remonte a la surface
		gotostate('attaque');
}
function AnimEnd(int Channel)
{
    Pawn.AnimEnd(Channel);
}

//niveau d'alerte sonore
Function IncNbAlerte()
{
}
Function DecNbAlerte()
{
}
Function IncNbAttaque()
{
}

Function DecNbAttaque()
{
}
Function IncNbAttente()
{
}

Function DecNbAttente()
{
}

// ----------------------------------------------------------------------
// FindBestPathToward()
//
// assumes the desired destination is not directly reachable.
// It tries to set Destination to the location of the
// best waypoint, and returns true if successful
// ----------------------------------------------------------------------
function bool FindBestPathToward(actor desired, bool bClearPaths)
{
    local Actor path;
    local bool success;
    local vector Desti;

    desti=desired.location;
    path = FindPathTo(desti,true);
    success = (path != None);
    if (success)
    {
        MoveTarget = path;
        Destination = path.Location;
    }

    return success;
}


//                 ---------------- ETATS ------------------

// ----------------------------------------------------------------------
//Etat d'init
//
// ----------------------------------------------------------------------
auto state init
{
   ignores seeplayer,seemonster,hearnoise;

     function Beginstate()
     {
     }
begin:
     //CHARGE_LES_LOGS=true;
preinit:
	 Plongeur=Plongeur_Usa01(pawn);
	  pawn.bSpineControl=false;
	  pawn.enableChannelNotify(0, 1);
	  pawn.bphysicsanimupdate=false;
		if (pawn.PhysicsVolume.bWaterVolume)
		{
		 pawn.PlayMoving();
		 pawn.setphysics(PHYS_SWIMMING);
		}
		else
		{
		   plongeur.bWaitToTouchWaterVolume=true;
	       pawn.Playanim('descenterappel',0.1);
		   pawn.setphysics(PHYS_FALLING);
		}
     sleep(0.1);
     XIII=XIIIPlayerPawn(xiiigameinfo(level.game).mapinfo.XIIIpawn);
     Plongeur.InitializeInventory();  //inialise inventaire
     pawn.pendingWeapon=XIIIWeapon(Plongeur.FindInventoryType(class'LHarpon')); //prend harpon
     if (pawn.pendingWeapon==none)
        log("WARNING WARNING PAS DE HARPON PAS DE HARPON");
     else
        pawn.ChangedWeapon();
     bRotateToDesired = false;
     plongeur.PeripheralVision=cos(plongeur.PeripheralVision*0.00873);
     //pawn.BaseEyeHeight=40;
     //pawn.EyeHeight=40;
		pawn.rotationrate=rot(4096,50000,3072);
		plongeur.bIsPafable=false;
init:
     pawn.bcanswim=true;
     Temps_RefreshEnemyPos=0.6-0.1*plongeur.skill;
     //si skill==1
     if (plongeur.skill==1)
     {
        Angle_Visee=14;
     }
     //si skill==2
     else if (plongeur.skill==2)
     {
        Angle_Visee=12;
     }
     //si skill==3
     else if (plongeur.skill==3)
     {
        Angle_Visee=10;
     }
     //si skill==4
     else if (plongeur.skill==4)
     {
        Angle_Visee=8;
     }
     //si skill==5
     else if (plongeur.skill==5)
     {
        Angle_Visee=6;
     }
     NiveauAlerte=0;
   if (pawn.weapon!=none)
	{
   	pawn.weapon.FireOffset=vect(150.000000,-20.000000,-50.000000);
		XIIIWeaponAttachment(pawn.weapon.ThirdPersonActor).SetRelativeLocation(vect(15.00,3.00,5.00));
    	XIIIWeaponAttachment(pawn.weapon.ThirdPersonActor).SetRelativeRotation(rot(7000,5000,-10000));
   	pawn.weapon.ThirdPersonRelativeRotation=rot(0,0,0);
	}
   else
        log("ATTENTION PAS D'ARME !!!!!!!!!!!!!!!"@pawn.physics@pawn.PhysicsVolume);
   gotostate('SuitReseau');
}


// ----------------------------------------------------------------------
//Etat de Attente
//
//
// ----------------------------------------------------------------------
state attente
{
   ignores seemonster,hearnoise;

	 event SeePlayer (pawn seenplayer)
    {
        if (seenplayer==XIII && !xiii.bisdead)
           gotostate('attaque');
    }

     function Beginstate()
     {
        if (NiveauAlerte==1)
          {
             IncNbattente();
             DecNbAlerte();
          }
          else if (NiveauAlerte==2)
          {
             IncNbattente();
             DecNbAttaque();
          }
        NiveauAlerte=0;
          if (CHARGE_LES_LOGS) log(pawn@"ETAT Attente fait rien");
     }

begin:
     pawn.velocity=vect(0,0,0);
     pawn.Acceleration = vect(0,0,0);
	  enemy=none;
     focus=none;
     focalpoint=100*vector(pawn.rotation)+pawn.location;
}

// ----------------------------------------------------------------------
//Etat de WaitForXIIIInWater
//
//
// ----------------------------------------------------------------------
state WaitForXIIIInWater
{
   ignores seemonster,seeplayer,hearnoise;

     function Beginstate()
     {
        if (NiveauAlerte==1)
          {
             IncNbattente();
             DecNbAlerte();
          }
          else if (NiveauAlerte==2)
          {
             IncNbattente();
             DecNbAttaque();
          }
        NiveauAlerte=0;
          if (CHARGE_LES_LOGS) log(pawn@"ETAT Attend que XIII reentre dans l'eau");
     }
    	function endstate()
		{
			settimer2(0,false);
		}
begin:
     pawn.velocity=vect(0,0,0);
     pawn.Acceleration = vect(0,0,0);
     focus=XIII;
	 settimer2(1,true);
}

// ----------------------------------------------------------------------
// SuitReseau
//
//
// ----------------------------------------------------------------------
state SuitReseau
{
  ignores EnemyNotVisible;

    function PatrolPoint PickStartPoint()
    {
          local NavigationPoint nav;
        local PatrolPoint     curNav;
        local float           curDist;
        local PatrolPoint     closestNav;
        local float           closestDist;

        nav = Level.NavigationPointList;
        while (nav != None)
        {
            nav.visitedWeight = 0;
            nav = nav.nextNavigationPoint;
        }
        closestNav  = None;
        closestDist = 100000;
        nav = Level.NavigationPointList;
          if (plongeur.NumReseauPropre!=0)
          {
               while (nav != None)
               {
                    curNav = PatrolPoint(nav);
                    if ((curnav!=none) && (curNav.NumReseau!=plongeur.NumReseauPropre))
                         curNav=none;
                    if ((curNav != None) && ActorReachable(curNav) && (LineofSightTo(curNav)))
                    {
                         while (curNav != None)
                         {
                              if (curNav.visitedWeight != 0)  // been here before
                                   break;
                              curDist = VSize(pawn.Location - curNav.Location);
                              if ((closestNav == None) || (closestDist > curDist))
                              {
                                   closestNav  = curNav;
                                   closestDist = curDist;
                              }
                              curNav.visitedWeight = 1;
                              curNav = curNav.NextPatrolPoint;
                              if ((curnav!=none)&&(curNav.NumReseau!=plongeur.NumReseauPropre))
                                   break;
                         }
                    }
                    nav = nav.nextNavigationPoint;
               }
               if (closestnav==none)
               {
                    closestNav  = None;
                    closestDist = 100000;
                    nav=Level.NavigationPointList;
               }
               else
                    nav=none;
          }
          while (nav != None)
         {
            curNav = PatrolPoint(nav);
            if ((curNav != None) && ActorReachable(curNav) && (LineofSightTo(curNav)))
            {
                while (curNav != None)
                {
                    if (curNav.visitedWeight != 0)  // been here before
                        break;
                    curDist = VSize(pawn.Location - curNav.Location);
                    if ((closestNav == None) || (closestDist > curDist))
                    {
                        closestNav  = curNav;
                        closestDist = curDist;
                    }
                    curNav.visitedWeight = 1;
                    curNav = curNav.NextPatrolPoint;
                }
            }
            nav = nav.nextNavigationPoint;
        }
        return (closestNav);
    }

    function PickDestination()
    {
         if (PatrolPoint(destnavpoint) != None)
        {
            destnavpoint = PatrolPoint(destnavpoint).NextPatrolPoint;
        }
        else
            destnavpoint = PickStartPoint();
        if (destnavpoint == None)  // can't go anywhere...
        {
               if (CHARGE_LES_LOGS) log(pawn@"can't go anywhere");
            GotoState('attente');
        }
    }

    function bool IsPointInCylinder(Actor cylinder, Vector point,
                                optional float extraRadius, optional float extraHeight)
    {
       local bool  bPointInCylinder;
       local float tempX, tempY, tempRad;

       tempX    = cylinder.Location.X - point.X;
       tempX   *= tempX;
       tempY    = cylinder.Location.Y - point.Y;
       tempY   *= tempY;
       tempRad  = cylinder.CollisionRadius + extraRadius;
       tempRad *= tempRad;

       bPointInCylinder = false;
       if (tempX+tempY < tempRad)
          if (Abs(cylinder.Location.Z - point.Z) < (cylinder.CollisionHeight+extraHeight))
               bPointInCylinder = true;

        return (bPointInCylinder);
     }

    function BeginState()
    {
        if (CHARGE_LES_LOGS) log(pawn@"ETAT SuitReseau");
        if (NiveauAlerte==1)
          {
             IncNbattente();
             DecNbAlerte();
          }
          else if (NiveauAlerte==2)
          {
             IncNbattente();
             DecNbAttaque();
          }
        NiveauAlerte=0;
    }
    function EndState()
    {
    }
Begin:
	  enemy=none;
     destnavpoint = None;
Patrol:
     PickDestination();
Moving:
    // Move from pathnode to pathnode until we get where we're going
    if (destnavpoint != None)
    {
        if (!IsPointInCylinder(pawn, destnavpoint.Location, 16-pawn.CollisionRadius))
        {
            MoveTarget=none;
            if (FastTrace(DestNavPoint.location-vect(0,0,30),pawn.location-vect(0,0,30)))
            {
                routecache[0]=DestNavPoint;
                routecache[1]=none;
            }
            else if (!FindBestPathToward(DestNavPoint,true))
            {
                if (CHARGE_LES_LOGS) log(pawn@"trouve pas le patrolpoint");
                GotoState('attente');
            }
            for (iCompteur=0;iCompteur<16;iCompteur++)
            {
               if (routecache[iCompteur]==none)
                   break;
               focus=none;
               focalpoint=1000*(routecache[iCompteur].location-pawn.location)+pawn.location;
               Temp_float=normal(routecache[iCompteur].location-pawn.location) dot normal(vector(pawn.rotation));
               if (Temp_float<0.3)
               {
                  pawn.velocity=vect(0,0,0);
                  pawn.acceleration=vect(0,0,0);
                  sleep(20000*(1-Temp_float)/pawn.rotationrate.yaw);
               }
               MoveToward(routecache[iCompteur],none);
            }
        }
		  WaitForLanding();
        goto('patrol');
    }
finreseau:
    if (cansee(XIII))
       gotostate('attaque');
    else
       gotostate('attente');
}

// ----------------------------------------------------------------------
// Etat d'attaque  (voit forcement xiii sinon Poursuite)
//
//
// ----------------------------------------------------------------------
state attaque
{

/*	function NotifyFiring()
	{
		plongeur.PlaySpearGunFiring();
	}  */
  function EnemyNotVisible()
  {
		gotostate('Poursuite');
  }
  function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
  {
     local vector Vect_Modif;
     local vector direction;
     local float angle;
     local vector X,Y,Z;

     if (PersoTargetPOs==vect(0,0,0))
         LOG("WUUUUUUUUUU WUUUUUUUUU WUUUUUUUU  PERSOTARGET POS = 0 0 0 PAS BON BUG BUGGGGG");
     //chance de coup fatal
     If (plongeur.skill==5 && Frand()<0.5)
         direction=xiii.location;
     else
     {
         // -------------
         // cone de visee
         // -------------
         GetAxes(Rotation, X,Y,Z);  //choppe axes pawn
         angle=Angle_Visee;
         //choppe valeur de l'angle de visee actuel en degre
         Vect_Modif=Normal(Vrand() cross Normal(X)); //prend une direction aleatoire
         angle*=Frand(); //prend une valeur pour l'angle de tir entre 0 et angle actuel
         Vect_Modif*=Vsize(xiii.location-pawn.location)*Tan(angle*Pi/180);  //multiplie direction a norme imposee par angle et distance a xiii
         if (xiii.base!=none)
            direction= Vect_Modif + PersoTargetPos+(xiii.base.velocity+PersoTargetVelocity-pawn.velocity)*0.8*Temps_RefreshEnemyPos;
         else
            direction= Vect_Modif + PersoTargetPos+(PersoTargetVelocity-pawn.velocity)*0.8*Temps_RefreshEnemyPos;
      }
      return rotator(direction-projStart);
  }
  function Fire_xiii()
  {
      local float Temps_Acqui;
      local int random;

     if (!bTire)
     {
        if (xiii.bisdead)
           return;
        //plongeur.bEnableSpineControl=true;
        bFire=1;
        bTire = true;
        setTimer(plongeur.Temps_Acquisition,false);
     }
  }
  function HalteAuFeu()
  {
      bTire = false;
      bFire=0;
      settimer(0,false);
      //plongeur.bEnableSpineControl=false;
      //plongeur.SetBoneDirection(plongeur.FIRINGBLENDBONE, rot(0,0,0), vect(0,0,0), 0.0 );
  }

  event Tick(float delta)
  {
      if ((Level.timeseconds-Timer_RefreshEnemyPos)>Temps_RefreshEnemyPos)
       {
           PersoTargetPos=xiii.location;
           PersoTargetVelocity=xiii.velocity;
           Timer_RefreshEnemyPos=level.timeseconds;
       }
  }

  event Timer()         //tir
  {
    if (xiii.bisdead)
    {
        gotostate('attente');
    }
    if (!pawn.weapon.hasammo() || pawn.weapon==none) //passe aux points
    {
       log(" BIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIP PLUS DE MUNS CA MERDE");
       return;
    }
	 if (!bTempsPause)
	 {
      settimer(0.4,false);
		plongeur.PlaySpearGunFiring();
	   bTempsPause=true;
		return;
	 }
	 else
		  bTempsPause=false;
    /*if (vsize(xiii.location-pawn.location)>1200)
    {
    log("trop loin ne tir pas");
       return;
    } */
    bFire=1;
    pawn.weapon.fire(1.0);
	 bfire=0;
    settimer(5,false);
 }

 function BeginState()
 {
     if (CHARGE_LES_LOGS) log(pawn@"ETAT Attaque");
     //pawn.rotationrate.yaw=46000;
     Timer_RefreshEnemyPos=level.timeseconds;
     PersoTargetPos=xiii.location;
     if (NiveauAlerte==0)
     {
        DecNbAttente();
        IncNbAttaque();
     }
     else if (NiveauAlerte==1)
     {
        DecNbAlerte();
        IncNbAttaque();
     }
     NiveauAlerte=2;
 }
 function EndState()
 {
     HalteAuFeu();
		settimer2(0,false);
 }

begin:
	enemy=xiii;
	focus=xiii;
	settimer2(1,true);
tir:
   sleep(0.5);
   Fire_xiii();
Positionnnement:
   PosRelative=xiii.location-pawn.location;
   if (Vsize(PosRelative)> plongeur.distanceattaque*1.2 || Vsize(PosRelative)< plongeur.distanceattaque*0.8)
   {
       PosRelative=(Vsize(PosRelative)-plongeur.distanceattaque)*normal(PosRelative);
       if (PosRelative dot vector(pawn.rotation) <0)
          MoveTo(PosRelative+pawn.location,xiii,0.3);
       else
          MoveTo(PosRelative+pawn.location,xiii,1);
   }
   sleep(1);
	WaitForLanding();
   goto('positionnnement');
}

// ----------------------------------------------------------------------
//Poursuite
//
//
// ----------------------------------------------------------------------

state Poursuite
{
ignores EnemyNotVisible;
     event seeplayer(pawn seenplayer)
     {
        if (seenplayer==XIII && !xiii.bisdead)
           gotostate('attaque');
     }

     function PickDestination()
     {
        local NavigationPoint path;
        local actor HitActor;
        local vector HitNormal, HitLocation, nextSpot, ViewSpot;
        local float posZ;
        local bool bCanSeeLastSeen;
        local int i;

       // If no xiii, or I should see him but don't, then give up
        if (xiii.bisdead || (Level.TimeSeconds-LastSeenTime)>20)
        {
            gotostate('attente');
            return;
        }
        if (actorreachable(XIII))
        {
             if ((numHuntPaths < 8) || (Level.TimeSeconds - LastSeenTime < 15)
                    || ((Normal(xiii.Location - Pawn.Location) Dot vector(Pawn.Rotation)) > -0.5) )
            {
                 Destination = xiii.Location;
                 MoveTarget = None;
                 numHuntPaths++;
            }
            else
            {
                 gotostate('attente');
            }
            return;
        }
        numHuntPaths++;

        ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
        bCanSeeLastSeen = false;
        //fixemoi probleme de Poursuite sur etage different
        bCanSeeLastSeen=(FastTrace(LastSeenPos, ViewSpot) && (abs(Lastseenpos.z-viewspot.z)<400));

        MoveTarget = None;
        if (FindBestPathToward(xiii,true))
        {
            if (CHARGE_LES_LOGS) log(pawn@"trouvereseau de Poursuite");
            return;
        }
        if (NumHuntPaths > 60)
        {
             gotostate('attente');
             return;
        }
        posZ = LastSeenPos.Z + Pawn.CollisionHeight - xiii.CollisionHeight;
        nextSpot = LastSeenPos - Normal(xiii.Velocity) * Pawn.CollisionRadius;
        nextSpot.Z = posZ;
        hitactor=Trace(HitLocation, HitNormal, nextSpot, ViewSpot, false);
        if ((( HitActor==none ) || (XIIIporte(hitactor)!=none)) && (abs(nextspot.z - viewspot.z) < 400))
        {
               Destination = nextSpot;
        }
        else if (bCanSeeLastSeen)
             Destination = LastSeenPos;
        else
        {
             Destination = LastSeenPos;
             if ( !FastTrace(LastSeenPos, ViewSpot) )
             {
                   // check if could adjust and see it
                  if (PickWallAdjust(Normal(LastSeenPos - ViewSpot)) || FindViewSpot())
                  {
                            GotoState('Poursuite', 'AdjustFromWall');
                                   return;
                  }
                  else
                  {
                       if (CHARGE_LES_LOGS) log (pawn@"quitte vers patrouille");
                       gotostate('attente');
                       return;
                  }
             }
        }
        LastSeenPos = xiii.Location;
     }

    function bool FindViewSpot()
    {
          local vector X,Y,Z;
          local bool bAlwaysTry;

          GetAxes(Rotation,X,Y,Z);

          // try left and right
          // if frustrated, always move if possible
          //bAlwaysTry = bFrustrated;
          //bFrustrated = false;

          if ( FastTrace(xiii.Location, Pawn.Location + 2 * Y * Pawn.CollisionRadius) )
          {
               Destination = Pawn.Location + 2.5 * Y * Pawn.CollisionRadius;
               return true;
          }
          if ( FastTrace(xiii.Location, Pawn.Location - 2 * Y * Pawn.CollisionRadius) )
          {
               Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
               return true;
          }
          return false;
     }

     function BeginState()
     {
          //pawn.rotationrate.yaw=46000;
          if (CHARGE_LES_LOGS) log(pawn@"ETAT Poursuite");
          if (NiveauAlerte==0)
          {
             DecNbAttente();
             IncNbAlerte();
          }
          else if (NiveauAlerte==2)
          {
             DecNbAttaque();
          }
          NiveauAlerte=1;
     }
     function EndState()
     {
				settimer2(0,false);
     }

AdjustFromWall:
     if (CHARGE_LES_LOGS) log(pawn@"adjustfromwall");
     MoveTo(Destination, MoveTarget);
     Goto('suivre');

Begin:
     numHuntPaths = 0;
		settimer2(1,true);
suivre:
	if (!XIII.PhysicsVolume.bWaterVolume) //si XIII plus dans l'eau remonte a la surface
	{
		/*if (Fasttrace(XIII.location))
		{
			Movetarget=XIII;
			bWaitToBeAtSurface=true;
		}
		else
		{  */
			gotostate('WaitForXIIIInWater');
		//}
	}
	if (CanSee(xiii))  // dans setenemy test sur actorReachable.
         gotostate('attaque');
	PickDestination();
SpecialNavig:
   if (MoveTarget == None)
   {
      focus=none;
      focalpoint=destination;
      MoveTo(destination,none);
   }
   else
   {
      focus=none;
      focalpoint=MoveTarget.location;
      MoveToward(MoveTarget,none);
   }
   Goto('suivre');
}



defaultproperties
{
}
