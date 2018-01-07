//-----------------------------------------------------------
// XIIITeamGameInfo || For Team DeathMatch GamePlay
//-----------------------------------------------------------
class XIIIMPTeamGameInfo extends XIIIMPGameInfo;

var localized string TeamName[2];

//_____________________________________________________________________________
function AddBot(int BotID)
{
    local TeamBotController Bot;

    Bot = spawn( class'TeamBotController');

    if ( BotClasses[ BotID ] == none )
      BotClasses[ BotID ] = class<XIIIPlayerPawn>(DynamicLoadObject(BotClassesName[ BotID ], class'class'));


    Bot.PawnClass = BotClasses[ BotID ];
    Bot.PlayerReplicationInfo.PlayerID = CurrentID++;
    Bot.bIsBot = true;

    log(bot@"level"@level.BotLevel[BotID]@"--> Team"@Level.BotTeam[BotID]);

    Bot.TeamID = Level.BotTeam[BotID];
    Bot.Skill = level.BotLevel[BotID];

    Bot.GRI = GameReplicationInfo;
    ChangeTeam(Bot,Level.BotTeam[BotID]);
}

//_____________________________________________________________________________

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
    if( Other.PlayerReplicationInfo.Team.TeamIndex == 1 )
    {
        if ( (Killer == Other) || (Killer == None) )
          BroadcastLocalizedMessage(DeathMessageClass, 1, None, Other.PlayerReplicationInfo, damageType);
        else
          BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType);
    }
    else
    {
        if ( (Killer == Other) || (Killer == None) )
          BroadcastLocalizedMessage(class'XIIIMP.XIIIMPRedDeathMessage', 1, None, Other.PlayerReplicationInfo, damageType);
        else
          BroadcastLocalizedMessage(class'XIIIMP.XIIIMPRedDeathMessage', 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType);
    }
}

//_____________________________________________________________________________

function StartMatch()
{
    super.StartMatch();

    Level.Game.GameReplicationInfo.Teams[0].score = 5;
    Level.Game.GameReplicationInfo.Teams[1].score = 10;
}

//_____________________________________________________________________________
function PostBeginPlay()
{
    local int i;

    for (i=0; i<2; i++)
    {
      if (Level.Game.GameReplicationInfo.Teams[i] == none )
        Level.Game.GameReplicationInfo.Teams[i] = spawn(class'Teaminfo');
      Level.Game.GameReplicationInfo.Teams[i].TeamName=TeamName[i];
      Level.Game.GameReplicationInfo.Teams[i].TeamIndex=i;
    }
}

//_____________________________________________________________________________
function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
    local int OriginalDamage;
//    local armor FirstArmor;
    local inventory I;
    local int ArmorDamage;

    OriginalDamage = Damage;

    if (
      (Injured.Controller.PlayerReplicationInfo.Team == instigatedBy.Controller.PlayerReplicationInfo.Team)
      && (Injured != InstigatedBy) )
      Damage *= fFriendlyFireScale;

    if( injured.PhysicsVolume.bNeutralZone )
      Damage = 0;
    else if ( injured.InGodMode() ) // God mode
      Damage = 0;
    else if ( (injured.Inventory != None) && (damage > 0) && DamageType.default.bArmorStops ) //then check if carrying armor
    {
      if ( Injured.Vest != none )
        Damage = Injured.Vest.ArmorAbsorbDamage(Damage, DamageType, HitLocation);
      if ( Injured.Helm != none )
        Damage = Injured.Helm.ArmorAbsorbDamage(Damage, DamageType, HitLocation);
    }

    if ( GameRulesModifiers != None )
      return GameRulesModifiers.NetDamage( OriginalDamage, Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );

    return Damage;
}

//_____________________________________________________________________________
// Return a picked team number if none was specified
function byte PickTeam(byte Current)
{
    if (Current > 1)
      return (NumPlayers % 2);
}

//_____________________________________________________________________________
// Return whether a team change is allowed.
function bool ChangeTeam(Controller Other, int N)
{
    Log("MP-] ChangeTeam call for"@other@"to be in team"@N);
    return Level.Game.GameReplicationInfo.Teams[N].AddToTeam(Other);
}

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
        Killer.PlayerReplicationInfo.Team.Score += 1;
        XIIIPlayerReplicationInfo(killer.PlayerReplicationInfo).MyDeathScore += 1;
      }
      else
      {
        if ( PlayerController(Killer) != none)
          PlayerController(killer).PlayerStat.StatKills --;
        killer.PlayerReplicationInfo.Score -= 1;
        Killer.PlayerReplicationInfo.Team.Score -= 1;
      }
    }

    if ( GameRulesModifiers != None )
      GameRulesModifiers.ScoreKill(Killer, Other);

    CheckScore(Killer.PlayerReplicationInfo);
}

