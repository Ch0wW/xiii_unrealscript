class TexOscillator extends TexModifier
	editinlinenew
	native;

enum ETexOscillationType
{
	OT_Pan,
	OT_Stretch
};

var Matrix M;
var() Float UOscillationRate;
var() Float VOscillationRate;
var() Float UOscillationPhase;
var() Float VOscillationPhase;
var() Float UOscillationAmplitude;
var() Float VOscillationAmplitude;
var() Float UCenter;
var() Float VCenter;
var() ETexOscillationType UOscillationType;
var() ETexOscillationType VOscillationType;
var Float CurPosU;
var Float CurPosV;

defaultproperties
{
     UOscillationRate=1.000000
     VOscillationRate=1.000000
     UOscillationAmplitude=0.100000
     VOscillationAmplitude=0.100000
}
