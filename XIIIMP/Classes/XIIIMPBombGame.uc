//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPBombGame extends XIIIMPTeamGameInfo;

//var class<XIIIPlayerPawn> DefenderClasses[5];
//var string DefenderClassesName[5];             // dynamic load of pawn classes
var array<MPBombingBase> Objectives;

//const NBCLASSES=5;

//_____________________________________________________________________________
function ScoreKill(Controller Killer, Controller Other)
{
    if (killer == Other)
    { // Suicide or killed by something and not someone
      Other.PlayerReplicationInfo.Score -= 1;
      if ( PlayerController(Other) != none )
        PlayerController(Other).PlayerStat.StatSuicides ++;
    }
    else if ( killer.PlayerReplicationInfo != None )
    {
      if ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
      {
        if ( PlayerController(Killer) != none)
          PlayerController(killer).PlayerStat.StatKills ++;
        if ( PlayerController(Other) != none)
          PlayerController(Other).PlayerStat.StatDeaths ++;
        killer.PlayerReplicationInfo.Score += 1;
        XIIIPlayerReplicationInfo(killer.PlayerReplicationInfo).MyDeathScore += 1;
      }
      else
      {
        if ( PlayerController(Killer) != none)
          PlayerController(killer).PlayerStat.StatKills --;
        killer.PlayerReplicationInfo.Score -= 1;
      }
    }

    if ( GameRulesModifiers != None )
      GameRulesModifiers.ScoreKill(Killer, Other);

    CheckScore(Killer.PlayerReplicationInfo);
}
//_____________________________________________________________________________
event InitGame( string Options, out string Error )
{
    Super.InitGame(Options, Error);
    MaxTime = 600;
    WinningScore = 1;
}

//_____________________________________________________________________________
function bool ChangeClass(Controller Other, class<Pawn> InClass)
{
	if ( Other.Pawn.Weapon!=none )
	{
		Other.Pawn.Weapon.Destroy( );
		Other.Pawn.Weapon = none;
	}

    Other.PawnClass = InClass;
    return true;
}

//_____________________________________________________________________________
function GivePointToTheDefender()
{
    local controller C;

    for (C=Level.ControllerList; C!=None; C=C.NextController )
    {
        if( C.PlayerReplicationInfo.Team.TeamIndex == 1 )
        {
            if( C.PlayerReplicationInfo.Team.Score == 0 )
            {
                C.PlayerReplicationInfo.Team.Score = 1.0;
                break;
            }
        }
    }
}

//_____________________________________________________________________________
State MatchInProgress
{
    event BeginState()
    {
      bGameEnded = false;
    }

    event timer()
    {
      Super( XIIIGameInfo ).Timer();
      if ( !bOverTime && (MaxTime > 0) )
      {
        GameReplicationInfo.bStopCountDown = false;
        RemainingTime --;
        XIIIGameReplicationInfo(GameReplicationInfo).XIIIRemainingTime = RemainingTime;
        if ( RemainingTime % 60 == 0 )
          GameReplicationInfo.RemainingMinute = RemainingTime;
        if ( RemainingTime <= 0 )
        {
            PlayMenu(hTimeLimit);
            GivePointToTheDefender();
            EndGame(FindWinner(),"TimeLimit");
        }
        if ( RemainingTime == 60 )
           PlayMenu(hLastMinute);
      }
    }
}

//_____________________________________________________________________________
function StartMatch()
{
    local controller C;
    local int Loop;


    for (C=Level.ControllerList; C!=None; C=C.NextController )
    {
        if( SabotageBotController(C) != none )
        {
            for( Loop = 0 ; Loop < 3 ; Loop++ )
            {
                SabotageBotController(C).BombSpotStatus[ Loop ] = 1;
            }
        }
    }

    super.StartMatch();
}

//_____________________________________________________________________________
function AddBot(int BotID)
{

    local SabotageBotController Bot;

    Bot = spawn( class'SabotageBotController');

    if ( BotClasses[ BotID ] == none )
      BotClasses[ BotID ] = class<XIIIPlayerPawn>(DynamicLoadObject(BotClassesName[ BotID ], class'class'));


    Bot.PawnClass = BotClasses[ BotID ];
    Bot.PlayerReplicationInfo.PlayerID = CurrentID++;
    Bot.bIsBot = true;

    Bot.TeamID = Level.BotTeam[BotID];
    Bot.Skill = level.BotLevel[BotID];
    ChangeTeam(Bot,Level.BotTeam[BotID]);
}

//_____________________________________________________________________________
function InitObjectives()
{
    Local MPBombingBase OB;
    Local int i;

    //Log("BOMBING-] Init Objectives");
    i = 0;
    foreach allactors(class'MPBombingBase', OB)
    {
      //Log("       -]   found :"@OB);
      Objectives[i] = OB; // auto incrment array
      i++;
    }
}


//_____________________________________________________________________________
function ScoreObjective(PlayerReplicationInfo Scorer, Int Score)
{
    if ( Scorer != None )
    {
      Scorer.Score += 10;
    }
    if ( GameRulesModifiers != None )
      GameRulesModifiers.ScoreObjective(Scorer,Score);

    CheckScore(Scorer);
}

//_____________________________________________________________________________
function CheckScore(PlayerReplicationInfo Scorer)
{
    Local int i, j;
    Local bool bWon;

    log("*** CheckScore ***");

    if( RemainingTime <= 0 )
        return;

    if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
      return;

    if ( Objectives.Length == 0 )
      InitObjectives();

    // check if all objectives are on the same side
    //log( "BOMBING-] CheckObjectives");
    bWon = true;
    for (i=0; i<Objectives.Length; i++)
    {
      //log( "       -] testing Objective"@Objectives[i]@"Team:"@Objectives[i].CurrentTeam);
      if ( Objectives[i].CurrentTeam != 0 )
        bWon = false;
    }

    //log( "BOMBING-] Game won ? "$bWon@Scorer.Team.Score);
    if ( bWon )
    {
      Scorer.Team.Score = 1.0;
      EndGame(Scorer, "Completed");
    }
}

//_____________________________________________________________________________
// ELR ::TODO:: Handle the team/class change between each match there ?
function ReStartMatch()
{
    local controller C;

    Log("MP-] -- RESTART MATCH --, MaxTime="$MaxTime@"RemainingTime="$XIIIGameReplicationInfo(GameReplicationInfo).XIIIRemainingTime);
    for (C=Level.ControllerList; C!=None; C=C.NextController )
      RestartPlayer(C);

    StartMatch();
}



defaultproperties
{
     ScoreBoardType="XIIIMP.XIIIMPSabotageScoreBoard"
     HUDType="XIIIMP.XIIIBombHud"
     MapPrefix="SB"
     GameName="Sabotage"
     MutatorClass="XIIIMP.MPBombMutator"
}
