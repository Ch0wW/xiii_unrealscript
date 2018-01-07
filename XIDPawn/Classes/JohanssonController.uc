//=============================================================================
// JOhanssonController.
//=============================================================================
class JohanssonController extends AIController;

//Structures
struct AllianceInfoEx  {
	var Name  AllianceName;
	var float AllianceLevel;
	var bool  bPermanent;
};

var AllianceInfoEx  AlliancesEx[8];
var XiiiPlayerPawn XIII;
var Johansson Johan;
var pathnode PointDeVUe;
var SafePoint LastSafepoint;
var SafePoint OldSafepoint;
var XIIIGameInfo GI;
var array<PathNode> PathNodeJohanList;
var pawn PeeredEnemy;

var rotator temp_rotator;
var rotator rl;

var vector LastPosition; //position de deplacement
var vector V_Pos;

var float TempsEntreChaqueScalpels;
var float TempsEntreChaqueFioles;
var float TimeToLastPiquouse;
var float TimeToLastFiole;

var int NumeroTimbre;
var int NbFiolesRestantes;
var int iCompteur; //compteur utilise dans les boucle sur routecache
var int NbCoupsDonnes; //en H2H
var int ValeurArmeXIII;
var int CompteurFonceSurXIII;
var int CompteurTirSurXIIIDeLoin;

var bool CHARGE_LES_LOGS; // Pour voir mes logs
var bool bTire;
var bool bTestSiXIIIProche;
var bool bTestSiXIIILoin;
var bool bTestTimeToLastPiquouse;
var bool bTestXIIIDelogeable;
var bool bTestArmeXIII;
var bool bPointIsBehindMe;
var bool bStrafe;
var bool bPlanqueSurSafePoint;
var bool bInStrafeMode;
var bool bFonceSurXIII;
var bool bTirsurXIIIdeLoin;
var bool bChambreXIII;
var bool bFirstTrigger;

// ****************************************  Fonctions Systemes **************

// ----------------------------------------------------------------------
// FindBestPathToward()
//
// assumes the desired destination is not directly reachable.
// It tries to set Destination to the location of the
// best waypoint, and returns true if successful
function bool FindBestPathToward(actor desired, bool bClearPaths)
{
    local Actor path;
    local bool success;
    local vector Desti;

    desti=desired.location;
    MoveTarget=none;   //pas de test sur movetarget!=none donc je le place ici
    path = FindPathTo(desti,true);
    success = (path != None);
    if (success)
    {
        MoveTarget = path;
        Destination = path.Location;
    }

    return success;
}

// ----------------------------------------------------------------------
// FindBestLineOfFire()
//
function pathnode FindBestLineOfFire()
{
    local PathNOde bestpath;
    local float distance;
    local int i;

    for (i=0;i<PathNodeJohanList.Length;i++)
    {
		distance=VSize(PathNodeJohanList[i].location-pawn.location);
        if (/*distance<400 && */distance>50 && LineOfFire(PathNodeJohanList[i].location-pawn.location))
        {
            if (bestpath!=none)
            {
				if (Vsize(bestpath.location-pawn.location)>Vsize(PathNodeJohanList[i].location- pawn.location))
				{
					bestpath=PathNodeJohanList[i];
				}
            }
            else
				bestpath=PathNodeJohanList[i];
        }
    }
    return bestpath;
}


// ----------------------------------------------------------------------
// FindNewPositionBehind()
//
function pathnode FindNewPosition(bool bDerrierePerso)
{
    local Actor path;
    local vector Desti;
    local int i;

    for (i=0;i<PathNodeJohanList.Length;i++)
    {
        if ((((!bDerrierePerso && (normal(PathNodeJohanList[i].location-pawn.location) dot vector(pawn.rotation))>0) || (bDerrierePerso && (normal(PathNodeJohanList[i].location-pawn.location) dot vector(pawn.rotation))<0))) && VSize(PathNodeJohanList[i].location-pawn.location)<200 && Fasttrace(PathNodeJohanList[i].location,pawn.location-vect(0,0,30)))
        {
            return PathNodeJohanList[i];
        }
    }
    return none;
}


//------------------------------------------------
// TRIGGER: Fonction Trigger declenchee par detectionvolume ou trigger alarme
//------------------------------------------------
event Trigger( actor Other, pawn EventInstigator)
{
	if (!bFirstTrigger)
	{
		bFirstTrigger=true;
		gotostate('intro');
	}
	else
		gotostate('intro','go');
}
event bool NotifyBump(actor Other)
{
    return false;
}
function DamageAttitudeTo(pawn Other, float Damage)
{
	Johan.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',Johan.CodeMesh,Johan.NumeroTimbre);
}
event SeePlayer (pawn seenplayer)
{
}
event SeeMonster(pawn seenplayer)
{
}
event Timer()
{
}
event timer3()
{
	if (bFonceSurXIII)
	{
		if (CompteurFonceSurXIII>10)
			bFonceSurXIII=false;
		else
			CompteurFonceSurXIII++;
	}
	if (bTirsurXIIIdeLoin)
	{
		if (CompteurTirSurXIIIdeLoin>5)
			bTirsurXIIIdeLoin=false;
		else
			CompteurTirSurXIIIdeLoin++;
	}

	if (bTestTimeToLastPiquouse)  //piquouse toutes les 5s
	{
		if ((level.timeseconds-TimeToLastPiquouse)>10 && Vsize(xiii.location-pawn.location)<450)
		{
			gotostate('piquouse');
			return;
		}
	}

	if (bTestXIIIDelogeable)
	{
		if (XIIIDelogeable())
		{
			gotostate('vachercherfioles');
			return;
		}
	}
	if (bTestSiXIIIProche)
	{
		if (bTirsurXIIIdeLoin)
			return;
		if (Vsize(xiii.location-pawn.location)<350)
		{
			gotostate('attaqueH2H');
			return;
		}
		else if (frand()<0.1)
		{
			CompteurFonceSurXIII=0;
			bFonceSurXIII=true;
		}
	}
	else if (bTestSiXIIILoin)
	{
		if (bFonceSurXIII)
			return;
		if (Vsize(xiii.location-pawn.location)>550)
		{
			gotostate('attaqueadistance');
			return;
		}
	}
}
event HearNoise(float Loudness, Actor NoiseMaker)
{
}


