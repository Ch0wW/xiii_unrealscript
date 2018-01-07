//=============================================================================
// Johansson.
//=============================================================================
class Johansson extends BaseSoldier;

// var designers
var() pathnode PointScalpel;
var() pathnode PointFiole;
var() Prock03_fioledeco Fioles[3];
var() Prock03_PointPlanque PtsDePlanque[8];
var() Prock03_GenEffects GenEffects;


var Scalpels_Attachment VisuelScalpel;
var Piquouse_Attachment VisuelPiquouse;
var Fiole_Attachment VisuelFiole;

var vector ScalpelOffset;

var name Arme;

var float DispersionJohansson;
var float DistanceAttaque;
var float timersound;//son
var float TimerWeapon;
var float TimeBeforeEndStateWeapon;

var int NbScalpels;
var int NbFioles;
var int NbCoupsDansVide; //en h2h

var bool bWeaponReady; //arme prete a retirer
var bool bxiiipoisoned;
var bool bInEndStateWeapon;

var bool bSerumSound; //son
var bool bPlayedSound;   //son


event PostBeginPlay()
{
//	LinkSkelAnim (MeshAnimation'XIIIPersos.JohanssonSpeA');
//	LinkSkelAnim (MeshAnimation'XIIIPersos.GardienSPeA');
//	LinkSkelAnim (MeshAnimation'XIIIPersosG.MigA');
    Super.PostBeginPlay();
}
event Tick(float DeltaTime)
{
	local int valeurarmeactuelle;

	super.tick(DeltaTime);

	if (bPlayedSound && (level.timeseconds-TimerSound)>4)
	{
		bSerumSound=false;
		bPlayedSound=false;
	}
	if (bInEndStateWeapon && (level.timeseconds-TimerWeapon)>TimeBeforeEndStateWeapon)
	{
		EndWeaponState();
	}
}

