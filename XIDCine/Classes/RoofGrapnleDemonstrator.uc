//-----------------------------------------------------------
// RoofGrapnleDemonstrator
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class RoofGrapnleDemonstrator extends Triggers;

#exec Texture Import File=Textures\Rock_ico.pcx Name=Rock_ico Mips=Off

VAR()	Cine2					Jones;
VAR()	HookPoint				PointGrappin;
VAR()	Actor					XIIIPosition;
VAR(Sound) Sound				HookSelectSound, HookFireSound, HookStartSound, HookStopSound, HookLetSound;
VAR		Vector					WallNormal;
VAR		XIIIPlayerController	PC;
VAR		CineHook				Crochet;
VAR		CineHookLink			PremierFilin, DernierFilin;
VAR		float					TimeStamp, TaillePremierFilin;
VAR TRANSIENT int				MemCurrentScript;

CONST PlayerLinearSpeed=600;
CONST PlayerRotationSpeed=180;
CONST RotationAcceleration=245;
VAR TRANSIENT	float	ActualPlayerRotationSpeed;

CONST	LinkLength = 100.0;

//-----------------------------------------------------------

AUTO STATE STA_Init
{
	EVENT Trigger(actor Other,pawn EventInstigator)
	{
		GotoState('STA_Lets_the_show_begins');
	}
}

//-----------------------------------------------------------
/*FUNCTION float Magic(float f,float dt)
{
	return 1.0f - ((1.0f-f)**(150*dt));
}*/

FUNCTION bool LookAtJones(float dt)
{
	LOCAL rotator r, Roto;

	ActualPlayerRotationSpeed= fMin( PlayerRotationSpeed, ActualPlayerRotationSpeed+RotationAcceleration*dt );
	Roto=ROTATOR( Jones.Location+vect(0,0,10)-PC.Pawn.Location );

	r.Yaw   = Clamp( ( ( Roto.Yaw   - PC.Rotation.Yaw   + 32768 ) & 65535 ) - 32768, -ActualPlayerRotationSpeed*dt*182,ActualPlayerRotationSpeed*dt*182 );
	r.Roll  = Clamp( ( ( Roto.Roll  - PC.Rotation.Roll  + 32768 ) & 65535 ) - 32768, -ActualPlayerRotationSpeed*dt*182,ActualPlayerRotationSpeed*dt*182 );
	r.Pitch = Clamp( ( ( Roto.Pitch - PC.Rotation.Pitch + 32768 ) & 65535 ) - 32768, -ActualPlayerRotationSpeed*dt* 41,ActualPlayerRotationSpeed*dt* 41 );

	PC.SetRotation( r + PC.Rotation );
	if ( r.Yaw==0 && r.Pitch==0 && r.Roll==0)
	{
		ActualPlayerRotationSpeed=0;
		return true;
	}
	return false;
}

FUNCTION bool MoveToRightThePlace(float dt)
{
	LOCAL vector v;

	v = XIIIPosition.Location-PC.Pawn.Location;
	v.Z = 0;
	PC.Pawn.Velocity = fMin( vSize(v)/dt, PlayerLinearSpeed ) * Normal( v );
	if ( vSize( v )<1 )
		return true;
	return false;
}

STATE STA_Lets_the_show_begins
{

	EVENT BeginState()
	{
		// Player
		PC=XIIIGameInfo(Level.Game).MapInfo.XIIIController;
		PC.GotoState('NoControl');

		// Jones
		Jones.CineController.LockedActor=none;
		Jones.CineController.rWantedRotation=ROTATOR(-WallNormal);
		MemCurrentScript=Jones.CurrentScript;
		Jones.CurrentScript=-1;
	}

	EVENT Tick(float dt)
	{
		LOCAL bool a,b;

		a = MoveToRightThePlace(dt);
		b = LookAtJones(dt);
		if ( a && b )
			GotoState( 'STA_Look_the_demonstrator' );

/*		LOCAL Vector v;
		LOCAL Rotator r;

		v = Jones.Location-PC.Pawn.Location;
		v.Z = 0;
		r = ROTATOR(v);
		r-= PC.Rotation;
		r.Yaw   = ( ( r.Yaw   + 32768 ) & 65535 ) - 32768;
		r.Roll  = ( ( r.Roll  + 32768 ) & 65535 ) - 32768;
		r.Pitch = ( ( r.Pitch + 32768 ) & 65535 ) - 32768;
		PC.SetRotation( r * Magic(0.015,dt) + PC.Rotation );

		v = XIIIPosition.Location - PC.Pawn.Location;
		v.Z = 0;
		if ( vSize(v)>100 )
		{
			PC.Pawn.SetLocation( PC.Pawn.Location + Magic(0.005,dt) * v );
		}
		else
		{
			if ( Abs( r.Yaw ) < 100 )
				GotoState( 'STA_Look_the_demonstrator' );
		}*/
	}
}

