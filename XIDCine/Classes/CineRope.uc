//-----------------------------------------------------------
// CineRope
// Created by iKi
//-----------------------------------------------------------
class CineRope extends Triggers;

#exec Texture Import File=Textures\Rock_ico.pcx Name=Rock_ico Mips=Off

const LinkLength = 100.0;
const LinkNumber = 30;
const RopeLength = 320;
VAR			float	LinkRealLength;
VAR			float	LinkScaleX;
//VAR			float	vA0Link[LinkNumber],vALink[LinkNumber];
VAR			float	TimeStamp;
//VAR			bool	bTendue;
VAR			int FrameCount;
const		IAPeriod=0.1;

VAR			CineRopeLink PremierFilin;

EVENT PostBeginPlay()
{
	LOCAL Vector ds3d;
	LOCAL Rotator Horiz;
	LOCAL CineRopeLink Filin, PrevFilin;
	LOCAL int i,n,v;

	LinkRealLength = RopeLength / LinkNumber;
	LinkScaleX = LinkRealLength / LinkLength;

	Horiz = ROTATOR( vect(0,1,0) );
	Horiz.Pitch=0;
	PremierFilin = Spawn( class'CineRopeLink',,,Location+0.5*LinkRealLength*vect(1,0,0), Horiz );
	ds3d = PremierFilin.DrawScale3D;
	ds3d.X = LinkScaleX;
	PremierFilin.SetDrawScale3D( ds3d );
	PrevFilin = PremierFilin;

	n=0;
//	v=-3072;
//	vA0Link[0]=v;

	for (i=1;i<LinkNumber;i++)
	{
		Horiz.Pitch = 12288*i;

//		vA0Link[i]=v;

		Filin = Spawn( class'CineRopeLink',,,PrevFilin.Location, Horiz );

		Filin.SetDrawScale3D( ds3d );
		PrevFilin.NextLink = Filin;
		Filin.PrevLink = PrevFilin;
		PrevFilin = Filin;
	}

	SetTimer( IAPeriod, true );
}

//VAR float vZ;
/* STATE STA_Wait
{
	EVENT BeginState()
	{
		SetTimer( 3.0, false );
	}
}*/
/*
FUNCTION float Magic(float f)
{
	log("MAGIC"@f@1.0f - ((1.0f-f)**10));
	return 1.0f - ((1.0f-f)**10);
}
*/
auto STATE STA_Fall
{
	EVENT BeginState()
	{
	}

	EVENT Timer()
	{
		LOCAL Rotator r;
		LOCAL Vector Up;
		LOCAL CineRopeLink Filin;
		LOCAL int i;

		Up = Location;
		Filin = PremierFilin;
		TimeStamp+=IAPeriod; //dt;
		for (i=0;i<LinkNumber;i++)
		{
			r.Pitch = ( ( -16384 - Filin.Rotation.Pitch + 32768 ) & 65535 ) - 32768;
			r.Yaw = ( ( -Filin.Rotation.Yaw + 32768 ) & 65535 ) - 32768;
			r.Roll = ( ( -Filin.Rotation.Roll + 32768 ) & 65535 ) - 32768;
			r = r*0.07 + Filin.Rotation;

			Filin.SetRotation( r );
			Filin.SetLocation( Up + 0.5 * LinkRealLength * VECTOR( r ) );
			Up += LinkRealLength*VECTOR(r);
			Filin = Filin.NextLink;
		}
	}

//	EVENT Tick( float dt )
/*	EVENT Timer()
	{
		LOCAL Rotator r;
		LOCAL Vector Up;
		LOCAL CineRopeLink Filin;
		LOCAL int i;

		Up = Location;
		Filin= PremierFilin;

		for (i=0;i<LinkNumber;i++)
		{
			r = Filin.Rotation;
			if ( Abs(r.Pitch+16384)<128 )
			{
				if ( i+1==LinkNumber )
					GotoState('STA_WaitLoose');
			}
			else
			{
				if ( (r.Pitch+vALink[i]+16384)*(r.Pitch+16384)<0)
				{
					vALink[i]=vA0Link[i];
					vA0Link[i]=-0.9*vA0Link[i];
					
				}
				r.Pitch += vALink[i];
//				vALink[i] = vALink[i] + Magic( 0.05 + 0.001*float(LinkNumber-i)/LinkNumber)*(vA0Link[i]-vALink[i]);
			}
	
			Filin.SetRotation( r );
			Filin.SetLocation( Up+Magic(0.5)*LinkRealLength*VECTOR(r));
			Up += LinkRealLength*VECTOR(r);
			Filin = Filin.NextLink;
		}
	}*/
}

