//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FBI_Helico01a extends BaseSoldier;

var TalkieWalkie Talkie;
var() float TempsDegainageTalkie;
var bool bBlocked;

event timer2()
{
	bBlocked=false;
}

event PostBeginPlay()
{
		local FBI_Helico01_Controller FBI_Controller;

      super.PostBeginPlay();

		FBI_Controller=FBI_Helico01_Controller(controller);

	//	FBI_Controller.CHARGE_LES_LOGS=true;
		FBI_Controller.FBI=self;

		 Switch(Level.Game.Difficulty)
		 {
			 case 0: FBI_Controller.FBI.TempsDegainageTalkie*=1.2; break;
			 case 2: FBI_Controller.FBI.TempsDegainageTalkie*=0.8;break;
			 case 3: FBI_Controller.FBI.TempsDegainageTalkie*=0.6; break;
		 }
     Talkie = Spawn(class'TalkieWalkie',self);
     Talkie.AttachToWalkie(self,false);
		talkie.bhidden=true;
	  	talkie.RefreshDisplaying();

	//	 LinkSkelAnim (MeshAnimation'XIIIPersosG.MigA');
	//	 LinkSkelAnim (MeshAnimation'XIIIPersos.SpadsSPeA');
}


event bump(actor other)
{
	local FBI_Helico01_Controller FBIController,monFBIController;
	local FBI_Helico01a FBIPawn;
	local safepoint PointSafeVise;

   if (bBlocked)
		return;

	if (other.isa('xiiiplayerpawn')) // je me crampe sur XIII
	{
		if (controller!=none &&  bmoving && (velocity dot (other.location-location)>0))
		{
			if (Talkie!=none) Talkie.AttachToWalkie(self,false); //remet talkie ceinture
			log(self@"je suis crampe sur xiii je repasse en attaque"@other);
			controller.gotostate('restesurplace','PutDownTalkie');
		}
	}
	else
	{
		FBIPawn=FBI_Helico01a(other);
		if (FBIPawn!=none)
		{
			FBIController=FBI_Helico01_Controller(FBIPawn.controller);
			monFBIController=FBI_Helico01_Controller(controller);
			if (FBIController!=none && monFBIController!=none) // je me crampe sur un pote
			{
				if (Vsize(monFBIController.xiii.location-self.location)<Vsize(monFBIController.xiii.location-other.location) )
				{
					log(self@"je suis en face de XIII et je suis bloque par mon mon pote je repasse en attaque");
					bBlocked=true;
					settimer2(2,false);
					FBIPawn.bBlocked=true;
					FBIPawn.settimer2(10,false);
					PointSafeVise=none;
					if (velocity dot (monFBIController.xiii.location-location)<0 && FBIPAWN.velocity dot (monFBIController.xiii.location-location)>=0 ) //je fuis et pas l'autre
				   {
						if (monFBIController.isinstate('vavers') && monFBIController.bGoToCallTalkie &&  safepoint(monFBIController.moveactor.moveactor)!=none)  //j'allais vesr talkie point
						{
							PointSafeVise=safepoint(monFBIController.moveactor.moveactor);
							PointSafeVise.timer(); //pour liberer point
							monFBIController.gotostate('restesurplace','PutDownTalkie');
						}
						if (FBIController.NiveauAlerte!=2) FBIController.gotostate('investigation','ContinueUnPeuEtAttaque');   //je suis pas en attaque
					}
					else
					{
						if (FBIController.isinstate('vavers') && FBIController.bGoToCallTalkie && safepoint(FBIController.moveactor.moveactor)!=none)    //j'allais vers point
						{
							PointSafeVise=safepoint(FBIController.moveactor.moveactor);
							PointSafeVise.timer(); //pour liberer point
							FBIController.gotostate('restesurplace','PutDownTalkie');
						}
					}
				}
			}
		}
	}
}

function PlayTakeTalkie()
{
	 TakeAnimControl(false);
    playAnim('talkie1',2,0.5,FIRINGCHANNEL+1);
	 AnimBlendToAlpha(FIRINGCHANNEL+1,1,0.05);
}
function PlayCallTalkie()
{
	 TakeAnimControl(false);
    loopAnim('Talkie2',1,0.1,FIRINGChannel+1);
	 AnimBlendToAlpha(FIRINGCHANNEL+1,1,0.05);
}

function SpawnCadavre()
{
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
//      Log("Dying BeginState, should be setting timer to 2.0");

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
		bmoving=false;
    }
Begin:
  Sleep(0.5);
  bInvulnerableBody=false;
  if (talkie!=none) talkie.destroy();
  genalerte(level.game.genalerte).potemeurt(self);   //genalerte doit etre present dans toute map solo
  // ELR Added LieStill there 0.5 seconds after state beginning because we don't want the col cyl staying big a long time
  LieStill();
}




defaultproperties
{
     TempsDegainageTalkie=3.000000
     bCanBeGrabbed=False
     GroundSpeed=356.000000
     ControllerClass=Class'XIDPawn.FBi_Helico01_Controller'
     Mesh=SkeletalMesh'XIIIPersos.GardienM'
}
