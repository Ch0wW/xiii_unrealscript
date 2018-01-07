//-----------------------------------------------------------
// BeachFinalFall
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class BeachFinalFall extends Triggers;
//	ShowCategories( Collision,
//	placeable;

#exec Texture Import File=Textures\Rock_ico.pcx Name=Rock_ico Mips=Off

VAR Color clBlack, clGrey;
VAR bool bTheEnd;
VAR TRANSIENT Vector Loc;
VAR TRANSIENT Rotator Rotat;
VAR TRANSIENT XIIIPlayerController PC;

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
		GotoState( 'LetsSwing_01' );
	}
}

STATE LetsSwing_01
{
	EVENT BeginState()
	{
		PC.GotoState( 'NoControl' );
		Level.bCineFrame=false;
		Loc=  PC.Pawn.Location-vect(0,0,60);//-PC.Pawn.CollisionHeight;
		Rotat.Yaw = PC.Rotation.Yaw;
		Rotat.Pitch= 3000;
		Rotat.Roll= 12000;
		PC.FilterColorWanted=clBlack;
	}

	EVENT Tick( float dt )
	{
		LOCAL Rotator r;
		LOCAL Vector v;
//		LOCAL float f;
		if ( PC.Pawn.Physics!=PHYS_None )
		{
			PC.Pawn.SetPhysics( PHYS_None );
			PC.Pawn.bCollideWorld=false;
		}
		if ( !PC.IsInState( 'NoControl' ) )
			GotoState( 'NoControl' );

//		TimeStamp+=dt;
		r=Rotat;
		r-=PC.Rotation;
		r.Yaw= ((r.Yaw+32768)&65535)-32768;
		r.Roll= ((r.Roll+32768)&65535)-32768;
		r.Pitch= ((r.Pitch+32768)&65535)-32768;

		PC.SetRotation(r*0.005+PC.Rotation);

		v = Loc-PC.Pawn.Location;
		PC.Pawn.SetLocation( PC.Pawn.Location+ 0.005*v );

		if ( bTheEnd )
		{
			GotoState( 'LetsSwing_02' );
		}

	}
Begin:
	PC.FilterColorSpeed=4;
	PC.FilterColorWanted=clBlack;
	Sleep( 0.25 );
	PC.FilterColorSpeed=5;
	PC.FilterColorWanted=clGrey;
	Sleep( 0.2+0.5 );
	PC.FilterColorSpeed=4;
	PC.FilterColorWanted=clBlack;
	Sleep( 0.25 );
	PC.FilterColorSpeed=5;
	PC.FilterColorWanted=clGrey;
	Sleep( 0.2+0.5 );
	PC.FilterColorSpeed=0.25;
	PC.FilterColorWanted=clBlack;
	Sleep( 4 );
	bTheEnd=true;
}

STATE LetsSwing_02
{
Begin:
	Sleep(2.0);
	TriggerEvent( event, Self, PC.Pawn );

}



defaultproperties
{
     clGrey=(B=128,G=128,R=128)
     InitialState="Init"
     Texture=Texture'XIDCine.Rock_ico'
     bDirectional=True
}
