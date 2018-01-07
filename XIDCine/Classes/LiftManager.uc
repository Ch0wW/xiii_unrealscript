class LiftManager extends info
	hidecategories(display,sound,rolloff)
	placeable;

VAR() LiftDoor Floor1_OuterDoors[2];
VAR() LiftDoor Floor2_OuterDoors[2];
VAR() LiftDoor Internal_Doors[2];
VAR() LiftButton Floor1_CallingButton;
VAR() LiftButton Floor2_CallingButton;
VAR() LiftButton Internal_Button;
VAR() LiftCage LiftCage;
VAR() int CurrentFloor;
VAR() bool CurrentFloorDoorsOpen;
VAR() float Z_TimeLiftCage;
VAR() float Z_TimeInternalDoors;
VAR() float Z_TimeExternalDoors;
VAR() float Z_OpenDelayInternalDoor;
VAR() float Z_OpenDelayExternalDoor;
VAR() float Z_CloseDelayInternalDoor;
VAR() float Z_CloseDelayExternalDoor;
VAR(Advanced) bool bAutomatic;

VAR vector RL_Doors[2];
VAR name MemoState;

// Pour le debug
//VAR XIIIPlayerController PC;

EVENT PostBeginPlay( )
{
	LOCAL LiftCage lc;
	LOCAL LiftButton lb;
	LOCAL LiftDoor ld;
	LOCAL int eldIndex, ildIndex; // external and internal liftdoor indexes
	LOCAL vector vCageOtherKeyRelLoc;

	if ( bAutomatic )
	{
//		DebugLog ("LIFT:: AUTOMATIC");
//		DebugLog ("LIFT:: Cleaning variables");

		LiftCage=none;
		Floor1_OuterDoors[0]=none;
		Floor1_OuterDoors[1]=none;
		Floor2_OuterDoors[0]=none;
		Floor2_OuterDoors[1]=none;
		Internal_Doors[0]=none;
		Internal_Doors[1]=none;
		Floor1_CallingButton=none;
		Floor2_CallingButton=none;
		Internal_Button=none;
		CurrentFloor=1;
		CurrentFloorDoorsOpen=true;

		// cherche une cage d'ascenseur à moins de 5 mètres (position du pivot)
		foreach RadiusActors(class 'LiftCage', lc, 400)  
		{
			break;
		}
		if ( lc == none )
		{
//			log ("LIFT:: No lift cage"@name);
			Destroy();
		}
		LiftCage=lc;
		LiftCage.MoveTime=Z_TimeLiftCage;
		if (LiftCage.KeyNum==0)
			vCageOtherKeyRelLoc=LiftCage.KeyPos[1];
		else
			vCageOtherKeyRelLoc=-LiftCage.KeyPos[1];
		
// cherche des boutons d'ascenseur à moins de 4 mètres
		foreach RadiusActors(class 'LiftButton', lb, 300)  
		{
			if ( (lb.Location-Location) dot vector(rotation) > 0 )
			{
				// Internal
				if ( Internal_Button==none )
				{
					lb.SetBase( LiftCage );
					lb.Event=Tag;
//					DebugLog ("LIFT:: Register Internal_Button"@lb);
					Internal_Button=lb;
				}
//				else
//					Log ("LIFT:: Too many internal liftbutton in lift"@name);
			}
			else
			{
				// External
				if ( Floor1_CallingButton==none )
				{
					Floor1_CallingButton=lb;
					Floor1_CallingButton.Event=Tag;
					DebugLog ("LIFT:: Register 1st floor calling button"@lb);
				}
//				else
//					log ("LIFT:: Too many 1st floor calling button in lift"@name);
			}
		}

		foreach RadiusActors(class 'LiftButton', lb, 300, Location + vCageOtherKeyRelLoc)  
		{
			if ( Floor2_CallingButton==none )
			{
				Floor2_CallingButton=lb;
				Floor2_CallingButton.Event=Tag;
//				DebugLog ("LIFT:: Register 2nd floor calling button"@lb);
			}
//			else
//				log ("LIFT:: Too many 2nd floor calling button in lift"@name);
		}

// cherche des portes d'ascenseur à moins de 4 mètres
		foreach RadiusActors(class 'LiftDoor', ld, 300)  
		{
			if ( (ld.Location-Location) dot vector(rotation) > 0 )
			{
				// Internal
				if ( ildIndex<2 )
				{
					Internal_Doors[ildIndex]=ld;
//					DebugLog ("LIFT:: Register internal liftdoor"@ld);
					RL_Doors[ildIndex]=ld.BasePos-LiftCage.Location;
					ld.SetBase( LiftCage );
					ld.MoveTime=Z_TimeInternalDoors;
					if (ld.KeyNum==0)
						CurrentFloorDoorsOpen=false;

					ildIndex++;
				}
//				else
//					log ("LIFT:: Too many internal liftdoor in lift"@name);

			}
			else
			{
				// External
				if ( eldIndex<2 )
				{
					Floor1_OuterDoors[eldIndex]=ld;
					ld.MoveTime=Z_TimeExternalDoors;
//					DebugLog ("LIFT:: Register 1st floor external doors"@ld);
					if (ld.KeyNum==0)
						CurrentFloorDoorsOpen=false;
					eldIndex++;
				}
//				else
//					log ("LIFT:: Too many 1st floor external doors in lift"@name);
			}
		}
		eldIndex=0;
		foreach RadiusActors(class 'LiftDoor', ld, 300, Location + vCageOtherKeyRelLoc ) 
		{
			if ( eldIndex<2 )
			{
				Floor2_OuterDoors[eldIndex]=ld;
				ld.MoveTime=Z_TimeExternalDoors;
//				DebugLog ("LIFT:: Register 2nd floor external doors"@ld);
				eldIndex++;
			}
//			else
//				log ("LIFT:: Too many 1st floor external doors in lift"@name);
		}
		CurrentFloor=1;
	}
	else
	{
		LiftCage.MoveTime=Z_TimeLiftCage;

		if ( Internal_Doors[0]!=none )
		{
			RL_Doors[0]=Internal_Doors[0].BasePos-LiftCage.Location;
			Internal_Doors[0].SetBase( LiftCage );
			Internal_Doors[0].MoveTime=Z_TimeInternalDoors;
		}
		if ( Internal_Doors[1]!=none )
		{
			RL_Doors[1]=Internal_Doors[1].BasePos-LiftCage.Location;
			Internal_Doors[1].SetBase( LiftCage );
			Internal_Doors[1].MoveTime=Z_TimeInternalDoors;
		}
		if ( Floor1_OuterDoors[0]!=none )
		{
			Floor1_OuterDoors[0].MoveTime=Z_TimeExternalDoors;
		}
		if ( Floor1_OuterDoors[1]!=none )
		{
			Floor1_OuterDoors[1].MoveTime=Z_TimeExternalDoors;
		}
		if ( Floor2_OuterDoors[0]!=none )
		{
			Floor2_OuterDoors[0].MoveTime=Z_TimeExternalDoors;
		}
		if ( Floor2_OuterDoors[1]!=none )
		{
			Floor2_OuterDoors[1].MoveTime=Z_TimeExternalDoors;
		}
		if ( Internal_Button!=none )
		{
			Internal_Button.SetBase( LiftCage );
		}
	}
}