STATE STA_WaitLoose
{
	EVENT Timer()
	{
		LOCAL Rotator r;
		LOCAL Vector Up;
		LOCAL CineRopeLink Filin;
		LOCAL int i;

		Up = Location;
		Filin= PremierFilin;
		TimeStamp+=IAPeriod; //dt;
		for (i=0;i<LinkNumber;i++)
		{
			r = Filin.Rotation;
			r.Pitch += 0.05 *( -16384 + (i+3)*180*cos(TimeStamp*3+i*0.3+i*i)-r.Pitch);
			r.Yaw += 0.05 *( (i+3)*180*sin(TimeStamp*2+i*0.3)-r.Yaw);
			Filin.SetRotation( r );
			Filin.SetLocation( Up+0.5*LinkRealLength*VECTOR(r));
			Up += LinkRealLength*VECTOR(r);
			Filin = Filin.NextLink;
		}
	}
}

STATE STA_Tight
{
	EVENT Timer()
	{
		LOCAL Rotator r;
		LOCAL Vector Up;
		LOCAL CineRopeLink Filin;
		LOCAL int i;

		Up = Location;
		Filin= PremierFilin;
		TimeStamp+=IAPeriod; //dt;
		for (i=0;i<LinkNumber;i++)
		{
			r.Pitch = ( ( -16384 - Filin.Rotation.Pitch + 32768 ) & 65535 ) - 32768;
			r.Yaw = ( ( -Filin.Rotation.Yaw + 32768 ) & 65535 ) - 32768;
			r.Roll = ( ( -Filin.Rotation.Roll + 32768 ) & 65535 ) - 32768;
			r = r*0.15 + Filin.Rotation;

			Filin.SetRotation( r );
			Filin.SetLocation( Up+0.5*LinkRealLength*VECTOR(r));
			Up += LinkRealLength*VECTOR(r);
			Filin = Filin.NextLink;
		}
	}
}

STATE STA_Break
{
	EVENT BeginState( )
	{
		// Keep 5 links alive, kill the others
		LOCAL CineRopeLink Filin, FilinSuivant;
		LOCAL int i;

		Filin=PremierFilin;
		while (Filin!=none)
		{
			i++;
			
			FilinSuivant=Filin.NextLink;
			if (i==4)
				Filin.NextLink=None;
			else
				if (i>4)
					Filin.Destroy();
			Filin=FilinSuivant;
		}		
	}
	
//	EVENT Tick( float dt )
	EVENT Timer()
	{
		LOCAL Rotator r;
		LOCAL Vector Up;
		LOCAL CineRopeLink Filin;
		LOCAL int i;

		Up = Location;
		Filin= PremierFilin;
		TimeStamp+=IAPeriod; //dt;
		for (i=0;i<4;i++)
		{
			r = Filin.Rotation;
			r.Pitch += 0.05 *( -16384 + (i+20)*180*cos(TimeStamp*3+i*0.3+i*i)-r.Pitch);
			r.Yaw += 0.05 *( (i+20)*180*sin(TimeStamp*2+i*0.3)-r.Yaw);
			Filin.SetRotation( r );
			Filin.SetLocation( Up+0.5*LinkRealLength*VECTOR(r));
			Up += LinkRealLength*VECTOR(r);
			Filin = Filin.NextLink;
		}
	}
}

EVENT Destroyed()
{
	LOCAL CineRopeLink Filin, FilinSuivant;

	Filin=PremierFilin;
	while (Filin!=none)
	{
		FilinSuivant=Filin.NextLink;
		Filin.Destroy();
		Filin=FilinSuivant;
	}

}




defaultproperties
{
     Texture=Texture'XIDCine.Rock_ico'
}
