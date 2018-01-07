//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPPlayerController extends XIIIPlayerController;

var bool bImmortal;
var int matchTimestamp;
var XboxLiveManager xboxlive;
var int TimeBeforeRespawn;
var int once;

//_____________________________________________________________________________
replication
{
	reliable if( Role<ROLE_Authority )
		ChangeClass;
}

//_____________________________________________________________________________
exec function SwitchClass(int N)
{
    ChangeClass(N);
}

function ChangeClass( int N )
{
    local class<Pawn> InClass;

    InClass = class<Pawn>(DynamicLoadObject(class'MPClassList'.default.ClassListInfo[N].ClassName, class'Class'));
    if ( InClass != PawnClass )
    {
      if ( Level.Game.ChangeClass(self, InClass) )
        Pawn.Died( self, class'DTSuicided', Pawn.Location );
    }
}

//_____________________________________________________________________________
function ChangeTeam( int N )
{
    local TeamInfo OldTeam;

    OldTeam = PlayerReplicationInfo.Team;
    Level.Game.ChangeTeam(self, N);
    if ( Level.Game.bTeamGame && (PlayerReplicationInfo.Team != OldTeam) )
      Pawn.Died( self, class'DTSuicided', Pawn.Location );
}

//_____________________________________________________________________________
event PlayerTick( float DeltaTime )
{
  local Controller C;
  local Pawn P;
  local PlayerReplicationInfo PRI;
  //local PlayerController plr[16];
  //local PlayerReplicationInfo plr[16];
  local Pawn plr[16];
  local int counter,q;
    super.PlayerTick(DeltaTime);

  // SouthEnd - Test if the server went down or we got kicked. If so, go to the ingame menu which will take over automatically...
  if ( Level.GetPlateForme() == 2)
  {
    if ( xboxlive == none )
      xboxlive = New Class'XboxLiveManager';
    if (!bMenuIsActive && (xboxlive.IsServerDown() || xboxlive.IsKicked() || xboxlive.IsLoggedInTwice() || (xboxlive.IsLoggedIn(xboxLive.GetCurrentUser()) && !xboxlive.IsNetCableIn())))
    {
        ShowMenu();
    }

    // Check and update listeners (only for xbox live, only server)
    if (xboxlive.IsHost())
    {
      once--;
      if (xboxlive.IsLoggedIn(xboxLive.GetCurrentUser()) && once<=0)
      {
        once = 100;
        xboxlive.UpdateServerListeners();
      }
    }
  }
}

//_____________________________________________________________________________
// Grab the next option from a string.
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

// break up a key=value pair into its key and value.
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

// Find an option in the options string and return it.
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

function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
  local string InOpt;

  InOpt = ParseOption( Options, ParseString );
  if ( InOpt != "" )
  {
//    log(ParseString@InOpt);
    return int(InOpt);
  }
  return CurrentValue;
}

//_____________________________________________________________________________
// Called to update stats on xboxlive
function StatUpdate()
{
    local int kills, deaths, suicides, minutes, games, gameswon, flagscapt, flagsret;

//    Log("STATS StatUpdate '"$StatsMem$"'");
    kills = GetIntOption(StatsMem, "KI", 0);
    deaths = GetIntOption(StatsMem, "DE", 0);
    suicides = GetIntOption(StatsMem, "SU", 0);
    minutes = GetIntOption(StatsMem, "MI", 0);
    flagscapt = GetIntOption(StatsMem, "FS", 0);
    flagsret = GetIntOption(StatsMem, "FR", 0);
    games =  GetIntOption(StatsMem, "MP", 0);
    Log("STATS for"@self@"::");
    Log("  Kills +="@kills);
    Log("  Deaths +="@deaths);
    Log("  Suicides +="@suicides);
    Log("  Minutes +="@minutes);
    Log("  Flags Scored +="@flagscapt);
    Log("  Flags Returned +="@flagsret);
    Log("  Matches played +="@games);
    gameswon = 0; // unused/not implemented
    if ( xboxlive != none )
    {
      switch ( GameReplicationInfo.GameClass )
      {
        case "XIIIMP.XIIIMPBombGame" :
          xboxlive.SetStatisticsType(GT_Sabotage);
          break;
        case "XIIIMP.XIIIMPCTFGameInfo" :
          xboxlive.SetStatisticsType(GT_CTF);
          break;
        case "XIIIMP.XIIIMPTeamGameInfo" :
          xboxlive.SetStatisticsType(GT_TeamDM);
          break;
        case "XIIIMP.XIIIMPGameInfo" :
        default:
          xboxlive.SetStatisticsType(GT_DM);
          break;
      }
      xboxlive.StatsUpdateMyStats(kills, deaths, suicides, minutes, games, gameswon, flagscapt, flagsret);
    }
/*
      //order is important here because all team games 'extend' XIIITeamHud
      if(MyHud.IsA('XIIIMPHud') == true)
      {
        if(MyHud.IsA('XIIITeamHud') == true)
        {
          if(MyHud.IsA('XIIICTFHud') == true)
          {
            xboxlive.SetStatisticsType(GT_CTF);
            xboxlive.StatsUpdateMyStats(kills, deaths, suicides, minutes, games, gameswon, flagscapt, flagsret);
          }
          else if(MyHud.IsA('XIIIBombHud') == true)
          {
            xboxlive.SetStatisticsType(GT_Sabotage);
            xboxlive.StatsUpdateMyStats(kills, deaths, suicides, minutes, games, gameswon, flagscapt, flagsret);
          }
          else
          {
            xboxlive.SetStatisticsType(GT_TeamDM);
            xboxlive.StatsUpdateMyStats(kills, deaths, suicides, minutes, games, gameswon, flagscapt, flagsret);
          }
        }
        else
        {
          xboxlive.SetStatisticsType(GT_DM);
          xboxlive.StatsUpdateMyStats(kills, deaths, suicides, minutes, games, gameswon, flagscapt, flagsret);
        }
      }
    }
*/
}

