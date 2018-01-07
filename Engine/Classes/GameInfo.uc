//=============================================================================
// GameInfo.
//
// The GameInfo defines the game being played: the game rules, scoring, what actors
// are allowed to exist in this game type, and who may enter the game.  While the
// GameInfo class is the public interface, much of this functionality is delegated
// to several classes to allow easy modification of specific game components.  These
// classes include GameInfo, AccessControl, Mutator, BroadcastHandler, and GameRules.
// A GameInfo actor is instantiated when the level is initialized for gameplay (in
// C++ UGameEngine::LoadMap() ).  The class of this GameInfo actor is determined by
// (in order) either the DefaultGameType if specified in the LevelInfo, or the
// DefaultGame entry in the game's .ini file (in the Engine.Engine section), unless
// its a network game in which case the DefaultServerGame entry is used.
//
//=============================================================================
class GameInfo extends Info
  config(user)
  native;

//____________________________________________________________________________
// Variables.
var globalconfig byte Difficulty; // 0=easy, 1=medium, 2=hard, 3=very hard.
var globalconfig byte DetailLevel;// 0=Low, 1=Normal, 2=High

// Group bools
var bool bRestartLevel;           // Level should be restarted when player dies
var bool bPauseable;              // Whether the game is pauseable.
var bool bCoopWeaponMode;  // Whether or not weapons stay when picked up.
var bool bTeamGame;               // This is a team game.
var bool bGameEnded;              // set when game ends
var bool bOverTime;               // Game should be ended but wait for Tie to resolve.
var globalconfig bool bAlternateMode;// Alternate mode Gore -> Peace&Love
var bool bCanViewOthers;          // to avoid cheat ViewClass in multi ;)
var bool bDelayedStart;           // When logging, a player is sent to PlayerWaiting instead of being restarted
var bool bWaitingToStartMatch;    // Not every logged player is ready, wait for all of them to have PlayerReplicationInfo.bReadyToPlay = true
// Statistics Logging
var globalconfig bool bLocalLog;
var globalconfig bool bWorldLog;
var bool bLoggingGame;            // Does this gametype log?
var bool bInventorySetUp;         // Used by Saving/Loading (AcceptInventory)

var globalconfig int GoreLevel;   // 0=Normal, increasing values=less gore
var float GameSpeed;              // Scale applied to game rate.
var string DefaultPlayerClassName;// Default player Pawn class
// user interface
var string ScoreBoardType;        // ScoreBoard class this game uses.
var string HUDType;               // HUD class this game uses.
var string MapPrefix;             // Prefix characters for names of maps for this game type.
var string BeaconName;            // Identifying string used for finding LAN servers.

var int MaxSpectators;            // Maximum number of spectators.
var int NumSpectators;            // Current number of spectators.
var int MaxPlayers;               // Maximum number of players
var int NumPlayers;               // number of human players
var int NumBots;                  // number of non-human players (AI controlled but participating as a player)
var int CurrentID;                // set the PlayerID of each player to different using CurrentID++
var localized string DefaultPlayerName;   // Default player name
var localized string GameName;    // Name of the game type

// Message classes.
var class<LocalMessage> DeathMessageClass;  // Class for sending Death messages.
var class<GameMessage> GameMessageClass;    // Class for sending GameType specific messages.

// GameInfo components
var string MutatorClass;          // Base mutator class to use for the game
var Mutator BaseMutator;          // linked list of Mutators (for modifying actors as they enter the game)

var string AccessControlClass;
var AccessControl AccessControl;  // AccessControl controls whether players can enter and/or become admins
var GameRules GameRulesModifiers; // linked list of modifier classes which affect game rules
var string BroadcastHandlerClass;
var BroadcastHandler BroadcastHandler;    // handles message (text and localized) broadcasts

var class<PlayerController> PlayerControllerClass;    // type of player controller to spawn for players logging in
var string PlayerControllerClassName;                 // default player controller class name

// ReplicationInfo
var() class<GameReplicationInfo> GameReplicationInfoClass;
var GameReplicationInfo GameReplicationInfo;

var float DummyStuff1;
var int DummyStuff2;

// Statistics Logging
var StatLog StatLog;
var class<StatLog> StatLogClass;

//actor's lists
var keypoint GenAlerte;                       // idem
var array<Pawn> BaseSoldierList;          // to avoid foreach repeated calls in BaseSoldiers
var array<Triggers> AlarmList;            // idem
var array<Keypoint> GrenadeTargetList;        // idem
var array<NavigationPoint> SafePointList;     // idem
var array<NavigationPoint> AttackPointList;   // idem
var array<NavigationPoint> PatrolPointList;   // idem
var int StatPlayerStart[8];

//____________________________________________________________________________
// Engine notifications.

event PreBeginPlay()
{
  SetGameSpeed(GameSpeed);
  GameReplicationInfo = Spawn(GameReplicationInfoClass);
  InitGameReplicationInfo();
}

event PostBeginPlay()
{
//  if ( bAlternateMode )
//    GoreLevel = 2;
  InitLogging();
  InitLists();
  Super.PostBeginPlay();
}

