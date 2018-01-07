//-----------------------------------------------------------
// XIIIMJGameInfo || For DeathMatch GamePlay
//-----------------------------------------------------------
class XIIIMPGameInfo extends XIIIGameInfo;

var float fFriendlyFireScale;
var int WinningScore;          // Maximum Score of a game
var float MaxTime;             // Maximum duration of a game
var int RemainingTime;                // Time remaining before Game End
var float Endtime;
var localized string PreGameEndMessageWinner,PostGameEndMessageWinner;
var localized string PreGameEndMessageTimeOut,PostGameEndMessageTimeOut;

var NavigationPoint LastPlayerStartSpot;  // last place player looking for start spot started from
var NavigationPoint LastStartSpot;        // last place any player started from

var string EndGameMessage;            // To display message when game ended

var class<XIIIPlayerPawn> PawnClasses[16]; // E3 CHEAT
var string PawnClassesName[16];             // dynamic load of pawn classes
var class<XIIIPlayerPawn> BotClasses[8];
var string BotClassesName[8];             // dynamic load of bot classes

var Pawn Cadavre1, Cadavre2;          // To limit up to 2 corpses max on ground in multiplayer
var int BotNumber;
var string strBotLevel[4];

var int Mnu_BotLevel[8];
var int Mnu_BotTeam[8];
var int Mnu_BotNumber;

var string strSpeudo[28];
var int SpeudoUsed[28];
var XboxLiveManager xboxlive;
var String xboxliveName;
var sound hLastMinute, hTimeLimit,hLastFragLimit, hFragLimit;

var bool bNeedToKeepGSPosted;
var string ServerName, MapName;
VAR localized string AltGameName;
VAR int GameTypeIndex, MapIndex;
var int RestartTimeOut;

event string GetBeaconText()
{
	if ( Level.GetPlateforme()==0 )
	{ // PC
		return
			ServerName
			$"|"$ MapName
			$"|"$ GameTypeIndex
			$"|"$ BeaconName
			$"|"$ NumPlayers $"/"$ MaxPlayers;
	}
	else
	{ // X-Box and al.
		return
			ServerName
			$"|"$ MapIndex
			$"|"$ GameTypeIndex
			$"|"$ BeaconName
			$"|"$ NumPlayers $"/"$ MaxPlayers;
	}
}

//_____________________________________________________________________________
function AddBot(int BotID)
{
    local BotController Bot;

    Bot = spawn( class'BotController');

    if ( BotClasses[ BotID ] == none )
      BotClasses[ BotID ] = class<XIIIPlayerPawn>(DynamicLoadObject(BotClassesName[ BotID ], class'class'));


    Bot.PawnClass = BotClasses[ BotID ];
    Bot.PlayerReplicationInfo.PlayerID = CurrentID++;
    Bot.bIsBot = true;
    Bot.TeamID = Level.BotTeam[BotID];
    Bot.Skill = level.BotLevel[BotID];
    Bot.GRI = GameReplicationInfo;
}

//_____________________________________________________________________________
// Called BEFORE PreBeginPlay.
event InitGame( string Options, out string Error )
{
    Super.InitGame(Options, Error);

    ServerName = ParseOption ( Options, "SN" );
    if ( ServerName=="")
      ServerName="InternetServer";
    MaxPlayers = GetIntOption( Options, "NP", 2 );
    fFriendlyFireScale = GetIntOption( Options, "FF", 0 );
    MaxTime = GetIntOption( Options, "TI", 0 ) * 60;
    WinningScore  = GetIntOption( Options, "FR", 0 );
    GameTypeIndex = GetIntOption( Options, "GameIdx", 0 );
    MapIndex = GetIntOption( Options, "MapIdx", 0 );
    MapName = ParseOption( Options, "MapName" );

    if ( ParseOption ( Options, "Mutator" )!="" )
      GameName = AltGameName;

    Log(" MaxPlayers:"$MaxPlayers);
    Log(" fFriendlyFireScale:"$fFriendlyFireScale);
    Log(" MaxTime:"$MaxTime);
    Log(" WinningScore:"$WinningScore);

    if ( !Level.bLonePlayer )
    {
      if ( GameRulesModifiers == None )
        GameRulesModifiers = Spawn(class'XIIIMP.XIIIMPGameRules');
      else
        GameRulesModifiers.AddGameRules(Spawn(class'XIIIMP.XIIIMPGameRules'));
    }
}

//_____________________________________________________________________________
event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(1.0, true);
}

//_____________________________________________________________________________
function SetLonePlayer()
{
    Level.bLonePlayer=false;
}

//_____________________________________________________________________________
function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();
    Log("InitGameReplicationInfo:"$GameReplicationInfo);

    GameReplicationInfo.GoalScore = WinningScore;
    GameReplicationInfo.TimeLimit = MaxTime;
    GameReplicationInfo.bStopCountDown = true;
    XIIIGameReplicationInfo(GameReplicationInfo).iGameState = 1;
}

