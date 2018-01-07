//-----------------------------------------------------------
//
//-----------------------------------------------------------
class PRock01a extends Map08_PlainRock;

var(PRock01aSetUp) XIIIPawn GardeLocal;
var(PRock01aSetUp) XIIIPawn Tabasseur1;
var(PRock01aSetUp) XIIIPawn Tabasseur2;
var(PRock01aSetUp) XIIIPawn Gardien1;
var(PRock01aSetUp) XIIIPawn Gardien2;

var(PRock01aSetUp) GenNMI GenNMI_GardeCouloir;
var(PRock01aSetUp) GenNMI GenNMI_GardeRotonde1;
var(PRock01aSetUp) GenNMI GenNMI_GardeRotonde2;

var(PRock01aSetUp) localized string sClefPorteLocal;
var(PRock01aSetUp) localized string sClefEscaliers;
var(PRock01aSetUp) localized string sClefCouloir;
var(PRock01aSetUp) localized string sClefEntreeRotonde;
var(PRock01aSetUp) localized string sClefSortieRotonde;
var(PRock01aSetUp) localized string sClefDebarrasLingerie;

var(PRock01aSetUp) DialogueManager DialManagerBas;
var(PRock01aSetUp) DialogueManager DialManagerHaut;

var(PRock01aSetUp) float fBlurDelay;

var(PRock01aSetUp) name EventClefPorteLocal;
var(PRock01aSetUp) name EventClefDebarrasLingerie;
var(PRock01aSetUp) name EventClefCouloir;
var(PRock01aSetUp) name EventClefEscaliers;
var(PRock01aSetUp) name EventClefEntreeRotonde;
var(PRock01aSetUp) name EventClefSortieRotonde;

var bool bAlarm;

var bool bPremierGenNMI;
var bool bPremierDialogue;

var Pawn PersoParleur;
var DialogueManager DialDuParleur;
var name TagTemp;



// Keys
/*
ClefPorteLocal          -> GardeLocal
ClefEscaliers          -> GardeLingerie1
ClefCouloir          -> GardeLingerie2
ClefEntreeRotonde      -> GardeCouloir
ClefSortieRotonde     -> GardeRotonde1 & GardeRotonde2
*/

//_____________________________________________________________________________
event PostBeginPlay()
{
	local mutator m;

	Super.PostBeginPlay();

	// prise en compte d un mutator qui retire les poings au joueur
	m = Spawn( class'PRock01aMutator' );
	m.NextMutator = Level.Game.BaseMutator.NextMutator;
	Level.Game.BaseMutator = m; //.AddMutator(m);

}


//_____________________________________________________________________________
function FirstFrame()
{
    local inventory Inv;

    Super.FirstFrame();

    Inv = GiveSomething(class'Keys', GardeLocal);
    Inv.Event = 'ClefPorteLocal';
    Keys(Inv).KeyCodeName = "ClefPorteLocal";
    Inv.ItemName = sClefPorteLocal;
	XIIIItems(Inv).EventCausedOnPick = EventClefPorteLocal;

   Inv = GiveSomething(class'PRock01aCorridorKey', Gardien1);
	Inv.Event = 'ClefCouloir';
	//Keys(Inv).InventoryGroup = 6;
	Keys(Inv).KeyCodeName = "ClefCouloir";
	Inv.ItemName = sClefCouloir;
	XIIIItems(Inv).EventCausedOnPick = EventClefCouloir;

    Inv = GiveSomething(class'PRock01aStairsKey', Gardien2);
    Inv.Event = 'ClefEscaliers';
	//Keys(Inv).InventoryGroup = 7;
    Keys(Inv).KeyCodeName = "ClefEscaliers";
    Inv.ItemName = sClefEscaliers;
	XIIIItems(Inv).EventCausedOnPick = EventClefEscaliers;

	if ( XIIIGameInfo(Level.Game).CheckPointNumber<2 ) // ( !Objectif[0].bCompleted ) || ( !Objectif[0].bPrimary ) )
		GotoState( 'STA_Blur' );
}


//_____________________________________________________________________________
function Trigger( actor Other, pawn EventInstigator )
{

	// premier cas : au bas de la rotonde
	if ( !bPremierDialogue )
	{
		if ( bAlarm )
		{
			// on renseigne le maton dans le premier dialogue manager
			if ( DialManagerBas != none )
			{
				log(self@"---> PREMIER : REPERE PAR MATON"@EventInstigator);
				DialManagerBas.Speakers[0].Pawn = EventInstigator;
				TriggerEvent( DialManagerBas.tag, none, none );
				PersoParleur = EventInstigator;
				DialDuParleur = DialManagerBas;
				TagTemp = Tag;
				Tag = DialManagerBas.event;
				GotoState( 'STA_TestMortParleur' );
			}
		}
	}
	else
	{
		// on renseigne le maton dans le second dialogue manager
		if ( DialManagerHaut != none )
		{
			log(self@"---> SECOND : REPERE PAR MATON"@EventInstigator);
			DialManagerHaut.Speakers[0].Pawn = EventInstigator;
			DialManagerHaut.Speakers[1].Pawn = EventInstigator;
			TriggerEvent( DialManagerHaut.tag, none, none );
			PersoParleur = EventInstigator;
			DialDuParleur = DialManagerHaut;
			TagTemp = Tag;
			Tag = DialManagerHaut.event;
			GotoState( 'STA_TestMortParleur' );
		}
	}
}


