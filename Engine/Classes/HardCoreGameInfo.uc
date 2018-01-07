//==============================================================================
//                          HardCoreGameInfo
//    By : FrA'|Tairusu, Requested by RafL.
//    Current Release : for Rafl... Maybe Added as a mod for XIIIMP (Rafl, Nice find) !
//    Features : - Well... Simply Classes Changes (for looking like COD4 Hardcore Mode)
//               - Features of OxMatch (Especially for Lag)
//==============================================================================
class HardCoreGameInfo extends XIIIMPGameInfo;


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
          InClass = class'MPClassList'.default.ClassListInfo[NumPlayers].ClassName;
          DefaultPlayerName = class'MPClassList'.default.ClassListInfo[NumPlayers].ReadableName;
          DesiredPawnClass = class<Pawn>(DynamicLoadObject(InClass, class'Class'));
    }
    else
    { // On-line game, get Class in
      PlayerSkin[0] = PlayerSkin[0] % class'MPClassList'.default.ClassListInfo.Length;
      InClass = class'HardcoreList'.default.ClassListInfo[PlayerSkin[0]].ClassName;
      DefaultPlayerName = class'MPClassList'.default.ClassListInfo[PlayerSkin[0]].ReadableName;
      DesiredPawnClass = class<Pawn>(DynamicLoadObject(InClass, class'class'));
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
    ForEach DynamicActors(class'HardcorePawn', TestPawn )
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

defaultproperties
{
     PreGameEndMessageWinner="Player "
     PostGameEndMessageWinner=" Wins the match"
     PreGameEndMessageTimeOut="Time out"
     AltGameName="HardcoreModeXIII"
     RestartTimeOut=180
     bDelayedStart=True
     PlayerControllerClassName="OXMatch.XPlayerController"
     ScoreBoardType="OXMatch.OXTeamScoreBoard"
     HUDType="OXMatch.WarTeamHUD"
     DefaultPlayerClassName="OXMatch.XMultiPawn"
     MapPrefix="DM"
     GameName="HardCoreModeXIII"
     MutatorClass="OXMatch.OXGameMutator"
     AccessControlClass="OXMatch.AdminAccess"
     GameReplicationInfoClass=class'XIII.XIIIGameReplicationInfo'
}