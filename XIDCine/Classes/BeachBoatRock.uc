//-----------------------------------------------------------
// BeachBoatRock
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class BeachBoatRock extends Triggers;

#exec Texture Import File=Textures\Rock_ico.pcx Name=Rock_ico Mips=Off

CONST StaggerringTime=1;
//CONST FloatingTime=11;
CONST FeedBackPitch=-4096;
VAR() Sound EndMusic;
VAR float WaterHeight;
VAR TRANSIENT XIIIPlayerController PC;
VAR TRANSIENT Pawn Player;
VAR TRANSIENT float TimeStamp;
VAR TRANSIENT Color BaseFlashColor, CurrentFlashColor;
VAR TRANSIENT Vector vSpeed;
VAR bool bUnderwater, bPosOK, bRotOK;
VAR Color MyFlashColor;

EVENT PostBeginPlay()
{
}
/*
AUTO STATE Init
{
	EVENT BeginState()
	{
		SetTimer(0.1,true);
	}
	
	EVENT Timer()
	{
		if (XIIIGameInfo(Level.Game).MapInfo!=none && XIIIGameInfo(Level.Game).MapInfo.XIIIController!=none && XIIIGameInfo(Level.Game).MapInfo.XIIIController.Pawn!=none)
		{
			PC=XIIIGameInfo(Level.Game).MapInfo.XIIIController;
			Player=PC.Pawn;
			LOG ( "PLAYER ="@Player$", XIIIPawn ="@XIIIGameInfo(Level.Game).MapInfo.XIIIPawn );
			SetTimer( 0, false );
			GotoState( 'Waiting' );
		}
	}
}*/

AUTO STATE Waiting
{
	EVENT Trigger( Actor Other, Pawn EventInstigator )
	{
//		if ( Pawn(Other)!=none && Pawn(Other).IsPlayerPawn() )
		GotoState( 'LetsRock_01_GoNearTheEdge' );
	}

	EVENT Touch( Actor Other )
	{
		if ( Pawn(Other)!=none && Pawn(Other).IsPlayerPawn() )
			GotoState( 'LetsRock_01_GoNearTheEdge' );
	}
}

FUNCTION float Magic(float f, float dt)
{
	return 1.0f - ((1.0f-f)**(150*dt));
}

STATE LetsRock_01_GoNearTheEdge
{
	EVENT BeginState()
	{
		PC=XIIIGameInfo(Level.Game).MapInfo.XIIIController;
		Player=PC.Pawn;
		LOG ( "PLAYER ="@Player$", XIIIPawn ="@XIIIGameInfo(Level.Game).MapInfo.XIIIPawn );

		TimeStamp=0;
		PC.GotoState( 'NoControl' );
		Player.SetPhysics( PHYS_None );
		bRotOK = false;
		bPosOk = false;
	}
	EVENT Tick( float dt )
	{
		LOCAL Rotator r, rWanted;
		LOCAL Vector v;
		LOCAL float f, fLimitAngle;

		TimeStamp+=dt;

		f = FMin( 1.0, TimeStamp/StaggerringTime );
		if (f==1 && Player.bCollideWorld )
			Player.bCollideWorld=false;

		CurrentFlashColor = (1-f)*BaseFlashColor+f*MyFlashColor;
		PC.Region.Zone.FlashEffectDesc.LayerColor=CurrentFlashColor;


		PC.DesiredFOV=85+2*cos(2.5*TimeStamp);
		PC.SetRotation(r*Magic(0.015,dt)+PC.Rotation);

		if ( !bRotOK )
		{
			rWanted.Yaw   = Rotation.Yaw;
			rWanted.Roll  = 1024 * cos( 3 * TimeStamp );
			rWanted.Pitch = FeedBackPitch - 1024 * sin( 2 * TimeStamp );
			r       = rWanted - PC.Rotation;
			
			fLimitAngle = 182*80*dt;

			r.Yaw   = ( ( r.Yaw   + 32768 ) & 65535 ) - 32768;
			r.Roll  = ( ( r.Roll  + 32768 ) & 65535 ) - 32768;
			r.Pitch = ( ( r.Pitch + 32768 ) & 65535 ) - 32768;

			if ( abs(r.Yaw)<fLimitAngle /*&& abs(r.Pitch)<fLimitAngle && abs(r.Roll)<fLimitAngle*/ )
			{
				bRotOK = true;
				PC.SetRotation( rWanted );
			}
			else
			{
				r.Yaw   = Clamp( r.Yaw  , -fLimitAngle, fLimitAngle );
				r.Roll  = Clamp( r.Roll , -fLimitAngle, fLimitAngle );
				r.Pitch = Clamp( r.Pitch, -fLimitAngle, fLimitAngle );
				PC.SetRotation( PC.Rotation + r );
			}
		}

		if ( !bPosOK )
		{
			v = Location-Player.Location;
			v.Z = 0;
			if ( vSize(v)>10 )
			{
				Player.SetLocation( Player.Location + 320*dt*Normal(v) );
			}
			else
			{
				Player.SetLocation( Player.Location + v*dt );
				bPosOK = true;
			}
		}

		if ( bPosOK && bRotOk )
			GotoState( 'LetsRock_02_Swing' );

	}		
}