//_____________________________________________________________________________
function SetGoalComplete(int N)
{

	local inventory Inv;

	if ( N == 91 )
	{
		SetPrimaryGoal(0);
		return;
	}

	if ( N == 92 )
	{
		Super.SetGoalComplete(0) ;
		SetPrimaryGoal(1);
		return;
	}

	if ( N == 93 )
	{
		bAlarm=true;
		return;
	}

	if ( N == 94 )
	{
		bPremierDialogue = true;
		Enable('Trigger');
	}

	if ( N == 95 )
	{
		// on donne la cle au garde du couloir
		if ( GenNMI_GardeCouloir.SpawnActor != none )
		{
			Inv = GiveSomething(class'PRock01aRotondeKey', GenNMI_GardeCouloir.SpawnActor);
			Inv.Event = 'ClefEntreeRotonde';
			Keys(Inv).KeyCodeName = "ClefEntreeRotonde";
			Inv.ItemName = sClefEntreeRotonde;
			XIIIItems(Inv).EventCausedOnPick = EventClefEntreeRotonde;
		}

		// on donne la cle au deuxième des gardes de la rotonde
/*		if (( GenNMI_GardeRotonde1.SpawnActor != none ) && ( GenNMI_GardeRotonde2.SpawnActor != none ))
		{
			if ( fRand() < 0.5 )
			{
				Inv = GiveSomething(class'PRock01aRotondeExitKey', GenNMI_GardeRotonde1.SpawnActor);
				Inv.Event = 'ClefSortieRotonde';
				Keys(Inv).KeyCodeName = "ClefSortieRotonde";
				Inv.ItemName = sClefSortieRotonde;
				XIIIItems(Inv).EventCausedOnPick = EventClefSortieRotonde;
			}
			else
			{*/
				Inv = GiveSomething(class'PRock01aRotondeExitKey', GenNMI_GardeRotonde2.SpawnActor);
				Inv.Event = 'ClefSortieRotonde';
				Keys(Inv).KeyCodeName = "ClefSortieRotonde";
				Inv.ItemName = sClefSortieRotonde;
				XIIIItems(Inv).EventCausedOnPick = EventClefSortieRotonde;
//			}
//		}
	}
	if ( N == 96 ) // Activated when a tabasseur2 was killed
	{
	    if (!Tabasseur1.bIsDead)
		 {
			 Inv = GiveSomething(class'Keys', Tabasseur1);
			 Inv.Event = 'ClefDebarrasLingerie';
			 Keys(Inv).KeyCodeName = "ClefDebarrasLingerie";
			 Inv.ItemName = sClefDebarrasLingerie;
			 XIIIItems(Inv).EventCausedOnPick = EventClefDebarrasLingerie;
		}
		else
			TriggerEvent( 'garde1mort', Tabasseur2, Tabasseur2);
	}
	if ( N == 97 ) // Activated when a tabasseur1 was killed
	{
		 if (!Tabasseur2.bIsDead)
		 {
			 Inv = GiveSomething(class'Keys', Tabasseur2);
			 Inv.Event = 'ClefDebarrasLingerie';
			 Keys(Inv).KeyCodeName = "ClefDebarrasLingerie";
			 Inv.ItemName = sClefDebarrasLingerie;
			 XIIIItems(Inv).EventCausedOnPick = EventClefDebarrasLingerie;
		}
		else
			TriggerEvent( 'garde2mort', Tabasseur1, Tabasseur1);

	}

	Super.SetGoalComplete(N);
}

//_____________________________________________________________________________
STATE STA_Blur
{
begin:
	Level.SetInjuredEffect(true,0.01);
	sleep(0.01);
	Level.SetInjuredEffect(false,fBlurDelay);
	GotoState('');
}


//_____________________________________________________________________________
STATE STA_TestMortParleur
{
	event Trigger( actor Other, pawn EventInstigator )
	{
		Tag = TagTemp;
		Disable( 'Trigger' );
		GotoState('');
	}

	event Tick( float dt )
	{
		if ( PersoParleur.bIsDead )
		{
			// on interrompt le dialogue
			DialDuParleur.Destroy();
			Tag = TagTemp;
			Disable( 'Trigger' );
			GotoState('');
		}
	}
}


//_____________________________________________________________________________


defaultproperties
{
     fBlurDelay=10.000000
     iLoadSpecificValue=55
}