//_____________________________________________________________________________
event ClientMessage( coerce string S, optional Name Type )
{
    if ( Type == 'STATS' )
    {
      Log("STATS update received '"$S$"'");
      StatsMem = S;
      if ( xboxlive == none )
      	xboxlive = New Class'XboxLiveManager';

      if (xboxlive.IsLoggedIn(xboxlive.GetCurrentUser()))
         xboxlive.SetShouldUpdateStats(true);

      return;
    }
    if (Type == '')
      Type = 'Event';
    TeamMessage(PlayerReplicationInfo, S, Type);
}

//_____________________________________________________________________________
function ClientGameEnded()
{
    GotoState('GameEnded');
}

//_____________________________________________________________________________
exec function Fire( optional float F )
{
  if ( Level.Pauser == PlayerReplicationInfo )
  {
    SetPause(false);
    return;
  }
  if (!bImmortal)
    Super.Fire(F);
}

//_____________________________________________________________________________
exec function AltFire( optional float F )
{
  if ( Level.Pauser == PlayerReplicationInfo )
  {
    SetPause(false);
    return;
  }
  if (!bImmortal)
    Super.AltFire(F);
}

//_____________________________________________________________________________
exec function Grab()
{
    local PowerUps PwrU;

    // No grab in multiplayer
    // then interact w/ door
    if ( MyInteraction.bCanDoor )
    {
      if ( MyInteraction.bCanUnLockDoor )
      {
        // ELR Select required item if in inventory
        PwrU = TryInteractWithDoor(MyInteraction.TargetActor);
        if ( ( bWeaponMode ) && (PwrU != none) )
        {
          cNextItem();
          XIIIPawn(Pawn).PendingItem = PwrU;
          if ( (XIIIPawn(Pawn).PendingItem != None) && (XIIIPawn(Pawn).PendingItem != Pawn.SelectedItem) )
            XIIIItems(Pawn.SelectedItem).PutDown();
        }
        else if ( (!bWeaponMode) && (PwrU != none) )
        {
          if (PwrU == Pawn.SelectedItem)
            Pawn.SelectedItem.Activate();
          else
          {
            cNextItem();
            XIIIPawn(Pawn).PendingItem = PwrU;
            if ( (XIIIPawn(Pawn).PendingItem != None) && (XIIIPawn(Pawn).PendingItem != Pawn.SelectedItem) )
              XIIIItems(Pawn.SelectedItem).PutDown();
          }
        }
        else
        {
          // ELR End Select required item if in inventory
          MyHud.LocalizedMessage(class'XIIISoloMessage', 5);
          XIIIMover(MyInteraction.TargetActor).PlayerTrigger(self, Pawn);
        }
      }
      else
      {
        XIIIMover(MyInteraction.TargetActor).PlayerTrigger(self, Pawn);
        XIIIPawn(Pawn).PlayOpenDoor();
        return;
      }
    }
    if ( bWeaponMode && (Pawn.Weapon.Default.ReloadCount > Pawn.Weapon.ReloadCount) )
    {
      ReLoad();
      return;
    }
}

