//=============================================================================
// BaseSoldier.
//=============================================================================
class BaseSoldier extends XIIIPawn native;
#exec OBJ LOAD FILE=XIIISound.uax PACKAGE=XIIISound
#exec OBJ LOAD FILE="Onomatopees.uax" PACKAGE=Onomatopees

//----------------------------------------------------
//STRUCTURES
struct InventoryItem  {
	var() class<Inventory> Inventory;
	var() int              Count;
};

struct InitialAllianceInfo  {
	var() Name  AllianceName;
	var() float AllianceLevel;
};

//----------------------------------------------------
//VARIABLES
var(Inventory) InventoryItem InitialInventory[8];  // inventaire par defaut du pawn
var(Alliances) InitialAllianceInfo InitialAlliances[4]; //alliances du pawn

var(baseSoldier) name Order; // nom de l'etat de depart
var(baseSoldier) float PourcErrance; //Pourcentage d'errance par rapport a la patrouille.
//----------------------
// Reactions aux ennemis
//----------------------
var(BaseSoldier) float TempsRechercheNMI; //temps avant de reprende activite lorsque a cru voir quelque chose
var(BaseSoldier) float Agressivite;  //agressivite -1 a 1
var(BaseSoldier) float TempsIdentification;  //Temps d'identification (en s) max quand NMI au max                                                   de vision
var(BaseSoldier) float DistanceAttaque; //distance d'attaque (defaut a 600)
var(BaseSoldier) float TempsVisee; //Temps de visee avant tir
var(BaseSoldier) int StrategicPointAttraction; // 0 a 100 : proportion d'utilisation des strategicpoints
var(BaseSoldier) int ProbaDeclencheAlarme; // probabilite de declencher l'alarme la plus proche
var(baseSoldier) int NumReseauPropre; // num du reseau propre
var(BaseSoldier) int NumReseauAttaque; // num du reseau d'attaque
var(BaseSoldier) float TempsPasVu; //temps ou l'ennemi a rien vu et on peut se recacher (valeur pour la distance de vision)
var(BaseSoldier) bool bAlerte; //permet de dire que le perso est en etat alerte<->declenche par trigger
var(BaseSoldier) bool bRappliqueSiAlerte; //si entend alarme rapplique ou se plaqnue

var(BaseSoldier_Advanced) bool bPasseAttScr_SiDeclenche; //le perso declenche passe direct en attaquescriptee
var(BaseSoldier_Advanced) float OffsetTimeBetweenShots; //
var(BaseSoldier_Advanced) bool bPasDeclenchableParAlarme; //
var(BaseSoldier_Advanced) bool bNeVoitPasCadavre; // detecte un cadavre ou pas
var(BaseSoldier_Advanced) bool bMeurtEnTombant; //bah quand on le bute il chute
var(BaseSoldier_Advanced) bool bAlerteAmisEnCriant; //crie pour avertir potes
var(BaseSoldier_Advanced) float WalkingSpeed;       // tag of object referred to byorders
var(BaseSoldier_Advanced) bool bPatrolWithWalkSearchAnim;  // fait sa premiere patrouille en anim de marche suspicieuse
var(baseSoldier_Advanced) WanderingVolume MyWanderingVolume; //volume d'errance
VAR(baseSoldier_Advanced) Array<MeshAnimation>	SpecificAnimations;
VAR(baseSoldier_Advanced) bool bFouilleCadavres;
VAR(baseSoldier_Advanced) bool bNeFuitPasGrenades;


var (GroupeAlarme) name GroupeAlarme[4]; //par quel groupe d'alarme le perso est affecte
var (Cine_Vars) bool bTurnIntoAgressiveSoldier;
var(sound) bool bDontCallFriends; //dont call allies if he is alone assault
var(sound) enum NumTimbre
{
	Timbre_1,
        Timbre_2,
        Timbre_3
} NumeroTimbre;
var(sound) int CodeMesh;

var bool bDejaFouille; //pour avertir que ce cadavre a deja ete fouille
var bool bJetombe;
Var bool bBasesGenere;
var bool bControleChute;
var bool bDetecteBloquage; //dans bump pour delcelcher attente si bloque
var bool bSlave; //dans bump pour ne recaler qu'un perso
var bool bMonCadavreEstDejaVu;
var bool bJOuvreLaBouche;  //etat du ouahouah pour sequencer les ouvertures de bouche
var bool bBlockNextOuahOuah;
var bool bPasseAttScr_ApresGen; //initialisee par gennmi
VAR bool bSpawnInAir; //si personnage genere en l'air


