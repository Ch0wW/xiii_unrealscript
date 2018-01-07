//-----------------------------------------------------------
// TrigerredEmitter
// Created by iKi
// Last Modification by iKi
//-----------------------------------------------------------
class TrigerredEmitter extends Emitter;

VAR() bool ForceParticlesSpawn;
VAR() bool bInitiallyOn;
VAR() bool bTriggeredOnceOnly;
VAR() float EmitTime;

EVENT PostBeginPlay( )
{
	LOCAL int i;

	for (i=0;i<Emitters.Length;++i)	
		Emitters[i].Disabled=!bInitiallyOn;
}
/*
EVENT Tick (float dt)
{
	DebugLog("============================"@Rotation);
}
*/
STATE() TriggerToggle
{
	EVENT Trigger( actor Other, pawn EventInstigator )
	{
		LOCAL int i;

		if (bTriggeredOnceOnly)
			Disable('Trigger');

		for (i=0;i<Emitters.Length;++i)	
			Emitters[i].Disabled=!Emitters[i].Disabled;
	}
}

STATE() TriggerControl
{
	EVENT Trigger( actor Other, pawn EventInstigator )
	{
		LOCAL int i;

		if (bTriggeredOnceOnly)
			Disable('Trigger');
		
		for (i=0;i<Emitters.Length;++i)	
			Emitters[i].Disabled=bInitiallyOn;
	}
	EVENT Untrigger( actor Other, pawn EventInstigator )
	{
		LOCAL int i;

		if (bTriggeredOnceOnly)
			Disable('Untrigger');
		
		for (i=0;i<Emitters.Length;++i)	
			Emitters[i].Disabled=!bInitiallyOn;
	}
}

STATE() TriggerEmit
{
	EVENT Trigger( actor Other, pawn EventInstigator )
	{
		LOCAL int i;

		if (bTriggeredOnceOnly)
			Disable('Trigger');

		for (i=0;i<Emitters.Length;++i)	
		{
			Emitters[i].Disabled=!Emitters[i].Disabled;
			if (ForceParticlesSpawn)
				Emitters[i].SpawnParticle(Emitters[i].MaxParticles);
		}
	}
}

STATE() TriggerPound
{
	EVENT Trigger( actor Other, pawn EventInstigator )
	{
		LOCAL int i;

		if (bTriggeredOnceOnly)
			Disable('Trigger');

		for (i=0;i<Emitters.Length;++i)	
		{
			Emitters[i].Disabled=!Emitters[i].Disabled;
			if (ForceParticlesSpawn)
				Emitters[i].SpawnParticle(Emitters[i].MaxParticles);
		}
		SetTimer(EmitTime,false);
	}

	EVENT Timer( )
	{
		LOCAL int i;

		if (bTriggeredOnceOnly)
			Disable('Untrigger');
		
		for (i=0;i<Emitters.Length;++i)	
			Emitters[i].Disabled=!bInitiallyOn;
	}
}




defaultproperties
{
     EmitTime=1.000000
     InitialState="TriggerEmit"
}
