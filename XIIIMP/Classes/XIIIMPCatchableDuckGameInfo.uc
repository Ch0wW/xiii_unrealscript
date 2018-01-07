//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPCatchableDuckGameInfo extends XIIIMPDuckGameInfo;


//_____________________________________________________________________________

function AddBot(int BotID)
{
    local CatchableDuckBotController Bot;

    Bot = spawn( class'CatchableDuckBotController');

    if ( BotClasses[ BotID ] == none )
      BotClasses[ BotID ] = class<XIIIPlayerPawn>(DynamicLoadObject(BotClassesName[ BotID ], class'class'));


    Bot.PawnClass = BotClasses[ BotID ];
    Bot.PlayerReplicationInfo.PlayerID = CurrentID++;
    Bot.bIsBot = true;
}

//_____________________________________________________________________________

function ScoreKill(Controller Killer, Controller Other);

//_____________________________________________________________________________



defaultproperties
{
     HUDType="XIIIMP.XIIITeamHUD"
     MutatorClass="XIIIMP.XIIIMPCatchableDuckMutator"
}
