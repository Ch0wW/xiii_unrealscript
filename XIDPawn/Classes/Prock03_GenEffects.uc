//=============================================================================
// Prock03_GenEffects.
//=============================================================================
class Prock03_GenEffects extends GenFRD;

var xiiiplayerpawn xiii;
VAR TRANSIENT XIIIPlayerController PC;
var int iAutoaim;


/*
var int NbDegats;



function XIIIBurned()
{
    //effet
    NbDegats=1;
    settimer(1,false);
}

function timer()
{
    //degats
    //xiii.TakeDamage(70, Instigator, Hitlocation, -MomentumTransfer * normal(velocity), MyDamageType);
    xiii.TakeDamage(50, Instigator, xiii.location, vect(0,0,0), class'DTRocketed');
    //fin effet
    if (NbDegats<3)
    {
       settimer(1,false);
       NbDegats++;
    }
}   */


function XIIIPoisoned()
{
	local Johansson JoJo;

	 Level.Game.SetGameSpeed(0.4);
    level.SetPoisonEffect(true,2);
    iAutoaim=PC.iAutoAimMode;
    PC.iAutoAimMode=0;
    PC.ThrowWeapon();
    PC.switchweapon(0);
	 JoJo=Johansson(instigator);
    JoJo.bxiiipoisoned=true;
	 if (rand(4)==0)
	 {
		 triggerevent('dial_serum',self,instigator);
		 JoJo.timersound=level.timeseconds;
		 JoJo.bSerumSound=true;
		 JoJo.bPlayedSound=true;
	 }
    xiii.playsound(Sound'XIIIsound.XIIIPerso__XIIIPaf.XIIIPaf__hTrip');
    settimer2(3,false);
}

function timer2()
{
	 Level.Game.SetGameSpeed(1);
    level.SetPoisonEffect(false,2);
    xiii.playsound(Sound'XIIIsound.XIIIPerso__XIIIPaf.XIIIPaf__hTrip');
    PC.iAutoAimMode=iAutoaim;
    Johansson(instigator).bxiiipoisoned=false;
}




defaultproperties
{
}
