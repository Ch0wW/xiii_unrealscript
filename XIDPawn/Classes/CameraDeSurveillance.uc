//-----------------------------------------------------------
// Camera de surveillance
// On utilise le timer pour les seuils de detection du perso
// On utilise le tick pour tourner.
//-----------------------------------------------------------
class CameraDeSurveillance extends Decoration;

//#EXEC OBJ LOAD FILE=MeshObjetsPickup.usx PACKAGE=MeshObjetsPickup

var() TriggerAlarme AlarmeObjectToRing;
var() float TimeBeforeWarn, TimeBetweenWarnAndAlert, DistanceDetection;
var() SurveillCamTarget Target1,Target2;
var() float RotationSpeed;
var int AlertLevel;
var XIIIPlayerPawn PawnToDetect;
var SurveillCamTarget CurTgt, NextTgt;
var float TimeMoved;
var Texture NoiseTex;
var texture TVScreen;
var StaticMesh CamVStatic, CamRStatic, CamJStatic;
var float scale;

//_____________________________________________________________________________
simulated event Trigger( Actor other, Pawn instigator )
{
    scale = 0.0;
}

//_____________________________________________________________________________
// ELR Render Overlay
simulated event RenderOverlays( canvas C )
{
    local float x,y;
    local eDrawType DT_mem;

    // WARN NO Level.Game on clients on-line
    if ( (level.game != none) && XIIIGameInfo(level.game).bRocketArena )
    {
      x = 320-160;
      y = 240-120+40;
    }
    else
    {
      x = 50;
      y = 50;
    }

    if ( ((Level.Game != none) && (Level.Game.DetailLevel < 2)) || (XIIIPlayerController(Instigator.controller).bRenderPortal))
    {
      RenderScreenOverlays( C );
      return;
    }

    scale = XIIIPlayerController(Instigator.controller).fCamViewPercent;
    if (scale < 0.01)
      return;
    //scale += 0.01;
    //if (scale > 1)
    //  scale = 1;
    C.SetPos(x-4,y-4);
    //C.DrawTile(texture'XIIIMenu.Blanc',320*scale+8,240*scale+8,0,0,1,1);

    XIIIPlayerController(Instigator.controller).bRenderPortal = true;
    DT_mem = DrawType;
    SetDrawType(DT_none);
    XIIIPlayerController(Instigator.controller).bBehindView = true;
    C.DrawPortal(x,y,320*scale,240*scale,self,location,rotation);
    XIIIPlayerController(Instigator.controller).bBehindView = false;
    SetDrawType(DT_mem);
    XIIIPlayerController(Instigator.controller).bRenderPortal = false;
}

//_____________________________________________________________________________
simulated function RenderScreenOverlays( canvas C )
{
    C.SetPos(0.0, 0.0);
    C.SetDrawColor(255,255,255,128);
    C.Style = ERenderStyle.STY_Alpha;
    C.DrawTile(NoiseTex,C.ClipX,C.ClipY,0,0,NoiseTex.USize*(Frand()+2),NoiseTex.VSize*(Frand()+2));
    DrawScreenBackground(C, -1,-1,C.ClipX,C.ClipY);
}

//_____________________________________________________________________________
simulated function DrawScreenBackground(Canvas C, float x, float y, float width, float height)
{
    C.SetDrawColor(255,255,255,255);
    C.SetPos(x+width*0.5, y);
    C.DrawTile(TVScreen, 0.5*width+1, 0.5*height+2, 01, 01, (TVScreen.USize-2), (TVScreen.VSize-2));
    C.SetPos(x, y);
    C.DrawTile(TVScreen, 0.5*width+2, 0.5*height+2, -01, 01, -(TVScreen.USize-2), (TVScreen.VSize-2));
    C.SetPos(x, y + 0.5 * height);
    C.DrawTile(TVScreen, 0.5*width+2, 0.5*height+1, -01, -01, -(TVScreen.USize-2), -(TVScreen.VSize-2));
    C.SetPos(x+0.5*width, y+0.5*height);
    C.DrawTile(TVScreen, 0.5*width+1, 0.5*height+1, 01, -01, (TVScreen.USize-2),-(TVScreen.VSize-2));
}

//_____________________________________________________________________________
function Bool CanISee(XIIIPlayerPawn P)
{
    if ( FastTrace(P.Location, Location)
      || FastTrace(P.Location+P.EyeHeight*vect(0,0,0.8), Location)
      || FastTrace(P.Location-P.EyeHeight*vect(0,0,0.8), Location) )
    {
      if ( ((normal(P.Location-Location) dot vector(rotation)) > 0.707 )
        && (vSize(P.Location-Location) < DistanceDetection) )
        return true;
    }
    return false;
}

