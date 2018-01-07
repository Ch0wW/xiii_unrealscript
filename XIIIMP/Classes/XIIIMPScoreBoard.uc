//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPScoreBoard extends ScoreBoard;

var localized string MapTitle, Author, Restart, sContinue, Ended, ElapsedTime, sRemainingTime, FragGoal, TimeLimit;
var localized string PlayerString, FragsString, DeathsString, PingString;
var localized string TimeString, LossString, FPHString;
var localized string sWaitingForReady;
var localized string strReady, strPressFire, strPleaseWait;
var color GreenColor, WhiteColor, GoldColor, LightCyanColor, CyanColor, RedColor, BlackColor;
var float ScoreStart;     // top allowed score start
var bool bTimeDown;
var XIIIFontInfo MyFonts;
var localized string MapTitleQuote;
var PlayerController PlayerOwner;
var localized string PreGameEndMessage,PostGameEndMessage,TieGameMessage;
var int PlayerCount;
var float LastPlayerUpdateTime;
var texture NotReadytex;
var int YP;                   // Y position on screen to keep track of the text locations
var font BigFont;            // Big system font.
var font LargeFont;            // Largest system font.
var font SmallFont;            // Small system font.
var color HudTeamColor[2],HudBasicColor;

const DBScores=false;

var MatchMakingManager myMMManager;
var int ResultCode;
var float TimeOfNextGSUpdate, TimeOfNextForcedGSUpdate;
var string LastUpdateValue;

//____________________________________________________________________
function Destroyed()
{
    Super.Destroyed();
    if ( MyFonts != None )
      MyFonts.Destroy();

    // Unregister the server from GS if required
    if ((Level.Game != none) && (XIIIMPGameInfo(Level.Game) != none) && XIIIMPGameInfo(Level.Game).bNeedToKeepGSPosted && (myMMManager != none))
    {
        myMMManager.UnregisterMyGameServer();
    }

}

//____________________________________________________________________
function PostBeginPlay()
{
    Super.PostBeginPlay();
    MyFonts = spawn(class'XIIIFontInfo');
    PlayerOwner = PlayerController(Owner);
}

//____________________________________________________________________
function DrawVictoryConditions(Canvas Canvas)
{
    local float XL, YL;

    Canvas.Font = MyFonts.GetMediumFont( fMin(Canvas.ClipX, Canvas.ClipY) );
    Canvas.StrLen("Test", XL, YL);

    Canvas.SetPos(0, YP);
    Canvas.DrawText(caps(PlayerOwner.GameReplicationInfo.GameName));
    YP += YL;

    if ( PlayerOwner.GameReplicationInfo.GoalScore > 0 )
    {
      Canvas.SetPos(0, YP);
      Canvas.DrawText(caps(FragGoal@PlayerOwner.GameReplicationInfo.GoalScore));
      YP += YL;
    }
    if ( PlayerOwner.GameReplicationInfo.TimeLimit > 0 )
    {
      Canvas.SetPos(0, YP);
      Canvas.DrawText(caps(TimeLimit@PlayerOwner.GameReplicationInfo.TimeLimit$":00"));
      YP += YL;
    }
}

//____________________________________________________________________
function string TwoDigitString(int Num)
{
    if ( Num < 10 )
      return "0"$Num;
    else
      return string(Num);
}

