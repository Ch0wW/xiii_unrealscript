//-----------------------------------------------------------
// XIIICTFGameInfo || For CTF GamePlay
//-----------------------------------------------------------
class XIIIMPCTFGameInfo extends XIIIMPTeamGameInfo;

//_____________________________________________________________________________
function AddBot(int BotID)
{
    local TeamBotController Bot;

    Bot = spawn( class'CTFBotController');

    if ( BotClasses[ BotID ] == none )
      BotClasses[ BotID ] = class<XIIIPlayerPawn>(DynamicLoadObject(BotClassesName[ BotID ], class'class'));


    Bot.PawnClass = BotClasses[ BotID ];
    Bot.PlayerReplicationInfo.PlayerID = CurrentID++;
    Bot.bIsBot = true;

    Bot.TeamID = Level.BotTeam[BotID];
    Bot.Skill = level.BotLevel[BotID];

    Bot.GRI = GameReplicationInfo;
    ChangeTeam(Bot,Level.BotTeam[BotID]);
}

//_____________________________________________________________________________
function PostBeginPlay()
{
    local XIIIMPFlag F;

    Super.PostBeginPlay();

    // associate flags with teams
    ForEach AllActors(Class'XIIIMPFlag',F)
    {
      F.Team = GameReplicationInfo.Teams[F.TeamNum];
      F.Team.Flag = F;
    }
}

//_____________________________________________________________________________
function Logout(Controller Exiting)
{
    if ( Exiting.PlayerReplicationInfo.HasFlag != None )
      XIIIMPFlag(Exiting.PlayerReplicationInfo.HasFlag).SendHome(1);
    Super.Logout(Exiting);
}

//_____________________________________________________________________________
function StartMatch()
{
    local XIIIMPFlag F;

    ForEach AllActors(Class'XIIIMPFlag',F)
    {
      log("MP-] STARTMATCH, sending flag home "$F);
      F.SendHome(-1);
    }
    Super.StartMatch();
}


//_____________________________________________________________________________
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    local XIIIMPFlag BestFlag;
    local Controller P;
    local PlayerController Player;
    local XIIIGameReplicationInfo TGRI;

    if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
      return false;

    // check for tie
    if ( Winner != none )
      for ( P=Level.ControllerList; P!=None; P=P.nextController )
        if ( P.bIsPlayer && (Winner.Team != P.PlayerReplicationInfo.Team) && (P.PlayerReplicationInfo.Team.Score == Winner.Team.Score) )
        {
          BroadcastLocalizedMessage( GameMessageClass, 0 );
          return false;
        }

    EndTime = Level.TimeSeconds + 3.0;
    TGRI = XIIIGameReplicationInfo(GameReplicationInfo);
    SetGameEndMessage(TGRI, reason, winner);
    log( "MP-] Game ended at "$EndTime);

    GameReplicationInfo.Winner = Winner.Team;

    XIIIGameReplicationInfo(GameReplicationInfo).iGameState = 3;
    gotoState('MatchOver');

    for ( P=Level.ControllerList; P!=None; P=P.nextController )
    {
      P.GotoState('GameEnded');
      Player = PlayerController(P);
      if ( Player != None )
      {
        Player.ClientSetBehindView(true);
        Player.SetViewTarget(BestFlag.HomeBase);
        Player.ClientGameEnded();
      }
    }
    BestFlag.HomeBase.bHidden = false;
    BestFlag.bHidden = true;

    return true;
}

//_____________________________________________________________________________
function ScoreFlag(Controller Scorer, XIIIMPFlag theFlag)
{
    local Controller TeamMate;

    if ( Scorer.PlayerReplicationInfo.Team == theFlag.Team )
    {
      // scorer returned his flag
      if ( PlayerController(Scorer) != none )
        PlayerController(Scorer).PlayerStat.StatFlagsR ++;
      Scorer.PlayerReplicationInfo.Score += 3;
      if (Level.Game.StatLog != None)
        Level.Game.StatLog.LogSpecialEvent("flag_returned", Scorer.PlayerReplicationInfo.PlayerID, theFlag.Team.TeamIndex);
      BroadcastLocalizedMessage( class'XIIIMPCTFMessage', 1, Scorer.PlayerReplicationInfo, None, TheFlag );
      return;
    }

    if ( PlayerController(Scorer) != none )
      PlayerController(Scorer).PlayerStat.StatFlagsS ++;
    Scorer.PlayerReplicationInfo.Score += 5;
    Scorer.PlayerReplicationInfo.Team.Score += 1.0;

    if (Level.Game.StatLog != None)
      Level.Game.StatLog.LogSpecialEvent("flag_captured", Scorer.PlayerReplicationInfo.PlayerID, theFlag.Team.TeamIndex);

    BroadcastLocalizedMessage( class'XIIIMPCTFMessage', 0, Scorer.PlayerReplicationInfo, None, TheFlag );
    TriggerEvent(theFlag.HomeBase.Event,theFlag.HomeBase, Scorer.Pawn);

    CheckScore(Scorer.PlayerReplicationInfo);
}


//_____________________________________________________________________________
function ScoreKill(Controller Killer, Controller Other)
{
    if (killer == Other)
    { // Suicide or killed by something and not someone
      if ( PlayerController(Other) != none )
        PlayerController(Other).PlayerStat.StatSuicides ++;
      Other.PlayerReplicationInfo.Score -= 1;
      //Other.PlayerReplicationInfo.Team.Score -= 1;
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
function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
    local XIIIMPFlag F;

    Super.Killed(Killer, Killed, KilledPawn, damageType);
    if ( Killed.PlayerReplicationInfo.HasFlag != None )
          Killed.PlayerReplicationInfo.HasFlag = none;

//          XIIIMPFlag(Killed.PlayerReplicationInfo.HasFlag).SendHome();
}



defaultproperties
{
     ScoreBoardType="XIIIMP.XIIIMPCTFScoreBoard"
     HUDType="XIIIMP.XIIICTFHUD"
     MapPrefix="CTF"
     GameName="Capture The Flag"
     MutatorClass="XIIIMP.XIIIMPCTFMutator"
}