//_____________________________________________________________________________
function Timer()
{
    Local actor HitActor;
    Local vector HitLoc, HitNorm;

    if ( AlertLevel==0 )
    {
      // Check here if player is visible then switch alertlevel
      foreach DynamicActors( class'XIIIPlayerPawn', PawnToDetect)
      {
        if ( ( PawnToDetect!=none) && CanISee(PawnToDetect) )
        {
          AlertLevel=1;
          StaticMesh = CamJStatic;
          SetTimer(TimeBeforeWarn,false);
          break;
        }
      }
    }
    else if ( AlertLevel==1 )
    {
      if ( (PawnToDetect!=none) && CanISee(PawnToDetect) )
      {
        AlertLevel=2;
        StaticMesh = CamRStatic;
        SetTimer(TimeBetweenWarnAndAlert, false);
      }
      else
      {
        AlertLevel=0;
        StaticMesh = CamVStatic;
        SetTimer(0.5, True);
      }
    }
    else
    {
      if ( (PawnToDetect!=none) && CanISee(PawnToDetect) )
      {
        // Touch alarm here
        if (AlarmeObjectToRing!=none)
        {
          XIIIPlayerController(PawnToDetect.controller).MyInteraction.TargetActor = AlarmeObjectToRing;
          AlarmeObjectToRing.Trigger(self, PawnToDetect);
        }
        AlertLevel=2;
        StaticMesh = CamRStatic;
        SetTimer(TimeBetweenWarnAndAlert, false);
      }
      else
      {
        AlertLevel=0;
        StaticMesh = CamVStatic;
        SetTimer(0.5, True);
      }
    }
}

//_____________________________________________________________________________
// FUCK Have to put all this here because it doesn't worked in PostBeginPlay...
auto state StartingState
{
Begin:
  AlertLevel=0;
  if ( DistanceDetection > 0 )
  {
    SetTimer(0.5, true);
    StaticMesh = CamVStatic;
  }
  if ( (Target1==none) || (Target2==none) )
    gotostate('SurveillCamFixedOrientation');
  else
    gotostate('SurveillCamMoving');
}

//_____________________________________________________________________________
state SurveillCamFixedOrientation
{
    Function BeginState()
    { // Set the camera rotation
      if ( Target1!=none )
        SetRotation(rotator(Target1.Location-Location));
      if ( Target2!=none )
        SetRotation(rotator(Target2.Location-Location));
      // No else, just keep our rotation
    }
}

//_____________________________________________________________________________
state SurveillCamMoving
{
    Function BeginState()
    { // Set the camera rotation
      CurTgt=Target1;
      NextTgt=target2;
      SetRotation(rotator(CurTgt.Location-Location));
    }
    function Tick(float DeltaTime)
    {
      local vector vTgt;

      if (AlertLevel == 0)
      {
        vTgt = (TimeMoved/RotationSpeed)*NextTgt.Location + (1-(TimeMoved/RotationSpeed))*CurTgt.Location;
        SetRotation(rotator(vTgt-Location));
        TimeMoved -= DeltaTime;
        if (TimeMoved<=0.0)
        {
          if (CurTgt == Target1)
          {
            CurTgt=Target2;
            NextTgt=target1;
            gotostate(GetStateName(), 'TwotoOne');
          }
          else
          {
            CurTgt=Target1;
            NextTgt=target2;
            gotostate(GetStateName(), 'OnetoTwo');
          }
        }
      }
    }
Begin:
  disable('tick');
  sleep(Target1.TimeToStayOnMe);
  TimeMoved=RotationSpeed;
  enable('tick');
OnetoTwo:
  disable('tick');
  sleep(Target1.TimeToStayOnMe);
  TimeMoved=RotationSpeed;
  enable('tick');
  goto('DoNothing');
TwotoOne:
  disable('tick');
  sleep(Target2.TimeToStayOnMe);
  TimeMoved=RotationSpeed;
  enable('tick');
  goto('DoNothing');
DoNothing:
}

//      NoiseTex=Texture'XIIIHual2.H2AnimTele01'
//     DrawType=DT_Mesh
//     Mesh=VertMesh'XIIIDeco.cameraM'
//     CamVTex=texture'XIIIMeshobjets.CameraV'
//     CamRTex=texture'XIIIMeshobjets.CameraR'
//     CamNTex=texture'XIIIMeshobjets.CameraN'
//     CamJTex=texture'XIIIMeshobjets.CameraJ'


defaultproperties
{
     TimeBeforeWarn=2.000000
     TimeBetweenWarnAndAlert=2.000000
     DistanceDetection=5000.000000
     RotationSpeed=2.000000
     NoiseTex=Texture'XIIICine.Bruit'
     TVScreen=Texture'XIIIMenu.HUD.tv_cacheA'
     CamVStatic=StaticMesh'MeshObjetsPickup.camera_vert'
     CamRStatic=StaticMesh'MeshObjetsPickup.camera_rouge'
     CamJStatic=StaticMesh'MeshObjetsPickup.camera_jaune'
     bStatic=False
     bStasis=False
     bInteractive=False
     bCollideActors=True
     bProjTarget=True
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'MeshObjetsPickup.Camera'
     bDirectional=True
}