//_____________________________________________________________________________
function InitLists()
{
    local Pawn P;
    local Triggers T;
    local Keypoint K;
    local Navigationpoint N;

    foreach dynamicactors(class'Pawn', P)
//    foreach ActorInIterationCategory(1, 1, P)
    {
      if ( (P != none) && P.IsA('BaseSoldier') && !P.IsA('Cine2') ) // Have to do this because Basesoldier unknown (in later package)
      {
        BaseSoldierList.Length = BaseSoldierList.Length + 1;
        BaseSoldierList[BaseSoldierList.Length - 1] = P;
      }
    }
    foreach dynamicactors(class'Triggers', T)
//    foreach ActorInIterationCategory(2, 2, P)
    {
      if ( (T != none) && T.IsA('TriggerAlarme') )
      {
        AlarmList.Length = AlarmList.Length + 1;
        AlarmList[AlarmList.Length - 1] = T;
      }
    }
    foreach Allactors(class'keypoint', K)
//    foreach ActorInIterationCategory(3, 3, P)
    {
      if ( K != none )
      {
        if ( K.IsA('GrenadeTarget') )
        {
          GrenadeTargetList.Length = GrenadeTargetList.Length + 1;
          GrenadeTargetList[GrenadeTargetList.Length - 1] = K;
        }
        else if ( K.IsA('GenAlerte') )
        {
          GenAlerte = K;
        }
      }
    }
    foreach Allactors(class'Navigationpoint', N)
//    foreach ActorInIterationCategory(4, 6, P)
    {
      if ( N != none )
      {
        if ( N.IsA('SafePoint') )
        {
          SafePointList.Length = SafePointList.Length + 1;
          SafePointList[SafePointList.Length - 1] = N;
        }
        else if ( N.IsA('AttackPoint') )
        {
          AttackPointList.Length = AttackPointList.Length + 1;
          AttackPointList[AttackPointList.Length - 1] = N;
        }
        else if ( N.IsA('PatrolPoint') )
        {
          PatrolPointList.Length = PatrolPointList.Length + 1;
          PatrolPointList[PatrolPointList.Length - 1] = N;
        }
      }
    }
}
/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
  Super.Reset();
  bGameEnded = false;
  bOverTime = false;
  bWaitingToStartMatch = true;
  InitGameReplicationInfo();
}

/* InitLogging()
Set up statistics logging
*/
function InitLogging()
{
  local bool bLoggingWorld;

  if ( !bLoggingGame )
    return;

  bLoggingWorld = bWorldLog &&
    ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer));
  if ( bLocalLog || bLoggingWorld )
  {
    StatLog = spawn(StatLogClass);
    Log("Initiating logging using "$StatLog$" class "$Statlogclass);
    StatLog.GenerateLogs(bLocalLog, bLoggingWorld);
    StatLog.StartLog();
    LogGameParameters();
  }
}

event Timer()
{
  BroadcastHandler.UpdateSentText();
}

// Called when game shutsdown.
event GameEnding()
{
  EndLogging("serverquit");
}

//------------------------------------------------------------------------------
// Replication

function InitGameReplicationInfo()
{
  GameReplicationInfo.bTeamGame = bTeamGame;
  GameReplicationInfo.GameName = GameName;
  GameReplicationInfo.GameClass = string(Class);
}

native(573) static final function string GetNetworkNumber();

//------------------------------------------------------------------------------
// Game Querying.

function string GetInfo()
{
  local string ResultSet;

  // World logging enabled and working
  if ( StatLog.bWorld && !StatLog.bWorldBatcherError )
    ResultSet = "\\worldlog\\true";
  else
    ResultSet = "\\worldlog\\false";

  // World logging activated
  if ( StatLog.bWorld )
    ResultSet = ResultSet$"\\wantworldlog\\true";
  else
    ResultSet = ResultSet$"\\wantworldlog\\false";

  return ResultSet;
}

function string GetRules()
{
  local string ResultSet;
  local Mutator M;
  local string NextMutator, NextDesc;
  local string EnabledMutators;
  local int Num, i;

  ResultSet = "";

  EnabledMutators = "";
  for (M = BaseMutator.NextMutator; M != None; M = M.NextMutator)
  {
    Num = 0;
    NextMutator = "";
    GetNextIntDesc("Engine.Mutator", 0, NextMutator, NextDesc);
    while( (NextMutator != "") && (Num < 50) )
    {
      if(NextMutator ~= string(M.Class))
      {
        i = InStr(NextDesc, ",");
        if(i != -1)
          NextDesc = Left(NextDesc, i);

        if(EnabledMutators != "")
          EnabledMutators = EnabledMutators $ ", ";
         EnabledMutators = EnabledMutators $ NextDesc;
         break;
      }

      Num++;
      GetNextIntDesc("Engine.Mutator", Num, NextMutator, NextDesc);
    }
  }
  if(EnabledMutators != "")
    ResultSet = ResultSet $ "\\mutators\\"$EnabledMutators;

  ResultSet = ResultSet$"\\listenserver\\"$string(Level.NetMode==NM_ListenServer);
//  Resultset = ResultSet$"\\changelevels\\"$bChangeLevels;
  if ( GameRulesModifiers != None )
    ResultSet = ResultSet$GameRulesModifiers.GetRules();

  return ResultSet;
}