event Tick(float DeltaTime)
{
	local int valeurarmeactuelle;

	super.tick(DeltaTime);

	if (bTestArmeXIII)
	{
		valeurarmeactuelle=EvalueArmeXIII();
		if (valeurarmeactuelle!=ValeurArmeXIII)
		{
			ValeurArmeXIII=valeurarmeactuelle;
			if (valeurarmeactuelle==2)
			{
				if (rand(3)<1)
				{
					HalteAufeu();
					gotostate('fuite');
				}
			}
			else if (valeurarmeactuelle==0)
				gotostate('attaqueH2H');
		}
	}
}

// ----------------------------------------------------------------------
// Firexiii
// ----------------------------------------------------------------------
function Firexiii()
{
	if (!bTire)
	{
        if (!xiii.bisdead)
        {
			Focus=xiii;
			bTire = true;
			timer();
        }
        else
        {
			gotostate('end');
        }
	}
}

// ----------------------------------------------------------------------
// HalteAuFeu
// ----------------------------------------------------------------------
function HalteAuFeu()
{
    bTire = false;
    settimer(0,false);
}

// ----------------------------------------------------------------------
// NotifyFiring
// ----------------------------------------------------------------------
function NotifyFiring()
{
}

// ----------------------------------------------------------------------
// Adjust Aim
// ----------------------------------------------------------------------
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	local vector DirectionTir;

    if (Johan.arme=='scalpelH2H' || Johan.arme=='piquouse')
    {
	DirectionTir=xiii.location; /*+xiii.velocity*(0.6+0.4*Frand())*(Vsize(xiii.location-pawn.location)/0.05);
	DirectionTir+=vect(0,0,28);  */
    }
    else if (Johan.arme=='scalpels')
    {
		DirectionTir=xiii.location+xiii.velocity*(0.6+0.4*Frand())*(Vsize(xiii.location-pawn.location)/class'Prock03_Scalpels'.default.speed);
		DirectionTir+=vect(0,0,28);
    }
    else if (Johan.arme=='fiole')
	{
		DirectionTir=xiii.location+xiii.velocity*(0.6+0.4*Frand())*(Vsize(xiii.location-pawn.location)/class'Prock03_Fioles'.default.speed);
		DirectionTir+=vect(0,0,28);
	}
	return rotator(DirectionTir-projStart);
}


// Fin fonctions systemes -------------------------------------------------------
//--------------------------------------------------------------------------------


// ----------------------------------------------------------------------
// LineOfFire()
//permet de savoir si je peut tirer sur XIII (pour eviter de tirer dans les murs)
function bool LineOfFire(optional vector Offset)
{
	local vector X,Y,Z;
	local vector StartTrace;
	local vector Depart;
	local actor hitactor;
	local vector hitlocation,hitnormal;

	GetAxes(rotation, X,Y,Z);  //choppe axes controller
	StartTrace = Johan.GetScalpelStart(X,Y,Z)+16*X;
	if (offset!=vect(0,0,0))
	{
		StartTrace+=offset;
	}
	HitActor=Trace(HitLocation, HitNormal, xiii.location+vect(0,0,28), StartTrace, true, vect(0,0,0));
	if (HitActor == None || HitActor == xiii || (Johan.arme=='fiole' && HitActor.isa('Breakablemover')))
		return true;
	return false;
}


function bool XIIIDelogeable()
{
	local int i;

	if (NbFiolesRestantes<=0 && Johan.NbFioles>0)
		return false;
	for (i=0;i<8;i++)
	{
		if (Johan.PtsDePlanque[i] != none && Johan.PtsDePlanque[i].bActive)
			return true;
	}
	return false;
}

function int EvalueArmeXIII()
{
	if (xiii.weapon.InventoryGroup==0 || xiii.weapon.isinstate('reloading') || !xiii.weapon.hasammo()) //au point ou reload
		return 0;
	else if (xiii.weapon.InventoryGroup<=2) //beretta  ou tknife
		return 1;
	else
		return 2;    //magum ou pompe
}

function bool TestDirection(vector dir, out vector pick)
{
	local vector HitLocation, HitNormal, dist;
	local actor HitActor;
	local float minDist;

	minDist = 100;
	pick = dir * (minDist + 250* FRand());
	HitActor = Trace(HitLocation, HitNormal, Pawn.Location + pick + 1.5 * Pawn.CollisionRadius * dir , Pawn.Location, false);
	if (HitActor != None)
	{
		pick = HitLocation + (HitNormal - dir) * 2 * Pawn.CollisionRadius;
		if ( !FastTrace(pick, Pawn.Location) )
			return false;
	}
	else
		pick = Pawn.Location + pick;

	dist = pick - Pawn.Location;
	if (Pawn.Physics == PHYS_Walking)
		dist.Z = 0;
	return (VSize(dist) > minDist);
}

function XIIIBePoisoned()
{
}

State Mort
{
    ignores seeplayer,seemonster,hearnoise,notifybump;

    function bool NearWall(float walldist)
    {
        return false;
    }
    event Tick(float DeltaTime)
    {
    }
    singular function DamageAttitudeTo(pawn Other, float Damage)
    {
    }
    function Trigger(actor Other, pawn EventInstigator)
    {
    }
    function BeginState()
    {
        if (CHARGE_LES_LOGS) log(pawn@"dead man"@self);
        HalteAuFeu();
        settimer(0,false);
        settimer2(0,false);
		  XIIIBaseHud(XIIIPlayerController(XIII.Controller).MyHud).AddBossBar(none);
		  Johan.VisuelScalpel.destroy();
		  Johan.VisuelPiquouse.destroy();
		  Johan.VisuelFiole.destroy();
		  //johan.releaseanimcontrol();
		  pawn.RefreshDisplaying();
    }
    function Endstate()
    {
    }
begin:

Dead:
}

