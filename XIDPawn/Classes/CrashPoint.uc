//=============================================================================
// CrashPoint.
//=============================================================================
class CrashPoint extends GenFRD;

var() bool bMakeCrashNoise; //son de crash quand touche sol ou eau



defaultproperties
{
     bMakeCrashNoise=True
     Texture=Texture'Engine.S_LookTarget'
}