var int iOuahOuah; //etat du ouahouah = 0 eteint =1 en timing et =2 en cours

var float ScaleOuahOuah;  //facteur de scale du ouahouah sur les levres
var float AlphaRotation; //facteur alapha sur rotation entre les levres du ouahouah
var float TimerBeforeStop; //timer du ouahouah qui determine fin
var float DistanceBord;//distance entre perso et bord=multiple 0.5 de distancemax (Cf.testchute)
var float Timer_PoteMeBloque;

var vector Vect_Position;

var name TypeDommage;

var GenNMI GenEnnemi;
var CrashPoint PointCrash;
var BaseSoldier LeBloqueur;
var emitter OnoChute;

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

native function vector EyePosition();
event OnoStartNotif() //perso a recu notification de son pour jouer ouahouah
{
	if (bBlockNextOuahOuah)
	{
		bBlockNextOuahOuah=false;
		return;
	}
	TimerBeforeStop=level.timeseconds;
	iOuahOuah=1;
	ScaleOuahOuah=1;
	AlphaRotation=0;
	bJOuvreLaBouche=true;
}

function AmplitudeOuahOuah(float dt)
{
	if (bJOuvreLaBouche && AlphaRotation>=1)
	{
		bJOuvreLaBouche=false;
		ScaleOuahOuah=0.2;
	}
	else if (!bJOuvreLaBouche && AlphaRotation<0.1)
	{
		bJOuvreLaBouche=true;
		ScaleOuahOuah=1;
	}
	if (bJOuvreLaBouche)
	{
		ScaleOuahOuah-=3.5*dt;
		AlphaRotation+=4*dt;
		// 		log("j'ouvre la bouche"@scaleouahouah@alpharotation);
	}
	else
	{

		ScaleOuahOuah+=4.5*dt;
		AlphaRotation-=5*dt;
		//       	log("je ferme la bouche"@scaleouahouah@alpharotation);
	}
}



event Tick (float delta)
{
	super.tick(delta);

	if (iOuahOuah>0)
	{
		if ((level.timeseconds-TimerBeforeStop)<0.8)
		{
			self.SetBoneScalePerAxis( 0, fclamp(ScaleOuahOuah*1.2,0,1),,,'X LIPS');
			self.SetBoneRotation('X JAW', -5000* rot( 0, 0, 1 ),,fclamp(AlphaRotation*0.3,0,1));
			AmplitudeOuahOuah(delta);
		}
		else
		{
			//log(self@"play fermre");
			self.SetBoneRotation('X JAW', rot( 0, 0, 0 ), , 0);
			self.SetBoneScalePerAxis( 0, 1,,,'X LIPS');
			iOuahOuah=0;
		}
	}
}
//gestion des collisions entre basesoldiers
event bump(actor other)
{
	local Iacontroller IaContr;
	local basesoldier OtherSoldier;

	if (XIIIPAwn(other)==none)
		return;

	IACOntr=IACOntroller(COntroller);
	if (IACOntr!=none && IACOntr.XIII==other && IACOntr.NiveauAlerte==2 && IACOntr.AllianceLevel(IACOntr.XIII)<0 && !IACOntr.bAlarmeInstigator && (IACOntr.IsInState('VaVers') || IACOntr.IsInState('OuvrePorte')))
	{
		IACOntr.GotoState('attaque');
		return;
	}
	if (XIIIPAwn(other).controller!=none && !XIIIPAwn(other).controller.isa('iacontroller') || bSlave)
		return;

	if (!bDetecteBloquage && ((velocity dot vector(rotation))>(other.velocity dot vector(other.rotation)))) //Je me déplace
	{
		OtherSoldier=basesoldier(other);
		//log(self@"bPoteMeBloque"@other@(level.timeseconds-Timer_PoteMeBloque));
		if (!OtherSoldier.bSlave)
		{
			Timer_PoteMeBloque=level.timeseconds;
			if (OtherSoldier.controller.isinstate('ouvrePorte'))
			{
				 LeBloqueur=self;
				 bslave=true;
			}
			else if ((Vsize(velocity)<100 && Vsize(other.velocity)>100)) //il se deplace mais pas moi
			{
				 LeBloqueur=self;
				 bslave=true;
			}
			else
			{
				LeBloqueur=OtherSoldier;
				LeBloqueur.bSlave=true;
			}
		}
		else if ((level.timeseconds-Timer_PoteMeBloque)>0.2 && other==Lebloqueur)
		{
			IaContr=Iacontroller(controller);
			bDetecteBloquage=true;
			IaContr.PoteQuiMeBloque=LeBloqueur;
			IaContr.PoteQuiMeBloquePos=LeBloqueur.location;
			IAContr.HalteAufeu();
			Iacontr.prevstate=controller.getstatename();
			controller.gotostate('restesurplace','PoteMeBLoque');
		}
	}
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    local DamageLocations Loc;

    Loc = GetDamageLocation( HitLocation, Location - instigatedBy.Location );

    if (Loc != LOC_Head)
        Damage *= (1 + ( 1-Level.Game.Difficulty) *0.25 );

   Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}


