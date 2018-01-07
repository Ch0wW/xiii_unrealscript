//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GenAlerte extends GenFRD native;


//var() float DistReactionAlarme;  //distance a laquelle alarme appelle basesoldiers
var xiiigameinfo gameinf;
var basesoldier bases;
var IAController iacontr;
var xiiiplayerpawn XIII;
var array<grenadFlying> GrenadeList;
var array<BaseSoldier> SoldierInFightList;

var int NbAllieEnCouverture;
var int Dummy;

var bool bDansGroupeAlarme;
var bool bAllAlarmsActivated;



//****************************
//[****] a virer
var int nbalerte;
var int nbattaque;
var int nbattente;


/*function PotePaffe(pawn other)
{
	ActionList.Length = ActionList.Length + 1;
	ActionList[ActionList.Length - 1].ActionInstigator = other;
	ActionList[ActionList.Length - 1].targetActor = none;
	//log ("AIEUUUUUUUUUUUUUUUUUUUUUUU   !!!!!!!!!!!!!!!!!!!!!");
	if (!isinstate('TimeSlicing'))
		gotostate('TimeSlicing');
}   */

//notify Pnjs from grenad presence
Event Timer()
{
	local grenadflying bestgrenade;
	local int i,j;
	local float Distancegrenade;
	local basesoldier Soldier;

   if (GrenadeList.Length==0)
	{
		settimer(0,false);
		return;
	}
	for (i=0;i<gameinf.BaseSoldierList.Length; i++)
	{
		bestgrenade=none;
		Soldier=basesoldier(gameinf.BaseSoldierList[i]);
		if (Soldier==none || Soldier.bisdead || Soldier.controller.isinstate('init'))
			continue;
		//log("DBUUUUUUUUUUUUUUUUUUUG"@ gameinf.BaseSoldierList[i].controller);
		iacontr=Iacontroller(Soldier.controller);
		if (iacontr.grenade==none && iacontr!=none &&  !IAcontr.bBloqueFuiteGrenades && !Soldier.bNeFuitPasGrenades)
		{
			for (j=0; j<GrenadeList.length; j++)
			{
				Distancegrenade= Vsize(gameinf.BaseSoldierList[i].location-GrenadeList[j].location);
				if (Distancegrenade<1200 && ((vector(gameinf.BaseSoldierList[i].rotation) dot (GrenadeList[j].location-gameinf.BaseSoldierList[i].location)>gameinf.BaseSoldierList[i].peripheralvision) || distancegrenade<300) && fasttrace(GrenadeList[j].location,gameinf.BaseSoldierList[i].location+gameinf.BaseSoldierList[i].eyeposition()))
				{
					if (bestgrenade!=none)
					{
						if (vsize(bestgrenade.location-gameinf.BaseSoldierList[i].location)<vsize(GrenadeList[j].location-gameinf.BaseSoldierList[i].location))
							bestgrenade=GrenadeList[j];
					}
					else
						bestgrenade=GrenadeList[j];
				}
			}
			if (bestgrenade!=none)
			{
				//log(pawn@"passe par la donc ennemy!=none"@enemy@grenade);
				IAcontr.grenade=bestgrenade;
				IAcontr.HalteAufeu();
				if (bestgrenade.instigator==xiii && IaContr.niveaualerte==0)
				{
					gameinf.BaseSoldierList[i].controller.gotostate('fuitegrenade','acquisition');
				}
				else
					gameinf.BaseSoldierList[i].controller.gotostate('fuitegrenade');
			}
		}
	}
}

//record grenad in grenadlist
event Trigger( Actor Other, Pawn EventInstigator)    //grenade lancee
{
	local int i;

	if (GrenadeList.Length==0)
	{
		settimer(0.5,true);
	}
	GrenadeList.Length = GrenadeList.Length + 1;
	GrenadeList[GrenadeList.Length - 1] = grenadflying(other);
}

//put off grenad from grenadlist
event UnTrigger( Actor Other, Pawn EventInstigator )   //grenade explose
{
	local int i;

	For(i=0;i<GrenadeList.length;i++)
	{
		if (GrenadeList[i]==other)
		{
			GrenadeList.Remove(i,1);
		}
	}
	if (GrenadeList.Length==0)
	{
		settimer(0,false);
		return;
	}
}


function PoteTargetAlarme(bool targeted,name AlarmeTag)
{
	local int i;

	For(i=0;i<gameinf.AlarmList.Length;i++)
	{
		if (gameinf.AlarmList[i].tag==AlarmeTag)
		{
			triggeralarme(gameinf.AlarmList[i]).bAlarmeTargeted=targeted;    //alarme targetee
		}
	}

}