// ----------------------------------------------------------------------
// INIT
//
// ----------------------------------------------------------------------
auto state init
{
	ignores SeePlayer,hearNoise,seemonster;
    event Tick (float delta)
    {
    }
    function InitPathNodeJohanList()
	{
		local Pathnode PathNodeJ;

		foreach allactors(class'Pathnode', PathNodeJ,'JohanssonPath')
		{
			PathNodeJohanList.Length = PathNodeJohanList.Length + 1;
			PathNodeJohanList[PathNodeJohanList.Length - 1] = PathNodeJ;
		}
	}
    singular event bool NotifyBump(actor Other)
    {
		return false;
    }
    function BeginState()
    {
    }
    function EndState()
    {
    }

begin:
    //CHARGE_LES_LOGS=true;
start:
    sleep(0.5);
	GI=XIIIGameInfo(level.game);
	XIII=XIIIPlayerPawn(xiiigameinfo(level.game).mapinfo.XIIIpawn);
    if (XIII==none)
		goto('start');
    pawn.rotationrate.yaw=43000;
	pawn.rotationrate.roll=0;
	pawn.rotationrate.pitch=0;
    bRotateToDesired = false;
    Johan= Johansson(Pawn);
	pawn.AnimBlendParams(johan.FIRINGCHANNEL+1,0,0,0,'X');
	pawn.EnableChannelNotify(johan.FiringChannel+1, 1);
    //conversions
    johan.PeripheralVision=cos(johan.PeripheralVision*0.00873);
    johan.alertness=0;
    pawn.bCanJump=false;
    temp_rotator=johan.rotation;
    Pawn.SetPhysics(PHYS_Walking);
    johan.setrotation(temp_rotator);
    InitPathNodeJohanList();
initinventaire:
    JOhan.InitializeInventory();
    Johan.InitScalpelAttach();
    Johan.InitPiquouseAttach();
    Johan.InitFioleAttach();
    Johan.ScalpelDansLaMain(false);
    Johan.PiquouseDansLaMain(false);
    Johan.FioleDansLaMain(false);
    JOhan.arme='Scalpels';
    For(iCompteur=0;iCompteur<3;iCompteur++) //init nb de fioles
    {
        if (Johan.Fioles[iCompteur] !=none)
        {
            NbFiolesRestantes++;
        }
    }
    focalpoint=johan.location+vector(temp_rotator);
    focus =none;
    pawn.bCanPickupInventory=false;
    bPreparingMove=false;
    bAdvancedTactics=false;
    NumeroTimbre=1;
    disable('seeplayer');
    disable('seemonster');
    disable('hearnoise');
    sightcounter=0;
    if (Johan.GenEffects!=none)
    {
		Johan.GenEffects.xiii=xiii;
		Johan.GenEffects.instigator=instigator;
		Johan.GenEffects.PC=XIIIGameInfo(Level.Game).MapInfo.XIIIController;
    }
initperceptions:
    TimeToLastPiquouse=3;
    TimeToLastFiole=3;
    //gotostate('intro');
    stop;
}

// ----------------------------------------------------------------------
// Intro
//
// ----------------------------------------------------------------------
state intro
{
    event Tick (float delta)
    {
		super.tick(Delta);
    }
	event timer2()
	{
			LOCAL Rotator rl;
			LOCAL int n;

			if (PeeredEnemy!=none )
			{
				rl=rotator(PeeredEnemy.Location-pawn.Location)-pawn.Rotation;

				n=rl.Yaw;//-16384;
				n=((n+32768)&65535)-32768;

				//if ((15000>n) /*&& (n>-15000)*/)
				//{
					pawn.HeadYaw = pawn.HeadYaw*0.6+0.4*n;
					rl.Yaw=0;
					rl.Pitch=0;
					rl.Roll=pawn.HeadYaw;
					pawn.SetBoneRotation('X HEAD',rl,,0.75);
				/*}
				else
				{
					pawn.HeadYaw = pawn.HeadYaw*0.7;
					rl.Yaw=0;
					rl.Pitch=0;
					rl.Roll= pawn.HeadYaw;
					pawn.SetBoneRotation('X HEAD',rl,,0.75);
				}     */
			}
			else
			{
				if ( pawn.HeadYaw!=0 )
				{
					pawn.HeadYaw = pawn.HeadYaw*0.8;
					if (pawn.HeadYaw > 100 )
					{
						rl.Yaw=0;
						rl.Pitch=0;
						rl.Roll= pawn.HeadYaw;
						pawn.SetBoneRotation('X HEAD',rl,,0.75);
					}
					else
					{
						pawn.HeadYaw=0;
						rl.Yaw=0;
						rl.Pitch=0;
						rl.Roll= 0;
						settimer2(0,false);
						pawn.SetBoneRotation('X HEAD',rl,,0.0);
					}
				}
			}
	}

begin:
	Johan.ScalpelDansLaMain(false);
   johan.TakeAnimControl(false);
	pawn.loopanim('gardienbricole',,,johan.FIRINGCHANNEL+1);
	stop;
go:
	Johan.playAnim('takescalpel',0.5,0.4,johan.FIRINGCHANNEL+1);
	sleep(1.5);
	pawn.PlayAnim('wait',1,0.4,johan.FIRINGCHANNEL+1);
 	PeeredEnemy=xiii;
	settimer2(0.05,true);
	timer2();
	pawn.rotationrate.yaw=50000;
	moveto(50*(normal(xiii.location-pawn.location)-0.5*vector(pawn.rotation))+pawn.location,xiii,0.1);
	settimer2(0,false);
	PeeredEnemy=none;
	pawn.HeadYaw=0;
	rl.Yaw=0;
	rl.Pitch=0;
	rl.Roll= 0;
	pawn.SetBoneRotation('X HEAD',rl,,0.0);
	pawn.rotationrate.yaw=43000;
//	pawn.bSpineControl=false;
	sleep(2);
	pawn.PlayAnim('dialogue4JOH',0.5,0.4,johan.FIRINGCHANNEL+1);
	sleep(4.5);
	pawn.loopAnim('marche',1,0.3,johan.FIRINGCHANNEL+1);
  // johan.releaseanimcontrol();
	moveto(200*normal(xiii.location-pawn.location)+pawn.location,xiii,0.4);
  // johan.TakeAnimControl(false);
	pawn.PlayAnim('degaine2',1,0.3,johan.FIRINGCHANNEL+1);
	sleep(1.7);
	Johan.NbScalpels=10;
	Johan.ScalpelDansLaMain(true);
	pawn.playAnim('provoc',1,0.4,johan.FIRINGCHANNEL+1);
	sleep(4);
	johan.releaseanimcontrol();
	settimer3(0.5,true);
	XIIIBaseHud(XIIIPlayerController(XIII.Controller).MyHud).AddBossBar(pawn);
	gotostate('attaqueadistance');

//gotostate('attaqueH2H');
}


