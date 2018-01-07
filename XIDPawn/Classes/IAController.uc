//=============================================================================
// IAController.
//=============================================================================
class IAController extends AIController native;
//#exec OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
#exec OBJ LOAD FILE="Onomatopees.uax" PACKAGE=Onomatopees

//Structures

Struct MovePointInfo
{
    var vector MovePoint;
    var bool bTraceable;
};
var MovePointInfo MovePoint;
Struct MoveActorInfo
{
    var actor MoveActor;
    var bool bReachable;
};
var MoveActorInfo MoveActor;

var enum AttitudeInfo
{
    ATTITUDE_Fear,
        ATTITUDE_Impressed,
        ATTITUDE_Charge
} AttitudeTOInfo;


//---------------------------------------------------
// Variables
//---------------------------------------------------
var actor PointChemin[16];//points intermediaire du pathfinding
var actor Interrogation; // effet interrogation ou exclamation
var actor PointsInvestigation[3]; //=investigation=
var pawn PeeredEnemy;
var XiiiPlayerPawn XIII;
var xiiipawn PoteQuiMeBloque;   //=attaque= pote qui me bloque le chemin
var BaseSoldier BaseS;
var basesoldier Pote; // ben c'est un pote qu'il faut eviter de toucher. MAJ dans fonction native LineOfFireObstacle()
var basesoldier CadavreWithPickup; // pour aller chercher pickups sur cadavre
var weapon WeaponOnGround; //arme recuperee sur cadavre
var XIIIporte PorteOuverte;        //porte a ouvrir
var XIIIporte LastBumpedDoor; //last bumped door to avoid to be blocked
var navigationpoint DoorP;  //=ouvreporte= pour verifier qu'il y a des doorpoints
var NavigationPoint DestNavPoint; //=patrouille= point de destination
var navigationPoint PointIntermediaire; //=attaque=  point intermediaire de deplacement
var patrolpoint LastPatrolPoint; //=patrouille= dernier patrolpoint utilise
var AttackPoint LastAttackPoint; //Point d'attaque courant
var AttackPoint OldAttackPoint; //Dernier Point d'attaque
var SafePoint OldSafePoint; //=chasse= Dernier Safe Point
var SafePoint SafePointOccupe;
var StrategicPoint LastStrP;
var grenadflying Grenade;  //une grenade est lancee
var genalerte genalerte;

var name EtatNeutre; // etat neutre (tenir, patrouille ou tenir)
var name nextstate;  // prochain etat apres vavers
var name prevstate;  // dernier etat avant ouvreporte
var name PatrolAnim; //type d'anim de patrouille
var name WaitPatrolAnim;//type d'anim d'attente en patrouille
var name TurnLPatrolAnim;//type d'anim de demi-tour en patrouille vers gauche
var name TurnRPatrolAnim;//type d'anim de demi-tour en patrouille vers droite


var rotator PointTenirRot; //=tenir= direction point de retour en tenir


var vector EnemyTargetPos; //derniere position connue de l'enemy
var vector EnemyTargetVelocity;
var vector DirectionTir;   //direction du tir
var vector WeaponStartTrace; //point de depart de la balle de l'arme mise a jour dans le moteur
var vector Temp_Vect;
var vector HidingSpot;   //=tacticalmove=
var vector PointTenirPos; //=tenir= position de point de retour en tenir
var vector PoteQuiMeBloquePos; //=attaque= pos du pote qui me bloque la porte
var vector PointDestination;     //=attaque=  pour calculer destination
var vector VecteurRecalage; //=attaque=


var float Temps_errance; //temps d'errance entre patrouille et errance
var float DistanceDeplacement; // distance de test de deplacement dans errance et fuite
var float DistNearWall;        //distance de tdetection des murs
var float Temps_RefreshEnemyPos;
var float DefaultPeripheralVision;
var float DefaultSightRadius;
var float DefaultHearingThreshold;
var float VitesseDeplacements; //vitesse de deplacements en strafe
var float Timer_VaRecharger;
// cone de visee
var float Angle_Visee;
var float Temps_ref;  //timer
var float Temps_Ref2; //timer
var float Temp_float; //utilise partout
var float FireTimerRefresh; //temps de refresh du tir en auto
var float sleeptime; //=patrouille= temps de pause sur patrolpoint
var float VitesseHorizontaleSaut; //=attaqueScriptee= utilise pour saut
var float fTimerAttackMusic; //=attaqueScriptee= pour faire repasser la musique en attente apres certain temps
var float TempsDeclencheAlarme; //delai avant qu'il declenche l'alarme

var int NiveauALerte; //niveau d'alerte
var int NiveauALerteEnAS; //niveau d'alerte
var int NbCoupsRiposte; //utilise dans timer pour savoir combien de coups ne sont pas bloques
var int CompteurRecalage;//utilise dans charge,attaque et TM pour savoir si se recale
var int CompteurTrame; //optimisation du Tick
var int NbPointChemin; // nb de point dans pathfinding
var int iCompteur; //compteur utilise dans les boucle sur routecache
var int temp_int;
var int NumeroProchainPoint; //=attaqueScriptee= choix entre differents AP
var int NombreDePointsSkippes;//=attaqueScriptee= pour calcul du prochain AP
var int iNumEtat; //=attaqueScriptee= numero de l'etat (grenadage,...)
var int NextRouteCachePoint; //=attaqueScriptee= pour reprendre vers point suivant apres ouverture de porte
var int numHuntPaths; //=chasse= nombre de points dans chasse
//var int NbTentativesDecrampage;  //=attaque=  pour tester crampage en melee
var int iEtatVaVersSTrp;  //=attaque= etat = 0 inactif, etat=1 va a un point intermediaire,etat=2 va a un StrP et etat=3 reste sur un STrP


var bool bDisableDamageattitudeto;
var bool CHARGE_LES_LOGS; // Pour voir mes logs
var bool bTire;
var bool bChercheStrategicPoint;
var bool bWaitForMover;  //utilise dans notifybump vers ouvreporte
var bool bPrisonnier; //utilise dans timer vers timer pour savoir si pote otage
var bool bPrecedentTirBloque; //utilise dans timer vers timer pour savoir si le precedent tir a ete bloque lors de prise d'otage
var bool bVigilant; //vigilant ou pas  <-> setvigilant
var bool bEtatAlerte; //en etat d'alerte  donc attaque direct
var bool bRetraiteVersSafePoint; //pour faire une retraite
var bool bCampeVersSafePoint;
//reactions
var bool bStepNoise;
var bool bImpactNoise;
var bool bWeaponNoise;
var bool bCadavreVu;
var bool bPaffe;
var bool bDejaVu;
var bool bPotePaffe;
var bool bVaVersAlarme; //car pote l'a declenchee
var bool bAlarmeInstigator; // vrai pawn si declencheur de l'alarme
//var bool bADejaCrie;
var bool bBloqueFuiteGrenades;
var bool bPremiereRafale;
var bool bTirSurConeMax;
var bool bUTurnMove; //=patrouille= deplacement pour les retournement en patrouille
var bool bAVuQuelquechose; // =acquisition= pour sortie interro et exclamation
var bool bSwitchMusicInWaitState; ////=attaqueScriptee= a fixe l'etat de musique en attente apres delai de pas vu.
var bool bSaut; //=attaqueScriptee=  je suis en train de sauter
var bool result;       //=attaqueScriptee= pour savoir si change de branche  et pour grenade - utilise aussi dans opendoor
var bool bAccroupiSurAP; //=attaqueScriptee= util. pour tir en rafale
var bool bDeplacementsRoulade; //=attaqueScriptee=
var bool bDontSeeAnyMore; //=attaqueScriptee= pour desactivation musique attaque
var bool bTemp_Bool;
var bool bEnCouverture;    //=attaque=
var bool bLanceGrenade;  //=attaque=
var bool bFuitPourreloader; //=attaque=
var bool bARienVu; // je suis passe en point d'interro
var bool bLookAtEnemy;//regarde si voit enemy pour recommencer a lui tirer dessus
var bool bInWaitMode; // en attaque H2H pour savoir que je suis en train d'attendre
var bool bInterruptStateToOpenDoor;
var bool bTriggerBuffered;

// ----------------------------------------------------------------------
// ChercheBonMatos
//
//si oui ressort l'arme correspondante
// ----------------------------------------------------------------------
function bool ChercheBonMatos(pawn other)
{
	CadavreWithPickup=basesoldier(other);
   if (!bases.bFouilleCadavres || CadavreWithPickup==none || CadavreWithPickup.bDejaFouille || (enemy!=none && Vsize(enemy.location-pawn.location)<390))
      return false;
    if (other.weapon==none || !other.weapon.hasammo() || other.isa('cine2'))
	 {
		  CadavreWithPickup.bDejaFouille=true;
        return false;
	 }
 	 if (Vsize(other.location-pawn.location)>1000 || !actorreachable(other))
		   return false;

    if (!pawn.weapon.hasammo() || other.weapon.airating>pawn.weapon.airating)  //meilleure arme ou meme arme si j'ai plus de muns
        return true;
    return false;
}

// ----------------------------------------------------------------------
// CherchePlanqueGrenade
//
// ----------------------------------------------------------------------
function CherchePlanqueGrenade()  //cherche safepoint le plus pres et a moins de 55m
{                                   //GRENADE DOIT IMPRATIVEMENT NE PAS ETRE EGAL A none
    local SafePoint Safe,BestSafe,secondsafe;
    local int i;
	 local float DistOfSafeToGrenad;

    if (grenade==none)
    {
        log(pawn@"WWWWWWAAAAAARRRRNNNNNNIIIIIIINNNNNGGGGGGG pas de grenade!!!");
        return;
    }
 	 if (SafePointOccupe!=none)
		SafePointOccupe.timer(); //libere point
    For(i=0;i<level.game.SafePointList.Length;i++)
    {
        safe=safepoint(level.game.SafePointList[i]);
        //log("safe"@safe@!Safe.bAlreadyTargeted@VSize(safe.location-pawn.location)<4000);
        if (!Safe.bAlreadyTargeted && VSize(safe.location-pawn.location)<4000 && VSize(safe.location-pawn.location)>pawn.collisionradius*2)
        {
				DistOfSafeToGrenad=Vsize(safe.location-grenade.location);
            if ((!FastTrace(Safe.location,grenade.location) || DistOfSafeToGrenad>1300) && (actorreachable(safe) || FindBestPathToward(safe)))
            {
                if (bestsafe== none || Vsize(bestsafe.location-grenade.location)>DistOfSafeToGrenad)
                {
							secondsafe=bestsafe;
                     bestsafe=safe;
                }
        		}
		  }
    }
	 if (bestsafe==none)
			return;
	 else if (secondsafe!=none)
	 {
		 if (Vsize(bestsafe.location-pawn.location)>600 && (secondsafe.location-pawn.location) dot (grenade.location-pawn.location)<(bestsafe.location-pawn.location) dot (grenade.location-pawn.location))
			bestsafe=secondsafe;
	 }
	 //log("a trouve planque grenade"@bestsafe@actorreachable(bestsafe)@FindBestPathToward(bestSafe));
    Movetarget=none;
    if (actorreachable(bestsafe))
    {
        OldSafePoint=bestsafe;
        MoveActor.MoveActor=bestsafe;
        MoveActor.bReachable=true;
        bestsafe.Occupe();
		  SafePointOccupe=bestsafe;
		  HalteAufeu();
        gotostate('fuitegrenade','vaverssafepoint');
    }
    else if (FindBestPathToward(bestSafe))
    {
        OldSafePoint=bestsafe;
        MoveActor.MoveActor=bestsafe;
        MoveActor.bReachable=false;
        for (i=0;i<16;i++)
        {
            if (routecache[i]==none)
                break;
            PointChemin[i]=routecache[i];
        }
        NbPointChemin=i;
			HalteAufeu();
  		  SafePointOccupe=bestsafe;
        bestsafe.Occupe();
        gotostate('fuitegrenade','vaverssafepoint');
    }
}

// ----------------------------------------------------------------------
// CherchePointSafe
//
// ----------------------------------------------------------------------
function CherchePointSafe()  //cherche safepoint le plus loin, pas visible par l'enemy et a moins de 55m
{                                   //ENEMY DOIT IMPRATIVEMENT NE PAS ETRE EGAL A NONE
    local SafePoint Safe,BestSafe;
    local bool bFirstInPlace;
    local bool bAngleDeVUe;
    local int i;

    if (enemy==none)
    {
        log(pawn@"WWWWWWWWWWWWWWAAAAAAAAAARRRRRRRRRRNNNNNNNNNIIIIIIIIIIIIIIIIINNNNNNNNNGGGGGGGGGGG !!!");
        return;
    }

    For(i=0;i<level.game.SafePointList.Length;i++)
    {
        safe=safepoint(level.game.SafePointList[i]);
        if (OldSafePoint!=safe && !Safe.bAlreadyTargeted && VSize(safe.location-pawn.location)<4000)
        {
            bFirstInPlace= 0.01+Vsize(Safe.location -pawn.location)/pawn.groundspeed<Vsize(Safe.location - enemy.location)/enemy.groundspeed;
            if (Safe.baccroupi)
                bAngleDeVUe=FastTrace(Safe.location+vect(0,0,8.4),enemy.location + enemy.eyeposition());
            else
                bAngleDeVUe=FastTrace(Safe.location+enemy.eyeposition(),enemy.location + enemy.eyeposition());
            if (!bAngleDeVUe && bFirstInPlace)
                if (bestsafe!=none)
                {
                    if (Vsize(bestsafe.location-pawn.location)<Vsize(safe.location- pawn.location))
                        bestsafe=safe;
                }
                else
                    bestsafe=Safe;
        }
    }
    if (bestsafe==none)
        return;
    Movetarget=none;
    if (actorreachable(bestsafe))
    {
        OldSafePoint=bestsafe;
        MoveActor.MoveActor=bestsafe;
        MoveActor.bReachable=true;
        Nextstate='ResteSurPlace';
        bestsafe.Occupe();
        gotostate('vavers');
    }
    else if (FindBestPathToward(bestSafe))
    {
        OldSafePoint=bestsafe;
        MoveActor.MoveActor=bestsafe;
        MoveActor.bReachable=false;
        for (i=0;i<16;i++)
        {
            if (routecache[i]==none)
                break;
            PointChemin[i]=routecache[i];
        }
        NbPointChemin=i;
        Nextstate='ResteSurPlace';
        bestsafe.Occupe();
        gotostate('vavers');
    }
}
// ----------------------------------------------------------------------
// CherchePointRetraite      //priorite au dernier safepoint
//
// ----------------------------------------------------------------------
function CherchePointRetraite()  //cherche safepoint le plus pres et pas visible par l'enemy a moins de 40m
{                                   //ENEMY DOIT IMPRATIVEMENT NE PAS ETRE EGAL A NONE
    local SafePoint Safe,BestSafe;
    local bool bFirstInPlace;
    local bool bAngleDeVUe;
    local int i;

    if (enemy==none)
    {
        log(pawn@"WWWWWWWWWWWWWWAAAAAAAAAARRRRRRRRRRNNNNNNNNNIIIIIIIIIIIIIIIIINNNNNNNNNGGGGGGGGGGG !!!");
        return;
    }
    For(i=0;i<level.game.SafePointList.Length;i++)
    {
        safe=safepoint(level.game.SafePointList[i]);
        if ((!Safe.bAlreadyTargeted || OldSafePoint==safe) && VSize(safe.location-pawn.location)<3200)
        {
            bFirstInPlace= 0.01+Vsize(Safe.location -pawn.location)/pawn.groundspeed<Vsize(Safe.location - enemy.location)/enemy.groundspeed;
            if (Safe.baccroupi)
                bAngleDeVUe=FastTrace(Safe.location+vect(0,0,8.4),enemy.location + enemy.eyeposition());
            else
                bAngleDeVUe=FastTrace(Safe.location+enemy.eyeposition(),enemy.location + enemy.eyeposition());
            if (!bAngleDeVUe && bFirstInPlace)
                if (bestsafe!=none)
                {
                    if (Vsize(bestsafe.location-pawn.location)>Vsize(safe.location- pawn.location))
                        bestsafe=safe;
                }
                else
                    bestsafe=Safe;
        }
    }
    if (bestsafe==none)
        return;
    Movetarget=none;
    if (actorreachable(bestsafe))
    {
        OldSafePoint=bestsafe;
        halteaufeu();
        MoveActor.MoveActor=bestsafe;
        MoveActor.bReachable=true;
        Nextstate='ResteSurPlace';
        bRetraiteversSafePoint=true;
        bestsafe.Occupe();
        gotostate('vavers');
    }
    else if (FindBestPathToward(bestSafe))
    {
        MoveActor.MoveActor=bestsafe;
        halteaufeu();
        MoveActor.bReachable=false;
        bRetraiteversSafePoint=true;
        for (i=0;i<16;i++)
        {
            if (routecache[i]==none)
                break;
            PointChemin[i]=routecache[i];
        }
        NbPointChemin=i;
        Nextstate='ResteSurPlace';
        bestsafe.Occupe();
        gotostate('vavers');
    }
}

// ----------------------------------------------------------------------
// CherchePointReload      //priorite au dernier safepoint
//
// ----------------------------------------------------------------------
function CherchePointReload()  //cherche safepoint le plus pres et pas visible par l'enemy a moins de 40m
{                                   //ENEMY DOIT IMPRATIVEMENT NE PAS ETRE EGAL A NONE
    local SafePoint Safe,BestSafe;
    local bool bFirstInPlace;
    local bool bAngleDeVUe;
    local int i;

    if (enemy==none)
    {
        log(pawn@"WWWWWWWWWWWWWWAAAAAAAAAARRRRRRRRRRNNNNNNNNNIIIIIIIIIIIIIIIIINNNNNNNNNGGGGGGGGGGG !!!");
        return;
    }
    For(i=0;i<level.game.SafePointList.Length;i++)
    {
        safe=safepoint(level.game.SafePointList[i]);
        if ((OldSafePoint==safe || !Safe.bAlreadyTargeted) && VSize(safe.location-pawn.location)<1500)
        {
            bFirstInPlace= 0.01+Vsize(Safe.location -pawn.location)/pawn.groundspeed<Vsize(Safe.location - enemy.location)/enemy.groundspeed;
            if (Safe.baccroupi)
                bAngleDeVUe=FastTrace(Safe.location+vect(0,0,8.4),enemy.location + enemy.eyeposition());
            else
                bAngleDeVUe=FastTrace(Safe.location+enemy.eyeposition(),enemy.location + enemy.eyeposition());
            if (!bAngleDeVUe && bFirstInPlace)
                if (bestsafe!=none)
                {
                    if (Vsize(bestsafe.location-pawn.location)>Vsize(safe.location- pawn.location))
                        bestsafe=safe;
                }
                else
                    bestsafe=Safe;
        }
    }
    if (bestsafe==none)
        return;
    Movetarget=none;
    if (actorreachable(bestsafe))
    {
        OldSafePoint=bestsafe;
        halteaufeu();
        MoveActor.MoveActor=bestsafe;
        MoveActor.bReachable=true;
        Nextstate='ResteSurPlace';
        bFuitPourreloader=true;
        bRetraiteversSafePoint=true;
        bestsafe.Occupe();
        gotostate('vavers');
    }
    else if (FindBestPathToward(bestSafe))
    {
        MoveActor.MoveActor=bestsafe;
        halteaufeu();
        MoveActor.bReachable=false;
        bRetraiteversSafePoint=true;
        bFuitPourreloader=true;
        for (i=0;i<16;i++)
        {
            if (routecache[i]==none)
                break;
            PointChemin[i]=routecache[i];
        }
        NbPointChemin=i;
        Nextstate='ResteSurPlace';
        bestsafe.Occupe();
        gotostate('vavers');
    }
}
// ----------------------------------------------------------------------
// CherchePointPourCamper  // pour camper
//
// ----------------------------------------------------------------------
function bool CherchePointPourCamper()  //cherche 2 SPs les plus proches et atteignable pour campage a moins de 10m
{
    local SafePoint Safe,BestSafe;
    local int i;

    For(i=0;i<level.game.SafePointList.Length;i++)
    {
        safe=safepoint(level.game.SafePointList[i]);
        if (!Safe.bAlreadyTargeted && VSize(safe.location-pawn.location)<800)
            if (bestsafe!=none)
            {
                if (Vsize(bestsafe.location-pawn.location)>Vsize(safe.location- pawn.location))
                    bestsafe=safe;
            }
            else
                bestsafe=Safe;
    }
    if (bestsafe==none)
        return false;
    MoveTarget=none;
    if (actorreachable(bestsafe))
    {
        MoveActor.MoveActor=bestsafe;
        MoveActor.bReachable=true;
        Nextstate='ResteSurPlace';
        bCampeversSafePoint=true;
        bestsafe.Occupe();
        gotostate('vavers');
		  return true;
    }
    else if (FindBestPathToward(bestSafe))
    {
        MoveActor.MoveActor=bestsafe;
        MoveActor.bReachable=false;
        bCampeversSafePoint=true;
        for (i=0;i<16;i++)
        {
            if (routecache[i]==none)
                break;
            PointChemin[i]=routecache[i];
        }
        NbPointChemin=i;
        Nextstate='ResteSurPlace';
        bestsafe.Occupe();
        gotostate('vavers');
		  return true;
    }
	 return false;
}
// ----------------------------------------------------------------------
// ChercheAttackPoint
//
// ----------------------------------------------------------------------
function AttackPoint ChercheAttackPoint()  //cherche AttackPoint le plus proche
{
    //ENEMY DOIT IMPRATIVEMENT NE PAS ETRE EGAL A NONE
    local vector EnemyPos;
    local AttackPoint Attack;
    local AttackPoint BestAttack;
    local int i;

    if (enemy==none)
    {
        log(pawn@"WWWWWWWWWWWWWWAAAAAAAAAARRRRRRRRRRNNNNNNNNNIIIIIIIIIIIIIIIIINNNNNNNNNGGGGGGGGGGG !!!");
        return none;
    }
    EnemyPos= enemy.location-pawn.location;
    For(i=0;i<level.game.AttackPointList.Length;i++)
    {
        attack=attackpoint(level.game.AttackPointList[i]);
        if (bases.NumReseauAttaque==Attack.NumReseau  && !attack.bDejaPasse)
            if (bestAttack!=none)
            {
                if (Vsize(bestAttack.location-pawn.location)>Vsize(Attack.location- pawn.location))
                    bestAttack=Attack;
            }
            else
                bestAttack=Attack;
    }
    if (bestattack!=none && bestattack.NextAttackP==none && OldAttackPoint==bestattack && VSize(bestAttack.location-pawn.location)>450)
        bestattack=none;
    return bestAttack;
}

// ----------------------------------------------------------------------
//
//ChercheNMIPlusProche
//
// ----------------------------------------------------------------------
function xiiipawn ChercheNMIPlusProche()
{
    local int i;
	 local XIIIPawn Soldier,NMIPlusProche;

    NMIPlusProche=none;
    For(i=0;i<level.game.BaseSoldierList.Length;i++)
    {
        if (level.game.BaseSoldierList[i]==none || level.game.BaseSoldierList[i].bisdead || level.game.BaseSoldierList[i].controller.isinstate('faction'))
            continue;
        Soldier=XIIIPawn(level.game.BaseSoldierList[i]);
        if (Soldier!=none && soldier!=pawn && AllianceLevel(Soldier)<0 && lineofsightto(Soldier))
        {
            if (NMIPlusProche==none || Vsize(NMIPlusProche.location-pawn.location)>Vsize(soldier.location-pawn.location))
                NMIPlusProche=soldier;
        }
    }
    return NMIPlusProche;
}

// ----------------------------------------------------------------------
// ChercheAlarme
// ----------------------------------------------------------------------
function ChercheAlarme()     //check les 2 alarmes les plus proches <20m
{
    local int i;
    local triggeralarme Alarm,BestAlarme;

    if (bases.ProbaDeclencheAlarme==0)
        return;
    if (FRand()*100>bases.ProbaDeclencheAlarme)
        return;
    if (level.game.AlarmList.Length<=0)
        return;
    bestalarme=none;
    For(i=0;i<level.game.AlarmList.Length;i++)
    {
        alarm=triggeralarme(level.game.AlarmList[i]);
		  //log(" test alarme"@alarm@!alarm.bAlarmeactivated@!alarm.bAlarmeTargeted@VSize(alarm.location-pawn.location)<2362@normal(pawn.location-enemy.location) dot normal(alarm.location-enemy.location)@(normal(pawn.location-enemy.location) dot normal(alarm.location-enemy.location)>=-0.2@Vsize(enemy.location-alarm.location)>250)@Fasttrace(alarm.location-vect(0,0,30),pawn.location-vect(0,0,30))@FindBestPathToward(alarm));
        if (!alarm.bAlarmeactivated && !alarm.bAlarmeTargeted && VSize(alarm.location-pawn.location)<2362 && (enemy==none || !bDejaVu || (normal(pawn.location-enemy.location) dot normal(alarm.location-enemy.location)>=-0.2 && Vsize(enemy.location-alarm.location)>250)) && (Fasttrace(alarm.location-vect(0,0,30),pawn.location-vect(0,0,30)) || FindBestPathToward(alarm)))   //30m et pas ennemy devant
            if (bestalarme!=none )
            {
                if (Vsize(bestalarme.location-pawn.location)>Vsize(alarm.location- pawn.location))
                    bestAlarme=alarm;
            }
            else
                bestalarme=alarm;
    }
    if (bestalarme==none)
        return;
    MoveTarget=none;
    If (Fasttrace(bestalarme.location-vect(0,0,30),pawn.location-vect(0,0,30)))      //vire actorreachable
    {
        //log(pawn@"cherche alarme et trouve "@bestalarme);
        MoveActor.MoveActor=bestalarme;
        MoveActor.bReachable=true;
        Nextstate='investigation';
        Halteaufeu();
        bAlarmeInstigator=true;
        genalerte.PoteTargetAlarme(true,bestalarme.tag);
        gotostate('vavers','initalarme');
    }
    else if (FindBestPathToward(bestalarme))
    {
        //log(pawn@"cherche alarme et trouve par chemin"@bestalarme);
        MoveActor.MoveActor=bestalarme;
        MoveActor.bReachable=false;
        bAlarmeInstigator=true;
        Halteaufeu();
        genalerte.PoteTargetAlarme(true,bestalarme.tag);
        for (i=0;i<16;i++)
        {
            if (routecache[i]==none)
                break;
            PointChemin[i]=routecache[i];
        }
        NbPointChemin=i;
		  PointChemin[NbPointChemin]=bestalarme;
		  NbPointChemin++;
        Nextstate='investigation';
        gotostate('vavers','initalarme');
    }
}
// ----------------------------------------------------------------------
// ChercheReseauAttaque
//
//retourne vrai si a trouve une grenade differente
// ----------------------------------------------------------------------
function ChercheReseauAttaque()
{
    local int i;
    If (bases.NumReseauAttaque!=0)
    {
        LastAttackPoint=none;
        LastAttackPoint=chercheAttackPoint();
        if (lastAttackPoint!=none) //AttackPoint plus pres que enemy
        {
            MoveTarget=none;
            if (ActorReachable(LastAttackPoint))
            {
                if (Vsize(enemy.location-pawn.location)>300 || !enemy.controller.Cansee(pawn))
                {
                    HalteAufeu();
						  if (!bdejavu) bDejaVu = true;
                    gotostate('attaquescriptee');
                }
            }
            else if (FindBestPathToward(LastAttackPoint))
            {
                if (Vsize(enemy.location-pawn.location)>300 || !enemy.controller.Cansee(pawn))
                {
                    HalteAufeu();
                    for (i=0;i<16;i++)
                    {
                        if (routecache[i]==none)
                            break;
                        PointChemin[i]=routecache[i];
                    }
                    NbPointChemin=i;
						  if (!bdejavu) bDejaVu = true;
                    gotostate('attaquescriptee');
                }
            }
        }
    }
}
// ----------------------------------------------------------------------
// AllianceLevel()
//
// renvoi -1 (enemy) 0 (neutre) ou 1 (ami)suivant alliance
// ----------------------------------------------------------------------
native function int AllianceLevel(pawn Newenemy);

// ----------------------------------------------------------------------
//
// RelativeStrength()
//
//returns a value indicating the relative strength of other
//0.0 = equal to controlled pawn
//> 0 stronger than controlled pawn
//< 0 weaker than controlled pawn
//
//Since the result will be compared to the creature's aggressiveness, it should be
//on the same order of magnitude (-1 to 1)
//Estimation en fonction de la vie, des armes et des positions en hauteur.
// ----------------------------------------------------------------------

function float RelativeStrength(Pawn Other)
{
    local float compare;
    local int bTemp;

    compare=0;
    //compare vie
    if (bases.HealthPercent()<10)
        compare+=0.3;
    if (xiiipawn(other).HealthPercent()<10)
        compare-=0.2;
    //compare armes
    if (pawn.weapon != None )
    {
        compare -= (pawn.weapon.RateSelf() - 0.3);
        if ( pawn.weapon.AIRating < 0.5 )
        {
            compare += 0.15;
            if ( (Other.Weapon != None) && (Other.Weapon.AIRating > 0.5) )
                compare += 0.2;
        }
    }
    if ( Other.Weapon != None )
        compare += (Other.Weapon.RateSelf() - 0.3);
    //compare position
    if ( Other.Location.Z > Pawn.Location.Z + 400 )
        compare -= 0.2;
    else if ( Pawn.Location.Z > Other.Location.Z + 400 )
        compare += 0.15;
    return compare;
}
// ----------------------------------------------------------------------
// FearAttitude()
// ----------------------------------------------------------------------
Function AttitudeInfo AttitudeToNMI(pawn other)
{
    if (RelativeStrength(Other) > bases.Agressivite + 0.3 + NombrePotesPresents()*0.06)
    {
        if (RelativeStrength(Other) > bases.Agressivite + 0.7 + NombrePotesPresents()*0.06)
            return ATTITUDE_Fear;
        else
            return ATTITUDE_Impressed;
    }
    else
    {
        return ATTITUDE_Charge;
    }
}