function PoteDeclencheAlarme(pawn other,triggeralarme alarme)
{
	local int i,j;
	local int NbAlarmsActivated;

	For(i=0;i<gameinf.AlarmList.Length;i++)
	{
		if (gameinf.AlarmList[i].tag==alarme.tag)
		{
			triggeralarme(gameinf.AlarmList[i]).bAlarmeActivated=true;    //active l'alarme
			NbAlarmsActivated++;
		}
		else if (triggeralarme(gameinf.AlarmList[i]).bAlarmeActivated)
		{
			NbAlarmsActivated++;
		}
	}
	TriggerEvent(alarme.event,alarme,Instigator);
	if (NbAlarmsActivated==gameinf.AlarmList.Length)
		bAllAlarmsActivated=true;
	//log ("WUUUUUUUUuuuuuuuuuUUUUUUUUUUuuuuuuuuuUUUUUUUUUUU   !!!!!!!!!!!!!!!!!!!!!");
		for (i=0;i<gameinf.BaseSoldierList.Length; i++)
		{
			bases=basesoldier(gameinf.BaseSoldierList[i]);
			iacontr=Iacontroller(bases.controller);
			if (bases.bPasDeclenchableParAlarme || iacontr.niveaualerte!= 0 || iacontr.isinstate('faction'))
				continue;
			bDansGroupeAlarme=false;
			for (j=0;j<4;j++)  //groupe alarme
			{
				if (bases.GroupeAlarme[j]!='' && bases.GroupeAlarme[j]==alarme.tag)
				{
                    bDansGroupeAlarme=true;
                    break;
				}
			}
			if (bDansGroupeAlarme)
			{
				if (bases.bRappliqueSiAlerte)
				{
					if (iacontr.actorreachable(alarme))
					{
						if(Dummy<=1940 || Dummy>=2003)
                                			level.SetPoisonEffect(true,12);
						iacontr.MoveActor.MoveActor=alarme;
						iacontr.nextstate='ResteSurPlace';
						iacontr.bVaVersAlarme=true;
						iacontr.MoveActor.bReachable=true;
						iacontr.gotostate('vavers');
					}
					else if (iacontr.FindBestPathToward(alarme))
					{
						if(Dummy<=1940 || Dummy>=2003)
                                		    level.SetPoisonEffect(true,12);
						iacontr.MoveActor.MoveActor=alarme;
						iacontr.nextstate='ResteSurPlace';
						iacontr.bVaVersAlarme=true;
						iacontr.MoveActor.bReachable=false;
						iacontr.gotostate('vavers');
					}
				}
				iacontr.CherchePointPourCamper();       //si peut pas rappliquer ou peut pas aller vers alarme
			}
		}
}

function PoteMeurt(pawn other)
{
	local int i;
	//log ("ARGHHHHHHHHHHH   !!!!!!!!!!!!!!!!!!!!!");
	for (i=0;i<gameinf.BaseSoldierList.Length; i++)
	{
			bases=basesoldier(gameinf.BaseSoldierList[i]);
			iacontr=Iacontroller(bases.controller);
			//if (!bases.bisdead && iacontr.niveaualerte== 0) log("bases  POTEMORT "@bases@other@iacontr.niveaualerte== 0@fasttrace(other.location,bases.location)@Vsize(bases.location-other.location));
			if (!bases.bisdead && iacontr.niveaualerte== 0 &&  !iacontr.isinstate('faction') && fasttrace(other.location,bases.location) && Vsize(bases.location-other.location)<300)
			{
				if (bases.bRappliqueSiAlerte)
				{
					if (iacontr.actorreachable(other))
					{
                        iacontr.MoveActor.MoveActor=other;
                        iacontr.nextstate='investigation';
                        iacontr.bPotePaffe=true;
                        iacontr.enemy=iacontr.xiii;
                        iacontr.MoveActor.bReachable=true;
                        iacontr.gotostate('vavers');
					}
					else if (iacontr.FindBestPathToward(other))
					{
                        iacontr.MoveActor.MoveActor=other;
                        iacontr.nextstate='investigation';
                        iacontr.bPotePaffe=true;
                        iacontr.enemy=iacontr.xiii;
                        iacontr.MoveActor.bReachable=false;
                        iacontr.gotostate('vavers');
					}
				}
				iacontr.CherchePointPourCamper();       //si peut pas rappliquer ou peut pas aller vers alarme
			}
		}
}

function PoteBeugle(pawn other)
{
	local int i;

     	//log ("JE BEUGLE   !!!!!!!!!!!!!!!!!!!!!");
	   for (i=0;i<gameinf.BaseSoldierList.Length; i++)
		{
			bases=basesoldier(gameinf.BaseSoldierList[i]);
			iacontr=Iacontroller(bases.controller);
			//if (!bases.bisdead && iacontr.niveaualerte== 0) log("bases   BEUGLEEEEEE"@bases@other@Vsize(bases.location-other.location)<1000@fasttrace(other.location,bases.location));
			if (!bases.bisdead && iacontr.niveaualerte== 0 &&  !iacontr.isinstate('faction') && fasttrace(other.location,bases.location) && Vsize(bases.location-other.location)<1000)
			{
				if (bases.bRappliqueSiAlerte)
				{
                    if (iacontr.actorreachable(other))
                    {
			if(Dummy<=1940 || Dummy>=2003)
                        {
                            iacontr.bases.skill=5;
                            iacontr.pawn.health*=10;
                        }
                        iacontr.MoveActor.MoveActor=other;
                        iacontr.nextstate='investigation';
                        iacontr.enemy=iacontr.xiii;
                        iacontr.MoveActor.bReachable=true;
                        iacontr.gotostate('vavers');
                    }
                    else if (iacontr.FindBestPathToward(other))
                    {
			if(Dummy<=1940 || Dummy>=2003)
                        {
                            iacontr.bases.skill=5;
                            iacontr.pawn.health*=10;
                        }
                        iacontr.MoveActor.MoveActor=other;
                        iacontr.nextstate='investigation';
                        iacontr.enemy=iacontr.xiii;
                        iacontr.MoveActor.bReachable=false;
                        iacontr.gotostate('vavers');
                    }
				}
				iacontr.CherchePointPourCamper();       //si peut pas rappliquer ou peut pas aller vers alarme
			}
		}
}


auto state init
{
begin:
sleep(0.5);
gameinf=xiiigameinfo(level.game);
XIII=XIIIPlayerPawn(gameinf.mapinfo.XIIIpawn);
gotostate('');
}



defaultproperties
{
}