event Timer2 ()   //declenchement des degats de l'arme
{
    local Vector Start,EndTrace,X,Y,Z;
    local rotator AdjustedAIm;
    local Prock03_Scalpels PS;
    local Prock03_Fioles PF;
    local vector eyepos,Hitlocation,Hitnormal;
    local actor other,BLE;
    local Material HitMat;

	 if (bisdead)
		return;
    If (arme=='ScalpelH2H')
    {
        GetAxes(GetViewRotation(),X,Y,Z);
        Start = Location + eyepos;
        AdjustedAim = controller.AdjustAim(none, Start, 0);
        Endtrace=Start + 120*vector(AdjustedAim);
        Other = Trace(HitLocation, HitNormal, EndTrace, Start, True, vect(0,0,0), HitMat, TRACETYPE_DiscardIfCanShootThroughWithRayCastingWeapon);
        if (XIIIPlayerPawn(other)!=none)
        {
				NbCoupsDansVide=0;
				if (!bPlayedSound && rand(5)==0)
				{
					bPlayedSound=true;
					timersound=level.timeseconds;
					triggerevent('dial_goute',self,self);
				}
            Other.TakeDamage(40,  self, HitLocation, 300.0*X, Class'XIII.DTFisted');
            BLE = Spawn(class'BloodShotEmitter',,, HitLocation+HitNormal, Rotator(HitNormal));
        }
			else
				NbCoupsDansVide++;
		  //PlayVoice(Sound'XIIIsound.PNJ__Johansson.Johansson__hScalpel',1);
		bInEndStateWeapon=true;
		TimerWeapon=level.timeseconds;
		TimeBeforeEndStateWeapon=0.15;
    }
    else if (arme=='Scalpels')
    {
			//log("je lance le scalpel");
			bispafable=true;
		  if (biscrouched)
           eyepos=vect(0,0,40);
        else
            eyepos=vect(0,0,60);
        ScalpelDansLaMain(false);
        GetAxes(GetViewRotation(),X,Y,Z);
        Start = GetScalpelStart(X,Y,Z) + 16*X;
        AdjustedAim = controller.AdjustAim(none, Start, 0);
        Ps=Spawn(class'Prock03_scalpels',self,,Start,AdjustedAim);
        //PlayVoice(Sound'XIIIsound.PNJ__Johansson.Johansson__hScalpel',0);
        //log("projectiole"@ps);
        if ( Ps != none )
        {
           Nbscalpels--;
           PS.instigator=self;
           PS.SetImpactNoise(0, 0.15);
        }
       bInEndStateWeapon=true;
		TimerWeapon=level.timeseconds;
		TimeBeforeEndStateWeapon=0.62;
    }
    else if (arme=='piquouse')
    {
        GetAxes(GetViewRotation(),X,Y,Z);
        Start = Location + eyepos;
        AdjustedAim = controller.AdjustAim(none, Start, 0);
        Endtrace=Start + 120*vector(AdjustedAim);
		  Other = Trace(HitLocation, HitNormal, EndTrace, Start, True, vect(0,0,0), HitMat, TRACETYPE_DiscardIfCanShootThroughWithRayCastingWeapon);
        if (Xiiiplayerpawn(other)!=none)
        {
				 //poisoned
        		JOhansson(instigator).GenEffects.XIIIPoisoned();
				NbCoupsDansVide=0;
		 		if (controller!=none)
					JohanssonController(controller).XIIIBePoisoned();
            BLE = Spawn(class'BloodShotEmitter',,, HitLocation+HitNormal, Rotator(HitNormal));
        }
		  else
				NbCoupsDansVide++;
		   bInEndStateWeapon=true;
			TimerWeapon=level.timeseconds;
			TimeBeforeEndStateWeapon=0.15;
    }
    else    //fiole
    {
				bispafable=true;
		  if (biscrouched)
           eyepos=vect(0,0,40);
        else
            eyepos=vect(0,0,60);
        GetAxes(GetViewRotation(),X,Y,Z);
        Start = GetScalpelStart(X,Y,Z) + 16*X;
		  FioleDansLaMain(false);
        AdjustedAim = controller.AdjustAim(none, Start, 0);
        PF=Spawn(class'Prock03_Fioles',self,,Start,AdjustedAim);
        //Pf.velocity.z+=10;
        //log("projectiole"@ps);
        if (PF != none)
        {
           NbFioles--;
           PF.instigator=self;
           PF.SetImpactNoise(0, 0.15);
        }
       	bInEndStateWeapon=true;
			TimerWeapon=level.timeseconds;
			TimeBeforeEndStateWeapon=0.7;
    }
}

function EndWeaponState() //retabli etat de l'arme et remet le visuel dans la main
{
	bInEndStateWeapon=false;
	releaseanimcontrol();
	bWeaponReady=true;
	If (arme=='ScalpelH2H')
	{
		if (controller!=none)
			JohanssonController(controller).Halteaufeu();
	  //log("rien a faire pour scalpelH2H");
	}
	else if (arme=='Scalpels')
	{
	  ScalpelDansLaMain(true);
	}
	else if (arme=='piquouse')
	{
	   if (controller!=none)
		JohanssonController(controller).Halteaufeu();
	    //log("rien a faire pour piquouse");
	}
	else
	{
	 FioleDansLaMain(true);
	 //log("rien a faire pour fiole");
	}
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocCode)
{
	if (Controller != none) controller.bControlanimations=false;
	bSpineControl=true;
	bPhysicsanimupdate=true;
	AnimBlendToAlpha(FIRINGCHANNEL+1,0,0);
	AnimBlendToAlpha(FIRINGCHANNEL+2,0,0);
	super.Died(Killer,damageType,HitLocCode);
}

//_FRD reecrite pour ne pas l'assomer dans le dos.____________________________________________________________________________
// ELR CheckDamageLocation
function int GetDamageSide( vector HitLocation )
{
    return 3;
}