// ----------------------------------------------------------------------
// ATTAQUE A DISTANCE
//
// ----------------------------------------------------------------------
State AttaqueADistance  //attaque au scalpel   א distance
{
	ignores hearnoise;

	event timer2()
	{
		if (!bInStrafeMode)
		{
			bInStrafeMode=true;
			settimer2(3,false);
		}
		else
		{
			bInStrafeMode=false;
			settimer2(8,false);
		}
	}

	event ReceiveWarning(pawn shooter, float projspeed,vector firedir)
	{
		// AI controlled creatures may duck if not falling
		if (xiii.bisdead || ValeurArmeXIII==0 || bStrafe || (bInStrafeMode && frand()<0.5))
			return;
//|| btire
		if (!XIIIWeapon(xiii.weapon).AmmoType.bInstantHit)
		{
			if (CHARGE_LES_LOGS) log(pawn$"evite projectile");
			if (pawn.biscrouched)
				pawn.shouldcrouch(false);
			gotostate('AttaqueADistance','strafe');
		}
		else
		{
			if (rand(500)>5*ValeurArmeXIII)
					return;
            if (CHARGE_LES_LOGS) log(pawn$"je suis vise");
            if (pawn.biscrouched && frand()<0.3)
            {
				pawn.shouldcrouch(false);
				gotostate('AttaqueADistance','strafe');
            }
            else
				gotostate('AttaqueADistance','strafe');
		}
    }
	event Timer()
	{
		if (bTire)
		{
			if (xiii.bisdead)
			{
				gotostate('end');
				return;
			}
			if (Johan.arme=='scalpels')
			{
				if (Johan.bWeaponReady) Johan.ScalpelsFire();
				settimer(TempsEntreChaqueScalpels,false); // pour tester si reste muns
			}
			else
			{
				if (Johan.bWeaponReady) Johan.FioleFire();
				settimer(TempsEntreChaqueFioles,false); // pour tester si reste muns
			}

		}
	}
    Function TakeScalpels()
    {
        if (CHARGE_LES_LOGS) log("takescalpels *******************");
        focalpoint=pawn.location+1000*vector(Johan.pointscalpel.rotation);
        Johan.PlayTakeScalpels();
        Johan.NbScalpels=10;
        Johan.ScalpelDansLaMain(true);
    }
    function bool StrafeDestination()
    {
		local vector pick, pickdir;
        local bool success;

        pickdir=(xiii.location-pawn.location) cross vect(0,0,1);
        pickdir.Z = 0;
        pickdir=normal(pickdir);
        if (Frand()>0.5)
			pickdir *= -1;

        success = TestDirection(pickdir, pick);
        if (!success)
        {
			success = TestDirection(-1*pickdir, pick);
			if (!success)
				return false;
        }
        Destination = pick;
        return success;
	}
    function bool NeedRecalage()
    {
		local float distance;

		movetarget=none;
		distance=vsize(xiii.location-pawn.location);

		if (distance<(Johan.DistanceAttaque-(100+50*frand())))
		{
			destination=pawn.location+(Johan.distanceAttaque-distance)*normal(pawn.location-xiii.location);
			if (Fasttrace(destination,pawn.location-vect(0,0,30)))
			{
				if (CHARGE_LES_LOGS) log("recalage arriere");
				bPointIsBehindMe=true;
				return true;
			}
			else
			{
				movetarget=FindNewPosition(true);
				if (movetarget!=none)
				{
					if (CHARGE_LES_LOGS)log("recalage arriere sur point");
					destination=movetarget.location;
					bPointIsBehindMe=true;
					return true;
				}
			}
		}
		else if (distance>(Johan.distanceAttaque+(100+50*frand())))
		{
			destination=pawn.location+(distance-Johan.distanceAttaque)*normal(xiii.location-pawn.location);
			if (Fasttrace(destination,pawn.location-vect(0,0,30))/* && LineOfFire(destination-pawn.location)*/)
			{
				if (CHARGE_LES_LOGS)log("recalage avant");
				return true;
			}
			else
			{
				movetarget=FindNewPosition(false);
				if (movetarget!=none)
				{
					destination=movetarget.location;
					if (CHARGE_LES_LOGS)log("recalage avant sur point");
					return true;
				}
			}
		}
    }

    function BeginState()
    {
		//updates
		if (Johan.NbFioles<=0) bTestSiXIIIProche=true;
		if (Johan.NbFioles<=0) bTestTimeToLastPiquouse=true;
		if (Johan.NbFioles<=0) bTestXIIIDelogeable=true;
		if (Johan.NbFioles<=0) bTestArmeXIII=true;
		bStrafe=false;
		bInStrafeMode=false;
		settimer2(4,false);
    }
    function EndState()
    {
		if (pawn.biscrouched)
			pawn.shouldcrouch(false);
		bTestSiXIIIProche=false;
		bTestTimeToLastPiquouse=false;
		bTestXIIIDelogeable=false;
		bTestArmeXIII=false;
		HalteAufeu();
		settimer2(0,false);
    }


begin:
    if (CHARGE_LES_LOGS) log(pawn@"Etat Atatque a distance"@Johan.NbScalpels);
	//pawn.velocity=vect(0,0,0);
	//pawn.acceleration=vect(0,0,0);
	if (xiii.bisdead)
	{
        gotostate('end');
	}
	if (Johan.NbScalpels<=1 && Johan.NbFioles<=0)
	{
		if (pawn.biscrouched)
            pawn.shouldcrouch(false);
		gotostate('VaChercherScalpels');
	}
	focus=xiii;
	finishrotation();
attaque:
	if (xiii.bisdead)
	{
        gotostate('end');
	}
	if (Johan.NbScalpels<=1 && Johan.NbFioles<=0)
	{
		if (pawn.biscrouched)
            pawn.shouldcrouch(false);
		gotostate('VaChercherScalpels');
	}
	else if (!LineOfFIre())
	{
		HalteAuFeu();
		if (pawn.biscrouched)
			pawn.shouldcrouch(false);
		goto('cherchelignedevue');
	}

TirSurPlace:
	//if (CHARGE_LES_LOGS) log("TirSurPlace");
	if (Johan.NbFioles>0)
	{
		if (Johan.arme!='fiole')
		{
			if (!Johan.bWeaponReady)
			{
				sleep(0.5);
				goto('TirSurPlace');
			}
			Johan.arme='fiole';
			Johan.ScalpelDansLaMain(false);
			Johan.FioleDansLaMain(true);
		}
	}
	else if (Johan.arme!='scalpels')
	{
		if (!Johan.bWeaponReady)
		{
			sleep(0.5);
			goto('TirSurPlace');
		}
		Johan.arme='scalpels';
		bTestSiXIIIProche=true;
		bTestTimeToLastPiquouse=true;
		bTestXIIIDelogeable=true;
		bTestArmeXIII=true;
		Johan.ScalpelDansLaMain(true);
		Johan.FioleDansLaMain(false);
	}
	Johan.PiquouseDansLaMain(false);
	bPointIsBehindMe=false;
	if (!pawn.biscrouched && NeedRecalage() && (Johan.NbScalpels>1 || Johan.NbFioles>0))
	{
		HalteAuFeu();
		if (bPointIsBehindMe)
			MoveTo(Destination,xiii,0.6);
		else
			MoveTo(Destination,xiii);
	}
	Firexiii();
	sleep(0.5);
	goto('attaque');
ChercheLignedevue:
	if (CHARGE_LES_LOGS) log("ChercheLignedevue");
    HalteAuFeu();
    If (!pawn.biscrouched && LineOfFIre(vect(0,0,-29)))
    {
		pawn.shouldcrouch(true);
		sleep(0.5);
		goto('attaque');
    }
    else if (pawn.biscrouched)
    {
        pawn.shouldcrouch(false);
    }
    PointDeVue=FindBestLineOfFire();
    if (PointDeVue==none)   //trouve pas de point donc tente le starfe
    {
		log("PAS DE POINT DE VUE !!!!!!!!!!!!!!!!!!*");
		goto('strafe');
    }
	//log("point de vue "@Pointdevue);
    if (actorreachable(PointDeVue))
    {
		focalpoint=PointDeVue.location;
		MoveToward(PointDeVue,none,0.8);
    }
    else if (FindBestPathToward(PointDeVue,true))
    {
        for (iCompteur=0;iCompteur<16;iCompteur++)
        {
			if (routecache[iCompteur]==none)
				break;
			focus=none;
			focalpoint=1000*(routecache[iCompteur].location-pawn.location)+pawn.location;
			MoveToward(routecache[iCompteur],none,0.8);
        }
    }
    else
    {
		log("N'ARRIVE PAS ATTEINDRE point de ligne de vue"@PointDeVUe);
		gotostate('attaqueH2H');
    }
    goto('attaque');
Strafe:
	if (CHARGE_LES_LOGS) log("strafe");
    If (StrafeDestination())
    {
		bStrafe=true;
		//HalteAuFeu();
        MoveTo(Destination,xiii,0.8);
		bStrafe=false;
    }
    goto('attaque');
}


