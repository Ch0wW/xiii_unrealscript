//=============================================================================
// PlayerReplicationInfo.
//=============================================================================
class PlayerReplicationInfo extends ReplicationInfo
  native nativereplication;

// also replicate here player class and skins and any other seldom changed stuff
var float Score;          // Player's current score.
var float OldScore;       // Player's Old score (to handle event ScoreUpdated)
var float Deaths;         // Number of player's deaths.
var Decoration   HasFlag;
var int Ping;
var Volume PlayerLocation;
var int NumLives;

var string PlayerName;    // Player name, or blank if none.
var string OldName, PreviousName;    // Temporary value.
var string OldSkinCodeName, SkinCodeName;
var int PlayerID;         // Unique id number.
var TeamInfo Team;        // Player Team
var int TeamID;           // Player position in team.
var class<VoicePack> VoiceType;
var bool bIsFemale;
var bool bFeigningDeath;
var bool bIsSpectator;
var bool bWaitingPlayer;
var bool bReadyToPlay;
var bool bOutOfLives;
var bool bBot;
var Texture TalkTexture;

// Time elapsed.
var int StartTime;
var int TimeAcc;

replication
{
  // Things the server should send to the client.
  reliable if ( bNetDirty && (Role == Role_Authority) )
    Score, Deaths, HasFlag, Ping, PlayerLocation,
    PlayerName, Team, TeamID, VoiceType, bIsFemale,
    bFeigningDeath, bIsSpectator, bWaitingPlayer, bReadyToPlay, TalkTexture,
    bOutOfLives;

  reliable if ( Role == Role_Authority )
    SkinCodeName;

  reliable if ( bNetInitial && (Role == Role_Authority) )
    StartTime, bBot;
}

function PostBeginPlay()
{
  StartTime = Level.TimeSeconds;
  Timer();
  SetTimer(2.0, true);
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
  Super.Reset();
  Score = 0;
  Deaths = 0;
  HasFlag = None;
  bReadyToPlay = false;
  NumLives = 0;
  bOutOfLives = false;
}

simulated function string GetLocationName()
{
  if ( PlayerLocation != None )
    return PlayerLocation.LocationName;
  else
    return"";
}

simulated function string GetHumanReadableName()
{
  return PlayerName;
}

function UpdatePlayerLocation()
{
  local Volume V;

  PlayerLocation = None;
  ForEach TouchingActors(class'Volume',V)
    if ( (V.LocationName != "")
      && ((PlayerLocation == None) || (V.LocationPriority > PlayerLocation.LocationPriority))
      && V.Encompasses(self) )
    {
      PlayerLocation = V;
    }
}

/* DisplayDebug()
list important controller attributes on canvas
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
  Canvas.DrawText("     PlayerName "$PlayerName$" Team "$Team);
}

function Timer()
{
  UpdatePlayerLocation();

  if ( FRand() < 0.65 )
    return;

  if (PlayerController(Owner) != None)
    Ping = int(Controller(Owner).ConsoleCommand("GETPING"));
}

function SetPlayerName(string S)
{
  OldName = PlayerName;
  PlayerName = S;
}

function SetWaitingPlayer(bool B)
{
  bIsSpectator = B;
  bWaitingPlayer = B;
}


debugonly simulated function DumpContent(float TimeStamp, int tabulation)
{
    local int j;
    local string Tab;

    for (j=0; j<tabulation; j++) Tab = Tab$" ";

    log(Tab$"PlayerReplicationInfo's dump at "$TimeStamp$":");
    //log(Tab$"  Score:"$Score$" Deaths:"$Deaths$" HasFlag:"$HasFlag$" Ping:"$Ping$" PlayerLocation:"$PlayerLocation$" NumLives:"$NumLives);
        log(Tab$"  Ping:"$Ping);
    //log(Tab$"  PlayerName:"$PlayerName$" OldName:"$OldName$" PreviousName:"$PreviousName$" PlayerID:"$PlayerID$" Team:"$Team$" TeamID:"$TeamID$" VoiceType:"$VoiceType);
        log(Tab$"  PlayerID:"$PlayerID);
    //log(Tab$"  bIsFemale:"$bIsFemale$" bFeigningDeath:"$bFeigningDeath$" bIsSpectator:"$bIsSpectator$" bWaitingPlayer:"$bWaitingPlayer$" bReadyToPlay:"$bReadyToPlay$" bOutOfLives:"$bOutOfLives);
    //log(Tab$"  bBot:"$bBot$" TalkTexture:"$TalkTexture$" StartTime:"$StartTime$" TimeAcc:"$TimeAcc);
    //Super.DumpContent(TimeStamp, tabulation);
}

simulated event ScoreUpdated(); // ELR Used to update score sorting only when receiving score replication
simulated event SkinUpdated();  // ELR Used to update skin only when receiving SkinCodeName replication

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
}