//_____________________________________________________________________________
event PreLogin(string Options, string Address, out string Error, out string FailCode)
{
  local string IP, gamertag;

  Super.Prelogin(Options, Address, Error, FailCode);

  gamertag = ParseOption ( Options, "GAMERTAG" );

  if ( Level.GetPlateForme() == 2 )
  {
    if (xboxlive == none)
      xboxlive=New Class'XboxLiveManager';
    gamertag = xboxlive.UnconvertString(gamertag);
    if (xboxlive.IsLoggedIn(xboxlive.GetCurrentUser()))
    { // Running on Xbox live
      IP = Address;
      if (IP != "")
      { // Client
        Log("Xbox Live IP: "$IP);
        if (!xboxlive.VerifyIPLoggedIn(gamertag, IP))
        {
          Error = GameMessageClass.Default.MaxedOutMessage; // Temp error
          return;
        }
        //xboxliveName = gamertag;//xboxlive.GetGamerTag(IP);
      }
      else
      { // Server
        Log("Xbox Live IP: <LOCALHOST>");
        //xboxliveName = xboxlive.GetCurrentUser();
      }
    }
  }
}

//_____________________________________________________________________________
//
// Log a player in.
// Fails login if you set the Error string.
// PreLogin is called before Login, but significant game time may pass before
// Login is called, especially if content is downloaded.
//
event PlayerController Login ( string Portal, string Options, out string Error )
{
    local NavigationPoint StartSpot;
    local PlayerController NewPlayer;
    local class<Pawn> DesiredPawnClass;
    local Pawn TestPawn;
    local string InName, InPassword, InChecksum, InClass;
    local byte InTeam;
    local bool bSpectator;
    local int i;
    local Actor A;
    local int BotBumber, Loop;
    local int BotLevel[8];
    local int BotTeam[8];
    local int SkinID;
    local int PlayerTeam[4];
    local int PlayerSkin[4];
    local string InSkinName;
    local MatchMakingManager myMMManager;


//    log("");
//    log("_________________________________");
//    log("Parameters");

    bSpectator = ( ParseOption( Options, "SpectatorOnly" ) != "" );
    InName = "";

    // Make sure there is capacity. (This might have changed since the PreLogin call).
    if ( AtCapacity(bSpectator) )
    {
      Error=GameMessageClass.Default.MaxedOutMessage;
      return None;
    }

    BaseMutator.ModifyLogin(Portal, Options);

    // Get URL options.
    PlayerSkin[0]  = GetIntOption( Options, "PC0", 0 );
    PlayerSkin[1]  = GetIntOption( Options, "PC1", 1 );
    PlayerSkin[2]  = GetIntOption( Options, "PC2", 2 );
    PlayerSkin[3]  = GetIntOption( Options, "PC3", 3 );

    PlayerTeam[0]  = GetIntOption( Options, "PT0", 0 );
    PlayerTeam[1]  = GetIntOption( Options, "PT1", 1 );
    PlayerTeam[2]  = GetIntOption( Options, "PT2", 0 );
    PlayerTeam[3]  = GetIntOption( Options, "PT3", 1 );

    if (ParseOption ( Options, "GS" ) != "")
    {
        bNeedToKeepGSPosted = true;
        myMMManager = new(none) class'MatchMakingManager';
        myMMManager.IStartMatch();       // in fact, the server joins its own room...
    }

    if ( Level.NetMode == NM_StandAlone )
      InTeam = PlayerTeam[NumPlayers];
    else
      InTeam = GetIntOption( Options, "Team", 255 ); // default to "no team"

    InPassword = ParseOption ( Options, "Password" );
    InChecksum = ParseOption ( Options, "Checksum" );

    BotBumber  = GetIntOption( Options, "Nbots", Level.BotNumber );

    BotLevel[0]  = GetIntOption( Options, "Nb0", Level.BotLevel[0] );
    BotLevel[1]  = GetIntOption( Options, "Nb1", Level.BotLevel[1] );
    BotLevel[2]  = GetIntOption( Options, "Nb2", Level.BotLevel[2] );
    BotLevel[3]  = GetIntOption( Options, "Nb3", Level.BotLevel[3] );
    BotLevel[4]  = GetIntOption( Options, "Nb4", Level.BotLevel[4] );
    BotLevel[5]  = GetIntOption( Options, "Nb5", Level.BotLevel[5] );
    BotLevel[6]  = GetIntOption( Options, "Nb6", Level.BotLevel[6] );

    BotTeam[0]  = GetIntOption( Options, "Tb0", Level.BotTeam[0] );
    BotTeam[1]  = GetIntOption( Options, "Tb1", Level.BotTeam[1] );
    BotTeam[2]  = GetIntOption( Options, "Tb2", Level.BotTeam[2] );
    BotTeam[3]  = GetIntOption( Options, "Tb3", Level.BotTeam[3] );
    BotTeam[4]  = GetIntOption( Options, "Tb4", Level.BotTeam[4] );
    BotTeam[5]  = GetIntOption( Options, "Tb5", Level.BotTeam[5] );
    BotTeam[6]  = GetIntOption( Options, "Tb6", Level.BotTeam[6] );

//    GameReplicationInfo.GoalScore = WinningScore;
//    GameReplicationInfo.TimeLimit = MaxTime;

    Level.BotNumber = BotBumber;

    for( Loop = 0; Loop < 7 ; Loop++ )
    {
        Level.BotLevel[Loop] = BotLevel[Loop];
        Level.BotTeam[Loop] = BotTeam[Loop];
    }

    log("_________________________________");
    log( "Login LevelNetMode ="@Level.NetMode);

    log( " Login:" @ InName );
    if( InPassword != "" )
      log( " Password"@InPassword );

    // Pick a team (if need teams)
    InTeam = PickTeam(InTeam);
    log( " InTeam:" @ InTeam );

    // Find a start spot.
    StartSpot = FindPlayerStart( None, InTeam, Portal );

    if( StartSpot == none )
    {
      Error = GameMessageClass.Default.FailedPlaceMessage;
      return None;
    }

    // Init player's administrative privileges
    if ( AccessControl.AdminLogin(NewPlayer, InPassword) )
    {
      NewPlayer = spawn(AccessControl.AdminClass,,,StartSpot.Location,StartSpot.Rotation);
//      bSpectator = true; // Leave admin being player for console on-line
    }
    else
    {
      if ( PlayerControllerClass == None )
        PlayerControllerClass = class<PlayerController>(DynamicLoadObject(PlayerControllerClassName, class'Class'));
      NewPlayer = spawn(PlayerControllerClass,,,StartSpot.Location,StartSpot.Rotation);
    }

    // Handle spawn failure.
    if( NewPlayer == None )
    {
      log("Couldn't spawn player controller of class "$PlayerControllerClass);
      Error = GameMessageClass.Default.FailedSpawnMessage;
      return None;
    }

    NewPlayer.StartSpot = StartSpot;

    // Init player's replication info
    NewPlayer.GameReplicationInfo = GameReplicationInfo;
    NewPlayer.PlayerStat = Spawn(class'PlayerStats', NewPlayer);
    NewPlayer.PlayerStat.EnterTimeSeconds = Level.TimeSeconds;

    NewPlayer.GotoState('Spectating');

    if ( bSpectator )
    {
      NewPlayer.bOnlySpectator = true;
      NumSpectators++;
      return NewPlayer;
    }

    // Change player's team.
    if ( !ChangeTeam(newPlayer, InTeam) )
    {
      Error = GameMessageClass.Default.FailedTeamMessage;
      return None;
    }

    // Set the player's ID.
    NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

    // Set Player Class
    if ( Level.NetMode == NM_StandAlone )
    { // Solo/Split game
      if( IsA('XIIIMPBombGame') ) // OD:Prise en compte de l'URL pour le choix des classes en Sabotage OffLine
      {
          PlayerSkin[NumPlayers] = PlayerSkin[NumPlayers] % class'MPClassList'.default.ClassListInfo.Length;
          InClass = class'MPClassList'.default.ClassListInfo[PlayerSkin[NumPlayers]].ClassName;
          DefaultPlayerName = class'MPClassList'.default.ClassListInfo[PlayerSkin[0]].ReadableName;
          DesiredPawnClass = class<Pawn>(DynamicLoadObject(InClass, class'Class'));
      }
      else
      {
          InClass = class'MPClassList'.default.ClassListInfo[NumPlayers].ClassName;
          DefaultPlayerName = class'MPClassList'.default.ClassListInfo[NumPlayers].ReadableName;
          DesiredPawnClass = class<Pawn>(DynamicLoadObject(InClass, class'Class'));
      }
    }
    else
    { // On-line game, get Class in
      PlayerSkin[0] = PlayerSkin[0] % class'MPClassList'.default.ClassListInfo.Length;
      InClass = class'MPClassList'.default.ClassListInfo[PlayerSkin[0]].ClassName;
      DefaultPlayerName = class'MPClassList'.default.ClassListInfo[PlayerSkin[0]].ReadableName;
      DesiredPawnClass = class<Pawn>(DynamicLoadObject(InClass, class'Class'));
    }
    if ( DesiredPawnClass != None )
      NewPlayer.PawnClass = DesiredPawnClass;
    log( " Class:" @ NewPlayer.PawnClass );

    if ( Level.NetMode != NM_StandAlone )
    {
      InSkinName = caps(ParseOption ( Options, "SK" ));
      if ( InSkinName != "" )
      {
        Log(" Skin:" @ InSkinName);
        NewPlayer.PlayerReplicationInfo.SkinCodeName = InSkinName;
      }
    }

/* // reminder of skin usage
    NbSkins = class'SkinList'.default.SkinListInfo.Length;
    Log("STATIC SkinList NbSkins="$NbSkins);
    if ( NbSkins > 0 )
    {
      for (i=0; i<NbSkins; i++)
        Log("  "$i$" - "$class'SkinList'.default.SkinListInfo[i].SkinReadableName@"("$class'SkinList'.default.SkinListInfo[i].SkinClassName$")");
    }
*/
    // Init player's name
    if( Level.NetMode == NM_Standalone )
    { // solo /splitt game
      InName = NewPlayer.PawnClass.Default.PawnName;
    }
    else
    {
      InName = ParseOption ( Options, "GAMERTAG" );
      if (xboxlive == none)
        xboxlive=New Class'XboxLiveManager';
      InName = xboxlive.UnconvertString(InName);
      if (InName=="")
  	    InName = Left(ParseOption ( Options, "Name"), 20);
      if (InName=="")
  	    InName = NewPlayer.PawnClass.Default.PawnName;
    }
    if( InName == "" )
      InName = DefaultPlayerName;

//    if( (Level.NetMode = NM_Standalone) || (NewPlayer.PlayerReplicationInfo.PlayerName == DefaultPlayerName) )
    if( !Level.bLonePlayer || (NewPlayer.PlayerReplicationInfo.PlayerName == DefaultPlayerName) )
      ChangeName( NewPlayer, InName, false );
//    ChangeName(NewPlayer, NewPlayer.PlayerReplicationInfo.PlayerName, false);
    log( " Name:" @ NewPlayer.PlayerReplicationInfo.PlayerName );

    // Log it.
    if ( StatLog != None )
      StatLog.LogPlayerConnect(NewPlayer);
    NewPlayer.ReceivedSecretChecksum = !(InChecksum ~= "NoChecksum");

    NumPlayers++;

    // if delayed start, don't give a pawn to the player yet
    // Normal for multiplayer games
//    if ( bDelayedStart )
    if ( bDelayedStart && !(XIIIGameReplicationInfo(GameReplicationInfo).iGameState == 2) )
    {
      NewPlayer.GotoState('PlayerWaiting');
      return NewPlayer;
    }

    // Try to match up to existing unoccupied player in level,
    // for savegames and coop level switching.
    ForEach DynamicActors(class'Pawn', TestPawn )
    {
      if ( (TestPawn!=None) && (PlayerController(TestPawn.Controller)!=None) && (PlayerController(TestPawn.Controller).Player==None) && (TestPawn.Health > 0)
        &&  (TestPawn.PawnName~=InName) )
      {
        TestPawn.Controller.Destroy();
        NewPlayer.Possess(TestPawn);
        return NewPlayer;
      }
    }

    // start match, or let player enter, immediately
    bRestartLevel = false;     // let player spawn once in levels that must be restarted after every death
    if ( bWaitingToStartMatch )
      StartMatch();
    bRestartLevel = Default.bRestartLevel;

    return newPlayer;
}