// Return the server's port number.
function int GetServerPort()
{
  local string S;
  local int i;

  // Figure out the server's port.
  S = Level.GetAddressURL();
  i = InStr( S, ":" );
  assert(i>=0);
  return int(Mid(S,i+1));
}

function bool SetPause( BOOL bPause, PlayerController P )
{
  if( bPauseable || P.IsA('Admin') || Level.Netmode==NM_Standalone )
  {
    if( bPause )
      Level.Pauser=P.PlayerReplicationInfo;
    else
      Level.Pauser=None;
    return True;
  }
  else return False;
}

//------------------------------------------------------------------------------
// Stat Logging.

function LogGameParameters()
{
  local Mutator M;

  for (M = BaseMutator; M != None; M = M.NextMutator)
    StatLog.LogMutator(M);

  StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameName"$Chr(9)$GameName);
  StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameClass"$Chr(9)$Class);// <-- Move to c++
  StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameVersion"$Chr(9)$Level.EngineVersion);
  StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MinNetVersion"$Chr(9)$Level.MinNetVersion);
  StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"WeaponsStay"$Chr(9)$bCoopWeaponMode);
  StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GoreLevel"$Chr(9)$GoreLevel);
  StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"TeamGame"$Chr(9)$bTeamGame);
  StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameSpeed"$Chr(9)$int(GameSpeed*100));
  StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MaxSpectators"$Chr(9)$MaxSpectators);
  StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MaxPlayers"$Chr(9)$MaxPlayers);
}

//------------------------------------------------------------------------------
// Game parameters.

//
// Set gameplay speed.
//
function SetGameSpeed( Float T )
{
  local float OldSpeed;

  OldSpeed = GameSpeed;
  GameSpeed = FMax(T, 0.1);
  Level.TimeDilation = GameSpeed;
  if ( GameSpeed != OldSpeed )
    SaveConfig();
  SetTimer(Level.TimeDilation, true);
}

//
// Called after setting low or high detail mode.
//
event DetailChange()
{
  local actor A;
  local zoneinfo Z;
  local skyzoneinfo S;

  if( !Level.bHighDetailMode )
  {
    foreach DynamicActors(class'Actor', A)
    {
      if( A.bHighDetail && !A.bGameRelevant )
        A.Destroy();
    }
  }
  foreach AllActors(class'ZoneInfo', Z)
    Z.LinkToSkybox();
}

//------------------------------------------------------------------------------
// Player start functions

//
// Grab the next option from a string.
//
function bool GrabOption( out string Options, out string Result )
{
  if( Left(Options,1)=="?" )
  {
    // Get result.
    Result = Mid(Options,1);
    if( InStr(Result,"?")>=0 )
      Result = Left( Result, InStr(Result,"?") );

    // Update options.
    Options = Mid(Options,1);
    if( InStr(Options,"?")>=0 )
      Options = Mid( Options, InStr(Options,"?") );
    else
      Options = "";

    return true;
  }
  else return false;
}

//
// break up a key=value pair into its key and value.
//
function GetKeyValue( string Pair, out string Key, out string Value )
{
  if( InStr(Pair,"=")>=0 )
  {
    Key   = Left(Pair,InStr(Pair,"="));
    Value = Mid(Pair,InStr(Pair,"=")+1);
  }
  else
  {
    Key   = Pair;
    Value = "";
  }
}

/* ParseOption()
 Find an option in the options string and return it.
*/
function string ParseOption( string Options, string InKey )
{
  local string Pair, Key, Value;
  while( GrabOption( Options, Pair ) )
  {
    GetKeyValue( Pair, Key, Value );
    if( Key ~= InKey )
      return Value;
  }
  return "";
}