//____________________________________________________________________
function DrawTrailer( canvas Canvas )
{
    local XIIIGameReplicationInfo TGRI;
    local int Hours, Minutes, Seconds;
    local float XL, YL;
    local string TmpPleasWait;

    TGRI = XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo);

    Canvas.bCenter = true;
    Canvas.StrLen("999", XL, YL);
    Canvas.DrawColor = WhiteColor;
    Canvas.SetPos(0, YP - YL);

    //log("----"@TGRI.iGameState@"----");

    if (TGRI.iGameState==1)
    {
        //PlayerOwner.PlayerReplicationInfo.bReadyToPlay = true;
        if ( PlayerOwner.PlayerReplicationInfo.bReadyToPlay )
            Canvas.DrawText(strReady, true);
        else
            Canvas.DrawText(strPressFire, true);
    }
    else if (TGRI.iGameState==2)
    {
      bTimeDown = true;

        if ( TGRI.XIIIRemainingTime > 0 )
        {
            Minutes = TGRI.XIIIRemainingTime/60;
            Seconds = TGRI.XIIIRemainingTime % 60;
//            Canvas.DrawText(sRemainingTime@TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
            Canvas.DrawText(TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);

            if( ( OwnerHUD.HelpDisplay ) && ( !PlayerOwner.bFrozen ) )
            {
                Canvas.SetPos(0, YP - 2*YL);
                Canvas.DrawText(strPressFire, true);
            }
            else if( ( OwnerHUD.HelpDisplay ) && ( PlayerOwner.bFrozen ) )
            {
                TmpPleasWait = strPleaseWait@"..."@XIIIMPPlayerController(PlayerOwner).TimeBeforeRespawn;
                Canvas.SetPos(0, YP - 2*YL);
                Canvas.DrawText( TmpPleasWait, true);
            }
        }
        else
        {
            if( ( OwnerHUD.HelpDisplay ) && ( !PlayerOwner.bFrozen ) )
            {
                Canvas.SetPos(0, YP - YL);
                Canvas.DrawText(strPressFire, true);
            }
            else if( ( OwnerHUD.HelpDisplay ) && ( PlayerOwner.bFrozen ) )
            {
                TmpPleasWait = strPleaseWait@"..."@XIIIMPPlayerController(PlayerOwner).TimeBeforeRespawn;
                Canvas.SetPos(0, YP - 2*YL);
                Canvas.DrawText( TmpPleasWait, true);
            }
        }
    }
    else if( TGRI.iGameState != 3 )
    {
        Seconds = PlayerOwner.GameReplicationInfo.ElapsedTime;
        Minutes = Seconds / 60;
        Hours   = Minutes / 60;
        Seconds = Seconds - (Minutes * 60);
        Minutes = Minutes - (Hours * 60);
//        Canvas.DrawText(ElapsedTime@TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
        Canvas.DrawText(TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);

        if( ( OwnerHUD.HelpDisplay ) && ( !PlayerOwner.bFrozen ) )
        {
            Canvas.SetPos(0, YP - 2*YL);
            Canvas.DrawText(strPressFire, true);
        }
    }

    if (TGRI.iGameState==3)
    {
        Canvas.bCenter = true;
        //Canvas.StrLen("Test", XL, YL);
        Canvas.SetPos(0, YP - YL);
        //Canvas.SetPos(0, Canvas.ClipY - Min(YL*6, Canvas.ClipY * 0.1));
        //Canvas.DrawColor = GreenColor;
        Canvas.DrawText(Ended, true);
    }

    Canvas.bCenter = false;
}

//____________________________________________________________________
function DrawInfoLine(Canvas C, string Info1, string Info2, string Info3, color LineColor, color BgColor , bool AddBg, int ViewPortNumber, optional bool bDrawReadyToPlay, optional bool bNotReadyToPlay )
{
    local float W,H; //, IconSize;
    local int XP;

    if( ViewPortNumber == 1 )
      C.Font = BigFont;
    else
      C.Font = SmallFont;
    C.SpaceX = 1;
    C.StrLen(Info1, W, H);

//    IconSize = (H+4) / (ReadyTex.VSize/2.0);

    XP = C.CLipX*0.15;

    // BackGround Icon + Text
    C.bUseBorder = false;
    C.Style = ERenderStyle.STY_Alpha;
    C.DrawColor = BgColor*0.3;
    C.DrawColor.A = 90;
    C.SetPos(XP,YP);
    OwnerHud.DrawStdBackGround(C, H-4, C.CLipX*0.7 - 2*(H-4));
    if( AddBg )
    {
      C.Style = ERenderStyle.STY_Translucent;
      C.DrawColor = BgColor;
      C.DrawColor.A = 200;
      C.SetPos(XP,YP);
      OwnerHud.DrawStdBackGround(C, H-4, C.CLipX*0.7 - 2*(H-4));
    }

//    Log(Info1@"Ready ?"@!bNotReadyToPlay@"GRI State="$XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo).iGameState);
    // Player Ready ?
    if ( (Level.NetMode != NM_StandAlone) && bDrawReadyToPlay && XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo).iGameState != 2 )
    {
      C.Style = ERenderStyle.STY_Alpha;
      if ( bNotReadyToPlay )
        C.DrawColor = WhiteColor * 0.5;
      else
        C.DrawColor = GoldColor;
      C.SetPos(XP-H/4,YP-3);
      C.DrawIcon(NotReadyTex, (H+3)/NotReadyTex.VSize);
      bDrawReadyToPlay = true;
    }
    else
      bDrawReadyToPlay = false;

    // Text
    C.Style = ERenderStyle.STY_Normal;

    C.DrawColor = BgColor*0.3;
    C.SetPos(XP+H+4+1,YP-1);
    C.DrawText(Info1, false);

    C.DrawColor = LineColor;
    C.SetPos(XP+H+4,YP-2);
    C.DrawText(Info1, false);

    C.StrLen(Info2, W, H);

    C.DrawColor = BgColor*0.3;
    C.SetPos(C.ClipX*0.58 + 1 - W/2,YP-1);
    C.DrawText(Info2, false);

    C.DrawColor = LineColor;
    C.SetPos(C.ClipX*0.58 - W/2,YP-2);
    C.DrawText(Info2, false);

    C.StrLen(Info3, W, H);

    C.DrawColor = BgColor*0.3;
    C.SetPos(C.ClipX*0.75 + 1 - W/2,YP-1);
    C.DrawText(Info3, false);

    C.DrawColor = LineColor;
    C.SetPos(C.ClipX*0.75 - W/2,YP-2);
    C.DrawText(Info3, false);

    YP += H;

    C.SpaceX = 0;
}

