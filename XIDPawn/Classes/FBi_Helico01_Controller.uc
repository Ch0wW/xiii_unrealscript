//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FBi_Helico01_Controller extends IAController;

var FBI_Helico01a FBI;
var bool bGoToCallTalkie;


// ----------------------------------------------------------------------
// CherchePointPourCamper  // pour appeler a l'aide
//
// ----------------------------------------------------------------------
function bool ChercheTalkiePoint()  //cherche 2 SPs les plus proches et atteignable pour campage a moins de 10m
{
   local SafePoint Safe,BestSafe,secondsafe;
	local actor SecondPathRouteCache[16];
   local int i,j,temp_num;
	local int SecondPathNbPoint;

	NbPointChemin=1000;
	For(i=0;i<level.game.SafePointList.Length;i++)
	{
		safe=safepoint(level.game.SafePointList[i]);
      if (!Safe.bAlreadyTargeted && VSize(safe.location-pawn.location)<2000)
		{
			if (FindBestPathToward(safe))
			{
				for (j=0;j<16;j++)
				{
				   if (routecache[j]==none)
				     break;
				}
				temp_num=j;
				if (temp_num<NbPointChemin)
				{
					if (NbPointChemin<1000)
					{
						SecondSafe=BestSafe;
						SecondPathNbPoint=NbPointChemin;
						for (j=0;j<16;j++)
					 	{
					      if (routecache[j]==none)
					         break;
							SecondPathRouteCache[j]=PointChemin[j];
					 	}
					}
					NbPointChemin=temp_num;
					bestsafe=safe;
					for (j=0;j<16;j++)
				 	{
				      if (routecache[j]==none)
				         break;
						PointChemin[j]=routecache[j];
				 	}
				}
			}
 		}
	}
	if (secondsafe!=none /*&& rand(2)!=0 */&& (XIII.location - pawn.location) dot (bestsafe.location-pawn.location)>0 && (XIII.location - pawn.location) dot (SecondSafe.location-pawn.location)<0)
	{
		bestsafe = secondsafe;
		for (j=0;j<16;j++)
		{
			if (routecache[j]==none)
				 break;
			PointChemin[j]=SecondPathRouteCache[j];
		}
		NbPointChemin=SecondPathNbPoint;
	}
   if (bestsafe==none || (Vsize(bestsafe.location-xiii.location)<600 && rand(3)!=0))
	{
		NbPointChemin=0;
        return false;
	}
	MoveActor.MoveActor=bestsafe;
	MoveActor.bReachable=false;
	Nextstate='ResteSurPlace';
	bestsafe.Occupe();
	return true;
}

