//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPFlagBase extends NavigationPoint
     placeable;

//#exec AUDIO IMPORT FILE="..\botpack\Sounds\CTF\flagtaken.WAV" NAME="flagtaken" GROUP="CTF"

var() byte Team;
var() Sound TakenSound;

//_____________________________________________________________________________
function PostBeginPlay()
{
    local XIIIMPFlag myFlag;

    Super.PostBeginPlay();
    LoopAnim('newflag');
    if (!Level.Game.IsA('XIIIMPCTFGameInfo'))
    {
      Log(">>>> "$self$" XIIIMPFlagBase says Level is not a CTF Level");
      return;
    }

//    bHidden = false;
    if ( Team == 0 )
    {
      Log(">>>> "$self$" XIIIMPFlagBase Spawns Red Flag");
      myFlag = Spawn(class'XIIIMP.XIIIMPRFlag');
    }
    else if ( Team == 1 )
    {
      Log(">>>> "$self$" XIIIFlagBase Spawns Blue Flag");
      myFlag = Spawn(class'XIIIMP.XIIIMPFlag');
    }

    myFlag.HomeBase = self;
}

function PlayAlarm()
{
     SetTimer(5.0, false);
     AmbientSound = TakenSound;
}

function Timer()
{
     AmbientSound = None;
}

//     TakenSound=Sound'XIIISounds.flagtaken'


defaultproperties
{
     bStatic=False
     bNoDelete=True
     bAlwaysRelevant=True
     bCollideActors=True
     DrawScale=1.300000
     CollisionRadius=60.000000
     CollisionHeight=60.000000
     NetUpdateFrequency=3.000000
}
