//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CineCombineSM extends SMAttached;

FUNCTION AttachTo(Pawn p)
{
	P.AttachToBone(self,'x r hand');
	SetRelativeLocation(vect(8,-4,0));
	SetRelativeRotation(rot(16384,-14000,0));
}



defaultproperties
{
     RelativeLocation=(X=8.000000,Y=-7.000000)
     RelativeRotation=(Roll=16384)
     StaticMesh=StaticMesh'Staticbanque.Bphone'
     DrawScale=0.730000
}