EVENT Untrigger(actor Other, Pawn EventInstigator)
{
	Trigger( Other, EventInstigator );
}

EVENT Trigger(actor Other, Pawn EventInstigator)
{
//	Other.tag
//	DebugLog("LM::Trigger");
	if ( Other == Floor1_CallingButton )
	{
//		DebugLog("LM::Global::Trigger->GotoState('CallFloor1')");
		GotoState('CallFloor1');
	}
	else
		if ( Other == Floor2_CallingButton )
		{
//			DebugLog("LM::Global::Trigger->GotoState('CallFloor2')");
			GotoState('CallFloor2');
		}
		else
			if ( Other == Internal_Button )
			{
				if ( CurrentFloor == 1 )
//				{
//					DebugLog("LM::Global::Trigger->GotoState('CloseInternalAndFirstFloorDoors')");
					GotoState('CloseInternalAndFirstFloorDoors');
//				}
				else
//				{
//					DebugLog("LM::Global::Trigger->GotoState('CloseInternalAndSecondFloorDoors')");
					GotoState('CloseInternalAndSecondFloorDoors');
//				}
			}
}

/*
FUNCTION WaitingForAllDoorsAreClose()
{
	MemoState = GetStateName();
	GotoState('WaitDoors');
}
*/
STATE CallFloor1
{
	FUNCTION BeginState()
	{
//		DebugLog("LM::Trigger->GotoState('CloseInternalAndSecondFloorDoors')");
		if ( CurrentFloor!=1 )
		{
			// Close Internal and Second Floor Doors
//			DebugLog("LM::CallFloor1::BeginState->GotoState('CloseInternalAndSecondFloorDoors')");
			GotoState('CloseInternalAndSecondFloorDoors');
			return;
		}
		else
		{
			if ( !CurrentFloorDoorsOpen )
			{
//				DebugLog("LM::CallFloor1::BeginState->GotoState('OpenInternalAndFirstFloorDoors')");
				GotoState('OpenInternalAndFirstFloorDoors');
				return;
			}
		}
	}
}

