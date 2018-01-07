//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIAdmin extends XIIIMPPlayerController;

//_____________________________________________________________________________
replication
{
  reliable if( Role<ROLE_Authority )
     Kick, KickBan;
}

/*
//_____________________________________________________________________________
// Execute an administrative console command on the server.
exec function Admin( string CommandLine )
{
    local string Result;

    Result = ConsoleCommand( CommandLine );
    if( Result!="" )
      ClientMessage( Result );
}
*/

//_____________________________________________________________________________
exec function KickBan( string S )
{
    if ( S ~= PlayerReplicationInfo.PlayerName )
      return; // no self-kick ?
    Level.Game.KickBan(S);
}

//_____________________________________________________________________________
exec function Kick( string S )
{
    if ( S ~= PlayerReplicationInfo.PlayerName )
      return; // no self-kick ?
    Level.Game.Kick(S);
}

//_____________________________________________________________________________
exec function PlayerList()
{
    local PlayerReplicationInfo PRI;

    log("Player List:");
    ForEach DynamicActors(class'PlayerReplicationInfo', PRI)
      log("'"$PRI.PlayerName$"' ( ping"@PRI.Ping$")");
}



defaultproperties
{
}
