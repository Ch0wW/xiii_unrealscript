//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GenPlongeurs extends GenFRD;

struct InventoryItem  {
	var() class<Inventory> Inventory;
	var() int              Count;
};


//-----------------------------
var() int NbNMIMax;
var() float TimeBetweenGen;
var() int NbNMIGen;
var() int NbNMIActifs;
var() int PV_NMI;
var() vector PointSpawn;
var() bool bGenerationCamouflee; //ne genere que si perso peut pas voir le GENNMI
var() bool bWaitAllDeadToDestroy; // attend que tous les persos generes soient morts
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
var(BaseSoldier) int skill;
var(BaseSoldier) float Temps_Acquisition;
var(BaseSoldier) name Bases_Event;
var(BaseSoldier) name Bases_Tag;
var(Inventory) InventoryItem InitialInventory[8];
var(BaseSoldier) int NumReseauPropre;
var(Alliances) name Alliance;
var(basesoldier) float DistanceAttaque;

// GenNMI
var GenPlongeurs GenEnnemi;


//*------------------------------*
var vector SpawnLocation;
var Plongeur_Usa01 SpawnActor;
var int NbNMIGenere;
var xiiiplayerpawn XIII;
var Xiiigameinfo gameinf;
var int NbNMIPresents;

//_____________________________________________________________________________
event ParseDynamicLoading(LevelInfo MyLI)
{
    local int i;

    Log("ParseDynamicLoading Actor="$self);
    for (i=0; i<8; i++)
    {
		if (InitialInventory[i].Inventory != none )
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
	{
		NbNMIGenere=0;
		gotostate('genese');
	}
	else
	{
		NbNMIGenere=0;
		gotostate('genese','suitegeneration');
	}

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
	event Timer()
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
					if (!bGenerationCamouflee || (!FastTrace(SpawnLocation,XIII.location+ XIII.eyeposition()) || ((XIII.location-SpawnLocation) dot vector(XIII.rotation))>0))
					{

						SpawnActor=spawn(class'Plongeur_Usa01',self,,SpawnLocation);
						if (SpawnActor == none)
						{
							SpawnLocation=self.location+vect(0,0,1)*78-i*90*((-1)**i)*vect(1,1,0);
							SpawnActor=spawn(class'Plongeur_Usa01',self,,SpawnLocation);
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
						//        gameinf.BaseSoldierList.Length=gameinf.BaseSoldierList.Length+1;   //pas mis dans basesoldierlist
						//     gameinf.BaseSoldierList[gameinf.BaseSoldierList.Length-1]=SpawnActor;
						NbNMIGenere++;
						NbNMIPresents++;
						//SpawnActor.PreBeginPlay();
						//SpawnActor.PostBeginPlay();
						if ((SpawnActor.ControllerClass != None) && SpawnActor.Controller == None)
							SpawnActor.Controller = spawn(SpawnActor.ControllerClass);
						if (SpawnActor.Controller != None )
							SpawnActor.Controller.Possess(SpawnActor);
						gameinf.MapInfo.GeneratedPawn(self,spawnactor);
						SpawnActor.GenEnnemi=self;
						// initialisation des variables
						//ai
						instigator=spawnactor;
						SpawnActor.bLOSHearing=bLOSHearing;
						SpawnActor.bSameZoneHearing=bSameZoneHearing;
						SpawnActor.bAdjacentZoneHearing=bAdjacentZoneHearing;
						SpawnActor.bMuffledHearing=bMuffledHearing;
						SpawnActor.bAroundCornerHearing=bAroundCornerHearing;
						SpawnActor.SightRadius=sightradius;
						SpawnActor.HearingThreshold=hearingthreshold;
						SpawnActor.PeripheralVision=PeripheralVision;
						//basesoldier
						for (j=0;j<8;j++)
						{
							SpawnActor.InitialInventory[j].Inventory=InitialInventory[j].Inventory;
							SpawnActor.InitialInventory[j].count=InitialInventory[j].count;
						}
						SpawnActor.Temps_Acquisition=Temps_Acquisition;
						SpawnActor.skill=skill;
						SpawnActor.SetCollisionSize(CollisionRadius, CollisionHeight);
						SpawnActor.DistanceAttaque=DistanceAttaque;
						SpawnActor.NumReseauPropre=NumReseauPropre;
						SpawnActor.event=Bases_event;
						SpawnActor.tag=Bases_Tag;
						SpawnActor.Alliance=Alliance;
						SpawnActor.bBasesGenere=true;
						//assigne PVs
						AssignePV();
						SpawnActor.controller.focalpoint=SpawnActor.location+vector(self.rotation);
						if (Mesh!=none)
						{
							SpawnActor.mesh=mesh;
							//BaseSoldier(SpawnActor).setCollisionSize(collisionradius,collisionheight);
						}
						if (Skins.length>0)
						{
							SpawnActor.Skins[0]=Skins[0];
							//BaseSoldier(SpawnActor).setCollisionSize(collisionradius,collisionheight);
						}
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

begin:
     //log(self$"GENERE BASESOLDIER");
	 sleep(0.04);
	 gameinf=xiiigameinfo(level.game);
	 XIII=XIIIPlayerpawn(gameinf.mapinfo.XIIIpawn);
	 if (XIII==none)
	 {
		 log("********************* ATTENTION LA VARIABLE XIII N'A PAS ETE INITIALISEE");
		 goto('begin');
	 }
suitegeneration:
     timer();
     sleep(0.04);
	 settimer(TimeBetweenGen,true);
}

State PauseGenese
{
}

state AttendMortNMIs
{
	function UnNMIenMoins()
	{
		if (!bWaitAllDeadToDestroy)
		{
			TriggerEvent(Event, Self, none);
			destroy();
		}
		else if (NbNMIPresents<=0)
		{
            TriggerEvent(Event, Self, none);
			destroy();
		}
	}
begin:
	UnNMIenMoins();
}



defaultproperties
{
     NbNMIMax=10
     TimeBetweenGen=4.000000
     NbNMIGen=1
     NbNMIActifs=2
     PV_NMI=100
     PeripheralVision=120.000000
     SightRadius=2000.000000
     HearingThreshold=1500.000000
     Skill=1
     Temps_Acquisition=0.500000
     InitialInventory(0)=(Inventory=Class'XIII.LHarpon',Count=12)
     DistanceAttaque=600.000000
     CollisionRadius=44.000000
     CollisionHeight=30.000000
     bDirectional=True
}