/* Initialize the game.
 The GameInfo's InitGame() function is called before any other scripts (including
 PreBeginPlay() ), and is used by the GameInfo to initialize parameters and spawn
 its helper classes.
 Warning: this is called before actors' PreBeginPlay.
*/
event InitGame( string Options, out string Error )
{
  local string InOpt, LeftOpt;
  local int pos;
  local class<Mutator> MClass;
  local class<AccessControl> ACClass;
  local class<GameRules> GRClass;
  local class<BroadcastHandler> BHClass;

  log("_________________________________");
  log( "InitGame:" @ Options );
//  MaxPlayers = Min( 32,GetIntOption( Options, "MaxPlayers", MaxPlayers ));
  InOpt = ParseOption( Options, "Difficulty" );
  if( InOpt != "" )
    Difficulty = int(InOpt);

  InOpt = ParseOption( Options, "GameSpeed");
  if( InOpt != "" )
  {
    log(" GameSpeed"@InOpt);
    SetGameSpeed(float(InOpt));
  }

  MClass = class<Mutator>(DynamicLoadObject(MutatorClass, class'Class'));
  BaseMutator = spawn(MClass);

  BHClass = class<BroadcastHandler>(DynamicLoadObject(BroadcastHandlerClass,Class'Class'));
  BroadcastHandler = spawn(BHClass);

  InOpt = ParseOption( Options, "AccessControl");
  if( InOpt != "" )
    ACClass = class<AccessControl>(DynamicLoadObject(InOpt, class'Class'));
  if ( ACClass != None )
    AccessControl = Spawn(ACClass);
  else
  {
    ACClass = class<AccessControl>(DynamicLoadObject(AccessControlClass, class'Class'));
    AccessControl = Spawn(ACClass);
  }

  InOpt = ParseOption( Options, "AdminPassword");
  if( InOpt!="" )
    AccessControl.SetAdminPassword(InOpt);

  InOpt = ParseOption( Options, "GameRules");
  if ( InOpt != "" )
  {
    log(" Game Rules"@InOpt);
    while ( InOpt != "" )
    {
      pos = InStr(InOpt,",");
      if ( pos > 0 )
      {
        LeftOpt = Left(InOpt, pos);
        InOpt = Right(InOpt, Len(InOpt) - pos - 1);
      }
      else
      {
        LeftOpt = InOpt;
        InOpt = "";
      }
      log("  Add game rules "$LeftOpt);
      GRClass = class<GameRules>(DynamicLoadObject(LeftOpt, class'Class'));
      if ( GRClass != None )
      {
        if ( GameRulesModifiers == None )
          GameRulesModifiers = Spawn(GRClass);
        else
          GameRulesModifiers.AddGameRules(Spawn(GRClass));
      }
    }
  }

  log(" Base Mutator is "$BaseMutator);
  InOpt = ParseOption( Options, "Mutator");
  if ( InOpt != "" )
  {
    log(" Mutators"@InOpt);
    while ( InOpt != "" )
    {
      pos = InStr(InOpt,",");
      if ( pos > 0 )
      {
        LeftOpt = Left(InOpt, pos);
        InOpt = Right(InOpt, Len(InOpt) - pos - 1);
      }
      else
      {
        LeftOpt = InOpt;
        InOpt = "";
      }
      log("  Add mutator "$LeftOpt);
      MClass = class<Mutator>(DynamicLoadObject(LeftOpt, class'Class'));
      if ( MClass != None )
        BaseMutator.AddMutator(Spawn(MClass));
    }
  }

  InOpt = ParseOption( Options, "GamePassword");
  if( InOpt != "" )
  {
    AccessControl.SetGamePassWord(InOpt);
    log( " GamePassword" @ InOpt );
  }

  InOpt = ParseOption( Options, "LocalLog");
  if( InOpt ~= "true" )
    bLocalLog = True;

  InOpt = ParseOption( Options, "WorldLog");
  if( InOpt ~= "true" )
    bWorldLog = True;
}

//
// Return beacon text for serverbeacon.
//
event string GetBeaconText()
{
  return
    Level.ComputerName
  $"|"$ Left(Level.Title,24)
  $"|"$ GameName
  $"|"$ BeaconName
  $"|"$ NumPlayers $"/"$ MaxPlayers;
}

/* ProcessServerTravel()
 Optional handling of ServerTravel for network games.
*/
function ProcessServerTravel( string URL, bool bItems )
{
  local playercontroller P, LocalPlayer;

  EndLogging("mapchange");

  // Notify clients we're switching level and give them time to receive.
  // We call PreClientTravel directly on any local PlayerPawns (ie listen server)
  log("ProcessServerTravel:"@URL);
  foreach DynamicActors( class'PlayerController', P )
    if( NetConnection( P.Player)!=None )
      P.ClientTravel( URL, TRAVEL_Relative, bItems );
    else
    {
      LocalPlayer = P;
      P.PreClientTravel();
    }

  if ( (Level.NetMode == NM_ListenServer) && (LocalPlayer != None) )
    Level.NextURL = Level.NextURL$"?Skin="$LocalPlayer.GetDefaultURL("Skin")
           $"?Face="$LocalPlayer.GetDefaultURL("Face")
           $"?Team="$LocalPlayer.GetDefaultURL("Team")
           $"?Name="$LocalPlayer.GetDefaultURL("Name")
           $"?Class="$LocalPlayer.GetDefaultURL("Class");

  // Switch immediately if not networking.
  if( Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
    Level.NextSwitchCountdown = 0.0;
}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//
event PreLogin
(
  string Options,
  string Address,
  out string Error,
  out string FailCode
)
{
  local bool bSpectator;
  local string spec;

  spec = ParseOption ( Options, "SpectatorOnly" );
  bSpectator = ( spec != "" );

  AccessControl.PreLogin(Options, Address, Error, FailCode, bSpectator);
}

function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
  local string InOpt;

  InOpt = ParseOption( Options, ParseString );
  if ( InOpt != "" )
  {
    log(ParseString@InOpt);
    return int(InOpt);
  }
  return CurrentValue;
}

function bool AtCapacity(bool bSpectator)
{
  if ( Level.NetMode == NM_Standalone )
    return false;

  if ( bSpectator )
    return ( (NumSpectators >= MaxSpectators)
      && ((Level.NetMode != NM_ListenServer) || (NumPlayers > 0)) );
  else
    return ( (MaxPlayers>0) && (NumPlayers>=MaxPlayers) );
}