function TakeAnimControl(bool bMoveAnim)
{
	bMoving=bMoveAnim;
	bPhysicsanimupdate=false;
	bSpineControl=false;
	if (controller!=none)
		controller.bControlanimations=true;
	AnimBlendToAlpha(FIRINGCHANNEL+1,1,0.2);
	SetBoneDirection(FIRINGBLENDBONE, rot(0,0,0), vect(0,0,0), 0.0 );
}

function ReleaseAnimControl(optional bool bFastTransition)
{
	if (Controller != none) controller.bControlanimations=false;
	bSpineControl=true;
	bPhysicsanimupdate=true;
	PlayWaiting();
	AnimBlendToAlpha(FIRINGCHANNEL+1,0,0.2);
}


/*function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
   if (bXIIIpoisoned)
      Damage*=0.3;
   super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}*/

//[FRD] gestion anim en fonction vitesse deplacement
/*simulated function PlayMoving()
{
   local float AnimRate;

   if (bisdead)
      return;
   AnimRate = fmax(0,1*vsize(velocity)/GroundSpeed);
   loopanim('courseseringue',AnimRate,0.2);
}     */

//_____________________________________________________________________________
simulated function PlayWaiting()
{
    if ( bDBAnim ) Log("--@ PlayWaiting call for "$self);

    if ( (Controller != None) && Controller.bControlAnimations )
      return;
    PlayAnim('attente',,0.25);
    PlayAnim('attente',,0.25,12);
    AnimBlendParams(12,1.0,0.0,0.0,FIRINGBLENDBONE);
}
function PlayTakeScalpels()
{
	 TakeAnimControl(false);
    PlayAnim('takescalpel',,0.4,FIRINGCHANNEL+1);
}
function PlayTakeFiole()
{
	TakeAnimControl(false);
    PlayAnim('takefiole',2,0.4,FIRINGCHANNEL+1);
}
function PlayProvoc()
{
	TakeAnimControl(false);
	if (rand(2)==0)
	{
		PlayAnim('provoc',2,0.4,FIRINGCHANNEL+1);
	}
	else
	{
		if (!bSerumSound)
		{
			bPlayedSound=true;
			triggerevent('dial_Ahahah',self,self);
			TimerSound=level.timeseconds;
		}
		PlayAnim('eclatrire',2,0.4,FIRINGCHANNEL+1);
	}
}

Function InitScalpelAttach()
{
    VisuelScalpel = Spawn(class'Scalpels_Attachment');
    VisuelScalpel.SetDrawType(DT_StaticMesh);
    VisuelScalpel.SetDrawScale(1);
    AttachToBone(VisuelScalpel,'X R Hand');
    VisuelScalpel.SetRelativeLocation(vect(8,-2,10));
    VisuelScalpel.SetRelativeRotation(rot(+16000,10000,20000));
}
Function InitPiquouseAttach()
{
    VisuelPiquouse = Spawn(class'Piquouse_Attachment');
    VisuelPiquouse.SetDrawType(DT_StaticMesh);
    VisuelPiquouse.SetDrawScale(1);
    AttachToBone(VisuelPiquouse,'X L Hand');
    VisuelPiquouse.SetRelativeLocation(vect(9,-2,-5));
    VisuelPiquouse.SetRelativeRotation(rot(-15000,0,00));
}
Function InitFioleAttach()
{
    VisuelFiole = Spawn(class'Fiole_Attachment');
    VisuelFiole.SetDrawType(DT_StaticMesh);
    VisuelFiole.SetDrawScale(1);
    AttachToBone(VisuelFiole,'X R Hand');
    VisuelFiole.SetRelativeLocation(vect(8,-2,4));
    VisuelFiole.SetRelativeRotation(rot(+32000,30000,-30000));
}
function PiquouseDansLaMain(bool bNeedToDisplay)
{
   if (!bNeedToDisplay)
      VisuelPiquouse.SetDrawType(DT_none);
   else
      VisuelPiquouse.SetDrawType(DT_StaticMesh);
}
function ScalpelDansLaMain(bool bNeedToDisplay)
{
   if (!bNeedToDisplay)
      VisuelScalpel.SetDrawType(DT_none);
   else
       VisuelScalpel.SetDrawType(DT_StaticMesh);
}
function FioleDansLaMain(bool bNeedToDisplay)
{
   if (!bNeedToDisplay)
      VisuelFiole.SetDrawType(DT_none);
   else
       VisuelFiole.SetDrawType(DT_StaticMesh);
}

