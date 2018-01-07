//-----------------------------------------------------------
// Specific FX
// To be displayed for the USA02 Helico boss Destruction
//-----------------------------------------------------------
class CWndUSA02BossEnd extends CWndBase;

var int iPhase;

//_____________________________________________________________________________
event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(0.1, false);
}

//_____________________________________________________________________________
event Timer()
{
    iPhase ++;
    switch (iPhase)
    {
      Case 1:
        // Take view, Square
        MyHudForFX.CWndMat.Update( 0, 0, 128, 128, Owner.Location - vect(600,0,0), rotator(vect(600,0,0)), 90 );
//        AddWnd(10, 10, 128, 128, MyHudForFX.CWndMat, 0, 0, 128, 128, 0.7);
        SetTimer(0.5, false);
        break;
      Case 2:
        MyHudForFX.CWndMat.Update( 128, 0, 128, 128, Owner.Location - vect(600,-100,-50), rotator(vect(600,-100,-50)), 90 );
//        AddWnd(100, 50, 128, 128, MyHudForFX.CWndMat, 128, 0, 128, 128, 0.7);
        SetTimer(0.5, false);
        break;
      Case 3:
        MyHudForFX.CWndMat.Update( 0, 128, 128, 128, Owner.Location - vect(600,-200,-100), rotator(vect(600,-200,-100)), 90 );
//        AddWnd(170, 110, 128, 128, MyHudForFX.CWndMat, 0, 128, 128, 128, 0.7);
        SetTimer(0.5, false);
        break;
      Case 4:
        MyHudForFX.CWndMat.Update( 128, 128, 128, 128, Owner.Location - vect(600,-300,-150), rotator(vect(600,-300,-150)), 90 );
//        AddWnd(200, 210, 128, 128, MyHudForFX.CWndMat, 128, 128, 128, 128, 0.7);
        SetTimer(0.1, false);
        break;
      Case 5:
        AddWnd(10, 10, 128, 128, MyHudForFX.CWndMat, 0, 0, 128, 128, 1.2, false);
        Owner.PlaySound(hCWndSound, CWndSoundType);
        Settimer(0.1, false);
        break;
      Case 6:
        AddWnd(60, 50, 128, 128, MyHudForFX.CWndMat, 128, 0, 128, 128, 1.5, false);
        Owner.PlaySound(hCWndSound, CWndSoundType);
        Settimer(0.1, false);
        break;
      Case 7:
        AddWnd(100, 110, 128, 128, MyHudForFX.CWndMat, 0, 128, 128, 128, 1.8, false);
        Owner.PlaySound(hCWndSound, CWndSoundType);
        Settimer(0.1, false);
        break;
      Case 8:
        AddWnd(130, 210, 128, 128, MyHudForFX.CWndMat, 128, 128, 128, 128, 2.1, false);
        Owner.PlaySound(hCWndSound, CWndSoundType);
        Settimer(0.1, false);
        break;

/*      Case 5:
        MyHudForFX.CWndMat.Update( 0, 0, 128, 128, Owner.Location - vect(600,-500,-300), rot(0,0,0), 90 );
        AddWnd(210, 320, 128, 128, MyHudForFX.CWndMat, 0, 0, 128, 128, 0.7);
        SetTimer(0.5, false);
        break;
*/
      Case 9:
        Destroy();
        break;
    }
}



defaultproperties
{
     CWndSoundType=3
}
