//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPDuckGameInfo extends XIIIMPGameInfo;

var class<LocalMessage> DuckMessageClass;
var pawn WhoHasTheDuck;
var XIIIMPDuckEmiter DuckEmitter;
var TheDuck TheDuck;

//_____________________________________________________________________________

function AddBot(int BotID)
{
    local DuckBotController Bot;

    Bot = spawn( class'DuckBotController');

    if ( BotClasses[ BotID ] == none )
      BotClasses[ BotID ] = class<XIIIPlayerPawn>(DynamicLoadObject(BotClassesName[ BotID ], class'class'));


    Bot.PawnClass = BotClasses[ BotID ];
    Bot.Skill = level.BotLevel[BotID];
    Bot.PlayerReplicationInfo.PlayerID = CurrentID++;
    Bot.bIsBot = true;
}

//_____________________________________________________________________________

function ScoreKill(Controller Killer, Controller Other)
{
    if (killer == Other)
        Other.PlayerReplicationInfo.Score -= 50;
    else if ( killer.PlayerReplicationInfo != None )
    {
        Other.PlayerReplicationInfo.Score -= 1;
        XIIIPlayerReplicationInfo(killer.PlayerReplicationInfo).MyDeathScore += 1;
    }
}

//_____________________________________________________________________________

function BroadcastDuckMessage( controller Other )
{
    BroadcastLocalizedMessage( GameMessageClass, 0 );
}

//_____________________________________________________________________________



defaultproperties
{
     HUDType="XIIIMP.XIIIBirdHUD"
     MutatorClass="XIIIMP.XIIIMPDuckMutator"
}