//_____________________________________________________________________________
// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerPawn.
event PostLogin( PlayerController NewPlayer )
{
    local Controller P;
    local class<Scoreboard> S;
    local class<HUD> H;

    // tell client what hud and scoreboard to use
    H = class<HUD>(DynamicLoadObject(HUDType, class'Class'));
    S = class<Scoreboard>(DynamicLoadObject(ScoreboardType, class'Class'));
    NewPlayer.ClientSetHUD(H,S);

    // Replicate skins - to avoid loading pauses in multiplayer games
//    if ( Level.NetMode != NM_Standalone )
/*
    if ( !Level.bLonePlayer )
    {
      for ( P=Level.ControllerList; P!=None; P=P.NextController )
        if ( P != NewPlayer )
        {
          // send other players' skins to new player
          if ( P.Pawn != None )
          {
               NewPlayer.ClientReplicateSkins(P.Pawn.Skins[0], P.Pawn.Skins[1], P.Pawn.Skins[2], P.Pawn.Skins[3]);
          }

          // send new player's skins to any player which hasn't started play yet
          if ( (NewPlayer.Pawn != None)
               && (P.PlayerReplicationInfo != None)
               && P.PlayerReplicationInfo.bWaitingPlayer
               && (PlayerController(P) != None) )
          {
               PlayerController(P).ClientReplicateSkins(NewPlayer.Skins[0], NewPlayer.Skins[1], NewPlayer.Skins[2], NewPlayer.Skins[3]);
          }
        }
    }
*/

    if ( NewPlayer.Pawn != None )
      NewPlayer.Pawn.ClientSetRotation(NewPlayer.Pawn.Rotation);

    if ( !bWaitingToStartMatch )
      RestartPlayer(newPlayer);

    // if we are a server, broadcast a welcome message.
    // ELR message may be received before name is replicated ??
    if( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
    {
      Log("MP-] Sending Welcome message for"@NewPlayer@"("$NewPlayer.PlayerReplicationInfo.PlayerName$")");
//      BroadcastLocalizedMessage(GameMessageClass, 1, NewPlayer.PlayerReplicationInfo);
//      Broadcast(self, class'XIIIMultiMessage'.static.GetString(1,NewPlayer.PlayerReplicationInfo), 'PlayerEnter');
      Broadcast(self, NewPlayer.PlayerReplicationInfo.PlayerName, 'PlayerEnter');
    }
}

//_____________________________________________________________________________
function Logout(Controller Exiting)
{
    local bool bMessage;

    Log("LOGOUT"@exiting);

    bMessage = true;
    if ( PlayerController(Exiting) != None )
    {
      if ( PlayerController(Exiting).bOnlySpectator )
      {
        bMessage = false;
        if ( Level.NetMode == NM_DedicatedServer )
          NumSpectators--;
      }
      else
        NumPlayers--;
    }
    if( !Exiting.bTearOff && bMessage && (Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer) )
//      Broadcast(self, class'XIIIMultiMessage'.static.GetString(4,Exiting.PlayerReplicationInfo), 'PlayerEnter');
      BroadcastLocalizedMessage(GameMessageClass, 4, Exiting.PlayerReplicationInfo);

    if ( StatLog != None )
      StatLog.LogPlayerDisconnect(Exiting);
    if ( (PlayerController(Exiting) != none) && PlayerController(Exiting).PlayerStat != none )
    {
//      PlayerController(Exiting).PlayerStat.LeaveTimeSeconds = Level.TimeSeconds;
//      PlayerController(Exiting).PlayerStat.LogStats();
      PlayerController(Exiting).PlayerStat.Destroy();
    }
}

//_____________________________________________________________________________
function ChangeName( Controller Other, coerce string S, bool bNameChange )
{
    Local Controller C;

    if ( (S == "") || (S == Other.PlayerReplicationInfo.PlayerName) )
      return;

    // Check for same names, add "+" if same name until name different.
		for( C=Level.ControllerList; C!=None; C=C.nextController )
		{
      if ( (C != Other) && (C.PlayerReplicationInfo.PlayerName ~= S) )
      {
        S = S$"+";
        C = Level.ControllerList;
      }
    }

    if ( StatLog != None)
      StatLog.LogNameChange(Other);

    Other.PlayerReplicationInfo.SetPlayerName(S);
    if ( bNameChange && (PlayerController(Other) != None) )
      BroadcastLocalizedMessage( GameMessageClass, 2, Other.PlayerReplicationInfo );
}

//_____________________________________________________________________________
// Restart a player.
function RestartPlayer( Controller aPlayer )
{
    local NavigationPoint startSpot;
    local bool foundStart;
    local int TeamNum,i;
    local class<Pawn> defaultPlayerClass;
    local Pawn P;

    Log("MP-] RestartPlayer call for "$aPlayer);

    if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
      return;

    if ( (aPlayer.PlayerReplicationInfo == None) || (aPlayer.PlayerReplicationInfo.Team == None) )
      TeamNum = 255;
    else
      TeamNum = aPlayer.PlayerReplicationInfo.Team.TeamIndex;

    startSpot = FindPlayerStart(aPlayer, TeamNum);

//    log(" > PlayerStart ="@startSpot);

    if( startSpot == none )
    {
      log("MP-] Player start not found for "$aplayer@"!!!");
      return;
    }

    if ( (aPlayer.PlayerReplicationInfo.Team != None)
      && ((aPlayer.PawnClass == None) || !aPlayer.PlayerReplicationInfo.Team.BelongsOnTeam(aPlayer.PawnClass)) )
           aPlayer.PawnClass = class<Pawn>(DynamicLoadObject(aPlayer.PlayerReplicationInfo.Team.DefaultPlayerClassName, class'Class'));

    // ELR Destroy it before reinitializing after (to be sure we have a fresh just-intialized pawn)
    if( aPlayer.Pawn!=None )
    {
      P = aPlayer.Pawn;
      aPlayer.PawnDied();
      P.Destroy();
    }

    if ( aPlayer.PawnClass != None )
      aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,StartSpot.Location,StartSpot.Rotation);

    if( aPlayer.Pawn == None )
    {
      DefaultPlayerClass = class<Pawn>(DynamicLoadObject(GetDefaultPlayerClassName(aPlayer), class'Class'));
      aPlayer.Pawn = Spawn(DefaultPlayerClass,,,StartSpot.Location,StartSpot.Rotation);
    }

    if ( aPlayer.Pawn == None )
    {
      log("Couldn't spawn player of type "$aPlayer.PawnClass$" at "$StartSpot);
      aPlayer.GotoState('Dead');
      return;
    }

    aPlayer.Possess(aPlayer.Pawn);
    aPlayer.PawnClass = aPlayer.Pawn.Class;
    XIIIMPPlayerPawn(aPlayer.Pawn).ClientChangeSkin( TeamNum );

    PlayTeleportEffect(aPlayer, true, true);
    aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
    AddDefaultInventory(aPlayer.Pawn);
    TriggerEvent( StartSpot.Event, StartSpot, aPlayer.Pawn);
}

