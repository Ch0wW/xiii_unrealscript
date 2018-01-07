//-=-=-=-=-=-=-=-=-=-=-=-=-=-
// GenFlash
//     Created by iKi
// Last Modification by iKi
//-=-=-=-=-=-=-=-=-=-=-=-=-=-

#exec Texture Import File=Textures\flash_ico.tga Name=Flash_ico Mips=Off

class GenFlash extends Info
	placeable;

STRUCT structFlash
{
    VAR()			Actor	StartReference;
    VAR()			Actor	ArrivalReference;
	VAR	TRANSIENT	bool	bMemDuck;
};

VAR(Flash)		structFlash Flash[4];			 // max number of flashes
VAR(Flash)		Actor ViewFocus[4];
VAR(Flash)		float FeedBackFlashEndDuration;
VAR(Flash)		name EventBeginBeginFlash, EventBeginEndFlash,EventEndBeginFlash, EventEndEndFlash, EventPostFeedback;
VAR TRANSIENT	float alpha;
VAR TRANSIENT	int			IndexCurrentFlash;
VAR TRANSIENT	XIIIPlayerController PC;
VAR TRANSIENT	XIIIPawn Player;

VAR	TRANSIENT	Vector	MemPos;
VAR	TRANSIENT	Rotator	MemRot;
VAR TRANSIENT	int count;
VAR TRANSIENT	float MemSpeedFactorLimit;
VAR TRANSIENT	ZoneInfo PlayerZone;
VAR				bool bGod;

EVENT PostBeginPlay()
{
	Level.FlashManager=self;
}

EVENT BeginBeginFlash()
{
	count++;
	GotoState('IntroFlash');
}

EVENT EndBeginFlash()
{
	count++;
	GotoState('FinIntroFlash');
}

EVENT BeginEndFlash()
{
	count++;
	IndexCurrentFlash=0;
	GotoState('ExtroFlash');
}

EVENT EndEndFlash()
{
	count=0;
	GotoState('FinExtroFlash');
}

EVENT Trigger( actor Other, pawn EventInstigator )
{
// FOR DEBUG
	if ( EventInstigator.IsA('XIIIPlayerPawn') )
	{
		switch (count%2)
		{
		case 0:
			BeginBeginFlash();
			break;
		case 1:
			EndBeginFlash();
			break;
		}
	}
	else
	{
		switch (count)
		{
		case 0:
			BeginBeginFlash();
			break;
		case 1:
			EndBeginFlash();
			break;
		case 2:
			BeginEndFlash();
			break;
		case 3:
			EndEndFlash();
			break;
		}
	}

}

STATE IntroFlash
{
	EVENT BeginState()
	{
		if (PC==none)
		{
			PC = XIIIGameInfo( Level.Game ).MapInfo.XIIIController;
			Player = XIIIPawn( PC.Pawn );
		}
		Flash[ IndexCurrentFlash ].bMemDuck = Player.bIsCrouched;
		if ( IndexCurrentFlash == 0 )
		{
			bGod = PC.bGodMode;
			PC.bGodMode = true;
			MemSpeedFactorLimit = Player.SpeedFactorLimit;
		}
		if ( ViewFocus[ IndexCurrentFlash ]==none )
			Disable( 'Tick' );
		SetTimer( 10, false );
	}
	EVENT Timer()
	{
		EndBeginFlash();
	}
	EVENT EndState()
	{
		SetTimer( 0, false );

	}
	EVENT Tick(float dt)
	{
		LOCAL rotator r;
		CONST rotationspeed=80;

		if ( PC.IsInState( 'NoControl' ) )
		{
			r=rotator(ViewFocus[ IndexCurrentFlash ].Location-(Player.Location+Player.EyePosition()))-PC.Rotation;
			r.Yaw=Clamp( ((r.Yaw+32768)&65535)-32768, -rotationspeed*dt*182,rotationspeed*dt*182 );
			r.Roll=Clamp( ((r.Roll+32768)&65535)-32768, -rotationspeed*dt*182,rotationspeed*dt*182 );
			r.Pitch=Clamp( ((r.Pitch+32768)&65535)-32768, -rotationspeed*dt*182,rotationspeed*dt*182 );
			PC.SetRotation(PC.Rotation+r);
			Player.SetRotation(PC.Rotation);
		}
	}
begin:
	Sleep(0.2);
	if ( IndexCurrentFlash==0 )
		XIIIGameInfo( Level.Game ).MapInfo.SaveInventoryForFlash( Player );
    Player = XIIIPawn( PC.Pawn ); // <= Fake Flash Player Pawn
	PC.GotoState('NoControl');
	Player.SetPhysics( PHYS_None );
	Player.SpeedFactorLimit = 1.0;
	Player.SetGroundSpeed( 1.0 );
	PC.StopFiring();
	Level.bCineFrame = false; // No frame with flashes
	PC.ConstantGlowFog =vect(1,1,1);
	PC.ConstantGlowScale =-3;
	Sleep(0.1);
	PC.ConstantGlowScale =0;
	Sleep(0.2);
	PC.ConstantGlowScale =-3;
	Sleep(0.1);
	PC.ConstantGlowScale =0;
	Sleep(0.5);
	PC.ConstantGlowScale =-3;
	Sleep(0.1);
	PC.ConstantGlowScale =0;
	Sleep(0.2);
	PC.ConstantGlowScale =-5;
	Sleep(0.1);
	PC.ConstantGlowScale =0;
	Sleep(0.5);

	PC.FilterColorWanted.R=255;
	PC.FilterColorWanted.G=255;
	PC.FilterColorWanted.B=255;
	PC.FilterColorSpeed=1;
//	PC.ClientFlash( -3.2, vect(2550,2550,2550));
	PC.DesiredFlashScale=2.0;
	PC.ConstantGlowScale=-1.0;
	PC.ConstantGlowFog=vect(0.5,0.5,0.5);

	if ( /*EventBeginBeginFlash!='' &&*/ IndexCurrentFlash==0 || !(Level.Title~="Plage00") )
		TriggerEvent( EventBeginBeginFlash, none, none);
}

