//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MotorBoat extends BoatDeco;

VAR() bool bExplodeIfDead;
VAR bool bDying;
VAR(Crash) int Health, DamageAmount, DamageRadius;
VAR int InitialHealth;
VAR() string CrashLabel;
VAR(Sound) Sound SoundExplosion;
VAR(Events) name CrashEvent;
VAR(Events) name DeadEvent;
VAR	Emitter SmokeEmitter;
VAR Emitter ExploEmitter;

FUNCTION TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType )
{
	if ( !bDying && instigatedBy.IsPlayerPawn() )
	{
		Health= Max(0,Health-Damage);
		if (SmokeEmitter==none)
		{
			SmokeEmitter=Spawn(class'HelicoHSEmitter',,,Location+346*(vect(0,0,1) cross vector(Rotation)));
			SmokeEmitter.SetBase(self);
		}
		if ( SmokeEmitter!=none )
		{
			SmokeEmitter.Emitters[0].InitialParticlesPerSecond = 0.3333 * (1-float(Health)/InitialHealth);	
			SmokeEmitter.Emitters[0].ParticlesPerSecond = 0.3333 * (1-float(Health)/InitialHealth);	
		}
		if (Health==0)
		{
			bDying=true;
			DebugLog( "CRASH" );
			if ( bExplodeIfDead )
			{
				ExploEmitter= spawn(class'HelicoExploEMitter',,,Location+vect(0,0,64)/* HitLocation+400*Normal(instigatedBy.Location-HitLocation)*/);
//				HurtRadius( 5000/*DamageAmount*/, 500/*DamageRadius*/, class'DTGrenaded', 0, HitLocation );	
				PlaySound(SoundExplosion/*,SoundExplosionType*/);
				if ( SmokeEmitter!=none)
					SmokeEmitter.Destroy();
				GotoState( 'Dying' );
			}
			else
				if ( Cine2(LinkedTo)!=none )
				{
					DebugLog( "CRASH sent to cine2" );
					Cine2(LinkedTo).CineController.CineGoto( CrashLabel );
				}
		}
	}
}

STATE Dying
{
	FUNCTION TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType )
	{
	}
Begin:
	SetCollision(false,false,false);
	TriggerEvent( CrashEvent, self, none );
	Sleep( 1.0 );
	TriggerEvent( DeadEvent, self, none );
	Destroy( );
}



defaultproperties
{
     bExplodeIfDead=True
     Health=350
     CrashLabel="Crash"
     SoundExplosion=Sound'XIIIsound.Explo__GenExplo.GenExplo__hGenExplo'
     CrashEvent="Crash"
}