// ----------------------------------------------------------------------
// SetMonster
// ----------------------------------------------------------------------
Function bool SetMonster(XIIIPawn NewEnemy,bool bEnemyPasVu)
{
    local bool result;

    if (NewEnemy==Pawn || NewEnemy==None || NewEnemy.bisdead || AllianceLevel(Newenemy)<0)
        return false;
    if (newenemy.controller.isinstate('restesurplace')|| (newenemy.controller.isinstate('vavers') &&  Iacontroller(newenemy.controller).bCampeversSafePoint))
    {
        enemy=xiii;
        gotostate('acquisition','attaque');
    }
    return true;
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
		if (bGoToCallTalkie && moveactor.moveactor!=none && moveactor.moveactor.isa('safepoint'))
		{
			moveactor.moveactor.timer(); //pour liberer
			bGoToCallTalkie=false;
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

//-----------------------------------------------------
// Acquisition reecrit pour talkie
//-----------------------------------------------------
State Acquisition
{
	 event SeeDeadPawn(pawn other)
    {
        local basesoldier soldier;

        soldier=basesoldier(other);

        if (bases.BNeVoitPascadavre || bCadavreVu || bdejavu || Soldier.DrawType == DT_NONE ||  soldier==none || soldier.bMonCadavreEstDejaVu || AllianceLevel(Soldier)!=1)
            return;
        bStepNoise=false;
        bCadavreVu=true;
        instigator=other;
        enemy=none;
        InitReactions();
        Soldier.bMonCadavreEstDejaVu=true;
        gotostate('acquisition','CadavreVu');
    }
	event Seeplayer(pawn other)
	{
		if (!bGoToCallTalkie) //cheat pour savoir si a deja sorti talkie
		{
			if (!bDejaVu && enemy!=none && enemy==other)
			{
            	SeeEnemy();
			}
			else
				setenemy(XIII);
		}
		else
			setenemy(XIII);
	}
Begin:
    InitReactions();
    if (!bcadavrevu && xiiipawn(enemy).bisdead)
    {
        ChangeEtat();
    }
    Pawn.Acceleration = vect(0,0,0);
    Pawn.Velocity = vect(0,0,0);
Init:
    if (!bDejaVu)
    {
        //pawn.SetAnimStatus('alert');
		  //son
   	  pawn.PlaySndPNJOno(pnjono'Onomatopees.hPNJDetect',bases.CodeMesh,bases.NumeroTimbre);//se retourne vers bruit et reste sur place
        Interrogation=Spawn(class'exclamation',self,,bases.location+(vector(bases.rotation) cross vect(0,0,1))*6 + 120*vect(0,0,1));
        interrogation.setbase(pawn);
        if (bStepNoise)
            goto('BruitPas');
        else if (bImpactNoise)
            goto('BruitImpact');
        else if (bCadavreVu)
            goto('CadavreVu');
        else if (bPaffe)
            goto('Paffe');
        else if (bWeaponNoise)
            goto('BruitArme');
    }
    else
        goto('Vu');
BruitPas:
    //se retourne vers bruit, (va vers bruit de pas ??)et reste sur place
    ChercheNMIDuRegard();
    FinishRotation();
    sleep(2);
    Changeetat();
CadavreVu:
    //va vers cadavre, alarme, investigation (???)
    Pawn.Acceleration = vect(0,0,0);
    Pawn.Velocity = vect(0,0,0);
    Focalpoint=instigator.location;
    FinishRotation();
    sleep(0.5);
    if (Vsize(instigator.location-pawn.location)<800)   //vavers cadavre
        temp_vect=0.2*(instigator.location-pawn.location) + pawn.location;
    else
        temp_vect=(Vsize(instigator.location-pawn.location)-800)*normal(instigator.location-pawn.location)+pawn.location;
	 TriggerEvent('surprise_corps_decouvert', self, pawn);
    MoveTo(instigator.location,instigator);
 	 pawn.pendingweapon=XIIIWeapon(pawn.FindInventoryType(class'fists'));
    if (Pawn.Weapon!=Pawn.PendingWeapon)
        Pawn.Weapon.PutDown();
    sleep(0.4);
	//sort talkie
    FBI.PlayTakeTalkie();
    sleep(0.3); //attente anim
    FBI.Talkie.AttachToWalkie(pawn,true); //talkie dans la main
    sleep(1);
	 TriggerEvent('alerte_corps_decouvert', pawn, pawn);
	 bases.ReleaseAnimControl();
	// TriggerEvent('cadavrevu', self, pawn);
    gotostate('ResteSurPlace');
BruitImpact:
    //se retourne vers bruit, alarme, cherche safepoint sinon investigation
    ChercheNMIDuRegard();
    FinishRotation();
    CherchePointPourCamper(); //interruption possible vers vavers
    gotostate('investigation');
Paffe:
    //se retourne vers tireur (60d), alarme, cherche safepoint sinon investigation
    ChercheNMIDuRegard();
    FinishRotation();
    CherchePointPourCamper();
    gotostate('investigation');
BruitArme:
    //se retourne vers bruit, alarme, va vers bruit,investigation
    ChercheNMIDuRegard();
    FinishRotation();
    if (Fasttrace(instigator.location-vect(0,0,30),pawn.location-vect(0,0,30)))
    {
        MoveActor.MoveActor=none;
        MovePoint.MovePoint=instigator.location;
        Nextstate='Investigation';
        MovePoint.bTraceable=true;
        gotostate('vavers');
    }
    else if (FindbestPathToward(instigator))
    {
        MovePoint.MovePoint=instigator.location;
        Nextstate='Investigation';
        for (iCompteur=0;iCompteur<16;iCompteur++)
        {
            if (routecache[iCompteur]==none)
                break;
            PointChemin[iCompteur]=routecache[iCompteur];
        }
        NbPointChemin=iCompteur;
        MovePoint.bTraceable=false;
        gotostate('vavers');
    }
    gotostate('investigation');
Vu:
    if (bases.bAlerte)
        goto('attaque');
	 else if (bARienVu)
			goto('Identification');
    enable('enemynotvisible');
PointInterro:
    Interrogation=Spawn(class'interro',self,,bases.location+110*vect(0,0,1));  // INTERRO
    interrogation.SetDrawScale3D(vect(1,0.7,0.7));
    interrogation.setbase(pawn);
    sleep(FMin(2.5,bases.TempsPasVu*Vsize(pawn.location-enemy.location)*0.00025));
	 if (Vsize(pawn.location-enemy.location)>320)
    {
	 	  sleep(FMin(2.5,bases.TempsPasVu*Vsize(pawn.location-enemy.location)*0.00025));
	 }
Identification:
    bAVuQuelquechose=true;
	 if (bARienVu)
	 {
		  enable('enemynotvisible');
		  bARienVu=false;
		  Settimer3(0,false);
	 }
    focus=enemy;
	 if (enemy==xiii) Playercontroller(XIII.controller).MyHud.LocalizedMessage(class'XIIIDialogMessage', 3, none, none, pawn, "?!! ");
    //    pawn.SetAnimStatus('alert');
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
        sleep(fmin(2.5,(Vsize(pawn.location-enemy.location)*bases.TempsIdentification)*0.00025));
		  if (Vsize(pawn.location-enemy.location)>320)
				sleep(fmin(2.5,(Vsize(pawn.location-enemy.location)*bases.TempsIdentification)*0.00025));
    }
	 disable('enemynotvisible');
    bAVuQuelquechose=false;
attaque:
	 bDisableDamageattitudeto=true;
    disable('seeplayer');
    disable('seemonster');
	 disable('hearnoise');
	 pawn.velocity=vect(0,0,0);
	 pawn.acceleration=vect(0,0,0);
    pawn.rotationrate.yaw=46000;
    focus=enemy;
	 genalerte.PoteBeugle(pawn);
	 TriggerEvent('surprise_xiii_apercu', Self, pawn);  //trigger
    if (ChercheTalkiePoint())
	 {
			//log(pawn@"attaque cherche taloijotjt");
    		//vire gun courant
			if (!FBI.Talkie.bTalkieDansLaMain)
			{
				sleep(1);
				pawn.pendingweapon=XIIIWeapon(pawn.FindInventoryType(class'fists'));
   	 		if (Pawn.Weapon!=Pawn.PendingWeapon)
      	  		Pawn.Weapon.PutDown();
    			sleep(0.4);
				//sort talkie
   	 		FBI.PlayTakeTalkie();
    			sleep(0.3); //attente anim
    			FBI.Talkie.AttachToWalkie(pawn,true); //talkie dans la main
    			sleep(0.4);
				bases.ReleaseAnimControl();
			}
			bGoToCallTalkie=true;
    		gotostate('vavers');
	 }
	 else
	{
		//log(pawn@"jai pas de point je tir dans le tas !!!!!!!!!!!!");
		if (FBI.talkie!=none) FBI.talkie.destroy();
		ChangetoBestWeapon();
		sleep(0.04);
		gotostate('attaque');
	}
}

// ----------------------------------------------------------------------
//     Investigation    (enemy!=none)
//
//      Se deplace vers enemy pendnat tempsrecherchenmi
//
// ----------------------------------------------------------------------
state Investigation    //temps d'investigation depend du comportement ???
{
    ignores hearnoise;

	 event SeeDeadPawn(pawn other)
    {
        local basesoldier Soldier;

        Soldier=basesoldier(other);
        if (bases.BNeVoitPascadavre || Soldier==none || Soldier.DrawType == DT_NONE || Soldier.bMonCadavreEstDejaVu || AllianceLevel(Soldier)!=1)
            return;
        instigator=other;
        bCadavreVu=true;
        Soldier.bMonCadavreEstDejaVu=true;
		  gotostate('acquisition','cadavrevu');
        return;
    }
    event enemyacquired()
    {
        Gotostate('Investigation','ContinueUnPeuEtAttaque');
    }


begin:
    if (CHARGE_LES_LOGS) log(pawn@"ETAT Investigation"@enemy);
    if (enemy==none)
    {
        log(pawn@"ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none ** ENEMY==none **");
        //enemy=xiii;
    }

investigation:
    if (fasttrace(enemy.location-vect(0,0,30),pawn.location-vect(0,0,30)))
    {
        //log("je vais directement vers perso");
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
        //log("je prend les points d'investigation");
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
        log(pawn@"trouve pas de ligne d'investigation ni reseau");
        stop;
    }
ChercheSurPlace:
    Focus=enemy;
    sleep(1+frand());
    goto('investigation');
ContinueUnPeuEtAttaque:
    Focus=enemy;
	 pawn.velocity=vect(0,0,0);
	 pawn.acceleration=vect(0,0,0);
	FinishRotation();
    gotostate('acquisition','attaque');
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
singular event bool NotifyBump(actor Other)
    {
        return false;
    }
	 event timer2()
	 {
		  genalerte.PoteBeugle(pawn);
	 }
    event SeeMonster(pawn other)
    {
	}
	event SeeDeadPawn(pawn other)
    {
        local basesoldier soldier;

		soldier=basesoldier(other);

       if (bases.BNeVoitPascadavre || bCadavreVu || bDejaVu || Soldier.DrawType == DT_NONE || soldier==none || soldier.bMonCadavreEstDejaVu || AllianceLevel(Soldier)!=1)
            return;
        bStepNoise=false;
		  bWeaponNoise=false;
        bCadavreVu=true;
        instigator=other;
        enemy=none;
        Soldier.bMonCadavreEstDejaVu=true;
        gotostate('acquisition','CadavreVu');
    }
    event UpdateTactics()
    {
    }
    event enemyacquired()
    {
        if (!bDejaVu)
		  {
				bDejaVu=true;
				//log(pawn@"repasse en attaque   Gotostate('Investigation','ContinueUnPeuEtAttaque');");
        		Gotostate('Investigation','ContinueUnPeuEtAttaque');
			}
    }
    event Trigger(actor Other, pawn EventInstigator)
    {
    }
    function beginstate()
    {
        if (NiveauALerte==0)
        {
            s_decAttente();
            s_incAttaque();
        }
        else if (NiveauALerte==1)
        {
            s_decAlerte();
            s_incAttaque();
        }
        NiveauALerte=2;
		  if (bGoToCallTalkie && moveactor.moveactor!=none && MoveActor.MoveActor.isa('SAFEPOINT'))
		  {
				timer2();
				settimer2(2,true);
				disable('hearnoise');
				disable('seeplayer');
				TriggerEvent('CoursVersAlarme', Self, pawn);  //trigger de debut de course vers alarme
		  }
    }
    function endstate()
    {
		  settimer2(0,false);
    }

    //ca de vavers: cadavre, bruit pas, bruit arme, alarme, pote en fight, pote paffe
begin:
    if (CHARGE_LES_LOGS) log(pawn@"ETAT VaVers"@MoveActor.MoveActor@MovePoint.MovePoint@enemy);
Deplacement:
    if (MoveActor.MoveActor!=none)
    {
        If (MoveActor.bReachable)
            MoveToward(MoveActor.MoveActor,MoveActor.MoveActor);
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
            focalpoint=MovePoint.MovePoint+pawn.location;
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
    if (SAFEPOINT(MoveActor.MoveActor)!=none && SAFEPOINT(MoveActor.MoveActor).baccroupi)
    {
        pawn.shouldcrouch(true);
    }
    Gotostate(nextstate);
ContinueUnPeuEtAttaque:
    Focus=enemy;
    gotostate('acquisition','attaque');
}

// ----------------------------------------------------------------------
// Etat de ResteSurPlace    //revu pour talkie
//
//
// ----------------------------------------------------------------------
state ResteSurPlace
{
    event Seeplayer(pawn other)
    {
  	   if (bGoToCallTalkie)
				return;
			if (enemy==none || !bdejavu)
			{
				if (setenemy(XIII))
                bDejaVu=true;
			}
			else
			{
			  if (enemy!=none && enemy==other)
            	SeeEnemy();
		  }
    }
    event EnemyAcquired()
    {
			if (bGoToCallTalkie)
				return;
        gotostate('acquisition','attaque');
    }
    event SeeDeadPawn(pawn other)
    {
    }
    function Endstate()
    {
		  super.endstate();
        bases.AnimBlendParams(bases.FIRINGCHANNEL+1,0,0,0);
	 }

begin:
    pawn.velocity=vect(0,0,0);
    pawn.acceleration=vect(0,0,0);
    if (CHARGE_LES_LOGS) log(pawn@"ETAT Reste SUr Place");
    if (enemy!=none)
    {
        focus=enemy;
        finishrotation();
    }
	 if (!bGoToCallTalkie && !bCadavreVu)
	 {
       sleep(1+4*frand());
		 gotostate('investigation');
	 }
TalkInTalkie:
	// log(pawn@"TalkInTalkie"@bGoToCallTalkie@FBI);
	 enemy=xiii;
    Pawn.Acceleration = vect(0,0,0);
    Pawn.Velocity = vect(0,0,0);
    focus=none;
	 FBI.PlayCallTalkie();
    sleep(0.4);
	 if (!bCadavreVu)
	 {
			TriggerEvent('alerte_xiii_apercu', Self, pawn);  //trigger
	     sleep(FBI.TempsDegainageTalkie);
	}
	else
	{
		sleep(FBI.TempsDegainageTalkie*0.5);
		disable('Seeplayer');
		sleep(FBI.TempsDegainageTalkie*0.5);
	}
//log(pawn@"temps degainage");
    bases.ReleaseAnimControl();
	 bases.PlayWaiting();
    sleep(0.6);
	 TriggerEvent('XIIIVuFBI', Self, pawn);  //trigger
PutDownTalkie:
	//log(pawn@"PutDownTalkie");
	 Pawn.Acceleration = vect(0,0,0);
    Pawn.Velocity = vect(0,0,0);
	 enemy=XIII;
	 focus=enemy;
    finishrotation();
	 ChangeToBestWeapon();
	 sleep(0.3);
    if (FBI.talkie!=none) FBI.talkie.destroy();
	 gotostate('attaque');
}



// ----------------------------------------------------------------------
//  Chasse         (enemy!=none)
//
//
// ----------------------------------------------------------------------
state Chasse
{
    ignores EnemyNotVisible;

    event EnemyAcquired()
    {
        focus=enemy;
        gotostate('acquisition','attaque');
    }
}



defaultproperties
{
}
