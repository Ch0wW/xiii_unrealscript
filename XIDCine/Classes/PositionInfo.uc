//=============================================================================
// PositionInfo
// Created by iKi on ??? ??th 2001
// Last Modification Mar 19th 2002 by iKi
//=============================================================================
class PositionInfo extends Info
	showcategories(Movement,Collision)
	placeable
	native;

#exec Texture Import File=Textures\PosInfo_ico.pcx Name=PosInfo_ico Mips=Off

VAR() bool bAutoZLocation;
VAR() float fAltitude;

event SetInitialState()
{
	Super.SetInitialState();

	if (bAutoZLocation)
	{
		AutoPosition( );
	}
//	bHidden = false;
//	RefreshDisplaying();
//	tag='PositionInfo';
}

native FUNCTION AutoPosition( );




defaultproperties
{
     bAutoZLocation=True
     fAltitude=178.000000
     Texture=Texture'XIDCine.PosInfo_ico'
     CollisionRadius=1.000000
     bDirectional=True
}