//
// Log a player in.
// Fails login if you set the Error string.
// PreLogin is called before Login, but significant game time may pass before
// Login is called, especially if content is downloaded.
//
event PlayerController Login
(
  string Portal,
  string Options,
  out string Error
)
{
  local NavigationPoint StartSpot;
  local PlayerController NewPlayer;
  local class<Pawn> DesiredPawnClass;
  local Pawn      TestPawn;
  local string          InName, InPassword, InChecksum, InClass;
  local byte            InTeam;
  local bool bSpectator;
  local int i;
  local Actor A;

  bSpectator = ( ParseOption( Options, "SpectatorOnly" ) != "" );

  // Make sure there is capacity. (This might have changed since the PreLogin call).
  if ( AtCapacity(bSpectator) )
  {
    Error=GameMessageClass.Default.MaxedOutMessage;
    return None;
  }

  BaseMutator.ModifyLogin(Portal, Options);

  // Get URL options.
  InName     = Left(ParseOption ( Options, "Name"), 20);
  InTeam     = GetIntOption( Options, "Team", 255 ); // default to "no team"
  InPassword = ParseOption ( Options, "Password" );
  InChecksum = ParseOption ( Options, "Checksum" );

  log( "Login:" @ InName );
  if( InPassword != "" )
    log( "Password"@InPassword );

  // Pick a team (if need teams)
  InTeam = PickTeam(InTeam);

  // Find a start spot.
  StartSpot = FindPlayerStart( None, InTeam, Portal );

  if( StartSpot == None )
  {
    Error = GameMessageClass.Default.FailedPlaceMessage;
    return None;
  }

  // Init player's administrative privileges
  if ( AccessControl.AdminLogin(NewPlayer, InPassword) )
  {
    NewPlayer = spawn(AccessControl.AdminClass,,,StartSpot.Location,StartSpot.Rotation);
    bSpectator = true;
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

  // Init player's name
  if( InName=="" )
    InName=DefaultPlayerName;
  if( Level.NetMode!=NM_Standalone || NewPlayer.PlayerReplicationInfo.PlayerName==DefaultPlayerName )
    ChangeName( NewPlayer, InName, false );

  // Init player's replication info
  NewPlayer.GameReplicationInfo = GameReplicationInfo;

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

  InClass = ParseOption( Options, "Class" );
  if ( InClass != "" )
  {
    DesiredPawnClass = class<Pawn>(DynamicLoadObject(InClass, class'Class'));
    if ( DesiredPawnClass != None )
      NewPlayer.PawnClass = DesiredPawnClass;
  }

  // Log it.
  if ( StatLog != None )
    StatLog.LogPlayerConnect(NewPlayer);
  NewPlayer.ReceivedSecretChecksum = !(InChecksum ~= "NoChecksum");

  NumPlayers++;

  // If we are a server, broadcast a welcome message.
  if( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
    BroadcastLocalizedMessage(GameMessageClass, 1, NewPlayer.PlayerReplicationInfo);

  // if delayed start, don't give a pawn to the player yet
  // Normal for multiplayer games
  if ( bDelayedStart )
  {
    NewPlayer.GotoState('PlayerWaiting');
    return NewPlayer;
  }

  // Try to match up to existing unoccupied player in level,
  // for savegames and coop level switching.
  ForEach DynamicActors(class'Pawn', TestPawn )
  {
    if ( (TestPawn!=None) && (PlayerController(TestPawn.Controller)!=None) && (PlayerController(TestPawn.Controller).Player==None) && (TestPawn.Health > 0) &&  (TestPawn.PawnName~=InName) )
    {
      NewPlayer.Destroy();
      TestPawn.SetRotation(TestPawn.Controller.Rotation);
      TestPawn.bInitializeAnimation = false; // FIXME - temporary workaround for lack of meshinstance serialization
      TestPawn.PlayWaiting();
      return PlayerController(TestPawn.Controller);
    }
  }

  return newPlayer;
}

/* StartMatch()
Start the game - inform all actors that the match is starting, and spawn player pawns
*/
function StartMatch()
{
  local Controller P;
  local Actor A;

  if (StatLog != None)
    StatLog.LogGameStart();

  // tell all actors the game is starting
  ForEach AllActors(class'Actor', A)
    A.MatchStarting();

  // start human players first
  for ( P = Level.ControllerList; P!=None; P=P.nextController )
    if ( P.IsA('PlayerController') && (P.Pawn == None) )
    {
      if ( bGameEnded ) return; // telefrag ended the game with ridiculous frag limit
      else if ( !PlayerController(P).bOnlySpectator  )
        RestartPlayer(P);
      SendStartMessage(PlayerController(P));
    }

  // start AI players
  for ( P = Level.ControllerList; P!=None; P=P.nextController )
    if ( P.bIsPlayer && !P.IsA('PlayerController') )
      RestartPlayer(P);

  bWaitingToStartMatch = false;
}

//
// Restart a player.
//
function RestartPlayer( Controller aPlayer )
{
  local NavigationPoint startSpot;
  local bool foundStart;
  local int TeamNum,i;
  local class<Pawn> DefaultPlayerClass;

  if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
    return;

  if ( (aPlayer.PlayerReplicationInfo == None) || (aPlayer.PlayerReplicationInfo.Team == None) )
    TeamNum = 255;
  else
    TeamNum = aPlayer.PlayerReplicationInfo.Team.TeamIndex;

  startSpot = FindPlayerStart(aPlayer, TeamNum);
  if( startSpot == None )
  {
    log(" Player start not found!!!");
    return;
  }

  if ( (aPlayer.PlayerReplicationInfo.Team != None)
    && ((aPlayer.PawnClass == None) || !aPlayer.PlayerReplicationInfo.Team.BelongsOnTeam(aPlayer.PawnClass)) )
      aPlayer.PawnClass = class<Pawn>(DynamicLoadObject(aPlayer.PlayerReplicationInfo.Team.DefaultPlayerClassName, class'Class'));

  if ( aPlayer.PawnClass != None )
    aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,StartSpot.Location,StartSpot.Rotation);

  if( aPlayer.Pawn==None )
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

  PlayTeleportEffect(aPlayer, true, true);
  aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
  AddDefaultInventory(aPlayer.Pawn);
  TriggerEvent( StartSpot.Event, StartSpot, aPlayer.Pawn);
}

function string GetDefaultPlayerClassName(Controller C)
{
  return DefaultPlayerClassName;
}

function SendStartMessage(PlayerController P)
{
  P.ClearProgressMessages();
}

//
// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerPawn.
//
event PostLogin( PlayerController NewPlayer )
{
  local Controller P;
  local class<Scoreboard> S;
  local class<HUD> H;

  if ( !bDelayedStart )
  {
    // start match, or let player enter, immediately
    bRestartLevel = false;  // let player spawn once in levels that must be restarted after every death
    if ( bWaitingToStartMatch )
      StartMatch();
    else
      RestartPlayer(newPlayer);
    bRestartLevel = Default.bRestartLevel;
  }

    // tell client what hud and scoreboard to use
  if ( HUDType != "" )
    H = class<HUD>(DynamicLoadObject(HUDType, class'Class'));
  if ( ScoreboardType != "" )
    S = class<Scoreboard>(DynamicLoadObject(ScoreboardType, class'Class'));
  NewPlayer.ClientSetHUD(H,S);

  // Replicate skins - to avoid loading pauses in multiplayer games
  if ( Level.NetMode != NM_Standalone )
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

  if ( NewPlayer.Pawn != None )
    NewPlayer.Pawn.ClientSetRotation(NewPlayer.Pawn.Rotation);
}

//
// Player exits.
//
function Logout( Controller Exiting )
{
  local bool bMessage;

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
  if( bMessage && (Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer) )
    BroadcastLocalizedMessage(GameMessageClass, 4, Exiting.PlayerReplicationInfo);

  if ( StatLog != None )
    StatLog.LogPlayerDisconnect(Exiting);
}

//
// Examine the passed player's inventory, and accept or discard each item.
// AcceptInventory needs to gracefully handle the case of some inventory
// being accepted but other inventory not being accepted (such as the default
// weapon).  There are several things that can go wrong: A weapon's
// AmmoType not being accepted but the weapon being accepted -- the weapon
// should be killed off. Or the player's selected inventory item, active
// weapon, etc. not being accepted, leaving the player weaponless or leaving
// the HUD inventory rendering messed up (AcceptInventory should pick another
// applicable weapon/item as current).
//
event AcceptInventory(pawn PlayerPawn)
{
  //default accept all inventory except default weapon (spawned explicitly)
}

//
// Spawn any default inventory for the player.
//
function AddDefaultInventory( pawn PlayerPawn )
{
  local Weapon newWeapon;
  local class<Weapon> WeapClass;

  // Spawn default weapon.
  WeapClass = BaseMutator.GetDefaultWeapon();
  if( (WeapClass!=None) && (PlayerPawn.FindInventoryType(WeapClass)==None) )
  {
    newWeapon = Spawn(WeapClass,,,PlayerPawn.Location);
    if( newWeapon != None )
    {
      newWeapon.GiveTo(PlayerPawn);
      newWeapon.BringUp();
      newWeapon.bCanThrow = false; // don't allow default weapon to be thrown out
    }
  }
  SetPlayerDefaults(PlayerPawn);
}

/* SetPlayerDefaults()
 first make sure pawn properties are back to default, then give mutators an opportunity
 to modify them
*/
function SetPlayerDefaults(Pawn PlayerPawn)
{
  PlayerPawn.JumpZ = PlayerPawn.Default.JumpZ;
  PlayerPawn.AirControl = PlayerPawn.Default.AirControl;
  BaseMutator.ModifyPlayer(PlayerPawn);
}

function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn )
{
  local Controller C;

  for ( C=Level.ControllerList; C!=None; C=C.nextController )
    C.NotifyKilled(Killer, Killed, KilledPawn);
}

