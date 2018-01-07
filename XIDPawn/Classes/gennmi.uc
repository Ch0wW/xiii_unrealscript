//=============================================================================
// GenNMI.
//=============================================================================
class GenNMI extends GenFRD;

struct InventoryItem  {
	var() class<Inventory> Inventory;
	var() int              Count;
};

struct InitialAllianceInfo  {
	var() Name  AllianceName;
	var() float AllianceLevel;
};
//-----------------------------
var() int NbNMIMax;
var() float TimeBetweenGen;
var() int NbNMIGen;
var() int NbNMIActifs;
var() int PV_NMI;
var() vector PointSpawn;
var() bool bDestroyedAtEndOfGen;// se detruit a la fin de la generation
var() bool bGenerationCamouflee; //ne genere que si perso peut pas voir le GENNMI
var() bool bWaitAllDeadToDestroy; // attend que tous les persos generes soient morts
var() bool bDestroySoldiersWhenDestroyed; //detruit les autres baseoldiers quand il est detruit
var() bool bPasseAttScr_ApresGen; //le perso declenche passe direct en attaquescriptee

//pour se detruire et declencher un event

//-----------------------------

var(AI) float PeripheralVision;
var(AI) float SightRadius;
var(AI) float HearingThreshold;
var(AI) bool     bLOSHearing;
var(AI) bool     bSameZoneHearing;
var(AI) bool     bAdjacentZoneHearing;
var(AI) bool     bMuffledHearing;
var(AI) bool     bAroundCornerHearing;


//-----------------------------
var(Alliances) name Alliance;
var(Inventory) InventoryItem InitialInventory[8];
var(Alliances) InitialAllianceInfo InitialAlliances[4];
var(BaseSoldier) name Bases_Event;
var(BaseSoldier) name Bases_Tag;
var(BaseSoldier) int skill;
var(BaseSoldier) float TempsIdentification;
var(BaseSoldier) name Order;
var(BaseSoldier) float ProbaDeclencheAlarme;
var(BaseSoldier) float PourcErrance;
var(BaseSoldier) float TempsRechercheNMI;
var(BaseSoldier) float Agressivite;
var(BaseSoldier) float TempsVisee;
var(BaseSoldier) int NumReseauPropre;
var(BaseSoldier) int NumReseauAttaque;
var(Basesoldier) float TempsPasVu;
var(basesoldier) float DistanceAttaque;
var(basesoldier) bool bRappliqueSiAlerte;
var(BaseSoldier) bool bAlerte; //permet de dire que le perso est en etat alerte<->declenche par trigger
var(BaseSoldier) int StrategicPointAttraction; // 0 a 100 : proportion d'utilisation des strategicpoints

var(BaseSoldier_Advanced) bool bPasseAttScr_SiDeclenche;
var(BaseSoldier_Advanced) float OffsetTimeBetweenShots; //
var(BaseSoldier_Advanced) float WalkingSpeed;
var(BaseSoldier_Advanced) bool bNeVoitPasCadavre; // detecte un cadavre ou pas
var(BaseSoldier_Advanced) bool bPasDeclenchableParAlarme; //ben heu
var(BaseSoldier_Advanced) bool bMeurtEnTombant; //bah quand on le bute il chute
var(BaseSoldier_Advanced) bool bTirPasLorsReplacement; //En attaque se repositionne sans regarder xiii (ni tirer)
var(baseSoldier_Advanced) WanderingVolume MyWanderingVolume; //volume d'errance
var(BaseSoldier_Advanced) bool bPatrolWithWalkSearchAnim;  // fait sa premiere patrouille en anim de marche suspicieuse
var(BaseSoldier_Advanced) bool bAlerteAmisEnCriant; //crie pour avertir potes
var(BaseSoldier_Advanced) bool bForceSoldierInUniverse; //the basesoldier is in the Universe Zone.
var(baseSoldier_Advanced) Array<MeshAnimation>	SpecificAnimations;
VAR(baseSoldier_Advanced) bool bSpawnInAir; //si personnage genere en l'air


var(Cine_Behavior) Pawn.EGameOver GameOver;    // Do shooting this guy will make pbs ?

var(pawn) bool bDestroyWhenDead;      // i should be destroyed wxhen dead to optimize
var(pawn) float DelayBeforeDestroyWhenDead;
var(pawn) float DistanceBeforeDestroyWhenDead;
var(pawn) bool bCauseEventOnStun;
var(pawn) bool bCanBeGrabbed;         // to allow grab of myself like Corpse/Prisonner
var(pawn) bool bStunnedIfJumpedOn;    // to allow dogs not being stunned by jumping on their head (too easy)