//_____________________________________________________________________________
event AcceptInventory(pawn PlayerPawn)
{
    local inventory Inv, InvT;

    // In multiplayer accept nothing
    Inv = PlayerPawn.Inventory;
    while ( Inv != none )
    {
      InvT = Inv;
      Inv = Inv.Inventory;
      InvT.Destroy();
    }
}

//_____________________________________________________________________________
// Play a teleporting special effect.
function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
    if ( PlayerController(Incoming) != none )
      Spawn(class'SpawnEmitter',,, PlayerController(Incoming).Pawn.Location);
}

//_____________________________________________________________________________
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
        if ( P.bIsPlayer && (Winner != P.PlayerReplicationInfo) && (P.PlayerReplicationInfo.Score == Winner.Score) )
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
// ELR GameEnded in solo mode = GameOver
function EndGame( PlayerReplicationInfo Winner, string Reason )
{
    // don't end game if not really ready
    if ( !CheckEndGame(Winner, Reason) )
    {
      bOverTime = true;
      return;
    }

    bGameEnded = true;
    TriggerEvent('EndGame', self, None);
/*    if ( Reason=="PlayerKilled" )
      Level.Game.BroadCastLocalizedMessage(class'XIIIEndGameMessage', 1, winner);
    else if ( Reason=="GoalComplete" )
      Level.Game.BroadCastLocalizedMessage(class'XIIIEndGameMessage', 2, winner);
    else if ( Reason=="GoalIncomplete" )
      Level.Game.BroadCastLocalizedMessage(class'XIIIEndGameMessage', 3, winner); */
    EndLogging(Reason);
}