//____________________________________________________________________
simulated function SortScores(int N)
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

//____________________________________________________________________
simulated function UpdatePlayerList()
{
    local int i;
    local PlayerReplicationInfo PRI;

    // infrequent checks (every 0.5 seconds) since AllActors is expensive

    if ( Level.TimeSeconds - LastPlayerUpdateTime < 0.5 )
      return;
    LastPlayerUpdateTime = Level.TimeSeconds;

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

    if ((Level.TimeSeconds > TimeOfNextGSUpdate) && (Level.Game != none) && (XIIIMPGameInfo(Level.Game) != none) && XIIIMPGameInfo(Level.Game).bNeedToKeepGSPosted)
    {
      TimeOfNextGSUpdate = Level.TimeSeconds + 10.0;
      GotoState('KeepGSposted');
    }
}

//____________________________________________________________________
function ShowScores( Canvas C , int ViewPortId , int PlayerNumber )
{
    local color BgColor;
    local int Loop;
    local string PName,PFrag,PDeath;
    local bool IsMe;
    local XIIIGameReplicationInfo TGRI;

    if ( PlayerOwner.GameReplicationInfo == none )
      return;

    TGRI = XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo);
    UpdatePlayerList();

    GetUpMargin( C , ViewPortId , PlayerNumber );
    if( (TGRI.iGameState==1) && ( Level.NetMode == NM_Standalone ) )
    {
      if( PlayerNumber == 1 )
        C.Font = BigFont;
      else
        C.Font = SmallFont;

      GetDownMargin( C , ViewPortId , PlayerNumber );
      DrawTrailer(C);
      return;
    }

    // Header
    DrawInfoLine( C,PlayerString,FragsString,DeathsString,HudBasicColor,HudBasicColor,false,PlayerNumber );
    YP += 8;

    //Players ...
    for ( Loop=0; Loop<PlayerCount; Loop++ )
    {
      IsMe = ( Ordered[Loop] == PlayerOwner.PlayerReplicationInfo );
      PName = Ordered[Loop].PlayerName;
      PFrag = string( int(Ordered[Loop].Score));
      PDeath = string( int(Ordered[Loop].Deaths));
      DrawInfoLine( C, PName,PFrag,PDeath,HudBasicColor,HudBasicColor,IsMe,PlayerNumber, Ordered[Loop].bWaitingPlayer, !Ordered[Loop].bReadyToPlay );
    }

    // Trail
    GetDownMargin( C , ViewPortId , PlayerNumber );
    DrawTrailer(C);
}

//____________________________________________________________________
function GetDownMargin( Canvas C , int ViewPortId , int PlayerNumber )
{
    YP = C.ClipY*0.85; // default Value

    if( ViewPortId != -1 )
    {
        if( PlayerNumber == 2 )
        {
            if( ViewPortId == 0 )
                YP = C.ClipY*0.95;
            else
                YP = C.ClipY*0.85;
        }
        else
        {
            if( ( ViewPortId == 0 ) || ( ViewPortId == 1 ) )
                YP = C.ClipY*0.95;
            else
                YP = C.ClipY*0.85;
        }
    }

    if( ( Level.NetMode != NM_Standalone ) || ( ( ViewPortId == 0 ) && ( PlayerNumber == 1 ) ) )
        YP = C.ClipY*0.90;
}