var(sound) string TimbresPossibles;
var(sound) int CodeMesh;
var(Sound) int SoundStepCategory;
var name Numtimbre;





// GenNMI
var GenNMI GenEnnemi;

//*------------------------------*
var vector SpawnLocation;
var basesoldier SpawnActor;
var int NbNMIGenere;
var int NbNMIPresents;


var xiiiplayerpawn XIII;
var Xiiigameinfo gameinf;

//_____________________________________________________________________________
event ParseDynamicLoading(LevelInfo MyLI)
{
    local int i;

    Log("ParseDynamicLoading Actor="$self);
    for (i=0; i<8; i++)
    {
		if ( InitialInventory[i].Inventory != none )
		{
			MyLI.ForcedClasses[MyLI.ForcedClasses.Length] = InitialInventory[i].Inventory;
			(InitialInventory[i].Inventory).Static.StaticParseDynamicLoading(MyLI);
		}
    }
}

//------------------------------------------------
// TRIGGER: Fonction Trigger declenchee par detectionvolume
//------------------------------------------------
function Trigger( actor Other, pawn EventInstigator )
{
	//NbNMIPresents=0;
	if (NbNMIGenere==0)
		gotostate('genese');
	else if (((NbNMIGenere<NbNMIMax) || NbNMIMAX==-1) && NbNMIPresents<NbNMIActifs)
		gotostate('genese','suitegeneration');
}

function UnNMIenMoins()
{
}