//-----------------------------------------------------------

STATE STA_Look_the_demonstrator
{
	EVENT BeginState( )
	{
//		TriggerEvent( HookExitEvent, self, none );
		Jones.PlaySound( HookSelectSound );
 		Jones.PlayAnim( 'LanceGrappin', , 0.5 );
		Crochet = Spawn(class'CineHook',self,'Tag',Jones.GetBoneCoords('X R Finger1').Origin);

		Jones.AttachToBone( Crochet, 'X R Finger1');
		Crochet.SetRelativeLocation( vect( 2, -2, 8 ) );
		Crochet.SetRelativeRotation( rot( 16384, 0, 0 ) );
		SetTimer( 2.66, false );
		TimeStamp = 0;
	}

	EVENT Timer( )
	{
		LOCAL Vector v;

		v = 1200 * Normal( PointGrappin.Location - Crochet.Location );
		
		Jones.DetachFromBone( Crochet );
		Crochet.SetRotation( ROTATOR( PointGrappin.Location - Crochet.Location ) );
		PremierFilin = Spawn(class'CineHookLink',self,'Tag',Jones.GetBoneCoords('X R Finger1').Origin,Rotator(PointGrappin.Location-Crochet.Location));

		Crochet.Velocity=v;
		GotoState( 'STA_Demonstrator_CastHook' );
	}

	EVENT Tick(float dt)
	{
//		LOCAL Vector v;
//		LOCAL Rotator r;
		TimeStamp += dt;
//		v=Jones.GetBoneCoords('X').Origin-Jones.Location;
//		Jones.SetLocation(Jones.Location+v);

//		Jones.PrePivot-=v;
/*
		v = Jones.Location-PC.Pawn.Location;
		r = ROTATOR(v);
		r-= PC.Rotation;
		r.Yaw   = ( ( r.Yaw   + 32768 ) & 65535 ) - 32768;
		r.Roll  = ( ( r.Roll  + 32768 ) & 65535 ) - 32768;
		r.Pitch = ( ( r.Pitch + 32768 ) & 65535 ) - 32768;
		PC.SetRotation( r * Magic( 0.015, dt ) + PC.Rotation );*/
		LookAtJones(dt);
	}
}

//-----------------------------------------------------------

STATE STA_Demonstrator_CastHook
{
	EVENT BeginState()
	{
//		TriggerEvent( CastHookEvent, self, none );
		Jones.PlaySound( HookFireSound );
	}

	EVENT Tick(float dt)
	{
		LOCAL vector /*v,*/ vDir, vDown, vUp, vHand;
		LOCAL CineHookLink Filin;
//		LOCAL Rotator r;

		vHand = Jones.GetBoneCoords('X R Finger0').Origin;
		vUp = Crochet.Location;
		vDir = Normal(Crochet.Location - vHand);
		PremierFilin.SetRotation( rotator(vDir) );
		PremierFilin.SetLocation( vUp - Normal(vDir) * LinkLength * 0.5 );
		vDown = PremierFilin.Location + VECTOR(PremierFilin.Rotation) * 0.5 * LinkLength;

		Filin = PremierFilin.NextLink ;
		DernierFilin = PremierFilin;

		while ( Filin != none )
		{
			Filin.SetRotation( ROTATOR(vDir) );
			vUp = Filin.PrevLink.Location - VECTOR(Filin.PrevLink.Rotation) * 0.5 * LinkLength;
			vDown = vUp - VECTOR(Filin.Rotation)*0.5*LinkLength;

			Filin.SetLocation( Filin.PrevLink.Location - vDir * LinkLength );
			DernierFilin=Filin;
			Filin = Filin.NextLink ;
		}
		if ( vSize(vDown-vHand) > LinkLength )
		{
			DernierFilin.NextLink=Spawn(class'CineHookLink',,, DernierFilin.Location - VECTOR(DernierFilin.Rotation) * LinkLength,DernierFilin.Rotation);
			if ( DernierFilin.NextLink != none)
				DernierFilin.NextLink.PrevLink = DernierFilin;
		}
		if ( Crochet.Velocity.Z<1 )
			GotoState('STA_Demonstrator_goes_up');
/*
		v = Jones.Location-PC.Pawn.Location;
		v.Z = 0;
		r = ROTATOR(v);
		r-= PC.Rotation;
		r.Yaw   = ( ( r.Yaw   + 32768 ) & 65535 ) - 32768;
		r.Roll  = ( ( r.Roll  + 32768 ) & 65535 ) - 32768;
		r.Pitch = ( ( r.Pitch + 32768 ) & 65535 ) - 32768;
		PC.SetRotation( r * Magic( 0.015, dt ) + PC.Rotation );*/
		LookAtJones(dt);
	}
}