// ----------------------------------------------------------------------
//ATTAQUEH2H
//
// ----------------------------------------------------------------------
State AttaqueH2H  //attaque au scalpel en H2H
{
	ignores hearnoise;

	event Tick(float DeltaTime)
	{
		local float distanceaxiii;

		super.tick(DeltaTime);

		if (btire)
			return;

		if (Johan.NbCoupsDansVide>3)
		{
			gotostate('attaqueadistance');
			return;
		}
		distanceaxiii=vsize(XIII.location-pawn.location);
		if (distanceaxiii<95)
		{
			fireXIII();
			gotostate('attaqueh2h','TapeSurPlace');
			return;
		}
		if (!bStrafe && vsize(XIII.location-LastPosition)>60 && distanceaxiii>100)  //a bouge
		{
			gotostate('attaqueH2H','VaVersXIII');
			return;
		}

	}
	event timer2()
	{
		CompteurTirSurXIIIDeLoin=0;
		bTirSurXIIIDeLoin=true;
	   gotostate('attaqueadistance');
	}
	event ReceiveWarning(pawn shooter, float projspeed,vector firedir)
	{
		// AI controlled creatures may duck if not falling
		if (xiii.bisdead /*|| btire */|| ValeurArmeXIII==0 || bStrafe || frand()<0.4)
			return;

		if (!XIIIWeapon(xiii.weapon).AmmoType.bInstantHit)
		{
			if (CHARGE_LES_LOGS) log(pawn$"evite projectile");
			if (pawn.biscrouched)
				pawn.shouldcrouch(false);
			gotostate('AttaqueH2H','strafe');
		}
		else
		{
			if (rand(200)>5*ValeurArmeXIII)
					return;
            if (CHARGE_LES_LOGS) log(pawn$"je suis vise");
			gotostate('AttaqueH2H','strafe');
		}
    }

	event Timer()    //ATTENTION le scalepl H2H ne tir qu'une fois
	{
		if (bTire && Johan.bWeaponReady)
		{

			if (xiii.bisdead)
			{
				gotostate('end');
				return;
			}
			NbCoupsDonnes++;
			Johan.ScalpelH2HFire();
		}
	}
	function bool StrafeDestination()
    {
		local vector pick, pickdir;
        local bool success;
		local vector DirectionXIII;

		DirectionXIII=xiii.location-pawn.location;

		if (Frand()>0.5)
			pickdir=(DirectionXIII) cross vect(0,0,1);
		else
			pickdir=(DirectionXIII) cross vect(0,0,-1);
		pickdir+=DirectionXIII;
        pickdir.Z = 0;
        pickdir=normal(pickdir);


        success = TestDirection(pickdir, pick);
        if (!success)
        {
			success = TestDirection(-1*pickdir, pick);
			if (!success)
				return false;
        }
        Destination = pick;
        return success;
	}
    singular event bool NotifyBump(actor Other)  //je touche je tape
    {
		if (other==xiii)
		{
			fireXIII();
			gotostate('attaqueh2h','TapeSurPlace');
		}
		return false;
    }
    function BeginState()
    {
		disable('tick');
		if (CHARGE_LES_LOGS) log(pawn@"Etat Atatque H2H");
		//updates
		bTestSiXIIILoin=true;
		bTestTimeToLastPiquouse=true;
		bTestXIIIDelogeable=true;
		bTestArmeXIII=true;
      settimer2(6,false);
		bStrafe=false;
		if (Johan.arme=='fiole')
		{
			Johan.ScalpelDansLaMain(true);
			Johan.FioleDansLaMain(false);
		}
    }
    function EndState()
    {
		bTestSiXIIILoin=false;
		bTestTimeToLastPiquouse=false;
		bTestXIIIDelogeable=false;
		bTestArmeXIII=false;
		HalteAufeu();
		settimer2(0,false);
    }
begin:
	//pawn.velocity=vect(0,0,0);
	//pawn.acceleration=vect(0,0,0);
	if (!Johan.bWeaponReady)
	{
		sleep(0.5);
		goto('begin');
	}
	Johan.arme='scalpelH2H';
	Johan.NbCoupsDansVide=0;
	if (xiii.bisdead)
	{
        gotostate('end');
	}
	Johan.PiquouseDansLaMain(false);
	enable('tick');
VaVersXIII:
//log("vaversxiii");
    LastPosition=XIII.location;
    if (actorreachable(xiii))
    {
		// focalpoint=XIII.location;
		// focus=xiii;
		V_Pos=XIII.location-pawn.location;
		V_Pos=Vsize(V_Pos)*normal(V_Pos+0.7*xiii.velocity)+pawn.location;
		MoveTo(V_Pos,xiii);
    }
    else if (FindBestPathToward(XIII,true))
    {
        for (iCompteur=0;iCompteur<16;iCompteur++)
        {
			if (routecache[iCompteur]==none)
				break;
			focus=none;
			focalpoint=1000*(routecache[iCompteur].location-pawn.location)+pawn.location;
			MoveToward(routecache[iCompteur],none);
        }
    }
    else
    {
		log("N'ARRIVE PAS ATTEINDRE XIII POUR LES SCALPETISER");
		CompteurTirSurXIIIDeLoin=0;
		bTirSurXIIIDeLoin=true;
		gotostate('attaqueadistance');
    }
		if (Vsize(pawn.location-xiii.location)>91)
		{
			goto('VaVersXIII');
		}
		else
			fireXIII();
TapeSurPlace:
		pawn.velocity=vect(0,0,0);
		pawn.acceleration=vect(0,0,0);
		sleep(0.75);
		if (!Johan.bxiiipoisoned && Vsize(pawn.location-xiii.location)>90)
		{
			goto('VaVersXIII');
		}
		stop;
Strafe:
	if (CHARGE_LES_LOGS) log("strafe");
    If (StrafeDestination())
    {
		bStrafe=true;
		//HalteAuFeu();
		MoveTo(Destination,xiii,0.7);
		bStrafe=false;
    }
    goto('vaversxiii');
}