//_____________________________________________________________________________
function SetGameEndMessage(XIIIGameReplicationInfo TGRI, string reason, PlayerReplicationInfo winner)
{
    if ( caps(Reason)=="FRAGLIMIT" )
      TGRI.EndGameMessage = PreGameEndMessageWinner@Winner.playername@PostGameEndMessageWinner;
    else if ( caps(Reason)=="TIMELIMIT" )
      TGRI.EndGameMessage = PreGameEndMessageTimeOut@PostGameEndMessageTimeOut;
    else
      TGRI.EndGameMessage = "BUG EndGameMessage::"@reason@":: EndGameMessage BUG";
    log("#### GameEnded, TGRI.EndGameMessage == "$TGRI.EndGameMessage@"Level.Game="$Level.Game);
}

//_____________________________________________________________________________
function CheckScore(PlayerReplicationInfo Scorer)
{
//    log("--- ChechScore --- Goal="$GameReplicationInfo.GoalScore@"current="$Scorer.Score);
    if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
      return;

    //log(" > Ok test"@int(Scorer.Score)@"/"@GameReplicationInfo.GoalScore);

    if ( (Scorer != None)
     && (bOverTime || (GameReplicationInfo.GoalScore > 0))
     && (Scorer.Score >= GameReplicationInfo.GoalScore) )
    {
      PlayMenu(hFragLimit);
      EndGame(Scorer,"FragLimit");
    }

    if ( (Scorer != None)
      && (bOverTime || (GameReplicationInfo.GoalScore > 0))
      && (Scorer.Score == GameReplicationInfo.GoalScore - 1) )
    {
//      Log("MP-] Near FragLimit");
      PlayMenu(hLastFragLimit);
      BroadCastLocalizedMessage(class'XIIIMultiMessage',5,Scorer);
    }
}

