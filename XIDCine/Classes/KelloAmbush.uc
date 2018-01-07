//-----------------------------------------------------------
// KelloAmbush
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class KelloAmbush extends Triggers;

#exec Texture Import File=Textures\Rock_ico.pcx Name=Rock_ico Mips=Off

VAR()				Actor					ActorsToPeer[4];
VAR()				float					Pauses[4];
VAR()				Name					EventsToCast[5];
VAR					int						ActorToPeerIndex;
VAR		TRANSIENT	XIIIPlayerController	PC;
VAR					Rotator					Roto;
VAR()				float					RotationSpeed;
VAR					float					ActualRotationSpeed;
VAR()				float					LinearSpeed;

CONST RotationAcceleration=250;

AUTO STATE Init
{
	EVENT BeginState()
	{
		SetTimer(0.1,true);
	}
	
	EVENT Timer()
	{
		if (XIIIGameInfo(Level.Game).MapInfo!=none && XIIIGameInfo(Level.Game).MapInfo.XIIIController!=none)
		{
			PC=XIIIGameInfo(Level.Game).MapInfo.XIIIController;
			SetTimer( 0, false );
			GotoState( 'Waiting' );
		}

	}
}

STATE Waiting
{
	EVENT Trigger( actor Other, Pawn EventInstigator )
	{
		GotoState( 'LetsMove_01' );
	}
}

STATE LetsMove_01
{
	EVENT BeginState()
	{
		PC.GotoState( 'NoControl' );
		ActualRotationSpeed = 0;
	}

	EVENT Tick( float dt )
	{
		LOCAL Rotator r;
		LOCAL Vector v;

		v = Location-PC.Pawn.Location;
		v.Z = 0;

		ActualRotationSpeed= fMin( RotationSpeed, ActualRotationSpeed+RotationAcceleration*dt );
		Roto=ROTATOR( ActorsToPeer[0].Location+vect(0,0,10)-PC.Pawn.Location );

		r.Yaw   = Clamp( ( ( Roto.Yaw   - PC.Rotation.Yaw   + 32768 ) & 65535 ) - 32768, -ActualRotationSpeed*dt*182,ActualRotationSpeed*dt*182 );
		r.Roll  = Clamp( ( ( Roto.Roll  - PC.Rotation.Roll  + 32768 ) & 65535 ) - 32768, -ActualRotationSpeed*dt*182,ActualRotationSpeed*dt*182 );
		r.Pitch = Clamp( ( ( Roto.Pitch - PC.Rotation.Pitch + 32768 ) & 65535 ) - 32768, -ActualRotationSpeed*dt* 41,ActualRotationSpeed*dt* 41 );

		log ( vSize( v ) );
		if ( vSize(v)<1 && r.Yaw==0 )
		{
			TriggerEvent( event, Self, PC.Pawn );
			GotoState( 'LetsLook_02' );
			return;
		}

		PC.SetRotation( r + PC.Rotation );
		PC.Pawn.Velocity = fMin( vSize(v)/dt, linearspeed ) * Normal( v );
	}
}

STATE LetsLook_02
{
	EVENT BeginState( )
	{
		Roto=Rotator( ActorsToPeer[ActorToPeerIndex].Location+vect(0,0,10)-PC.Pawn.Location );
		if ( ActorToPeerIndex!=0 )
			ActualRotationSpeed = 0;
	}

	EVENT Tick( float dt )
	{
		LOCAL Rotator r;

		ActualRotationSpeed= fMin( RotationSpeed, ActualRotationSpeed+RotationAcceleration*dt );

		r.Yaw   = Clamp( ( ( Roto.Yaw   - PC.Rotation.Yaw   + 32768 ) & 65535 ) - 32768, -ActualRotationSpeed*dt*182,ActualRotationSpeed*dt*182 );
		r.Roll  = Clamp( ( ( Roto.Roll  - PC.Rotation.Roll  + 32768 ) & 65535 ) - 32768, -ActualRotationSpeed*dt*182,ActualRotationSpeed*dt*182 );
		r.Pitch = Clamp( ( ( Roto.Pitch - PC.Rotation.Pitch + 32768 ) & 65535 ) - 32768, -ActualRotationSpeed*dt* 41,ActualRotationSpeed*dt* 41 );

		PC.SetRotation( r + PC.Rotation );

		if ( r.Yaw==0 )
			GotoState( 'Pause_03' );
	}
}

STATE Pause_03
{
Begin:
	TriggerEvent( EventsToCast[ActorToPeerIndex], self, none );
	sleep( Pauses[ActorToPeerIndex] );
	ActorToPeerIndex++;
	if ( ActorToPeerIndex==4)
		GotoState( 'TheEnd' );
	else
		GotoState( 'LetsLook_02' );
}


STATE TheEnd
{
	EVENT BeginState( )
	{
		Roto = ROTATOR( ActorsToPeer[0].Instigator.Location+vect(0,0,10)-PC.Pawn.Location );
		ActualRotationSpeed = 0;
	}

	EVENT Tick( float dt )
	{
		LOCAL Rotator r;

		ActualRotationSpeed= fMin( RotationSpeed, ActualRotationSpeed+RotationAcceleration*dt );

		r.Yaw   = Clamp( ( ( Roto.Yaw   - PC.Rotation.Yaw   + 32768 ) & 65535 ) - 32768, -ActualRotationSpeed*dt*182,ActualRotationSpeed*dt*182 );
		r.Roll  = Clamp( ( ( Roto.Roll  - PC.Rotation.Roll  + 32768 ) & 65535 ) - 32768, -ActualRotationSpeed*dt*182,ActualRotationSpeed*dt*182 );
		r.Pitch = Clamp( ( ( Roto.Pitch - PC.Rotation.Pitch + 32768 ) & 65535 ) - 32768, -ActualRotationSpeed*dt* 41,ActualRotationSpeed*dt* 41 );

		PC.SetRotation( r + PC.Rotation );

		if ( r.Yaw==0 )
		{
			TriggerEvent( EventsToCast[ActorToPeerIndex], self, none );
			PC.GotoState( 'PlayerWalking' );
			PC.Pawn.Velocity = vect(0,0,0);
			PC.Pawn.Acceleration = vect(0,0,0);
			Destroy();
			return;
		}

	}
}



defaultproperties
{
     Pauses(0)=1.500000
     Pauses(1)=1.500000
     Pauses(2)=1.500000
     Pauses(3)=1.500000
     RotationSpeed=145.000000
     LinearSpeed=600.000000
     InitialState="Init"
     Texture=Texture'XIDCine.Rock_ico'
     bDirectional=True
}