// ----------------------------- ANIMS ---------------------
function TakeAnimControl(bool bMoveAnim)
{
	bMoving=bMoveAnim;
	bPhysicsanimupdate=false;
	bSpineControl=false;
	if (controller!=none)
		controller.bControlanimations=true;
	SetBoneDirection(FIRINGBLENDBONE, rot(0,0,0), vect(0,0,0), 0.0 );
}
function ReleaseAnimControl(optional bool bFastTransition)
{
	if (Controller != none) controller.bControlanimations=false;
	bSpineControl=true;
	bPhysicsanimupdate=true;
	PlayWaiting();
   if (bFastTransition)
		AnimBlendToAlpha(FIRINGCHANNEL+1,0,0.2);
	else
		AnimBlendToAlpha(FIRINGCHANNEL+1,0,0.6);
}

event AnimEnd(int Channel)
{
    //Log("@@ AnimEnd w/channel="$Channel$" call for "$self);

    if ( (Controller != none) && Controller.bControlAnimations )
    {
		//Log("@@ AnimEnd w/channel="@Controller.bControlAnimations);
		if (channel!=FIRINGCHANNEL+1)
 		   AnimBlendToAlpha(Channel,0,0.4);
      return;
    }
	 if (channel==FIRINGCHANNEL+1) //no more control
	 {
        //log("release control");
		  ReleaseAnimControl();
		  return;
	 }
    if ( Channel == FIRINGCHANNEL )
    {
      bRndAnimM16 = true;

      // FIRINGCHANNEL used for upper body (firing weapons, etc.)

      if ( Role < ROLE_Authority )
      {
        PlayWaiting();
        PlayMoving();
      }
      if ( bReloadingWeapon || !bChangingWeapon )
      {
        AnimBlendToAlpha(FIRINGCHANNEL,0,0.2);
      }
      else
      {
        if ( bChangingWeapon )
        {
          Switch(WeaponMode)
          {
            Case 'FM_Bazook':
            Case 'FM_BazookAlt':
            Case 'FM_2H':
            Case 'FM_M16':
            Case 'FM_ShotGunAlt':
            Case 'FM_HarpoonAlt':
              PlayAnim('SearchGun',,0.15,FIRINGCHANNEL); break;
            Case 'FM_2HHeavy':
              PlayAnim('SearchGatling',,0.15,FIRINGCHANNEL); break;
            Default:
              PlayAnim('SearchPistol',,0.15,FIRINGCHANNEL); Break;
          }
          bReloadingWeapon=false;
        }
        else
        {
          if ( !bMoving )
            PlayWaiting();
          else
            PlayMoving();
        }
      }
    }
    else
    {
      if ( !bMoving )
        PlayWaiting();
      else
        PlayMoving();
    }
}
function PlayQuickLookAround()
{
	TakeAnimControl(false);
   loopAnim('devantcorps',,0.2,FIRINGCHANNEL+1);
	AnimBlendToAlpha(FIRINGCHANNEL+1,1,0.2);
}