//_____________________________________________________________________________
//
function ReStartMatch()
{
//    local actor A;
    local controller C;

//    ForEach AllActors(class'Actor', A)
//      A.Reset();
    Log("MP-] -- RESTART MATCH --, MaxTime="$MaxTime@"RemainingTime="$XIIIGameReplicationInfo(GameReplicationInfo).XIIIRemainingTime);
    for (C=Level.ControllerList; C!=None; C=C.NextController )
      RestartPlayer(C);

    StartMatch();
}

//_____________________________________________________________________________
function StartMatch()
{
    local Controller C;
    local BotController Bot;
    local int NumPlayer, Loop, Index1, Index2;
    local string BotName, strTmpSpeudo;
    local bool BotAlreadyExist;
    local Actor a;

    //DEBUGLOG( "Initialize Breakablemover " );
    foreach DynamicActors(class'actor',a)
    {
      if (a.IsA('BreakableMover'))
        a.Reset();
    }

    // ELR as we do not restart by reloading the map, need to initialize scores w/ each StartMatch.
    for (C=Level.ControllerList; C!=None; C=C.NextController )
    {
      if ( (PlayerController(C) != none) && (C.PlayerReplicationInfo != None) )
      {
        C.PlayerReplicationInfo.Score = 0;
        C.PlayerReplicationInfo.Deaths = 0;
        C.PlayerReplicationInfo.HasFlag = none;
        NumPlayer++;
      }

      if( BotController(C) != none )
          BotAlreadyExist = true;
    }

    if( Mnu_BotNumber != -1 )
    {
        Level.BotNumber = Mnu_BotNumber;

        for( Loop=0;Loop<8;Loop++)
        {
            Level.BotLevel[Loop] = Mnu_BotLevel[Loop];
            Level.BotTeam[Loop] = Mnu_BotTeam[Loop];
        }
    }

    BotNumber = Level.BotNumber;//  Max( 0,Level.IdealPlayerCount-NumPlayer);

    if( BotNumber > Level.IdealPlayerCount - NumPlayer )
    {
        BotNumber = Level.IdealPlayerCount - NumPlayer;
    }

    if( BotAlreadyExist )
        BotNumber = 0;

    if( ( ! Level.bLonePlayer ) && ( Level.NetMode == NM_StandAlone ) )
    {
        if( BotNumber > 0 )
        {
            for( Loop=0;Loop<BotNumber;Loop++)
                AddBot(Loop);
        }
    }

    GotoState('MatchInProgress');
    RemainingTime = MaxTime;
    XIIIGameReplicationInfo(GameReplicationInfo).XIIIRemainingTime = RemainingTime;
    XIIIGameReplicationInfo(GameReplicationInfo).iGameState = 2;
    Super.StartMatch();
    Log("MP-] -- START MATCH --, MaxTime="$MaxTime@"RemainingTime="$XIIIGameReplicationInfo(GameReplicationInfo).XIIIRemainingTime);
//    if ( Cadavre1 != none )
//      Cadavre1.destroy();
//    if ( Cadavre2 != none )
//      Cadavre2.destroy();


    // Init Bot

//    Loop=0;
//    for (C=Level.ControllerList; C!=None; C=C.NextController )
//    {
//      if ( (BotController(C) != none) && (C.bIsBot) )
//      {
//          BotController(C).Skill = level.BotLevel[Loop];
//          Loop++;
//      }
//    }

    for( Loop=0; Loop<28 ; Loop++ )
        SpeudoUsed[ Loop ] = 0;

    Loop=0;
    for (C=Level.ControllerList; C!=None; C=C.NextController )
    {
      if ( (BotController(C) != none) && (C.bIsBot) )
      {
           Index1 = Rand(7);

           for( Index2=0 ; Index2<7 ; Index2++ )
           {
               if( Index1 + Index2 == 7 )
                   Index1 -= 7;

               if( SpeudoUsed[ Index1 + Index2 + BotController(C).Skill*7 ] == 0 )
               {
                   SpeudoUsed[ Index1 + Index2 + BotController(C).Skill*7 ] = 1;
                   strTmpSpeudo = strSpeudo[ Index1 + Index2 + BotController(C).Skill*7 ];
                   break;
               }
           }

           BotName = strTmpSpeudo$" "$strBotLevel[BotController(C).Skill]$" ";

           BotController(C).Initialize( Loop , BotController(C).Skill , BotName );

           ChangeName( BotController(C), BotName, false );
           Loop++;

            C.PlayerReplicationInfo.Score = 0;
            C.PlayerReplicationInfo.Deaths = 0;
            C.PlayerReplicationInfo.HasFlag = none;
      }
      else if( XIIIMPDuckController(C)!= none )
      {
          if( XIIIMPDuckController(C).IsInState('GameEnded') )
              XIIIMPDuckController(C).Gotostate('ReInitWithTeleport');
      }
    }

}

