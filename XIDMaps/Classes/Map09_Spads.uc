//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Map09_Spads extends MapInfo placeable;

VAR(Rain)	Float Distance;
VAR(Rain)	Int DropsByCube;
VAR(Rain)	Texture DropsTexture;
VAR(Rain)	Float DropsSize;
VAR(Rain)	Vector BaseDropsSpeed;
VAR(Rain)	Float DropsSpeedDisturbance;
VAR(Rain)	Float RandomDropsAcceleration;
VAR(Rain)	bool Activate;
VAR(Rain)	float FadeTime;
VAR			float Alpha_Direction;

FUNCTION FirstFrame()
{
	Disable('tick');
	Super.FirstFrame();

	if (Activate)
	{
		StartRain(1.0);
		Alpha_Direction=1;
	}
	else
	{
		Alpha_Direction=0;
	}

}

FUNCTION StartRain(float proportion)
{
	LOCAL DelimitationVolume dv;
	LOCAL Box dvBox;

	Level.InitRndCubeSpr( DropsTexture, DropsByCube, proportion, Distance );
	Level.SetRndCubeSprSpeed( BaseDropsSpeed, DropsSpeedDisturbance, RandomDropsAcceleration );
	Level.SetRndCubeSprSize( DropsSize );

	foreach allactors(class'DelimitationVolume',dv)
	{
		dvBox=dv.GetBoundingBox();
		if (dvBox.IsValid!=0)
			Level.AddRndCubeSprExclude( dvBox.Min, dvBox.Max+vect(1,1,1) );
	}

	Level.SetRndCubeSprState( True );
}

EVENT Trigger(actor a,pawn p)
{
	if (!Activate)
	{
		StartRain(0.0);
		Activate=true;
	}
	Alpha_Direction=1-Alpha_Direction;
	Enable('tick');
}

EVENT Tick(float dt)
{
	if (Alpha_Direction!=-1)
		if (Level.ChangeRndCubeSprProp(Alpha_Direction,dt/FadeTime,0.1/*DropsByCube*/))
			Disable('Tick');
}



defaultproperties
{
     Distance=512.000000
     DropsByCube=500
     DropsTexture=Texture'XIIICine.effets.etincelle'
     DropsSize=1.000000
     BaseDropsSpeed=(X=-10.000000,Y=100.000000,Z=-300.000000)
     RandomDropsAcceleration=1.000000
     fadeTime=1.000000
     Alpha_Direction=-1.000000
}