function PlayJumpInAir()
{
	TakeAnimControl(false);
	if (weapon.inventorygroup>=8 && weapon.inventorygroup<=12)
	   PlayAnim('jumpGunD',,0.05,FIRINGCHANNEL+1);
	else
		PlayAnim('jumpPistolD',,0.05,FIRINGCHANNEL+1);
	AnimBlendToAlpha(FIRINGCHANNEL+1,1,0.05);
}
function PlayJumpInFlight()
{
	if (weapon.inventorygroup>=8 && weapon.inventorygroup<=12)
   	loopAnim('jumpGunC',,0.1,FIRINGCHANNEL+1);
	else
		loopAnim('jumpPistolC',,0.1,FIRINGCHANNEL+1);
}
function PlayJumpLanding()
{
	if (weapon.inventorygroup>=8 && weapon.inventorygroup<=12)
   	playAnim('jumpGunF',,0.05,FIRINGCHANNEL+1);
	else
		playAnim('jumpPistolF',,0.05,FIRINGCHANNEL+1);
}

function PlaySearchGround()
{
	TakeAnimControl(false);
   PlayAnim('SearchGround',,0.2,FIRINGCHANNEL+1);
	AnimBlendToAlpha(FIRINGCHANNEL+1,1,0.4);
}
function PlayWaitGrenade()
{
	TakeAnimControl(false);
   PlayAnim('attentegrenade',,0.2,FIRINGCHANNEL+1);
	AnimBlendToAlpha(FIRINGCHANNEL+1,1,0.4);
}
Function PlayH2HProvoc ()
{
	TakeAnimControl(false);
    PlayAnim('MigBoxeProvoc',1,0.2,FIRINGCHANNEL+1);
	AnimBlendToAlpha(FIRINGCHANNEL+1,1,0.4);
}
function PlayManip()
{
	TakeAnimControl(false);
    PlayAnim('alarm',1,0.2,FIRINGCHANNEL+1);
	AnimBlendToAlpha(FIRINGCHANNEL+1,1,0.4);
}
function PlayStartToFall()
{
	PlayAnim('DeathDos',,0.3,FIRINGCHANNEL+2);
   AnimBlendToAlpha(FIRINGCHANNEL+2,1,0.3);
}
function PlayFallingFalaise()
{
	loopanim('DeathFalaiseC',,0.4,FIRINGCHANNEL+2);
}
function PlayCrashOnGround()
{
	playanim('deathfalaisefin',,0.10,FIRINGCHANNEL+2);
}

function PlayRoulade()
{
	//AnimBlendParams(FIRINGCHANNEL+3,0,0,0,'X')
	TakeAnimControl(false);
	if (normal(controller.focalpoint-location) dot normal(vector(rotation) cross vect(0,0,1)) >0)
		playanim('rouladeg',0.75,,FiringChannel+1);
	else
		playanim('rouladed',0.75,,FiringChannel+1);
	AnimBlendToAlpha(FIRINGCHANNEL+1,1,0.4);
}
//_____________________________________________________________________________
event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    if ( bDBAnim ) Log("--@ PlayDying call for "$self@"HitLocCode="$HitLoc);

    bPlayedDeath = true;
    if ( bPhysicsAnimUpdate )
    {
		bTearOff = true;
		bReplicateMovement = false;
    }
	//    Velocity += TearOffMomentum;
    SetPhysics(PHYS_Falling);

    AnimBlendToAlpha(FIRINGCHANNEL,0,0.1);

    if (!bJeTombe)
		PlayDyingAnim(DamageType,HitLoc);
    GotoState('Dying');
}

function PlayOpenDoor()
{
    //if ( bDBAnim ) Log("--@ PlayOpenDoor call for "$self);
	 TakeAnimControl(false);
    PlayAnim('OpenDoor',2,,FIRINGCHANNEL+1);
	 AnimBlendToAlpha(FIRINGCHANNEL+1,1,0.4);
}


/*simulated function AnimateWalking()
{
super.AnimateWalking();

  if (Iacontroller(self.controller).niveaualerte<2)
  {
  MovementAnims[1] = 'RotationG';
  MovementAnims[3] = 'RotationD';
  }
  }

	simulated function AnimateRunning()
	{
    super.AnimateRunning();

	  if (Iacontroller(self.controller).niveaualerte<2)
	  {
	  MovementAnims[1] = 'RotationG';
	  MovementAnims[3] = 'RotationD';
	  }
}*/