//_____________________________________________________________________________
// ELR Copy from UW DeathMatch RatePlayerStart
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
     local NavigationPoint Best;

     if ( (Player != none) && (Player.StartSpot != None) )
          LastPlayerStartSpot = Player.StartSpot;

     Best = Super.FindPlayerStart(Player, InTeam, incomingName );
     if ( Best != None )
          LastStartSpot = Best;
     return Best;
}

//_____________________________________________________________________________
// ELR Copy from UW DeathMatch RatePlayerStart
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local PlayerStart P;
    local float Score, NextDist;
    local Controller OtherPlayer;

    P = PlayerStart(N);

    if ( (P == None) || !P.bEnabled || P.PhysicsVolume.bWaterVolume )
      return 1;

//    log("");
//    log("    > "@N);
//    log("    > LastStartSpot="@LastStartSpot);
//    log("    > LastPlayerStartSpot="@LastPlayerStartSpot);

    //assess candidate
    Score = 10000000;

//    if ( (N == LastStartSpot) || (N == LastPlayerStartSpot) )
    if ( N == LastStartSpot )
      Score -= 100000.0;
    else
      Score += 3000 * FRand(); //randomize

    for ( OtherPlayer=Level.ControllerList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextController)
    {
      if ( OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != None) )
      {
          //Score -= 1500;
          NextDist = VSize(OtherPlayer.Pawn.Location - N.Location);
          if ( NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight )
          {
//            log("    > Warning TeleFrag"@N);
            Score -= 1000000.0;
          }
//          else if ( (NextDist < 3000) && FastTrace(N.Location, OtherPlayer.Pawn.Location) )
//          {
//            log("    > Player in the zone"@N);
//            Score -= (10000.0 - NextDist);
//          }
      }
    }
    return Score;
}

//_____________________________________________________________________________
function PlayerReplicationInfo FindWinner()
{
    local PlayerReplicationInfo PRI, Winner;

    ForEach AllActors(class'PlayerReplicationInfo', PRI)
    {
      if (PRI!=none)
      {
        if ( Winner == none )
          PRI = Winner;
        else if ( PRI.Score > Winner.Score )
          PRI = Winner;
      }
    }
    return Winner;
}

//_____________________________________________________________________________
function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
    if ( Killer == none )
       return;

    if ( (Killer == Other) || (Killer == None) )
      BroadcastLocalizedMessage(DeathMessageClass, 1, None, Other.PlayerReplicationInfo, damageType);
    else
      BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType);
}

//_____________________________________________________________________________
function ScoreKill(Controller Killer, Controller Other)
{
    if (killer == Other)
    {
        if ( PlayerController(Other) != none )
          PlayerController(Other).PlayerStat.StatSuicides ++;
        Other.PlayerReplicationInfo.Score -= 1;
    }
    else if ( killer.PlayerReplicationInfo != None )
    {
        if ( PlayerController(Killer) != none)
          PlayerController(killer).PlayerStat.StatKills ++;
        if ( PlayerController(Other) != none)
          PlayerController(Other).PlayerStat.StatDeaths ++;
        killer.PlayerReplicationInfo.Score += 1;
        XIIIPlayerReplicationInfo(killer.PlayerReplicationInfo).MyDeathScore += 1;
    }

    if ( GameRulesModifiers != None )
        GameRulesModifiers.ScoreKill(Killer, Other);

    CheckScore(Killer.PlayerReplicationInfo);
}

//_____________________________________________________________________________
auto State PendingMatch
{
    event BeginState()
    { // ELR, Timing out the 'press fire to start', after (default) seconds, start anyway
      RestartTimeOut = default.RestartTimeOut;
    }

    event Timer()
    {
      local Controller P;
      local bool bReady;

      bReady = false;
      for (P = Level.ControllerList; P != None; P = P.NextController )
        if ( XIIIPlayerController(P) != none )
          bReady = true;
      if ( !bReady )
      {
//        log("MP-] "$self$" PendingMatch, No PlayerController logged");
        return; // ELR launch no game if no playercontroller connected (on dedicated serveur, wait for 1rst player to connect
      }

//      log("MP-] "$self$" PendingMatch, bWaitingToStartMatch="$bWaitingToStartMatch@"TimeOut="$RestartTimeOut);

      if ( Level.NetMode != NM_StandAlone )
        RestartTimeOut --; // ELR Only in on-line multiplayer, not offline

      if ( bWaitingToStartMatch )
      {
        bReady = true;
        if ( RestartTimeOut > 0 )
        {
          for (P=Level.ControllerList; P!=None; P=P.NextController )
          {
            if ( PlayerController(P)!=none && (P.PlayerReplicationInfo != None) )
            {
  //            Log("MP-] "$P@"bWaitingPlayer="$P.PlayerReplicationInfo.bWaitingPlayer@"bReadyToPlay="$P.PlayerReplicationInfo.bReadyToPlay);
              if (P.PlayerReplicationInfo.bWaitingPlayer && !P.PlayerReplicationInfo.bReadyToPlay )
                bReady = false;
            }
          }
        }

//        log("MP-] "$self$" bWaitingToStartMatch, ready="$bReady);
        if ( bReady )
        {
          log("_________________________________");
          log("StartMatch");
          StartMatch();
        }
/*        else
        {
          for (P=Level.ControllerList; P!=None; P=P.NextController )
            if ( XIIIPlayerController(P) != none )
              XIIIPlayerController(P).ReceiveLocalizedMessage(class'XIIIMultiMessage', 1, XIIIPlayerController(P).PlayerReplicationInfo);
        }
*/
      }
      else
      { // ELR Unused in XIII, we always wait to start match
//        StartMatch();
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
      Super.Timer();
//      log("MP-] "$"Match in Progress -- RemainingTime="@RemainingTime);
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
          EndGame(FindWinner(),"TimeLimit");
        }
        if ( RemainingTime == 60 )
        {
          PlayMenu(hLastMinute);
        }
      }
    }
}