// ----------------------------------------------------------------------
// Piquouse
//
// ----------------------------------------------------------------------
State Piquouse //attaque au scalpel en H2H
{
	ignores hearnoise;

	event Tick(float DeltaTime)
	{
		local float distanceaxiii;

		super.tick(DeltaTime);

		if (bTire || Johan.bxiiipoisoned || bChambreXIII)
			return;

		if (Johan.NbCoupsDansVide>2)
		{
			gotostate('attaqueadistance');
			return;
		}
		distanceaxiii=vsize(XIII.location-pawn.location);
		if (distanceaxiii<95)
		{
			fireXIII();
			gotostate('piquouse','TapeSurPlace');
			return;
		}
		if (!bstrafe && vsize(XIII.location-LastPosition)>60 && distanceaxiii>85)
			gotostate('piquouse','VaVersXIII');
	}

	event ReceiveWarning(pawn shooter, float projspeed,vector firedir)
	{
		// AI controlled creatures may duck if not falling
		if (xiii.bisdead || btire || ValeurArmeXIII==0 || bStrafe || frand()<0.4)
			return;

		if (!XIIIWeapon(xiii.weapon).AmmoType.bInstantHit)
		{
			if (CHARGE_LES_LOGS) log(pawn$"evite projectile");
			if (pawn.biscrouched)
				pawn.shouldcrouch(false);
			gotostate('piquouse','strafe');
		}
		else
		{
			if (rand(500)>5*ValeurArmeXIII)
					return;
            if (CHARGE_LES_LOGS) log(pawn$"je suis vise");
			gotostate('piquouse','strafe');
		}
    }
	function bool StrafeDestination()
    {
		local vector pick, pickdir;
        local bool success;
		local vector DirectionXIII;

		DirectionXIII=xiii.location-pawn.location;

		if (Frand()>0.5)
			pickdir=(DirectionXIII) cross vect(0,0,1);
		else
			pickdir=(DirectionXIII) cross vect(0,0,-1);
		pickdir+=DirectionXIII;
        pickdir.Z = 0;
        pickdir=normal(pickdir);


        success = TestDirection(pickdir, pick);
        if (!success)
        {
			success = TestDirection(-1*pickdir, pick);
			if (!success)
				return false;
        }
        Destination = pick;
        return success;
	}
	event Timer()    //ATTENTION le scalepl H2H ne tir qu'une fois
	{
		if (bTire && Johan.bWeaponReady)
		{
			if (xiii.bisdead)
			{
				gotostate('end');
				return;
			}
			NbCoupsDonnes++;
			Johan.PiquouseFire();
		}
	}
	function XIIIBePoisoned()
	{
		gotostate('piquouse','ChambrerXIII');
	}
    function BeginState()
    {
		disable('tick');
		if (CHARGE_LES_LOGS) log(pawn@"Piquouse     ששששששששששששששששששששששששששששששש");
		//updates
		bTestSiXIIILoin=true;
		Johan.PiquouseDansLaMain(true);
		Johan.NbCoupsDansVide=0;
    }
    function EndState()
    {
		bTestSiXIIILoin=false;
		TimeToLastPiquouse=level.timeseconds;
		HalteAufeu();
		bChambreXIII=false;
		Johan.PiquouseDansLaMain(false);
    }

begin:
	pawn.velocity=vect(0,0,0);
	pawn.acceleration=vect(0,0,0);
	if (!Johan.bWeaponReady)
	{
		sleep(0.5);
		goto('begin');
	}
	Johan.arme='piquouse';
  	  if (xiii.bisdead)
		{
			gotostate('end');
		}
	 enable('tick');
VaVersXIII:
//log("vaversxiii"@btire@Johan.bxiiipoisoned@bChambreXIII);
		LastPosition=XIII.location;
		if (actorreachable(xiii))
		{
			// focalpoint=XIII.location;
			// focus=xiii;
			V_Pos=XIII.location-pawn.location;
			V_Pos=Vsize(V_Pos)*normal(V_Pos+0.7*xiii.velocity)+pawn.location;
			MoveTo(V_Pos,xiii);
		}
		else if (FindBestPathToward(XIII,true))
		{
			for (iCompteur=0;iCompteur<16;iCompteur++)
			{
				if (routecache[iCompteur]==none)
					break;
				focus=none;
				focalpoint=1000*(routecache[iCompteur].location-pawn.location)+pawn.location;
				MoveToward(routecache[iCompteur],none);
			}
		}
		else
		{
			log("N'ARRIVE PAS ATTEINDRE XIII POUR LE Piquouser");
			CompteurTirSurXIIIDeLoin=0;
			bTirSurXIIIDeLoin=true;
			gotostate('attaqueadistance');
		}
		if (Vsize(pawn.location-xiii.location)>90)
		{
			goto('VaVersXIII');
		}
		else
			fireXIII();
TapeSurPlace:
//log("tape sur place");
		pawn.velocity=vect(0,0,0);
		pawn.acceleration=vect(0,0,0);
		sleep(0.75);
		if (!Johan.bxiiipoisoned && Vsize(pawn.location-xiii.location)>90)
		{
			goto('VaVersXIII');
		}
		stop;
Strafe:
	if (CHARGE_LES_LOGS) log("strafe");
    If (StrafeDestination())
    {
		bStrafe=true;
		//HalteAuFeu();
		MoveTo(Destination,xiii,0.7);
		bStrafe=false;
    }
    goto('vaversxiii');
ChambrerXIII:
//log("vchanmber xii");
		if (CHARGE_LES_LOGS) log("je chambre");
		bChambreXIII=true;
		HalteAuFeu();
//[******] faire joli trace
		if (fasttrace(pawn.location-200*vector(pawn.rotation)))
		{
				Moveto(pawn.location-200*vector(pawn.rotation),XIII,3); //fait 2 pas en arriere.
				if (vsize(xiii.location-pawn.location)> 180)
				{
					Johan.PlayProvoc();
					sleep(1.44);
					Johan.ReleaseAnimControl();
				}
		}
	gotostate('attaqueH2H');
}


