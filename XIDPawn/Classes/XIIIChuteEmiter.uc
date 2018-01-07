//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIChuteEmiter extends Emitter;

var int index;
var int lastType;
var Pawn lastDamagedBy;
var bool initialized;

//SOUTHEND Added code to make it AAAAHHAAHHAA instead of AAAAAAAAAAAAA

//_____________________________________________________________________________
event PostBeginPlay( )
{
	index = 0;
	SetTimer(0.1,false);
	lastType = 0;
}


//_____________________________________________________________________________
event timer()
{
  local float r;

  //SOUTHEND
  // For XBOX only - Start a camera showing the falling actor
  local CWndFalling CWnd;

  if (!initialized)
  {
	  initialized = true;
	  if ( (Level.Game != none) && (Level.Game.DetailLevel > 1) )
	  {
	      if ( (lastDamagedBy != none) && (XIIIPlayerController(lastDamagedBy.Controller) != none) )
	      {
	        DebugLog("Falling CWND");
	        CWnd = Spawn(class'XIII.CWndFalling',self);
	        if ( CWnd != none )
	        {
	          CWnd.Falling = Owner;
	          CWnd.CamPos = Owner.Location + vect(0,0,30);
	          CWnd.MyHudForFX = XIIIBaseHUD(XIIIPlayerController(lastDamagedBy.Controller).MyHud);
	          CWnd.Timer();
	          //Destroy();
	          //return;
	        }
	      }
	  }
  }

  r = Frand();

  if (index==0)
  {
    SetTimer(0.1,false);
    index++;
    Emitters[0].SpawnParticle(1);
  }
  else if (index<18)
  {
    if (lastType == 0)
      r -= 0.25f;
    else
      r += 0.25f;

    if (r < 0.5)
    {
      SetTimer(0.1,false);
      index++;
  	  Emitters[0].SpawnParticle(1);
  	  lastType = 0;
	  }
	  else
	  {
      SetTimer(0.1,false);
      index++;
  	  Emitters[1].SpawnParticle(1);
  	  lastType = 1;
	  }
  }
  else
  {
	destroy();
	}
}
event timer2()
{
	destroy();
}



defaultproperties
{
     Begin Object Class=SpriteEmitter Name=XIIIChuteEmiterA
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=198,G=255,R=255))
         ColorScale(1)=(relativetime=0.500000,Color=(R=255))
         ColorScale(2)=(relativetime=1.000000,Color=(B=187,G=187,R=255))
         MaxParticles=5
         StartLocationRange=(X=(Min=-50.000000,Max=-50.000000),Y=(Min=-34.000000,Max=34.000000),Z=(Min=50.000000,Max=78.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(relativetime=0.500000,RelativeSize=0.100000)
         SizeScale(2)=(relativetime=1.000000,RelativeSize=0.100000)
         StartSizeRange=(X=(Min=40.000000,Max=40.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=0.000100
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIIMenu.SFX.ALetterM'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         Name="XIIIChuteEmiterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDPawn.XIIIChuteEmiter.XIIIChuteEmiterA'
     Begin Object Class=SpriteEmitter Name=XIIIChuteEmiterH
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=198,G=255,R=255))
         ColorScale(1)=(relativetime=0.500000,Color=(R=255))
         ColorScale(2)=(relativetime=1.000000,Color=(B=187,G=187,R=255))
         MaxParticles=5
         StartLocationRange=(X=(Min=-50.000000,Max=-50.000000),Y=(Min=-34.000000,Max=34.000000),Z=(Min=50.000000,Max=78.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(relativetime=0.500000,RelativeSize=0.100000)
         SizeScale(2)=(relativetime=1.000000,RelativeSize=0.100000)
         StartSizeRange=(X=(Min=40.000000,Max=40.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=0.000100
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XIIIMenu.SFX.HLetterM'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         Name="XIIIChuteEmiterH"
     End Object
     Emitters(1)=SpriteEmitter'XIDPawn.XIIIChuteEmiter.XIIIChuteEmiterH'
     bActorLight=True
     bDynamicLight=True
     bDelayDisplay=True
     LightType=LT_Steady
     LightEffect=LE_TorchWaver
     LightBrightness=255
     LightHue=41
     LightSaturation=117
     LightRadius=50
}