STATE STA_Demonstrator_goes_up
{
	EVENT BeginState()
	{
		Jones.SetPhysics( PHYS_Flying );
		Jones.LoopAnim( 'GrappinMonte',,0.5 );
		Jones.AirSpeed=600;
//		TriggerEvent( ClimbUpEvent, self, none );
		Jones.PlaySound( HookStartSound );
	}

	EVENT Tick(float dt)
	{
		LOCAL vector /*v,*/ vDir, vDown, vUp, vHand;
//		LOCAL Rotator r;
		LOCAL CineHookLink Filin;
		LOCAL int i;
		

		vHand = Jones.GetBoneCoords('X R Finger0').Origin;
		vUp = Crochet.Location;
		vDir = Normal(Crochet.Location - vHand);
		
		Jones.Velocity.X = 900 * vDir.X;
		Jones.Velocity.Y = 900 * vDir.Y;
		Jones.Velocity.Z = 450 * vDir.Z;

		PremierFilin.SetRotation( rotator(vDir) );
		PremierFilin.SetLocation( vUp - Normal(vDir) * LinkLength * 0.5 );
		vDown = PremierFilin.Location + VECTOR(PremierFilin.Rotation) * 0.5 * LinkLength;

		Filin = PremierFilin.NextLink;
		DernierFilin = PremierFilin;
		i=0;
		while ( Filin != none )
		{
			if (Filin.Location.Z<Jones.Location.Z)
			{
				Filin.SetRotation( Filin.Rotation+ 0.1*(ROTATOR(vDir)+ exp(i*0.05)*cos(0.7*i+Level.TimeSeconds)*rot(512,0,0) -Filin.Rotation));
				i++;
			}
			else
				Filin.SetRotation( ROTATOR(vDir) );
			vUp = Filin.PrevLink.Location - VECTOR(Filin.PrevLink.Rotation) * 0.5 * LinkLength;
			vDown = vUp - VECTOR(Filin.Rotation)*LinkLength;

			Filin.SetLocation( 0.5*(vUp+vDown) );
			DernierFilin=Filin;
			Filin = Filin.NextLink ;
		}

		if ( Crochet.Location.Z-Jones.Location.Z < 675 ) // 475
			GotoState('STA_Demonstrator_Swing_And_Jump');

		LookAtJones(dt);
/*
		v = Jones.Location-PC.Pawn.Location;
		r = ROTATOR(v);
		r-= PC.Rotation;
		r.Yaw= ((r.Yaw+32768)&65535)-32768;
		r.Roll= ((r.Roll+32768)&65535)-32768;
		r.Pitch= ((r.Pitch+32768)&65535)-32768;
		PC.SetRotation(r*Magic(0.045,dt)+PC.Rotation);*/
	}
}