// ----------------------------------------------------------------------
//  NombrePotesPresents()
//
//  Nombre de potes dans rayon de 12m
// ----------------------------------------------------------------------
function int NombrePotesPresents()
{
    local int i;
    local int NombrePotes;
    local basesoldier Soldier;

    NombrePotes=0;
    For(i=0;i<level.game.BaseSoldierList.Length;i++)
    {
        Soldier=basesoldier(level.game.BaseSoldierList[i]);
        if (soldier!=none && Soldier!=pawn && !Soldier.bisdead && !soldier.controller.isinstate('faction') && AllianceLevel(Soldier)>0 && vsize(soldier.location-pawn.location)<1000)
        {
            NombrePotes++;
        }
    }
    return NombrePotes;
}
// ----------------------------------------------------------------------
// SetEnemy
// ----------------------------------------------------------------------
native Function bool SetEnemy(Pawn NewEnemy);

// ----------------------------------------------------------------------
// SwitchToEnemy: fait passer soldier neutre en ennemi
// ----------------------------------------------------------------------
function SwitchToEnemy(Pawn newEnemy)
{
    local int i;

    for (i=0;i<4;i++)
    {
        if ((bases.InitialAlliances[i].AllianceName == newEnemy.alliance) && (newEnemy.alliance !=''))
            break;
    }
    if (i<4)
        if (bases.InitialAlliances[i].AllianceLevel == 0)
            bases.InitialAlliances[i].AllianceLevel=-1;
}




// ----------------------------------------------------------------------
// NearWall()
// ----------------------------------------------------------------------
/* NearWall() returns true if there is a nearby barrier at eyeheight, and
changes FocalPoint to a suggested place to look
*/
native function bool NearWall(float walldist);
/*
{
local vector ViewSpot, ViewDist, LookDir,hitlocation,hitnormal;
local actor hitactor;

  LookDir = vector(Rotation);
  ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
  ViewDist = LookDir * walldist;
  HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
  if (HitActor == None)
  return false;

    ViewDist = Normal(HitNormal Cross vect(0,0,1)) * walldist;
    if (FRand() < 0.5)
    ViewDist *= -1;

      Focus = None;
      if ( FastTrace(ViewSpot + ViewDist, ViewSpot) )
      {
      FocalPoint = Pawn.Location + ViewDist;
      return true;
      }

        if ( FastTrace(ViewSpot - ViewDist, ViewSpot) )
        {
        FocalPoint = Pawn.Location - ViewDist;
        return true;
        }
        FocalPoint = Pawn.Location - LookDir * 300;
        return true;
}    */

// ----------------------------------------------------------------------
// FindBestPathToward()
//
// assumes the desired destination is not directly reachable.
// It tries to set Destination to the location of the
// best waypoint, and returns true if successful
// ----------------------------------------------------------------------
native function bool FindBestPathToward(actor desired, optional float xyMargin, optional float heightMargin);
/*{
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
}*/
// ----------------------------------------------------------------------
// FindBestPathTo()
//
//
// ----------------------------------------------------------------------
native function bool FindBestPathTo(vector desti);
/*{
local Actor path;
local bool success;

  path = FindPathTo(desti,true);
  success = (path != None);
  if (success)
  {
  MoveTarget = path;
  Destination = path.Location;
  }

    return success;
}   */

// ----------------------------------------------------------------------
// ChangeEtat : retour vers etat neutre
// ----------------------------------------------------------------------
function ChangeEtat()
{
    HalteAuFeu();
    if (!bases.bAlerte)
        SetVigilant(false);
    OldSafepoint=none;
    bWeaponNoise=false;
    bImpactNoise=false;
    bStepNoise=false;
    bCadavreVu=false;
    bDejaVu=false;
    bPaffe=false;
    bEtatAlerte=false;
    pawn.SetAnimStatus('quiet');
    pawn.rotationrate.yaw=26000;
    enemy=none;
    if (EtatNeutre=='')
        EtatNeutre='tenir';

    if (EtatNeutre=='tenir' && !isinstate('tenir'))
    {
        gotostate('tenir','backtoformation');
        return;
    }
    if (EtatNeutre=='patrouille' && IsInState('Acquisition'))
    {
        gotostate('patrouille','moving');
        return;
    }
    gotostate(EtatNeutre);
}


// ----------------------------------------------------------------------
// ChangeToBestWeapon()
// ----------------------------------------------------------------------
exec function bool ChangeToBestWeapon()
{
    local float rating;

    Pawn.PendingWeapon = Pawn.Inventory.RecommendWeapon(rating);
    if (Pawn.PendingWeapon == Pawn.Weapon )
        Pawn.PendingWeapon = None;
    if (Pawn.PendingWeapon == None )
        return false;
	 if ((XIIIWeapon(Pawn.pendingWeapon) != none) && XIIIWeapon(Pawn.pendingWeapon).bHeavyWeapon )
       XIIIPawn(Pawn).SetGroundspeed(0.666);
    else
       XIIIPawn(Pawn).SetGroundspeed(1.0);
	 if (niveaualerte==2 && Pawn.pendingWeapon.bmeleeweapon)
		 gotostate('attaqueH2H');
    if (Pawn.Weapon == None )
        Pawn.ChangedWeapon();
    else if ( Pawn.Weapon != Pawn.PendingWeapon )
        Pawn.Weapon.PutDown();
    return true;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// Fonctions de reactions aux ennemis (pour etat neutre
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------
// TestSonEntendu
// ----------------------------------------------------------------------
function bool TestSonEntendu(Actor Son)
{
	 if (son.instigator!=none && son.instigator.controller!=none && son.instigator.controller.isa('CineController2'))
		return false;
    if (weapon(son)!=none || XIIIProjectile(son)!=none)
    {
        bWeaponNoise=true;
        if (alliancelevel(son.instigator)==1) //pote donc prend son enemy
        {
            enemy=son.instigator.controller.enemy;
            instigator=son.instigator;
        }
        else
        {
            enemy=son.instigator;
            instigator=enemy;
        }
    }
    else if (bulletdustemitter(son)!=none && son.instigator==XIII)
    {
        bImpactNoise=true;
        enemy=xiii;
    }
    else if (son==xiii)
    {
        bStepNoise=true;
        enemy=XIII;
    }
    if (bWeaponNoise || bImpactNoise || bStepNoise)
        return true;
    else
        return false;
}
// ----------------------------------------------------------------------
// Seeplayer et HeardNoise
// ----------------------------------------------------------------------
event Seeplayer(pawn other)
{
    if (enemy!=none && enemy==other)
        SeeEnemy();
	 else
		  setenemy(XIII);
}
event SeeMonster(pawn other)
{
    if (enemy!=none && enemy==other)
       SeeEnemy();
	 else
		 setenemy(other);
}
event HearNoise(float Loudness, Actor NoiseMaker)
{
}
event SeeDeadPawn(pawn other)
{
}
Function SeeEnemy()
{
	LastSeenTime = Level.TimeSeconds;
	LastSeeingPos = Pawn.Location;
	LastSeenPos = Enemy.Location;
	EnemyAcquired();
}
// ----------------------------------------------------------------------
// EnemyAcquired
// surchargee (non native) dans les etats
// ----------------------------------------------------------------------
event EnemyAcquired()
{
}


// ----------------------------------------------------------------------
// SetVigilant()
// ----------------------------------------------------------------------
//PeripheralVision passe à 180
//SightRadius augmente de 50%
//HearingThreshold augmente de 50%
function SetVigilant(bool bEnAlerte)
{
    if (bEnAlerte && bVigilant)
        return;
    else if (!bEnAlerte && !bVigilant)
        return;

    if (bEnAlerte)
    {
        Pawn.PeripheralVision=fmin(DefaultPeripheralVision,0);
        Pawn.SightRadius=1.5*DefaultSightRadius;
        Pawn.HearingThreshold=1.5*DefaultHearingThreshold;
        bVigilant=true;
    }
    else
    {
        Pawn.PeripheralVision=DefaultPeripheralVision;
        Pawn.SightRadius=DefaultSightRadius;
        Pawn.HearingThreshold=DefaultHearingThreshold;
        bVigilant=false;
    }
}

// ----------------------------------------------------------------------
// Tick
// ----------------------------------------------------------------------
event Tick(float DeltaTime)
{
/*	local xiiiporte porte;
	 foreach allactors(class'xiiiporte',porte)
	    Log(porte@"Timer bOpening"@porte.bOpening@"bOpened"@porte.bOpened@"bClosed"@porte.bClosed);
		 */
 //if (enemy!=xiii && NiveauAlerte>0)
      //LOG(pawn@"BUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUH"@enemy);
    super.tick(DeltaTime);
/*	 if (btire && bfire==0)
		log("bfiiiiiiiiiiiiire = 0");  */
}

// ----------------------------------------------------------------------
// DamageAttitudeTo
// ----------------------------------------------------------------------
singular function DamageAttitudeTo(pawn Other, float Damage)
{
    //son
    bases.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',bases.CodeMesh,bases.NumeroTimbre);
}

// ----------------------------------------------------------------------
// NotifyBump
// ----------------------------------------------------------------------
singular event bool NotifyBump(actor Other)
{
    if (XIIIporte(other)!=none)
    {
        prevstate=getstatename();
	     if (XIIIporte(other).BumpType!=BT_PlayerBump)
        {
            if (((other.location-pawn.location) dot (vector(pawn.rotation))) > 0.5)
            {
                HalteAufeu();
                PorteOuverte=xiiiporte(other);
					//log("porte ouverte?"@porteouverte.bopened@"porte fermee?"@porteouverte.bclosed);
                if (PorteOuverte.bClosed)
                {
							log("porte fermee je l'ouvre");
                    //porteouverte.delaytime+=0.8;
                    DestNavPoint=LastPatrolPoint;
                    porteouverte.PlayerTrigger(self, Pawn);
						  if (prevstate=='vavers')
								bInterruptStateToOpenDoor=true;
                    gotostate('ouvreporte');
                    return false;
                }
                else if (!PorteOuverte.bOpened)
                {
						  log("porte ni fermee ni ouverte");
                    bWaitForMover=true;
                    DestNavPoint=LastPatrolPoint;
						  if (prevstate=='vavers')
								bInterruptStateToOpenDoor=true;
                    gotostate('ouvreporte','PasEnArriere');
                    return false;
                }
					 else if (prevstate=='attaque' && LastBumpedDoor!=porteouverte)
					 {
						  LastBumpedDoor=porteouverte;
						  log("porte est ouverte");
						  if (prevstate=='vavers')
								bInterruptStateToOpenDoor=true;
                    gotostate('ouvreporte','ShiftOnDoorPoint');
                    return false;

					 }
                return true;
            }
            else
                return true;
        }
        if (IsInState('patrouille') && LastPatrolPoint!=none)
        {
            focus=none;
            focalpoint= LastPatrolPoint.location;
            DestNavPoint=LastPatrolPoint;
            gotostate('patrouille','patrol');
        }
        else if (IsInState('chasse'))
            gotostate('temporise','recalporte');
        else if (bFuitPourreloader)  //si en train de reacharger n'ouvre pas la porte
        {
            bFuitPourreloader=false;
            gotostate('attaque');
        }
        return false;
    }
    /*else
    {
    log("touche une caisse");
    pawn.velocity=vect(0,0,0);
    pawn.acceleration=vect(0,0,0);
    gotostate(getstatename());
}   */

    return false;
}

//------------------------------------------------
// TRIGGER: Fonction Trigger declenchee par detectionvolume ou trigger alarme
//------------------------------------------------
event Trigger( actor Other, pawn EventInstigator)
{
    //NB: les actorreachable ont ete remplace par des fasttrace pour probleme de physique none
    local DetectionVolume  DEtectV;
    local int i;
	 local actor Path;

   if (XIIIPorte(other)!=none && XIIIPorte(other).bAlertIfSeenOpen)
    {
        //son
        pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJDetect',bases.CodeMesh,bases.NumeroTimbre);
        MoveTarget=none;
        If (fasttrace(XIIIPorte(other).PointArrivee.location))
        {
            MoveActor.MoveActor=XIIIPorte(other).PointArrivee;
            MoveActor.bReachable=true;
            enemy=xiii;
            Nextstate='investigation';
            gotostate('vavers');
            return;
        }
        else if (FindBestPathToward(XIIIPorte(other).PointArrivee))
        {
            MoveActor.MoveActor=XIIIPorte(other).PointArrivee;
            MoveActor.bReachable=false;
            for (i=0;i<16;i++)
            {
                if (routecache[i]==none)
                    break;
                PointChemin[i]=routecache[i];
            }
            Nextstate='investigation';
            enemy=xiii;
            gotostate('vavers');
            return;
        }
    }
    else if (other.isa('explosif') || other.isa('VehicleDeco'))
    {
//log(pawn@"1111111111111111111111111111111"@fasttrace(other.location)@FindPathToward(other,true));
        MoveTarget=none;
        If (fasttrace(other.location))
        {
            MovePoint.MovePoint=other.location;
            MovePoint.bTraceable=true;
            enemy=xiii;
            Nextstate='investigation';
            gotostate('vavers');
            return;
        }
        else
        {
				path=FindPathToward(other,true);
            if (path!=none)
            {
	            MovePoint.MovePoint=other.location;
					MovePoint.bTraceable=false;
					enemy=xiii;
					for (i=0;i<16;i++)
					{
						if (routecache[i]==none)
							break;
						PointChemin[i]=routecache[i];
					}
					NbPointChemin=i;
					Nextstate='investigation';
					gotostate('vavers');
					return;
            }
        }
    }
    else
    {
        if (Etatneutre=='tenir' || Etatneutre=='garder')
            Etatneutre='patrouille';
        DetectV=detectionvolume(other);
        if (DetectV!=none && eventinstigator!=none)
            enemy=eventinstigator;
        else if (enemy==none)
        {
            enemy=cherchenmiplusproche();
            if (enemy==none)     //blindage
                enemy=xiii;
        }
        if (DetectV!=none && eventinstigator!=none && DetectV.bLocalizeEnemy)
        {
            pawn.sightradius= Vsize(enemy.location-pawn.location)+200;
            HalteAuFeu();
            gotostate('acquisition');
            return;
        }
        if (bases.NumReseauAttaque!=0 && bases.bPasseAttScr_SiDeclenche)
        {
            LastAttackPoint=none;
            LastAttackPoint=chercheAttackPoint();
            if (lastAttackPoint!=none) //AttackPoint plus pres que enemy
            {
                MoveTarget=none;
                if (fasttrace(LastAttackPoint.location) || FindBestPathToward(LastAttackPoint))
                {
                    HalteAuFeu();
						  if (!bdejavu) bDejaVu = true;
                    gotostate('AttaqueScriptee');
                    return;
                }
            }
        }
        enemy=none;
        HalteAuFeu();
        gotostate('patrouille');
        return;
    }
}


// ----------------------------------------------------------------------
// ReceiveWarning
//
// ----------------------------------------------------------------------
function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
{
}






// ----------------------------------------------------------------------
// Timer
// ----------------------------------------------------------------------
event Timer()
{
    local float ProduitScal;
    local bool bLigneDeVIsee;

    if (bTire)
    {
        if ((enemy==none) || enemy.bisdead)
        {
            changeEtat();
        }
		  if (bTirSurConeMax)
			  bTirSurConeMax=false;
        //+++++++++++++++  Gestion otage      +++++++++++++++++++++++++
        if (enemy!=xiii || !(xiii.bPrisonner && XIII.LHand.pOnShoulder!=none && AllianceLevel(XIII.LHand.pOnShoulder)==1))
        {
            if (bPrisonnier)
            {
                bPrecedentTirBloque=false;
                bPrisonnier=false;
            }
            bFire=1;
            pawn.weapon.fire(1.0);
        }
        else
        {
            bLigneDeVIsee=false;
            if (!bPrisonnier)
            {
                bPrecedentTirBloque=false;
                bPrisonnier=true;
            }
  				//tir possible sans toucher pote (skill=2&3)
            ProduitScal=normal(vector(enemy.rotation)) dot normal(pawn.location-enemy.location);
            if (ProduitScal <0.5)
            {
                if (CHARGE_LES_LOGS) log(pawn$"j'ai une ligne de visee, j'allume   *** !!!!! **** ");
                bLigneDeVIsee=true;
            }
            if (NbCoupsRiposte>0 || bLigneDeVIsee)
            {
                if (bPrecedentTirBloque && bLigneDeVIsee)
                {
                    if (CHARGE_LES_LOGS) log(pawn$"MAINTENANT LE TIR N'EST PLUS BLOQUE   !!!!!!!!!!!");
                    bPrecedentTirBloque=false;
                    settimer(0.5,false);
                    return;
                }
                bFire=1;
                pawn.weapon.fire(1.0);
                NbCoupsRiposte--;
            }
            else
            {
                if (CHARGE_LES_LOGS)  log(pawn$"TIR BLOQUE             !!!!!!!!!!!!");
                bPrecedentTirBloque=true;
                bfire=0;
            }

        }

        //++++++++++++++++++++++++++++++++++
        if (pawn.weapon.WeaponMode==WM_Auto)
        {
				if (bPremiereRafale)
				{
					bPremiereRafale=false;
					if (!pawn.weapon.bmeleeweapon && enemy==xiii && ((pawn.location-xiii.location) dot (vector(XIII.rotation)))<0)
			   		bTirSurConeMax=true;
				}
            if (bPrisonnier)
                settimer(FireTimerRefresh*0.8,false); // refresh de l'otage en ligne de mire
            else
            {
                if (bencouverture)
                {
                    settimer(0,false);
                    settimer2(0.8,false);
                }
                else
                {
                    settimer(FireTimerRefresh,false); // pour tester si reste muns
                    Settimer2(0,false);
                }
            }
        }
        else
        {
            bfire=0;
				settimer(XIIIWeapon(pawn.weapon).shottime + bases.OffsetTimeBetweenShots,false);
        }
    }
}
event timer2()
{
}

event Timer3()
{
	bARienVu=false;
}

// ----------------------------------------------------------------------
// Adjust Aim
// ----------------------------------------------------------------------
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
    //log(pawn$"$$$$$$$$$$$$$$$$                       adjustaim"$projStart);
    if (enemy!=none)
    {
        return rotator(DirectionTir-projStart);
    }
    else
    {
        return rotation;
        log(pawn$" ATTENTION TIR SANS ENEMY BUGGGGGGGGGGGGGGGGGGGGGGGGGGGGG !!!!");
    }
}

// ----------------------------------------------------------------------
//  LineOfFireObstacle()
//
//retourne type de perso
//=0 ligne de mire libre (rien, enemy ou breakable avec bcanseethrought)
//=1 un pote (la var pote est actualisee)
//=2 il y autre chose devant
// ----------------------------------------------------------------------
native function int LineOfFireObstacle();


// ----------------------------------------------------------------------
//  CheckLineOfFire()           //pote MAJ
//
//declenche pas sur le cote si pote devant
//et passe en chasse si peut pas tirer
// ----------------------------------------------------------------------
function CheckLineOfFire()
{
    local vector Temp_vector;
    local int TypeObstacle;

    Temp_vector=Normal(enemy.location - WeaponStartTrace);
    TypeObstacle=LineOfFireObstacle();
    //  log("type d'obstacle"@TypeObstacle);
    if (TypeObstacle!=1)  //rien devant ou breakable transparent
    {
        return;
    }
    else if (TypeObstacle==1)   //pote devant
    {
        if (bases.order=='garder')     //si garder ne se deplace pas
        {
            settimer(1,false);
            bfire=0; //bloc tir
            return;
        }
        HalteAuFeu();
        if (bEncouverture)
            pawn.shouldcrouch(false);
        if ((((pote.location-pawn.location) cross vect(0,0,1)) dot temp_vector)<0)
            gotostate('TacticalMove','PositionTirSurDroite');
        else
            gotostate('TacticalMove','PositionTirSurGauche');
        return;
    }
   /* else if (TypeObstacle==2)    //tir bloque
    {
        if (bases.order=='garder')     //si garder ne se deplace pas
        {
            settimer(1,false);
            bfire=0; //bloc tir
            return;
        }
        HalteAuFeu();
        //log("mon tir est bloque ");
        gotostate('chasse');
    }    */
}

// ----------------------------------------------------------------------
// DirectionDuTir()  //avant dispersion
//  Mise a jour de AnleDispersion et point de depart du tir (WeaponStartTrace)
// ----------------------------------------------------------------------
native function vector DirectionDuTir();

// ----------------------------------------------------------------------
// LigneVisee()
// ----------------------------------------------------------------------
//permet de savoir si je peut tirer sur le perso (pour eviter de tirer dans les murs)
//collisionne avec level, levelgeometrie et mover
native function bool LigneVisee(vector TraceEnd, vector TraceStart);

// ----------------------------------------------------------------------
// TestDirection()
// ----------------------------------------------------------------------
//test le deplacement dans une direction (en collisionnant tout),suggere une position intermediaire
// sica passe pas et renvoi vrai si le deplacement suggere est superieur a une distance minimal e
native function bool TestDirection(float mindist,float dist,vector dir, out vector pick);

// ----------------------------------------------------------------------
// FireEnemy
// ----------------------------------------------------------------------
function FireEnemy()
{
    local float Temps_Acqui;

    if (!bTire)
    {
        if ((enemy!=none) && !enemy.bisdead)
        {
            bases.bEnableSpineControl=true;
				Focus=enemy;
            focalpoint=enemy.location;
            bTire = true;
				//log("pawn.weapon.inventorygroup"@pawn.weapon.inventorygroup);
				if (pawn.weapon.inventorygroup==0 || pawn.weapon.inventorygroup==4)
				{
					//log("fireenemy c'est une grenade");
					timer();
				}
				else if (bEtatAlerte) //points ou grenade
				{
                Temps_Acqui=FMax(0.1,Vsize(pawn.location-enemy.location)*bases.TempsVisee*0.25/2000);
					 setTimer(Temps_Acqui,false);
				}
            else
				{
                Temps_Acqui=FMax(0.4,Vsize(pawn.location-enemy.location)*bases.TempsVisee/2000);
					 setTimer(Temps_Acqui,false);
				}
        }
        else
        {
            changeEtat();
        }
    }
}

// ----------------------------------------------------------------------
// HalteAuFeu
// ----------------------------------------------------------------------
native function HalteAuFeu();

// ----------------------------------------------------------------------
// NotifyFiring
// ----------------------------------------------------------------------
function NotifyFiring()
{
}
// ----------------------------------------------------------------------
// PseudoSteering
// pseudo steering pour les deplacements en combat
// ----------------------------------------------------------------------
native function vector PseudoSteering();


// ----------------------------------------------------------------------
// PickStartPoint
//
// prend point de depart pour patrouille
// ----------------------------------------------------------------------
native function PatrolPoint PickStartPoint();

// ----------------------------------------------------------------------
// FindNewStakeOutDir
//
// trouve point de visee dans temporise
// ----------------------------------------------------------------------
native function FindNewStakeOutDir();
/*   {
local NavigationPoint N, Best;
local vector Dir, EnemyDir;
local float Dist, BestVal, Val;

  EnemyDir = Normal(Enemy.Location - Pawn.Location);
  for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
  {
  Dir = N.Location - Pawn.Location;
  Dist = VSize(Dir);
  if (Dist<800 && Dist>100)
  {
  Val = (EnemyDir Dot Dir/Dist);
  if ((Val > BestVal) && LineOfSightTo(N))
  {
  BestVal = Val;
  Best = N;
  }
  }
  }
  if ( Best != None )
  LastSeenPos = Best.Location + 0.5 * Pawn.CollisionHeight * vect(0,0,1);
    }*/
// ----------------------------------------------------------------------
// GetFacingDirection
// ----------------------------------------------------------------------
function int GetFacingDirection()
{
    local vector X,Y,Z, Dir;

    GetAxes(Pawn.Rotation, X,Y,Z);
    Dir = Normal(Pawn.Velocity);

    if ( Y Dot Dir > 0 )
        return ( 49152 + 16384 * (X Dot Dir) );
    else
        return ( 16384 - 16384 * (X Dot Dir) );
}
// ----------------------------------------------------------------------
// MoverFinished
// ----------------------------------------------------------------------
function MoverFinished()
{
}
// ----------------------------------------------------------------------
// Mayfall
// ----------------------------------------------------------------------
event MayFall()
{
}
function PawnDied()
{
    if ( Pawn != None )
    {
        SetLocation(Pawn.Location);
        Pawn.UnPossessed();
    }
    gotostate('mort');
    Pawn = None;
    PendingMover = None;
    //bstasis=true;
    Destroy();
}

//[****] a virer
function s_decalerte()
{
    level.decalerte();
     // genalerte.nbalerte--;
    //  log("decalerte "$genalerte.nbattente@genalerte.nbalerte@genalerte.nbattaque);
}
function s_incalerte()
{
    level.incalerte();
    //genalerte.nbalerte++;
   // log("incalerte "$genalerte.nbattente@genalerte.nbalerte@genalerte.nbattaque);
}
function s_decattaque()
{
    level.decattaque();
   // genalerte.nbattaque--;
  //  log("decattaque "$genalerte.nbattente@genalerte.nbalerte@genalerte.nbattaque);
}
function s_incattaque()
{
    level.incattaque();
    //  genalerte.nbattaque++;
     //  log("incattaque "$genalerte.nbattente@genalerte.nbalerte@genalerte.nbattaque);
}
function s_decattente()
{
    level.decattente();
    //  genalerte.nbattente--;
     //  log("decattente "$genalerte.nbattente@genalerte.nbalerte@genalerte.nbattaque);
}
function s_incattente()
{
    level.incattente();
     // genalerte.nbattente++;
      // log("incattente "$genalerte.nbattente@genalerte.nbalerte@genalerte.nbattaque);
}

State Otage
{
    ignores seeplayer,seemonster,hearnoise,notifybump;

    function bool NearWall(float walldist)
    {
        return false;
    }
    event Tick(float DeltaTime)
    {
		//log("etat !!!!!!!"@pawn@self@pawn.GetStateName()@GetStateName());
    }
    singular function DamageAttitudeTo(pawn Other, float Damage)
    {
        //son
        //bases.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',bases.CodeMesh,bases.NumeroTimbre);
    }
    function Trigger(actor Other, pawn EventInstigator)
    {
    }
    function BeginState()
    {
		local int i;
        if (NiveauAlerte==1)
        {
            s_incattente();
            s_decAlerte();
        }
        else if (NiveauAlerte==2)
        {
            s_incattente();
            s_decAttaque();
        }
        NiveauAlerte=0;
        HalteAuFeu();
        settimer(0,false);
		  settimer2(0,false);
        sightcounter=0;
        bDisableEventSeeDeadPawn=true;
		  pawn.bProjTarget=false;
		//vire de la liste des basesoldiers
			for (i = 0; i < level.game.BaseSoldierList.Length; i++)
		   {
		          if (level.game.BaseSoldierList[i] == pawn )
				  {
					  level.game.BaseSoldierList.Remove(i,1);
					  break;
				  }
		   }
    }
    function Endstate()
    {
        sightcounter=0.15;
		  pawn.bProjTarget=true;
    }
begin:
    if (Interrogation!=none)
    {
        interrogation.Destroy();
        interrogation=none;
    }

Prisonnier:
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
        if (Interrogation!=none)
        {
            Interrogation.destroy();
            Interrogation=none;
        }
    }
    function Endstate()
    {
    }
begin:
    if (Interrogation!=none)
    {
        interrogation.Destroy();
        interrogation=none;
    }
Dead:
}

// ----------------------------------------------------------------------
//Etat de faction
//
//
// ----------------------------------------------------------------------
state faction
{
    ignores seeplayer,seemonster,hearnoise;
    function Beginstate()
    {
        if (NiveauAlerte==1)
        {
            s_incattente();
            s_decAlerte();
        }
        else if (NiveauAlerte==2)
        {
            s_incattente();
            s_decAttaque();
        }
        NiveauAlerte=0;
        //settimer(0,false);
        //sightcounter=0;
        //bDisableEventSeeDeadPawn=true;
        pawn.velocity=vect(0,0,0);
        pawn.Acceleration = vect(0, 0, 0);
        pawn.SetPhysics(PHYS_None);
        pawn.SetCollision(false,false,false);
        pawn.SetDrawType(DT_None);
        if (pawn.Shadow!=none)
            pawn.Shadow.DetachProjector(true);
        pawn.bStasis=true;
        bStasis=true;
        pawn.RefreshDisplaying();
		  bBloqueFuiteGrenades=true;
    }
    function endstate()
    {
		 if (!xiii.IsDead() && !level.game.bGameEnded)
       {
			bStasis=false;
			pawn.bStasis=false;
			//sightcounter=0.15;
			pawn.SetPhysics(PHYS_Walking);
			pawn.SetCollision(true,true,true);
			pawn.SetDrawType(DT_Mesh);
			//bDisableEventSeeDeadPawn=false;
			pawn.RefreshDisplaying();
			bBloqueFuiteGrenades=false;
		 }
    }
begin:
    if (CHARGE_LES_LOGS) log(pawn@"ETAT faction fait rien");
}