EVENT PostBeginPlay()
{
	LOCAL int i;

	Super.PostBeginPlay();

	if (SpecificAnimations.Length>0)   //fait dans gennmi pour les persos generes
	{
		for (i=0;i<SpecificAnimations.Length;++i)
		{
			LinkSkelAnim (SpecificAnimations[i]);
		}
	}
}


//---------------------------------------------------------------------------------
//Inventaire par defaut appele par initialize pawn dans le controller
//----------------------------------------------------------------------------------
function InitializeInventory()
{
    local int       i, j;
    local Inventory inv;
    local ammunition AmmoTmp;

    //initialise poings
    inv = spawn(class'Fists', self);
    if (inv != None)
    {
		inv.gotostate('');
		inv.GiveTo(Self);
    }

    // Add initial inventory items
    for (i=0; i<8; i++)
    {
		if ( InitialInventory[i].Inventory != None )
		{
			inv = spawn(InitialInventory[i].Inventory);
			if ( Weapon(inv) != none )
			{
				Inv.GiveTo(self);
				// Add clips
				AmmoTmp = Weapon(Inv).AmmoType;
				if ( class<Ammo>(AmmoTmp.PickupClass) != none )
					AmmoTmp.AmmoAmount += InitialInventory[i].count * class<Ammo>(AmmoTmp.PickupClass).Default.AmmoAmount;
				else
					AmmoTmp.AmmoAmount = InitialInventory[i].count;
			}
			else if ( Ammunition(Inv) != none )
			{
				AmmoTmp = ammunition(FindInventoryType(Inv.Class));
				if ( AmmoTmp == none )
				{
					Inv.GiveTo(self);
					if ( class<Ammo>(Inv.PickupClass) != none )
						Ammunition(Inv).AmmoAmount += InitialInventory[i].count * class<Ammo>(Inv.PickupClass).Default.AmmoAmount;
					else
						Ammunition(Inv).AmmoAmount = InitialInventory[i].count;
				}
				else
				{
					if ( class<Ammo>(Inv.PickupClass) != none )
						AmmoTmp.ammoAmount += InitialInventory[i].count * class<Ammo>(Inv.PickupClass).Default.AmmoAmount;
					else
						Ammunition(Inv).AmmoAmount = InitialInventory[i].count;
					Inv.Destroy();
				}
			}
			else if ( Casque(Inv) != none )
			{
				Inv.GiveTo(self);
				Inv.Charge = 40;
				// No special treatment
			}
			else
			{
				Inv.GiveTo(self);
				// No special treatment
			}
		}
    }
}


