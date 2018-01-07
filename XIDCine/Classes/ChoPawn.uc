//***********************************
//********* BARFIGHT BARMAN *********
//***********************************

class ChoPawn extends Cine2;


//*** Variables
var() int eNbFoisTouches;
var int eNbTakeDamage;
var weapon OldWeapon;



STATE CineInit
{
	//*** Damages detection
	function TakeDamage(int Damage, pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> damageType)
	{	
		eNbTakeDamage ++;
		//log(self@eNbTakeDamage);
		if (eNbTakeDamage == eNbFoisTouches)
		{
			//log(self@"====> COURAGE FUYONS");
			CurrentTabActionIndex = 2;
			CineController.StartSequence();
		}
	}
}

//*** no more ammo
function ChangedWeapon()
{
	Super.ChangedWeapon();
	//log(self@"====> CHANGEMENT ARME"@weapon@pendingweapon);
	if ((OldWeapon.IsA('Tknife')) && Weapon.IsA('Fists'))
	{
		//log(self@"====> COURAGE FUYONS");
		CurrentTabActionIndex = 2;
		CineController.StartSequence();		
	}
	OldWeapon = Weapon;
}



//*** Default properties


defaultproperties
{
     eNbFoisTouches=2
     Reaction(0)=(eCS_Stimulus=CS_MapStart,TabActionIndex=1,bUneSeuleFois=True)
}
