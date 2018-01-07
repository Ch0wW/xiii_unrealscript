//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Hual04a extends Map06_HualparBase;

#exec obj load file=MeshObjetsPickup.usx package=MeshObjetsPickup

var() BaseSoldier SoldiersToKill[8];
var() GenNMI SoldiersEnRenforts[3];
var() name CablecarStartEvent;
var() Hual04aDecofusible FusibleRemisEnPlace;
var() XIIIMover CableCarLever;
var() CwndFocusTrigger FocusTrigger;
var() name EventFocusSoldierWithKey;
var() CWndSFXTrigger SFXTriggerTelepherique;
var() MagneticPassTrigger PassTrigger;
var() name EventMagneticCardPick;
var() XIIIGoalTrigger FuseInteraction;

var int eNbMorts,eNbVivants;
var bool bFuseInPosition;
var bool bTeleOn;
var XIIIPlayerController PC;



// Trouver le clef de l'armoire au fusible
// Active par le flingage de 6 mecs. ____ 6 x XIIIGoalTrigger Goal 99 avec les 6 tags == les 6 event des mecs a buter (differents !!)
// les 6 mecs à buter sont dans le tableau en variable mapinfo / SoldiersToKill.

// Obj 00 = trouver le moyen de fuir par le telepherique
      // Primary true pendant tous le jeu
// Obj 01 = Carrington ne doit pas mourrir
      // AntiGoal Primary true pendant tous le jeu
// Obj 02 = Trouver un fusible pour remettre en marche le telepherique
      // Active par l'ouverture d'une armoire (Mover) ____ XIIIGoalTrigger Goal 0 avec le Tag == Event du mover
      // Armoire vérouillée, Tag du mover == var mapinfo / FusibleLockedDoorEvent
      // Inactive par le fusible ramasse(obj suivant)
// Obj 03 = Placer le fusible dans la machinerie
      // Active par le ramassage du fusible ____ XIIIGoalTrigger Goal 2 avec Tag == Event du EventPick == 'FusibleRamasse'
      // bCauseEventOnPick true pour le EventPick fusible.
      // Inactive par l'utilisation du fusible sur un XIIIGoalTrigger (Obj suivant)
// Obj 04 = Activer le telepherique
      // Active par l'utilisation du fusible sur un XIIIGoalTrigger ____ XIIIGoalTrigger Goal 3 avec Tag =='FusibleEnPlace' (Modifier l'event du fusible une fois dans l'inventaire du joueur)
      // Inactive par l'utilisation d'un Mover.
// Obj 05 = Rejoindre Carrington
      // Active par l'objectif precedent ____ XIIIGoalTrigger Goal 4 avec Tag == Event du mover pour mettre en route le telepherique
// Obj 06 = Rdv dans le telepherique
      // Active en meme temps que le 5.

// mis en commentaire le 25/04/03 : enleve le staticmesh jaune au moment de l install !
/*function FirstFrame()
{
    Super.FirstFrame();

    if ( FusibleRemisEnPlace != none )
	{
      FusibleRemisEnPlace.bHidden = true;
	  FusibleRemisEnPlace.RefreshDisplaying();
	}
}*/

