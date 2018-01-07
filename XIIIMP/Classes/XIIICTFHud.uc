//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIICTFHud extends XIIITeamHud;

var texture texFlagFree, texFlagHold, texFlagDropped;
var int FlagState[2];
var sound sndFlagHold, sndFlagReturn, sndFlagDropped, sndFlagScored;
var texture FlagTex[2];

//____________________________________________________________________
// ELR
simulated event PostRender( canvas C )
{
    if ( (PlayerOwner == none) || (PlayerOwner.GameReplicationInfo == none) )
    {
      DrawWaitForMPInit(C);
      return; // wait for game initialization/replications
    }

//    Log("PR SND 0="$XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo).SoundFlagState0@"SND 1="$XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo).SoundFlagState1);
    if ( FlagState[0] != XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo).SoundFlagState0 )
    {
      FlagState[0] = XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo).SoundFlagState0;
      switch ( FlagState[0] )
      {
        Case -1: // Start/Restart game, don't play any sound
          FlagTex[0] = texFlagFree;
          Log("MP-] FLAG 0 Restart");
          break;
        case 1:
          FlagTex[0] = texFlagFree;
          PlayerOwner.PlayMenu( sndFlagReturn );
          Log("MP-] FLAG 0 Returned");
          break;
        case 2:
          FlagTex[0] = texFlagDropped;
          PlayerOwner.PlayMenu( sndFlagDropped );
          Log("MP-] FLAG 0 Dropped");
          break;
        Case 3:
          FlagTex[0] = texFlagFree;
          PlayerOwner.PlayMenu( sndFlagScored );
          Log("MP-] FLAG 0 Score");
          break;
        Case 4:
          FlagTex[0] = texFlagHold;
          PlayerOwner.PlayMenu( sndFlagHold );
          Log("MP-] FLAG 0 Held");
          break;

      }
    }
    if ( FlagState[1] != XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo).SoundFlagState1 )
    {
      FlagState[1] = XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo).SoundFlagState1;
      switch ( FlagState[1] )
      {
        case -1: // Start/Restart game, don't play any sound
          FlagTex[1] = texFlagFree;
          Log("MP-] FLAG 1 Restart");
          break;
        Case 1:
          FlagTex[1] = texFlagFree;
          PlayerOwner.PlayMenu( sndFlagReturn );
          Log("MP-] FLAG 1 Returned");
          break;
        Case 2:
          FlagTex[1] = texFlagDropped;
          PlayerOwner.PlayMenu( sndFlagDropped );
          Log("MP-] FLAG 1 Dropped");
          break;
        Case 3:
          FlagTex[1] = texFlagFree;
          PlayerOwner.PlayMenu( sndFlagScored );
          Log("MP-] FLAG 1 Score");
          break;
        Case 4:
          FlagTex[1] = texFlagHold;
          PlayerOwner.PlayMenu( sndFlagHold );
          Log("MP-] FLAG 1 Held");
          break;
      }
    }

    Super.PostRender(C);
}

//____________________________________________________________________
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

    C.bUseBorder = false;
    C.Style = ERenderStyle.STY_Alpha;

    // background team 0

    C.DrawColor = TeamColor[0];
    C.DrawColor.A = 200;
    C.SetPos( XP, YP);
    C.DrawRect(RoundBackGroundTex, ScoreHeight,ScoreHeight);
    C.DrawRect(FondMsg, ScoreWidth +ScoreHeight + 4,ScoreHeight);

    // background team 1

    C.DrawColor = TeamColor[1];
    C.DrawColor.A = 200;
    C.SetPos( XP + ScoreHeight +ScoreWidth+4+ScoreHeight+4 , YP);
    C.DrawRect(FondMsg, ScoreWidth +ScoreHeight + 4,ScoreHeight);
    C.DrawTile(RoundBackGroundTex, ScoreHeight,ScoreHeight, 0, 0, -RoundBackGroundTex.USize, RoundBackGroundTex.VSize);

    C.bTextShadow = true;

    // Info Team 0
    C.StrLen(strScore[0], W, H );

    C.DrawColor = HudBasicColor;
    C.DrawColor.A = 255;
    C.SetPos( XP + ScoreHeight + ScoreWidth/2- W/2, YP-1);
    C.DrawText(strScore[0], false);