//____________________________________________________________________
function GetUpMargin( Canvas C , int ViewPortId , int PlayerNumber )
{
    YP = C.ClipY*0.15; // default Value

    if( ViewPortId != -1 )
    {
        if( PlayerNumber == 2 )
        {
            if( ViewPortId == 0 )
                YP = C.ClipY*0.15;
            else
                YP = C.ClipY*0.05;
        }
        else
        {
            if( ( ViewPortId == 0 ) || ( ViewPortId == 1 ) )
                YP = C.ClipY*0.15;
            else
                YP = C.ClipY*0.05;
        }
    }
}

//____________________________________________________________________
simulated function UpdateScores()
{
    if ( DBScores ) Log("MP-] UpdateScores for "$self);
    UpdatePlayerList();
}

//____________________________________________________________________
function bool BuildPlayerListWithScore()
{
    local string Result;
    local int Loop;

    for ( Loop=0; Loop<PlayerCount; Loop++ )
    {
        if (Loop > 0)
            Result = Result$"?";
        Result = Result$Ordered[Loop].PlayerName$"="$int(Ordered[Loop].Score);
    }

    if (LastUpdateValue == Result)
    {
        if (Level.TimeSeconds >= TimeOfNextForcedGSUpdate)
        {
            TimeOfNextForcedGSUpdate = Level.TimeSeconds + 29.0;
            return true;
        }
        else
            return false;
    }
    else
    {
        LastUpdateValue = Result;
        TimeOfNextForcedGSUpdate = Level.TimeSeconds + 29.0;
        return true;
    }
}


//____________________________________________________________________
State KeepGSposted
{
begin:
    if (myMMManager == none)
	    myMMManager = new(none) class'MatchMakingManager';

    if (BuildPlayerListWithScore())
    {
        //log("Sending "$LastUpdateValue$" to GS");
        myMMManager.UpdateMyGameServer(-1, -1, "", ""/*info*/, LastUpdateValue/*AdditionalInfo*/, -1);
        while ( !myMMManager.IsMyGameServerUpdated(ResultCode) )
        {
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
    GotoState('');
}



//____________________________________________________________________
//    NotReadyTex=texture'XIIIMenu.Mul_moinsdevie'


defaultproperties
{
     MapTitle="in"
     Author="by"
     Restart="You are dead.  Hit [Fire] to respawn!"
     sContinue=" Hit [Fire] to continue!"
     Ended="The match has ended."
     ElapsedTime="Elapsed Time: "
     sRemainingTime="Remaining Time: "
     FragGoal="Frag Limit:"
     TimeLimit="Time Limit:"
     PlayerString="Player"
     FragsString="Frag(s)"
     DeathsString="Death(s)"
     PingString="Ping"
     TimeString="Time"
     LossString="Loss"
     FPHString="FPH"
     sWaitingForReady="Waiting for players to be ready"
     strReady="Ready"
     strPressFire="Press Fire to begin"
     strPleaseWait="Please Wait"
     GreenColor=(G=255,A=255)
     WhiteColor=(B=255,G=255,R=255,A=255)
     GoldColor=(G=210,R=240,A=255)
     LightCyanColor=(B=255,G=255,R=128,A=255)
     CyanColor=(B=255,G=128,A=255)
     RedColor=(R=255,A=255)
     BlackColor=(A=255)
     PostGameEndMessage=" wins the round!"
     TieGameMessage="Round ends with no winner."
     LastPlayerUpdateTime=-1.000000
     NotReadytex=Texture'XIIICine.effets.impactpoing2A'
     BigFont=Font'XIIIFonts.PoliceF16'
     LargeFont=Font'XIIIFonts.PoliceF20'
     SmallFont=Font'XIIIFonts.XIIIConsoleFont'
     HudTeamColor(0)=(R=200,A=255)
     HudTeamColor(1)=(B=255,G=159,R=64,A=255)
     HudBasicColor=(B=210,G=252,R=255,A=230)
}