STATE CallFloor2
{
	FUNCTION BeginState()
	{
		if ( CurrentFloor!=2 )
		{
			// Close Internal and Second Floor Doors
//			DebugLog("LM::CallFloor2::BeginState->GotoState('CloseInternalAndFirstFloorDoors')");
			GotoState('CloseInternalAndFirstFloorDoors');
			return;
		}
		else
		{
			if ( !CurrentFloorDoorsOpen )
			{
//				DebugLog("LM::CallFloor2::BeginState->GotoState('OpenInternalAndSecondFloorDoors')");
				GotoState('OpenInternalAndSecondFloorDoors');
				return;
			}
		}
	}
}

STATE CloseInternalAndSecondFloorDoors
{
	EVENT BeginState( )
	{
		LOCAL float waittime;
		
		LOCAL bool bMoveUp;

//		DebugLog("LM::CloseInternalAndSecondFloorDoors::BeginState");

		bMoveUp= (LiftCage.KeyPos[LiftCage.KeyNum].Z<LiftCage.KeyPos[1-LiftCage.KeyNum].Z);

		if ( Internal_Button != none )		{	Internal_Button.CageIsCalled( bMoveUp );	}
		if ( Floor1_CallingButton != none ) {	Floor1_CallingButton.CageIsCalled( bMoveUp );	}
		if ( Floor2_CallingButton != none ) {	Floor2_CallingButton.CageIsCalled( bMoveUp );	}

//		DebugLog( "Enter "$GetStateName() );

//		waittime=0; default value
		if ( Internal_Doors[0] != none )
		{
			Internal_Doors[0].DelayTime = Z_CloseDelayInternalDoor;
			Internal_Doors[0].Untrigger( self, none );
			waittime=max(waittime,Internal_Doors[0].MoveTime+Z_CloseDelayInternalDoor);
		}
		if ( Internal_Doors[1] != none )
		{
			Internal_Doors[1].DelayTime = Z_CloseDelayInternalDoor;
			Internal_Doors[1].Untrigger( self, none );
			waittime=max(waittime,Internal_Doors[1].MoveTime+Z_CloseDelayInternalDoor);
		}
		if ( Floor2_OuterDoors[0] != none )
		{
			Floor2_OuterDoors[0].DelayTime = Z_CloseDelayExternalDoor;
			Floor2_OuterDoors[0].Untrigger( self, none ); 
			waittime=max(waittime,Floor2_OuterDoors[0].MoveTime+Z_CloseDelayExternalDoor);
		}
		if ( Floor2_OuterDoors[1] != none )
		{
			Floor2_OuterDoors[1].DelayTime = Z_CloseDelayExternalDoor;
			Floor2_OuterDoors[1].Untrigger( self, none );
			waittime=max(waittime,Floor2_OuterDoors[1].MoveTime+Z_CloseDelayExternalDoor);
		}

		if ( waittime != 0 )
			SetTimer( waittime, false );
		else
			Timer( );

	}

	EVENT Timer( )
	{
		CurrentFloorDoorsOpen = false;
		GotoState( 'GotoFloor1' );
	}
}