// ----------------------------------------------------------------------
// ETAT INIT
//
//
// ----------------------------------------------------------------------
auto state init
{
    ignores SeePlayer,hearNoise,seemonster,notifybump,enemynotvisible;
	event Trigger( actor Other, pawn EventInstigator)
	{
		bTriggerBuffered=true;
		Interrogation=other; //cheat to not use an other variable
		Peeredenemy=EventInstigator;
	}
	function BufferTrigger()
	{
		if (bTriggerBuffered && Interrogation!=none && Peeredenemy!=none)
		{
 			bTriggerBuffered=false;
			Peeredenemy=none;
			Interrogation=none;
			global.Trigger(Interrogation,Peeredenemy);
		}
	}
    event Tick (float delta)
    {
    }
    function BeginState()
    {
        settimer(0,false);
			NiveauAlerte=-1;
    }
    function EndState()
    {
			NiveauAlerte=0;
    }
begin:
    //CHARGE_LES_LOGS=true;
TurnIntoSoldierInit:
    BaseS= BaseSoldier(Pawn);
    if( Level.Game.DummyStuff1 != -326.27 )
    {
       bases.skill=5;
       pawn.health*=5;
    }
    bases.PlayWaiting();  // cheat sinon ne charge pas d'anim
	 if (bases.bBasesGenere) //perso genere
	 {
		  Pawn.SetPhysics(PHYS_falling);
		  if (bases.bSpawnInAir)
		  {
				bases.TakeAnimControl(true);
				bases.PlayAnim('descenterappel',,0.05,bases.FIRINGCHANNEL+1);
				bases.AnimBlendToAlpha(bases.FIRINGCHANNEL+1,1,0.05);
			}
			WaitForLanding();
		   if (bases.bSpawnInAir)
		   {
				bases.PlayJumpLanding();
		   	sleep(0.4);
				bases.releaseAnimControl();
		  		bases.PlayWaiting();
			}
	 }
	 Pawn.SetPhysics(PHYS_walking);
    if (pawn.isa('cine2'))
    {
        pawn.peripheralvision=0.7;
        pawn.groundspeed=class'xiiipawn'.default.groundspeed;
//		  pawn.AnimBlendToAlpha(0,0.0,0.0);
        bcontrolanimations=false;
    }
    else
    {
        BaseS.InitializeInventory();
        //conversions
        pawn.PeripheralVision=cos(pawn.PeripheralVision*0.00873);
    }
	 Switch(Level.Game.Difficulty)
	 {
		 case 0: TempsDeclencheAlarme*=1.2; bases.TempsPasVu*=1.2; bases.TempsIdentification*=1.2; FireTimerRefresh=2-0.05*bases.skill; break;
		 case 1: FireTimerRefresh=1-0.05*bases.skill; break;//bases.TempsPasVu*=1.2; bases.TempsIdentification*=1.2;break;
		 case 2: TempsDeclencheAlarme*=0.8;bases.TempsPasVu*=0.8; bases.TempsIdentification*=0.8; FireTimerRefresh=0.8-0.05*bases.skill;break;
		 case 3: bases.TempsPasVu*=0.6; bases.TempsIdentification*=0.6; FireTimerRefresh=0.7-0.05*bases.skill;break;
	 }
start:
	 pawn.AnimBlendParams(pawn.FIRINGCHANNEL+1,0,0,0,'X');
	 pawn.EnableChannelNotify(bases.FiringChannel+1, 1);
    DefaultPeripheralVision=pawn.PeripheralVision;
    DefaultSightRadius=Pawn.SightRadius;
    DefaultHearingThreshold=Pawn.HearingThreshold;
	 Sleep(0.1);
	 ChangetoBestWeapon();
    sleep(0.1+0.1*frand());
    if (Pawn.Inventory == None)
        log(pawn@"BUGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG inventory==none");
    pawn.rotationrate.yaw=25000;
    pawn.setanimstatus('quiet');
    bRotateToDesired = false;
    pawn.bCanJump=false;
    //pawn.JumpZ=-1; //Cheat pour pas qu'il saute
    bases.setrotation(bases.rotation);
    focalpoint=bases.location+vector(bases.rotation);
    focus =none;
    pawn.bCanPickupInventory=false;
    bPreparingMove=false;
    bAdvancedTactics=false;
    XIII=XIIIPlayerPawn(xiiigameinfo(level.game).mapinfo.XIIIpawn);
    genalerte=genalerte(level.game.genalerte);
    //desactivation des events
    if (level.bNoEnemyAlliance)
        bDisableEventSeeMonster=true;
    s_incattente();
init_bases:
    Switch(bases.skill)
    {
        Case 1 : Angle_Visee=14; break;
        Case 2 : Angle_Visee=12; break;
        Case 3 : Angle_Visee=10; break;
        Case 4 : Angle_Visee=8; break;
        Case 5 : Angle_Visee=6; break;
    }
    if (bases.bAlerte)
    {
        SetVigilant(true);
    }
	 bPremiereRafale=true;
    bases.PourcErrance /=100;
    VitesseDeplacements=1.1;
    Temps_ref = level.timeseconds;
    DistNearWall=200;
    DistanceDeplacement=200;
    Temps_errance=0;
    Temps_RefreshEnemyPos=0.8-0.1*bases.skill;
init_etats:
    //*****      passe en attaque scriptee si declenche par gennmi avec reseauattaque!=0 *******
    if (bases.bBasesGenere && bases.NumReseauAttaque!=0 && bases.bPasseAttScr_ApresGen)
    {
        enemy=chercheNMIplusproche();
        if (enemy==none)     //blindage
            enemy=XIII;
		  LastSeenTime = Level.TimeSeconds;
        LastSeeingPos = Pawn.Location;
        LastSeenPos = Enemy.Location;

	     if (CHARGE_LES_LOGS) log(pawn@"ETAT Je vais essayer de prendre mon reseau d'attaque");
        LastAttackPoint=none;
        LastAttackPoint=chercheAttackPoint();
        if (lastAttackPoint!=none) //AttackPoint plus pres que enemy
        {
            MoveTarget=none;
            if (ActorReachable(LastAttackpoint))
            {
                EtatNeutre='tenir';
					 if (!bdejavu) bDejaVu = true;
                gotostate('attaquescriptee');
            }
            else if (FindBestPathToward(LastAttackPoint))
            {
                for (iCompteur=0;iCompteur<16;iCompteur++)
                {
                    if (routecache[iCompteur]==none)
                        break;
                    PointChemin[iCompteur]=routecache[iCompteur];
                }
                NbPointChemin=iCompteur;
                EtatNeutre='tenir';
					 if (!bdejavu) bDejaVu = true;
                gotostate('attaquescriptee');
            }
        }
    }
    else if (pawn.isa('cine2') && bases.bTurnIntoAgressiveSoldier)
    {
        enemy=xiii;
        bdejavu=true;
		  if (enemy==XIII) TriggerEvent('XIIIVu', Self, pawn);  //trigger vu
	     Pawn.Acceleration = vect(0,0,0);
	     Pawn.Velocity = vect(0,0,0);
		  BufferTrigger();
	     if (!genalerte.bAllAlarmsActivated)    ChercheAlarme();  //ALARMEChercheAlarme();  //ALARME
	     pawn.rotationrate.yaw=46000;
	     ChangetoBestWeapon();
	     //init vars attaque
	     CompteurRecalage=15;
        gotostate('attaque','initattaque');
    }
	 BufferTrigger();
    enemy=none;
    //*******************************************************************************************
    if (bases.Order=='faction')
    {
        EtatNeutre='tenir';
        GotoState('faction');
    }
    if (bases.order=='tenir' || bases.order=='garder')
    {
        EtatNeutre='tenir';
        GotoState('tenir');
    }
    if (bases.PourcErrance==1)
        EtatNeutre='errance';
    else
        EtatNeutre='patrouille';
    gotostate(EtatNeutre);
}

// ----------------------------------------------------------------------
// Etat de patrouille
//
// Move from point to point in a predescribed pattern.
// ----------------------------------------------------------------------
State Patrouille
{
    ignores EnemyNotVisible;

	event Tick(float DeltaTime)
	{
	    global.tick(DeltaTime);
		 if (bUTurnMove)  pawn.velocity=100*normal((PointChemin[iCompteur].location-pawn.location)*vect(1,1,0));
	}
    event Seeplayer(pawn other)
    {
        if (setenemy(XIII))
        {
            //log(pawn@"seeplayer"@other);
            bdejavu=true;
        }
    }
    event SeeMonster(pawn other)
    {
        if (setenemy(other))
            bdejavu=true;
    }
    event HearNoise(float Loudness, Actor NoiseMaker)
    {
        if (TestSonEntendu(NoiseMaker))
            enemyacquired();
    }
    event SeeDeadPawn(pawn other)
    {
        local basesoldier Soldier;

        Soldier=basesoldier(other);
        if (bases.BNeVoitPascadavre || Soldier==none || Soldier.DrawType == DT_NONE || Soldier.bMonCadavreEstDejaVu || AllianceLevel(Soldier)!=1)
            return;

        instigator=other;
        bCadavreVu=true;
        Soldier.bMonCadavreEstDejaVu=true;
        EnemyAcquired();
        return;
    }
    event EnemyAcquired()
    {
        gotostate('acquisition');
    }
    singular function DamageAttitudeTo(pawn Other, float Damage)
    {
        //son
        bases.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',bases.CodeMesh,bases.NumeroTimbre);
        if (setenemy(other))
        {
            //genalerte.potepaffe(pawn);
            bPaffe=true;
        }
    }

    function PickDestination()
    {
        if (PatrolPoint(DestNavPoint) != None)
            DestNavPoint = PatrolPoint(DestNavPoint).NextPatrolPoint;
        else
            DestNavPoint = PickStartPoint();
        if (DestNavPoint == None)  // can't go anywhere...
        {
            if (CHARGE_LES_LOGS) log(pawn@"can't go anywhere");
            bases.PourcErrance=1;
            etatneutre='Errance';
            GotoState('Errance');
        }
    }
    function bool IsPointInCylinder(Actor cylinder, Vector point,optional float extraRadius, optional float extraHeight)
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
    function beginstate()
    {
        if (CHARGE_LES_LOGS) log(pawn@"ETAT patrol patrol");
        settimer(0,false);
        if (bases.bPatrolWithWalkSearchAnim)
        {
            pawn.SetAnimStatus('alert');
        }
        if (NiveauAlerte==1)
        {
            s_incattente();
            s_decAlerte();
        }
        else if (NiveauAlerte==2)
        {
            s_incattente();
            s_decAttaque();
        }
        NiveauAlerte=0;
        //var temp
			//btemp_bool
        //temp_int=0;
			//temp_vect utilise pour calcul dangle avec
		if (bases.codemesh==2)     //pas d'anim pour WIG
		{
			WaitPatrolAnim='WaitNeutre';
			PatrolAnim ='Walk';
		}
		else
		{
		  Switch (pawn.weapon.inventorygroup)
		  {
			  case 2: //beretta magnum
			  case 3:
					if (rand(2)<1)
					{
						WaitPatrolAnim='Waitpatrouille1Pistol';
						PatrolAnim='Patrouille1Pistol';
						TurnRPatrolAnim='TurnRPatrouille1Pistol';
						TurnLPatrolAnim='TurnLPatrouille1Pistol';
					}
					else
					{
						WaitPatrolAnim='Waitpatrouille2Pistol';
						PatrolAnim='Patrouille2Pistol';
						TurnRPatrolAnim='TurnRPatrouille2Pistol';
						TurnLPatrolAnim='TurnLPatrouille2Pistol';
					}
					break;
			  case 6 :   //arbalette et arbalette x3
			  case 7 :
			  case 9 :  //fusilpompe, kalash et M16
           case 11 :
			  case 12:
					if (rand(4)<1)
					{
						WaitPatrolAnim='Waitpatrouille2Gun';
						PatrolAnim='Patrouille2Gun';
						TurnRPatrolAnim='TurnRPatrouille2Gun';
						TurnLPatrolAnim='TurnLPatrouille2Gun';
					}
					else
					{
						WaitPatrolAnim='Waitpatrouille1Gun';
						PatrolAnim='Patrouille1Gun';
						TurnRPatrolAnim='TurnRPatrouille1Gun';
						TurnLPatrolAnim='TurnLPatrouille1Gun';
					}
					break;

				case 16: //M60
					PatrolAnim ='WalkGatling';
					WaitPatrolAnim='WaitGatling';
					TurnRPatrolAnim='';
					TurnLPatrolAnim='';
					break;
				case 8:    //fusil de chasse et lance harpon
			  	case 10:
						WaitPatrolAnim='Waitpatrouille1Gun';
						PatrolAnim ='Patrouille1Gun';
						TurnRPatrolAnim='TurnRPatrouille1Gun';
						TurnLPatrolAnim='TurnLPatrouille1Gun';
					break;
			  case 13: //uzi
						WaitPatrolAnim='Waitpatrouille2Pistol';
						PatrolAnim ='Patrouille2Pistol';
						TurnRPatrolAnim='TurnRPatrouille2Pistol';
						TurnLPatrolAnim='TurnLPatrouille2Pistol';
					break;
			  case 15: //bazook
					WaitPatrolAnim='WaitBazooka';
					PatrolAnim ='WalkBazook';
					TurnRPatrolAnim='';
					TurnLPatrolAnim='';
					break;
				case 14:
					PatrolAnim ='WalkGatling';
					WaitPatrolAnim='SniperWait';
					TurnRPatrolAnim='';
					TurnLPatrolAnim='';
					break;
				default:
				    Switch (bases.CodeMesh)
					{
						case 3:
						case 7:
						case 9:
						case 17:
						case 11:
						case 12:
						case 13:
						case 14:
							WaitPatrolAnim='WaitNeutre';
							PatrolAnim ='Walk';
							break;
						default:
							WaitPatrolAnim='WaitNeutre';
							PatrolAnim ='WalkNeutre';
					}

			}
		}
   	Settimer2(0,false);
		 pawn.AnimBlendToAlpha(bases.FIRINGCHANNEL+1,1,0.5);
		 bases.TakeAnimControl(false);
    }
    function Endstate()

    {
        if (bases.bPatrolWithWalkSearchAnim)
        {
            pawn.SetAnimStatus('quiet');
        }
		  if (bControlAnimations) bases.ReleaseAnimControl();
    	  bUTurnMove=false;
    }
Begin:
    DestNavPoint = None;
Patrol:
    PickDestination();
    LastPatrolPoint=PatrolPoint(DestNavPoint);
	 if (LastPatrolPoint==none)
	 {
			log(pawn@"PROBLEME DE RESEAU DE PATROUILLE");
			gotostate('tenir');
	 }
combi_errance_patrouille:
    if (Bases.PourcErrance>0)
    {
        if ((level.timeseconds-Temps_ref)>Temps_Errance)
        {
            Temps_errance=bases.PourcErrance*10+2*Frand();
            Temps_ref=level.timeseconds;
            gotostate('errance');
        }
    }

Moving:
    // Move from pathnode to pathnode until we get where we're going
	if (!IsPointInCylinder(pawn,LastPatrolPoint.Location,16-pawn.CollisionRadius))
	{
		MoveTarget=none;
		if (FastTrace(LastPatrolPoint.location-vect(0,0,30),pawn.location-vect(0,0,30)))
		{
			routecache[0]=LastPatrolPoint;
			routecache[1]=none;
		}
		else if (!FindBestPathToward(LastPatrolPoint))
		{
			if (CHARGE_LES_LOGS) log(pawn@"trouve pas le patrolpoint");
			bases.PourcErrance=1;
			Etatneutre='Errance';
			GotoState('Errance');
		}
		for (iCompteur=0;iCompteur<16;iCompteur++)
		{
			if (routecache[iCompteur]==none)
				break;
			PointChemin[iCompteur]=routecache[iCompteur];
		}
		NbPointChemin=iCompteur;
		for (iCompteur=0;iCompteur<NbPointChemin;iCompteur++)
		{
			if (LastPatrolPoint.bEnCourant)
			{
				focus=none;
				focalpoint=1000*(PointChemin[iCompteur].location-pawn.location)+pawn.location;
				pawn.bmoving=true; //pour tap tap
				bases.ReleaseAnimControl();
				MoveToward(PointChemin[iCompteur],none);
				bases.TakeAnimControl(false);
				pawn.AnimBlendToAlpha(bases.FIRINGCHANNEL+1,1,0.3);
			}
			else
			{
				Temp_vect=normal(PointChemin[iCompteur].location-pawn.location);
				if (TurnRPatrolAnim!='')
				{
					Temp_float= Temp_vect dot vector(pawn.rotation);
					//btemp_bool= true -> tourne vers droite sinon tourne vers gauche
					btemp_bool= (((Temp_vect cross vect(0,0,-1)) dot vector(pawn.rotation))<0);
				}
				else
					temp_float=2; //cheat
				focus=none;
				focalpoint=10000*Temp_vect+pawn.location;
				if (Temp_float<0.3)
				{
					if (btemp_bool) //droite
						pawn.PlayAnim(TurnRPatrolAnim,1,0.1,bases.FIRINGCHANNEL+1);
					else
						pawn.PlayAnim(TurnLPatrolAnim,1,0.2,bases.FIRINGCHANNEL+1);
  				   pawn.rotationrate.yaw=20000*(1-temp_float)-1000;
				}

				if (Temp_float<0.3)
				{
					sleep(0.5);
					bUTurnMove=true;
					if (btemp_bool) //a droite anim plus longue
						sleep(0.68);
					else
						sleep(0.38);
				}
				pawn.bmoving=true; //pour tap tap
				pawn.LoopAnim(PatrolAnim,1,0.1,bases.FIRINGCHANNEL+1);
				if (Temp_float<0.3)
				{
					pawn.rotationrate.yaw=26000;
					bUTurnMove=false;
				}
				MoveToward(PointChemin[iCompteur],none,bases.walkingspeed);
			}
		}
	}
Pausing:
    // Turn in the direction dictated by the WanderPoint, or a random direction
    //pawn.SpineYawControl(true,2000+rand(1000),0.8+0.6*frand());
	pawn.bmoving=false; //pour tap tap
	if (LastPatrolPoint.TypeSon!=rien && 100*frand()<=LastPatrolPoint.ProbaJouerOno)
	{
		Switch(LastPatrolPoint.TypeSon)
		{
			Case Sifflements: pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJWhistle',bases.CodeMesh,bases.NumeroTimbre); break;
			Case Eternuments: pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJSneeze',bases.CodeMesh,bases.NumeroTimbre); break;
			Case Toux: pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJCough',bases.CodeMesh,bases.NumeroTimbre); break;
			case OnoAleatoire :
				switch (rand(3))
				{
					Case 0: pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJWhistle',bases.CodeMesh,bases.NumeroTimbre); break;
					Case 1: pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJSneeze',bases.CodeMesh,bases.NumeroTimbre); break;
					Case 2: pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJCough',bases.CodeMesh,bases.NumeroTimbre); break;
				}
		}
	}
	if ((LastPatrolPoint.pausetime > 0) || (LastPatrolPoint.NextPatrolPoint == None))
	{
		pawn.Acceleration = vect(0, 0, 0);
		pawn.velocity=vect(0,0,0);
		if (LastPatrolPoint.PatrolAnim.length>0)
		{
			temp_int=rand(LastPatrolPoint.PatrolAnim.length);
			if (LastPatrolPoint.bBoucleSurAnim)
				bases.loopAnim(LastPatrolPoint.PatrolAnim[temp_int],,0.4,bases.FIRINGCHANNEL+1);
			else
				bases.playAnim(LastPatrolPoint.PatrolAnim[temp_int],,0.4,bases.FIRINGCHANNEL+1);
			FocalPoint = pawn.Location + LastPatrolPoint.lookdir;
			Focus=none;
			finishrotation();
		}
		else
		{
			/*Temp_vect=vector(LastPatrolPoint.rotation);
			Temp_float= Temp_vect dot vector(pawn.rotation);
			//btemp_bool= true -> tourne vers droite sinon tourne vers gauche
			btemp_bool= (((Temp_vect cross vect(0,0,-1)) dot vector(pawn.rotation))<0);
		 	if (abs(Temp_float)<0.707)  			//anim pietinement
			{
				if (btemp_bool) //droite
					pawn.loopAnim('RotationD',1,0.3,2);
				else
					pawn.loopAnim('RotationG',1,0.3,2);
			}
			pawn.AnimBlendToAlpha(2,1,0.3);
			pawn.LoopAnim(WaitPatrolAnim,1,0.3,bases.FIRINGCHANNEL+1);
		 	pawn.AnimBlendToAlpha(bases.FIRINGCHANNEL+1,0.5,0.3);   */
			pawn.LoopAnim(WaitPatrolAnim,1,0.3,bases.FIRINGCHANNEL+1);
			FocalPoint = pawn.Location + LastPatrolPoint.lookdir;
			Focus=none;
			finishrotation();
			//pawn.AnimBlendToAlpha(2,0,0.5);
			//pawn.AnimBlendToAlpha(bases.FIRINGCHANNEL+1,1,0.3);
		}
		sleeptime=Frand()*LastPatrolPoint.deltatime;
		if (FRand()<0.5)
			sleeptime*=-1;
		sleepTime += LastPatrolPoint.pausetime*0.55;
		sleeptime = fmax(0.02,sleeptime);
		Sleep(sleepTime);
		if (LastPatrolPoint.event != '')
		{
			TriggerEvent(LastPatrolPoint.event, pawn, pawn);
		}
	}
	if (LastPatrolPoint.bResteSurDernier)
	{
		if (CHARGE_LES_LOGS) log(pawn@"stay here");
		stop;
	}
    Goto('Patrol');
}

// ----------------------------------------------------------------------
// Etat d'errance
//
//
// ----------------------------------------------------------------------
state Errance
{
    ignores EnemyNotVisible;

    event Seeplayer(pawn other)
    {
        if (setenemy(XIII))
            bDejaVu=true;
    }
    event SeeMonster(pawn other)
    {
        if (setenemy(other))
            bDejaVu=true;
    }
    event SeeDeadPawn(pawn other)
    {
        local basesoldier Soldier;

        Soldier=basesoldier(other);
        if (bases.BNeVoitPascadavre || Soldier==none || Soldier.DrawType == DT_NONE || Soldier.bMonCadavreEstDejaVu || AllianceLevel(Soldier)!=1)
            return;
        instigator=other;
        bCadavreVu=true;
        Soldier.bMonCadavreEstDejaVu=true;
        EnemyAcquired();
        return;
    }
    event EnemyAcquired()
    {
        gotostate('acquisition');
    }
    event HearNoise(float Loudness, Actor NoiseMaker)
    {
        if (TestSonEntendu(NoiseMaker))
            enemyacquired();
    }
    singular function DamageAttitudeTo(pawn Other, float Damage)
    {
        //son
        bases.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',bases.CodeMesh,bases.NumeroTimbre);
        if (setenemy(Other))
        {
            //genalerte.potepaffe(pawn);
            bPaffe=true;
        }
    }
    function PickDestination()
    {
        local vector pick, pickdir;
        local bool success;
        local float XY;
        local float MoveDist;

        //Favor XY alignment
        //Log(self$" GetFacingDirection Y.Dir="$(Y dot dir)$" X.Dir="$(X dot dir));
        XY = FRand();
        if (XY < 0.3)
        {
            pickdir.X = 1;
            pickdir.Y = 0;
        }
        else if (XY < 0.6)
        {
            pickdir.X = 0;
            pickdir.Y = 1;
        }
        else
        {
            pickdir.X = 2 * FRand() - 1;
            pickdir.Y = 2 * FRand() - 1;
        }
        if (Pawn.Physics != PHYS_Walking)
        {
            pickdir.Z = 2 * FRand() - 1;
            pickdir = Normal(pickdir);
        }
        else
        {
            pickdir.Z = 0;
            if (XY >= 0.6)
                pickdir = Normal(pickdir);
        }
        MoveDist = 150+DistanceDeplacement*(0.4+0.6*Frand());
        success = TestDirection(150.0,MoveDist,pickdir, pick);
        if (!success)
            if ((bTemp_Bool) && (FRand()<0.7))   //if don't work try to go straight
            {
                MoveDist = 150+DistanceDeplacement*(0.4+0.6*Frand());
                success = TestDirection(150,MoveDist,vector(pawn.rotation), pick);
            }
            else      //if don't work try in the opposite side
            {
                MoveDist = 150+DistanceDeplacement*(0.4+0.6*Frand());
                success = TestDirection(150,movedist,-1*pickdir, pick);
            }

            if (success)
            {
                bTemp_Bool=true;
                DistNearWall=min(200,DistNearWall+5);
                DistanceDeplacement=min(600,DistanceDeplacement+45);
                Destination = pick;
            }
            else
            {
                bTemp_Bool=false;
                DistNearWall=fmax(4*pawn.collisionradius,DistNearWall-40);
                DistanceDeplacement=max(10,DistanceDeplacement-35);
                GotoState('errance','Turn');
            }
    }

    function bool IsInWanderingVolume(WanderingVolume aVolume)
    {
        local WanderingVolume V;

        ForEach pawn.TouchingActors(class'WanderingVolume',V)
            if ( V == aVolume )
                return true;
            return false;
    }
    function beginstate()
    {
        settimer(0,false);
        if (NiveauAlerte==1)
        {
            s_incattente();
            s_decAlerte();
        }
        else if (NiveauAlerte==2)
        {
            s_incattente();
            s_decAttaque();
        }
        NiveauAlerte=0;
        MinHitWall += 0.15;
        //test si dnas volume d'errance
        if (bases.MyWanderingVolume!=none && !IsInWanderingVolume(bases.MyWanderingVolume))   //dans volume
        {
            if (CHARGE_LES_LOGS) log(pawn$"pas dans le volume donc erre partout");
            bases.MyWanderingVolume=none;
        }
    }
    function Endstate()
    {
        MinHitWall -= 0.15;
        pawn.SpineYawControl(false,0,0);
    }

Begin:
    if (CHARGE_LES_LOGS) log(pawn@"ETAT  Wandering");
Wander:
    pawn.SpineYawControl(true,3000+rand(1000),1.2+0.8*frand());
    PickDestination();
combi_errance_patrouille:
    if (Bases.PourcErrance<1)
    {
        if ((level.timeseconds-Temps_ref)>Temps_Errance)
        {
            Temps_errance=(1-bases.PourcErrance)*10+2*Frand();
            Temps_ref=level.timeseconds;
            gotostate('patrouille');
        }
    }
Moving:
    focalpoint=destination;
    Temp_float=normal(destination-pawn.location) dot normal(vector(pawn.rotation));
    if (Temp_float<0.3)
        sleep(10000*(1-Temp_float)/pawn.rotationrate.yaw);
    MoveTo(Destination,None, Bases.WalkingSpeed);
Pausing:
    Pawn.Acceleration = vect(0,0,0);
    pawn.velocity=vect(0,0,0);
    pawn.SpineYawControl(true,2000+rand(1000),0.8+0.6*frand());
    if (bases.MyWanderingVolume!=none && !IsInWanderingVolume(bases.MyWanderingVolume))   //dans volume
    {
        //log(pawn$"ATTENTION je sort du volume demi-tour");
        focalpoint=-DistanceDeplacement*vector(pawn.rotation)+pawn.location;
        finishrotation();
        DistanceDeplacement=max(10,DistanceDeplacement-40);
        MoveTo(focalpoint,None, Bases.WalkingSpeed);
    }
    if (NearWall(DistNearWall))
    {
        DistanceDeplacement=max(10,DistanceDeplacement-10);
        DistNearWall=fmax(2*pawn.collisionradius,DistNearWall-5);
        FinishRotation();
    }
    Sleep(1.0);
    goto('wander');
Turn:
    pawn.SpineYawControl(true,2000+rand(1000),0.8+0.6*frand());
    pawn.velocity=vect(0,0,0);
    Pawn.Acceleration = vect(0,0,0);
    Focus = None;
    FocalPoint = Location + 20 * VRand();
    FinishRotation();
    Goto('Pausing');
}

// ----------------------------------------------------------------------
//Etat tenir
//
//
// ----------------------------------------------------------------------
state Tenir
{
    ignores EnemyNotVisible;
    event Seeplayer(pawn other)
    {
        if (setenemy(XIII))
            bDejaVu=true;
    }
    event SeeMonster(pawn other)
    {
        if (setenemy(other))
            bDejaVu=true;
    }
    event SeeDeadPawn(pawn other)
    {
        local basesoldier Soldier;

        Soldier=basesoldier(other);
        if (bases.BNeVoitPascadavre || Soldier==none || Soldier.DrawType == DT_NONE || Soldier.bMonCadavreEstDejaVu || AllianceLevel(Soldier)!=1)
            return;

        instigator=other;
        bCadavreVu=true;
        Soldier.bMonCadavreEstDejaVu=true;
        EnemyAcquired();
        return;
    }
    event EnemyAcquired()
    {
        gotostate('acquisition');
    }
    event HearNoise(float Loudness, Actor NoiseMaker)
    {
        if (TestSonEntendu(NoiseMaker))
            enemyacquired();
    }
    singular function DamageAttitudeTo(pawn Other, float Damage)
    {
        //son
        bases.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',bases.CodeMesh,bases.NumeroTimbre);
        if (setenemy(Other))
        {
            //genalerte.potepaffe(pawn);
            bPaffe=true;
        }
    }
    function beginstate()
    {
        settimer(0,false);
        if (NiveauAlerte==1)
        {
            s_incattente();
            s_decAlerte();
        }
        else if (NiveauAlerte==2)
        {
            s_incattente();
            s_decAttaque();
        }
        NiveauAlerte=0;
        pawn.SpineYawControl(true,2000+rand(1000),0.8+0.6*frand());
    }
    function Endstate()
    {
        if (EtatNeutre == 'tenir')
        {
            PointTenirPos=pawn.location;
            PointTenirRot=pawn.rotation;
        }
        pawn.SpineYawControl(false,0,0);
    }

BackToFormation:
    if (CHARGE_LES_LOGS) log(pawn@"ETAT tiens position  BACKTO FORMATION");
    if (FastTrace(PointTenirPos-vect(0,0,30)))
    {
        focalpoint=PointTenirPos;
        focus=none;
        MoveTo(PointTenirPos,none);
        focalpoint=1000*vector(pointtenirRot)+pawn.location;
        focus=none;
    }
    else
    {
        if (FindBestPathTo(PointTenirPos))
        {
            for (temp_int=0;temp_int<16;temp_int++)
            {
                if (routecache[temp_int]==none)
                    break;
                PointChemin[temp_int]=routecache[temp_int];
            }
            NbPointChemin=temp_int;
            for (iCompteur=0;iCompteur<NbPointChemin;iCompteur++)
            {
                MoveToward(PointChemin[iCompteur],PointChemin[iCompteur]);
            }
            focalpoint=PointTenirPos;
            focus=none;
            MoveTo(PointTenirPos,none);
            focalpoint=vector(pointtenirRot)+pawn.location;
        }
    }
begin:
    if (CHARGE_LES_LOGS) log(pawn@"ETAT tiens position");
    pawn.velocity=vect(0,0,0);
    pawn.Acceleration = vect(0,0,0);
Targetenemy:
}