function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
  local String Message, KillerWeapon, OtherWeapon;
  local name logtype;

  NotifyKilled(Killer,Killed,KilledPawn);

  if ( Killed.bIsPlayer && !Level.bLonePlayer )
  { // ELR don't message if loneplayer = solo game
    Killed.PlayerReplicationInfo.Deaths += 1;
    BroadcastDeathMessage(Killer, Killed, damageType);
    if ( (StatLog != None) && (Killer != None) && Killer.bIsPlayer )
    {
      if ( DamageType.Default.DamageWeaponName != "" )
        KillerWeapon = DamageType.Default.DamageWeaponName;
      else
        KillerWeapon = "None";

      if (KilledPawn.Weapon != None)
        OtherWeapon = KilledPawn.Weapon.ItemName;
      else
        OtherWeapon = "None";
      StatLog.LogKill(
        Killer.PlayerReplicationInfo,
        Killed.PlayerReplicationInfo,
        KillerWeapon,
        OtherWeapon,
        damageType
      );
    }
  }

  log("Killed"@Killer@Killed);
  ScoreKill(Killer, Killed);
  DiscardInventory(KilledPawn);
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
  if ( GameRulesModifiers == None )
    return false;
  return GameRulesModifiers.PreventDeath(Killed,Killer, damageType,HitLocation);
}

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
  if ( (Killer == Other) || (Killer == None) )
    BroadcastLocalizedMessage(DeathMessageClass, 1, None, Other.PlayerReplicationInfo, damageType);
  else
    BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType);
}


