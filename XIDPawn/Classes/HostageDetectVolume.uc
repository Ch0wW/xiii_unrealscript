//-----------------------------------------------------------
//    HostageDetectVolume
//-----------------------------------------------------------
class HostageDetectVolume extends Volume;

ignores touch;

var bool bActivated;
var XiiiPlayerPawn XIII;

auto state init
{
begin:
   XIII=XIIIPlayerPawn(XIIIGameInfo(level.game).mapinfo.XIIIpawn);
   gotostate('');
}


//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
//Detection quand perso rentre dans volume avec otage
//
state() Detection
{
	function Trigger( actor Other, pawn EventInstigator )
  {
  }
  //_______________________________________________________________
  // When HostageDetectvolume is triggered...
	event Touch( actor Other)
	{
      if (!bActivated)
     	{
          if (Other==XIII && XIII.bPrisonner)
          {
             bActivated=true;
             instigator=xiiipawn(Other);
             TriggerEvent(Event, Self, instigator);
             gotostate('');
          }
   	  }
	}
begin:
}

// When detectionvolume is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
     Instigator = EventInstigator;
     gotostate('Detection');
}



defaultproperties
{
     bStatic=False
     bAlwaysRelevant=True
     InitialState="Detection"
     CollisionRadius=126.000000
     CollisionHeight=126.000000
}
