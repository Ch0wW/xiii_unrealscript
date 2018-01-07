//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Plongeur_USA01 extends XIIIPawn;

struct InventoryItem  {
     var() class<Inventory> Inventory;
     var() int              Count;
};

var() float Temps_Acquisition;
var() float DistanceAttaque;
//var() float SwimmingSpeed;
var() int NumReseauPropre;
var(inventory) InventoryItem InitialInventory[8];  // inventaire par defaut du pawn
var GenPlongeurs GenEnnemi;
var bool bBasesGenere;
var bool bWaitToTouchWaterVolume;

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

FUNCTION PostBeginPlay()
{
	Super.PostBeginPlay();

//   LinkSkelAnim(MeshAnimation'XIIIPersos.PlongeurspeA');
//	LinkSkelAnim(MeshAnimation'XIIIPersosG.MigA');
}


event HeadVolumeChange( PhysicsVolume NewHeadVolume )
{
	// log("event change volume"@bWaitToTouchWaterVolume@NewHeadVolume.bWaterVolume);

    if (NewHeadVolume.bWaterVolume)
	 {
		setphysics(phys_swimming);
		if (bWaitToTouchWaterVolume)
		{
			bWaitToTouchWaterVolume=false;
			PlayMoving();
   	}
	 }
}

simulated event AnimEnd(int Channel)
{
	playwaiting();
}
//_____________________________________________________________________________
simulated function PlayMoving()
{
	if (physics==PHYS_SWIMMING)
	{
    //Log("--@ PlayMoving call for "$self@"in physics"@Physics);
		loopanim('plongnage',,0.3);
	}
}

//_____________________________________________________________________________
simulated function PlayReLoading(float Rate, name FiringMode)
{
/*log("--@ PlayReLoading call for "$self@"w/FiringMode="$FiringMode);
    if ( bIsDead )
      return;
	playanim('plongnage',,0.4);
  */
}

simulated function PlayWaiting()
{
	if (physics==PHYS_SWIMMING)
	{
 		//Log("--@ PlayWaitingcall for "$self@"in physics"@Physics);
		loopanim('plongnage',,0.3);
	}
}

//_____________________________________________________________________________
simulated function PlayFiring(float Rate, name FiringMode)
{
}

simulated function PlaySpearGunFiring()
{
   //log("--@ PlayFiringcall 2222222222222222222222222 for "$self@"in physics"@Physics);
  	playanim('plongtir',,0.2);
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
          if ( AmmoTmp.PickupClass != none )
            AmmoTmp.AmmoAmount += InitialInventory[i].count * class<Ammo>(AmmoTmp.PickupClass).Default.AmmoAmount;
        }
        else if ( Ammunition(Inv) != none )
        {
          AmmoTmp = ammunition(FindInventoryType(Inv.Class));
          if ( AmmoTmp == none )
          {
            Inv.GiveTo(self);
            if ( Inv.PickupClass != none )
              Ammunition(Inv).AmmoAmount += InitialInventory[i].count * class<Ammo>(Inv.PickupClass).Default.AmmoAmount;
          }
          else
          {
            if ( Inv.PickupClass != none )
              AmmoTmp.ammoAmount += InitialInventory[i].count * class<Ammo>(Inv.PickupClass).Default.AmmoAmount;
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

simulated event Destroyed()
{
     if (bBasesGenere)
     {
          if (GenEnnemi!=none)
          {
               GenEnnemi.NbNMIPresents--;
               if (GenEnnemi.isinstate('AttendMortNMIs'))
                  GenEnnemi.UnNMIenMoins();
               else if (GenEnnemi.isinstate('PauseGenese'))
                  GenEnnemi.gotostate('genese','suitegeneration');
          }
          else
               bBasesGenere=false;
     }
  	 Super.Destroyed();
}

//FRD ne prend pas de dommage pour noyade
function TakeDrowningDamage()
{
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocCode)
{
    local Controller Other;
    local int i;
    local inventory Kapio;

    PawnKiller = Killer.Pawn;

    HitDamageType = DamageType;

    if ( bDeleteMe )
      return;   // Already destroyed

    if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocCode) )
    {
      Health = max(Health, 1); // mutator should set this higher
      return;
    }

    // ELR
    ShouldCrouch(false);

    Health = Min(0, Health);

    Level.Game.Killed(Killer, Controller, self, damageType);

    // ELR Characters that are stunned MUST NOT Cause their event
    if ( bCauseEventOnStun || ((DamageType != class'DTStunned') && (DamageType != class'DTSureStunned') && (DamageType != class'DTDropAfterStun')) )
    {
      if ( Killer != None )
        TriggerEvent(Event, self, Killer.Pawn);
      else
        TriggerEvent(Event, self, None);
    }

    Velocity.Z *= 1.3;

    TakeHitLocation = HitLocCode;

    PlayDying(DamageType, HitLocCode);    // HitLocCode instead of HitLocation

    bIsDead = true;
    SetBoneDirection( FIRINGBLENDBONE, rot(0,0,0), vect(0,0,0), 0.0 );

    if ( Level.Game.bGameEnded )
      return;
}

simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
    if ( bDBAnim ) Log("### PlayDyingAnim call for "$self@" HitLoc="$HitLoc);

    PlayAnim('plongmort',,0.5); //mettre death nage
    mass=70;
	 Buoyancy=105.00000;
    acceleration*=vect(0,0,1);
}



defaultproperties
{
     Temps_Acquisition=0.500000
     DistanceAttaque=600.000000
     InitialInventory(0)=(Inventory=Class'XIII.LHarpon',Count=12)
     bCanJump=False
     HearingThreshold=1500.000000
     SightRadius=2000.000000
     PeripheralVision=120.000000
     WaterSpeed=150.000000
     ControllerClass=Class'XIDPawn.Plongeur_Usa01_Controller'
     CarcassCollisionHeight=30.000000
     Skill=1
     Mesh=SkeletalMesh'XIIIPersos.PlongeurM'
     CollisionRadius=44.000000
     CollisionHeight=30.000000
}
