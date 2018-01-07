// ====================================================================
//
// ====================================================================

class USA02HelicoMuzzleFlash extends Effects;

var int TickCount;     // How long to display it

//var(MuzzleFlash) ELightType FlashLightType;
//var(MuzzleFlash) ELightEffect FlashLightEffect;
var(MuzzleFlash) bool bUseRandRotation;
var EDrawType MemDrawType;

//_____________________________________________________________________________
simulated event PostBeginPlay()
{
    MemDrawType=DrawType;
    SetDrawType(DT_None);
}

//_____________________________________________________________________________
simulated event Timer()
{
    SetDrawType(DT_None);
//     bHidden=true;
}

//_____________________________________________________________________________
simulated function Flash()
{
//    Log(self$" flashing, MemDrawType="$MemDrawType);
    GotoState('Visible');
}

//_____________________________________________________________________________
simulated state Visible
{
    simulated event Tick(float Delta)
    {
/*
      Log("RelativeLocation="$RelativeLocation);
      SetLocation(Controller(Owner).Pawn.Location + RelativeLocation);
*/
//      SetRotation(Owner.Rotation);
      if ( DrawType==DT_None )
        SetDrawType(MemDrawType);
      if (TickCount>2)
        gotoState('');
      TickCount++;
    }

    simulated function EndState()
    {
      SetDrawType(DT_None);
    }

    simulated function BeginState()
    {
      local Rotator R;
      local vector V;

      TickCount=0;

      R = RelativeRotation;
      if ( bUseRandRotation )
        R.roll = Rand(65535);
      SetRelativeRotation(R);

/*
      V=Default.DrawScale3D;
      V.X += frand() - 0.5;
      V.Y += frand() - 0.5;

      SetDrawScale3D(v);
*/
      SetDrawType(MemDrawType);
    }
}



defaultproperties
{
     bUseRandRotation=True
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'StaticExplosifs.MuzzleFlash_NMI'
     DrawScale=1.500000
}