//------------------------------------------------
// GENESE
//------------------------------------------------
state() genese
{
	function AssignePV()
	{
		SpawnActor.Health = PV_NMI;
	}

	function Timer()
	{
		local int i,j;
		local bool result;

		if ((NbNMIGenere<NbNMIMax) || (NbNMIMAX==-1))
		{
			for (i=0;i<NbNMIGen;i++)
			{
				if (NbNMIPresents<NbNMIActifs)
				{
					if (PointSpawn!=vect(0,0,0))
						SpawnLocation=PointSpawn;
					else
						SpawnLocation=self.location + vect(0,0,1)*78+ i*90*((-1)**i)*vect(1,1,0);
					result=false;
					if (!bGenerationCamouflee || !FastTrace(SpawnLocation,XIII.location+ XIII.eyeposition()) || ((XIII.location-SpawnLocation) dot vector(XIII.rotation))>0)
					{
						SpawnActor=spawn(class'BaseSoldier',self,,SpawnLocation);
						if (SpawnActor == none)
						{
							SpawnLocation=self.location+vect(0,0,1)*78-i*90*((-1)**i)*vect(1,1,0);
							SpawnActor=spawn(class'BaseSoldier',self,,SpawnLocation);
							if (SpawnActor == none)
							{
								result=false;
								//log(self$"ca merde je peux pas spawner, j'ai pas la place");
							}
							else
								result=true;
						}
						else
						{
							result=true;
						}
					}

					if (result)
					{
						NbNMIGenere++;
						NbNMIPresents++;
						if ((SpawnActor.ControllerClass != None) && SpawnActor.Controller == None)
							SpawnActor.Controller = spawn(SpawnActor.ControllerClass);
						if (SpawnActor.Controller != None )
							SpawnActor.Controller.Possess(SpawnActor);
						gameinf.MapInfo.GeneratedPawn(self,spawnactor);
						gameinf.BaseSoldierList.Length=gameinf.BaseSoldierList.Length+1;
						gameinf.BaseSoldierList[gameinf.BaseSoldierList.Length-1]=SpawnActor;
						instigator=spawnactor;
						SpawnActor.GenEnnemi=self;
						// initialisation des variables
						//ai
                  SpawnActor.GameOver=GameOver;
						SpawnActor.bStunnedIfJumpedOn=bStunnedIfJumpedOn;
						SpawnActor.bCanBeGrabbed=bCanBeGrabbed;
						SpawnActor.bLOSHearing=bLOSHearing;
						SpawnActor.bSameZoneHearing=bSameZoneHearing;
						SpawnActor.bAdjacentZoneHearing=bAdjacentZoneHearing;
						SpawnActor.bMuffledHearing=bMuffledHearing;
						SpawnActor.bAroundCornerHearing=bAroundCornerHearing;
						SpawnActor.SightRadius=sightradius;
						SpawnActor.HearingThreshold=hearingthreshold;
						SpawnActor.PeripheralVision=PeripheralVision;
						SpawnActor.Alliance=Alliance;
						//basesoldier
						for (j=0;j<8;j++)
						{
								SpawnActor.InitialInventory[j].Inventory=InitialInventory[j].Inventory;
								SpawnActor.InitialInventory[j].count=InitialInventory[j].count;
						}
						for (j=0;j<4;j++)
						{
							if (InitialAlliances[j].AllianceName!='')
							{
								SpawnActor.InitialAlliances[j].AllianceName=InitialAlliances[j].AllianceName;
								SpawnActor.InitialAlliances[j].AllianceLevel=InitialAlliances[j].AllianceLevel;
							}
						}
						SpawnActor.TempsIdentification=TempsIdentification;
						SpawnActor.skill=skill;
						SpawnActor.PourcErrance=PourcErrance;
						SpawnActor.WalkingSpeed=WalkingSpeed;
						SpawnActor.bNeVoitPasCadavre=bNeVoitPasCadavre;
						SpawnActor.bPasDeclenchableParAlarme=bPasDeclenchableParAlarme;
						SpawnActor.SetCollisionSize(CollisionRadius, CollisionHeight);
						SpawnActor.TempsRechercheNMI=TempsRechercheNMI;
						SpawnActor.Agressivite=Agressivite;
						SpawnActor.TempsVisee=TempsVisee;
						SpawnActor.DistanceAttaque=DistanceAttaque;
						SpawnActor.bMeurtEnTombant=bMeurtEnTombant;
						SpawnActor.StrategicPointAttraction=StrategicPointAttraction;
						SpawnActor.NumReseauPropre=NumReseauPropre;
						SpawnActor.bAlerte=bAlerte;
						SpawnActor.event=Bases_event;
						SpawnActor.tag=Bases_Tag;
						spawnActor.bcancrouch=true;
						SpawnActor.NumReseauAttaque=NumReseauAttaque;
						SpawnActor.TempsPasVu=TempsPasVu;
						SpawnActor.OffsetTimeBetweenShots=OffsetTimeBetweenShots;
						SpawnActor.ProbaDeclencheAlarme=ProbaDeclencheAlarme;
						SpawnActor.bBasesGenere=true;
						SpawnActor.bSpawnInAir=bSpawnInAir;
						SpawnActor.MyWanderingVolume=MyWanderingVolume;
						SpawnActor.bAlerteAmisEnCriant=bAlerteAmisEnCriant;
						SpawnActor.bRappliqueSiAlerte=bRappliqueSiAlerte;
						SpawnActor.bPasseAttScr_SiDeclenche=bPasseAttScr_SiDeclenche;
						SpawnActor.bPasseAttScr_ApresGen=bPasseAttScr_ApresGen;
						if ( bForceSoldierInUniverse )
						{
							SpawnActor.bForceInUniverse = bForceSoldierInUniverse;
							SpawnActor.RefreshDisplaying();
						}
						if (!bActorShadows && SpawnActor.Shadow != none)
						{
				        SpawnActor.Shadow.Destroy();
					     SpawnActor.Shadow = none;
						}
						SpawnActor.bCauseEventOnStun=bCauseEventOnStun;
						//son
						j=InStr(TimbresPossibles,";");
						if (j>1)
						{
							Switch(byte(mid(TimbresPossibles,rand(j))))
							{
                          case 1 : SpawnActor.NumeroTimbre=timbre_1;  break;
                          case 2 : SpawnActor.NumeroTimbre=timbre_2;  break;
                          case 3 : SpawnActor.NumeroTimbre=timbre_3;  break;
							}
						}
						SpawnActor.bHasPosition=bHasPosition;
						SpawnActor.bHasRollOff=bHasRollOff;
						SpawnActor.PanCoeff=PanCoeff;
						SpawnActor.CodeMesh=CodeMesh;
						SpawnActor.SoundStepCategory=SoundStepCategory;
						SpawnActor.SaturationDistance=SaturationDistance;
	 					SpawnActor.StabilisationDistance=StabilisationDistance;
	 					SpawnActor.StabilisationVolume=StabilisationVolume;
	 					SpawnActor.VoicesSaturationDistance=VoicesSaturationDistance;
	 					SpawnActor.VoicesStabilisationDistance=VoicesStabilisationDistance;
	 					SpawnActor.VoicesStabilisationVolume=VoicesStabilisationVolume;
						//assigne PVs
						AssignePV();
						SpawnActor.controller.focalpoint=SpawnActor.location+vector(self.rotation);
						//BaseSoldier(SpawnActor).setCollisionSize(collisionradius,collisionheight);
						if (Mesh!=none)
						{
							SpawnActor.mesh=mesh;
						}
						if (SpecificAnimations.Length>0)
						{
							for (j=0;j<SpecificAnimations.Length;j++)
								SpawnActor.LinkSkelAnim (SpecificAnimations[j]);
						}
						if (Skins.length>0 && Skins[0]!=none)
						{
							SpawnActor.Skins[0]=Skins[0];

						}
						if (order!='')
						{
							SpawnActor.order=order;
						}
						SpawnActor.bDestroyWhenDead=bDestroyWhenDead;
						SpawnActor.DelayBeforeDestroyWhenDead=DelayBeforeDestroyWhenDead;
						SpawnActor.DistanceBeforeDestroyWhenDead=DistanceBeforeDestroyWhenDead;
					}
            }
            else
            {
                settimer(0,false);
                gotostate('PauseGenese');
                break;
            }
        }
     }
     else
     {
         gotostate('AttendMortNMIs');
     }
  }

  function endstate()
  {
  }

begin:
  //log(self$"GENERE BASESOLDIER");
  sleep(0.04);
  gameinf=xiiigameinfo(level.game);
  XIII=XIIIPlayerpawn(gameinf.mapinfo.XIIIpawn);
  if (XIII==none)
  {
	  log(self@"********************* ATTENTION LA VARIABLE XIII N'A PAS ETE INITIALISEE");
	  goto('begin');
  }
suitegeneration:
  timer();
  sleep(0.04);
  settimer(TimeBetweenGen,true);
}

