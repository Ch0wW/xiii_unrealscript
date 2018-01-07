class TexPanner extends TexModifier
	editinlinenew
	native;

var Matrix M;
var() rotator PanDirection;
var() float PanRate;
var transient float CurPosU;
var transient float CurPosV;

defaultproperties
{
     PanRate=0.100000
}
