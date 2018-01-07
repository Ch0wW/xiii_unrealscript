//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIITeamHud extends XIIIMPHud;

function PlayerNameDisplay(Canvas C)
{
    local float W,H ;
    local string strScore[2], strFlagState[2];
    local int Score[2], PlayerId;
    local XIIIMPFlag Flag;
	local Controller Ctrl;
	local bool MP,SameTeam;
	local int TempTeamID;

    UseHugeFont(C);
    C.SpaceX = 0;
    if( ! bInit )
    {
      bInit = true;
      C.StrLen("999", ScoreWidth, ScoreHeight );
      ScoreHeight -= 4;
      ScoreWidth += 4;
      if ( (Level.NetMode != NM_Standalone) || (Level.bLonePlayer) )
        bSplitt = false;
      else
        bSplitt = true;


    TempTeamID = -1;

    for ( Ctrl=Level.ControllerList; Ctrl!=None; Ctrl= Ctrl.NextController )
    {
        if( XIIIMPPlayerController(Ctrl) != none )
        {
            MP = true;
            SameTeam = true;

            if( TempTeamID == -1 )
                TempTeamID = Ctrl.PlayerReplicationInfo.Team.TeamIndex;
            else if(  TempTeamID != Ctrl.PlayerReplicationInfo.Team.TeamIndex )
            {
                SameTeam = false;
                break;
            }
        }
    }

    if( MP && SameTeam )
        bSplitt = false;

      Scoring.UpdateScores();
    }

    PlayerId = PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;
    Score[0] = PlayerOwner.GameReplicationInfo.Teams[ 0 ].Score;
    strScore[0] = string( Score[0] );
    Score[1] = PlayerOwner.GameReplicationInfo.Teams[ 1 ].Score;
    strScore[1] = string( Score[1] );

    if (PlayerOwner.GameReplicationInfo.GameClass ~= "XIIIMP.XIIIMPCTFGameInfo")
    {
      Flag = XIIIMPFlag(PlayerOwner.GameReplicationInfo.Teams[0].Flag);
      if ( Flag.bHome )
        strFlagState[0] = "";
      else if ( Flag.bHeld )
        strFlagState[0] = "X";
      else
        strFlagState[0] = "?";
      Flag = XIIIMPFlag(PlayerOwner.GameReplicationInfo.Teams[1].Flag);
      if ( Flag.bHome )
        strFlagState[1] = "";
      else if ( Flag.bHeld )
        strFlagState[1] = "X";
      else
        strFlagState[1] = "?";
    }

    C.bUseBorder = false;
    C.Style = ERenderStyle.STY_Alpha;

    if( false )
//    if( bSplitt )
    { // if splitted screen, draw only local self team info
      C.DrawColor = TeamColor[PlayerId];
      C.DrawColor.A = 200;
      C.SetPos( XP, YP);
      DrawStdBackground(C, ScoreHeight, ScoreWidth);

      C.StrLen(strScore[PlayerId], W, H );

      C.DrawColor = TeamColor[PlayerId]*0.1;
      C.DrawColor.A = 90;
      C.SetPos( XP + ScoreHeight + ScoreWidth/2- W/2+2 , YP+1 );
      C.DrawText(strScore[PlayerId], false);

      C.DrawColor = HudBasicColor;
      C.DrawColor.A = 255;
      C.SetPos( XP + ScoreHeight + ScoreWidth/2- W/2, YP-1);
      C.DrawText(strScore[PlayerId], false);

      if (PlayerOwner.GameReplicationInfo.GameClass ~= "XIIIMP.XIIIMPCTFGameInfo")
      {
        C.StrLen(strFlagState[PlayerId], W, H );
        C.bTextShadow = true;
        C.DrawColor = HudBasicColor;
        C.DrawColor.A = 255;
        C.SetPos( XP + ScoreHeight/2.0- W/2, YP-1);
        C.DrawText(strFlagState[PlayerId], false);
      }
    }
    else
    { // no splitted screen, show info for the two teams
      // background team 0
      C.DrawColor = TeamColor[0];
      C.DrawColor.A = 200;
      C.SetPos( XP, YP);
      C.DrawRect(RoundBackGroundTex, ScoreHeight,ScoreHeight);
      C.DrawRect(FondMsg, ScoreWidth,ScoreHeight);

      // background team 1
      C.DrawColor = TeamColor[1];
      C.DrawColor.A = 200;
      C.SetPos( XP + ScoreHeight +ScoreWidth+4 , YP);
      C.DrawRect(FondMsg, ScoreWidth,ScoreHeight);
      C.DrawTile(RoundBackGroundTex, ScoreHeight,ScoreHeight, 0, 0, -RoundBackGroundTex.USize, RoundBackGroundTex.VSize);

      C.bTextShadow = true;
      // Info Team 0
      C.StrLen(strScore[0], W, H );
      C.DrawColor = HudBasicColor;
      C.DrawColor.A = 255;
      C.SetPos( XP + ScoreHeight + ScoreWidth/2- W/2-2, YP-1);
      C.DrawText(strScore[0], false);

      if (PlayerOwner.GameReplicationInfo.GameClass ~= "XIIIMP.XIIIMPCTFGameInfo")
      {
        C.StrLen(strFlagState[0], W, H );
        C.DrawColor = HudBasicColor;
        C.DrawColor.A = 255;
        C.SetPos( XP + ScoreHeight/2.0- W/2-2, YP-1);
        C.DrawText(strFlagState[0], false);
      }

      // Info Team 1
      C.StrLen(strScore[1], W, H );
      C.DrawColor = HudBasicColor;
      C.DrawColor.A = 255;
      C.SetPos( XP + ScoreHeight + ScoreWidth+4 + ScoreWidth/2- W/2 +4 -2, YP-1);
      C.DrawText(strScore[1], false);

      if (PlayerOwner.GameReplicationInfo.GameClass ~= "XIIIMP.XIIIMPCTFGameInfo")
      {
        C.StrLen(strFlagState[1], W, H );
        C.DrawColor = HudBasicColor;
        C.DrawColor.A = 255;
        C.SetPos( XP + ScoreHeight*1.5 + ScoreWidth+4 + ScoreWidth- W/2 +4 -2, YP-1);
        C.DrawText(strFlagState[1], false);
      }
      C.bTextShadow = false;
    }

    if( OldScore != XIIIPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).MyDeathScore )
    {
        FragCount=XIIIPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).MyDeathScore-OldScore;

        if( FragCount > 0 )
        {
            SetTimer2( 2.0, true );
            PlayerOwner.PlayMenu( SndFrag );
            LastFragTime=Level.TimeSeconds;
        }
        else
            FragCount = 0;
    }

    OldScore = XIIIPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).MyDeathScore;

    if( FragCount != 0 )
        DrawFrag(C);

    MarioBonusDisplay(C);
}

