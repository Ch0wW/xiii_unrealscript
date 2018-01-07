//=============================================================================
// SMActorRotating.
//=============================================================================

class SMActorRotating extends Actor
	placeable;
VAR(Rotating) bool bInitiallyOn;
VAR(Rotating) StaticMesh smRotatingMesh;
VAR(Rotating) StaticMesh smStaticMesh;

VAR(Scaling) bool bInitiallyOpen;
VAR(Scaling) float OpeningDelay;
VAR(Scaling) float ClosingDelay;
VAR(Scaling) float OpeningTime;
VAR(Scaling) vector OpenScale3D;
VAR(Scaling) vector ClosedScale3D;
VAR TRANSIENT float TimeStamp,TimeStart;
VAR bool bOpen,bOpening,bClosing;
VAR TRANSIENT vector vSpeed;

Function vector vLerp(float Alpha,vector vA, vector vB)
{
	return Alpha*vA+(1-Alpha)*vB;
}

State() ScalingTriggerToggle
{
	EVENT BeginState()
	{
		bOpen=bInitiallyOpen;
		SetPhysics(PHYS_None);
		if (bOpen)
			GotoState('Open');
		else
			GotoState('Closed');

		TimeStamp=0.0;
	}
}

State Closed
{
	EVENT BeginState()
	{
		SetDrawScale3D(ClosedScale3D);
		DebugLog(name@"enter Closed state");
	}

	EVENT Trigger(actor Other,pawn EventInstigator)
	{
		TimeStart=TimeStamp+OpeningDelay;
		GotoState('Opening');
	}

}

State Open
{
	EVENT BeginState()
	{
		SetDrawScale3D(OpenScale3D);
		DebugLog(name@"Open");
	}

	EVENT Trigger(actor Other,pawn EventInstigator)
	{
		TimeStart=TimeStamp+ClosingDelay;
		GotoState('Closing');
	}
}

State Opening
{
	EVENT BeginState()
	{
		DebugLog(name@"Opening");
		enable('Tick');
	}

	EVENT EndState()
	{
		disable('Tick');
	}

	EVENT Tick(float dt)
	{
		LOCAL float relativetime;
		TimeStamp+=dt;
		relativetime=(TimeStamp-TimeStart)/OpeningTime;
		if (relativetime<0)
			return;
		if (relativetime<1)
		{
			SetDrawScale3D(vLerp(relativetime,OpenScale3D,ClosedScale3D));
		}
		else
		{
			SetDrawScale3D(OpenScale3D);
			bOpen=true;
			GotoState('Open');
		}

	}
	EVENT Trigger(actor Other,pawn EventInstigator)
	{
//		TimeStart=2*TimeStamp-OpeningTime+TimeStamp;
//		TimeStart=TimeStamp+ClosingDelay;
		TimeStart = 2 * TimeStamp - OpeningTime - TimeStart;

		GotoState('Closing');
	}

}

State Closing
{
	EVENT BeginState()
	{
		DebugLog(name@"Closing");
		enable('Tick');
	}

	EVENT EndState()
	{
		disable('Tick');
	}

	EVENT Tick(float dt)
	{
		LOCAL float relativetime;
		TimeStamp+=dt;
		relativetime=(TimeStamp-TimeStart)/OpeningTime;
		if (relativetime<0)
			return;
		if (relativetime<1)
		{
			SetDrawScale3D(vLerp(relativetime,ClosedScale3D,OpenScale3D));
		}
		else
		{
			SetDrawScale3D(ClosedScale3D);
			bOpen=false;
			GotoState('Closed');
		}
	}
	EVENT Trigger(actor Other,pawn EventInstigator)
	{
		TimeStart = 2 * TimeStamp - OpeningTime - TimeStart;

		GotoState('Opening');
	}
}

State() TriggerToggle
{
	EVENT BeginState()
	{

		if (bInitiallyOn)
		{
			if (smRotatingMesh!=none)
				StaticMesh=smRotatingMesh;
			SetPhysics(PHYS_Rotating);
		}
		else
		{
			if (smStaticMesh!=none)
				StaticMesh=smStaticMesh;
			SetPhysics(PHYS_None);
		}
	}

	EVENT Trigger(actor Other,pawn EventInstigator)
	{
		if (Physics==PHYS_None)
		{
			if (smRotatingMesh!=none)
				StaticMesh=smRotatingMesh;
			SetPhysics(PHYS_Rotating);
		}
		else
		{
			if (smStaticMesh!=none)
				StaticMesh=smStaticMesh;
			SetPhysics(PHYS_None);
		}
	}
}

State() TriggerControl
{
	EVENT BeginState()
	{
		if (bInitiallyOn)
		{
			if (smRotatingMesh!=none)
				StaticMesh=smRotatingMesh;
			SetPhysics(PHYS_Rotating);
		}
		else
		{
			if (smStaticMesh!=none)
				StaticMesh=smStaticMesh;
			SetPhysics(PHYS_None);
		}
	}

	EVENT Trigger(actor Other,pawn EventInstigator)
	{
		if (smRotatingMesh!=none)
			StaticMesh=smRotatingMesh;
		SetPhysics(PHYS_Rotating);
	}

	EVENT Untrigger(actor Other,pawn EventInstigator)
	{
		if (smStaticMesh!=none)
			StaticMesh=smStaticMesh;
		SetPhysics(PHYS_None);
	}
}

defaultproperties
{
     OpeningDelay=3.500000
     ClosingDelay=1.500000
     OpeningTime=16.000000
     OpenScale3D=(X=1.000000,Y=1.000000,Z=1.000000)
     ClosedScale3D=(Z=1.000000)
     bWorldGeometry=True
     bShadowCast=True
     bIgnoreDynLight=False
     bBlockActors=True
     bBlockPlayers=True
     bFixedRotationDir=True
     Physics=PHYS_Rotating
     DrawType=DT_StaticMesh
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     RotationRate=(Pitch=5000)
     bEdShouldSnap=True
}