STATE FinIntroFlash
{
	EVENT BeginState( )
	{
		LOCAL Actor RefDepart;
		LOCAL Actor RefArrivee;

		RefDepart = Flash[ IndexCurrentFlash ].StartReference;
		RefArrivee = Flash[ IndexCurrentFlash ].ArrivalReference;

		if (RefArrivee!=none)
		{
			if (RefDepart==none)
			{
				if ( IndexCurrentFlash == 0 )
				{
					MemPos = Player.Location;
					MemRot = PC.Rotation;
				}
				PC.SetLocation( RefArrivee.Location );
				Player.SetLocation( RefArrivee.Location );
				Player.ShouldCrouch(false);
				Player.EndCrouch(Player.CollisionHeight - Player.CrouchHeight);
				PC.SetRotation( RefArrivee.Rotation );
				Player.SetRotation( RefArrivee.Rotation );
			}
			else
			{
				if ( IndexCurrentFlash == 0 )
				{
					MemPos = Player.Location;
					MemRot = PC.Rotation;
				}
				PC.SetLocation( Player.Location + RefArrivee.Location - RefDepart.Location );
				Player.SetLocation( PC.Location );
//				PC.SetRotation(RefArrivee.Rotation);
//				Player.SetRotation(RefArrivee.Rotation);
			}
		}
		if ( Event != '' )
			TriggerEvent( Event, self, none );
	}
begin:
	PC.GotoState( 'PlayerWalking' );
//	if (Flash[IndexCurrentFlash].bMemDuck /*&& !PC.bWantsToCrouch*/)
//	{
//		sleep(1);
//		PC.bAltDuck = 1;
//		sleep(0.1);
//		PC.bAltDuck = 0;
//	}
//	PC.bAltDuck = 0;
	PC.FilterColorWanted.R = 128;
	PC.FilterColorWanted.G = 128;
	PC.FilterColorWanted.B = 128;
	PC.FilterColorSpeed = 1;
	PC.ConstantGlowScale = 0;
	PC.ConstantGlowFog = vect( 0.5, 0.5, 0.5 );
	IndexCurrentFlash++;
	if ( EventEndBeginFlash!='' /*&& IndexCurrentFlash==0*/)
		TriggerEvent( EventEndBeginFlash, none, none);
}

STATE ExtroFlash
{
	EVENT BeginState()
	{
		SetTimer( 10, false );
	}
	EVENT Timer()
	{
		EndEndFlash();
	}
	EVENT EndState()
	{
		SetTimer( 0, false );

	}
begin:
	Sleep( 0.2 );
	PC.GotoState( 'NoControl' );
	Level.bCineFrame = false; // No frame with flashes
	PC.FilterColorWanted.R = 255;
	PC.FilterColorWanted.G = 255;
	PC.FilterColorWanted.B = 255;
	PC.FilterColorSpeed = 1;
	PC.DesiredFlashScale = 2.0;
	PC.ConstantGlowScale = -1.0;
	PC.ConstantGlowFog = vect( 0.5, 0.5, 0.5 );
	if ( EventBeginEndFlash!='')
		TriggerEvent( EventBeginEndFlash, none, none);
}