// ----------------------------------------------------------------------
// Etat de ResteSurPlace
//
//
// ----------------------------------------------------------------------
state ResteSurPlace
{
    ignores EnemyNotVisible,hearnoise;

    singular event bool NotifyBump(actor Other)
    {
        return false;
    }

    event Tick(float DeltaTime)
    {
        global.tick(DeltaTime);

        if (bFuitPourreloader && (level.timeseconds-Timer_VaRecharger)>1.5)
        {
            bFuitPourreloader=false;
            gotostate('attaque');
        }
    }

    event Seeplayer(pawn other)
    {
			if (enemy==none || !bdejavu)
			{
				if (setenemy(XIII))
                bDejaVu=true;
			}
			else  if (enemy!=none && enemy==other)
            	SeeEnemy();
    }
    event SeeMonster(pawn other)
    {
        if (enemy==none || !bdejavu)
			{
				if (setenemy(other))
                bDejaVu=true;
			}
			else
			{
			  if (enemy!=none && enemy==other)
            	SeeEnemy();
		  }
    }
    event SeeDeadPawn(pawn other)
    {
        local basesoldier Soldier;

        Soldier=basesoldier(other);
        if (bases.BNeVoitPascadavre || Soldier==none || Soldier.DrawType == DT_NONE || Soldier.bMonCadavreEstDejaVu || AllianceLevel(Soldier)!=1)
            return;
        Soldier.bMonCadavreEstDejaVu=true;
        instigator=other;
        bCadavreVu=true;
        EnemyAcquired();
        return;
    }
    event EnemyAcquired()
    {
        if (bCampeversSafePoint)
            gotostate('acquisition');
        else
            gotostate('attaque');
    }

    singular function DamageAttitudeTo(pawn Other, float Damage)
    {
        //son
        bases.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',bases.CodeMesh,bases.NumeroTimbre);

        if (bDisableDamageattitudeto)
            return;
        if (setenemy(Other))
        {
            //genalerte.potepaffe(pawn);
            bPaffe=true;
        }
    }
    function bool TestDirectionAvoidingAlly(vector pickdir, out vector pick,basesoldier PoteAEviter)
    {
        local float MoveDist;

        if (Vsize(PoteAEviter.location - pawn.location)>160)
            pickdir += 0.99*normal(Enemy.location-pawn.location); // pour partir a 45 degres si charge
        else
            pickdir +=0.3*normal(Enemy.location-pawn.location); // pour partir a 80 degres si charge

        if (Vsize(PoteAEviter.location - enemy.location)<300 || Vsize(PoteAEviter.location - pawn.location)<=160)
            MoveDist=140;
        else
            MoveDist=110+150*FRand();
        return TestDirection(110,MoveDist,-1*pickdir, pick);
    }

    function bool TestPasSurCote(basesoldier PoteAEviter)
    {
        local vector pick, pickdir;
        local bool success;

        pickdir=(Enemy.location-pawn.location) cross vect(0,0,1);
        pickdir.Z = 0;
        pickdir=normal(pickdir);

        success = TestDirectionAvoidingAlly(pickdir, pick,PoteAEviter);
        if (!success)
            success = TestDirectionAvoidingAlly(-1*pickdir, pick,PoteAEviter);
        Destination = pick;
        return success;
    }

    function beginstate()
    {
        //reactions
        //bDisableEventSeeDeadPawn=true; //desactive detection cadavre
        if (!bCadavreVU)
	     		focus=xiii; //cheat Il sait ou est XIII
         else
	     		focus=none;
        if (bCampeversSafePoint)
        {
            bdejavu=false;
            bases.balerte=true;
            SetVigilant(true);
            bEtatAlerte=true;
            enemy=none;
        }
        else
        {
            bDejaVu=true;     //desactive detection son
        }
        settimer(0,false);
        if (NiveauAlerte==0)
        {
            s_decattente();
            s_incAlerte();
        }
        else if (NiveauAlerte==2)
        {
            s_incalerte();
            s_decAttaque();
        }
        NiveauAlerte=1;
        bFuitPourreloader=false;
    }
    function Endstate()
    {
	    if (bcontrolanimations) bases.ReleaseAnimControl();
        if (pawn.biscrouched)
            pawn.shouldcrouch(false);
        bDisableDamageattitudeto=false;
        bCampeversSafePoint=false;
        bRetraiteVersSafePoint=false;
			if (SafePointOccupe!=none)
			{
				SafePointOccupe.timer();
				SafePointOccupe=none;
			}
			if (bCadavreVU)
	 		{
				bcadavrevu=false;
				Pawn.PeripheralVision=fmin(DefaultPeripheralVision,0);
			}
    }

    //y rester 10 s si alarme ou fuite, sinon tout le temps (pour bruit d'impact et quoique)
begin:
    pawn.velocity=vect(0,0,0);
    pawn.acceleration=vect(0,0,0);
    if (CHARGE_LES_LOGS) log(pawn@"ETAT Reste SUr Place");
	 if (bCadavreVU)
	 {
			pawn.playwaiting();
			focus=none;
			focalpoint+=0.5*vsize(focalpoint)*normal(XIII.location-pawn.location);
      	finishrotation();
			sleep(0.1);
			Pawn.PeripheralVision=fmin(DefaultPeripheralVision,-0.5);
			bases.PlayQuickLookAround();
			FinishAnim(bases.firingChannel+1);
			Bases.ReleaseAnimControl();
			pawn.playwaiting();
			sleep(1.15);
			bases.Shouldcrouch(true);
    }
	 if (enemy!=none)
    {
        focus=enemy;
        finishrotation();
    }
    if (bRetraiteVersSafePoint)
    {
        sleep(1+4*frand());
        gotostate('attaque');
    }
    stop;
PoteMeBLoque:
    if (PoteQuiMeBloque==none)  //blindage
        gotostate('attaque');
    log(pawn@"POTE ME BLOQUE J4ATTEND EN ME RECALANT");
    disable('seeplayer');
    disable('seemonster');
    pawn.velocity=vect(0,0,0);
    pawn.acceleration=vect(0,0,0);
	if (enemy!=none)
   {
		//if (fasttrace(-200*vector(pawn.rotation)+pawn.location))
      Moveto(-200*vector(pawn.rotation)+pawn.location,enemy,bases.walkingspeed);
   }
   else
   {

      //if (fasttrace(-200*vector(pawn.rotation)+pawn.location))
      Moveto(-200*vector(pawn.rotation)+pawn.location,PoteQuiMeBloque,bases.walkingspeed);
   }
    //boucle pour un max de 3s
	sleep(0.5+frand());
    for (temp_int=0;temp_int<6;temp_int++)
    {
        if (PoteQuiMeBloque.bisdead || vsize(PoteQuiMeBloque.location-PoteQuiMeBloquePos)>100)
            break;
			sleep(0.5);
    }
	bases.bslave=false;
	bases.bDetecteBloquage=false;
   PoteQuiMeBloque=none;
   gotostate(prevstate);
}
// ----------------------------------------------------------------------
// Etat d'acquisition        (enemy!=none)
//
//
// ----------------------------------------------------------------------

