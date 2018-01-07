//=============================================================================
// PlayerInput
// Object within playercontroller that manages player input.
// only spawned on client
//=============================================================================

class PlayerInput extends Object within PlayerController
  config(User)
  native
  transient;

var globalconfig	bool	bMaxMouseSmoothing;
var globalconfig	bool	bInvertMouse;

var bool bWasForward;	// used for doubleclick move
var bool bWasBack;
var bool bWasLeft;
var bool bWasRight;
var bool bEdgeForward;
var bool bEdgeBack;
var bool bEdgeLeft;
var bool bEdgeRight;
var bool bForceCrouch;    // Used to force crouching when going back from flashback

// Mouse smoothing
var globalconfig float MouseSensitivity;
var float SmoothMouseX, SmoothMouseY, BorrowedMouseX, BorrowedMouseY;
var globalconfig float MouseSmoothThreshold;
var float MouseZeroTime;

var	float DoubleClickTimer; // max double click interval for double click move
var globalconfig float	DoubleClickTime;

// XIII Added
var bool bUseSnapTimer;
var bool bDuckCheck;                  // Used for the duck SwitchMode
var int iDuckMem;                     // Used for the duck SwitchMode
var float fSnaptimer;
var float fInputRange, fPctWalkRun;
var float ViewTurnAcc;                // used to accelerate the view rotation
var float ViewTurnBoost;
var float ViewUpAcc;                // used to accelerate the view rotation
var float WeaponViewTurnAcc;          // used to accelerate the view rotation
var int iMemaTurnSign;                // used to accelerate the view rotation
var int iMemaLookUpSign;                // used to accelerate the view rotation

var array<float> MoveRange, TurnRange;
var float CurrentInput;
var int CurrentInputAngle;
var float CurrentTurnInput;
var int CurrentTurnInputAngle;
var globalconfig bool bCheckInputRanges;

CONST VIEWTURNACCSPEED=3;
CONST VIEWUPACCSPEED=3;
CONST VIEWTURNBOOSTSPEED=1.0;
CONST MAXBOOSTSPEED=1.0;
//

//=============================================================================
// Input related functions.

//_____________________________________________________________________________
// Postprocess the player's input.
/*  --> completely managed in the engine
event PlayerInput( float DeltaTime )
{
  DealWithXIIIInputEvent( DeltaTime );
  DealWithPlayerInputEvent( DeltaTime );

  // Handle walking.
  HandleWalking();
}
*/