/*
    Flag = XIIIMPFlag(PlayerOwner.GameReplicationInfo.Teams[0].Flag);

    if ( Flag.bHome )
    {
        TmpTexFlag = texFlagFree;

        if( FlagState[0] == 4 )
        {
            FlagState[0] = 0;
            PlayerOwner.PlayMenu( sndFlagScored );
        }
        else if( FlagState[0] == 2 )
        {
            FlagState[0] = 0;
            PlayerOwner.PlayMenu( sndFlagReturn );
        }
    }
    else if ( Flag.bHeld )
    {
        TmpTexFlag = texFlagHold;

        if( ( FlagState[0] == 0 ) || ( FlagState[0] == 2 ) )
        {
            FlagState[0] = 4;
            PlayerOwner.PlayMenu( sndFlagHold );
        }
    }
    else
    {
        TmpTexFlag = texFlagDropped;

        if( FlagState[0] == 4 )
        {
            FlagState[0] = 2;
            PlayerOwner.PlayMenu( sndFlagDropped );
        }
    }
*/


    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255;
    C.SetPos( XP + ScoreHeight + ScoreWidth, YP-1);
    C.DrawTile(FlagTex[0], ScoreHeight,ScoreHeight, 0, 0, FlagTex[0].USize, FlagTex[0].VSize);

    // Info Team 1

/*
    Flag = XIIIMPFlag(PlayerOwner.GameReplicationInfo.Teams[1].Flag);

    if ( Flag.bHome )
        TmpTexFlag = texFlagFree;
    else if ( Flag.bHeld )
        TmpTexFlag = texFlagHold;
    else
        TmpTexFlag = texFlagDropped;


    if ( Flag.bHome )
    {
        TmpTexFlag = texFlagFree;

        if( FlagState[1] == 4 )
        {
            FlagState[1] = 0;
            PlayerOwner.PlayMenu( sndFlagScored );
        }
        else if( FlagState[1] == 2 )
        {
            FlagState[1] = 0;
            PlayerOwner.PlayMenu( sndFlagReturn );
        }
    }
    else if ( Flag.bHeld )
    {
        TmpTexFlag = texFlagHold;

        if( ( FlagState[1] == 0 ) || ( FlagState[1] == 2 ) )
        {
            FlagState[1] = 4;
            PlayerOwner.PlayMenu( sndFlagHold );
        }
    }
    else
    {
        TmpTexFlag = texFlagDropped;

        if( FlagState[1] == 4 )
        {
            FlagState[1] = 2;
            PlayerOwner.PlayMenu( sndFlagDropped );
        }
    }
*/


    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255;
//    C.SetPos( XP + ScoreHeight +ScoreWidth+4+ScoreHeight+4+4, YP-1);
    C.SetPos( XP + ScoreHeight*2+ScoreWidth+12, YP-1);
    C.DrawTile(FlagTex[1], ScoreHeight,ScoreHeight, 0, 0, FlagTex[1].USize, FlagTex[1].VSize);

    C.StrLen(strScore[1], W, H );
    C.DrawColor = HudBasicColor;
    C.DrawColor.A = 255;
//    C.SetPos( XP + ScoreHeight +ScoreWidth+4+ScoreHeight+4+    ScoreWidth +ScoreHeight + 4 - ScoreWidth/2- W/2, YP-1);
    C.SetPos( XP + ScoreHeight*3 +ScoreWidth*1.5 +12 -W/2, YP-1);
    C.DrawText(strScore[1], false);

    C.bTextShadow = false;

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



defaultproperties
{
     texFlagFree=Texture'XIIIMenu.HUD.mul_flagsimple'
     texFlagHold=Texture'XIIIMenu.HUD.mul_flagpris'
     texFlagDropped=Texture'XIIIMenu.HUD.mul_flaglost'
     FlagState(0)=3
     FlagState(1)=3
     sndFlagHold=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hFlagToken'
     sndFlagReturn=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hFlagBack'
     sndFlagDropped=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hFlagDrop'
     sndFlagScored=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hScoreFlag'
     FlagTex(0)=Texture'XIIIMenu.HUD.mul_flagsimple'
     FlagTex(1)=Texture'XIIIMenu.HUD.mul_flagsimple'
}