//_____________________________________________________________________________
FUNCTION SetGoalComplete(int N)
{
	local int i;
	local Inventory Inv;
	local EventItemPick PickU;
	local EventItem EvItem;
	local Hual04aFusible fuse;

	if ( N < Objectif.Length )
		Super.SetGoalComplete(N);

	switch (N)
	{
		case 0:     // Activated when fusebox is open
			if (!Objectif[2].bCompleted)     // if player doesn't have the fuse : the new objective is to find a fuse
				SetPrimaryGoal(2);
			else               // if player already have the fuse : the new objective is to installed it in the box
				SetPrimaryGoal(3);
			break;
		case 2:     // Activated when fuse is taken
		case 98:// Pseudo-objective if player found fuse before fusebox
			Objectif[2].bCompleted = true;
			SetSecondaryGoal(2);
			SetPrimaryGoal(3);
			foreach allactors(class'EventItemPick', PickU)
			{
				//        Log("        Grabbed Fusible checking "$PickU$" w/ event "$PickU.Event);
				if ( caps(PickU.Event) == caps('FusibleRamasse') )
				{
				PickU.Event = 'FusibleEnPlace';
				}
			}
			GotoState('RechercheFusible');
			break;
		case 93:   // remplacement du static mesh transparent par le static mesh du fusible
			FusibleRemisEnPlace.StaticMesh = StaticMesh'MeshObjetsPickup.TLfusible';
			FusibleRemisEnPlace.RefreshDisplaying();
			break;
		case 3:     // Activated when fuse is installed
			SetSecondaryGoal(3);      
			SetPrimaryGoal(4);
			// remplacement du static mesh transparent par le static mesh du fusible
			FusibleRemisEnPlace.StaticMesh = StaticMesh'MeshObjetsPickup.TLfusible';
			FusibleRemisEnPlace.RefreshDisplaying();
			// Must remove fuse from inventory
			Fuse = Hual04aFusible(XIIIPawn.FindInventoryType(class'Hual04aFusible'));
			//Log("Found Fuse "$Fuse$" in player inventory");
			if ( Fuse != none )
				Fuse.UsedUp();
			SFXTriggerTelepherique.Tag = CableCarLever.Event;
			for (i=0;i<4;i++)
			{
				log(self@" ---> TEST SOLDATS"@SoldiersEnRenforts[i].SpawnActor);
				if (( SoldiersEnRenforts[i] != none ) && ( !SoldiersEnRenforts[i].SpawnActor.bIsDead))
				{
					GotoState('FinDeMission');
					break;
				}
			}
			break;
		case 5: // Activated when Carrington reaches the cable-car and XIII is near enough
			Super.SetGoalComplete(6);
			break;
		case 94: // Activated when cablecar lever is used
			if ( !Objectif[4].bPrimary )
			{
				// le levier n est pas encore en marche
				if (CableCarLever != none )
				{
					CableCarLever.GoToState('PlayerTriggerToggle','Close');
					TriggerEvent('PowerLow',none,none);
				}
				// condition d'échec
				if ( Objectif[3].bPrimary )
				{
					for (i=0;i<4;i++)
					{
						if (( SoldiersEnRenforts[i] != none ) && ( !SoldiersEnRenforts[i].SpawnActor.bIsDead))
						{
							GotoState('FinDeMission');
						}
					}
				}
			}
			else
			{
				// le levier fonctionne, le telepherique peut demarrer
				TriggerEvent ( CableCarStartEvent, self, none );
				CableCarLever.GoToState('Locked');
				CableCarLever.bNoInteractionIcon = true;
				Super.SetGoalComplete(4);
				SetPrimaryGoal(5);
				SetPrimaryGoal(6);
			}
			break;
		case 99:// Activated when a soldier was killed
			eNbMorts ++;
			i = 0;
			while (i<eNbVivants)
			{
				if ( SoldiersToKill[i].bIsDead )
				{
					SoldiersToKill[i] = SoldiersToKill[eNbVivants-1];
					eNbVivants --;
					if (eNbVivants < 2)
					{
						// le dernier soldat porte une carte magnétique
						Inv = GiveSomething(class'MagneticCard', SoldiersToKill[0]);
						Inv.Event = PassTrigger.tag;
						XIIIItems(Inv).EventCausedOnPick = EventMagneticCardPick;

						FocusTrigger.Focus = SoldiersToKill[0];
						TriggerEvent(EventFocusSoldierWithKey,none,none);
					}
				}
				else
				{
					i ++;
				}
			}
			break;
		case 97:
			if ( bTeleOn )
				SetTimer2(0.5, false);
			break;
		case 96:
			bTeleOn = true;
			break;
	}
}


// Use this event to force the reactivation of the event if player placed fuse before killing all the gen. basesoldiers.
event Timer2()
{
  TriggerEvent('TeleOn', self, XIIIPawn);
}

State RechercheFusible
{
	// on recherche le fusible dans l inventaire et on renseigne son acteur d interaction
	event Tick( float dt )
	{
		local Hual04aFusible fuse;
		
		Fuse = Hual04aFusible(XIIIPawn.FindInventoryType(class'Hual04aFusible'));
		if ( Fuse != none )
		{
			Fuse.FuseInteraction = FuseInteraction;
			GotoState('');
		}
	}
}

State FinDeMission
{
Begin:
	Sleep(2);
	PC = XIIIGameInfo(Level.Game).MapInfo.XIIIController;
	while ( XIIIBaseHud(PC.MyHud).HudMsg != none )
	{
		XIIIBaseHud(PC.MyHud).HudMsg.RemoveMe();
	}
	Super.SetGoalComplete(1);
}


//_____________________________________________________________________________
/*function GeneratedPawn(Actor Generator, Pawn Other)
{
    if ( Generator == GeneratorForKey )
    {
      if ( SoldiersToKill[6] == none )
      {
        KillNb ++;
        SoldiersToKill[6] = Basesoldier(Other);
      }
      else if ( SoldiersToKill[7] == none )
      {
        KillNb ++;
        SoldiersToKill[7] = Basesoldier(Other);
      }
    }
}*/

// ATTENTION !!!!!!!!!!!!!!!!!!!!!!
//EndMapVideo="cine05"
// enlevé pour E3, à remettre impérativement par la suite !



defaultproperties
{
     CablecarStartEvent="TeleOn"
     eNbVivants=6
     Activate=True
     iLoadSpecificValue=81
}
