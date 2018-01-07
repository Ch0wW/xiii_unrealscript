//-----------------------------------------------------------
// Movable
// Created by iKi on ??? ??th 2001
// Last Modification Feb 27th 2002
//-----------------------------------------------------------
class Movable extends XIIIMovable;

VAR float t;

AUTO STATE() MovableState
{
	EVENT bool EncroachingOn( actor Other )
	{
		return false;
	}

	EVENT PostBeginPlay()
	{
		KeyNum=0;
		t=0;
	}

	EVENT Tick(float dt)
	{
		velocity.y=1000;
	}

	EVENT Bump( actor Other )
	{
		LOCAL Vector v;
		LOCAL Float PlayerAbscisse,s,d;

		v=KeyPos[1]-KeyPos[0];
		d=VSize(v);
		s=3/VSize(KeyPos[1]-KeyPos[0]);

		if (Pawn(Other).IsPlayerPawn())
		{
			SetPhysics(PHYS_Flying);

			if (Other.base!=self && abs(Normal(Other.Location-Location)dot Normal(v))>0.7) // don't move if player is on us
			{
				PlayerAbscisse=((Other.location-BasePos)dot v)/(d*d);
				t=((location-BasePos)dot v)/(d*d);
				log("bump" @ t @ " , " @ PlayerAbscisse);
				if (PlayerAbscisse<t)
				{
					t=FClamp(t+s,0,1);
//					velocity=Normal(v)*100;
					SetLocation(BasePos+t*(KeyPos[1]-KeyPos[0]));
//					log("Avance "@t);
				}
				else
				{
					t=FClamp(t-s,0,1);
					SetLocation(BasePos+t*(KeyPos[1]-KeyPos[0]));
//					log("Recule "@t);
				}

			}
		}
	}
/*
	event KeyFrameReached()
	{
		local int NextKey;
		if (KeyNum==NumKeys-1)
			NextKey=0;
		else
			NextKey=KeyNum+1;
		KeyRot[NextKey]-=KeyRot[KeyNum];
		KeyRot[NextKey].Yaw=((KeyRot[NextKey].Yaw+32768)&65535)-32768;
		KeyRot[NextKey].Roll=((KeyRot[NextKey].Roll+32768)&65535)-32768;
		KeyRot[NextKey].Pitch=((KeyRot[NextKey].Pitch+32768)&65535)-32768;
		KeyRot[NextKey]+=KeyRot[KeyNum];
		InterpolateTo(NextKey,MoveTime);
	}
Begin:
     DoOpen();
     FinishInterpolation();*/
}



defaultproperties
{
}