// %k = Owner's PlayerName (Killer)
// %o = Other's PlayerName (Victim)
// %w = Owner's Weapon ItemName
native(572) static final function string ParseKillMessage( string KillerName, string VictimName, string DeathMessage );

function Kick( string S )
{
  AccessControl.Kick(S);
}
function KickBan( string S )
{
  AccessControl.KickBan(S);
}

function bool IsOnTeam(Controller Other, int TeamNum)
{
  if ( bTeamGame && (Other != None) && (Other.PlayerReplicationInfo.Team.TeamIndex == TeamNum) )
    return true;
  return false;
}

//-------------------------------------------------------------------------------------
// Level gameplay modification.

//
// Return whether Viewer is allowed to spectate from the
// point of view of ViewTarget.
//
function bool CanSpectate( PlayerController Viewer, actor ViewTarget )
{
  return true;
}

/* Use reduce damage for teamplay modifications, etc.
*/
function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType );

//
// Return whether an item should respawn.
//
function bool ShouldRespawn( Pickup Other )
{
  if( Level.NetMode == NM_StandAlone )
    return false;

  return Other.ReSpawnTime!=0.0;
}

/* Called when pawn has a chance to pick Item up (i.e. when
   the pawn touches a weapon pickup). Should return true if
   he wants to pick it up, false if he does not want it.
*/
function bool PickupQuery( Pawn Other, Pickup item )
{
  local byte bAllowPickup;

  if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, item, bAllowPickup) )
    return (bAllowPickup == 1);

  if ( Other.Inventory == None )
    return true;
  else
    return !Other.Inventory.HandlePickupQuery(Item);
}

/* Discard a player's inventory after he dies.
*/
function DiscardInventory( Pawn Other )
{
  local actor dropped;
  local inventory Inv,Next;
  local float speed;

  if( (Other.Weapon!=None) && Other.Weapon.bCanThrow && Other.Weapon.HasAmmo() )
  {
    if ( Other.Weapon.PickupAmmoCount == 0 )
      Other.Weapon.PickupAmmoCount = 1;
    speed = VSize(Other.Velocity);
    if (speed != 0)
      Other.TossWeapon(Normal(Other.Velocity/speed + 0.5 * VRand()) * (speed + 280));
    else
      Other.TossWeapon(vect(0,0,0));
  }
  Other.Weapon = None;
  Other.SelectedItem = None;
  Inv = Other.Inventory;
  while ( Inv != None )
  {
    Next = Inv.Inventory;
    Inv.Destroy();
    Inv = Next;
  }
}

/* Try to change a player's name.
*/
function ChangeName( Controller Other, coerce string S, bool bNameChange )
{
  if( S == "" )
    return;
  if ( StatLog != None)
    StatLog.LogNameChange(Other);
  Other.PlayerReplicationInfo.SetPlayerName(S);
  if( bNameChange && (PlayerController(Other) != None) )
    BroadcastLocalizedMessage( GameMessageClass, 2, Other.PlayerReplicationInfo );
}

/* Return whether a team change is allowed.
*/
function bool ChangeTeam(Controller Other, int N)
{
  return true;
}

// return wether a class change is allowed
function bool ChangeClass(Controller Other, class<Pawn> InClass)
{
  return false;
}

/* Return a picked team number if none was specified
*/
function byte PickTeam(byte Current)
{
  return Current;
}

/* Play an inventory respawn effect.
*/
function float PlaySpawnEffect( pickup P )
{
  return 0.3;
}

/* Send a player to a URL.
*/
function SendPlayer( PlayerController aPlayer, string URL )
{
  aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
}

/* Play a teleporting special effect.
*/
function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
  Incoming.MakeNoise(1.0);
}