//_____________________________________________________________________________
// FRD a partir de ELR
function Died(Controller Killer, class<DamageType> damageType, vector HitLocCode)
{
    local int i;
    local xiiigameinfo gameinf;
	 local IACOntroller IaContr;

	IAContr=IaController(controller);

	if (IAContr==none)
	{
		if ( class<XIIIDamageType>(damageType).default.bDieInSilencePlease )
			PlaySndDeathOno(deathono'Onomatopees.hPNJDeath2',CodeMesh,NumeroTimbre);
		else
			//PlaySndDeathOno(deathono'Onomatopees.hPNJDeath1',CodeMesh,NumeroTimbre)
            ;

		Super.Died( Killer, damageType, HitLocCode);
		return;
	}
    //supression de la basesoldierlist pour les persos non generes
	 ReleaseAnimControl();
    gameinf=xiiigameinfo(level.game);
	if (bBasesGenere && GenEnnemi!=none)
	{
		bBasesGenere=false;   //pour ne pas le ressupprimer
		GenEnnemi.NbNMIPresents--;
		if (GenEnnemi.isinstate('AttendMortNMIs'))
			GenEnnemi.UnNMIenMoins();
		else if (GenEnnemi.isinstate('PauseGenese'))
			GenEnnemi.gotostate('genese','suitegeneration');
	}
	else   //pas supprime de la basesoldierlist si genere, c'est le gennmi qui le fait
	{
		for (i = 0; i < gameinf.BaseSoldierList.Length; i++)
		{
		          if (gameinf.BaseSoldierList[i] == self )
				  {
					  gameinf.BaseSoldierList.Remove(i,1);
					  break;
				  }
		}
	}
	controller.gotostate('Mort');
	//son
	if (IAContr!=none)
	{
		if (IAContr.NiveauAlerte==2 && IAContr.NiveauALerteEnAS==0)
		{
			 IAContr.NiveauAlerte=0;
			 IAContr.bSwitchMusicInWaitState=false;  //inutile
		}
		//son
		Switch (IAContr.NiveauALerte)
		{
			case 0:
				level.decattente();
				//IAContr.genalerte.nbattente--;
				//log("decattente "$Iacontroller(controller).genalerte.nbattente@Iacontroller(controller).genalerte.nbalerte@Iacontroller(controller).genalerte.nbattaque);
				break;
			case 1:
				level.decAlerte();
				//IAContr.genalerte.nbalerte--;
				//log("decalerte "$Iacontroller(controller).genalerte.nbattente@Iacontroller(controller).genalerte.nbalerte@Iacontroller(controller).genalerte.nbattaque);
				break;
			case 2:
				level.decAttaque();
				//IAContr.genalerte.nbattaque--;
				//log("decattaque "$Iacontroller(controller).genalerte.nbattente@Iacontroller(controller).genalerte.nbalerte@Iacontroller(controller).genalerte.nbattaque);
				break;
		}
	}
	//sons
	if (bMeurtEnTombant && TestChute())
	{
        bJeTombe=true;
        PlaySndDeathOno(deathono'Onomatopees.hPNJDeath3',CodeMesh,NumeroTimbre);
	}
	else if ( class<XIIIDamageType>(damageType).default.bDieInSilencePlease )
		PlaySndDeathOno(deathono'Onomatopees.hPNJDeath2',CodeMesh,NumeroTimbre);
	else
		//PlaySndDeathOno(deathono'Onomatopees.hPNJDeath1',CodeMesh,NumeroTimbre)
        ;
	Super.Died( Killer, damageType, HitLocCode);
}


event Destroyed()
{
    local int i;
	local xiiigameinfo gameinf;
	local IACOntroller IAContr;

    //supression de la basesoldierlist pour les persos non generes
    gameinf=xiiigameinfo(level.game);
	if (bBasesGenere && GenEnnemi!=none)
	{
		GenEnnemi.NbNMIPresents--;
		if (GenEnnemi.isinstate('AttendMortNMIs'))
			GenEnnemi.UnNMIenMoins();
		else if (GenEnnemi.isinstate('PauseGenese'))
			GenEnnemi.gotostate('genese','suitegeneration');
	}
	else   //pas supprime de la basesoldierlist si genere, c'est le gennmi qui le fait
	{
		for (i = 0; i < gameinf.BaseSoldierList.Length; i++)
		{
		          if (gameinf.BaseSoldierList[i] == self )
				  {
					  gameinf.BaseSoldierList.Remove(i,1);
					  break;
				  }
		}
	}
	IAContr=IaController(controller);
	if (IAContr!=none)
	{
		if (IAContr.NiveauAlerte==2 && IAContr.NiveauALerteEnAS==0)
		{
			 IAContr.NiveauAlerte=0;
			 IAContr.bSwitchMusicInWaitState=false;  //inutile
		}
		//son
		Switch (IAContr.NiveauALerte)
		{
			case 0:
				level.decattente();
			//	IAContr.genalerte.nbattente--;
			//	log("decattente "$Iacontroller(controller).genalerte.nbattente@Iacontroller(controller).genalerte.nbalerte@Iacontroller(controller).genalerte.nbattaque);
				break;
			case 1:
				level.decAlerte();
			//	IAContr.genalerte.nbalerte--;
			//	log("decalerte "$Iacontroller(controller).genalerte.nbattente@Iacontroller(controller).genalerte.nbalerte@Iacontroller(controller).genalerte.nbattaque);
				break;
			case 2:
				level.decAttaque();
			//	IAContr.genalerte.nbattaque--;
			//	log("decattaque "$Iacontroller(controller).genalerte.nbattente@Iacontroller(controller).genalerte.nbalerte@Iacontroller(controller).genalerte.nbattaque);
				break;
		}
	}
	Super.Destroyed();
}
//_____________________________________________________________________________
// Cheat pour mettre les logs
//------------------------------------

