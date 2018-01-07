//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Banque01 extends Map02_Banque;

var(BankSetup) name SafeKeyEvent;
var(BankSetup) cine2 PersoBanquier;
var(BankSetup) float fDistanceBanquier;
var(BankSetup) name KeyEvent;
var(BankSetup) localized string KeyEventItemName;
var(BankSetup) XIIIPawn KeyKeeper;
var(BankSetup) Porte DoorToOpen;
var(BankSetup) name TagForGameOver;

var vector vPlayer_Banquier;
var XIIIPlayerController XPC;
var Keys CleBanque;
var bool bCleDonnee;
var bool bCleRedonnee;


//______________________________________________________________________________
function FirstFrame()
{
    local inventory Inv;

    Super.FirstFrame();

    if ( XIIIGameInfo(Level.Game).CheckPointNumber<2 && XIIIPawn != none )
    {
      Inv = GiveSomething(class'Keys', XIIIPawn);
      Inv.Event = SafeKeyEvent;
    }
	else
	{
		if ( XIIIGameInfo(Level.Game).CheckPointNumber > 1 )
		{
			if ( TagForGameOver != '' )
				Tag = TagForGameOver;
		}
	}
}

//_____________________________________________________________________________
event Trigger( actor Other,Pawn EventInstigator )
{
	local inventory Inv;

	// si le premier goal est rempli, on teste la mort de persos innoncents
	if ( Objectif[0].bCompleted )
	{
		//log(self@"---> QUI ME TUE ?"@EventInstigator);
		if ( XIIIPlayerPawn(EventInstigator) != none )
		{
			//log(self@"---> C'EST LE PERSO PRINCIPAL");
			SetGoalComplete(2);
		}
	}
	else
	{
		if ( bCleDonnee )
		{
			if ( bCleRedonnee )
			{
				// on retire l arme de la main du joueur
				if ( XPC.bWeaponMode )
				{
					XPC.OldWeap = XPC.Pawn.Weapon.InventoryGroup;
					XPC.Pawn.Weapon.PutDown();
				}
				else
				{
					XPC.OldItem = XIIIItems(XPC.Pawn.SelectedItem);
					XPC.OldItem.PutDown();
				}
				XPC.bWeaponBlock = true;
			}
			else
			{
				// on redonne la cle au joueur
				bCleRedonnee = true;
				Inv = GiveSomething(class'Keys', XIIIPawn );
				Inv.Event = KeyEvent;
				Keys(Inv).KeyCodeName = DoorToOpen.UnlockItemCode;
				Inv.ItemName = KeyEventItemName;
			}
		}
		else
		{
			//on enleve la cle de l inventaire
			bCleDonnee = true;
			XPC = XIIIGameInfo(Level.Game).MapInfo.XIIIController;
			GotoState('STA_DonneCle');
		}
	}
}


//_____________________________________________________________________________
function SetGoalComplete(int N)
{
	Super.SetGoalComplete(N);
	log("Banque01::SetGoalComplete"@n);
	if (N==0)
	{
		if ( TagForGameOver != '' )
			Tag = TagForGameOver;
		SetPrimaryGoal(1);
		SetPrimaryGoal(2);
	}
}


//_____________________________________________________________________________
State STA_DonneCle
{
	event Tick( float dt)
	{
		vPlayer_Banquier = PersoBanquier.Location - XPC.Pawn.Location;
		vPlayer_Banquier.z = 0;
		if (( vSize(vPlayer_Banquier) < fDistanceBanquier ) && ( XPC.CanSee(PersoBanquier) ))
		{
			SetTimer(0.1,false);
			Disable('Tick');
		}
	}

	event Timer()
	{
		TriggerEvent(event,none,none);
		//*** on supprime la cle de l inventaire
		CleBanque = Keys( XPC.Pawn.FindInventoryType( class'Keys' ) );
		XPC.NextWeapon();
		XPC.Pawn.ChangedWeapon();
		CleBanque.PlayDown();
		CleBanque.Destroy();
		GotoState('');
	}
}



defaultproperties
{
     SafeKeyEvent="SafeKeyEvent"
     KeyEventItemName="Key"
     checkTime=0.200000
     EndMapVideo="cine02"
}