//_____________________________________________________________________________
State MatchOver
{
    event BeginState()
    {
      local controller C;

      // Force stat update for each client
      for (C=Level.ControllerList; C!=None; C=C.NextController )
        if ( (PlayerController(C) != none) && (C.PlayerReplicationInfo != None) )
        {
          PlayerController(C).PlayerStat.Timer();
          PlayerController(C).PlayerStat.StatMatchesPlayed ++;
        }
    }

    event Timer()
    {
      local controller C;
      local Pawn P;

      Super.Timer();
//      log("MP-] "$"Match Over -- RemainingTime before next match="@(Level.TimeSeconds -(EndTime+2.0)));
      if ( Level.TimeSeconds > EndTime+4.0 )
      {
        bWaitingToStartMatch = true;
        for (C=Level.ControllerList; C!=None; C=C.NextController )
        {
          if ( (PlayerController(C) != none) && (C.PlayerReplicationInfo != None) )
          {
            P = C.Pawn;
//            PlayerController(C).UnPossess();
//            C.PawnDied();
            P.Controller = none; /* Thanx iKi else crash on-line */
            P.Destroy();
            C.GotoState('PlayerWaiting');
//            Log("Sent"@C@"in PlayerWaiting state");
            C.PlayerReplicationInfo.bReadyToPlay=false;
          }
        }
        XIIIGameReplicationInfo(GameReplicationInfo).iGameState = 1;
        GotoState('PendingMatch');
      }
    }
}



defaultproperties
{
     PreGameEndMessageWinner="Player "
     PostGameEndMessageWinner=" Wins the match"
     PreGameEndMessageTimeOut="Time Out"
     BotClassesName(0)="XIIIMP.Bot_GI"
     BotClassesName(1)="XIIIMP.Bot_Killer1"
     BotClassesName(2)="XIIIMP.Bot_Killer2"
     BotClassesName(3)="XIIIMP.Bot_XIII"
     BotClassesName(4)="XIIIMP.Bot_GI"
     BotClassesName(5)="XIIIMP.Bot_XIII"
     BotClassesName(6)="XIIIMP.Bot_Killer1"
     BotClassesName(7)="XIIIMP.Bot_Killer2"
     strBotLevel(0)="*"
     strBotLevel(1)="**"
     strBotLevel(2)="***"
     strBotLevel(3)="****"
     Mnu_BotNumber=-1
     strSpeudo(0)="Ender"
     strSpeudo(1)="Blade"
     strSpeudo(2)="Lunatic"
     strSpeudo(3)="Whiz"
     strSpeudo(4)="GroBeuh"
     strSpeudo(5)="Furax"
     strSpeudo(6)="Freddy"
     strSpeudo(7)="Cho"
     strSpeudo(8)="iKi"
     strSpeudo(9)="Sly"
     strSpeudo(10)="Rip"
     strSpeudo(11)="Rhill"
     strSpeudo(12)="Brutus"
     strSpeudo(13)="Douceur"
     strSpeudo(14)="Cray"
     strSpeudo(15)="Atlas"
     strSpeudo(16)="Oya-DM"
     strSpeudo(17)="Dr Spy"
     strSpeudo(18)="Baby"
     strSpeudo(19)="Tek C."
     strSpeudo(20)="Kyo"
     strSpeudo(21)="Draax"
     strSpeudo(22)="Solo"
     strSpeudo(23)="Rigolax"
     strSpeudo(24)="Matheo"
     strSpeudo(25)="Litst"
     strSpeudo(26)="Chandy"
     strSpeudo(27)="Gyb"
     hLastMinute=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hTime1Mn'
     hTimeLimit=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hTimeLimit'
     hLastFragLimit=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hFragLimit'
     hFragLimit=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hTimeLimit'
     AltGameName="Power Up"
     RestartTimeOut=30
     bDelayedStart=True
     DefaultPlayerClassName="XIIIMP.XIIIMPPlayerPawn"
     ScoreBoardType="XIIIMP.XIIIMPScoreBoard"
     HUDType="XIIIMP.XIIIMPHUD"
     MapPrefix="DM"
     GameName="DeathMatch"
     DeathMessageClass=Class'XIII.XIIIDeathMessage'
     GameMessageClass=Class'XIII.XIIIMultiMessage'
     MutatorClass="XIIIMP.XIIIMPMutator"
     AccessControlClass="XIIIMP.XIIIAccessControl"
     PlayerControllerClassName="XIIIMP.XIIIMPPlayerController"
     GameReplicationInfoClass=Class'XIII.XIIIGameReplicationInfo'
}
