//
//-----------------------------------------------------------
class NastyHelico extends HelicoDeco;

VAR()	Actor Passengers[2];
VAR		VECTOR PassengersRelativeLocation[2];
VAR		byte bPassengerDead[2];

FUNCTION PostBeginPlay()
{
	LOCAL AttackPoint ap;

	Super.PostBeginPlay();
	if ( Passengers[0]!=none )
	{
		Passengers[0].Tag=LinkedTo.Tag;
		PassengersRelativeLocation[0]=(Passengers[0].Location-Passengers[0].CollisionHeight*vect(0,0,1)-Location)<<Rotation;
	}
	if (Passengers[1]!=none)
	{
		Passengers[1].Tag=LinkedTo.Tag;
		PassengersRelativeLocation[1]=(Passengers[1].Location-Passengers[1].CollisionHeight*vect(0,0,1)-Location)<<Rotation;

	}
}
EVENT Tick( float dt )
{
	LOCAL ROTATOR r;
	LOCAL VECTOR vX, vY, vZ, vZ2;
	LOCAL int i;

	HelicoTick(dt);

	GetAxes( Rotation, vX, vY, vZ );
	for ( i=0; i<2; i++ )
	{
		if ( bPassengerDead[i]==0 && Passengers[i]!= none && Passengers[i].IsA( 'Pawn' ) )
		{
			Passengers[i].SetLocation(Location+(PassengersRelativeLocation[i]>>Rotation)+Passengers[i].CollisionHeight*vect(0,0,1));
			if ( !Pawn(Passengers[i]).bIsDead )
			{
				vX = Pawn(Passengers[i]).Controller.Focus.Location - Passengers[i].Location;
				vY= vZ cross vX;
				r = OrthoRotation( vX, vY, vZ );
				Passengers[i].SetRotation( r );
			}
			else
			{
				GetAxes( Passengers[i].Rotation, vX, vY, vZ2 );
				r = OrthoRotation( vX, vY, vZ );
				Passengers[i].SetRotation( r );
				Passengers[i].SetPhysics( PHYS_None );
				Passengers[i].SetBase( Self );
				Passengers[i].bCollideWorld=false;
				bPassengerDead[i] = 1;
			}
		}
	}
}

EVENT Destroyed( )
{
	LOCAL int i;

	for ( i=0; i<2; i++ )
	{
		if ( Passengers[i]!= none && Passengers[i].IsA( 'Pawn' ) && Pawn(Passengers[i]).bIsDead)
			Passengers[i].Destroy();
	}
	Super.Destroyed( );
}



defaultproperties
{
     bActorShadows=False
     InitialState="InvisibleUntilTriggered"
     StaticMesh=StaticMesh'Meshes_Vehicules.helicomangousteOpen'
}