FUNCTION InitPlayerZone()
{
	PlayerZone = PC.Pawn.region.Zone;
	PlayerZone.FlashEffectDesc.IsActivated = true;
	PlayerZone.FlashEffectDesc.Contrast = 0;
	PlayerZone.FlashEffectDesc.Brightness = 255;
	PlayerZone.FlashEffectDesc.NoGrey=True;
	PlayerZone.FlashEffectDesc.LayerColor.R = 192;
	PlayerZone.FlashEffectDesc.LayerColor.G = 192;
	PlayerZone.FlashEffectDesc.LayerColor.B = 192;
	PlayerZone.FlashEffectDesc.LayerSampling[0] = 1.0;
	PlayerZone.FlashEffectDesc.LayerBrightness = 255;
	PlayerZone.FlashEffectDesc.LayerSampling[3] = 1.0;
	PlayerZone.FlashEffectDesc.LayerSampling[6] = 1.0;
	PlayerZone.FlashEffectDesc.LayerSampling[7] = 1.0;
}

STATE FinExtroFlash
{
begin:
//	Sleep(0.1);
//	if( Flash[ IndexCurrentFlash ].bMemDuck && !Player.bIsCrouched /*&& (PC.bAltDuck==0)*/)
//	{
//		PC.bAltDuck = 1;
//		Sleep( 0.01 );
//	}

	XIIIGameInfo( Level.Game ).MapInfo.RestoreInventoryAfterFlash( Player );
	Player = XIIIPawn( PC.Pawn ); // Real Player Pawn
	Player.bCanCrouch = true;
//	PC.PlayerInput.bForceCrouch = Flash[ IndexCurrentFlash ].bMemDuck;
	Sleep(0.1);
//	PC.SetLocation( MemPos );
//	while ( !Player.SetLocation( MemPos ) )
//		sleep ( 0.03 );
	PC.SetRotation( MemRot );
	Player.SetRotation( MemRot );
	Player.Velocity=vect(0,0,0);
	Player.Acceleration=vect(0,0,0);
//	if( Flash[ IndexCurrentFlash ].bMemDuck && !Player.bIsCrouched && ( PC.bAltDuck == 1) )
//		PC.bAltDuck = 0;
	PC.FilterColorWanted.R = 128;
	PC.FilterColorWanted.G = 128;
	PC.FilterColorWanted.B = 128;
	PC.FilterColorSpeed = 1;
	PC.ConstantGlowScale = 0;
	PC.ConstantGlowFog = vect( 0.5, 0.5, 0.5 );
	PC.GotoState( 'PlayerWalking' );

//	log("FinExtroFlash : CODE LATENT");
	Alpha=1;
	InitPlayerZone();
	TriggerEvent( EventEndEndFlash, none, none);
	sleep( 0.25 );
	PC.bGodMode = bGod;
	Player.SpeedFactorLimit = MemSpeedFactorLimit;
	Player.SetGroundSpeed( 1.0 );

	GotoState( 'FeedBackFlashEnd' );
}

STATE FeedBackFlashEnd
{
	EVENT Tick( float dt )
	{
//LOG(".....Player.SpeedFactorLimit ="@Player.SpeedFactorLimit@Player.GroundSpeed@Player.default.GroundSpeed);
		Alpha -= dt/FeedBackFlashEndDuration;
		if ( PlayerZone != PC.Pawn.region.Zone )
		{
			PlayerZone.FlashEffectDesc.IsActivated = false;
			InitPlayerZone();
		}
		if ( Alpha < 0 )
		{
			PlayerZone.FlashEffectDesc.IsActivated = false;
			if ( EventPostFeedback!='')
				TriggerEvent( EventPostFeedback, none, none);
			GotoState( '' );
			return;
		}
		PlayerZone.FlashEffectDesc.LayerColor.R = 255 * Alpha;
		PlayerZone.FlashEffectDesc.LayerColor.G = 255 * Alpha;
		PlayerZone.FlashEffectDesc.LayerColor.B = 255 * Alpha;
		PlayerZone.FlashEffectDesc.LayerSampling[0] = 1.0 - 0.6 * Alpha;
		PlayerZone.FlashEffectDesc.LayerSampling[1] = 1.0 - 0.6 * Alpha;
		PlayerZone.FlashEffectDesc.LayerSampling[2] = 1.0 - 0.45 * Alpha;
		PlayerZone.FlashEffectDesc.LayerSampling[3] = 1.0 - 0.45 * Alpha;
		PlayerZone.FlashEffectDesc.LayerSampling[4] = 1.0 - 0.25 * Alpha;
		PlayerZone.FlashEffectDesc.LayerSampling[5] = 1.0 - 0.25 * Alpha;
	}

	EVENT BeginState( )
	{
//		log("FeedBackFlashEnd : BeginState");
    PC.PlayerInput.bForceCrouch = false;
	}
}




defaultproperties
{
     FeedBackFlashEndDuration=3.000000
     bAlwaysRelevant=True
     Tag="FM"
     Texture=Texture'XIDCine.Flash_ico'
}