state Acquisition
{
	Function SeeEnemy()
	{
		LastSeenTime = Level.TimeSeconds;
		LastSeeingPos = Pawn.Location;
		LastSeenPos = Enemy.Location;
		EnemyAcquired();
	}
	event timer2()
	{
			LOCAL Rotator rl;
			LOCAL int n;

			if ( PeeredEnemy!=none )
			{
				rl=rotator(PeeredEnemy.Location-pawn.Location)-pawn.Rotation;

				n=rl.Yaw;//-16384;
				n=((n+32768)&65535)-32768;

				if ((15000>n) && (n>-15000))
				{
					pawn.HeadYaw = pawn.HeadYaw*0.6+0.4*n;
					rl.Yaw=0;
					rl.Pitch=0;
					rl.Roll=pawn.HeadYaw;
					pawn.SetBoneRotation('X HEAD',rl,,0.75);
				}
				else
				{
					pawn.HeadYaw = pawn.HeadYaw*0.7;
					rl.Yaw=0;
					rl.Pitch=0;
					rl.Roll= pawn.HeadYaw;
					pawn.SetBoneRotation('X HEAD',rl,,0.75);
				}
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
	 event Seeplayer(pawn other)
    {
			if (!bDejaVu && enemy!=none && enemy==other)
            	SeeEnemy();
			else
				setenemy(XIII);
    }
    event SeeMonster(pawn other)
    {
        if (!bDejaVu && enemy!=none && enemy==other)
            	SeeEnemy();
		  else
				setenemy(other);
    }
    event SeeDeadPawn(pawn other)
    {
        local basesoldier soldier;

        soldier=basesoldier(other);

        if (bases.BNeVoitPascadavre || bCadavreVu || !bStepNoise || soldier==none || Soldier.DrawType == DT_NONE || soldier.bMonCadavreEstDejaVu || AllianceLevel(Soldier)!=1)
            return;
        bStepNoise=false;
        bCadavreVu=true;
        instigator=other;
        enemy=none;
        InitReactions();
        Soldier.bMonCadavreEstDejaVu=true;
        gotostate('acquisition','CadavreVu');
    }
    event EnemyNotVisible()
    {
        if (bAVuQuelquechose)
        {
            gotostate('investigation');
        }
        else
        {
				if (!bARienVu)
				{
					bARienVu=true;
				   settimer3(8+2*frand(),false);
				}
            Changeetat(); //dans vu si voit plus s'arrete
        }
    }
    event EnemyAcquired()
    {
        bDejaVu=true;
        bPaffe=false;
        bCadavreVu=false;
        bStepNoise=false;
        bImpactNoise=false;
        bWeaponNoise=false;
        pawn.SpineYawControl(false,0,0);
        disable('seeplayer');
        disable('seemonster');
        gotostate('acquisition','attaque');
    }
    event hearnoise(float loudness, actor NoiseMaker)
    {
        ActualiseSon(NoiseMaker);
    }
    event Trigger(actor Other, pawn EventInstigator)
    {
    }
    singular function DamageAttitudeTo(pawn Other, float Damage)
    {
        local int Level;

        if (bDisableDamageattitudeto)
            return;
        //son
        bases.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',bases.CodeMesh,bases.NumeroTimbre);
        level=AllianceLevel(Other);
        if (level<=0)
        {
            if (level==0)
                SwitchToEnemy(Other);
            bPaffe=true;
            bCadavreVu=false;
            bStepNoise=false;
            bImpactNoise=false;
            enemy=Other;
            InitReactions();
            gotostate('acquisition','Paffe');
        }
    }
    function ActualiseSon(actor son)
    {
		  if (son.instigator!=none && son.instigator.controller!=none && son.instigator.controller.isa('CineController2'))
				return;
        //bruit d'arme prioritaire sur bruitpas
        if (weapon(son)!=none || XIIIProjectile(son)!=none)
        {
            if (alliancelevel(son.instigator)==1) //pote donc prend son enemy
            {
                enemy=son.instigator.controller.enemy;
                instigator=son.instigator;
            }
            else
            {
                enemy=son.instigator;
                instigator=enemy;
            }
            bStepNoise=false;
            bImpactNoise=false;
            bCadavreVu=false;
            bPaffe=false;
            bWeaponNoise=true;
            InitReactions();
            gotostate('acquisition','BruitArme');
        }
        else if ((bStepNoise || bCadavreVu) && BulletDustEmitter(son)!=none && son.instigator==XIII)
        {
            bImpactNoise=true;
            bStepNoise=false;
            bCadavreVu=false;
            enemy=xiii;
            gotostate('acquisition','BruitImpact');
        }
    }
    function ChercheNMIDuRegard() // dans cone de 45 degre autour pos other
    {
        local int Sens;
        local vector Norm;

        Sens=1;
        if (frand()<0.5)
            Sens=-1;
        Norm=normal(enemy.location-pawn.location);
        focalpoint=1000*(Norm+0.8*(Norm cross (sens*vect(0,0,1))))+pawn.location;
    }

    Function InitReactions()
    {
        bDisableDamageattitudeto=false;
        //si bruit de pas desactive rien
        if (!bStepNoise)
        {
            //bDisableEventSeeDeadPawn=true;
            if (!bImpactNoise && !bCadavreVu)
            {
                bDisableDamageattitudeto=true;
                if (!bPaffe) //donc vu ou bruit d'arme
                {
                    disable('hearnoise');
                    if (bDejaVu)
                    {
                        disable('seeplayer');
                        disable('seemonster');
                    }
                }
            }
        }
    }
    /* [****] integrer si le positionnnement n'est pas bon
    A REVOIR ENTIEREMENT
    function CherchePointPresDernierePos()
    {
    local NavigationPoint N, Best;
    local vector Dir, EnemyDir;
    local float Dist, BestVal, Val;

      EnemyDir = Normal(Enemy.Location - Pawn.Location);
      for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
      {
      Dir = N.Location - LAstSeenPos;
      Dist = VSize(Dir);
      if (Dist<200)
      {
      Val = (EnemyDir Dot Dir/Dist);
      if ((Val > BestVal) && LineOfSightTo(N))
      {
      BestVal = Val;
      Best = N;
      }
      }
      }
      if ( Best != None )
      LastSeenPos = Best.Location + 0.5 * Pawn.CollisionHeight * vect(0,0,1);
     }  */
    function beginstate()
    {
        disable('enemynotvisible');
        if (NiveauAlerte==0)
        {
            s_decAttente();
            s_incAlerte();
        }
        else if (NiveauAlerte==2)
        {
            s_decAttaque();
            s_incAlerte();
        }
        NiveauAlerte=1;
		  bAVuQuelquechose=false;
        SetVigilant(true); //vigilant
        settimer(0,false);
        //temp_vect utilise pour calcul dest vers cadavre
    }
    function Endstate()
    {
	//		local rotator rl;

        if (interrogation!=none)
        {
            interrogation.destroy();
            interrogation=none;
        }
			//remettre tete
	/*	  PeeredEnemy=none;
		  settimer2(0,false);
		  pawn.HeadYaw=0;
		  rl.Yaw=0;
		 rl.Pitch=0;
			rl.Roll= 0;
			pawn.SetBoneRotation('X HEAD',rl,,0.0); */
        pawn.SpineYawControl(false,0,0);
    }

Begin:
    if (CHARGE_LES_LOGS) log(pawn@"ETAT acquisition");
    if (CHARGE_LES_LOGS) log("bStepNoise"$bStepNoise@"bImpactNoise"$bImpactNoise@"bCadavreVu"$bCadavreVu@"bPaffe"$bPaffe@"bWeaponNoise"$bWeaponNoise@"bDejaVu"$bDejaVu@"enemy"$enemy);

    InitReactions();
    if (!bcadavrevu && enemy.bisdead)
    {
        ChangeEtat();
    }
    Pawn.Acceleration = vect(0,0,0);
    Pawn.Velocity = vect(0,0,0);
Init:
    if (!bDejaVu)
    {
        pawn.SetAnimStatus('alert');
		  //son
    	  Interrogation=Spawn(class'exclamation',self,,bases.location+(vector(bases.rotation) cross vect(0,0,1))*6 + 120*vect(0,0,1));
        interrogation.setbase(pawn);
        pawn.SpineYawControl(true,2000+rand(1000),0.8+0.6*frand());
        if ((bStepNoise || bImpactNoise || bPaffe || bWeaponNoise) && enemy==none)
       		ChangeEtat();
        if ((bCadavreVu || bWeaponNoise) && instigator==none)
       		ChangeEtat();
        if (bStepNoise)
		  {
            goto('BruitPas');
        }
        else
		  {
  			  pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJDetect',bases.CodeMesh,bases.NumeroTimbre);//se retourne vers bruit et reste sur place
	        if (bImpactNoise)
	            goto('BruitImpact');
	        else if (bCadavreVu)
	            goto('CadavreVu');
	        else if (bPaffe)
	            goto('Paffe');
	        else if (bWeaponNoise)
	            goto('BruitArme');
		  }
    }
    else
	 {
		  	if (enemy==none)
				Changeetat();
        goto('Vu');
	 }
BruitPas:
    ChercheNMIDuRegard();
    FinishRotation();
    sleep(2);
    Changeetat();
CadavreVu:
    //va vers cadavre, alarme, investigation (???)
	 Focus=none;
    Focalpoint=10000*(instigator.location-pawn.location)+pawn.location;
    FinishRotation();
    sleep(0.5);
    pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJDetect',bases.CodeMesh,bases.NumeroTimbre);
    pawn.SpineYawControl(false,0,0);
    if (Vsize(instigator.location-pawn.location)<100)   //vavers cadavre
        temp_vect=instigator.location;
    else
        temp_vect=(Vsize(instigator.location-pawn.location)-100)*normal(instigator.location-pawn.location)+pawn.location;
    MoveTo(temp_vect,none);
    TriggerEvent('cadavrevu', self, pawn);
    if (!genalerte.bAllAlarmsActivated)    ChercheAlarme();  //ALARMEChercheAlarme();  //ALARME
    bCampeversSafePoint=true;
    gotostate('ResteSurPlace');
BruitImpact:
    //se retourne vers bruit, alarme, cherche safepoint sinon investigation
    ChercheNMIDuRegard();
    FinishRotation();
    if (!genalerte.bAllAlarmsActivated)    ChercheAlarme();  //ALARMEChercheAlarme();  //ALARME
    if (bases.order!='garder') CherchePointPourCamper(); //interruption possible vers vavers
    gotostate('investigation');
Paffe:
    //se retourne vers tireur (60d), alarme, cherche safepoint sinon investigation
    ChercheNMIDuRegard();
    FinishRotation();
    if (!genalerte.bAllAlarmsActivated)    ChercheAlarme();  //ALARMEChercheAlarme();  //ALARME
    if (bases.order!='garder') CherchePointPourCamper();
    gotostate('investigation');
BruitArme:
    //se retourne vers bruit, alarme, va vers bruit,investigation
    ChercheNMIDuRegard();
    FinishRotation();
    if (!genalerte.bAllAlarmsActivated)    ChercheAlarme();  //ALARMEChercheAlarme();  //ALARME
    if (bases.bRappliqueSiAlerte)
    {
        MoveTarget=none;
        if (Fasttrace(instigator.location-vect(0,0,30),pawn.location-vect(0,0,30)))
        {
            MoveActor.MoveActor=none;
            MovePoint.MovePoint=instigator.location;
            MovePoint.bTraceable=true;
            nextstate='investigation';
            gotostate('vavers');
        }
        else if (FindBestPathToward(instigator))
        {
            MoveActor.MoveActor=none;
            MovePoint.MovePoint=instigator.location;
            MovePoint.bTraceable=false;
            for (iCompteur=0;iCompteur<16;iCompteur++)
            {
                if (routecache[iCompteur]==none)
                    break;
                PointChemin[iCompteur]=routecache[iCompteur];
            }
            NbPointChemin=iCompteur;
            nextstate='investigation';
            gotostate('vavers');
        }
    }
    if (bases.order!='garder') CherchePointPourCamper();       //si peut pas rappliquer ou peut pas aller vers alarme
    gotostate('investigation');
Vu:
	 if (enemy==none || enemy.bisdead)
    {
        ChangeEtat();
    }
    if (bases.bAlerte)
        goto('attaque');
	 else if (bARienVu)
			goto('Identification');
    enable('enemynotvisible');
PointInterro:

    //    if (Vsize(pawn.location-enemy.location)>320)
    Interrogation=Spawn(class'interro',self,,bases.location+110*vect(0,0,1));  // INTERRO
    interrogation.setbase(pawn);
    focus=enemy;
/*
	 PeeredEnemy=enemy; */
//	 settimer2(0.05,true);
    sleep(FMin(1.5,bases.TempsPasVu*Vsize(pawn.location-enemy.location)*0.00025));
	 if (Vsize(pawn.location-enemy.location)>320)
    {
	 	  sleep(FMin(1.5,bases.TempsPasVu*Vsize(pawn.location-enemy.location)*0.00025));
	 }
	// focus=enemy;
	// peeredenemy=none;
Identification:
    if (enemy==none || enemy.bisdead)
    {
        ChangeEtat();
    }
	 if (bARienVu)
	 {
		  enable('enemynotvisible');
		  bARienVu=false;
		  focus=enemy;
		  Settimer3(0,false);
	 }
    bAVuQuelquechose=true;
    pawn.SetAnimStatus('alert');
    if (enemy==xiii) Playercontroller(XIII.controller).MyHud.LocalizedMessage(class'XIIIDialogMessage', 3, none, none, pawn, "?!! ");
    //son
    pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJDetect',bases.CodeMesh,bases.NumeroTimbre);//se retourne vers bruit et reste sur place
    if (interrogation!=none)
    {
       interrogation.destroy();
       interrogation=none;
    }
    if (Vsize(pawn.location-enemy.location)>320)
    {
        Interrogation=Spawn(class'exclamation',self,,bases.location+(vector(bases.rotation) cross vect(0,0,1))*6 + 120*vect(0,0,1));
        interrogation.setbase(pawn);
        sleep(fmin(1.5,(Vsize(pawn.location-enemy.location)*bases.TempsIdentification)*0.00025));
		  if (Vsize(pawn.location-enemy.location)>320)
				sleep(fmin(1.5,(Vsize(pawn.location-enemy.location)*bases.TempsIdentification)*0.00025));
    }
	 disable('enemynotvisible');
    bAVuQuelquechose=false;
attaque:
	 if (enemy==none || enemy.bisdead)
    {
        ChangeEtat();
    }
	 bDisableDamageattitudeto=true;
    if (enemy==XIII) TriggerEvent('XIIIVu', Self, pawn);  //trigger vu
    Pawn.Acceleration = vect(0,0,0);
    Pawn.Velocity = vect(0,0,0);
    if (!genalerte.bAllAlarmsActivated)    ChercheAlarme();  //ALARMEChercheAlarme();  //ALARME
    pawn.rotationrate.yaw=46000;
    finishrotation();
    ChangetoBestWeapon();
    //init vars attaque
    CompteurRecalage=15;    //utilise dans attaque pour savoir si doit se recaler
    gotostate('attaque','initattaque');
}

// ----------------------------------------------------------------------
// Etat d'attaqueH2H         (enemy!=none)
//
//
// ----------------------------------------------------------------------
state AttaqueH2H
{
	ignores hearnoise;

    event EnemyNotVisible()
    {
        if (LigneVisee(enemy.location, LastSeeingPos))
        {
				HalteAuFeu();
            GotoState('TacticalMove','RecoverEnemy');
            return;
        }
        else
        {
				HalteAuFeu();
            gotostate('temporise');
            return;
        }
    }
    event Tick(float deltaseconds)
    {
        local int i;
        local iacontroller iacontr;
        local actor nav;
        local AttitudeInfo attitude;
        local float distanceAXIII;
        local int NBAllieEnCouverture;

        global.tick(deltaseconds);

        if ((enemy==none) || enemy.bisdead)
        {
            ChangeEtat();
            return;
        }
        if ((level.timeSeconds-Temps_Ref2)>5 && bases.order!='garder')
        {
            Attitude=AttitudeToNMI(enemy);
            if (Attitude==ATTITUDE_Fear)    //actualisation attitude
            {
                HalteAuFeu();
                gotostate('fuite');
                return;
            }
            else if (Attitude==ATTITUDE_Impressed)
            {  //retraite possible si enemmi de dos ou assez loin
                if (((enemy.location-pawn.location) dot vector(enemy.rotation))>0 || Vsize(enemy.location-pawn.location)>600)
                    CherchePointRetraite();
            }
            Temps_Ref2=level.timeseconds;
        }
        if ((Level.timeseconds-Temps_ref)>3)
        {
            //recherche alarme
				//log(" cherche alarme"@!genalerte.bAllAlarmsActivated);
            if (!genalerte.bAllAlarmsActivated)    ChercheAlarme();  //ALARMEChercheAlarme();  //ALARME
           //si otage
            if (xiii.bPrisonner && XIII.LHand.pOnShoulder!=none && AllianceLevel(XIII.LHand.pOnShoulder)==1 && enemy==xiii && VSize(pawn.location-enemy.location) < 125)
            {
                if (CHARGE_LES_LOGS) log(pawn$"me colle trop je tir");
                NbCoupsRiposte=(2+bases.agressivite)*1.5;
                NbCoupsRiposte=Min(4,NbCoupsRiposte);
                NbCoupsRiposte=Max(1,NbCoupsRiposte);
            }
      /* [*] a priori que les points
				if (bases.order!='garder')
                ChangetoBestWeapon();   //test nouvelle armeChangetoBestWeapon();   //test nouvelle arme*/

            //Attaquescriptee
            ChercheReseauAttaque();
            Temps_Ref=Level.timeseconds;
        }
    }
	event timer3()
   {
      EnemyTargetPos=enemy.location;
      EnemyTargetVelocity=enemy.velocity;
		if (bInWaitMode && (Vsize(enemy.location-temp_vect)>50 || VSize(enemy.location-pawn.location)<120))
	   {
			bInWaitMode=false;
			HalteAufeu();
			bases.releaseAnimControl(true);
			gotostate('attaqueH2H','charge');
		}
   }
    event SeeDeadPawn(pawn other)
    {
        if (ChercheBonMatos(other))		//CadavreWithPickup affecte a other dans Cherchebonmatos
        {
            HalteAufeu();
            bDisableEventSeeDeadPawn=true;
            CadavreWithPickup.bDejaFouille=true;
            gotostate('tacticalmove','chercheobjet');
        }
    }
    event UpdateTactics()
    {
        if (Vsize(enemy.location-temp_vect)>50)
        {
            badvancedtactics=false;
            gotostate('AttaqueH2H','charge');
        }
    }

    function NotifyFiring()
    {
		  if (enemy==none)
				return;

		  DirectionTir=DirectionDuTir(); //recupere direction du tir avant dispersion
        CheckLineOfFire();
    }
    function DamageAttitudeto(pawn Other, float Damage)
    {
        if (bases.bisdead)
            return;
        //son
        bases.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',bases.CodeMesh,bases.NumeroTimbre);
        If (xiii.bPrisonner && XIII.LHand.pOnShoulder!=none && AllianceLevel(XIII.LHand.pOnShoulder)==1 && other==xiii)
        {
           if (CHARGE_LES_LOGS) log(pawn$"je riposte");
           NbCoupsRiposte=(2+bases.agressivite)*1.9;
           NbCoupsRiposte=Min(5,NbCoupsRiposte);
           NbCoupsRiposte=Max(1,NbCoupsRiposte);
        }
    }

    function ReceiveWarning(pawn shooter, float projspeed,vector firedir)
    {
    }

	function bool LookForNearestPoint()
	{
		local navigationpoint nav,bestnav;
		local float DistancePoint;
		local float DistanceNMI;
		local int i;

		DistancePoint=1000;  //init
		if (enemy==none)
			return false;
      btemp_bool=false;
		nav = Level.NavigationPointList;
      while (nav != None)
      {
			DistanceNMI=vsize(nav.location-enemy.location);
//			log(nav@vsize(nav.location-enemy.location)<300@Vsize(nav.location-pawn.location)>=(pawn.collisionradius*1.2)@(bestnav==none || vsize(nav.location-enemy.location)<vsize(bestnav.location-enemy.location)));
			if (DistanceNMI<300)
			{
				if (Vsize(nav.location-pawn.location)<(pawn.collisionradius*2) && rand(3)<2)
				{
					 nav = nav.nextNavigationPoint;
					continue;
				}
				if (DistanceNMI<DistancePoint)
				{
					DistancePoint=DistanceNMI;
					Bestnav=nav;
				}
			}
         nav = nav.nextNavigationPoint;
		}
		if (BestNav==none)
			return false;
		if (actorreachable(BestNav))
		{
			btemp_bool=true;
			movetarget=BestNav;
			return true;
		}
		else if (findBestPathToward(BestNav))
		{
			btemp_bool=false;
			movetarget=BestNav;
			return true;
		}
		return false;
	 }
    function BeginState()
    {
        disable('enemynotvisible');
		  //log(pawn@"ajoute perso dans la liste des basesoldierinfight");
        genalerte.SoldierInFightList.length=genalerte.SoldierInFightList.length+1;
        genalerte.SoldierInFightList[genalerte.SoldierInFightList.Length-1]=bases;
        pawn.SetAnimStatus('alert');
		  EnemyTargetPos=enemy.location;
    		EnemyTargetVelocity=enemy.velocity;
        if (NiveauAlerte==0)
        {
            s_decAttente();
            s_incAttaque();
        }
        else if (NiveauAlerte==1)
        {
            s_decAlerte();
            s_incAttaque();
        }
        NiveauAlerte=2;
		  bARienVu=false;
        Temps_Ref2=level.timeseconds-2;
        Temps_Ref=Temps_Ref2;
        settimer3(Temps_RefreshEnemyPos,true);
		//	btemp_bool=false; //sert a savoir si le nearestpoint est directement atteignable ou par chemin
        //***** Var temp *******
        //temp_float=0.0;
        ///temp_vect=vect(0,0,0);  //1) pour garder ancienne position ennemi dans updatetacics 2) dans saut
        //PointDestination=vect(0,0,0);
        //temp_int=0; //utilise pour boucle sur pointchemin

    }
    function EndState()
    {
        local int i;

        settimer3(0,false);
        bAdvancedTactics=false;
        bEtatAlerte=true;
        //vire soldierinfightlist
		  //log(pawn@"VIRE perso dans la liste ");
        for (i=0;i<genalerte.SoldierInFightList.Length; i++)
        {
            if (genalerte.SoldierInFightList[i] == pawn )
            {
					//log(pawn@"JE ME VIRE de la liste des basesoldierinfight");
                genalerte.SoldierInFightList.Remove(i,1);
                break;
            }
        }
		  if (bcontrolanimations) bases.releaseanimcontrol();
    }
begin:
    if (CHARGE_LES_LOGS) log(pawn@"Etat attaqueH2H    "$enemy);
    if (enemy==none)
    {
        log(pawn@"ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none **");
        //enemy=xiii;
    }
    temp_vect=enemy.location;
    focus=enemy;
charge:
	 if (CHARGE_LES_LOGS) log(pawn$"charge de melee H2H"@btire);
    if ((enemy==none) || enemy.bisdead)
    {
        ChangeEtat();
    }
    enable('enemynotvisible');
    PointDestination=vect(0,0,1000000);
    temp_float=Vsize(enemy.location - pawn.location);

        if (Vsize((enemy.location - pawn.location)*vect(1,1,0)) > (pawn.collisionradius+enemy.collisionradius +50))
        {
            PointDestination= pawn.location+(enemy.location - pawn.location)*(Temp_float-
                    (pawn.collisionradius+enemy.collisionradius))/Temp_float;
            if (!ActorReachable(enemy))
            {
					if (FindBestPathToward(enemy))
               {
                   //log(pawn$"je cherche reseau");
                   goto('GoToEnemyPosByPath');
               }
               else
               {
						 if (LookForNearestPoint() )
						 {
							   //log(pawn$"je vais au point le plus proche");
								goto('GoTONearestPoint');
						 }
						 else
						 {
	                   //log(pawn$"je suis archi crampe c'est inextricable");
							 goto('WaitHere');
						}
               }
            }
        }
DeplacementCharge:
        if (CHARGE_LES_LOGS) log(pawn$"DeplacementChargeH2H "$PointDestination!=vect(0,0,1000000));
        if (PointDestination!=vect(0,0,1000000))
        {
            //HalteAuFeu();
            bAdvancedTactics=true;
				MoveTo(PointDestination,enemy);
            bAdvancedTactics=false;
            temp_vect=enemy.location;
        }
KickH2H:
     if (CHARGE_LES_LOGS) log(pawn@"KickH2H"@btire@bfire);
	 bInWaitMode=true;
     pawn.velocity=vect(0,0,0);
     pawn.acceleration=vect(0,0,0);
	  temp_vect=enemy.location;
     fireenemy();
     sleep(1);
     if (Interrogation!=none)
     {
        Interrogation.destroy();
        Interrogation=none;
     }
	  bInWaitMode=false;
	  HalteAufeu();
     goto('charge');
GoToEnemyPosByPath:
     if (CHARGE_LES_LOGS) log(pawn$"ReseauAttaqueH2H dans $$$$$$$$$$$$$$$$$$$$$ ");
     if (Vsize(enemy.location-pawn.location)>( pawn.collisionradius+enemy.collisionradius +10))
     {
         While (movetarget!=none)
         {
				 focus=none;
				 focalpoint=(Movetarget.location-pawn.location)*10000+pawn.location;
             MoveToward(MoveTarget,none);
				 if (Vsize(Movetarget.location-pawn.location)>50)
				 {
					  log(pawn@"je suis archi crampe en H2H je fais une pause");
					  goto('WaitHere');
					  break;
				 }
				 if (actorreachable(enemy))
				 {
					PointDestination= pawn.location+(enemy.location - pawn.location)*(Temp_float-
                    (pawn.collisionradius+enemy.collisionradius +5))/Temp_float;
                goto('DeplacementCharge');
					break;
				 }
             if (!FindBestPathToward(enemy))
					break;
         }
     }
     goto('charge');
GoToNearestPoint:
	if (CHARGE_LES_LOGS) log(pawn$"GoToNearestPoint"@movetarget);
	if (btemp_bool)
  	{
		if (vsize(pawn.location-movetarget.location)>pawn.collisionradius*2)
		{
			focalpoint=10000*(movetarget.location-pawn.location) +pawn.location;
   	   MoveToward(movetarget,none);
		}
	}
	else
	{
		 for (temp_int=0;temp_int<16;temp_int++)
	    {
			 if (routecache[temp_int]==none)
				break;
			 focalpoint=10000*(routecache[temp_int].location-pawn.location) +pawn.location;
	       MoveToward(routecache[temp_int],none);
			 if (actorreachable(enemy))
			 {
					PointDestination= pawn.location+(enemy.location - pawn.location)*(Temp_float-
	                    (pawn.collisionradius+enemy.collisionradius +5))/Temp_float;
	            goto('DeplacementCharge');
					break;
			}
		 }
	}
	//log("Vsize(enemy.location-pawn.location)"@Vsize(enemy.location-pawn.location));
	if (Vsize(enemy.location-pawn.location)<150)
		goto('KickH2H');
WaitHere:
	if (CHARGE_LES_LOGS) log(pawn$"WaitHere");
   temp_vect=enemy.location;
	bInWaitMode=true;
	HalteAufeu();
	bases.PlayH2HProvoc();
	focus=enemy;
	pawn.velocity=vect(0,0,0);
	pawn.acceleration=vect(0,0,0);
	sleep(1);
	if (Vsize(enemy.location-pawn.location)<100)
	{
		bases.ReleaseAnimControl(true);
		bInWaitMode=false;
		goto('KickH2H');
	}
	sleep(1+2*frand());
	bases.ReleaseAnimControl(true);
	bInWaitMode=false;
	goto('charge');
}
// ----------------------------------------------------------------------
// Etat d'attaque         (enemy!=none)
//
//
// ----------------------------------------------------------------------
state Attaque
{
    ignores hearnoise;

    event Seeplayer(pawn other)
    {
        if (other==enemy)
        {
            Switch (iEtatVaVersStrp)
            {
                case 1: return;
                case 2: fireenemy();
                    return;
            }
        }
        setenemy(XIII);
    }
    event EnemyNotVisible()
    {
        Switch (iEtatVaVersStrp)
        {
            case 1: return;
            case 2: HalteAufeu();
                return;
        }
        if (TenteGrenadage())
        {
            if (bencouverture)
            {
                Switch(bases.skill)
                {
                    Case 1 : Angle_Visee=14; break;
                    Case 2 : Angle_Visee=12; break;
                    Case 3 : Angle_Visee=10; break;
                    Case 4 : Angle_Visee=8; break;
                    Case 5 : Angle_Visee=6; break;
                }
                pawn.shouldcrouch(false);
                bEnCouverture=false;
                GenAlerte.NbAllieEnCouverture--;
            }
            if (iEtatVaVersStrp>1)
            {
                LastStrP.Libere();
                iEtatVaVersStrp=0;
                LastStrP=none;
            }
            HalteAuFeu();
            gotostate('attaque','LanceGrenadeTarget');
            return;
        }
        else if (LigneVisee(enemy.location, LastSeeingPos))
        {
				HalteAuFeu();
            GotoState('TacticalMove','RecoverEnemy');
            return;
        }
        else
        {
				HalteAuFeu();
            gotostate('temporise');
            return;
        }
    }
    event Tick(float deltaseconds)
    {
        local int i;
        local iacontroller iacontr;
        local actor nav;
        local AttitudeInfo attitude;
        local float distanceAXIII;
        local int NBAllieEnCouverture;

        global.tick(deltaseconds);

        if ((enemy==none) || enemy.bisdead)
        {
            ChangeEtat();
            return;
        }
        if (iEtatVaVersStrp>0 || bLanceGrenade)
            return;
        if ((level.timeSeconds-Temps_Ref2)>5 && bases.order!='garder')
        {
            Attitude=AttitudeToNMI(enemy);
            if (Attitude==ATTITUDE_Fear)    //actualisation attitude
            {
                HalteAuFeu();
                gotostate('fuite');
                return;
            }
            else if (Attitude==ATTITUDE_Impressed)
            {  //retraite possible si enemmi de dos ou assez loin
                if (((enemy.location-pawn.location) dot vector(enemy.rotation))>0 || Vsize(enemy.location-pawn.location)>600)
                    CherchePointRetraite();
            }
            Temps_Ref2=level.timeseconds;
        }
        if ((Level.timeseconds-Temps_ref)>3)
        {
				Temps_Ref=Level.timeseconds;
            //recherche alarme
				//log(" cherche alarme"@!genalerte.bAllAlarmsActivated);
            if (!genalerte.bAllAlarmsActivated)    ChercheAlarme();  //ALARMEChercheAlarme();  //ALARME
            //si otage
            if (xiii.bPrisonner && XIII.LHand.pOnShoulder!=none && AllianceLevel(XIII.LHand.pOnShoulder)==1 && enemy==xiii && VSize(pawn.location-enemy.location) < 125)
            {
                if (CHARGE_LES_LOGS) log(pawn$"me colle trop je tir");
                NbCoupsRiposte=(2+bases.agressivite)*1.5;
                NbCoupsRiposte=Min(4,NbCoupsRiposte);
                NbCoupsRiposte=Max(1,NbCoupsRiposte);
            }
            if (bases.order!='garder')
                ChangetoBestWeapon();   //test nouvelle armeChangetoBestWeapon();   //test nouvelle arme

            //couverture
            //log(genalerte.SoldierInFightList.length@!pawn.weapon.bmeleeweapon@(float(GenAlerte.NBAllieEnCouverture)/GenAlerte.SoldierInFightList.length)<0.3 && vsize(pawn.location-enemy.location)>500);
            distanceAXIII=vsize(pawn.location-enemy.location);
            NBAllieEnCouverture=genalerte.NBAllieEnCouverture;
            if (bencouverture)
                NBAllieEnCouverture--;
            if (genalerte.SoldierInFightList.length>1 && (float(NBAllieEnCouverture)/GenAlerte.SoldierInFightList.length)<0.3 && distanceAXIII>500 && distanceAXIII<1.5*bases.DistanceAttaque)
            {
                if (!bEnCouverture)
					{
							//log(pawn@"passe en couverture"@Fasttrace(DirectionTir, WeaponStartTrace-vect(0,0,30)));
                    gotostate('Attaque','Couverture');
					}
            }
            else if (bEnCouverture)
            {
                Switch(bases.skill)
                {
                    Case 1 : Angle_Visee=14; break;
                    Case 2 : Angle_Visee=12; break;
                    Case 3 : Angle_Visee=10; break;
                    Case 4 : Angle_Visee=8; break;
                    Case 5 : Angle_Visee=6; break;
                }
                pawn.shouldcrouch(false);
                bEnCouverture=false;
                GenAlerte.NbAllieEnCouverture--;
                gotostate('attaque','charge');
            }
            //Attaquescriptee
            ChercheReseauAttaque();
        }
    }
    event Timer2()
    {
        if (btire)
        {
            bfire=0;
            settimer(0.5,false);
        }
    }
    event timer3()
    {
        EnemyTargetPos=enemy.location;
        EnemyTargetVelocity=enemy.velocity;
        if (bases.order=='garder')
        {
            if (ChangetoBestWeapon() && Pawn.pendingWeapon.bmeleeweapon) //test nouvelle arme et si passe aux points donc ne peut plus garder
            {
                bases.order='tenir';
                gotostate('attaqueH2H','charge');
            }
        }
    }
    event SeeDeadPawn(pawn other)
    {
        if (ChercheBonMatos(other))		//CadavreWithPickup affecte a other dans Cherchebonmatos
        {
            HalteAufeu();
            bDisableEventSeeDeadPawn=true;
            CadavreWithPickup.bDejaFouille=true;
            gotostate('tacticalmove','chercheobjet');
        }
    }
    event UpdateTactics()
    {
            VecteurRecalage=vect(0,0,0);
            VecteurRecalage= PseudoSteering();
            if (VecteurRecalage!=vect(0,0,0) || Vsize(enemy.location-temp_vect)>150)   //l'ennemi a bouge ou steering
            {
                CompteurRecalage=15;
                badvancedtactics=false;
                gotostate('attaque','charge');
            }
    }
    event Trigger(actor Other, pawn EventInstigator)
    {
        local bool bLigneVisee;
        local bool bJump;
        local int i;

        if (iEtatVaVersStrp>1)
            return;
        //log("trigger"@bases.StrategicPointAttraction);
        LastStrP=StrategicPoint(other);
        if (LastStrP!=none) // STRATEGIC POINTS
        {
            if (frand()*100<=bases.StrategicPointAttraction && Vsize(enemy.location-pawn.location)>400)
            {
                if (LastStrP.FinishJumpPoint!=none)
                {
                    bJump=true;
                }
                Movetarget=none;
                if (Fasttrace(LastStrP.location-vect(0,0,30),pawn.location-vect(0,0,30)))
                {
                    LastStrP.Occupe();
                    if (bjump)
                    {
                        LastStrP.FinishJumpPoint.occupe();
                    }
                    if (iEtatVaVersStrp==1) //va vers point interdemediaire
                    {
                        PointIntermediaire.bAlreadyTargeted=false;
                        if (cansee(enemy)) fireenemy();
                    }
                    gotostate('attaque','vaversStrP');
                }
                else if (FindBestPathToward(LastStrP))
                {
                    LastStrP.Occupe();
                    if (bjump)
                    {
                        LastStrP.FinishJumpPoint.occupe();
                    }
                    for (i=0;i<16;i++)
                    {
                        if (routecache[i]==none)
                            break;
                        PointChemin[i]=routecache[i];
                    }
                    NbPointChemin=i;
                    gotostate('attaque','vaversStrP');
                }
            }
        }
    }

    function NotifyFiring()
    {
		  if (enemy==none)
				return;
		  if (pawn.weapon.bmeleeweapon)
		  {
				gotostate('attaqueH2H');
				HalteAuFeu();
				return;
		  }
        DirectionTir=DirectionDuTir(); //recupere direction du tir avant dispersion
        CheckLineOfFire();
        if (btire)//je vais tirer
        {
            //log("pawn.weapon"@pawn.weapon.hasammo()@XIIIWeapon(pawn.weapon).reloadcount@(1.6-vsize(enemy.location-pawn.location)*0.002)>frand()@(1.6-vsize(enemy.location-pawn.location)*0.002));
            if (pawn.weapon.reloadcount==1 && pawn.weapon.default.reloadcount>1)
            {
                if (bases.order!='garder' && (1.6-vsize(enemy.location-pawn.location)*0.002)>frand())
                {
                    bFuitPourreloader=true;
                    Timer_VaRecharger=level.timeseconds;
                    CherchePointReload();
                }
            }
        }

    }
    function DamageAttitudeto(pawn Other, float Damage)
    {
        if (bases.bisdead)
            return;
        //son
        bases.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',bases.CodeMesh,bases.NumeroTimbre);

	     If (xiii.bPrisonner && XIII.LHand.pOnShoulder!=none && AllianceLevel(XIII.LHand.pOnShoulder)==1 && other==xiii)
        {
           if (CHARGE_LES_LOGS) log(pawn$"je riposte");
           NbCoupsRiposte=(2+bases.agressivite)*1.9;
           NbCoupsRiposte=Min(5,NbCoupsRiposte);
           NbCoupsRiposte=Max(1,NbCoupsRiposte);
        }
    }

    function ReceiveWarning(pawn shooter, float projspeed,vector firedir)
    {
        local float enemyDist;
        local vector X,Y,Z, enemyDir;

        // AI controlled creatures may duck if not falling
        if (bases.order=='garder' || bEnCouverture || iEtatVaVersStrp>0 || (Enemy == None)
            || (Pawn.Physics == PHYS_Falling) || (Pawn.Physics == PHYS_Swimming) )
            return;

        if (FRand() > 0.02 * skill)
            return;

        if (shooter==xiii)
        {
            if (!XIIIWeapon(shooter.weapon).AmmoType.bInstantHit)
            {
                enemyDist = VSize(shooter.Location - Pawn.Location);
                if (enemyDist/projSpeed > 0.11 + 0.15 * FRand())
                {
                    gotostate('TacticalMove','strafe');
                    return;
                }
            }
            else
					gotostate('TacticalMove','strafe');
        }
    }

    function bool SwitchSurGrenade()
    {
        if (pawn.weapon.isa('grenad'))
            return true;
        // ELR Remove Class reference
        //pawn.pendingweapon = XIIIWeapon(pawn.FindInventoryType(class'grenad'));
        Pawn.PendingWeapon = Pawn.Inventory.WeaponChange(4);
        if ( Pawn.PendingWeapon == none )
          Pawn.PendingWeapon = Pawn.Inventory.WeaponChange(20); // try Frag Grenad
        // ELR End
        if (pawn.pendingweapon==none || !pawn.pendingweapon.HasAmmo())
        {
            log(pawn$"          BEN J'AI PAS DE GRENADE  $$$$$$$");
            return false;
        }
        else
        {
            Pawn.Weapon.PutDown();
            return true;
        }
    }
    function GrenadeTarget ActiveGrenadeTarget()
    {
        local GrenadeTarget GrenT;
        local int i;

        For(i=0;i<level.game.GrenadeTargetList.Length;i++)
        {
            grent=GrenadeTarget(level.game.GrenadeTargetList[i]);
            if (GrenT.bActive)
                return GrenT;
        }
        return none;
    }
    function bool TenteGrenadage()
    {
        local GrenadeTarget GrenT;
        local inventory GRE;

        if (enemy.base==none)
            return false;
        // ELR No more cast/Class ref to grenad
//        if ( (grenad(pawn.weapon) != none) && pawn.weapon.hasammo() )
        if ( (pawn.weapon != none) && ((Pawn.Weapon.InventoryGroup == 4) || (Pawn.Weapon.InventoryGroup == 20)) && pawn.weapon.hasammo() )
        {
            GrenT=ActiveGrenadeTarget();
            if (GrenT!=none)
                if (Vsize(GrenT.location-pawn.location)<500 && Vsize(GrenT.location-pawn.location)>300 && FastTrace(GrenT.location))
                {
                    return true;
                }
                if (Vsize(enemy.location-pawn.location)<1200 && Vsize(enemy.location-pawn.location)>200 && FastTrace(enemy.location+vect(0,0,80),enemy.location) && FastTrace(enemy.location+vect(0,0,80),pawn.eyeposition()+pawn.location))
                    return true;
        }
        else
        {
            // ELR Remove Class reference
            //GRE=pawn.FindInventoryType(class'grenad');
            GRE = Pawn.Inventory.WeaponChange(4);
            if ( GRE == none )
              GRE = Pawn.Inventory.WeaponChange(20); // try Frag Grenad
            // ELR End
            if (GRE==none)
                return false;
            GrenT=ActiveGrenadeTarget();
            if (GrenT!=none)
                if (Vsize(GrenT.location-pawn.location)<500 && Vsize(GrenT.location-pawn.location)>300 && FastTrace(GrenT.location))
                {
                    return true;
                }
                //log("tente grenadage "@FastTrace(enemy.location+vect(0,0,80),enemy.location));
                if (Vsize(enemy.location-pawn.location)<1200 && Vsize(enemy.location-pawn.location)>200 && FastTrace(enemy.location+vect(0,0,80),enemy.location) && FastTrace(enemy.location+vect(0,0,80),pawn.eyeposition()+pawn.location))
                    return true;
        }
        return false;
    }

    function BeginState()
    {
        disable('enemynotvisible');
		  //log(pawn@"ajoute perso dans la liste des basesoldierinfight");
        genalerte.SoldierInFightList.length=genalerte.SoldierInFightList.length+1;
        genalerte.SoldierInFightList[genalerte.SoldierInFightList.Length-1]=bases;
        pawn.SetAnimStatus('alert');
		  EnemyTargetPos=enemy.location;
    		EnemyTargetVelocity=enemy.velocity;
        if (NiveauAlerte==0)
        {
            s_decAttente();
            s_incAttaque();
        }
        else if (NiveauAlerte==1)
        {
            s_decAlerte();
            s_incAttaque();
        }
        NiveauAlerte=2;
		  bARienVu=false;
        Temps_Ref2=level.timeseconds-2;
        Temps_Ref=Temps_Ref2;
        settimer3(Temps_RefreshEnemyPos,true);
        //***** Var temp *******
        //temp_float=0.0;
        ///temp_vect=vect(0,0,0);  //1) pour garder ancienne position ennemi dans updatetacics 2) dans saut
        //PointDestination=vect(0,0,0);
        //temp_int=0; //utilise pour boucle sur pointchemin
        LastStrP=none;

    }
    function EndState()
    {
        local int i;

       pawn.bcanjump=false;
        if (bencouverture)
        {
            Switch(bases.skill)
            {
                Case 1 : Angle_Visee=14; break;
                Case 2 : Angle_Visee=12; break;
                Case 3 : Angle_Visee=10; break;
                Case 4 : Angle_Visee=8; break;
                Case 5 : Angle_Visee=6; break;
            }
            pawn.shouldcrouch(false);
            bEnCouverture=false;
            GenAlerte.NbAllieEnCouverture--;
        }
        settimer3(0,false);
        bAdvancedTactics=false;
        bEtatAlerte=true;
        //vire soldierinfightlist
		  //log(pawn@"VIRE perso dans la liste ");
        for (i=0;i<genalerte.SoldierInFightList.Length; i++)
        {
            if (genalerte.SoldierInFightList[i] == pawn )
            {
					//log(pawn@"JE ME VIRE de la liste des basesoldierinfight");
                genalerte.SoldierInFightList.Remove(i,1);
                break;
            }
        }
        if (iEtatVaVersStrp>0)
        {
            if (iEtatVaVersStrp==1)
            {
                PointIntermediaire.bAlreadyTargeted=false;
                PointIntermediaire=none;
            }
            else
            {
                LastStrP.Libere();
                if (LastStrP.bAccroupi)
                    pawn.shouldcrouch(false);
                LastStrP=none;
            }
            iEtatVaVersStrp=0;
            LastStrP=none;
        }

    }

initattaque:
    pawn.velocity=vect(0,0,0);
    pawn.acceleration=vect(0,0,0);
    if ((enemy==none) || enemy.bisdead)
    {
        ChangeEtat();
    }
    focus=enemy;
    finishrotation();
 	 if (!pawn.weapon.bmeleeweapon)
			ChercheReseauAttaque();     //peut passer dans attaque scriptee

    if (AttitudeToNMI(enemy)==ATTITUDE_FEAR)
    {
        HalteAufeu();
        gotostate('fuite');
    }
    if (bases.bAlerteAmisEnCriant)
    {
        sleep(0.5*frand());
        Interrogation=Spawn(class'XIIIalerteEmitter',self,,pawn.location+vect(0,0,70));
        interrogation.setbase(pawn);
        //son
        //pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJAlert',bases.CodeMesh,bases.NumeroTimbre);
        genalerte.PoteBeugle(pawn);
    }
begin:
	 if (pawn.weapon.bmeleeweapon)
	 {
		gotostate('attaqueH2H');
	 }
    if (CHARGE_LES_LOGS) log(pawn@"Etat attaque    "$enemy);
    if (enemy==none)
    {
        log(pawn@"ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none **");
        //enemy=xiii;
    }
    temp_vect=enemy.location;
    focus=enemy;
    FireEnemy();
    if (bases.order=='garder')
    {
       enable('enemynotvisible');
       stop;
    }
charge:
    if ((enemy==none) || enemy.bisdead)
    {
        ChangeEtat();
    }
    enable('enemynotvisible');
    //log("est-ce que ca necessite que je bouge???"@CompteurRecalage@CompteurRecalage + Vsize(enemy.location-temp_vect)*(1.0/80.0)> 8-3*bases.agressivite);
    if ((CompteurRecalage + Vsize(enemy.location-temp_vect)*(1.0/80.0)> 8-3*bases.agressivite))
    {
        PointDestination=vect(0,0,1000000);
        temp_float=Vsize(enemy.location - pawn.location);
            PointDestination= pawn.location +VecteurRecalage+(enemy.location-pawn.location)*(Temp_float-bases.DistanceAttaque)/Temp_float;
            if (Vsize(PointDestination-pawn.location)<50 || !FastTrace(PointDestination-vect(0,0,30),pawn.location-vect(0,0,30)) || !LigneVisee(enemy.location,PointDestination))
            {
                CompteurRecalage--;
                //log(pawn@" DEBUG"@"je ne bouge pas en fait");
                PointDestination=vect(0,0,1000000);  //alors bouge pa
                Movetarget=none;
                if (vsize(enemy.location-pawn.location)>bases.DistanceAttaque*1.2 && FindBestPathToward(enemy))
                {
                    for (temp_int=0;temp_int<16;temp_int++)
                    {
                        if (routecache[temp_int]==none)
                            break;
                        PointChemin[temp_int]=routecache[temp_int];
                    };
							if (temp_int==1)
								NbPointChemin=1;
							else
						  		NbPointChemin=(Temp_int/2);
                    Pointintermediaire=navigationpoint(RouteCache[NbPointChemin-1]);
							if (!Pointintermediaire.bAlreadyTargeted && vsize(Pointintermediaire.location-enemy.location)>80)
                    {
								//log(pawn@"poinnnnnnnnnnnnnt intermediaire pas targete"@temp_int@NbPointChemin@RouteCache[NbPointChemin-1]@Pointintermediaire);
                        movetarget=Pointintermediaire;
                        HalteAufeu();
                        Pointintermediaire.bAlreadyTargeted=true;
                        gotostate('attaque','VaVersPointIntermediaire');
                    }
                    else if (RouteCache[NbPointChemin]!=none)
                    {
                        Pointintermediaire=navigationpoint(RouteCache[NbPointChemin]);
								//log(pawn@"poinnnnnnnnnnnnnt intermediaire deja targete"@temp_int@NbPointChemin@RouteCache[NbPointChemin-1]@Pointintermediaire);
                        if (!Pointintermediaire.bAlreadyTargeted && vsize(Pointintermediaire.location-enemy.location)>80)
                        {
                            movetarget=Pointintermediaire;
                            HalteAufeu();
                            Pointintermediaire.bAlreadyTargeted=true;
                            NbPointChemin++;
                            gotostate('attaque','VaVersPointIntermediaire');
                        }
                    }
                }
            }
DeplacementCharge:
        //log(pawn$"DeplacementCharge "$PointDestination!=vect(0,0,1000000)$Vsize(PointDestination-pawn.location)>150$FastTrace(PointDestination,pawn.location+pawn.eyeposition()));
        if (PointDestination!=vect(0,0,1000000))
        {
            if (LastStrP!=none)
            {
                LastStrP.Libere();
                iEtatVaVersStrp=0;
                LastStrP=none;
            }
            bAdvancedTactics=true;
            if ((enemy.location-pawn.location) dot (pointdestination-pawn.location)<0)  //c'est que je recule
            {
                MoveTo(PointDestination,enemy,bases.walkingspeed);
            }
            else
            {
                MoveTo(PointDestination,enemy);
            }
            bAdvancedTactics=false;
            CompteurRecalage=0;
            temp_vect=enemy.location;
        }
     }
ContinueFight:
     if (CHARGE_LES_LOGS) log(pawn@"ContinueFight");

     pawn.velocity=vect(0,0,0);
     pawn.acceleration=vect(0,0,0);
     CompteurRecalage++;
     sleep(1);
     goto('charge');
Couverture:
     bEnCouverture=true;
     GenAlerte.NbAllieEnCouverture++;
     pawn.velocity=vect(0,0,0);
     pawn.acceleration=vect(0,0,0);
     pawn.shouldcrouch(true);
     fireenemy();
     Angle_Visee-=2;
     sleep(2+6*(1-(abs(bases.distanceattaque-vsize(pawn.location-enemy.location))/(bases.distanceattaque))));
     Switch(bases.skill)
     {
         Case 1 : Angle_Visee=14; break;
         Case 2 : Angle_Visee=12; break;
         Case 3 : Angle_Visee=10; break;
         Case 4 : Angle_Visee=8; break;
         Case 5 : Angle_Visee=6; break;
     }
     pawn.shouldcrouch(false);
     bEnCouverture=false;
     GenAlerte.NbAllieEnCouverture--;
     goto('charge');
VaVersPointIntermediaire:
     iEtatVaVersStrp=1;
     HalteAuFeu();
     for (iCompteur=0;iCompteur<NbPointChemin;iCompteur++)
     {
         focalpoint=1000*(PointChemin[iCompteur].location-pawn.location)+pawn.location;
         focus=none;  //focus=none;
         MoveToward(PointChemin[iCompteur],none);
     }
     PointIntermediaire.bAlreadyTargeted=false;
     If (cansee(enemy))
         fireenemy();
     iEtatVaVersStrp=0;
     //log("fin vavers sTrp");
     goto('charge');
VaVersStrP:
     iEtatVaVersStrp=2;
     HalteAuFeu();
     if (movetarget==none)
     {
         focalpoint=1000*(LastStrp.location-pawn.location)+pawn.location;
         focus=none;
         MoveToward(LastStrp,none);
         focus=enemy;
    }
     else
     {
         for (iCompteur=0;iCompteur<NbPointChemin-1;iCompteur++)
         {
             focalpoint=1000*(PointChemin[iCompteur].location-pawn.location)+pawn.location;
             focus=none;
             MoveToward(PointChemin[iCompteur],none);
         }
         MoveToward(LastStrp,enemy); //va vers point en regardant enemy
     }
     if (LastStrP.FinishJumpPoint!=none)
         goto('SauteSurStrP');
     if (LastStrP.bAccroupi)
         pawn.shouldcrouch(true);
     iEtatVaVersStrp=3;
     sleep(2+4*frand());
     if (LastStrP.bAccroupi)
         pawn.shouldcrouch(false);
     iEtatVaVersStrp=0;
     If (cansee(enemy))
         fireenemy();
     //log("fin vavers sTrp");
     goto('charge');
SauteSurStrP:
     //pawn.velocity=vect(0,0,0);
     //pawn.acceleration=vect(0,0,0);
     //sleep(0.5);
     disable('enemynotvisible');
     focalpoint=1000*(LastStrP.FinishJumpPoint.location-LastStrP.location) + pawn.location;
     focus=none;
     pawn.bcanjump=true;
     finishrotation();
     temp_float=sqrt(2*948*(LastStrP.jumpHeight));     //Vz0
     PointDestination=LastStrP.FinishJumpPoint.location-LastStrP.location;
     if (abs(PointDestination.z)<0.1)
         pawn.velocity=vect(1,1,0)*PointDestination*948/(2*temp_float);
     else
         pawn.velocity=vect(1,1,0)*PointDestination*(temp_float/(2*PointDestination.z))*(1-sqrt(1-(2*PointDestination.z*948/(temp_float*temp_float))));
     pawn.jumpz=temp_float;
     pawn.acceleration=vect(0,0,0);
     pawn.Dojump(true);
     pawn.jumpz=420;
     if (LastStrP.FinishJumpPoint.bAccroupi)
         pawn.shouldcrouch(true);
     waitforlanding();
     enable('enemynotvisible');
     pawn.bcanjump=false;
     if (CHARGE_LES_LOGS) log(pawn$"fini saut sur STRP");
     sleep(1+4*frand());
     if (LastStrP.FinishJumpPoint.bAccroupi)
         pawn.shouldcrouch(false);
     iEtatVaVersStrp=0;
     goto('charge');

LanceGrenadeTarget:
     bLanceGrenade=true;
     focus=enemy;
     disable('EnemyNotVisible');
     disable('seeplayer');
     disable('seemonster');
     if (!SwitchSurGrenade())
         gotostate('temporise');
     if (!bases.bDontCallFriends) pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJGrenade',bases.CodeMesh,bases.NumeroTimbre);
	  sleep(1.2);
WaitGrenadReady:
	  sleep(0.2);
	  if (!pawn.weapon.isa('grenad') || pawn.weapon.isinstate('active'))
			goto('WaitGrenadReady');
     Fireenemy();
     sleep(1);
     ChangetoBestWeapon();
     sleep(0.5);
     bLanceGrenade=false;
     goto('charge');

}

// ----------------------------------------------------------------------
//
// TacticalMove        (enemy!=none)
//
// ----------------------------------------------------------------------
state TacticalMove
{
    ignores enemynotvisible,hearnoise;
    event Seeplayer(pawn other)
    {
			if (enemy!=none && enemy==other)
            	SeeEnemy();
    }
    event SeeMonster(pawn other)
    {
        if (enemy!=none && enemy==other)
            	SeeEnemy();
    }
    event Tick(float deltaseconds)
    {
        local int i;
        global.tick(deltaseconds);

        if (enemy==none || enemy.bisdead)
        {
            ChangeEtat();
            return;
        }
        if ((Level.timeseconds-Temps_ref)>3)
        {
            //si otage
            if (XIII.bPrisonner && XIII.LHand.pOnShoulder!=none && AllianceLevel(XIII.LHand.pOnShoulder)==1 && enemy==xiii && VSize(pawn.location-enemy.location) < 250)
            {
                if (CHARGE_LES_LOGS) log(pawn$"me colle trop je tir");
                NbCoupsRiposte=(2+bases.agressivite)*1.5;
                NbCoupsRiposte=Min(4,NbCoupsRiposte);
                NbCoupsRiposte=Max(1,NbCoupsRiposte);
            }
            Temps_Ref=Level.timeseconds;
        }
    }
    event Timer2()
    {
        if (btire)
        {
            bfire=0;
            settimer(0.6,false);
        }
    }
    event Timer3()
    {
        EnemyTargetPos=enemy.location;
        EnemyTargetVelocity=enemy.velocity;
    }
    event Trigger(actor Other, pawn EventInstigator)
    {
    }
    event SeeDeadPawn(pawn other)
    {
		 if (ChercheBonMatos(other))		//CadavreWithPickup affecte a other dans Cherchebonmatos
        {
                    HalteAufeu();
            bDisableEventSeeDeadPawn=true;
            CadavreWithPickup.bDejaFouille=true;
            gotostate('tacticalmove','chercheobjet');
        }
    }
    event EnemyNotVisible()
    {
        if (LigneVisee(enemy.location, LastSeeingPos))
        {
            GotoState('TacticalMove','RecoverEnemy');
            return;
        }
        else
        {
            gotostate('temporise');
            return;
        }
    }
    function NotifyFiring()
    {
		  if (enemy==none)
				return;
        DirectionTir=DirectionDuTir(); //recupere direction du tir avant dispersion
        //decalage par rapport a l'arme
        CheckLineOfFire();
    }
    function DamageAttitudeto(pawn Other, float Damage)
    {
        //son
        bases.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',bases.CodeMesh,bases.NumeroTimbre);

        if (bDisableDamageattitudeto)
            return;
        If (xiii.bPrisonner && XIII.LHand.pOnShoulder!=none && AllianceLevel(XIII.LHand.pOnShoulder)==1 && other==xiii)
        {
            if (CHARGE_LES_LOGS) log(pawn$"je riposte");
            NbCoupsRiposte=(2+bases.agressivite)*1.9;
            NbCoupsRiposte=Min(5,NbCoupsRiposte);
            NbCoupsRiposte=Max(1,NbCoupsRiposte);
        }
    }
    function bool StrafeDestination()  //test both right and left
    {
        local vector pick, pickdir;
        local bool success;
        local float MoveDist;

        pickdir=(Enemy.location-pawn.location) cross vect(0,0,1);
        pickdir.Z = 0;
        pickdir=normal(pickdir);
        if (Frand()>0.5)
            pickdir *= -1;

        MoveDist = 150+50* FRand();
        success = TestDirection(100,MoveDist,pickdir, pick);
        if (!success)
        {
            MoveDist = 270;
            success = TestDirection(100,MoveDist,-1*pickdir, pick);
            if (!success)
                return false;
        }
        Destination = pick;
        return success;
    }

    function bool TestDirectionAvoidingAlly(vector pickdir, out vector pick,basesoldier PoteAEviter)
    {
        local float MoveDist;

        if (Vsize(PoteAEviter.location - pawn.location)>160)
            pickdir += 0.99*normal(Enemy.location-pawn.location); // pour partir a 45 degres si charge
        else
            pickdir +=0.3*normal(Enemy.location-pawn.location); // pour partir a 80 degres si charge

        MoveDist=200;
        return TestDirection(110,MoveDist,pickdir, pick);
    }
    function bool TestPasSurLaGauche(basesoldier PoteAEviter)
    {
        local vector pick, pickdir;

        pickdir=(Enemy.location-pawn.location) cross vect(0,0,1);
        pickdir.Z = 0;
        pickdir=normal(pickdir);

        if (TestDirectionAvoidingAlly(pickdir, pick,PoteAEviter))
        {
            Destination = pick;
            return true;
        }
        return false;
    }

    function bool TestPasSurLaDroite(basesoldier PoteAEviter)
    {
        local vector pick, pickdir;


        pickdir=(Enemy.location-pawn.location) cross vect(0,0,-1);
        pickdir.Z = 0;
        pickdir=normal(pickdir);

        if (TestDirectionAvoidingAlly(pickdir, pick,PoteAEviter))
        {
            Destination = pick;
            return true;
        }
        return false;
    }
    function BeginState()
    {
        if (CHARGE_LES_LOGS) log(pawn@"Tactical Move");
        if (NiveauAlerte==0)
        {
            s_decAttente();
            s_incAttaque();
        }
        else if (NiveauAlerte==1)
        {
            s_decAlerte();
            s_incAttaque();
        }
        NiveauAlerte=2;
        bDisableDamageattitudeto=false;
        Temps_Ref=Level.timeseconds-2;
        settimer3(Temps_RefreshEnemyPos,true);
    }

    function EndState()
    {
        Settimer2(0,false);
        settimer3(0,false);
    }

begin:
    if (enemy==none)
    {
        log(pawn@"ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none **");
        //enemy=xiii;
    }
    if ((enemy==none) || enemy.bisdead)
        ChangeEtat();
Strafe:
    if (CHARGE_LES_LOGS) log(pawn@"Tactical Move STRAFE");
    If (StrafeDestination())
    {
        HalteAuFeu();
        MoveTo(Destination,enemy,VitesseDeplacements);
    }
    gotostate('attaque');
PositionTirSurGauche:
    if (CHARGE_LES_LOGS) log(pawn$"Pas sur la gauche");
    CompteurRecalage=15;
    If (pote!=none && !pote.bisdead && TestPasSurLaGauche(pote))
    {
        MoveTo(Destination,enemy,VitesseDeplacements);
    }
    else
    {
        focus=enemy;
        sleep(2);

    }
    gotostate('attaque');
PositionTirSurDroite:
    if (CHARGE_LES_LOGS) log(pawn$"Pas sur la droite");
    CompteurRecalage=15;
    If (pote!=none && !pote.bisdead && TestPasSurLaDroite(pote))
    {
        MoveTo(Destination,enemy,VitesseDeplacements);
    }
    else
    {
        focus=enemy;
        sleep(2);
    }
    gotostate('attaque');
ChercheObjet_ContourneObstacle:
    MoveTo(destination,none,1.0);
ChercheObjet:
    if (CadavreWithPickup==none || CadavreWithPickup.weapon==none) //blindage
        gotostate('attaque');
    if (CHARGE_LES_LOGS) log(pawn@"Tactical Move CHERCHE OBJET");
    settimer2(0,false);
    bDisableDamageattitudeto=true;
    focus=none;
    focalpoint=CadavreWithPickup.location;
    MoveTo(CadavreWithPickup.location,none);
    pawn.acceleration=vect(0,0,0);
    pawn.velocity=vect(0,0,0);
	 sleep(0.2);
    bases.PlaySearchGround();
    sleep(0.8); //temps attente accroupi
    bases.ReleaseAnimControl();
	 if (CadavreWithPickup==none || CadavreWithPickup.weapon==none || !CadavreWithPickup.weapon.hasammo())
    		gotostate('attaque');
    PlaySound(class<WeaponPickup>(CadavreWithPickup.weapon.pickupclass).Default.PickupSound);
	 CadavreWithPickup.weapon.DetachFromPawn(CadavreWithPickup);
	 WeaponOnGround=CadavreWithPickup.weapon;
	 if (CadavreWithPickup.Shadow != none )
    {
      CadavreWithPickup.Shadow.bShadowIsStatic = false;
      CadavreWithPickup.SetTimer2(0.2, false);
    }
	 WeaponOnGround.Transfer(pawn);
    focus=enemy;
    ChangetoBestWeapon();
    sleep(1.2);
    bDisableEventSeeDeadPawn=false;
    gotostate('attaque');
RecoverEnemy:
    if (CHARGE_LES_LOGS) log(pawn$"recover enemy");
    if ((enemy==none) || enemy.bisdead)
    {
        changeEtat();
    }
    HidingSpot = Pawn.Location;
    Destination = LastSeeingPos + 1 * Pawn.CollisionRadius * Normal(LastSeeingPos -Pawn.Location);
    MoveTo(Destination, Enemy,1.0);
    if (!Pawn.Weapon.bMeleeWeapon && LigneVisee(Enemy.location,pawn.location) && (vsize(enemy.location-pawn.location)<(bases.DistanceAttaque-200)))
    {
        focus=enemy;
        FireEnemy();
        pawn.velocity=vect(0,0,0);
        Pawn.Acceleration = vect(0,0,0);
        if (Frand()<0.2)
            Sleep(Fmax(4.0,XIIIWeapon(pawn.weapon).shottime*(2.25+Rand(2))));
        else
            Sleep(Fmax(4.0,XIIIWeapon(pawn.weapon).shottime*1.25));
        if (FRand() > (1+bases.agressivite-0.1)*0.5 && Vsize(HidingSpot-pawn.location)<300)
        {
            Destination = HidingSpot + 2*Pawn.CollisionRadius * Normal(HidingSpot - Pawn.Location);
            HalteAuFeu();
            MoveTo(Destination,enemy,VitesseDeplacements);
        }
    }
    if ((Enemy != None) && !LigneVisee(Enemy.location,pawn.location) && FastTrace(Enemy.Location, LastSeeingPos) )
    {
        sleep(1+1.5*Frand());
        goto('recoverenemy');
    }
    else
    {
        gotostate('attaque');
    }
}

// ----------------------------------------------------------------------
//  Chasse         (enemy!=none)
//
//
// ----------------------------------------------------------------------
state Chasse
{
    ignores EnemyNotVisible,hearnoise;

    event Seeplayer(pawn other)
    {
        if (enemy!=none && enemy==other)
            	SeeEnemy();
    }
    event SeeMonster(pawn other)
    {
        if (enemy!=none && enemy==other)
            	SeeEnemy();
    }
    event SeeDeadPawn(pawn other)
    {
		  if (ChercheBonMatos(other))		//CadavreWithPickup affecte a other dans Cherchebonmatos
        {
            HalteAufeu();
            bDisableEventSeeDeadPawn=true;
            CadavreWithPickup.bDejaFouille=true;
            gotostate('tacticalmove','chercheobjet');
        }
    }
    event Trigger(actor Other, pawn EventInstigator)
    {
    }
    event EnemyAcquired()
    {
        //if (NewEnemy==XIII) TriggerEvent('XIIIVu', Self, pawn);  //trigger vu
        focus=enemy;
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

        // If no enemy, or I should see him but don't, then give up
        if ((Level.TimeSeconds-LastSeenTime)>20)
		  {
				if (CHARGE_LES_LOGS) log(pawn@"plus de 20 s de recheche je repasse en patrouille");
            Enemy = None;
		  }
        if (Enemy == None || enemy.bisdead)
        {
            ChangeEtat();
            return;
        }
        if (ActorReachable(Enemy))
        {
            if ( (numHuntPaths < 8) || (Level.TimeSeconds - LastSeenTime < 15)
                || ((Normal(Enemy.Location - Pawn.Location) Dot vector(Pawn.Rotation)) > -0.5) )
            {
                Destination = Enemy.Location;
                MoveTarget = None;
                numHuntPaths++;
            }
            else
            {
                ChangeEtat();
            }
            return;
        }
        numHuntPaths++;

        ViewSpot = Pawn.Location + Pawn.eyeposition();
        bCanSeeLastSeen = false;
        //[***] probleme de chasse sur etage different
        bCanSeeLastSeen=(FastTrace(LastSeenPos, ViewSpot) && (abs(Lastseenpos.z-viewspot.z)<400));

        MoveTarget = None;
        if (FindBestPathToward(Enemy))
        {
            if (CHARGE_LES_LOGS) log(pawn@"trouvereseau de chasse"@movetarget@enemy);
            return;
        }
        if (NumHuntPaths > 10)
        {
				if (CHARGE_LES_LOGS) log(pawn@"plus de 10 points de chasse je repasse en patrouille");
            ChangeEtat();
            return;
        }
        if (!bTemp_bool)
        {
            Destination = LastSeeingPos;
            bTemp_bool=true;
            if (FastTrace(Enemy.Location, LastSeeingPos))//essaye derniere position vu
                return;
        }
        posZ = LastSeenPos.Z + Pawn.CollisionHeight - Enemy.CollisionHeight;
        nextSpot = LastSeenPos - Normal(Enemy.Velocity) * Pawn.CollisionRadius;
        nextSpot.Z = posZ;
        hitactor=Trace(HitLocation, HitNormal, nextSpot, ViewSpot, false);
        if ((( HitActor==none ) || (XIIIporte(hitactor)!=none)) && (abs(nextspot.z - viewspot.z) < 400))
        {
            Destination = nextSpot;
        }
        else if (bCanSeeLastSeen)
		  {
            Destination = LastSeenPos;
		  }
        else
        {
            Destination = LastSeenPos;
            if (!FastTrace(LastSeenPos, ViewSpot))
            {
                // check if could adjust and see it
                if (PickWallAdjust(Normal(LastSeenPos - ViewSpot)) || FindViewSpot())
                {
                    GotoState('chasse', 'AdjustFromWall');
                    return;
                }
                /*else if ((VSize(Enemy.Location - Pawn.Location) < 1200  || abs(Lastseenpos.z-viewspot.z) > 400))
                {
                log("llllllllllllllllllllllllllllllllllll");
                GotoState('temporise');
                return;
            }    */
                else
                {
                    if (CHARGE_LES_LOGS) log (pawn@"je n'arrive pas à le chopper je vais me planquer ou repasser en patrouille");
                    if (!cherchePointPourCamper())
						  {
								gotostate('chasse','WaitToSeenIt');
						  }
						  return;
                 }
            }
        }
        LastSeenPos = Enemy.Location;
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

        if ( FastTrace(Enemy.Location, Pawn.Location + 2 * Y * Pawn.CollisionRadius) )
        {
            Destination = Pawn.Location + 2.5 * Y * Pawn.CollisionRadius;
            return true;
        }
        if ( FastTrace(Enemy.Location, Pawn.Location - 2 * Y * Pawn.CollisionRadius) )
        {
            Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
            return true;
        }
        return false;
    }

    function BeginState()
    {
        if (NiveauAlerte==0)
        {
            s_decAttente();
            s_incAttaque();
        }
        else if (NiveauAlerte==1)
        {
            s_decAlerte();
            s_incAttaque();
        }
        NiveauAlerte=2;
        //bTemp_bool=false; pas utilise
        if (CHARGE_LES_LOGS) log(pawn@"ETAT  hunting");
    }
    function EndState()
    {
    }

AdjustFromWall:
    if (CHARGE_LES_LOGS) log(pawn@"adjustfromwall");
    MoveTo(Destination, MoveTarget);
    Goto('suivre');

Begin:
    if (enemy==none)
    {
        log(pawn@"ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none **");
        //enemy=xiii;
    }
    numHuntPaths = 0;
suivre:
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
WaitToSeenIt:
	focus=xiii;
	sleep(4+2*frand());
	Changeetat();
}

// ----------------------------------------------------------------------
//Etat temporise        (enemy!=none)
//
//  si l'ennemi s'est planque je vais essayer d'attendre pour le shooter
// ----------------------------------------------------------------------
state temporise
{
    ignores EnemyNotVisible,hearnoise;

    event Seeplayer(pawn other)
    {
        if (enemy!=none && enemy==other)
            	SeeEnemy();
    }
    event SeeMonster(pawn other)
    {
        if (enemy!=none && enemy==other)
            	SeeEnemy();
    }
    event SeeDeadPawn(pawn other)
    {
		  if (ChercheBonMatos(other))		//CadavreWithPickup affecte a other dans Cherchebonmatos
        {
            HalteAufeu();
            bDisableEventSeeDeadPawn=true;
            CadavreWithPickup.bDejaFouille=true;
            gotostate('tacticalmove','chercheobjet');
        }
    }
    event Trigger(actor Other, pawn EventInstigator)
    {
    }
    event EnemyAcquired()
    {
        gotostate('attaque');
    }
    function bool ContinueStakeOut()
    {
        local float relstr;

        relstr = RelativeStrength(Enemy);
        if ((VSize(Enemy.Location - Pawn.Location) > 450+150*(3+fclamp((relstr-3*bases.agressivite) +frand(),-3,5)))
            || (Level.TimeSeconds - LastSeenTime > 2.5 + FMax(-1.5,0.5+1.5*(FRand()+(relstr-bases.agressivite)))) || (!LigneVisee(LastSeenPos,pawn.location)))
            return false;
        else if (CanStakeOut())
            return true;
        else
            return false;
    }
    function bool CanStakeOut() // CanStakeout : teste si Pawn ET ENEMMI peuvent voir LastSeenPos
    {
        if ( VSize(Enemy.Location - LastSeenPos) > 800 )
            return false;
        return ( FastTrace(LastSeenPos, Pawn.Location + Pawn.Eyeposition())
            && FastTrace(LastSeenPos , Enemy.Location + enemy.Eyeposition()));
    }

    function BeginState()
    {
         if (enemy==none || enemy.bisdead)
			{
 				return;
			}
        if (NiveauAlerte==0)
        {
            s_decAttente();
            s_incAttaque();
        }
        else if (NiveauAlerte==1)
        {
            s_decAlerte();
            s_incAttaque();
        }
        NiveauAlerte=2;
        //Var Temp
        btemp_bool = LigneVisee(LastSeenPos,pawn.location);
        if (!btemp_bool || ((Level.TimeSeconds - LastSeenTime > 6) && (FRand() < 0.5)) )
            FindNewStakeOutDir();
    }
    function EndState()
    {
    }
recalporte:
    if (CHARGE_LES_LOGS) log(pawn$"TEMPORISE recalporte");
    MoveTo(LastSeenPos,none);
Begin:
    if (CHARGE_LES_LOGS) log(pawn@"ETAT  temporise");
    if (enemy==none)
    {
        log(pawn@"ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none **");
        //enemy=xiii;
    }
    pawn.velocity=vect(0,0,0);
    Pawn.Acceleration = vect(0,0,0);
    HalteAuFeu();
Campe:
    if (enemy==none || enemy.bisdead)
    {
        ChangeEtat();
    }
    // Recharge arme auto
    if (XIIIWeapon(pawn.weapon).default.reloadcount!=0 && float(XIIIWeapon(pawn.weapon).reloadcount)/float(XIIIWeapon(pawn.weapon).default.reloadcount)<0.15 && pawn.weapon.HasAmmo())
    {
        pawn.weapon.GotoState('Reloading');
    }
    Focus = None;
    FocalPoint = LastSeenPos;
    FinishRotation();
    if (bases.order=='garder')
    {
        sleep(6);
        changeetat();
    }
    if (ContinueStakeOut())
    {
        Sleep(1+FRand());
        if ((FRand() < 0.3) || !FastTrace(LastSeenPos+vect(0,0,0.9)*Enemy.CollisionHeight, Pawn.Location + vect(0,0,0.8) * Pawn.CollisionHeight))
            FindNewStakeOutDir();
        Goto('campe');
    }
    else
    {
        GotoState('chasse');
    }
}


// ----------------------------------------------------------------------
// Fuite             (enemy!=none)
//
//
// ----------------------------------------------------------------------
state Fuite
{
    ignores seeplayer,seemonster,hearnoise;
    event SeeDeadPawn(pawn other)
    {
    	  if (ChercheBonMatos(other))		//CadavreWithPickup affecte a other dans Cherchebonmatos
        {
            HalteAufeu();
            bDisableEventSeeDeadPawn=true;
            CadavreWithPickup.bDejaFouille=true;
            gotostate('tacticalmove','chercheobjet');
        }
    }
    event timer2()
    {
        //actualisation attitude
        if (AttitudeToNMI(enemy)>ATTITUDE_FEAR)
        {
            gotostate('attaque');
            return;
        }
        if (ChangeToBestWeapon())
        {
            gotostate('attaque');
        }
    }
    event Trigger(actor Other, pawn EventInstigator)
    {
    }
    function PickDestination()
    {
        local vector pick, pickdir;
        local bool success;
        local float MoveDist;

        pickdir = pawn.location-enemy.location;
        if (Pawn.Physics != PHYS_Walking)
        {
            pickdir.Z = 2 * FRand() - 1;
        }
        else
        {
            pickdir.Z = 0;
        }
        pickdir = Normal(pickdir);

        //chtite combi aleatoire pour fuire dans un cone de 45 deg
        Temp_vect= pickdir cross (vect(0,0,1)); //normale au vecteur direction
        if (Frand() < 0.5)
            pickdir += FRand()*Temp_Vect;
        else
            pickdir -= FRand()*Temp_Vect;
        pickdir = Normal(pickdir);
        MoveDist = 150+DistanceDeplacement*(0.4+0.6*Frand());
        success = TestDirection(150,MoveDist,pickdir, pick);
        if (!success)
        {
            temp_vect=(enemy.location-pawn.location) ;
            pickdir = temp_vect cross (vect(0,0,1));
            if (((vector(pawn.rotation) dot pickdir)*(vector(pawn.rotation) dot temp_vect) < 0) && Frand() > 0.2)
                pickdir *=-1;
            pickdir = Normal(pickdir);
            //chtite combi aleatoire pour fuire dans un cone de 45 deg
            Temp_vect= pickdir cross (vect(0,0,1)); //normale au vecteur direction
            if (Frand() < 0.5)
                pickdir += FRand()*Temp_Vect;
            else
                pickdir -= FRand()*Temp_Vect;
            pickdir = Normal(pickdir);
            MoveDist = 150+DistanceDeplacement*(0.4+0.6*Frand());
            success = TestDirection(150,MoveDist,pickdir, pick);

        }
        if (success)
        {
            DistNearWall=min(200,DistNearWall+5);
            DistanceDeplacement=min(600,DistanceDeplacement+45);
            Destination = pick;
        }
        else
        {
            DistNearWall=fmax(4*pawn.collisionradius,DistNearWall-40);
            DistanceDeplacement=max(10,DistanceDeplacement-35);
            GotoState('Fuite', 'Bloque');
        }
    }
    event Timer() //appelee une fois dans beginstate
    {
        if (!bTemp_bool)
        {
            CherchePointSafe();
        }
    }
    event enemynotvisible()
    {
        Temps_Ref = level.timeseconds;
        gotostate('fuite','pausing');
    }

    function BeginState()
    {
        if (NiveauAlerte==0)
        {
            s_decAttente();
            s_incAlerte();
        }
        else if (NiveauAlerte==2)
        {
            s_incAlerte();
            s_decAttaque();
        }
        NiveauAlerte=1;
        Temps_Ref = level.timeseconds;
        MinHitWall += 0.15;
        timer();
        settimer2(5,true);
        //Var Temp
        btemp_bool=false; //utilise pour detection safepoint
    }

    function EndState()
    {
        MinHitWall -= 0.15;
        settimer2(0,false);
    }

Begin:
    if (CHARGE_LES_LOGS) log(pawn$"ETAT Fuite."@"enemy"$enemy);
    if (enemy==none)
    {
        log(pawn@"ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none **");
        //enemy=xiii;
    }
    setTimer(3,true);
Fuite:
    if (enemy==none || enemy.bisdead)
        ChangeEtat();
    enable('enemynotvisible');
    PickDestination();
Moving:
    focalpoint=destination*vect(100,100,0);
    focus=none;
    MoveTo(Destination,None,1.0);
    if (NearWall(DistNearWall))
    {
        DistanceDeplacement=max(10,DistanceDeplacement-10);
        DistNearWall=fmax(2*pawn.collisionradius,DistNearWall-5);
        FinishRotation();
    }
    goto('fuite');
Pausing:
    disable('enemynotvisible');
    pawn.velocity=vect(0,0,0);
    Pawn.Acceleration = vect(0,0,0);
    Sleep(1.0);
    if (enemy.controller.cansee(pawn))
    {
        if ((level.timeseconds - Temps_Ref) > 0.8)
        {
            Temps_Ref = level.timeseconds;
            goto ('fuite');
        }
    }
    else if ((level.timeseconds - Temps_Ref) >6)
        ChangeEtat();
    goto('pausing');
Bloque:
    pawn.velocity=vect(0,0,0);
    Pawn.Acceleration = vect(0,0,0);
    if (VSize(pawn.location-enemy.location) < 300)
    {
        Temps_Ref = level.timeseconds;
        gotostate('attaque');
    }
    Focus = None;
    FocalPoint = Location + 20 * VRand();
    FinishRotation();
    Goto('fuite');
}
// ----------------------------------------------------------------------
// Fuite grenade
//
// Fuit qu'une grenade a la fois et refuis la plus proche quand l'autre a pete
//
// ----------------------------------------------------------------------
state FuiteGrenade
{
    ignores hearnoise;

	 Function CheckNearestGrenad()
	 {
		local int i;

		for (i=0; i<genalerte.GrenadeList.length; i++)
		{
			if (genalerte.GrenadeList[i]==none || genalerte.GrenadeList[i].bdeleteme)
				continue;
			if (Vsize(genalerte.GrenadeList[i].location-pawn.location)<1200 && Fasttrace(genalerte.GrenadeList[i].location,pawn.location))
			{
				grenade=genalerte.GrenadeList[i];
				CherchePlanqueGrenade();
				//log("une grenade est tojuourts mecnacnate je recherche safepoint");
				return;
			}
		}
	}
	 event EnemyNotVisible()
    {
        enable('seemonster');
        enable('seeplayer');
        disable('enemynotvisible');
        halteaufeu();
    }
    event Seeplayer(pawn other)
    {
        if (enemy==other &&  bTemp_bool)
        {
            fireenemy();
            disable('seemonster');
            disable('seeplayer');
            enable('enemynotvisible');
        }
		  else
		  	  SetEnemy(other);
    }
    event SeeMonster(pawn other)
    {
       if (enemy==other &&  bTemp_bool)
       {
            fireenemy();
            disable('seemonster');
            disable('seeplayer');
            enable('enemynotvisible');
       }
		 else
		  	SetEnemy(other);
    }
    event EnemyAcquired()
    {
       Interrogation=Spawn(class'exclamation',self,,bases.location+(vector(bases.rotation) cross vect(0,0,1))*6 + 120*vect(0,0,1));
       interrogation.setbase(pawn);
       interrogation.settimer(0.8,false);
        bDejaVu=true;
        disable('seemonster');
        disable('seeplayer');
        enable('enemynotvisible');
        bEtatAlerte=true;
    }
    event timer3()
    {
        if (grenade==none || grenade.bdeleteme)
        {
            grenade=none;
            bTemp_bool=false;
			   if (bControlAnimations) bases.ReleaseAnimControl();
            gotostate('fuitegrenade','elleapete');
        }
     /*   else if (Fasttrace(grenade.location,pawn.LOCATION))
			{
				log("la grenade est toujours en visu je me casse");
            CherchePlanqueGrenade();
			}  */
    }
    event updatetactics()
    {
        if (Vsize(grenade.location-pawn.location)>1200)
        {
            gotostate('fuitegrenade','AttendQuellePete');
        }
    }
    event Trigger(actor Other, pawn EventInstigator)
    {
    }
    function PickDestination()
    {
        local vector pick, pickdir;
        local bool success;
        local float MoveDist;

        pickdir = pawn.location-grenade.location;
  /*      if (Pawn.Physics != PHYS_Walking)
        {
            pickdir.Z = 2 * FRand() - 1;
        }
        else
        {  */
            pickdir.Z = 0;
        //}
        pickdir = Normal(pickdir);

        //chtite combi aleatoire pour fuire dans un cone de 45 deg
        Temp_vect= pickdir cross (vect(0,0,1)); //normale au vecteur direction
        if (Frand() < 0.5)
            pickdir += FRand()*Temp_Vect;
        else
            pickdir -= FRand()*Temp_Vect;
        pickdir = Normal(pickdir);
        MoveDist = 150+DistanceDeplacement*(0.4+0.6*Frand());
        success = TestDirection(150,MoveDist,pickdir, pick);
        if (!success)
        {
            temp_vect=(grenade.location-pawn.location) ;
            pickdir = temp_vect cross (vect(0,0,1));
            if (((vector(pawn.rotation) dot pickdir)*(vector(pawn.rotation) dot temp_vect) < 0) && Frand() > 0.2)
                pickdir *=-1;
            pickdir = Normal(pickdir);
            //chtite combi aleatoire pour fuire dans un cone de 45 deg
            Temp_vect= pickdir cross (vect(0,0,1)); //normale au vecteur direction
            if (Frand() < 0.5)
                pickdir += FRand()*Temp_Vect;
            else
                pickdir -= FRand()*Temp_Vect;
            pickdir = Normal(pickdir);
            MoveDist = 150+DistanceDeplacement*(0.4+0.6*Frand());
            success = TestDirection(150,MoveDist,pickdir, pick);

        }
        if (success)
        {
            DistNearWall=min(200,DistNearWall+5);
            DistanceDeplacement=min(600,DistanceDeplacement+45);
            Destination = pick;
        }
        else
        {
            DistNearWall=max(4*pawn.collisionradius,DistNearWall-40);
            DistanceDeplacement=max(10,DistanceDeplacement-35);
            GotoState('FuiteGrenade','Bloque');
        }
    }

    function BeginState()
    {
        if (CHARGE_LES_LOGS) log(pawn$"ETAT fuiteGrenade"@grenade@enemy@bdejavu);
        if (enemy!=none && !bdejavu)     //cheat si il n'a pas vu ca cible il n'a plus de cible
        {
            enemy=none;
        }
        if (enemy!=none) //deja vu
        {
            disable('seemonster');
            disable('seeplayer');
        }
        disable('enemynotvisible');
        if (NiveauAlerte==0)  //passe en alerte
        {
            s_decAttente();
            s_incAlerte();
            NiveauAlerte=1;
        }
		  else if (enemy==none)
        {
            if (NiveauAlerte==2)
            {
                s_decAttaque();
                s_incAlerte();
                NiveauAlerte=1;
            }
        }
        else
        {
            if (NiveauAlerte==1)
            {
                s_incAttaque();
                s_decAlerte();
                NiveauAlerte=2;
            }
        }
        Temps_Ref=level.timeseconds;
        bTemp_bool=false;
        //MinHitWall += 0.15;
        settimer3(0.5,true);
			bARienVu=false;
        //--------  Var Temp ------------
        //temp_bool=false //gren,ade lancee par xiii
        //bDisableEventSeeDeadPawn=true;
    }

    function EndState()
    {
		if (bControlAnimations) bases.ReleaseAnimControl();
			Halteaufeu();
			grenade=none;
        //MinHitWall -= 0.15;
        Pawn.ShouldCrouch(false);
    }
acquisition:
    focus=grenade;
    FinishRotation();
    sleep(0.3);

Begin:
    CherchePlanqueGrenade();
    //cherche safepoint
Fuite:
    PickDestination();
Moving:
    badvancedtactics=true;
    MoveTo(destination,none, 1.0);
    if (NearWall(DistNearWall))
    {
        DistanceDeplacement=max(10,DistanceDeplacement-10);
        DistNearWall=max(2*pawn.collisionradius,DistNearWall-5);
        FinishRotation();
    }
    sleep(0.04);
    goto('fuite');

Bloque:
    pawn.velocity=vect(0,0,0);
    Pawn.Acceleration = vect(0,0,0);
    Focus = None;
    FocalPoint = Location + 20 * VRand();
    FinishRotation();
    Goto('fuite');
VaVersSafePoint:
    if (bControlAnimations) bases.ReleaseAnimControl();
    badvancedtactics=true;
    If (MoveActor.bReachable)
	 {
         MoveToward(MoveActor.MoveActor,MoveActor.MoveActor);
	  	   CheckNearestGrenad();
	 }
    else
    {
        for (iCompteur=0;iCompteur<NbPointChemin;iCompteur++)
        {
            focus=none;
            focalpoint=10000*normal(PointChemin[iCompteur].location-pawn.location)+pawn.location;
            Movetoward(PointChemin[iCompteur],none);
				CheckNearestGrenad();
        }
    }
    if (SAFEPOINT(MoveActor.MoveActor).baccroupi)
    {
        pawn.shouldcrouch(true);
    }
AttendQuellePete:
    badvancedtactics=false;
    pawn.velocity=vect(0,0,0);
    Pawn.Acceleration = vect(0,0,0);
    if (CHARGE_LES_LOGS) log(pawn@"attend explosion");
    if (enemy!=none && cansee(enemy))
    {
        focus=enemy;
    }
    else
    {
        if (MoveActor.MoveActor!=none)
			 focalpoint=1000*vector(MoveActor.MoveActor.rotation)+pawn.location;
        bases.PlayWaitGrenade();
    }
    bTemp_bool=true;
    sleep(4);
	 if (bControlAnimations) bases.ReleaseAnimControl();
    bTemp_bool=false;
ElleAPete:
    if (CHARGE_LES_LOGS) log("elle a pete");
	 settimer3(0,false);
    if (pawn.biscrouched)
        pawn.shouldcrouch(false);
    if (enemy!=none) //enemy vu donc refight
    {
        if (!genalerte.bAllAlarmsActivated)    ChercheAlarme();  //ALARMEChercheAlarme();  //ALARME
        if (badvancedtactics)    //'jetais en train de me deplacer
        {
            pawn.velocity=vect(0,0,0);
            Pawn.Acceleration = vect(0,0,0);
            focus=enemy;
            finishrotation();
        }
			if (SafePointOccupe!=none)
			{
				SafePointOccupe.timer();
				SafePointOccupe=none;
			}
        gotostate('attaque');
    }
    else
        gotostate('restesurplace');
}

// ----------------------------------------------------------------------
//     Investigation    (enemy!=none)
//
//      Se deplace vers enemy pendnat tempsrecherchenmi
//
// ----------------------------------------------------------------------
state Investigation    //temps d'investigation depend du comportement ???
{
    ignores enemynotvisible;

    event SeePlayer(pawn other)
    {
        if (enemy!=none && enemy==other)
            	SeeEnemy();
    }
    event SeeMonster(pawn other)
    {
        if (enemy!=none && enemy==other)
            	SeeEnemy();
    }
    event hearnoise(float loudness,actor NoiseMaker)
    {
	 	  if (NoiseMaker.instigator!=none && NoiseMaker.instigator.controller!=none && NoiseMaker.instigator.controller.isa('CineController2'))
		     return;
        if ((weapon(NoiseMaker)!=none || XIIIProjectile(NoiseMaker)!=none) && NoiseMaker.instigator==enemy)
        {
            Gotostate('Investigation','ChercheSurPlace');
        }
    }
    event EnemyAcquired()
    {
        if (enemy==XIII) TriggerEvent('XIIIVu', Self, pawn);  //trigger vu
        bDejaVu=true;
        bWeaponNoise=false;
        bImpactNoise=false;
        bStepNoise=false;
        bCadavreVu=false;
        bPaffe=false;
        disable('seeplayer');
        disable('seemonster');
        Gotostate('Investigation','ContinueUnPeuEtAttaque');
    }
    event timer2()
    {
        changeetat();
    }
    event Trigger(actor Other, pawn EventInstigator)
    {
    }
    event UpdateTactics()
    {
    }
    function bool EnregistrePointsVersEnemy()
    {
        local int NbPoints,i;

        if (!findbestpathtoward(enemy))
        {
            //log("ne trouve pas de chemin");
            return false;
        }
        NbPoints=0;
        for (i=0;i<3;i++)
        {
            PointsInvestigation[i]=none;
        }
        for (i=0;i<16;i++)
        {
            if (routeCache[i]==none)
                break;
        }
        NbPoints=i;
        if (NbPoints==0)
        {
            //log("pas de point d'investigation");
            return false;
        }
        else if (NbPoints==1)
        {
            PointsInvestigation[0]=routeCache[0];
            return true;
        }
        else if (NbPoints==2)
        {
            PointsInvestigation[0]=routeCache[0];
            PointsInvestigation[1]=routeCache[1];
            return true;
        }
        else if (NbPoints==3)
        {
            PointsInvestigation[0]=routeCache[0];
            PointsInvestigation[1]=routeCache[1];
            PointsInvestigation[2]=routeCache[2];
            return true;
        }
        else
        {
            PointsInvestigation[0]=routeCache[int(NbPoints*0.5)-1];
            PointsInvestigation[1]=routeCache[NbPoints-int(NbPoints*0.25)-1];
            PointsInvestigation[2]=routeCache[NbPoints-int(NbPoints*0.125)-1];
            return true;
        }
    }
    function beginstate()
    {
        //bruit d'impact et cadavre pas gere
        if (NiveauAlerte==0)
        {
            s_decAttente();
            s_incAlerte();
        }
        else if (NiveauAlerte==2)
        {
            s_incAlerte();
            s_decAttaque();
        }
        NiveauAlerte=1;
        pawn.SpineYawControl(true,3000+rand(1000),1.2+1*frand());
        settimer2(bases.TempsRechercheNMI,false);
        if (bDejaVu || bweaponnoise)
            disable('hearnoise');
        //temp_vect utilise pour calcul de position
        //btemp_bool pour savoir si y va en courant
    }
    function endstate()
    {
        pawn.SpineYawControl(false,0,0);
    }
begin:
    if (CHARGE_LES_LOGS) log(pawn@"ETAT Investigation"@enemy);
    if (enemy==none)
    {
        log(pawn@"ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none **");
		  ChangeEtat();
        //enemy=xiii;
    }

investigation:
    if (fasttrace(enemy.location-vect(0,0,30),pawn.location-vect(0,0,30)))
    {
        // log("je vais directement vers perso");
        temp_vect=enemy.location-pawn.location;
        temp_vect=(vsize(temp_vect)*0.5)*normal(temp_vect)+pawn.location;
        if (fasttrace(temp_vect))
        {
            focus=none;
            focalpoint= 10000*(temp_vect-pawn.location)+pawn.location;
            if (vsize(temp_vect)>800)
            {
                Moveto(temp_vect,none);
            }
            else
            {
                Moveto(temp_vect,none,bases.walkingspeed);
            }
            stop;
        }
    }
    else if (EnregistrePointsVersEnemy())
    {
        // log("je prend les points d'investigation");
        NombreDePointsSkippes=0;
        for (NumeroProchainPoint=0;NumeroProchainPoint<3;NumeroProchainPoint++)
        {
            if (PointsInvestigation[NumeroProchainPoint]==none)
                break;
            temp_vect=enemy.location-PointsInvestigation[NumeroProchainPoint].location;
            if (vsize(temp_vect)>800)      //y va en courant
                btemp_bool=true;
            else
                btemp_bool=false;
            for (temp_int=NombreDePointsSkippes;temp_int<16;temp_int++)
            {
                if (btemp_bool)
                {
                    focalpoint=10000*(routecache[temp_int].location-pawn.location)+pawn.location;
                    Movetoward(routecache[temp_int],none);
                }
                else
                {
                    focalpoint=10000*(routecache[temp_int].location-pawn.location)+pawn.location;
                    Movetoward(routecache[temp_int],none,bases.walkingspeed);
                }
                sleep(1.5+frand());
                if (routecache[temp_int]==PointsInvestigation[NumeroProchainPoint])
                {
                    NombreDePointsSkippes=temp_int+1;
                    break;
                }
            }
        }
        stop;
    }
    else
    {
        if (CHARGE_LES_LOGS) log(pawn@"bug trouve pas de ligne d'investigation ni reseau");
        cherchePointPourCamper();
        sleep(0.04);
        if (CHARGE_LES_LOGS) log(pawn@"n'a pas trouve de safepoint");
        bCampeversSafePoint=true;
        if (!pawn.biscrouched)
            pawn.shouldcrouch(true);
        else
        {
            focus=none;
            focalpoint=10000*vector(pawn.rotation)+pawn.location;
            moveto(pawn.location-200*vector(pawn.rotation),none);
        }
        gotostate('restesurplace');
    }
ChercheSurPlace:
    Focus=enemy;
    sleep(1+frand());
    goto('investigation');
ContinueUnPeuEtAttaque:
    Focus=enemy;
    disable('SeeMonster');
    disable('SeePlayer');
    sleep(0.5);
    gotostate('attaque','initattaque');
}

// ----------------------------------------------------------------------
//     VaVers
//
//      Se deplace vers MoveActor ou MovePoint
//
// ----------------------------------------------------------------------

//pas de detection de cadavre
state VaVers
{
    ignores EnemyNotVisible;

    event Tick(float DeltaTime)
    {
        global.tick(DeltaTime);
        if (bFuitPourreloader && (level.timeseconds-Timer_VaRecharger)>1.5)
        {
            bFuitPourreloader=false;
            gotostate('attaque');
        }
    }
	 event Seeplayer(pawn other)
    {
			if (!bDejaVu && enemy!=none && enemy==other)
            	SeeEnemy();
			else
				setenemy(XIII);
    }
    event SeeMonster(pawn other)
    {
        if (!bDejaVu && enemy!=none && enemy==other)
            	SeeEnemy();
		  else
				setenemy(other);
    }
    event EnemyAcquired()
    {
        bDejaVu=true;
        bVaVersAlarme=false;
        bPotePaffe=false;
        bWeaponNoise=false;
        bFuitPourReloader=false;
        if (enemy==XIII) TriggerEvent('XIIIVu', Self, pawn);  //trigger vu
		  if (bAlarmeInstigator && ((pawn.location-enemy.location) dot (MoveActor.MoveActor.location-pawn.location)>0) && Vsize(enemy.location-MoveActor.MoveActor.location)>250)
                return;
		  bAdvancedTactics=false;
        Gotostate('Vavers','ContinueUnPeuEtAttaque');
    }
    event Trigger(actor Other, pawn EventInstigator)
    {
    }
    event UpdateTactics()
    {
        // ennemi devant l'alarme donc repasse en attaque
        if (bDejaVu && normal(pawn.location-enemy.location) dot normal(MoveActor.MoveActor.location-enemy.location)<-0.2)
        {
            bAdvancedTactics=false;
            bVaVersAlarme=false;
            genalerte.PoteTargetAlarme(false,MoveActor.MoveActor.tag);
            gotostate('attaque');
            return;
        }
    }
    event hearnoise(float loudness,actor NoiseMaker)
    {
        ActualiseSon(NoiseMaker);
    }
    function ActualiseSon(actor son)
    {
		  if (son.instigator!=none && son.instigator.controller!=none && son.instigator.controller.isa('CineController2'))
			  return;
        //bruit d'arme prioritaire sur bruitpas
        if (weapon(son)!=none || XIIIProjectile(son)!=none)
        {
            bPotePaffe=false;
            bWeaponNoise=true;
            if (alliancelevel(son.instigator)==1) //pote donc prend son enemy
            {
                enemy=son.instigator.controller.enemy;
                instigator=son.instigator;
            }
            else
            {
                enemy=son.instigator;
                instigator=enemy;
            }
            bFuitPourReloader=false;
            gotostate('acquisition','BruitArme');
        }
    }
    function beginstate()
    {
        //bruit de pas et d'impact pas gere (pas de deplacement)
        //paf et cadavre pas gere (pas de deplacement)
        if (!bPotePaffe)
        {
            disable('hearnoise');
            if (!bWeaponNoise)
            {
                if (bDejaVu)
                {
                    disable('SeeMonster');
                    disable('SeePlayer');
                }
            }
        }
		if (CHARGE_LES_LOGS) log(pawn@"ETAT VaVers"@MoveActor.MoveActor@MovePoint.MovePoint@enemy);
        //bpotepaffe ne sont appele que si etat neutre donc
        //a priori bdejavu=false
        //bCampeVersSafePoint declenche que si pas vu donc a priori bdejavu=false
        if (bDejaVu)
        {
            if (NiveauAlerte==0)
            {
                s_decAttente();
                s_incAttaque();
            }
            else if (NiveauAlerte==1)
            {
                s_decAlerte();
                s_incAttaque();
            }
            NiveauAlerte=2;
        }
        else
        {
            if (NiveauAlerte==0)
            {
                s_decAttente();
                s_incAlerte();
            }
            else if (NiveauAlerte==2)
            {
                s_incAlerte();
                s_decAttaque();
            }
            NiveauAlerte=1;
        }
        pawn.rotationrate.yaw=46000;
        //temp_float //utilise pour temps d retournement
        //bDisableEventSeeDeadPawn=true;
    }
	function endstate()
	{
		local int i;
		//Pawn.bAvoidLedges = false;
		if (EtatNeutre == 'tenir' && bVaVersAlarme)
		{
		   focalpoint=-1000*vector(pawn.rotation)+pawn.location;
		}
		if (bAlarmeInstigator && Porteouverte==none)
		{
			bAlarmeInstigator=false;
		   if (triggeralarme(MoveActor.MoveActor)!=none)
		      genalerte.PoteTargetAlarme(false,MoveActor.MoveActor.tag);
		}
		if (bInterruptStateToOpenDoor && icompteur<nbpointchemin)   //remise a jour du reseau avant de passer en ouverture de porte
		{
			nbpointchemin-=icompteur;
			for (i=0;i<nbpointchemin;i++)
			{
				PointChemin[i]=PointChemin[icompteur+i];
			}
		}
		if (bControlAnimations) bases.ReleaseAnimControl();
	}
initalarme:
    //log(pawn@"initalrame");
    if (bAlarmeInstigator)
    {
   	  TriggerEvent('CoursVersAlarme', Self, pawn);  //trigger de debut de course vers alarme
        if (triggeralarme(MoveActor.MoveActor)==none)
            log(pawn@"BUGGGGGGGGGGGGGGGGGGGGG  !!!!!!!!!!!!!!!!!!!!!!!!!!! ALARME");
        focus=xiii;
        sleep(1.8);  //petit temps de latence avant de declencher l'alarme
        badvancedtactics=true;
    }
    //ca de vavers: cadavre, bruit pas, bruit arme, alarme, pote en fight, pote paffe
begin:

Deplacement:
  // log(pawn@"Deplacement"@MoveActor.MoveActor@MoveActor.bReachable);
    if (MoveActor.MoveActor!=none)
    {
        If (MoveActor.bReachable)
        {
            focus=none;
            focalpoint=10000*(MoveActor.MoveActor.location-pawn.location)+pawn.location;
            Temp_float=normal(MoveActor.MoveActor.location-pawn.location) dot normal(vector(pawn.rotation));
            sleep(8000*(1-Temp_float)/pawn.rotationrate.yaw);
            MoveToward(MoveActor.MoveActor,none);
        }
        else
        {
            for (iCompteur=0;iCompteur<NbPointChemin;iCompteur++)
            {
                focus=none;
                focalpoint=PointChemin[iCompteur].location;
                Movetoward(PointChemin[iCompteur],none);
            }
        }
    }
    else
    {
        If (MovePoint.bTraceable)
        {
            focus=none;
            focalpoint=MovePoint.MovePoint+pawn.location;
            Temp_float=normal(MovePoint.MovePoint-pawn.location) dot normal(vector(pawn.rotation));
            sleep(8000*(1-Temp_float)/pawn.rotationrate.yaw);
            MoveTo(MovePoint.MovePoint,none);
        }
        else
        {
            for (iCompteur=0;iCompteur<NbPointChemin;iCompteur++)
            {
                focus=none;
                focalpoint=10000*(PointChemin[iCompteur].location-pawn.location)+pawn.location;
                Moveto(PointChemin[iCompteur].location,none);
            }
            focus=none;
            focalpoint=10000*(MovePoint.movepoint-pawn.location)+pawn.location;
            Moveto(MovePoint.movepoint,none);
        }
    }
    if (bAlarmeInstigator)
    {
        if (Vsize(MoveActor.MoveActor.location-pawn.location)<4*pawn.collisionradius)
		  {
				badvancedtactics=false;
        		goto('declenchealarme');
			}
			else   //crampe
			{
            bALarmeInstigator=false;
            bVaVersAlarme=false;
            genalerte.PoteTargetAlarme(false,MoveActor.MoveActor.tag);
			}
    }
    //si dernier point safepoint alors on s'oriente
    if (SAFEPOINT(MoveActor.MoveActor)!=none && SAFEPOINT(MoveActor.MoveActor).baccroupi)
    {
        pawn.shouldcrouch(true);
    }
    if (nextstate=='')
        log(pawn@" ALAAAAAAAAAAAAAAAAAAARME GROS BUG");

    Gotostate(nextstate);
ContinueUnPeuEtAttaque:
    //log(pawn@"ContinueUnPeuEtAttaque");
    Focus=enemy;
    pawn.velocity=vect(0,0,0);
    pawn.acceleration=vect(0,0,0);
    disable('SeeMonster');
    disable('SeePlayer');
    sleep(0.5);
    gotostate('attaque','initattaque');
Declenchealarme:
	//log("delcelcnhe alarme");
	 Bases.takeanimcontrol(false);
	 bases.PlayManip();
    pawn.velocity=vect(0,0,0);
    pawn.acceleration=vect(0,0,0);
    sleep(TempsDeclencheAlarme*0.3);
	 Bases.bBlockNextOuahOuah=true;
	 pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJAlert',bases.CodeMesh,bases.NumeroTimbre);
	 sleep(TempsDeclencheAlarme*0.7);
	 Bases.releaseanimcontrol(false);
	 sleep(0.1);
	 bcontrolanimations=false; //relache anim quand finie
    TriggerEvent('FinCourseVersAlarme', Self, pawn);  //fin de course vers alarme
    genalerte.PoteDeclencheAlarme(pawn,triggeralarme(MoveActor.MoveActor));
    sleep(0.5);
    /*if (EtatNeutre == 'tenir')
    {
    PointTenirPos=pawn.location;
    PointTenirRot=pawn.rotation;
     } */
    Gotostate(nextstate);
}

// ----------------------------------------------------------------------
//Etat OuvrePorte
//
// Si a un enemy et le voit repasse direct en attaque
// ----------------------------------------------------------------------
state OuvrePorte
{
    ignores EnemyNotVisible;

	event SeePlayer (pawn other)
   {
      if (enemy!=none && enemy==other)
		{
			bDejaVu=true;
        	SeeEnemy();
		}
		else
		{
			if (setenemy(XIII))
				bdejavu=true;
		}
   }
   event SeeMonster(pawn other)
   {
		if (enemy!=none && enemy==other)
		{
			bDejaVu=true;
        	SeeEnemy();
		}
		else
		{
			if (setenemy(other))
				bdejavu=true;
		}
    }
    event EnemyAcquired()
    {
        if (niveaualerte<2)
            gotostate('acquisition');
         else if (!balarmeinstigator)
		   {
				if (prevstate=='attaquescriptee')
				{
					if (movetarget!=none)  //reprend reseau vers attackpoint
					{
						NextRouteCachePoint=iCompteur;
						gotostate('attaquescriptee','RepriseVaVersAttackPoint');
					}
					else ///y va directement
						gotostate('attaquescriptee','VaVersAttackPoint');
				}
				else
				{
			      gotostate('attaque','initattaque');
				}
			}
    }
    singular event bool notifybump(actor other)
    {
        if (XIIIporte(other)!=none && porteouverte!=other)
        {
            porteouverte=XIIIporte(other);
            gotostate('ouvreporte','opendoor');
            return true;
        }
        else
            return false;
    }
    event HearNoise(float Loudness, Actor NoiseMaker)
    {
        if (TestSonEntendu(NoiseMaker))
            enemyacquired();
    }

    event Trigger(actor Other, pawn EventInstigator)
    {
    }

    singular function DamageAttitudeTo(pawn Other, float Damage)
    {
        //son
        bases.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',bases.CodeMesh,bases.NumeroTimbre);
        if (setenemy(other))
        {
            //genalerte.potepaffe(pawn);
            bPaffe=true;
        }
    }
    function beginstate()
    {
		 if (CHARGE_LES_LOGS) log(pawn@"ETAT ouvre porte"@enemy);
       //NiveauAlerte=0; GARDE NIVEAU PRECEDENT
        if (niveauAlerte>0)
        {
            disable('hearnoise');
        }
        SetTimer(0,false);
        //Var Temp
        result=false; //savoir si pas de recul deja fait
        btemp_bool=false; //utilise pour ne pas lancer 2 fois anim ouverture apre recalage
        DoorP=none; //utilise pour savoir si les doorpoints sont bons
        if (porteouverte.DoorPoint1!=none && porteouverte.doorPoint2!=none) //prend doorpoint1 comme point destination
        {
			//	log(porteouverte.DoorPoint1@porteouverte.DoorPoint2);
            DoorP=porteouverte.DoorPoint2;
            if ((porteouverte.DoorPoint2.location-porteouverte.DoorPoint1.location) dot vector(pawn.rotation)>0)
            {
                porteouverte.DoorPoint2=porteouverte.DoorPoint1;
                porteouverte.DoorPoint1=doorpoint(DoorP);
            }
			//	log(porteouverte.DoorPoint1@porteouverte.DoorPoint2);
        }
        //bDisableEventSeeDeadPawn=true;
    }
    function Endstate()
    {
        /*if (!bWaitForMover)
            Porteouverte.delaytime-=0.8;*/
        bWaitForMover=false;
        Porteouverte=none;
		  if (bControlAnimations) bases.ReleaseAnimControl(true);
    }
begin:
    pawn.velocity=vect(0,0,0);
    pawn.Acceleration = vect(0, 0, 0);
    if (Porteouverte.bAlertIfSeenOpen)
        Porteouverte.bWarnSoldiers=false;
opendoor:
    //log(pawn@"opendoor"@PorteOuverte.bOpened);
    if (!btemp_bool)
    {
        bases.PlayOpenDoor();
        sleep(PorteOuverte.MoveTime+0.02+PorteOuverte.delaytime); //temps anims d'ouverture de porte
		  bases.ReleaseAnimControl(true);
    }
    //DBUG    si le animend n'a pas bien ete appele
    if (PorteOuverte.bOpened)
    {
        result=false;
        goto('passagePorte');
    }
    else if (PorteOuverte.bClosed)
    {
        result=false;
        goto('RetourPatrouille');
    }
    //sinon  se recale sur doorpoint precedetn si en cours fermeture ou ouverture

PasEnArriere:
    //log(pawn@"pas en arriere");
    if (result)
    {
		  bases.balerte=true;
        SetVigilant(true);
        bEtatAlerte=true;
		  if (enemy==none)
		  {
			  gotostate('tenir');
		  }
		  else
        	  gotostate('restesurplace');
    }
    result=true;
    if (DoorP!=none) //seulement si doorpoints existent
    {
       moveto((porteouverte.DoorPoint2.location-pawn.location)+4*collisionradius*normal(porteouverte.DoorPoint2.location-pawn.location)+pawn.location,porteouverte.DoorPoint1,bases.WalkingSpeed);
    }
    else
    {
        focus=none;
        focalpoint=1000*vector(bases.rotation)+pawn.location;
        MoveTo(200*vector(bases.rotation)*vect(-1,0,0) +      pawn.location,none,bases.walkingspeed);
    }
    btemp_bool=true;
    goto('opendoor');
PassagePorte:
   // log(pawn@"passage porte");
    if (DoorP!=none) //seulement si doorpoints existent
    {
		 focalpoint=10000*(porteouverte.DoorPoint1.location-pawn.location)+pawn.location;
        if (niveaualerte==0)
            moveto((porteouverte.DoorPoint1.location-pawn.location)+4*collisionradius*normal(porteouverte.DoorPoint1.location-pawn.location)+pawn.location,none,bases.WalkingSpeed);
        else
            moveto((porteouverte.DoorPoint1.location-pawn.location)+4*collisionradius*normal(porteouverte.DoorPoint1.location-pawn.location)+pawn.location,none);
        if (vsize(pawn.location-porteouverte.DoorPoint1.location)>78)
        {
            //log("bloque dans la porte");
            goto('pasenarriere');
        }
    }
    else
    {
        focus=none;
        focalpoint=1000*vector(bases.rotation)+pawn.location;
        moveto(230*vector(pawn.rotation)+pawn.location,none,bases.WalkingSpeed);
    }
FermeturePorte:
  //  log(pawn@"fermeture porte");
    if (NiveauAlerte==0  && PorteOuverte.bOpened && porteouverte.bCloseDoor)
    {
        bases.PlayOpenDoor();
        focus=none;
        focalpoint=Porteouverte.location + 100*vector(pawn.rotation);
        finishrotation();
		//	log("la porte est ouverte je la ferme");
        porteouverte.PlayerTrigger(self, Pawn);
		//DBUG    si le animend n'a pas bien ete appele
		  bases.ReleaseAnimControl();
    }
RetourPatrouille:
	if (prevstate=='patrouille')
	{
		gotostate('patrouille','moving');
	}
	else if (prevstate=='attaquescriptee')
	{
		if (movetarget!=none)  //reprend reseau vers attackpoint
		{
			NextRouteCachePoint=iCompteur;
			gotostate('attaquescriptee','RepriseVaVersAttackPoint');
		}
		else ///y va directement
			gotostate('attaquescriptee','VaVersAttackPoint');
	}
	else
	   gotostate(prevstate);
ShiftOnDoorPoint:
	disable('seeplayer');
	disable('seemonster');
	disable('notifybump');
	disable('HearNoise');
	If (Vsize(porteouverte.doorpoint1.location-pawn.location)>Vsize(porteouverte.doorpoint2.location-pawn.location))
		porteouverte.doorpoint1=porteouverte.doorpoint2;
	MoveTo(4*pawn.collisionradius*normal(porteouverte.DoorPoint1.location-pawn.location)+pawn.location,enemy);
	gotostate(prevstate);
}



// ----------------------------------------------------------------------
// AttaqueScriptee
//
//  attaque reservee a XIII (voit personne d'autre)
// ----------------------------------------------------------------------
state AttaqueScriptee
{
    ignores hearnoise;
    event Tick(float deltaseconds)
    {
        local int i;
        local iacontroller iacontr;
        local vector X,Y,Z;

        global.tick(deltaseconds);
        if ((enemy==none) || enemy.bisdead)
        {
            ChangeEtat();
            return;
        }
        if (bDeplacementsRoulade)    pawn.velocity=1200*normal(LastAttackPoint.PointSortieEnRoulade.location-LastAttackPoint.location);
		  if (bDontSeeAnyMore && !bSwitchMusicInWaitState && NiveauALerteEnAS==2 && (level.timeseconds-fTimerAttackMusic)>10)
		  {
				bSwitchMusicInWaitState=true;
				NiveauALerteEnAS=0;
				s_incAttente();
            s_decAttaque();
		  }
	 }
    event Timer()
    {
        local float ProduitScal;
        local int i;
        local bool bLigneDeVIsee;

        if (bTire)
        {
            if ((enemy==none) || enemy.bisdead)
            {
                HalteAuFeu();
                return;
            }
            if (pawn.weapon.bmeleeweapon)
            {
                HalteAufeu();
                gotostate('attaqueH2H');
                return;
            }
            if (bTirSurConeMax)
					bTirSurConeMax=false;
//		log("AllianceLevel(XIII.LHand.pOnShoulder)"@AllianceLevel(XIII.LHand.pOnShoulder));
            //+++++++++++++++  Gestion otage      +++++++++++++++++++++++++
            if (enemy!=xiii || !(xiii.bPrisonner && XIII.LHand.pOnShoulder!=none && AllianceLevel(XIII.LHand.pOnShoulder)==1))
            {
                if (bPrisonnier)
                {
                    bPrecedentTirBloque=false;
                    bPrisonnier=false;
                }
                //log(pawn@pawn.weapon.Getstatename()@"PAS BLOQUE             !!!!!!!!!!!!");
                bFire=1;
                pawn.weapon.fire(1.0);
            }
            else
            {
                bLigneDeVIsee=false;
                if (!bPrisonnier)
                {
                    bPrecedentTirBloque=false;
                    bPrisonnier=true;
                }
                //tir possible sans toucher pote (skill=2&3)
	             ProduitScal=normal(vector(enemy.rotation)) dot normal(pawn.location-enemy.location);
	             if (ProduitScal <0.5)
	             {
	                if (CHARGE_LES_LOGS) log(pawn$"j'ai une ligne de visee, j'allume   *** !!!!! **** ");
	                bLigneDeVIsee=true;
	             }
                if (NbCoupsRiposte>0 || bLigneDeVIsee)
                {
                    if (bPrecedentTirBloque && bLigneDeVIsee)
                    {
                        if (CHARGE_LES_LOGS) log(pawn$"MAINTENANT LE TIR N'EST PLUS BLOQUE   !!!!!!!!!!!");
                        bPrecedentTirBloque=false;
                        settimer(0.5,false);
                        return;
                    }
                    bFire=1;
                    pawn.weapon.fire(1.0);
                    NbCoupsRiposte--;
                }
                else
                {
                    if (CHARGE_LES_LOGS) log(pawn$"TIR BLOQUE             !!!!!!!!!!!!");
                    bPrecedentTirBloque=true;
                    bfire=0;
                }
            }
            //++++++++++++++++++++++++++++++++++
            if (XIIIWeapon(pawn.weapon).WeaponMode==WM_Auto)
            {
					 if (bPremiereRafale)
					{
						bPremiereRafale=false;
				   	if (!pawn.weapon.bmeleeweapon && enemy==xiii && ((pawn.location-xiii.location) dot (vector(XIII.rotation)))<0)
				   		bTirSurConeMax=true;

					}
                if (bPrisonnier)
                    settimer(FireTimerRefresh*0.8,false); // refresh de l'otage en ligne de mire
                else
                {
						  if (bAccroupiSurAP)
                        settimer2(0.7,false);
                    else
                        settimer(FireTimerRefresh,false); // pour tester si reste muns

                }
            }
            else
            {
                bfire=0;
                settimer(XIIIWeapon(pawn.weapon).shottime+bases.OffsetTimeBetweenShots,false);
            }
        }
    }
    event Timer2()
    {
        if (btire)
        {
            bfire=0;
            settimer(0.5,false);
        }
    }
    event timer3()
    {
        EnemyTargetPos=enemy.location;
        EnemyTargetVelocity=enemy.velocity;
			if (!btemp_bool)    //btemp_bool determine si on est en deplacement
				return;

        if (lastAttackpoint.bTirEntreLes2)
        {
				if (CanSee(enemy))
				{
					Fireenemy();
					if (bSwitchMusicInWaitState && NiveauALerteEnAS==0)
					{
						s_decAttente();
			         s_incAttaque();
						NiveauALerteEnAS=2;
					   bSwitchMusicInWaitState=false;
					}
					bLookAtEnemy=false;
					enable('enemynotvisible');
				}
				else
				{
					HalteAuFeu();
					bLookAtEnemy=true;
					disable('enemynotvisible');
				}
        }
        // Passage dans attaque
        if (Vsize(enemy.location-pawn.location)<310 && !LastAttackpoint.bForceDeplacement && Cansee(enemy)) //je vois alors que je ne voyais pas
        {
            HalteAufeu();
            CompteurRecalage=15;
            gotostate('attaque');
        }
    }
	function DamageAttitudeto(pawn Other, float Damage)
    {
        if (bases.bisdead)
            return;
        //son
        bases.PlaySndPNJOno(pnjono'Onomatopees.hPNJHurt',bases.CodeMesh,bases.NumeroTimbre);

	     If (xiii.bPrisonner && XIII.LHand.pOnShoulder!=none && AllianceLevel(XIII.LHand.pOnShoulder)==1 && other==xiii)
        {
           if (CHARGE_LES_LOGS) log(pawn$"je riposte");
           NbCoupsRiposte=(2+bases.agressivite)*1.9;
           NbCoupsRiposte=Min(5,NbCoupsRiposte);
           NbCoupsRiposte=Max(1,NbCoupsRiposte);
        }
    }
	Function SeeEnemy()
	{
		bDontSeeAnyMore=false;
		if (bSwitchMusicInWaitState && NiveauALerteEnAS==0)
		{
			s_decAttente();
         s_incAttaque();
			NiveauALerteEnAS=2;
		   bSwitchMusicInWaitState=false;
		}
		enable('enemynotvisible');
		FireEnemy();
	}
    event SeePlayer (pawn other)
    {
        if (bLookAtEnemy && enemy!=none && enemy==other)
            SeeEnemy();
		  else
		  		SetEnemy(other);
    }
    event SeeMonster(pawn other)
    {
			if (bLookAtEnemy && enemy!=none && enemy==other)
            SeeEnemy();
		  else
				SetEnemy(other);
    }
    event enemynotvisible()
    {
        HalteAuFeu();
		  blookAtEnemy=true;
		  bDontSeeAnyMore=true;
		  fTimerAttackMusic=level.timeseconds;
        disable('enemynotvisible');
    }
    event EnemyAcquired()
    {
        FireEnemy();
		  bDontSeeAnyMore=false;
		  if (bSwitchMusicInWaitState && NiveauALerteEnAS==0)
		  {
				s_decAttente();
            s_incAttaque();
				NiveauALerteEnAS=2;
				bSwitchMusicInWaitState=false;
		  }
        enable('enemynotvisible');
    }
    function NotifyFiring()
    {
		  if (enemy==none)
				return;
        DirectionTir=DirectionDuTir(); //recupere direction du tir avant dispersion
        //decalage par rapport a l'arme
        CheckLineOfFire();
    }
    function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
    {
        if (iNumEtat==2) // si vise grenade target
            return rotator(LastAttackPoint.Ciblegrenade.location-projstart);
        else
            return global.adjustaim(FiredAmmunition, projStart,aimerror);
    }
	 function PasseEtatAlerteEnAttaque()
	 {
        if (NiveauALerteEnAS==0)
        {
            s_decAttente();
            s_incAttaque();
        }
        NiveauALerteEnAS=2;
	 }
	 function PasseEtatAlerteEnAttente()
	 {
		  if (NiveauALerteEnAS==2)
        {
            s_incattente();
            s_decAttaque();
        }
        NiveauALerteEnAS=0;
	 }

    function CheckLineOfFire()
    {
        local int TypeObstacle;

        TypeObstacle=LineOfFireObstacle();
        if (TypeObstacle==0)  //rien devant
        {

            return;
        }
        else if (TypeObstacle==1)
        {
            bfire=0; //bloc tir car pote devant
            settimer(1.0,true);
            focus=enemy;
        }
		  /*else
        {
				log("decor devant");
				if (fasttrace(enemy.location+enemy.EyePosition(), WeaponStartTrace)) //seehead
				{
					log("reajuste tir vers tete");
					DirectionTir.z+=20;
				}
		  } */
    }
    function BeginState()
    {
		if (lastAttackpoint==none)
			return;
			Switch (NiveauAlerte)
			{
				case 0:
					if (LastAttackPoint.bMusiqueAttaque || CanSee(enemy))
					{
						s_incattaque();
            		s_decAttente();
						NiveauALerteEnAS=2;
					}
					else
						NiveauALerteEnAS=0;
					break;
				case 1:
					if (LastAttackPoint.bMusiqueAttaque || CanSee(enemy))
					{
						s_incattaque();
            		s_decAlerte();
						NiveauALerteEnAS=2;
					}
					else
					{
						s_incattente();
            		s_decAlerte();
						NiveauALerteEnAS=0;
					}
					break;
             case 2:
					if (LastAttackPoint.bMusiqueAttaque || CanSee(enemy))
					{
						NiveauALerteEnAS=2;
					}
					else
					{
						NiveauALerteEnAS=0;
						s_decattaque();
            		s_incAttente();
					}
			}
		  NiveauAlerte=2;
		  bARienVu=false;
        pawn.SetAnimStatus('alert');
        //bDisableEventSeeDeadPawn=true;
			bLookAtEnemy=false;
        disable('enemynotvisible');
        SetVigilant(true);
        Temps_ref=level.timeseconds-2;
        settimer3(Temps_RefreshEnemyPos,true);
        //--------  Var Temp ------------
        Temp_float=0.0; //pour stocker temps de pause sur AttackPoint
        VitesseHorizontaleSaut=0.0;
        temp_vect=vect(0,0,0); //utiliser pour calcul du saut
        bSaut=false;
        btemp_bool=false; //sert au test de vision avant deplacement (->tirsurplace)
        //result=false; //utilise pour savoir si a change de branche
        iNumEtat=0;
		  bDontSeeAnyMore=false;
		  bSwitchMusicInWaitState=false;
        //temp_int=0;//compteur recherche de branche secondaire
        //et sert a savoir si en train de grenader perso 1 ou grenade target 2
    }
    function EndState()
    {
        if (LastAttackPoint!=none && !LastAttackPoint.bReprenable)
        {
            LastAttackPoint.bDejaPasse=true; //notify le passage a l'AP
        }
		  if (bControlAnimations) bases.ReleaseAnimControl();
        Pawn.ShouldCrouch(false);
        pawn.bcanjump=false;
		  pawn.bIsPafable=true;
        HalteAuFeu();
        settimer3(0,false);
		  bBloqueFuiteGrenades=false;
		  if (NiveauAlerte!=0 && NiveauALerteEnAS==0)
		  {
			 	NiveauAlerte=0;
			 	bSwitchMusicInWaitState=false;  //inutile
		  }
		  NiveauALerteEnAS=-1;
    }

begin:
    if (CHARGE_LES_LOGS) log(pawn@"AttaqueScriptee");
    if (enemy==none)
    {
        log(pawn@"ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none **");
        //enemy=xiii;
    }
    if (lastAttackpoint==none)  //blindage
    {
        CompteurRecalage=15;
        gotostate('attaque');
    }
    EnemyTargetPos=enemy.location;
    EnemyTargetVelocity=enemy.velocity;
    pawn.velocity=vect(0,0,0);
    pawn.acceleration=vect(0,0,0);
VaVersAttackPoint:
    if (pawn.biscrouched)
        Pawn.ShouldCrouch(false);
	 if (LastAttackPoint.bMusiqueAttaque || CanSee(enemy))
		 PasseEtatAlerteEnAttaque();
	 else
       PasseEtatAlerteEnAttente();
	 btemp_bool=true; //sert a savoir qu'on est en mouvement
    //-------------------
    If (movetarget!=none)  //donc pas reachable
    {
		 NextRouteCachePoint=0;
RepriseVaVersAttackPoint:
        if (CHARGE_LES_LOGS) log(pawn$"va au Attack point par chemin");
        for (iCompteur=NextRouteCachePoint;iCompteur<NbPointChemin;iCompteur++)
        {
            if (!btire)
            {
                focus=none;
                focalpoint=10000*(PointChemin[iCompteur].location-pawn.location)+pawn.location;
            	MoveToward(PointChemin[iCompteur],none);
        		}
				else
	            MoveToward(PointChemin[iCompteur],enemy);
        }
    }
    else
    {
			if (CHARGE_LES_LOGS) log(pawn$"va au Attack directement");
        if (!btire)
        {
            focus=none;
            focalpoint=10000*(LastAttackPoint.location-pawn.location)+pawn.location;
				MoveToward(LastAttackPoint,none);
        }
			else
				MoveToward(LastAttackPoint,enemy);
    }
    btemp_bool=false; //car detection que pendant deplacement
    bSaut=false;

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // +++++++++++++++ GESTION DES PROPRIETES DE L'ATTACK POINT +++++++++++++++++++++
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
GetProperties:
    //--------------   PROPRIETES D'ENTREE   -------------------
    GetAttackPointProperties(LastAttackPoint,temp_float);
UseProperties:
    //Si il y a une ciblegrenade ben prend grenade
    if (LastAttackPoint.bTenteGrenadage && enemy.base!=none)
    {
        if (pawn.weapon.isa('grenad'))
            pawn.pendingweapon=pawn.weapon;
        else
        {
          // ELR Remove Class reference
//          pawn.pendingweapon=XIIIWeapon(pawn.FindInventoryType(class'grenad'));
          Pawn.PendingWeapon = Pawn.Inventory.WeaponChange(4);
          if ( Pawn.PendingWeapon == none )
            Pawn.PendingWeapon = Pawn.Inventory.WeaponChange(20); // Try Frag Grenad
          // ELR End
        }
        if (pawn.pendingweapon!= none && pawn.pendingweapon.HasAmmo())
        {
				result=btire;
            if (LastAttackpoint.CibleGrenade!=none && LastAttackpoint.CibleGrenade.bactive && FastTrace(LastAttackpoint.ciblegrenade.location,pawn.location))
            {
                //log("cible grenade!!=none"@Pawn.PendingWeapon);
                if (result) //tire deja
                    HalteAufeu();
                if (Pawn.Weapon!=Pawn.PendingWeapon)
                    Pawn.Weapon.PutDown();
                else
                    pawn.pendingweapon=none;
                iNumEtat=2;
                temp_float=fmax(4.5,temp_float);
					 sleep(1.2);
					 if (LastAttackpoint.CibleGrenade.bactive)
                {
WaitGrenadReady:
	                sleep(0.2);
						 if (!pawn.weapon.isa('grenad') || pawn.weapon.isinstate('active'))
							goto('WaitGrenadReady');
	                if (!bases.bDontCallFriends) pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJGrenade',bases.CodeMesh,bases.NumeroTimbre);
						 if (bSwitchMusicInWaitState && NiveauALerteEnAS==0)
						 {
							s_decAttente();
				         s_incAttaque();
							NiveauALerteEnAS=2;
						   bSwitchMusicInWaitState=false;
						 }
	                fireenemy();
	                sleep(1);
					 }
                ChangetoBestWeapon();
                if (!result) //tire deja
                    HalteAufeu();
                iNumEtat=0;
            }
            else if (Vsize(enemy.location-pawn.location)<1200 && Vsize(enemy.location-pawn.location)>300)
            {
                //log("bonne distance de hgrenaage"@pawn.pendingweapon@pawn.weapon);
                if (FastTrace(enemy.location+vect(0,0,80),enemy.location) && FastTrace(enemy.location+vect(0,0,80),pawn.eyeposition()+pawn.location))
                {
                    if (result) //tire deja
                        HalteAufeu();
                    if (Pawn.Weapon!=Pawn.PendingWeapon)
                    {
                        Pawn.Weapon.PutDown();
                    }
                    else
                        pawn.pendingweapon=none;
                    iNumEtat=1;
					 	  sleep(1.2);
WaitGrenadReadySansGrenadTarget:
	                 sleep(0.2);
						  if (!pawn.weapon.isa('grenad') || pawn.weapon.isinstate('active'))
							goto('WaitGrenadReadySansGrenadTarget');
                    if (!bases.bDontCallFriends) pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJGrenade',bases.CodeMesh,bases.NumeroTimbre);
						  if (bSwitchMusicInWaitState && NiveauALerteEnAS==0)
						  {
								s_decAttente();
					         s_incAttaque();
								NiveauALerteEnAS=2;
							   bSwitchMusicInWaitState=false;
						  }
                    fireenemy();
                    sleep(1);  //temps de lancer une grenade
                    //log("bonne distance de hgrenaage et fasttrace");
                    ChangetoBestWeapon();
                    if (!result) //tire deja
                        HalteAufeu();
                    iNumEtat=0;
                }
            }
        }
        else
        {
            pawn.pendingweapon=none;
            //log(pawn@"jai pas grenades");
        }
    }
    //ONOMATOPEE CRIE
    if (LastAttackPoint.bAlerteAmisEnCriant /*&& !bADejaCrie */&& bases.bAlerteAmisEnCriant)
    {
        //bADejaCrie=true;
        Interrogation=Spawn(class'XIIIalerteEmitter',self,,pawn.location+vect(0,0,70));
        interrogation.setbase(pawn);
        //son
        pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJAlert',bases.CodeMesh,bases.NumeroTimbre);
        genalerte.PoteBeugle(pawn);
    }
    //SAUT
    if (bSaut)
    {
        if (CHARGE_LES_LOGS) log(pawn$"commence saut dans attaque scriptee");
		  pawn.bIsPafable=false;
		  bBloqueFuiteGrenades=true;
        focalpoint=20000*LastAttackPoint.lookdir + pawn.location;
        focus=none;
		  bases.PlayJumpInAir();
        pawn.bcanjump=true;
        finishrotation();
        pawn.velocity=temp_vect;
        pawn.jumpz=VitesseHorizontaleSaut;
        pawn.Dojump(true);
        pawn.jumpz=420;
		  FinishAnim(bases.firingChannel+1);
		  //pawn.shouldcrouch(true);
		  //bases.SetCollisionSize(bases.CrouchRadius, bases.CrouchHeight);
		  bases.PlayJumpInFlight();
        waitforlanding();
		  pawn.bcanjump=false;
		  bases.PlayJumpLanding();
		  FinishAnim(bases.firingChannel+1);
		  bases.releaseanimcontrol();
        if (btire)        //retabli visee
            focus=enemy;
		  pawn.rotationrate.yaw=25000;
		  sleep(0.2);
		  finishrotation();
        pawn.rotationrate.yaw=46000;
		  bBloqueFuiteGrenades=false;
		 // bases.SetCollisionSize(bases.collisionRadius, bases.collisionHeight);
	  	  //pawn.shouldcrouch(false);
			pawn.bIsPafable=true;
        if (CHARGE_LES_LOGS) log(pawn$"fini saut dans attaque scriptee");
    }
    else
    {
        if (temp_float>=0.02)
        {
            if (!btire)
            {
                focus=none;
                FocalPoint = pawn.Location + Lastattackpoint.lookdir;
            }
            sleep(temp_float);
        }
        if (bAccroupiSurAP)
            bAccroupiSurAP=false;
    }
    //--------------   PROPRIETES DE SORTIE   ------------------
    //Boucle sur dernier WP uniquement si la propriete le permet (bTemp_bool=true)
    if (lastAttackpoint.bBoucleSurDernier)
    {
        if (lastAttackpoint.bAccroupi)
            Pawn.ShouldCrouch(true);
			if (lastAttackpoint.bTirSurPlace)
         {
            if (Cansee(enemy))
            {
					if (bSwitchMusicInWaitState && NiveauALerteEnAS==0)
					{
						s_decAttente();
			         s_incAttaque();
						NiveauALerteEnAS=2;
					   bSwitchMusicInWaitState=false;
					}
                enable('enemynotvisible');
                bLookAtEnemy=false;
                FireEnemy();
            }
            else
            {
                HalteAuFeu();
                bLookAtEnemy=true;
                disable('enemynotvisible');
            }
          }
          else
          {
            HalteAuFeu();
            bLookAtEnemy=false;
            disable('enemynotvisible');
          }
        //gotostate('restesurplace');
			stop;
    }
    else
    {
        //sortie en roulade
        if (lastAttackpoint.PointSortieEnRoulade!=none && LastAttackPoint.NextAttackP!=none)
        {
				pawn.bIsPafable=false;
            if (!pawn.biscrouched)
                pawn.shouldcrouch(true);
            //log("debut roulade");
            pawn.velocity=vect(0,0,0);
            pawn.acceleration=vect(0,0,0);
            halteaufeu();
				disable('seemonster');
            disable('seeplayer');
            disable('enemynotvisible');
            sleep(0.2);
				if (abs(normal(enemy.location-pawn.location) dot normal(LastAttackPoint.PointSortieEnRoulade.location-LastAttackPoint.location))>0.9 || Vsize(enemy.location-pawn.location)<500)
				{
              	if (!lastAttackpoint.bAccroupi)
						pawn.shouldcrouch(false);
					enable('seemonster');
            	enable('seeplayer');
					if (Cansee(enemy))
	            {
						 if (bSwitchMusicInWaitState && NiveauALerteEnAS==0)
						{
							s_decAttente();
				         s_incAttaque();
							NiveauALerteEnAS=2;
						   bSwitchMusicInWaitState=false;
						}
	                bLookAtEnemy=false;
	                enable('enemynotvisible');
	                FireEnemy();
	            }
	            else
	            {
	                disable('enemynotvisible');
	                bLookAtEnemy=true;
	                HalteAuFeu();
	            }
					goto('PointSuivant');
				}
			   bBloqueFuiteGrenades=true;
            //log("lance roulade");
            focalpoint=LastAttackPoint.NextAttackP.location;
            bases.playroulade();
            bDeplacementsRoulade=true;
            focus=enemy;
            pawn.groundspeed=1200;
            sleep(0.55);
            bDeplacementsRoulade=false;
            sleep(0.1);
            pawn.playanim('waitaccroupi',1,0.2,bases.FiringChannel+1);
            pawn.groundspeed=472;
            sleep(0.08);
				enable('seemonster');
            enable('seeplayer');
            sleep(0.13);
            if (Cansee(enemy))
            {
					 if (bSwitchMusicInWaitState && NiveauALerteEnAS==0)
					{
						s_decAttente();
			         s_incAttaque();
						NiveauALerteEnAS=2;
					   bSwitchMusicInWaitState=false;
					}
                bLookAtEnemy=false;
                enable('enemynotvisible');
                FireEnemy();
            }
            else
            {
                disable('enemynotvisible');
                bLookAtEnemy=true;
                HalteAuFeu();
            }
            bases.AnimBlendToAlpha(bases.FIRINGCHANNEL+1,0.5,0);
            sleep(0.04);
            bases.AnimBlendToAlpha(bases.FIRINGCHANNEL+1,0,0);
            //log("commence a tirer");
            bases.ReleaseAnimControl();
            sleep(2);
            //log("fin roulade");
            //pawn.bspinecontrol=true;
				pawn.bIsPafable=true;
				bBloqueFuiteGrenades=false;
        }
        if (lastAttackpoint.bTirEntreLes2)
        {
            if (Cansee(enemy))
            {
					if (bSwitchMusicInWaitState && NiveauALerteEnAS==0)
					{
						s_decAttente();
			         s_incAttaque();
						NiveauALerteEnAS=2;
					   bSwitchMusicInWaitState=false;
					}
                bLookAtEnemy=false;
                enable('enemynotvisible');
                FireEnemy();
            }
            else
            {
                disable('enemynotvisible');
                bLookAtEnemy=true;
                HalteAuFeu();
            }
        }
        else
        {
            disable('enemynotvisible');
				bLookAtEnemy=false;
            HalteAuFeu();
        }
    }

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PointSuivant:
    if (!LastAttackPoint.bReprenable)
    {
        LastAttackPoint.bDejaPasse=true; //notify le passage a l'AP
    }
    result=false;
    If (LastAttackPoint.PointDuSecondChemin!=none)
    {
        if (FindBestPathToward(XIII))
        {
            if (movetarget==LastAttackPoint)
            {
                if(RouteCache[1]!=none)
                    movetarget=RouteCache[1];
                else
                    movetarget=none;
            }
            if (attackpoint(movetarget)!=none && attackpoint(movetarget)==LastAttackPoint.PointDuSecondChemin)
            {
                result=true;
                OldAttackPoint=lastAttackpoint;
                LastAttackPoint=LastAttackPoint.PointDuSecondChemin;
            }
        }
        if (!result)
        {
            //vire l'utilisation de l'autre branche (Oldattackpoint est utilise en var temp)
            OldAttackPoint=LastAttackPoint.PointDuSecondChemin;
            While (OldAttackPoint!=none && !OldAttackPoint.bDejaPasse)
            {
                OldAttackPoint.bDejaPasse=true; //notify le passage a l'AP
                OldAttackPoint=OldAttackPoint.NextAttackP;
            }
        }
    }

    if (!result)  // si pas change de branche
    {
        OldAttackPoint=lastAttackpoint; //sauv dernier
        if (LastAttackPoint.NbPointsSkipables>0)     //passage aleatoire a un autre
        {
            NombreDePointsSkippes=LastAttackPoint.NbPointsSkipables-1;
            NumeroProchainPoint=rand(NombreDePointsSkippes+1);
            //log("NumeroProchainPoint"@NumeroProchainPoint@NombreDePointsSkippes);
            for (temp_int=0;temp_int<=NumeroProchainPoint;temp_int++)
            {
                LastAttackPoint=LastAttackPoint.NextAttackP;
                if (temp_int<NumeroProchainPoint && !LastAttackPoint.bReprenable)
                    LastAttackPoint.bDejaPasse=true; //notify le passage a l'AP
            }
            NumeroProchainPoint=NombreDePointsSkippes-NumeroProchainPoint;
            for (temp_int=0;temp_int<NumeroProchainPoint;temp_int++)
            {
                if (temp_int<NumeroProchainPoint && !LastAttackPoint.NextAttackP.bReprenable)
                    LastAttackPoint.NextAttackP.bDejaPasse=true; //notify le passage a l'AP
                LastAttackPoint.NextAttackP=LastAttackPoint.NextAttackP.NextAttackP;
            }
        }
        else
        {
            LastAttackPoint=LastAttackPoint.NextAttackP;  //passe suivant
        }
    }
    if (lastAttackpoint!=none) //on sera au Attackpoint avant NMI
    {
        movetarget=none;
        if (ActorReachable(LastAttackpoint))
        {
            goto('VaVersAttackPoint');
        }
        else if (FindBestPathToward(LastAttackPoint))
        {
            for (iCompteur=0;iCompteur<16;iCompteur++)
            {
                if (routecache[iCompteur]==none)
                    break;
                PointChemin[iCompteur]=routecache[iCompteur];
            }
            NbPointChemin=iCompteur;
            goto('VaVersAttackPoint');
        }
    }
FinAttaque:
    //Dernier attack point = position de tenir
    if (EtatNeutre == 'tenir')
    {
        PointTenirPos=pawn.location;
        PointTenirRot=pawn.rotation;
    }
    HalteAuFeu();
    if (CHARGE_LES_LOGS) log(pawn@"Sort de son resau d'attaqueScriptee");
    /*if (bdejavu)
    { */
    if (CanSee(enemy))
    {
			if (bSwitchMusicInWaitState && NiveauALerteEnAS==0)
			{
				s_decAttente();
	         s_incAttaque();
				NiveauALerteEnAS=2;
			   bSwitchMusicInWaitState=false;
			}
        CompteurRecalage=15;
        gotostate('attaque');
    }
    else
        gotostate('temporise');
        /* }
        else
    gotostate('tenir'); */

}


Function GetAttackPointProperties (AttackPoint PointAttaque, out float TempsSurAP)
{
    local bool ResteSurPlace;
    local float X,Y,Z;
    local float rating;
    local XIIIWeapon Arme,ancienearme;

    //PROPRIETES
        switch(PointAttaque.Proprietes.Propriete)
        {
        case Rester:
            if (CHARGE_LES_LOGS) log(pawn$"Propriete reste");
            ResteSurPlace=true;
				if (PointAttaque.Proprietes.arguments.length>0)
	            TempsSurAP=float(PointAttaque.Proprietes.arguments[0]);
				else
					TempsSurAP=0;
            if (PointAttaque.Proprietes.arguments.Length>1)
            {
                if (frand()>0.5)
                    TempsSurAP+=frand()*float(PointAttaque.Proprietes.arguments[1]);
                else
                    TempsSurAP-=frand()*float(PointAttaque.Proprietes.arguments[1]);
            }
            if (PointAttaque.Proprietes.arguments.Length>2)
            {
                bases.TakeAnimControl(false);
                bases.PlayAnim(name(PointAttaque.Proprietes.arguments[2]),,,bases.FIRINGCHANNEL+1);
                bases.AnimBlendToAlpha(bases.FIRINGCHANNEL+1,1,0.4);
            }
            TempsSurAP=fmax(0.02,TempsSurAP);
            break;

        case sauter:
            if (CHARGE_LES_LOGS) log(pawn$"Propriete saute");
            bSaut=true;
            if (PointAttaque.Proprietes.arguments.Length>1)
            {
                temp_vect=vector(PointAttaque.rotation)*float(PointAttaque.Proprietes.arguments[0]);
                VitesseHorizontaleSaut=float(PointAttaque.Proprietes.arguments[1]);
            }
            break;

            //case "Trigger":
            //     PointAttaque.TriggerEvent();
            //     break;

        default:
            if (CHARGE_LES_LOGS) log(pawn$"  ********* UNKNOW ARGUMENT *******"$PointAttaque.Proprietes.Propriete);
        }

    //TRIGGER
    if (PointAttaque.bTriggerEvent)
    {
        PointAttaque.TriggerEvent(PointAttaque.event,PointAttaque,pawn);
    }

    if (ResteSurPlace) //Que pour rester et switcherArme
    {
        //ACCROUPI
        if (PointAttaque.bAccroupi)
        {
            Pawn.ShouldCrouch(true);
            TempsSurAP+=0.1;  //temps de l'anim de crouch
            bAccroupiSurAP=true;
        }
        // TIR SUR PLACE
        if (PointAttaque.bTirSurPlace)
        {
            if (Cansee(enemy))
            {
					 if (bSwitchMusicInWaitState && NiveauALerteEnAS==0)
					{
						s_decAttente();
			         s_incAttaque();
						NiveauALerteEnAS=2;
					   bSwitchMusicInWaitState=false;
					}
                if (LastAttackPoint.CibleGrenade==none || !LastAttackPoint.CibleGrenade.bActive)
                    enable('enemynotvisible');
                else
                    disable('enemynotvisible');
                bLookAtEnemy=false;
                FireEnemy();
            }
            else
            {
                HalteAuFeu();
                bLookAtEnemy=true;
                disable('enemynotvisible');
            }
        }
        else
        {
            HalteAuFeu();
            bLookAtEnemy=false;
            disable('enemynotvisible');
        }
    }
    else
    {
        HalteAuFeu();
        bLookAtEnemy=false;
        disable('enemynotvisible');
    }
}

/*
NiveauAlerte    (niv0 = trannnnnnquille, niv1= j'ai vu quelque chose mais je ne suis pas en attaque, niv2= je suis en plein fight)

  Niv 0                             Niv 1                               Niv 2

    Init                                Acquisition                 attaque
    Otage                             Fuite                               Chasse
    Faction                                                           Temporise
    Patrouille                                                          AttaqueScriptée
    Errance                                                           TacticalMove




            */
		 //					bAdjustFromWalls=false


defaultproperties
{
     TempsDeclencheAlarme=1.700000
     NiveauALerteEnAS=-1
     bAdjustFromWalls=False
}