event UsedBy(Pawn user)
{
	if (!self.bisdead)
		IACOntroller(controller).CHARGE_LES_LOGS=true;
}

// ----------------------------------------------------------------------
// TestChute : renvoi si le perso peut tomber.
// ----------------------------------------------------------------------
function bool TestChute()
{
	local vector PointArrivee, PointDepart, DirectionChute;
	local float DistanceMax, HauteurMin; //hauteur maximum de la distance pour se jeter et la hauteur mini pour tomber
	local bool result;
	local attackpoint AP;
	local int i;


	DistanceMax=90; //distance max au bord
	HauteurMin=150; //hauteur min de chute

	PointDepart=location+60*vect(0,0,1);
	//calcul a mi-chemin
    For(i=0;i<level.game.AttackPointList.Length;i++)
    {
		AP=attackpoint(level.game.AttackPointList[i]);
		if (AP.PointArriveeCrash!=none && vsize(AP.location-location)<80)
		{
			DirectionChute=normal((AP.PointArriveeCrash.location-location)*vect(1,1,0));
			PointCrash=AP.PointArriveeCrash;
			break;
		}
    }
    if (PointCrash==none)  //pas de crashpoint trouve
        DirectionChute=normal(vector(rotation)*vect(1,1,0));
	PointArrivee=location-vect(0,0,1)*(78+HauteurMin)+ DirectionChute*DistanceMax*0.5*(138     +DistanceMax*0.5)/138;
	if (FastTrace(Pointarrivee,pointdepart))
	{
		//log("distance < 45");
		DistanceBord=DistanceMax*0.5;
		return true;
	}
	else
	{
		PointArrivee=location-vect(0,0,1)*(78+HauteurMin)+ DirectionChute*DistanceMax*(138+DistanceMax)/138;
		if (FastTrace(Pointarrivee,pointdepart))
		{
			//log("45 < distance < 90");
			DistanceBord=DistanceMax;
			return true;
		}
	}
	return false;
}