simulated function vector GetScalpelStart(vector X, vector Y, vector Z)
{
    local vector eyepos;

    if (biscrouched)
        eyepos=vect(0,0,40);
    else
        eyepos=vect(0,0,60);
    return (Location + eyepos/*EyePosition() */+ ScalpelOffset.X * X + ScalpelOffset.Y * Y + ScalpelOffset.Z * Z);
}

function ScalpelsFire()
{
//log("scalpel fire");
    If (NbScalpels<=1)
        return;
	bispafable=false;
	 	bWeaponReady=false;
	 TakeAnimControl(false);
    PlayAnim('lancer',,0.01,FIRINGCHANNEL+1);
    Settimer2(0.38,false);
}

function ScalpelH2HFire()
{
    If (NbScalpels<=0)
        return;
	bWeaponReady=false;
	TakeAnimControl(false);

	switch(rand(3))
	{
      case 0: PlayAnim('coup1',1.5,0.1,FIRINGCHANNEL+1); break;
		case 1: PlayAnim('coup2',1.5,0.1,FIRINGCHANNEL+1); break;
		case 2: PlayAnim('coup3',1.5,0.1,FIRINGCHANNEL+1); break;
	}
   Settimer2(0.36,false);
}

function PiquouseFire()
{
	 bWeaponReady=false;
	 TakeAnimControl(false);
    PlayAnim('planterseringue',1.5,0.4,FIRINGCHANNEL+1);
    Settimer2(0.6,false);
}

function FioleFire()
{
    If (NbFioles<=0)
        return;
		bispafable=false;
		bWeaponReady=false;
	TakeAnimControl(false);
    PlayAnim('lancer',,0.01,FIRINGCHANNEL+1);
    Settimer2(0.45,false);
}

function SpawnCadavre()
{
//log("gotostate mort");
    Controller.gotostate('mort');
}

//state dying du xiii pawn
state Dying
{
    event Tick (float delta)
    {
//      super(XIIIPawn).Tick(delta);
    }
    event Landed(vector HitNormal)
    {
      LandedSpecial();
      PlaySound(hBodyFallSound);
    }
    event Touch(actor other)
    {
//      super(XIIIPawn).Touch(other);
    }
    event BeginState()
    {
		bInEndStateWeapon=false;
		settimer2(0,false);
      enable('tick');
      bForceInUniverse = false;
      RefreshDisplaying();

      if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
        LifeSpan = 1.0;
      SetTimer(2.0, false);

      SetPhysics(PHYS_Falling);
      bInvulnerableBody = true;

      if ( Controller != None )
      {
        if( Controller.bIsPlayer )
          Controller.PawnDied();
        else
          SpawnCadavre();
        if (controller != none)
          Controller.bControlAnimations = true;
      }
    }
Begin:
  Sleep(0.5);
  bInvulnerableBody=false;
  // ELR Added LieStill there 0.5 seconds after state beginning because we don't want the col cyl staying big a long time
  LieStill();
}



defaultproperties
{
     ScalpelOffset=(X=40.000000,Y=5.000000,Z=-2.000000)
     DistanceAttaque=600.000000
     NbScalpels=10
     bWeaponReady=True
     InitialInventory(0)=(Inventory=Class'XIII.TKnife',Count=2)
     bCanBeGrabbed=False
     GroundSpeed=650.000000
     Health=2000
     ControllerClass=Class'XIDPawn.JohanssonController'
     HeadShotFactor=1.500000
     Mesh=SkeletalMesh'XIIIPersos.JohanssonM'
}
