//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ForceFeedbackController extends Object within PlayerController
      native;

native function bool IsForceFeedbackEnable();
native function EnableForceFeedback(bool bEnable);
native function StartEffect(int iEffect, float fRumb1, float fRumb2, float fParam1, float fParam2, float fParam3, float fParam4, float fParam5 );

defaultproperties
{
}
