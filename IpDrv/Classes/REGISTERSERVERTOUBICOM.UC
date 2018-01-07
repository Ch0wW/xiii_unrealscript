//=============================================================================
// RegisterServerToUbiCom: To register a dedicated server to UBI.COM
//=============================================================================
class RegisterServerToUbiCom extends Info;


var MatchMakingManager myMMManager;
var int ResultCode;


var string GSAlias, GSPassword;
var string ServerName, IsPrivate;
var int MaxPlayer;
var string Info4GS;
var int ListeningPort;

var byte Status;
var string LastUpdateValue;
var int ExitMessageReminderCounter;

var int PlayerCount;
var PlayerReplicationInfo Ordered[32];



function BeginPlay()
{
    local string URLOptions, MapName;
    local bool bGSServer;
    local int GameIdx, FragLimit, TimeLimit;

    URLOptions = Level.getLocalURL();
    URLOptions = Mid(URLOptions, InStr( URLOptions, "?" ));

    //log("In RegisterServerToUbiCom, URLOptions = "$URLOptions);
    bGSServer = (Level.Game.ParseOption ( URLOptions, "GS" ) != "");

    if ((Level.NetMode != NM_DedicatedServer) || !bGSServer)
    {
        Destroy();
    }
    else
    {
        GSAlias = Level.Game.ParseOption ( URLOptions, "GSAlias" );
        GSPassword = Level.Game.ParseOption ( URLOptions, "GSPassword" );
        ServerName = Level.Game.ParseOption ( URLOptions, "ServerName" );
        IsPrivate = Level.Game.ParseOption ( URLOptions, "IsPrivate" );
        MaxPlayer = int(Level.Game.ParseOption ( URLOptions, "NP" ));
        
        GameIdx = int(Level.Game.ParseOption ( URLOptions, "GameIdx" ));
        MapName = Level.Game.ParseOption ( URLOptions, "MapName" );
        FragLimit = int(Level.Game.ParseOption ( URLOptions, "FR" ));
        TimeLimit = int(Level.Game.ParseOption ( URLOptions, "TI" ));
        Info4GS = GameIdx$"?"$MapName$"?"$FragLimit$"?"$TimeLimit$"?"$IsPrivate;

        ListeningPort = int(ConsoleCommand( "ListeningPort" ));
        if ((ListeningPort <= 0) || (ListeningPort >65535))
            ListeningPort = 7777;

        Status = 0;


        //log("GSAlias="$GSAlias$", GSPassword="$GSPassword$", ServerName="$ServerName$", IsPrivate="$IsPrivate$", Info4GS="$Info4GS);
        //log("MaxPlayer="$MaxPlayer$", GameIdx="$GameIdx$", MapIdx="$MapIdx$", FragLimit="$FragLimit$", TimeLimit="$TimeLimit$", ListeningPort="$ListeningPort);

    }
}


event Destroyed()
{
    // Unregister the server  (but don't seem to come here...)
    if (myMMManager != none)
    {
        myMMManager.UnregisterMyGameServer();
    }
}


event Timer()
{
    switch (Status)
    {
    case 0:
        GotoState('STA_RegisterGameServer');
        break;

    case 1:
        GotoState('KeepGSposted');
        break;
    }
}




function SortScores(int N)
{
    local int I, J, Max;
    local PlayerReplicationInfo TempPRI;

    for ( I=0; I<N-1; I++ )
    {
      Max = I;
      for ( J=I+1; J<N; J++ )
      {
        if ( Ordered[J].Score > Ordered[Max].Score )
          Max = J;
        else if ((Ordered[J].Score == Ordered[Max].Score) && (Ordered[J].Deaths < Ordered[Max].Deaths))
          Max = J;
        else if ((Ordered[J].Score == Ordered[Max].Score) && (Ordered[J].Deaths == Ordered[Max].Deaths) &&
          (Ordered[J].PlayerID < Ordered[Max].Score))
          Max = J;
      }

      TempPRI = Ordered[Max];
      Ordered[Max] = Ordered[I];
      Ordered[I] = TempPRI;
    }
}

function UpdatePlayerList()
{
    local int i;
    local PlayerReplicationInfo PRI;

    // Wipe everything.
    for ( i=0; i<ArrayCount(Ordered); i++ )
      Ordered[i] = None;
    PlayerCount = 0;

    foreach AllActors(class'PlayerReplicationInfo', PRI)
    {
      if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
      {
        Ordered[PlayerCount] = PRI;
        PlayerCount++;
        if ( PlayerCount == ArrayCount(Ordered) )
          break;
      }
    }

    SortScores(PlayerCount);
}


function bool BuildPlayerListWithScore()
{
    local string Result;
    local int Loop;

    UpdatePlayerList();

    for ( Loop=0; Loop<PlayerCount; Loop++ )
    {
        if (Loop > 0)
            Result = Result$"?";
        Result = Result$Ordered[Loop].PlayerName$"="$int(Ordered[Loop].Score);
    }

    if (LastUpdateValue == Result)
    {
        return false;
    } 
    else
    {
        LastUpdateValue = Result;
        return true;
    }
}