STATE GotoFloor1
{
	EVENT Trigger(actor Other, Pawn EventInstigator)
	{
	}

	EVENT BeginState( )
	{
		LOCAL float waittime;
		LOCAL bool bMoveUp;

//		DebugLog("LM::GotoFloor1::BeginState");

		bMoveUp= (LiftCage.KeyPos[LiftCage.KeyNum].Z<LiftCage.KeyPos[1-LiftCage.KeyNum].Z);

//		DebugLog( "Enter "$GetStateName() );

		if ( LiftCage != none ) { LiftCage.Trigger( self, none ); waittime=LiftCage.MoveTime; }

		if ( Internal_Button != none )		{	Internal_Button.CageMoves( bMoveUp );	}
		if ( Floor1_CallingButton != none ) {	Floor1_CallingButton.CageMoves( bMoveUp );	}
		if ( Floor2_CallingButton != none ) {	Floor2_CallingButton.CageMoves( bMoveUp );	}

		if ( waittime != 0 )
			SetTimer( waittime, false );
		else
			Timer( );
	}

	EVENT Timer( )
	{
		LOCAL bool bMoveUp;
		CurrentFloor = 1;
		bMoveUp= (LiftCage.KeyPos[LiftCage.KeyNum].Z>LiftCage.KeyPos[1-LiftCage.KeyNum].Z);
		if ( Internal_Button != none )		{	Internal_Button.CageIsCalled( bMoveUp );	}
		if ( Floor1_CallingButton != none ) {	Floor1_CallingButton.CageIsCalled( bMoveUp );	}
		if ( Floor2_CallingButton != none ) {	Floor2_CallingButton.CageIsCalled( bMoveUp );	}

//		if ( Mover(Internal_Button) != none ) { Mover(Internal_Button).BasePos = Internal_Button.Location; }
		GotoState( 'OpenInternalAndFirstFloorDoors' );
	}
}

STATE OpenInternalAndFirstFloorDoors
{
	EVENT BeginState( )
	{
		LOCAL float waittime;

		LOCAL bool bIsUp;
		bIsUp= (LiftCage.KeyPos[LiftCage.KeyNum].Z>LiftCage.KeyPos[1-LiftCage.KeyNum].Z);

//		if ( Internal_Button != none )		{	Internal_Button.CageIsCalled( bIsUp );	}
		if ( Floor1_CallingButton != none ) {	Floor1_CallingButton.CageIsCalled( bIsUp );	}
//		if ( Floor2_CallingButton != none ) {	Floor2_CallingButton.CageIsCalled( bIsUp );	}

		if ( Internal_Doors[0] != none )
		{
			Internal_Doors[0].DelayTime=Z_OpenDelayInternalDoor;
			Internal_Doors[0].SetLocation( LiftCage.Location + RL_Doors[0] );
			Internal_Doors[0].BasePos = Internal_Doors[0].Location;
			Internal_Doors[0].SetBase( LiftCage );
			Internal_Doors[0].Trigger( self, none );
			waittime=max(waittime,Internal_Doors[0].MoveTime+Z_OpenDelayInternalDoor);
		}
		if ( Internal_Doors[1] != none )
		{
			Internal_Doors[1].DelayTime=Z_OpenDelayInternalDoor;
			Internal_Doors[1].SetLocation( LiftCage.Location + RL_Doors[1] );
			Internal_Doors[1].BasePos = Internal_Doors[1].Location;
			Internal_Doors[1].SetBase( LiftCage );
			Internal_Doors[1].Trigger( self, none );
			waittime=max(waittime,Internal_Doors[1].MoveTime+Z_OpenDelayInternalDoor);
		}
		if ( Floor1_OuterDoors[0] != none )
		{
			Floor1_OuterDoors[0].DelayTime=Z_OpenDelayExternalDoor;
			Floor1_OuterDoors[0].Trigger( self, none );
			waittime=max(waittime,Floor2_OuterDoors[0].MoveTime+Z_OpenDelayExternalDoor);
		}
		if ( Floor1_OuterDoors[1] != none )
		{
			Floor1_OuterDoors[1].DelayTime=Z_OpenDelayExternalDoor;
			Floor1_OuterDoors[1].Trigger( self, none );
			waittime=max(waittime,Floor2_OuterDoors[1].MoveTime+Z_OpenDelayExternalDoor);
		}

		if ( waittime != 0 )
			SetTimer( waittime, false );
		else
			Timer( );
	}

	EVENT Timer( )
	{
		if ( Internal_Button != none )		{	Internal_Button.CageStops( );	}
		if ( Floor1_CallingButton != none ) {	Floor1_CallingButton.CageStops( );	}
		if ( Floor2_CallingButton != none ) {	Floor2_CallingButton.CageStops( );	}
		CurrentFloorDoorsOpen = true;
		GotoState( '' );
	}
}

