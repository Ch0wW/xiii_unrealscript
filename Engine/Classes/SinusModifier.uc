class SinusModifier extends Modifier
	noteditinlinenew
	native;

// Travelling from server to server.
enum ESinusAmplitudeFade
{
	SinFade_None,	   // No fade.
	SinFade_Negative,  // Fade to negative values.
	SinFade_Positive,  // Fade to positive values.
	SinFade_Both,      // Fade to negative and positives values.
};

var byte LastFrameCount;
var (Sinus) vector Amplitude;
var (Sinus) vector WaveLenghtX;
var (Sinus) vector WaveLenghtY;
var (Sinus) vector WaveLenghtZ;
var (Sinus) vector FreqOsci;
var (Sinus) ESinusAmplitudeFade AmplitudeFadeX;
var (Sinus) vector RndAmplitude;
var (Sinus) float RndAmpSpeed;
var (Sinus) float RndTimeVar;
var (Sinus) float RndTimeSpeed;
var transient float CurrentTime;
var transient float CurTimeSpeed;
var transient float CurAmplitude;
var transient float CurAmpSpeed;

defaultproperties
{
     Amplitude=(Z=10.000000)
     WaveLenghtZ=(X=1.000000,Y=1.000000)
     FreqOsci=(Z=1.000000)
}
