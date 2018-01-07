//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Map07_Kellownee extends MapInfo placeable;

VAR(Snow) Float Distance;
VAR(Snow) Int FlakeByCube;
VAR(Snow) Texture FlakeTexture;
VAR(Snow) Float FlakeSize;
VAR(Snow) Vector BaseFlakeSpeed;
VAR(Snow) Float FlakeSpeedDisturbance;
VAR(Snow) Float RandomFlakeAcceleration;
VAR(Snow) bool Activate;

FUNCTION FirstFrame()
{
	LOCAL DelimitationVolume dv;
	LOCAL Box dvBox;

	Super.FirstFrame();

	if (Activate)
	{
		Level.InitRndCubeSpr( FlakeTexture, FlakeByCube, 1.0, Distance );
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
}