STATE LetsRock_02_Swing
{
	EVENT BeginState()
	{
		vSpeed=500*Vector(Rotation);
		TimeStamp=0;
		bRotOK = false;
		bPosOk = false;
	}

	EVENT Tick( float dt )
	{
		LOCAL Rotator r, rWanted;
		LOCAL Vector v;
		LOCAL float fLimitAngle;

		if ( !bUnderwater && PC.IsInState('PlayerSwimming'))
		{
			bUnderwater=true;
//			PC.GotoState( 'NoControl' );
			vSpeed = vect(0,0,0); //Magic( 0.95, dt );
			bPosOk=true;
//			if ( vSize(vSpeed)<10 )
			GotoState( 'LetsRock_03_Floating' );
		}

		TimeStamp+=dt;

		if ( !bRotOK )
		{
			if ( !bUnderWater /*Player.Location.Z>WaterHeight*/ )
			{
				rWanted = Rotation;
				rWanted.Pitch = FeedBackPitch-65535*TimeStamp;
			}
			else
				rWanted=Rotator(Location-Player.Location);

			r = rWanted - PC.Rotation;
			r.Yaw   = ( ( r.Yaw   + 32768 ) & 65535 ) - 32768;
			r.Roll  = ( ( r.Roll  + 32768 ) & 65535 ) - 32768;
			r.Pitch = ( ( r.Pitch + 32768 ) & 65535 ) - 32768;
			
			fLimitAngle = 182*180*dt;

			r.Yaw   = ( ( r.Yaw   + 32768 ) & 65535 ) - 32768;
			r.Roll  = ( ( r.Roll  + 32768 ) & 65535 ) - 32768;
			r.Pitch = ( ( r.Pitch + 32768 ) & 65535 ) - 32768;

			if ( abs(r.Yaw)<fLimitAngle /*&& abs(r.Pitch)<fLimitAngle && abs(r.Roll)<fLimitAngle*/ )
			{
				bRotOK = true;
				PC.SetRotation( rWanted );
			}
			else
			{
				r.Yaw   = Clamp( r.Yaw  , -fLimitAngle, fLimitAngle );
				r.Roll  = Clamp( r.Roll , -fLimitAngle, fLimitAngle );
				r.Pitch = Clamp( r.Pitch, -fLimitAngle, fLimitAngle );
				PC.SetRotation( PC.Rotation + r );
			}
		}


		Player.SetLocation( Player.Location + vSpeed*dt );

		if ( bUnderwater )
		{
		}
		else
			vSpeed-=vect(0,0,950)*dt;
	}		

}

STATE LetsRock_03_Floating
{
	EVENT BeginState( )
	{
		LOCAL Vector v;

		TimeStamp=0;
		vSpeed = vector(Rotation);
		vSpeed.Z = 0;
		vSpeed = 280*Normal(vSpeed);
//		SetTimer( FloatingTime, false );
		PlayMusic( EndMusic );
	}

	EVENT Tick( float dt )
	{
		LOCAL Rotator r, rWanted;
		LOCAL Vector v;
		LOCAL float f, fLimitAngle;

		if ( PC.IsInState('PlayerSwimming') )
		{
			PC.GotoState( 'NoControl' );
		}

		TimeStamp+=dt;
		rWanted = Rotator(Location-Player.Location);
		rWanted.Roll+=1024*cos(3*TimeStamp);
		rWanted.Pitch-=1024*sin(2*TimeStamp);

		r = rWanted - PC.Rotation;
		r.Yaw   = ( ( r.Yaw   + 32768 ) & 65535 ) - 32768;
		r.Roll  = ( ( r.Roll  + 32768 ) & 65535 ) - 32768;
		r.Pitch = ( ( r.Pitch + 32768 ) & 65535 ) - 32768;
		
		fLimitAngle = 182*180*dt;

		r.Yaw   = ( ( r.Yaw   + 32768 ) & 65535 ) - 32768;
		r.Roll  = ( ( r.Roll  + 32768 ) & 65535 ) - 32768;
		r.Pitch = ( ( r.Pitch + 32768 ) & 65535 ) - 32768;

		r.Yaw   = Clamp( r.Yaw  , -fLimitAngle, fLimitAngle );
		r.Roll  = Clamp( r.Roll , -fLimitAngle, fLimitAngle );
		r.Pitch = Clamp( r.Pitch, -fLimitAngle, fLimitAngle );
		PC.SetRotation( PC.Rotation + r );

		PC.DesiredFOV=85+2*cos(2.5*TimeStamp);

		v = Player.Location + vSpeed*dt;
		v.Z = WaterHeight+20*cos(TimeStamp);
		Player.SetLocation( v );
		if ( Level.FlashManager!=none && Level.FlashManager.IsInState('FinExtroFlash') )
		{
			Player.bCollideWorld=true;
			PC.DesiredFOV=PC.DefaultFOV;
			Destroy();
		}
	}
/*
	EVENT Timer()
	{
		Player.bCollideWorld=true;
		Destroy();
	}*/
}



defaultproperties
{
     EndMusic=Sound'XIIIsound.Music__Plage00.Plage00__hFlashOff'
     WaterHeight=4400.000000
     MyFlashColor=(R=255)
     InitialState="Waiting"
     Texture=Texture'XIDCine.Rock_ico'
     bDirectional=True
}
