//=============================================================================
// CineTrigger.
// Created by iKi
// Last Modification by iKi
//=============================================================================
class CineTrigger extends Trigger
	HideCategories(force,lightcolor,lighting,rollof,sound);

#exec Texture Import File=Textures\Cine_ico.pcx Name=Cine_ico Mips=Off

VAR(CounterTrigger)	int InitialCounterValue;
VAR TRANSIENT int Count;
VAR(BufferTrigger)	float Period;
VAR(BufferTrigger)	float MaxDelay;

VAR TRANSIENT float TimeStamp;
VAR TRANSIENT Actor BufferredOther;
VAR TRANSIENT Pawn BufferredEventInstigator;

FUNCTION CineEvent(string Cine2Label)
{
	LOCAL CineController2 cc;

	if ( !( Cine2Label~="none" ) && (Cine2Label!="") )
	{
		foreach DynamicActors(class'CineController2', cc)
		{
			cc.CineGoto( Cine2Label );
		}
	}
}

EVENT Trigger( actor a, pawn p)
{
	CineEvent( string( tag ) );
}

STATE() CounterTrigger
{
	EVENT BeginState( )
	{
		Count = InitialCounterValue;
		SetCollision( false, false, false );
		bCollideWorld=false;
	}

	EVENT Trigger( actor a, pawn p )
	{
		Count--;
		if ( !bool( Count ) )
		{
			TriggerEvent( event, self, instigator);
			if ( bTriggerOnceOnly )
				Destroy( );
			else
				Count = InitialCounterValue;
		}
	}
}

// repeat the event until at least one actor catch it
STATE() BufferTrigger
{
	EVENT BeginState()
	{
		Period = FMax( 0.016, Period );
		SetCollision( false, false, false );
		bCollideWorld=false;
	}

	EVENT Timer( )
	{
		TimeStamp += Period;
		if ( ( MaxDelay == 0) || ( TimeStamp <= MaxDelay ) )
		{
			Trigger( BufferredOther, BufferredEventInstigator );
		}
	}

	EVENT Trigger( Actor Other, Pawn EventInstigator )
	{
		LOCAL bool b;
		LOCAL Actor A;

		b = false;
		ForEach DynamicActors( class 'Actor', A, Event )
		{
			if (A!=self)
			{
				log( self@"BUFFERED TRIGGER CATCH BY"@A );
				A.Trigger( Other, EventInstigator );
				b = b || (!A.IsA('TriggerSound'));
			}
		}
		if (b)
		{
			if ( bTriggerOnceOnly )
				Destroy( );
		}
		else
		{
			BufferredOther = Other;
			BufferredEventInstigator = EventInstigator;
			SetTimer( Period , false );
		}
	}
}

STATE() ControlledSoldierTouchTrigger
{
	EVENT Trigger( actor Other, pawn EventInstigator )
	{
		LOG( "ControlledSoldierTouchTrigger TRIGGER"@other );
		bInitiallyActive = true;
		CheckTouchList();
	}

	EVENT UnTrigger( actor Other, pawn EventInstigator )
	{
		LOG( "ControlledSoldierTouchTrigger UNTRIGGER"@other );
		bInitiallyActive = false;
	}

	EVENT Touch( Actor Other )
	{
		LOG( "ControlledSoldierTouchTrigger TOUCH"@other );

		if ( bInitiallyActive && Other.IsA('BaseSoldier') )
		{
			instigator = pawn(other);
			TriggerEvent( event, self, Instigator );
		}
	}
}

STATE() PlayerTouchControlTrigger
{
	EVENT Touch( Actor Other )
	{
		LOG( "PlayerTouchControlTrigger TOUCH"@other );
		if ( other.IsA('XIIIPlayerPawn') )
		{
			instigator = pawn(other);
			TriggerEvent( event, self, Instigator );
		}
	}

	EVENT UnTouch( Actor Other )
	{
		LOG( "PlayerTouchControlTrigger UNTOUCH"@other );
		if ( other.IsA('XIIIPlayerPawn') )
		{
			instigator = pawn(other);
			UnTriggerEvent( event, self, Instigator );
		}
	}

	EVENT Trigger( Actor Other, Pawn EventInstigator )
	{
	}
}



defaultproperties
{
     InitialCounterValue=1
     Period=1.000000
     bTriggerOnceOnly=True
     Texture=Texture'XIDCine.Cine_ico'
}