//_____________________________________________________________________________
state dying
{
	event Tick (float delta)
	{
  //	 Log(self@"Dying, PHYSICS="$Physics@"Rotation="$Rotation);
		super.tick(delta);
		if (bControleChute)
		{
			if (PointCrash!=none)
				velocity=200*normal((PointCrash.location-location)*vect(1,1,0));
			else
				velocity=200*normal(vector(rotation)*vect(1,1,0));
		}
	}

    event Landed(vector HitNormal)
    {
       LandedSpecial();
/*
      finalRot = Rotation;
      finalRot.Roll = 0;
      finalRot.Pitch = 0;
      setRotation(finalRot);
*/
      if (PointCrash!=none && PointCrash.bMakeCrashNoise)
        PlaySound(Sound'XIIIsound.PNJ__PNJCrash.PNJCrash__hCrashHard');

      if (OnoChute!=none)
      {
        if (Onochute.emitters[0]!=none)
		  {
          OnoChute.emitters[0].InitialParticlesPerSecond=0;
			 OnoChute.emitters[0].ParticlesPerSecond=0;
		  }
		  if (Onochute.emitters[1]!=none)
		  {
          OnoChute.emitters[1].InitialParticlesPerSecond=0;
			 OnoChute.emitters[1].ParticlesPerSecond=0;
		  }
        OnoChute.settimer2(1.5,false);
       }
//      Log(self@"Setting Rotation"@finalRot@"from floor="$floor@"Rotation="$Rotation);
      if (bJeTombe)
      {
        bjetombe=false;
        PlayCrashOnGround();
      }
    }

    event touch(actor other)
    {
        local rotator finalRot;
        local float OldHeight;
        local vector X,Y,Z,W;

        Super.Touch(other);

        if (other.isa('watervolume'))
        {
          finalRot = Rotation;
          finalRot.Roll = 0;
          finalRot.Pitch = 0;
          setRotation(finalRot);
          SetPhysics(PHYS_falling);
          if (bJeTombe)
          {
            if (PointCrash!=none && PointCrash.bMakeCrashNoise)
              PlaySound(Sound'XIIIsound.PNJ__PNJCrash.PNJCrash__hCrashWater');
            if (OnoChute!=none)
            {
              if (Onochute.emitters[0]!=none)
                OnoChute.emitters[0].InitialParticlesPerSecond=0;
              OnoChute.settimer(1.5,false);
            }
            bjetombe=false;
            PlayCrashOnGround();
          }
        }
    }

    function BeginState()
    {
		enable('tick');
		SetTimer(2.0, false);
		//FRD
		bEnableSpineControl=false;
		SetBoneDirection(FIRINGBLENDBONE, rot(0,0,0), vect(0,0,0), 0.0 );
		//SetPhysics(PHYS_Falling);
		//
		bInvulnerableBody = true;
    }

Begin:
	//  velocity.z=0;
	if (bJeTombe)
	{
  	   disable('landed');
  	   disable('touch');
		bMeurtEnTombant=false;
		bcollideworld=false;
		SetPhysics(PHYS_walking);
		bControleChute=true;
		controller.focus=none;
		if (PointCrash!=none)
		{
			controller.focalpoint=PointCrash.location;
		}
		else
			controller.focalpoint=vector(rotation)*10000*vect(1,1,0)+location;
      PlayStartToFall();


		//playanim('DeathDos',,0.1);
		sleep(0.6*(DistanceBord/90)); //grosse bidouille distancebord=DistanceMax ou DM/2
		SetPhysics(PHYS_Falling);
		enable('landed');
		enable('touch');
		//log("on commence a sauter");
		bControleChute=false;
		acceleration=vect(0,0,0);
		if (PointCrash!=none)
		{
			//log(self$"C'est bon je peux atteindre mon point de crash"$velocity);
			Vect_Position=PointCrash.location-location;
			/*velocity=300*normal((PointArriveeCrash.location-location)*vect(1,1,0));
			velocity.z=-150;*/
			velocity=0.8*Vect_Position*(950)*vect(1,1,0)/(-150 + sqrt(22500 -2*950*Vect_Position.z));
			velocity.z=-150;
			//log("vitesse horizontale   "$Vsize(Vect_Position*vect(1,1,0))*950/(-150 + sqrt(22500 -2*950*Vect_Position.z)));
		}
		else
		{
			//log(self$"Je peux pas atteindre mon point de crash");
			velocity=300*normal(vector(rotation)*vect(1,1,0));
			velocity.z=-150;
		}
		PlayFallingFalaise();
     		 OnoChute=Spawn(class'XIIIChuteEmiter',self);
			 XIIIChuteEmiter(OnoChute).lastDamagedBy = PawnKiller;
			 OnoChute.SetBase(self);
			 sleep(0.4);
			 bcollideworld=true;
			 //commence de la chute

	}
	Sleep(0.5);
	genalerte(level.game.genalerte).potemeurt(self);   //genalerte doit etre present dans toute map solo
	bInvulnerableBody=false;

	// ELR Added LieStill there 0.5 seconds after state beginning because we don't want the col cyl staying big a long time
	LieStill();
	//destruction
	SetOwner(None);
	controller.Destroy();
	controller = None;
}


//		InitialInventory(0)=(Inventory=Class'XIII.Beretta',Count=2)


defaultproperties
{
     InitialAlliances(0)=(AllianceName="Player",AllianceLevel=-1.000000)
     InitialAlliances(1)=(AllianceName="NMI",AllianceLevel=1.000000)
     TempsRechercheNMI=8.000000
     Agressivite=0.300000
     TempsIdentification=2.000000
     DistanceAttaque=600.000000
     TempsVisee=1.000000
     StrategicPointAttraction=100
     TempsPasVu=1.500000
     bRappliqueSiAlerte=True
     bPasseAttScr_SiDeclenche=True
     OffsetTimeBetweenShots=0.250000
     bAlerteAmisEnCriant=True
     WalkingSpeed=0.296600
     bFouilleCadavres=True
     bTurnIntoAgressiveSoldier=True
     CodeMesh=9
     HearingThreshold=1500.000000
     SightRadius=2000.000000
     PeripheralVision=120.000000
     ControllerClass=Class'XIDPawn.IAController'
     Alliance="NMI"
     Skill=1
     Mesh=SkeletalMesh'XIIIPersos.XIIIM'
}