/* Restart the game.
*/
function RestartGame()
{
//  local string NextMap;
//  local MapList myList;
//  local class<MapList> ML;

  if ( (GameRulesModifiers != None) && GameRulesModifiers.HandleRestartGame() )
    return;

/*
  // these server travels should all be relative to the current URL
  if ( bChangeLevels && !bAlreadyChanged && (MapListType != "") )
  {
    // open a the nextmap actor for this game type and get the next map
    bAlreadyChanged = true;
    ML = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
    myList = spawn(ML);
    NextMap = myList.GetNextMap();
    myList.Destroy();
    if ( NextMap == "" )
      NextMap = GetMapName(MapPrefix, NextMap,1);

    if ( NextMap != "" )
    {
      Level.ServerTravel(NextMap, false);
      return;
    }
  }
*/

  Level.ServerTravel( "?Restart", false );
}

//==========================================================================
// Message broadcasting functions (handled by the BroadCastHandler)

event Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
  BroadcastHandler.Broadcast(Sender,Msg,Type);
}

function BroadcastTeam( Controller Sender, coerce string Msg, optional name Type )
{
  BroadcastHandler.BroadcastTeam(Sender,Msg,Type);
}

/*
 Broadcast a localized message to all players.
 Most message deal with 0 to 2 related PRIs.
 The LocalMessage class defines how the PRI's and optional actor are used.
*/
event BroadcastLocalized( actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
  BroadcastHandler.AllowBroadcastLocalized(Sender,Message,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
}

//==========================================================================

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
  local Controller P;

  if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
    return false;

  // all player cameras focus on winner or final scene (picked by gamerules)
  for ( P=Level.ControllerList; P!=None; P=P.NextController )
  {
    P.ClientGameEnded();
    P.GotoState('GameEnded');
  }
  return true;
}

/* End of game.
*/
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
  EndLogging(Reason);
}

function EndLogging(string Reason)
{
  if ( StatLog == None )
    return;
  StatLog.LogGameEnd(Reason);
  StatLog.StopLog();
  StatLog.Destroy();
  StatLog = None;
}

/* Return the 'best' player start for this player to start from.
 */
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
  local NavigationPoint N, BestStart;
  local Teleporter Tel;
  local float BestRating, NewRating;
  local byte Team;
  local int test, loop;

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

//log("");
//log("Search....");
//log("");

  for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
  {
    if( N.IsA('PlayerStart') )
    {
        NewRating = RatePlayerStart(N,InTeam,Player);

        //log("    >"@N@NewRating);

        if ( NewRating > BestRating )
        {
          BestRating = NewRating;
          BestStart = N;
          //test = loop;
        }

        Loop++;
    }
  }

//StatPlayerStart[test]++;
//
//test=0;
//
//for( loop=0 ; loop<7; loop++ )
// test += StatPlayerStart[loop];
//
//  loop=0;
//
//  for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
//  {
//    if( N.IsA('PlayerStart') )
//    {
//        log(" >"@N@":"@StatPlayerStart[loop]*100/test$"%");
//        Loop++;
//    }
//  }
//
//log("");
//log("Respawn="@test);
//log("");

  if ( BestStart == None )
  {
    log("Warning - PATHS NOT DEFINED or NO PLAYERSTART");
    foreach AllActors( class 'NavigationPoint', N )
    {
      NewRating = RatePlayerStart(N,0,Player);
      if ( NewRating > BestRating )
      {
        BestRating = NewRating;
        BestStart = N;
      }
    }
  }

  return BestStart;
}

/* Rate whether player should choose this NavigationPoint as its start
default implementation is for single player game
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
  local PlayerStart P;

  P = PlayerStart(N);
  if ( P != None )
  {
    if ( P.bSinglePlayerStart )
    {
      if ( P.bEnabled )
        return 1000;
      return 20;
    }
    return 10;
  }
  return 0;
}

function ScoreObjective(PlayerReplicationInfo Scorer, Int Score)
{
  if ( Scorer != None )
  {
    Scorer.Score += Score;
    if ( Scorer.Team != None )
      Scorer.Team.Score += Score;
  }
  if ( GameRulesModifiers != None )
    GameRulesModifiers.ScoreObjective(Scorer,Score);

  CheckScore(Scorer);
}

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
  if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
    return;
}

function ScoreKill(Controller Killer, Controller Other)
{
  if (killer == Other)
    Other.PlayerReplicationInfo.Score -= 1;
  else if ( killer.PlayerReplicationInfo != None )
    killer.PlayerReplicationInfo.Score += 1;

  if ( GameRulesModifiers != None )
    GameRulesModifiers.ScoreKill(Killer, Other);

  CheckScore(Killer.PlayerReplicationInfo);
}

defaultproperties
{
     DetailLevel=2
     bRestartLevel=True
     bPauseable=True
     bCanViewOthers=True
     bWaitingToStartMatch=True
     bLocalLog=True
     bWorldLog=True
     GameSpeed=1.000000
     HUDType="Engine.HUD"
     MaxSpectators=2
     MaxPlayers=16
     DefaultPlayerName="Player"
     GameName="Game"
     DeathMessageClass=Class'Engine.LocalMessage'
     GameMessageClass=Class'Engine.GameMessage'
     MutatorClass="Engine.Mutator"
     AccessControlClass="Engine.AccessControl"
     BroadcastHandlerClass="Engine.BroadcastHandler"
     PlayerControllerClassName="Engine.PlayerController"
     GameReplicationInfoClass=Class'Engine.GameReplicationInfo'
     StatLogClass=Class'Engine.StatLogFile'
}
