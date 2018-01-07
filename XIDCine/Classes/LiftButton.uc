//-----------------------------------------------------------
//
//-----------------------------------------------------------
class LiftButton extends XIIIMover;

VAR() StaticMesh MovingUpSM, MovingDownSM;
VAR StaticMesh NoMoveSM;
VAR float FlashTime;
VAR bool FlashPhase;

//____________________________________________________________________
function PostBeginPlay()
{
	Super.PostBeginPlay();
	NoMoveSM = StaticMesh;
}

//____________________________________________________________________
function InterpolateTo( byte NewKeyNum, float Seconds )
{
//	LOG ("BON SANG DE BON SANG DE ...bip..."@name);
    NewKeyNum = Clamp( NewKeyNum, 0, ArrayCount(KeyPos)-1 );
	bInterpolating=false;
    if ( NewKeyNum == KeyNum-1 ) // Going backward
    {
//      PhysRate = 1.0 / FMax( fVarMoveTime[ NewKeyNum ], 0.005);
//      if ( VarStaticMesh[NewKeyNum] != none )
  //      StaticMesh = VarStaticMesh[NewKeyNum];
    }
    else // Going forward
    {
  //    PhysRate = 1.0 / FMax( fVarMoveTime[ KeyNum ], 0.005);
//      if ( VarStaticMesh[KeyNum] != none )
  //      StaticMesh = VarStaticMesh[KeyNum];
    }
    PrevKeyNum       = KeyNum;
    KeyNum           = NewKeyNum;

}

FUNCTION DoOpen()
{
     PlaySound( OpeningSound );
     if ( !bMusicOnlyOnce || !bAlreadyOpening )
     {
          bAlreadyOpening = true;
          PlayMusic( OpeningMusic );
     }
	 PlaySound(MoveAmbientSound);	
}

// Handle when the mover finishes opening.
function FinishedOpening()
{
     // Update sound effects.
     PlaySound( OpenedSound );
     if ( !bMusicOnlyOnce || !bAlreadyOpened )
     {
          bAlreadyOpened = true;
          PlayMusic( OpenedMusic );
     }
     
     // Trigger any chained movers.
     TriggerEvent(Event, Self, Instigator);

//     If ( MyMarker != None )
//          MyMarker.MoverOpened();
     FinishNotify();
}

STATE() PlayerTriggerToggle //extends TriggerToggle
{
    ignores bump;

    FUNCTION PlayerTrigger( actor Other, pawn EventInstigator )
    {
        SavedTrigger = Other;
        Instigator = EventInstigator;
        if ( SavedTrigger != None )
          SavedTrigger.BeginEvent();
          if ( EventInstigator.IsPlayerPawn() )
            bWarnSoldiers = true;
		  DoOpen();
		  FinishedOpening();
    }
}

FUNCTION CageIsCalled ( bool Z ) // true = Up, false = down
{
	bNoInteractionIcon=true;
	if ( Z )
	{
//		LOG( self@"CageIsCalled => MovingUpSM" );
		StaticMesh = MovingUpSM;
	}
	else
	{
//		LOG( self@"CageIsCalled => MovingDownSM" );
		StaticMesh = MovingDownSM;
	}
}

FUNCTION CageMoves( bool Z ) // true = Up, false = down
{
	if ( Z )
	{
		if ( MovingUpSM!=none)
			GotoState( 'MovingUp' );
	}
	else
	{
		if ( MovingDownSM!=none)
			GotoState( 'MovingDown' );
	}

}

FUNCTION CageStops( )
{
	GotoState( 'LittleBreak' );
}

STATE LittleBreak
{
begin:
	sleep( 1.0 );
	bNoInteractionIcon=false;
	GotoState( 'PlayerTriggerToggle' );
}

FUNCTION MakeGroupReturn()
{
}

STATE MovingUp
{
	EVENT BeginState( )
	{
//		LOG( self@"MovingUp::BeginState => MovingUpSM" );
		bNoInteractionIcon=true;
		StaticMesh = MovingUpSM;
		FlashPhase=true;
		if ( FlashTime>0 )
			SetTimer( FlashTime, true );
	}
	EVENT EndState( )
	{
//		LOG( self@"MovingUp::EndState => NoMoveSM" );
		StaticMesh = NoMoveSM;
	}
	EVENT Timer( )
	{
		if ( FlashPhase )
		{
//			LOG( self@"MovingUp::Timer => NoMoveSM" );
			StaticMesh = NoMoveSM;
		}
		else
		{
//			LOG( self@"MovingUp::Timer => MovingUpSM" );
			StaticMesh = MovingUpSM;
		}
		FlashPhase = !FlashPhase;
	}
}

STATE MovingDown
{
	EVENT BeginState( )
	{
//		LOG( self@"MovingDown::BeginState => MovingUpSM" );
		bNoInteractionIcon=true;
		StaticMesh = MovingDownSM;
		FlashPhase=true;
		if ( FlashTime>0 )
			SetTimer( FlashTime, true );
	}
	EVENT EndState( )
	{
//		LOG( self@"MovingDown::EndState => NoMoveSM" );
		StaticMesh = NoMoveSM;
	}
	EVENT Timer( )
	{
		if ( FlashPhase )
		{
//			LOG( self@"MovingDown::Timer => NoMoveSM" );
			StaticMesh = NoMoveSM;
		}
		else
		{
//			LOG( self@"MovingDown::Timer => MovingDownSM" );
			StaticMesh = MovingDownSM;
		}
		FlashPhase = !FlashPhase;
	}
}



defaultproperties
{
     FlashTime=0.500000
     InitialState="PlayerTriggerToggle"
}
