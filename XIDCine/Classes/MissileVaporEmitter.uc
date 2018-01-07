
//    ========================================
//                                          by iKi ,ad¤¤b d¤¤b
//    dMP dMP .aMMMb  dMMMMb  .aMMMb  dMMMMb      ,I    qbP  qb
//   dMP dMP dMP"dMP dMP.dMP dMP"dMP dMP.dMP    aadP     qb   I
//  dMP dMP dMMMMMP dMMMMP" dMP dMP dMMMMK"    d      I  ²qb dP
//  YMvAP" dMP dMP dMP     dMP.aMP dMP"AMF    P      I     qbP
//   VP"  dMP dMP dMP      VMMMP" dMP dMP  EMITTER  pd      I²   d¤¤b
//                                             ba_adb      dP   dP  qb  db  
//========================================          'ba..ad      qa_ap  ²P  a 

class MissileVaporEmitter extends emitter;

VAR float VEMaxIntensity;
VAR Color VEHue;
VAR float VETime;
VAR XIIIPlayerController PC;
VAR VECTOR InitialLocation;

AUTO STATE STA_Init
{
	EVENT BeginState( )
	{
		InitialLocation = Location;
		SetCollision( true, false, false );
		SetPhysics( PHYS_Projectile );
		Velocity = 450*VECTOR(Rotation);
	}

	EVENT EndState( )
	{
		SetCollision( false, false, false );
		InitialLocation = Location;
	}

	EVENT Tick( float dt )
	{
		LOCAL FLOAT f;

		f = vSize( Location - InitialLocation );
		Emitters[0].StartLocationOffset.X = -f;
		Emitters[0].StartLocationOffset.Y = 24;
		SetCollisionSize( 60*f/256, 40*f/256 ); // 50 - 40
	}

	EVENT Touch( Actor Other )
	{
		if ( Other.IsA('XIIIPlayerPawn') )
		{
			PC = XIIIPlayerController( Pawn(Other).Controller );
			GotoState( 'Effect' );
		}
		else
			if ( Other.IsA( 'MangousteSSH1Pawn' ) && Instigator!=Other )
				MangousteSSH1Pawn(Other).MangousteController.VaporHurts( );
	}
Begin:
//	sleep( 0.30 );
	
//	SetLocation( Location + 256*VECTOR(Rotation) );
//	Emitters[0].StartLocationOffset.X=-256; // SetLocation( Location + 256*VECTOR(Rotation) );
	sleep( 1.00 );
	Destroy();
}

FUNCTION PlayerFeedBack( XIIIPlayerController PCtrl, float MaxIntensity, Color Hue, float Time )
{
	VEMaxIntensity = MaxIntensity;
	VEHue = Hue;
	VETime = Time;
	PC = PCtrl;
	GotoState( 'Effect' );
}

State Effect
{
Begin:
/*	if ( PC.bWeaponMode )
	{
		PC.OldWeap = PC.pawn.weapon.InventoryGroup;
		PC.Pawn.Weapon.PutDown();
	}
	else
	{
		PC.OldItem = XIIIItems(PC.Pawn.SelectedItem);
		PC.OldItem.PutDown();
	}
	PC.bWeaponBlock = true;
*/	
	LOG ("PC.Pawn.SpeedFactorLimit ="@PC.Pawn.SpeedFactorLimit );
	PC.Pawn.SpeedFactorLimit = 0.50;
	XIIIPawn(PC.Pawn).SetGroundSpeed( 1.0 );

	Level.SetPoisonEffect( true, 0.25, VEMaxIntensity, VEHue );
//	Level.SetInjuredEffect( true, 0.01 );
	sleep( 0.25);
	Level.SetPoisonEffect( false, VETime, VEMaxIntensity, VEHue );
//	Level.SetInjuredEffect( false, VETime );

	sleep( VETime );
/*
	PC.bWeaponBlock = false;
	if ( PC.bWeaponMode )
	{
		PC.Switchweapon( PC.OldWeap );
		PC.Pawn.ChangedWeapon();
	}
	else
	{
		PC.cNextItem();
		XIIIPawn(PC.Pawn).PendingItem = PC.OldItem;
		PC.Pawn.ChangedWeapon();
	}
*/
	PC.Pawn.SpeedFactorLimit = 1.0;
	XIIIPawn(PC.Pawn).SetGroundSpeed( 1.0 );
	Destroy();
}

// 	AutoDestroy=true



defaultproperties
{
     VEMaxIntensity=0.100000
     VEHue=(B=160,G=255,R=255)
     VETime=1.500000
     Begin Object Class=SpriteEmitter Name=MissileVaporEmitterA
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Initialized=True
         ColorScale(0)=(Color=(B=84,G=133,R=130))
         ColorScale(1)=(relativetime=1.000000,Color=(B=50,G=80,R=79))
         FadeOutStartTime=0.850000
         MaxParticles=6
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(relativetime=0.500000,RelativeSize=2.000000)
         SizeScale(2)=(relativetime=1.000000,RelativeSize=5.500000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=18.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XIIICine.extinct_fumeeAD'
         SecondsBeforeInactive=10000.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=700.000000,Max=700.000000))
         MaxAbsVelocity=(X=500.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000))
         Name="MissileVaporEmitterA"
     End Object
     Emitters(0)=SpriteEmitter'XIDCine.MissileVaporEmitter.MissileVaporEmitterA'
     AutoDestroy=False
     CollisionRadius=1000.000000
     CollisionHeight=1000.000000
}
