// Specific FX
// To be displayed for the USA02 Helico boss introduction
//-----------------------------------------------------------
class CWndUSA02BossIntro extends CWndBase;

var int iPhase;
var vector X,Y,Z;

//_____________________________________________________________________________
event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(0.1, false);
    GetAxes(Owner.Rotation, X,Y,Z);
}

//_____________________________________________________________________________
event Timer()
{
    iPhase ++;
    switch (iPhase)
    {
      Case 1:
        // Take Front View, ratio height=2*width
        MyHudForFX.CWndMat.Update( 0, 0, 256, 256, Owner.Location + X*900, rotator(-X-Y*0.5), 90 );
        // Take Front-Right view, square
        MyHudForFX.CWndMat.Update( 128, 0, 128, 128, Owner.Location + normal(X+Y)*600, rotator(-normal(X+Y)), 90 );
        // Take Right view, square
        MyHudForFX.CWndMat.Update( 128, 128, 128, 128, Owner.Location + Y*600, rotator(-Y), 90 );
        AddWnd(10, 10, 128, 276, MyHudForFX.CWndMat, 0, 0, 128, 256, 0.3, false);
        Owner.PlaySound(hCWndSound, CWndSoundType);
        SetTimer(0.1, false);
        break;
      Case 2:
        AddWnd(10+128+10, 10, 128, 128, MyHudForFX.CWndMat, 128, 0, 128, 128, 0.2, false);
        Owner.PlaySound(hCWndSound, CWndSoundType);
        SetTimer(0.1, false);
        break;
      Case 3:
        AddWnd(10+128+10+128+10, 10, 128, 128, MyHudForFX.CWndMat, 128, 128, 128, 128, 0.1, false);
        Owner.PlaySound(hCWndSound, CWndSoundType);
        SetTimer(0.1, false);
        break;
      Case 4:
        Level.Game.SetGameSpeed(1.0);
        Destroy();
        break;
    }
}



defaultproperties
{
     hCWndSound=Sound'XIIIsound.Vehicles__USABossHelico.USABossHelico__hSnapShot'
     CWndSoundType=3
}