//_____________________________________________________________________________
//native function DealWithPlayerInputEvent( float DeltaTime );
/* Old Script Code
	local float FOVScale, MouseScale, AbsSmoothX, AbsSmoothY, MouseTime;

	// Check for Double click move
	// flag transitions
	bEdgeForward = (bWasForward ^^ (aBaseY > 0));
	bEdgeBack = (bWasBack ^^ (aBaseY < 0));
	bEdgeLeft = (bWasLeft ^^ (aStrafe > 0));
	bEdgeRight = (bWasRight ^^ (aStrafe < 0));
	bWasForward = (aBaseY > 0);
	bWasBack = (aBaseY < 0);
	bWasLeft = (aStrafe > 0);
	bWasRight = (aStrafe < 0);

	// Smooth and amplify mouse movement
	FOVScale = DesiredFOV * 0.01111;
	MouseScale = MouseSensitivity * FOVScale;

	aMouseX *= MouseScale;
	aMouseY *= MouseScale;
	MouseTime = (Level.TimeSeconds - MouseZeroTime)/Level.TimeDilation;
	SmoothMouse(aMouseX, MouseTime, SmoothMouseX, BorrowedMouseX, AbsSmoothX);
	SmoothMouse(aMouseY, MouseTime, SmoothMouseY, BorrowedMouseY, AbsSmoothY);

	if ( (aMouseX != 0) || (aMouseY != 0) )
		MouseZeroTime = Level.TimeSeconds;

	// adjust keyboard and joystick movements
	aLookUp *= FOVScale;
	aTurn   *= FOVScale;

	// Remap raw x-axis movement.
	if( bStrafe!=0 ) // strafe
		aStrafe += aBaseX + SmoothMouseX;
	else // forward
		aTurn  += aBaseX * FOVScale + SmoothMouseX;
	aBaseX = 0;

	// Remap mouse y-axis movement.
	if( (bStrafe == 0) && (bAlwaysMouseLook || (bLook!=0)) )
	{
		// Look up/down.
		if ( bInvertMouse )
			aLookUp -= SmoothMouseY;
		else
			aLookUp += SmoothMouseY;
	}
	else // Move forward/backward.
		aForward += SmoothMouseY;

	SmoothMouseX = AbsSmoothX;
	SmoothMouseY = AbsSmoothY;

	if ( bSnapLevel != 0 )
	{
		bCenterView = true;
		bKeyboardLook = false;
	}
	else if (aLookUp != 0)
	{
		bCenterView = false;
		bKeyboardLook = true;
	}
	else if ( bSnapToLevel && !bAlwaysMouseLook )
	{
		bCenterView = true;
		bKeyboardLook = false;
	}

	// Remap other y-axis movement.
	if ( bFreeLook != 0 )
	{
		bKeyboardLook = true;
		aLookUp += 0.5 * aBaseY * FOVScale;
	}
	else
		aForward += aBaseY;
	aBaseY = 0;

	// scale inputs FIXME REMOVE
		aForward *= 4;
		aStrafe  *= 4;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 1;
*/
/* --> exists now only on C++ side
function SmoothMouse(float aMouse, float MouseTime, out float SmoothMouse, out float BorrowedMouse, out float AbsSmooth)
{
	AbsSmooth = SmoothMouse;
	if ( bMaxMouseSmoothing && (aMouse == 0) && (MouseTime < MouseSmoothThreshold) )
	{
		SmoothMouse = 0.5 * (MouseSmoothThreshold - MouseTime) * AbsSmooth/MouseSmoothThreshold;
		BorrowedMouse += SmoothMouse;
	}
	else
	{
		if ( (SmoothMouse == 0) || (aMouse == 0)
				|| ((SmoothMouse > 0) != (aMouse > 0)) )
		{
			SmoothMouse = aMouse;
			BorrowedMouse = 0;
		}
		else
		{
			SmoothMouse = 0.5 * (SmoothMouse + aMouse - BorrowedMouse);
			if ( (SmoothMouse > 0) != (aMouse > 0) )
			{
				if ( AMouse > 0 )
					SmoothMouse = 1;
				else
					SmoothMouse = -1;
			}
			BorrowedMouse = SmoothMouse - aMouse;
		}
		AbsSmooth = SmoothMouse;
	}
}
*/

