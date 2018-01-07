//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Map06_HualparBase extends MapInfo placeable;

VAR(Snow) Float Distance;
VAR(Snow) Int FlakeByCube;
VAR(Snow) Texture FlakeTexture;
VAR(Snow) Float FlakeSize;
VAR(Snow) Vector BaseFlakeSpeed;
VAR(Snow) Float FlakeSpeedDisturbance;
VAR(Snow) Float RandomFlakeAcceleration;
VAR(Snow) bool Activate;
VAR(Snow) float FadeTime;
VAR   float Alpha_Direction;

FUNCTION FirstFrame()
{
	Disable('tick');
	Super.FirstFrame();

	if (Activate)
	{
		StartSnow(1.0);
		Alpha_Direction=1;
	}
	else
	{
		Alpha_Direction=0;
	}

}

FUNCTION StartSnow(float proportion)
{
	LOCAL DelimitationVolume dv;
	LOCAL Box dvBox;

	Level.InitRndCubeSpr( FlakeTexture, FlakeByCube, proportion, Distance );
	Level.SetRndCubeSprSpeed( BaseFlakeSpeed, FlakeSpeedDisturbance, RandomFlakeAcceleration );
	Level.SetRndCubeSprSize( FlakeSize );

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
		StartSnow(0.0);
		Activate=true;
	}
	Alpha_Direction=1-Alpha_Direction;
	Enable('tick');
}

EVENT Tick(float dt)
{
	if (Alpha_Direction!=-1)
		if (Level.ChangeRndCubeSprProp(Alpha_Direction,dt/FadeTime,0.1/*FlakeByCube*/))
			Disable('Tick');
}



defaultproperties
{
     Distance=512.000000
     FlakeByCube=1500
     FlakeTexture=Texture'XIIICine.snowflake'
     FlakeSize=2.000000
     BaseFlakeSpeed=(Z=-25.000000)
     FlakeSpeedDisturbance=25.000000
     RandomFlakeAcceleration=1.000000
     fadeTime=1.000000
     Alpha_Direction=-1.000000
}