STATE CloseInternalAndFirstFloorDoors
{
	EVENT BeginState( )
	{
		LOCAL float waittime;

		LOCAL bool bMoveUp;

//		DebugLog("LM::GotoFloor1::CloseInternalAndFirstFloorDoors");

		bMoveUp= (LiftCage.KeyPos[LiftCage.KeyNum].Z<LiftCage.KeyPos[1-LiftCage.KeyNum].Z);

		if ( Internal_Button != none )		{	Internal_Button.CageIsCalled( bMoveUp );	}
		if ( Floor1_CallingButton != none ) {	Floor1_CallingButton.CageIsCalled( bMoveUp );	}
		if ( Floor2_CallingButton != none ) {	Floor2_CallingButton.CageIsCalled( bMoveUp );	}

//		DebugLog( "Enter "$GetStateName() );

		if ( Internal_Doors[0] != none )
		{
			Internal_Doors[0].DelayTime = Z_CloseDelayInternalDoor;
			Internal_Doors[0].Untrigger( self, none );
			waittime=max(waittime,Internal_Doors[0].MoveTime+Z_CloseDelayInternalDoor);
		}
		if ( Internal_Doors[1] != none ) 
		{
			Internal_Doors[1].DelayTime = Z_CloseDelayInternalDoor;
			Internal_Doors[1].Untrigger( self, none );
			waittime=max(waittime,Internal_Doors[1].MoveTime+Z_CloseDelayInternalDoor);
		}
		if ( Floor1_OuterDoors[0] != none )
		{
			Floor1_OuterDoors[0].DelayTime = Z_CloseDelayExternalDoor;
			Floor1_OuterDoors[0].Untrigger( self, none );
			waittime=max(waittime,Floor2_OuterDoors[0].MoveTime+Z_CloseDelayExternalDoor);
		}
		if ( Floor1_OuterDoors[1] != none )
		{
			Floor1_OuterDoors[1].DelayTime = Z_CloseDelayExternalDoor;
			Floor1_OuterDoors[1].Untrigger( self, none );
			waittime=max(waittime,Floor2_OuterDoors[1].MoveTime+Z_CloseDelayExternalDoor);
		}

		if ( waittime != 0 )
			SetTimer( waittime, false );
		else
			Timer( );

	}

	EVENT Timer( )
	{
		CurrentFloorDoorsOpen = false;
		GotoState( 'GotoFloor2' );
	}
}

STATE GotoFloor2
{
	EVENT Trigger(actor Other, Pawn EventInstigator)
	{
	}

	EVENT BeginState( )
	{
		LOCAL float waittime;
		LOCAL bool bMoveUp;

//		DebugLog("LM::GotoFloor1::GotoFloor2");

		bMoveUp= (LiftCage.KeyPos[LiftCage.KeyNum].Z<LiftCage.KeyPos[1-LiftCage.KeyNum].Z);

//		DebugLog( "Enter "$GetStateName() );

		if ( LiftCage != none ) { LiftCage.trigger( self, none ); waittime=LiftCage.MoveTime; }

		if ( Internal_Button != none )		{	Internal_Button.CageMoves( bMoveUp );	}
		if ( Floor1_CallingButton != none ) {	Floor1_CallingButton.CageMoves( bMoveUp );	}
		if ( Floor2_CallingButton != none ) {	Floor2_CallingButton.CageMoves( bMoveUp );	}

		if ( waittime != 0 )
			SetTimer( waittime, false );
		else
			Timer( );
	}

	EVENT Timer( )
	{
		LOCAL bool bMoveUp;
		CurrentFloor = 2;
		bMoveUp= (LiftCage.KeyPos[LiftCage.KeyNum].Z>LiftCage.KeyPos[1-LiftCage.KeyNum].Z);
		if ( Internal_Button != none )		{	Internal_Button.CageIsCalled( bMoveUp );	}
		if ( Floor1_CallingButton != none ) {	Floor1_CallingButton.CageIsCalled( bMoveUp );	}
		if ( Floor2_CallingButton != none ) {	Floor2_CallingButton.CageIsCalled( bMoveUp );	}
		GotoState( 'OpenInternalAndSecondFloorDoors' );
	}
}