//_____________________________________________________________________________
//
function CheckScore(PlayerReplicationInfo Scorer)
{
    if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
      return;

    if ( (Scorer != None)
      && (bOverTime || (GameReplicationInfo.GoalScore > 0))
      && (Scorer.Team.Score >= GameReplicationInfo.GoalScore) )
      {
          PlayMenu(hFragLimit);
          EndGame(Scorer,"FragLimit");
      }

    if ( (Scorer != None)
      && (bOverTime || (GameReplicationInfo.GoalScore > 0))
      && (Scorer.Team.Score == GameReplicationInfo.GoalScore-1) )
      PlayMenu(hLastFragLimit);
}

//_____________________________________________________________________________
//
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
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
//    GameReplicationInfo.bStopCountDown = true;

    XIIIGameReplicationInfo(GameReplicationInfo).iGameState = 3;
    gotoState('MatchOver');

    for ( P=Level.ControllerList; P!=None; P=P.nextController )
    {
      P.GotoState('GameEnded');
      Player = PlayerController(P);
      if ( Player != None )
      {
        //PlayWinMessage(Player, (Player.PlayerReplicationInfo == Winner));
        Player.ClientSetBehindView(true);
        if ( (Controller(Winner.Owner).Pawn != None) && !XIIIPawn(Controller(Winner.Owner).Pawn).IsDead() )
          Player.SetViewTarget(Controller(Winner.Owner).Pawn);
        Player.ClientGameEnded();
      }
    }
    return true;
}

//_____________________________________________________________________________
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
    local NavigationPoint N, BestStart;
    local Teleporter Tel;
    local float BestRating, NewRating;
    local byte Team;

//    Log("XIIIMPTeamGameInfo FindPlayerStart for"@Player@"InTeam"@InTeam);
    // always pick StartSpot at start of match
    if( Level.bLonePlayer == true )
    {
        if ( (Player != None) && (Player.StartSpot != None)
        && (bWaitingToStartMatch || ((Player.PlayerReplicationInfo != None) && Player.PlayerReplicationInfo.bWaitingPlayer))  )
        {
            return Player.StartSpot;
        }
    }

    if ( GameRulesModifiers != None )
    {
      N = GameRulesModifiers.FindPlayerStart(Player,InTeam,incomingName);
      if ( N != None )
        return N;
    }

    // if incoming start is specified, then just use it
    if( incomingName!="" )
      foreach AllActors( class 'Teleporter', Tel )
        if( string(Tel.Tag)~=incomingName )
          return Tel;

    // use InTeam if player doesn't have a team yet
    if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
    {
      if ( Player.PlayerReplicationInfo.Team != None )
        Team = Player.PlayerReplicationInfo.Team.TeamIndex;
      else
        Team = 0;
    }
    else
      Team = InTeam;

    BestRating = 0;
    for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
    {
      NewRating = RatePlayerStart(N,InTeam,Player);
      if ( NewRating > BestRating )
      {
        BestRating = NewRating;
        BestStart = N;
      }
    }

    if ( BestStart == None )
    {
      log("Warning - PATHS NOT DEFINED or NO PLAYERSTART");
      foreach AllActors( class 'NavigationPoint', N )
      {
        NewRating = RatePlayerStart(N,InTeam,Player);
        if ( NewRating > BestRating )
        {
          BestRating = NewRating;
          BestStart = N;
        }
      }
    }

    return BestStart;
}

//_____________________________________________________________________________
// ELR re-written from UW
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local PlayerStart P;
    local int Rate;

    P = PlayerStart(N);
    if ( P == None )
      return 0;

    if (Team != P.TeamNumber)
      Rate = 1;
    else
      Rate = Super.RatePlayerStart(N,Team,Player);
//    Log("Rating PlayerStart"@P@"(Team"@P.TeamNumber@") for"@Player@"Team"@Team@"Rate="$Rate);
    return Rate;
}



defaultproperties
{
     TeamName(0)="The Red ones"
     TeamName(1)="The Blue ones"
     bTeamGame=True
     ScoreBoardType="XIIIMP.XIIIMPTeamScoreBoard"
     HUDType="XIIIMP.XIIITeamHUD"
     GameName="Team DeathMatch"
     DeathMessageClass=Class'XIIIMP.XIIIMPBlueDeathMessage'
     MutatorClass="XIIIMP.XIIIMPTeamMutator"
}
