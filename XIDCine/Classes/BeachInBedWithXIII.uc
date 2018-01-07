//-----------------------------------------------------------
// BeachInBedWithXIII.uc
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class BeachInBedWithXIII extends Triggers;

#exec Texture Import File=Textures\Rock_ico.pcx Name=Rock_ico Mips=Off

VAR() Actor Pos01, Pos02;
VAR() bool bActive;
VAR Color clBlack, clGrey;
VAR bool bGo, bEnd, bAlreadyChanged;
VAR float TimeStamp;
VAR TRANSIENT XIIIPlayerController PC;
VAR TRANSIENT Cine2 Pam;
VAR TRANSIENT Vector vFinalPosition;

AUTO STATE Init
{
	EVENT BeginState()
	{
		if ( !bActive || (XIIIGameInfo(Level.Game).CheckPointNumber>1) )
			Destroy();
		else
			SetTimer( 0.1, true );
	}
	
	EVENT Timer()
	{
		if ( XIIIGameInfo( Level.Game ).MapInfo!=none && XIIIGameInfo( Level.Game ).MapInfo.XIIIController!=none)
		{
			PC=XIIIGameInfo(Level.Game).MapInfo.XIIIController;
			SetTimer( 0, false );
			PC.GotoState( 'NoControl' );
			PC.Pawn.Weapon.bOwnerNoSee=true;
			GotoState( 'Waiting' );
		}
	}
}

STATE Waiting
{
	EVENT BeginState( )
	{
		PC.FilterColor=clBlack;
		PC.FilterColorWanted=clBlack;
		Level.SetInjuredEffect( true, 0.1);
		SetTimer( 1.0, false );
		PC.Pawn.bCollideWorld=false;
		PC.Pawn.SetPhysics( PHYS_None );
	}

	EVENT Timer( )
	{
		bGo=true;
		TimeStamp=0;
		GotoState( , 'Blink' );
	}

	EVENT Tick( float dt )
	{
		LOCAL Rotator r;
		LOCAL float f;

		if (bGo)
		{
			TimeStamp+=dt;
			if ( PC.IsInState( 'NoControl' ) )
				PC.Pawn.SetLocation( Location-(PC.Pawn.EyeHeight)*vect(0,0,1) );

			f = FMin( 1.0, TimeStamp/4 );
			if (f!=1.0)
			{
				if ( !PC.IsInState( 'NoControl' ) )
				{
					PC.GotoState( 'NoControl' );
					PC.Pawn.bCollideWorld=false;
				}
				r=Pos01.Rotation*(1-f)+f*Pos02.Rotation;

				PC.SetRotation(r);
			}
			else
			{
				PC.SetRotation(Pos02.Rotation);
				GotoState( 'LookAtBimbo' );
			}
			if ( PC.IsInState( 'NoControl' ) )
				PC.Pawn.SetLocation( Location-(PC.Pawn.EyeHeight /*+ PC.Pawn.CollisionHeight*/)*vect(0,0,1) );
		}
	}
Blink:
	Level.SetInjuredEffect( false, 12);
	PC.FilterColorSpeed=5;
	PC.FilterColorWanted=clGrey;
	Sleep(0.2+0.2);
	PC.FilterColorSpeed=5;
	PC.FilterColorWanted=clBlack;
	Sleep(0.2+0.2);
	PC.FilterColorSpeed=5;
	PC.FilterColorWanted=clGrey;
	Sleep(0.2+0.5);
	PC.FilterColorSpeed=5;
	PC.FilterColorWanted=clBlack;
	Sleep(0.2+0.2);
	PC.FilterColorSpeed=5;
	PC.FilterColorWanted=clGrey;
	bEnd=true;
}

STATE LookAtBimbo
{
	EVENT BeginState( )
	{
		LOCAL Cine2 c;

		foreach DynamicActors(class'Cine2',c)
		{
			if (c.PawnName=="Pam")
			{
				Pam=c;
				break;
			}
		}
		Tag='mitraillage2';
		TimeStamp=0;
	}

	EVENT Timer( )
	{
		Spawn( class'aahhEmitter',,,Pam.GetBoneCoords('X LIPS').Origin + VECTOR(Pam.Rotation)*40);
	}

	EVENT Trigger(actor a,pawn p)
	{
		Spawn( class'aahhEmitter',,,Pam.GetBoneCoords('X LIPS').Origin + VECTOR(Pam.Rotation)*40);
		SetTimer( 0.75, false );
		if (Tag!='fin_mitraillage')
			Tag='fin_mitraillage';
		else
			GotoState( 'GetUpStandUp' );
	}

	EVENT Tick( float dt )
	{
		LOCAL VECTOR v;
		LOCAL Rotator r;
		LOCAL float f;

		v = Pam.GetBoneCoords('X NECK').Origin;
		if ( Pam.bIsDead )
		{
			TimeStamp+=dt;
			if ( TimeStamp>2 && TimeStamp<5.5 )
				v += vect( 0,0, 40 )+VECTOR( Pam.Rotation )*300;
		}

		r = rotator(v-Location);
		r-= Pos02.Rotation;
		r.yaw=Clamp(((r.yaw+32768)&65535)-32768,-6144,6144);
		r+= Pos02.Rotation;

		r = PC.Rotation*0.98+0.02*r;
		if ( PC.IsInState( 'NoControl' ) )
			PC.SetRotation(r);
//		LOG ( PC.Pawn.Physics );
//		PC.Pawn.SetPhysics( PHYS_None );

		/*		if( Pam.bIsDead )
		{
			GotoState( 'GetUpStandUp' );
		}*/
	}
}

STATE GetUpStandUp
{
	EVENT BeginState( )
	{
		LOCAL vector v;
		LOCAL Rotator r;
		v = VECTOR(PC.Rotation);//Pam.Location-PC.Pawn.Location;
		v.Z = 0;
		v = NORMAL(v);
		
		vFinalPosition = PC.Pawn.Location+100*v+80*VECT(0,0,1);
		TimeStamp=0;
	}
	
	EVENT Tick( float dt )
	{
		LOCAL Rotator r;
		LOCAL float f;

//		r.Yaw = PC.rotation.Yaw;
		r.Yaw = ROTATOR( Pam.Location+VECTOR(Pam.Rotation)*120- PC.Pawn.Location).Yaw;
		r.Roll = 0;
		TimeStamp+=dt;
		
		r = PC.Rotation*0.98+0.02*r;
		if (TimeStamp<5)
			r.Pitch = -8192*sin(0.628*TimeStamp);
		else
			r.Pitch = 0;

		f = 0.98**(dt*100);
		r.Pitch = PC.Rotation.Pitch *f+(1-f)*r.Pitch;
		PC.SetRotation(r);

		if ( PC.IsInState( 'NoControl' ) )
		{
			PC.Pawn.SetLocation( PC.Pawn.Location*f+(1-f)*vFinalPosition );
			if ( vSize(vFinalPosition-PC.Pawn.Location)<10 && TimeStamp>=5 )
			{
				PC.Pawn.bCollideWorld=true;
				PC.Pawn.SetPhysics( PHYS_Walking );
				PC.GotoState('PlayerWalking');
				PC.Pawn.Weapon.bOwnerNoSee=false;

				Destroy();
				return;
			}
		}
	}
}



defaultproperties
{
     bActive=True
     clGrey=(B=128,G=128,R=128)
     InitialState="Init"
     Texture=Texture'XIDCine.Rock_ico'
     bDirectional=True
}