//_____________________________________________________________________________
state GameEnded
{
    exec function AltFire( optional float F );
    event BeginState()
    {
        if ( Pawn.weapon != none )
        {
          Pawn.weapon.bHidden = true;
          Pawn.weapon.RefreshDisplaying();
        }
        if ( Pawn.SelectedItem != none )
          Pawn.SelectedItem.bOwnerNoSee = true;

        XIIIMPHUD( PlayerController(Pawn.Controller).MyHud).MarioBonus = 0;
        XIIIMPHUD( PlayerController(Pawn.Controller).MyHud).OldScore = XIIIPlayerReplicationInfo(PlayerReplicationInfo).MyDeathScore;
        XIIIMPHUD( PlayerController(Pawn.Controller).MyHud).UpdateBonusSound();
        XIIIMPHUD( PlayerController(Pawn.Controller).MyHud).bDrawBonusText = false;

        Pawn.SetDrawType(DT_None);
        SetTimer2(0.25,true);
        super.BeginState();
    }

    function PlayerMove(float DeltaTime)
    {
      ViewShake(DeltaTime);
      ViewFlash(DeltaTime);
    }
    function ProcessMove( float DeltaTime, vector newAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot);

    event Timer2()
    {
      if ( XIIIGameReplicationInfo(GameReplicationInfo).iGameState == 1 )
      {
        SetTimer2(0,false);
        bWeaponBlock = false;
        GotoState('PlayerWaiting' );
      }
    }
}

//_____________________________________________________________________________
state Dead
{
    ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon;

    function ServerRestartPlayer()
    {
      if ( bFrozen )
        return;
      Super.ServerRestartPlayer();
    }
    exec function AltFire( optional float F );
    exec function Fire( optional float F )
    {
      if ( !bFrozen )
        ServerReStartPlayer();
    }

    event Timer()
    {
//      Log("DEAD Timer");
      myHUD.bShowScores = true;
      bPressedJump = false;
      if ( GameReplicationInfo.GameClass == "XIIIMP.XIIIMPBombGame" )
      {
        if ( PlayerReplicationInfo.Team.TeamIndex == 0 )
          TimeBeforeRespawn = 4.0 ;
        else
          TimeBeforeRespawn = 8.0 ;
        SetTimer2(1.0,true);
      }
      else
        bFrozen = false;
    }

    event Timer2()
    {
//      Log("DEAD Timer2");
      TimeBeforeRespawn--;
      if( TimeBeforeRespawn <= 0 )
      {
        SetTimer2(0.0,false);
        bFrozen = false;
      }
    }

    function PlayerMove(float DeltaTime)
    {
      local vector X,Y,Z;
      local rotator ViewRotation;

      if ( !bFrozen )
      {
        if ( bPressedJump )
        {
  //        Fire(0);
          bPressedJump = false;
        }
        GetAxes(Rotation,X,Y,Z);
        // Update view rotation.
        ViewRotation = Rotation;
        ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
        ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
        ViewRotation.Pitch = ViewRotation.Pitch & 65535;
        If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
        {
          If (aLookUp > 0)
            ViewRotation.Pitch = 18000;
          else
            ViewRotation.Pitch = 49152;
        }
        SetRotation(ViewRotation);
        if ( Role < ROLE_Authority ) // then save this move and replicate it
          ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
      }
      ViewShake(DeltaTime);
      ViewFlash(DeltaTime);
    }

    simulated event BeginState()
    {
      local SavedMove Next;

//      Log("DEAD BeginState");
      Enemy = None;
      bBehindView = true;
      bFrozen = true;
      bPressedJump = false;
      FindGoodView();
      SetTimer(1.0, false);
      DefaultFOV = default.DefaultFOV;
      DesiredFOV = DefaultFOV;
      FOVAngle = DefaultFOV;

      // clean out saved moves
      while ( SavedMoves != None )
      {
        Next = SavedMoves.NextMove;
        SavedMoves.Destroy();
        SavedMoves = Next;
      }
      if ( PendingMove != None )
      {
        PendingMove.Destroy();
        PendingMove = None;
      }
    }

}

//_____________________________________________________________________________
//    MyInteractionClass="XIIIMP.XIIIMPBotInteraction"


defaultproperties
{
     bHasRollOff=True
     bHasPosition=True
}