//_____________________________________________________________________________
//native function DealWithXIIIInputEvent( float DeltaTime );
/* Old Script Code
    local float faTan, fDistFact;

    // DON'T PUT ANYTHING BEFORE THIS ELSE THE VALUES WILL NOT BE CALIBRATED VS fInputRange nor DeltaTime
    // Kill the PAD Input/FrameRate dependance
    aBaseY *= (DeltaTime / (0.05/3));
    if ( bInverseLook )
      aLookUp *= - (DeltaTime / (0.05/3)) * fLookSpeed;
    else
      aLookUp *= (DeltaTime / (0.05/3)) * fLookSpeed;
    aTurn *= (DeltaTime / (0.05/3)) * fLookSpeed;
    aStrafe *= (DeltaTime / (0.05/3));

    // Change turn input to have acceleration & boost w/ 'pure' turn command
    if ( aTurn > 0 )
    {
      if ( iMemaTurnSign < 0 )
      {
        ViewTurnAcc = 0.0;
        ViewTurnBoost = 0.0;
      }
      else
        ViewTurnAcc = fMin(ViewTurnAcc+DeltaTime*VIEWTURNACCSPEED, 1.0);
      if ( (ViewTurnAcc == 1) && (aTurn > 0.95*fInputRange) && (aBaseY < 0.05*fInputRange) )
        ViewTurnBoost = fMin(ViewTurnBoost+DeltaTime*VIEWTURNBOOSTSPEED, MAXBOOSTSPEED);
      else
        ViewTurnBoost = 0.0;

      iMemaTurnSign = 1;
      if ( aTurn > 0 )
      {
        if ( WeaponViewTurnAcc > 0 )
          WeaponViewTurnAcc = fMin(WeaponViewTurnAcc+DeltaTime*VIEWTURNACCSPEED, 1.0);
        else
          WeaponViewTurnAcc = fMin(WeaponViewTurnAcc+DeltaTime*VIEWTURNACCSPEED*2, 1.0);
      }
      else
      {
        if ( WeaponViewTurnAcc > 0 )
          WeaponViewTurnAcc = fMax(WeaponViewTurnAcc-DeltaTime*VIEWTURNACCSPEED*2, 0.0);
        else
          WeaponViewTurnAcc = fMin(WeaponViewTurnAcc+DeltaTime*VIEWTURNACCSPEED*2, 0.0);
      }
    }
    else if ( aTurn < 0 )
    {
      if ( iMemaTurnSign < 0 )
        ViewTurnAcc = fMin(ViewTurnAcc+DeltaTime*VIEWTURNACCSPEED, 1.0);
      else
      {
        ViewTurnAcc = 0.0;
        ViewTurnBoost = 0.0;
      }
      if ( (ViewTurnAcc == 1) && (aTurn < -0.95*fInputRange) && (aBaseY < 0.05*fInputRange) )
        ViewTurnBoost = fMin(ViewTurnBoost+DeltaTime*VIEWTURNBOOSTSPEED, MAXBOOSTSPEED);
      else
        ViewTurnBoost = 0.0;

      iMemaTurnSign = -1;
      if ( aTurn < 0 )
      {
        if ( WeaponViewTurnAcc > 0 )
          WeaponViewTurnAcc = fMax(WeaponViewTurnAcc-DeltaTime*VIEWTURNACCSPEED*2, -1.0);
        else
          WeaponViewTurnAcc = fMax(WeaponViewTurnAcc-DeltaTime*VIEWTURNACCSPEED, -1.0);
      }
      else
      {
        if ( WeaponViewTurnAcc > 0 )
          WeaponViewTurnAcc = fMax(WeaponViewTurnAcc-DeltaTime*VIEWTURNACCSPEED*2, 0.0);
        else
          WeaponViewTurnAcc = fMin(WeaponViewTurnAcc+DeltaTime*VIEWTURNACCSPEED*2, 0.0);
      }
    }
    else // no turn, reset ViewTurnAcc
    {
      ViewTurnAcc = fMax(ViewTurnAcc-DeltaTime*VIEWTURNACCSPEED*2, 0.0);
      ViewTurnBoost = 0.0;
      if ( WeaponViewTurnAcc > 0 )
        WeaponViewTurnAcc = fMax(WeaponViewTurnAcc-DeltaTime*VIEWTURNACCSPEED*2, 0.0);
      else
        WeaponViewTurnAcc = fMin(WeaponViewTurnAcc+DeltaTime*VIEWTURNACCSPEED*2, 0.0);
    }
    aTurn *= (ViewTurnBoost + ViewTurnAcc);

    // Reduce pad lookup sensibility while strafing
    if ( (ConfigType == CT_StrafeLookSameAxis) && (abs(aLookUp) < abs(aStrafe)) ) aLookUp = 0;
    if ( (ConfigType == CT_StrafeLookNotSameAxis) && (aStrafe != 0) )
    { // normalize the pad values as at 45 degrees the max are not attained (we have only 0.707* the max value)
      fAtan = atan(aBaseY / aStrafe); // Angle
      if ( abs(faTan) < pi/4.0 )
        fDistFact = abs(1.414 / cos(faTan));
      else
        fDistFact = abs(1.414 / sin(faTan));
      aStrafe *= fDistFact;
      aBaseY *= fDistFact;
    }
    if ( (ConfigType == CT_StrafeLookSameAxis) && (aTurn != 0) )
    { // normalize the pad values as at 45 degrees the max are not attained (we have only 0.707* the max value)
      fAtan = atan(aBaseY / aTurn); // Angle
      if ( abs(faTan) < pi/4.0 )
        fDistFact = abs(1.414 / cos(faTan));
      else
        fDistFact = abs(1.414 / sin(faTan));
      aTurn *= fDistFact;
      aBaseY *= fDistFact;
    }

    // do this to have same SpeedBase for all inputs and quite good movements.
    aTurn *= 2;
    aLookUp *= -2;

    // Map the keys onto the PadInput
    if ( bUp>0 ) aBaseY = fInputRange;
    if ( bDown>0 ) aBaseY = -fInputRange;
    if ( bLeft>0 ) aStrafe = -fInputRange;
    if ( bRight>0 ) aStrafe = fInputRange;

    // On a Ladder = No SnapLevel
    // Check pawn as it is no more available if dead.
    if ( (pawn!= none) && ( (Pawn.Physics == PHYS_Ladder) || (bFreeLook != 0) ) )
    {
      bSnapLevel = 0;
      bUseSnapTimer = False;
    }
    else if ( bWalkCenterView )
    {
      // AutoCenter only if moving (and not for the strafe) after 1.0 second.
      if ( aBaseY != 0 )
      {
        if ( !bUseSnapTimer )
        {
          bUseSnaptimer = True;
          fSnaptimer = DeltaTime;
        }
        else
          fSnaptimer += DeltaTime;
        if ( fSnaptimer>1.0 )
        {
          bSnapLevel = 1.0;
          bSnapToLevel = True;
        }
      }
      else
      {
        bSnapLevel = 0.0;
        bSnapToLevel = false;
        bUseSnapTimer = False;
      }
    }
    // Switch Walk/Run upon the Pad Input
    // (BEWARE [ bRun=1 ] = Walking and not running :)
    if ( (abs(aBaseY)<fPctWalkRun*fInputRange && abs(aStrafe)<fPctWalkRun*fInputRange) || (bAltRun != 0) )
      bRun=1;
    else
      bRun=0;

    // Handle alternate (switch on/off) duck mode
    if ( (pawn!= none) && (Pawn.Physics == PHYS_Walking) && (Level.Game != none) && Level.Game.bAltDuckMode )
    {
      // ::DBUG::
      //log(self$" bDuck="$bDuck$" bDuckCheck="$bDuckCheck$" iDuckMem="$iDuckMem);
      if ( (bAltDuck==1) && bDuckCheck )
      {
        bDuckCheck = false;
        iDuckMem = abs(iDuckMem-1);
      }
      else if ( bAltDuck==0 )
      {
        bDuckCheck = true;
      }
      bDuck = iDuckMem;
    }
    else
    {
      bDuck = bAltDuck;
      bDuckCheck = true;
      iDuckMem = 0;
    }
*/