function CheckIfConnectionLostWithUbiCom()
{
    local bool ConnectionLost, GameServerStillResgistered;
    ConnectionLost = false; //myMMManager.IsConnectionLostWithGS();
    GameServerStillResgistered = myMMManager.IsMyGameServerStillRegistered();
    //if (ConnectionLost)
    //    log("----> Connection lost with ubi.com !!");
    if (!GameServerStillResgistered)
        log("----> My game server is no longer registered !!");

    if (myMMManager!=none)
    {
        if (ConnectionLost || !GameServerStillResgistered)
        {
            myMMManager.LogOut();
            log("**********************************************************************");
            log(" At "$LevelTimeInReadableFormat()$" since server launch");
            log(" Disconnected from Ubi.com. Will register the server again in 30 sec. ");
            log("**********************************************************************");
            GotoState('');
            Status = 0;
            LastUpdateValue="...";
        }
    }
    else
    {
        // no myMMManager ? Force the creation of one
        GotoState('');
        Status = 0;
        LastUpdateValue="...";
    }
}



function string LevelTimeInReadableFormat()
{
    local float LevelTime;
    local int Day, Hour, Min, Sec;

    LevelTime = Level.TimeSeconds;
    Day = int(LevelTime/86400);         // 86400 = 24 hours * 3600 secs
    LevelTime -= Day*86400;
    Hour = int(LevelTime / 3600);
    LevelTime -= Hour*3600;
    Min = int(LevelTime / 60);
    LevelTime -= Min * 60;
    Sec = int(LevelTime);

    return Day$"d "$Hour$"h "$Min$"m "$Sec$"s";
}



auto State STA_RegisterGameServer
{

begin:
    if (myMMManager == none)
        myMMManager = new(none) class'MatchMakingManager';

    //log("Log into GS with "$myMMManager);
    myMMManager.Login(GSAlias, GSPassword);

    //log("Getting server list");
    /*
    myMMManager.RequestGameServerList();
    while ( !myMMManager.IsGameServerListComplete(ResultCode) )
    {
        Sleep(0.1);
    }

    if (ResultCode != 0) 
    {
        // will retry later
        myMMManager.LogOut();
        SetTimer(30, true);
        log("*****************************************************************");
        log("*****************************************************************");
        log(" At "$LevelTimeInReadableFormat()$" since server launch");
        log(" Failed to register the game server (Phase 1). Will retry in 30 seconds...");
        log("*****************************************************************");
        log("*****************************************************************");
        GotoState('');
    }
    */

    //log("Register server to GS...");
	myMMManager.RegisterMyGameServer(ServerName, MaxPlayer, 0, "", Info4GS, "", ListeningPort, true);
	while (!myMMManager.IsMyGameServerRegistered(ResultCode))
	{
		Sleep(0.1);
	}
	
	if (ResultCode == 0) 
	{
        log("***********************************");
        log("***********************************");
        log(" Game server registered to Ubi.com ");
        log(" at "$LevelTimeInReadableFormat()$" since server launch");
        log("***********************************");
        log("***********************************");
        log(" Press 'q' to terminate the server");
        log("***********************************");
        //myMMManager.IStartMatch();      // the master joins its room...

        Status = 1;
	}
	else 
	{
        log("*****************************************************************");
        log("*****************************************************************");
        log(" At "$LevelTimeInReadableFormat()$" since server launch");
        log(" Failed to register the game server (Phase 2). Will retry in 30 seconds...");
        log("*****************************************************************");
        log("*****************************************************************");
        myMMManager.LogOut();
	}
    
    SetTimer(30, true);
    GotoState('');
}



State KeepGSposted
{
begin:
    CheckIfConnectionLostWithUbiCom();
    //log("Maybe I will update GS...");
    if (BuildPlayerListWithScore())
    {
        CheckIfConnectionLostWithUbiCom();
        log("Sending "$LastUpdateValue$" to GS");
        myMMManager.UpdateMyGameServer(-1, -1, "", ""/*info*/, LastUpdateValue/*AdditionalInfo*/, -1);
        while ( !myMMManager.IsMyGameServerUpdated(ResultCode) )
        {
            CheckIfConnectionLostWithUbiCom();
            Sleep(0.1);
        }
        /*  Whatever the ResultCode, there is nothing we can do...
        if (ResultCode == 0)
        {
            log("Server updated on GS");
        }
        else
        {
            log("Error while updating the server on GS");
        }
        */
    }

    ExitMessageReminderCounter++;
    if (ExitMessageReminderCounter > 10)
    {
        log("----- Press 'q' to terminate the server ("$LevelTimeInReadableFormat()$" since server launch)");
        ExitMessageReminderCounter = 0;
    }

    GotoState('');
}




defaultproperties
{
     LastUpdateValue="..."
}