//____________________________________________________________________
// ELR Draw HUD
function DrawHUD( canvas C )
{
//    Log("TEAMHUD DrawHud PlayerOwner="$PlayerOwner@"GRI="$PlayerOwner.GameReplicationInfo);
    if ( (PlayerOwner == none) || (PlayerOwner.GameReplicationInfo == none) )
      return; // wait for game initialization/replications

/* // ELR Useless multiple calls
    HUDSetup( C );

    // ELR Do show scores if needed.
    if ( XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo).iGameState != 2 )
    {
      if ( Scoring != None )
      {
        Scoring.OwnerHUD = self;
        if ( (Level.Game == none) || (Level.NetMode != NM_StandAlone) )
          Scoring.ShowScores(C, ViewPortId, 1);
        else
          Scoring.ShowScores(C, ViewPortId, Level.Game.NumPlayers);
        DrawViewPortSeparator(C);
        return;
      }
    }
*/

    HudBackGroundColor = TeamColor[PlayerOwner.PlayerReplicationInfo.Team.TeamIndex];
    HudBackGroundColor.A = 200;

    Super.DrawHud(C);
}

//____________________________________________________________________
simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional string CriticalString )
{
    if( ( Level.NetMode == NM_StandAlone) && ( ( Level.Game == none ) || ( Level.Game.NumPlayers > 2 ) ) )
    {
      if( ( ( Message == class'XIIIDeathMessage' ) || ( Message == Class'XIIIMPBlueDeathMessage' ) ) || ( Message == class'XIIIMPRedDeathMessage' ) )
        return;
    }

    if ( Message == class'XIIIEndGameMessage' )
    {
      AddHudEndMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
      bHideHud = true;
    }
    else if( ( ( ( ( ( Message == class'XIIIDeathMessage' ) || ( Message == class'XIIIMPCTFMessage') ) || ( Message == class'XIIIMultiMessage' ) ) || ( Message == class'XIIIMPDuckMessage' ) ) || ( Message == Class'XIIIMPBlueDeathMessage' ) ) || ( Message == class'XIIIMPRedDeathMessage' ) )
      AddHudMPMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
    else
      AddHudMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
}



defaultproperties
{
}
