//-----------------------------------------------------------
// Server class used to store player stats and updating rank/ladder at logout
//-----------------------------------------------------------
class PlayerStats extends Info
    native;

var int StatKills;          // Number of kills (ALL)
var int StatDeaths;         // Number of deaths (ALL)
var int StatSuicides;       // Number of suicides (ALL)
var int StatMinutes;        // Minutes Played (ALL)
var int StatFlagsS;         // Flags Scored (CTF)
var int StatFlagsR;         // Flags Returned (CTF)
var int StatMatchesPlayed;  // Number of matches played

var float EnterTimeSeconds;
var float LeaveTimeSeconds;

//var XboxLiveManager xboxlive; // ELR Useless as the controller will do the update (must be made on clients, this don't exists elsewhere than server
//StatsUpdateMyStats(kills, deaths, suicides, minutes, games, gameswon, flagscapt, flagsret)

//_____________________________________________________________________________
event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(50.0 + frand()*20, false); // client update timer, stats will be updated on clients in this timer
}

/*
//_____________________________________________________________________________
function LogStats()
{
    StatMinutes = int((LeaveTimeSeconds - EnterTimeSeconds)/60.0);
    Log("STATS for"@Owner@"::");
    Log("  Kills +="@StatKills);
    Log("  Deaths +="@StatDeaths);
    Log("  Suicides +="@StatSuicides);
    Log("  Minutes +="@StatMinutes);
    Log("  Flags Scored +="@StatFlagsS);
    Log("  Flags Returned +="@StatFlagsR);
//    Log("  Matchs Won +="@StatMatchWon);
//    Log("  Matchs Losed +="@StatMatchLost);

    // ELR Don't use line below, system changed (see StatUpdate in XIIIMPPlayercontroller.uc
    //xboxlive.StatsUpdateMyStats(StatKills, StatDeaths, StatSuicides, StatMinutes, 1, StatMatchWon, StatFlagsS, StatFlagsR);
}
*/

//_____________________________________________________________________________
event Timer()
{ // Send stats to client playercontroller
    Local string StatStr;

    // the string that will be parsed on client for update
    StatMinutes = int((Level.TimeSeconds - EnterTimeSeconds)/60.0);
    StatStr = "?KI="$StatKills
      $"?DE="$StatDeaths
      $"?SU="$StatSuicides
      $"?MI="$StatMinutes
      $"?FS="$StatFlagsS
      $"?FR="$StatFlagsR
      $"?MP="$StatMatchesPlayed;
    // Send message to store stats
//    Log("STATS Sending update '"$StatStr$"'");
    PlayerController(Owner).ClientMessage(StatStr, 'STATS');

    SetTimer(50.0 + frand()*20, false); // Next update
}

defaultproperties
{
     RemoteRole=ROLE_None
}