// ----------------------------------------------------------------------
// Fuite
//
// ----------------------------------------------------------------------
state fuite
{
	ignores hearnoise;

	event timer2()
	{
		gotostate('attaqueadistance');
	}
    event ReceiveWarning(pawn shooter, float projspeed,vector firedir) //sert a savoir si bien cache
    {
		if (xiii.bisdead || btire || !bPlanqueSurSafePoint || !xiii.weapon.hasammo())
			return;
		//log("je ne suis pas bien cache cassos");
		gotostate('attaqueadistance');
    }
    singular function DamageAttitudeTo(pawn Other, float Damage) //sert a savoir si bien cache
    {
		Johan.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',Johan.CodeMesh,Johan.NumeroTimbre);
		if (xiii.bisdead || !bPlanqueSurSafePoint)
			return;
		//log("je ne suis pas bien cache cassos");
		gotostate('attaqueadistance');
    }
    function SafePoint ChercheSafePoint()  //cherche safepoint le plus pres et pas visible par l'xiii
    {
		local vector xiiiPos;
		local SafePoint Safe;
		local SafePoint BestSafe;
		local bool bPasdNMI;
		local bool bFirstInPlace;
		local bool bAngleDeVUe;
		local int i;

		if (xiii.bisdead)
			return none;
		For(i=0;i<GI.SafePointList.Length;i++)
		{
			safe=safepoint(GI.SafePointList[i]);
			bFirstInPlace= 0.05+Vsize(Safe.location -pawn.location)/pawn.groundspeed<Vsize(Safe.location - xiii.location)/xiii.groundspeed;
			if (Safe.baccroupi)
				bAngleDeVUe=FastTrace(Safe.location+vect(0,0,8.4),xiii.location + xiii.eyeposition());
			else
				bAngleDeVUe=FastTrace(Safe.location+xiii.eyeposition(),xiii.location + xiii.eyeposition());
			if (OldSafePoint!=safe && !Safe.bAlreadyTargeted && VSize(safe.location-pawn.location)<1000 && (bPasdNMI || !bAngleDeVUe) &&  bFirstInPlace)
			{
				if (bestsafe!=none)
				{
                    if (Vsize(bestsafe.location-pawn.location)>Vsize(safe.location- pawn.location))
                    {
						bestsafe=safe;
                    }
				}
				else
                    bestsafe=Safe;
			}
        }
        return bestsafe;
    }
    function BeginState()
    {
		//updates
		bTestSiXIIIProche=true;
		bTestXIIIDelogeable=true;
    }
    function EndState()
    {
		if (pawn.biscrouched)
			pawn.shouldcrouch(false);
		bTestSiXIIIProche=false;
		bTestXIIIDelogeable=false;
		bPlanqueSurSafePoint=false;
		HalteAuFeu();
		settimer2(0,false);
    }
Begin:
	if (CHARGE_LES_LOGS) log(pawn$" Fuite");
	if (xiii.bisdead)
	{
        gotostate('end');
	}
ChercheSafepoint:
	pawn.shouldcrouch(false);
    LastSafepoint=ChercheSafePoint();
    If (LastSafePoint==none)
    {
		if (CHARGE_LES_LOGS)  LOG("TROUUUUUVE PAS SAFEPOINT");
		if (Vsize(pawn.location-xiii.location)<150)
			gotostate('attaqueH2H');
		else
			gotostate('attaqueADistance');
    }
VaVersSafePoint:
	if (ActorReachable(LastSafePoint))
	{
		MoveToward(LastSafePoint,LastSafePoint,0.8);
	}
	else if (FindBestPathToward(LastSafePoint,true))
	{
		for (iCompteur=0;iCompteur<16;iCompteur++)
		{
			if (routecache[iCompteur]==none)
				break;
			focus=none;
			focalpoint=1000*(routecache[iCompteur].location-pawn.location)+pawn.location;
			MoveToward(routecache[iCompteur],none,0.8);
		}
	}
	else
	{
		log("N'ARRIVE PAS ATTEINDRE LE SAFE POINT"$LastSafePoint);
		gotostate('attaqueadistance');
	}
	OldSafePoint=lastsafepoint;
	FocalPoint = XIII.location;
	if (lastsafepoint.baccroupi)
		pawn.shouldcrouch(true);
	focus=xiii;
	finishrotation();
	bPlanqueSurSafePoint=true;
	settimer2(5+5*frand(),false);
SurSafePoint:
	log("je suis arrive au safepoint");
	if (!LineOfFire())
	{
		sleep(0.5);
		goto('Sursafepoint');
	}
	else
	{
		gotostate('attaqueadistance');
	}
}