state AttendMortNMIs
{
	function UnNMIenMoins()
	{
		if (!bWaitAllDeadToDestroy)
		{
			if (bDestroyedAtEndOfGen)
				destroy();
		}
		else if (NbNMIPresents<=0)
		{
            destroy();
		}
	}
begin:
	UnNMIenMoins();
}

State PauseGenese
{
}

event Destroyed()
{
    local int index;
	local int i;
	local pawn PersoAVirer;
	local IACOntroller PersoAVirerController;

	TriggerEvent(Event, Self, none);
    if (!bDestroySoldiersWhenDestroyed)
		return;
	//vire perso de la BaseSoldierList et le detruit
    for (Index = 0; Index < level.game.BaseSoldierList.Length; Index++)
    {
		if (basesoldier(level.game.BaseSoldierList[Index]).GenEnnemi == self )
		{
			PersoAVirer=level.game.BaseSoldierList[Index];
			PersoAVirerController=IACOntroller(PersoAVirer.controller);
			If (PersoAVirerController==none || PersoAVirerController.XIII==none)
				continue;
			for (i = 0; i < gameinf.BaseSoldierList.Length; i++)
			{
				if (gameinf.BaseSoldierList[i] == PersoAVirer )
				{
					gameinf.BaseSoldierList.Remove(i,1);
					break;
				}
			}
			if (!PersoAVirerController.XIII.Controller.CanSee(PersoAVirer)
          && (PersoAVirer!= PersoAVirerController.XIII.LHand.pOnShoulder ) )
				PersoAVirer.destroy();
		}
    }
}

//		InitialInventory(0)=(Inventory=Class'XIII.Beretta',Count=1)


defaultproperties
{
     NbNMIMax=10
     TimeBetweenGen=4.000000
     NbNMIGen=1
     NbNMIActifs=2
     PV_NMI=150
     bPasseAttScr_ApresGen=True
     PeripheralVision=120.000000
     SightRadius=2000.000000
     HearingThreshold=1500.000000
     Alliance="NMI"
     InitialAlliances(0)=(AllianceName="Player",AllianceLevel=-1.000000)
     InitialAlliances(1)=(AllianceName="NMI",AllianceLevel=1.000000)
     Skill=1
     TempsIdentification=2.000000
     TempsRechercheNMI=3.000000
     Agressivite=0.300000
     TempsVisee=1.000000
     DistanceAttaque=600.000000
     bRappliqueSiAlerte=True
     StrategicPointAttraction=100
     OffsetTimeBetweenShots=0.250000
     WalkingSpeed=0.300000
     bAlerteAmisEnCriant=True
     bCanBeGrabbed=True
     TimbresPossibles="123;"
     bActorShadows=True
     CollisionRadius=34.000000
     CollisionHeight=78.000000
     bDirectional=True
}