STATE STA_Demonstrator_Swing_And_Jump
{
	EVENT BeginState()
	{
		Jones.PlayAnim( 'GrappinFin' );
		Jones.Velocity=WallNormal*-125; // 75
		TimeStamp=0;
		SetTimer( 2.0, false );
//		TriggerEvent( ClimbEndEvent, self, none );
		Jones.PlaySound( HookStopSound );
	}

	EVENT EndState()
	{
		LOCAL CineHookLink Filin, FilinSuivant;

		Filin=PremierFilin.NextLink;
		while (Filin!=none)
		{
			FilinSuivant=Filin.NextLink;
			Filin.Destroy();
			Filin=FilinSuivant;
		}
	}

	
	EVENT Tick(float dt)
	{
		LOCAL vector /*v,*/ vDir, vDown, vUp, vHand, ds3d;
//		LOCAL Rotator r;
		LOCAL CineHookLink Filin;
		LOCAL FLOAT ds;

		TimeStamp+=dt;
		vHand = Jones.GetBoneCoords('X R Finger0').Origin;
		vUp = Crochet.Location;
		vDir = Normal(Crochet.Location - vHand);
		
		ds= vSize(Crochet.Location - vHand)/LinkLength;

		ds3d = PremierFilin.DrawScale3D;
		ds3d.X = ds;
		PremierFilin.SetDrawScale3D( ds3d );

		PremierFilin.SetRotation( rotator(vDir) );
		PremierFilin.SetLocation( vUp - Normal(vDir) * LinkLength*ds * 0.5 );
		vDown = PremierFilin.Location + VECTOR(PremierFilin.Rotation) * 0.5 * LinkLength*ds;
		vDir = vect(0,0,1); 
		Crochet.SetRotation( PremierFilin.Rotation );

		Filin = PremierFilin.NextLink;
		DernierFilin = PremierFilin;

		while ( Filin != none )
		{
			Filin.SetRotation( Filin.Rotation+ 0.1*(ROTATOR(vDir)-Filin.Rotation));

			ds3d = Filin.DrawScale3D;
			ds3d.X = FMax(0.01,1-(TimeStamp*0.66));
			Filin.SetDrawScale3D( ds3d );
				
			vUp = Filin.PrevLink.Location - VECTOR(Filin.PrevLink.Rotation) * 0.5 * LinkLength * Filin.PrevLink.DrawScale3D.X;
			vDown = vUp - VECTOR(Filin.Rotation)*LinkLength*Filin.DrawScale3D.X;

			Filin.SetLocation( 0.5*(vUp+vDown) );
			DernierFilin=Filin;
			Filin = Filin.NextLink ;
		}

		LookAtJones(dt);
/*		v = Jones.Location-PC.Pawn.Location;
		r = ROTATOR(v);
		r-= PC.Rotation;
		r.Yaw   = ( ( r.Yaw   + 32768 ) & 65535 ) - 32768;
		r.Roll  = ( ( r.Roll  + 32768 ) & 65535 ) - 32768;
		r.Pitch = ( ( r.Pitch + 32768 ) & 65535 ) - 32768;
		PC.SetRotation(r*Magic(0.015,dt)+PC.Rotation);*/
	
	}
	EVENT Timer()
	{
		GotoState('STA_Retract');
	}

}

STATE STA_Retract
{
	EVENT BeginState()
	{
		TimeStamp=0;
		TaillePremierFilin=PremierFilin.DrawScale3D.X;
		PC.GotoState('PlayerWalking');
		SetTimer( 1.5, false );
//		TriggerEvent( HookOffEvent, self, none );
		Jones.PlaySound( HookStopSound );
	}

	EVENT Tick(float dt)
	{
		LOCAL vector vDir, vDown, vUp, vHand, ds3d;
		LOCAL CineHookLink Filin;
		LOCAL FLOAT ds;

		TimeStamp+=dt;
		vHand = Jones.GetBoneCoords('X R Finger0').Origin;
		vDir = VECTOR(PremierFilin.Rotation);
		vUp = vHand+ vDir*ds3d.X*LinkLength;

		ds3d = PremierFilin.DrawScale3D;
		ds3d.X = FMax(0.01,(1-(TimeStamp*1.0))*TaillePremierFilin);
		PremierFilin.SetDrawScale3D( ds3d );

		PremierFilin.SetLocation( vHand + vDir*ds3d.X*0.5*LinkLength);
		Crochet.SetLocation( vHand + vDir*ds3d.X*LinkLength );
	}

	EVENT Timer()
	{
		PremierFilin.Destroy();
		Crochet.Destroy();
		Jones.SetPhysics(PHYS_Walking);
		Jones.DropToGround();
		Jones.SetLocation(Jones.GetBoneCoords('X').Origin);
		Jones.LoopAnim('WaitNeutre',,0.5);
		Jones.CurrentScript=MemCurrentScript;
		TriggerEvent(event,none,none);
		Destroy();
	}
}



defaultproperties
{
     HookFireSound=Sound'XIIIsound.SpecActions__JonesHook.JonesHook__hFire'
     HookStartSound=Sound'XIIIsound.SpecActions__JonesHook.JonesHook__hStartLoop'
     HookStopSound=Sound'XIIIsound.SpecActions__JonesHook.JonesHook__hStopLoop'
     WallNormal=(X=-1.000000)
     Texture=Texture'XIDCine.Rock_ico'
}
