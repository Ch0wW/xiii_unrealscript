//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Palace01b extends Map14_Palace;

// 0 == ANTIGOAL, do not get spotted
// 1 == Reach chamber 41 (Activate 2)
// 2 == Spy the council using the microcannon (Deactivate 0, Activate 3 & 4)
// 3 == ANTIGOAL, do not let Willard & Winslow leave (Give chronometer)
// 4 == Deactivate the electrical generator (Deactivate 3, Activate 5)
// 5 == Goto fighting location (Activate 6)
// 6 == Get rid of Winslow (Activate 7)
// 7 == Get rid of Willard

// 99 == used by chronometer
// 98 == Train ended, now spy is real & serious
// 97 == Missed our target while in training
// 96 == make corpse reappear

var(Objectifs) float Goal3ChronoTime;

var(Palace01bSetUp) XIIIPawn PoolRoomKeyHolder;
var(Palace01bSetUp) localized string sPoolRoomKeyName;

var(Palace01bSetUp) Pawn MicroTarget;      // the target to assign the micro for the spying sequence
var(Palace01bSetUp) Pawn FinancialSupportDocumentOwner;
var(Palace01bSetUp) Pawn CatererBillDocumentOwner;

var(Palace01bSetUp) int SupportDoc_PersoNum;
var(Palace01bSetUp) localized string SupportDoc_Information;
var(Palace01bSetUp) texture SupportDoc_Photography;

var(Palace01bSetUp) int Bill_PersoNum;
var(Palace01bSetUp) localized string Bill_Information;
var(Palace01bSetUp) texture Bill_Photography;

var(Palace01bSetUp) float fTimeBeforeNotPlayingsAmos1DidacMiss;
var(Palace01bSetUp) DialogueManager AmosDDialogMngr;

var(Palace01bSetUp) array<XIIICorpse> GenCorpse;

var(Palace01bSetUp) name EventSupportDocPick;
var(Palace01bSetUp) name EventBillPick;
var(Palace01bSetUp) name EventKeyPick;

var Micro Mic;

event PostBeginPlay()
{
    local int i;

    Super.PostBeginPlay();
    for (i=0; i<GenCorpse.length; i++)
    {
      GenCorpse[i].SetDrawType(DT_none);
      GenCorpse[i].SetCollision(false,false,false);
      GenCorpse[i].bStasis=true;
    }
}

//_____________________________________________________________________________
FUNCTION FirstFrame()
{
    LOCAL inventory Inv;
	LOCAL XIIIDocuments Doc;

    Super.FirstFrame();

    if ( PoolRoomKeyHolder != none )
	{
		Inv = GiveSomething(class'Keys', PoolRoomKeyHolder);
		Inv.Event = 'billardroom';
		Keys(Inv).KeyCodeName = "billardroom";
		Inv.ItemName = sPoolRoomKeyName;
		XIIIItems(Inv).EventCausedOnPick = EventKeyPick;
	}

    Inv = GiveSomething(class'Silencer', XIIIPawn);

    Inv = GiveSomething(class'Micro', XIIIPawn);
    Mic = Micro(Inv);
    if ( Mic != none )
    {
      Mic.ListenTarget = MicroTarget;
	  Mic.bCanCauseGameOver = false;
    }

	if ( FinancialSupportDocumentOwner != none )
	{
		Doc = Spawn(class'XIIIDocuments');
		if ( Doc != none )
		{
			Doc.GiveTo( FinancialSupportDocumentOwner );
			Doc.EventCausedOnPick = EventSupportDocPick;
		}
	}

	if ( CatererBillDocumentOwner != none )
	{
		Doc = Spawn(class'XIIIDocuments');
		if ( Doc != none )
		{
			Doc.GiveTo( CatererBillDocumentOwner );
			Doc.EventCausedOnPick = EventBillPick;
		}
	}
}

//_____________________________________________________________________________
FUNCTION SetGoalComplete(int N)
{
	LOCAL inventory inv;
	LOCAL Chronometre C;
	LOCAL int i;
	LOCAL DialogueManager dm;

	switch ( N )
	{
	case 99:
	// Chrono ended... too bad GameOver.
		Level.Game.EndGame( XIIIController.PlayerReplicationInfo, "GoalIncomplete" );
		return;
	case 98:
	// Training phase ended, let's play seriously
		DebugLog("@@@ Palace01b Training ended, NOW IT IS SERIOUS");
		Mic.bCanCauseGameOver = true;
		Mic.Charge = Mic.Default.Charge;
		if (AmosDDialogMngr.Tag != 'RealThingStart')
		{
			DebugLog("@@@ Palace01b Setting DialogManager to next line RealThingStart");
			AmosDDialogMngr.LineIndex = 1;
			AmosDDialogMngr.Tag = 'RealThingStart';
		}
		DebugLog("@@@ Palace01b TRIGGER RealThingStart");
		TriggerEvent('RealThingStart', self, XIIIPawn);
		break;
	case 97:
		Log("@@@ Palace01b we missed our target while training, Level.TimeSeconds="$Level.TimeSeconds);
		if ( Level.TimeSeconds > fTimeBeforeNotPlayingsAmos1DidacMiss )
		{ // set dialogmanager to wait for next sentence.
//			TriggerEvent('LoseTarget', self, XIIIPawn);
//			AmosDDialogMngr.StartDialogue(0);
	        AmosDDialogMngr.LineIndex = 1;
		    AmosDDialogMngr.Tag = 'RealThingStart';
		}
		else
		{ // Play it
			TriggerEvent('LoseTarget', self, XIIIPawn);
		}
		break;
	case 96:
		for (i=0; i<GenCorpse.length; i++)
		{
			GenCorpse[i].SetDrawType(DT_mesh);
			GenCorpse[i].SetCollision(true,false,false);
			GenCorpse[i].bStasis=false;
		}
		break;
	}

	super.SetGoalComplete(N);

	if ( bLevelComplete )
	{
		C = Chronometre(XIIIPawn.FindInventoryType(class'Chronometre'));
		if (C != none)
		{
			C.Destroy();
		}
	}

	if ( N==1 )
	{
		Mic.bActivated = true;
		Mic.bCanCauseGameOver = false;
		fTimeBeforeNotPlayingsAmos1DidacMiss = default.fTimeBeforeNotPlayingsAmos1DidacMiss + Level.TimeSeconds;
		DebugLog("@@@ Set up training phase, fTimeBeforeNotPlayingsAmos1DidacMiss="$fTimeBeforeNotPlayingsAmos1DidacMiss);
		SetPrimaryGoal(2);
	}
	else if ( N == 2 )
	{
		SetPrimaryGoal(3);
		SetPrimaryGoal(4);
		SetSecondaryGoal(0);
		Mic.bActivated = false;
		Mic.bCanCauseGameOver = false;
		inv = GiveSomething(class'Chronometre', XIIIPawn);
		C = Chronometre(inv);
		if (C != none)
			C.ReSetTimer(Goal3ChronoTime);
	}
	else if ( N == 4 )
	{
		C = Chronometre(XIIIPawn.FindInventoryType(class'Chronometre'));
		if (C != none)
		{
			C.Destroy();
		}
		SetPrimaryGoal(5);
		SetSecondaryGoal(3);
	}
	else if ( N == 5 )
	{
		SetPrimaryGoal(6);
	}
	else if ( N == 6 )
	{
		SetPrimaryGoal(7);
	}
}



defaultproperties
{
     Goal3ChronoTime=60.000000
     sPoolRoomKeyName="Pool Room Key"
     fTimeBeforeNotPlayingsAmos1DidacMiss=28.000000
     EndMapVideo="cine13"
}