//_____________________________________________________________________________
function UpdateSensitivity(float F)
{
  MouseSensitivity = FMax(0,F);
}

//_____________________________________________________________________________
function ChangeSnapView( bool B )
{
  bSnapToLevel = B;
}

//_____________________________________________________________________________
exec function SetMouseSmoothThreshold( float F )
{
  MouseSmoothThreshold = FClamp(F, 0, 0.1);
  SaveConfig();
}

//_____________________________________________________________________________
// check for double click move
function Actor.eDoubleClickDir CheckForDoubleClickMove(float DeltaTime)
{
	local Actor.eDoubleClickDir DoubleClickMove, OldDoubleClick;

	if ( DoubleClickDir == DCLICK_Active )
		DoubleClickMove = DCLICK_Active;
	else
		DoubleClickMove = DCLICK_None;
	if (DoubleClickTime > 0.0)
	{
		if ( DoubleClickDir < DCLICK_Active )
		{
			OldDoubleClick = DoubleClickDir;
			DoubleClickDir = DCLICK_None;

			if (bEdgeForward && bWasForward)
				DoubleClickDir = DCLICK_Forward;
			else if (bEdgeBack && bWasBack)
				DoubleClickDir = DCLICK_Back;
			else if (bEdgeLeft && bWasLeft)
				DoubleClickDir = DCLICK_Left;
			else if (bEdgeRight && bWasRight)
				DoubleClickDir = DCLICK_Right;

			if ( DoubleClickDir == DCLICK_None)
				DoubleClickDir = OldDoubleClick;
			else if ( DoubleClickDir != OldDoubleClick )
				DoubleClickTimer = DoubleClickTime + 0.5 * DeltaTime;
			else
				DoubleClickMove = DoubleClickDir;
		}

		if (DoubleClickDir == DCLICK_Done)
		{
			DoubleClickTimer -= DeltaTime;
			if (DoubleClickTimer < -0.35)
			{
				DoubleClickDir = DCLICK_None;
				DoubleClickTimer = DoubleClickTime;
			}
		}
		else if ((DoubleClickDir != DCLICK_None) && (DoubleClickDir != DCLICK_Active))
		{
			DoubleClickTimer -= DeltaTime;
			if (DoubleClickTimer < 0)
			{
				DoubleClickDir = DCLICK_None;
				DoubleClickTimer = DoubleClickTime;
			}
		}
	}
	return DoubleClickMove;
}

defaultproperties
{
     bMaxMouseSmoothing=True
     MouseSensitivity=3.000000
     MouseSmoothThreshold=0.070000
     DoubleClickTime=0.250000
     fInputRange=1150.000000
     fPctWalkRun=0.875000
     ViewTurnAcc=1.000000
}