STATE OpenInternalAndSecondFloorDoors
{
	EVENT BeginState( )
	{
		LOCAL float waittime;

		LOCAL bool bIsUp;
		bIsUp= (LiftCage.KeyPos[LiftCage.KeyNum].Z>LiftCage.KeyPos[1-LiftCage.KeyNum].Z);

//		if ( Internal_Button != none )		{	Internal_Button.CageIsCalled( bIsUp );	}
//		if ( Floor1_CallingButton != none ) {	Floor1_CallingButton.CageIsCalled( bIsUp );	}
		if ( Floor2_CallingButton != none ) {	Floor2_CallingButton.CageIsCalled( bIsUp );	}

		if ( Internal_Doors[0] != none )
		{
			Internal_Doors[0].DelayTime = Z_OpenDelayInternalDoor;
			Internal_Doors[0].SetLocation( LiftCage.Location + RL_Doors[0] );
			Internal_Doors[0].BasePos = Internal_Doors[0].Location;
			Internal_Doors[0].SetBase( LiftCage );
			Internal_Doors[0].Trigger( self, none );
			waittime=max(waittime,Internal_Doors[0].MoveTime+Z_OpenDelayInternalDoor);
		}
		if ( Internal_Doors[1] != none )
		{
			Internal_Doors[1].DelayTime = Z_OpenDelayInternalDoor;
			Internal_Doors[1].SetLocation( LiftCage.Location + RL_Doors[1] );
			Internal_Doors[1].BasePos = Internal_Doors[1].Location;
			Internal_Doors[1].SetBase( LiftCage );
			Internal_Doors[1].Trigger( self, none );
			waittime=max(waittime,Internal_Doors[1].MoveTime+Z_OpenDelayInternalDoor);
		}
		if ( Floor2_OuterDoors[0] != none )
		{
			Floor2_OuterDoors[0].DelayTime=Z_OpenDelayExternalDoor;
			Floor2_OuterDoors[0].Trigger( self, none );
			waittime=max(waittime,Floor2_OuterDoors[0].MoveTime+Z_OpenDelayExternalDoor);
		}
		if ( Floor2_OuterDoors[1] != none )
		{
			Floor2_OuterDoors[1].DelayTime=Z_OpenDelayExternalDoor;
			Floor2_OuterDoors[1].Trigger( self, none );
			waittime=max(waittime,Floor2_OuterDoors[1].MoveTime+Z_OpenDelayExternalDoor);
		}

		if ( waittime != 0 )
			SetTimer( waittime, false );
		else
			Timer( );
	}

	EVENT Timer( )
	{
		if ( Internal_Button != none )		{	Internal_Button.CageStops( );	}
		if ( Floor1_CallingButton != none ) {	Floor1_CallingButton.CageStops( );	}
		if ( Floor2_CallingButton != none ) {	Floor2_CallingButton.CageStops( );	}
		CurrentFloorDoorsOpen = true;
		GotoState( '' );
	}
}

// 0
// XIIIMoverVarTime'MyLevel.XIIIMoverVarTime0'
// Porte'MyLevel.Porte4'
// 1
// XIIIMoverVarTime'MyLevel.XIIIMoverVarTime2'
// Porte'MyLevel.Porte5'
//
// Mover'MyLevel.Mover10'



defaultproperties
{
     CurrentFloor=1
     CurrentFloorDoorsOpen=True
     Z_TimeLiftCage=6.000000
     Z_TimeInternalDoors=3.000000
     Z_TimeExternalDoors=1.000000
     Z_OpenDelayExternalDoor=3.000000
     Z_CloseDelayInternalDoor=1.000000
     bAutomatic=True
     bDirectional=True
}
