//=============================================================================
// TriggerAlarme.
//=============================================================================
class TriggerAlarme extends XIIITriggers;

var xiiigameinfo gameinf;
var genalerte genalerte;
var bool bAlarmeTargeted;
var bool bAlarmeActivated;

/*
//____________________________________________________________________
function PlayerTrigger(actor Other,pawn EventInstigator )
{
    Trigger(Other, EventInstigator);
}

//____________________________________________________________________
function Trigger(actor Other,pawn EventInstigator )
{
   TriggerEvent(event,self,EventInstigator);
   if (!balarmeActivated) //si player active alarme
   {
      genalerte.poteDeclencheAlarme(pawn(other),self);
   }
}
	*/
event Destroyed()
{
    local int i;
	 local xiiigameinfo gameinf;

    //supression de la alarmlist
    gameinf=xiiigameinfo(level.game);
	for (i = 0; i < gameinf.AlarmList.Length; i++)
	{
		if (gameinf.AlarmList[i] == self )
		{
			gameinf.AlarmList.Remove(i,1);
			break;
		}
	}
}

auto state init
{
begin:
   sleep(0.5);
   gameinf=xiiigameinfo(level.game);
   genalerte=genalerte(gameinf.genalerte);
   gotostate('');
}



defaultproperties
{
}