// ----------------------------------------------------------------------
// VaChercherScalpels
//
// ----------------------------------------------------------------------
State VaChercherScalpels
{
	ignores hearnoise;

	Function TakeScalpels()
    {
        if (CHARGE_LES_LOGS) log("takescalpels *******************");
        focalpoint=pawn.location+1000*vector(Johan.pointscalpel.rotation);
        Johan.PlayTakeScalpels();
        Johan.NbScalpels=10;
    }
    function BeginState()
    {
		//updates
		if (CHARGE_LES_LOGS) log("VaChercherScalpels");
		bTestSiXIIIProche=true;
		Johan.PiquouseDansLaMain(false);
    }
    function EndState()
    {
		bTestSiXIIIProche=false;
		johan.releaseanimcontrol();
    }

begin:
    HalteAuFeu();
    if (pawn.biscrouched)
		pawn.shouldcrouch(false);
    if (Actorreachable(Johan.PointScalpel))
    {
		focalpoint=Johan.PointScalpel.location;
		MoveToward(Johan.PointScalpel,none);
    }
    else if (FindBestPathToward(Johan.PointScalpel,true))
    {
        for (iCompteur=0;iCompteur<16;iCompteur++)
        {
			if (routecache[iCompteur]==none)
				break;
			focus=none;
			focalpoint=1000*(routecache[iCompteur].location-pawn.location)+pawn.location;
			MoveToward(routecache[iCompteur],none);
        }
    }
    else
    {
		log("N'ARRIVE PAS ATTEINDRE SCALPELS"$Johan.PointScalpel);
		 gotostate('piquouse');
    }
    sleep(0.04);
    TakeScalpels();
    finishrotation();
    sleep(0.47);
    Johan.ScalpelDansLaMain(true);
	sleep(0.4);
    gotostate('attaqueadistance');
}

// ----------------------------------------------------------------------
// VaChercherFioles
//
// ----------------------------------------------------------------------
State VaChercherFioles
{
    ignores hearnoise;

	event Timer()
	{
	}
    Function TakeFiole()
    {
        local int i;

        if (CHARGE_LES_LOGS)  log("takes fiole *******************");
        focalpoint=pawn.location+1000*vector(Johan.pointfiole.rotation);
        Johan.ScalpelDansLaMain(false);
        Johan.PlayTakeFiole();
    }

	function BeginState()
    {
		Johan.PiquouseDansLaMain(false);
		//updates
		bTestSiXIIIProche=true;
    }
    function EndState()
    {
		bTestSiXIIIProche=false;
		johan.releaseanimcontrol();
    }

begin:
    if (CHARGE_LES_LOGS) log(pawn@"Etat VaChercherFioles");
	//pawn.velocity=vect(0,0,0);
	//pawn.acceleration=vect(0,0,0);
	if (xiii.bisdead)
	{
        gotostate('end');
	}
VaChercherFiole:
    HalteAuFeu();
    if (ActorReachable(Johan.PointFiole))
    {
		focalpoint=Johan.PointFiole.location;
		MoveToward(Johan.PointFiole,none);
    }
    else if (FindBestPathToward(Johan.PointFiole,true))
    {
        for (iCompteur=0;iCompteur<16;iCompteur++)
        {
			if (routecache[iCompteur]==none)
				break;
			focus=none;
			focalpoint=1000*(routecache[iCompteur].location-pawn.location)+pawn.location;
			MoveToward(routecache[iCompteur],none);
        }
    }
    else
    {
		log("N'ARRIVE PAS ATTEINDRE LE POINT FIOLE"@Johan.PointFiole);
		gotostate('attaqueadistance');
    }
    sleep(0.04);
    TakeFiole();
    finishrotation();
    //sleep(0.9);
		sleep(0.4);
    Johan.Fioles[NbFiolesRestantes-1].SetDrawType(DT_none);      //vire une fioledeco
	Johan.FioleDansLaMain(true);
    NbFiolesRestantes--;
	Johan.NbFioles=3;
	sleep(0.3);
//	sleep(0.6);
	gotostate('attaqueadistance');
}

// ----------------------------------------------------------------------
// THE END
//
// ----------------------------------------------------------------------
state end
{
    ignores hearnoise;
    event Tick(float DeltaTime)
    {
    }
begin:
    if (CHARGE_LES_LOGS) log(pawn@"END C'EST LA FIN POUR CE BATARD");
	XIIIBaseHud(XIIIPlayerController(XIII.Controller).MyHud).AddBossBar(none);
}



defaultproperties
{
     TempsEntreChaqueScalpels=1.000000
     TempsEntreChaqueFioles=2.500000
}
