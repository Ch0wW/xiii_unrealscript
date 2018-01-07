//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPTeamScoreBoard extends XIIIMPScoreBoard;

var color TeamColor[2];
var texture PlayerTex;          // Icon for drawing waiting player

//____________________________________________________________________
simulated function SortScores(int N)
{
    local int i, j, Max, ts,tsmax;
    local PlayerReplicationInfo TempPRI;
    local XIIIGameReplicationInfo TGRI;

    TGRI = XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo);

    for ( i=0; i<N-1; i++ )
    {
      Max = i;
      for ( j=i+1; j<N; j++ )
      {
        ts = TGRI.Teams[Ordered[j].Team.TeamIndex].Score;
        tsmax = TGRI.Teams[Ordered[Max].Team.TeamIndex].Score;
        if ( ts > tsmax )
          Max = j;
        else if (( ts == tsmax )
          && ( Ordered[j].Team.TeamIndex < Ordered[Max].Team.TeamIndex ))
          Max = j;
        else if (( ts == tsmax )
          && ( Ordered[j].Team == Ordered[Max].Team )
          && ( Ordered[j].Score > Ordered[Max].Score ))
          Max = j;
        else if (( ts == tsmax )
          && ( Ordered[j].Team == Ordered[Max].Team )
          && (Ordered[j].Score == Ordered[Max].Score)
          && (Ordered[j].Deaths < Ordered[Max].Deaths))
          Max = j;
        else if (( ts == tsmax )
          && ( Ordered[j].Team == Ordered[Max].Team )
          && (Ordered[j].Score == Ordered[Max].Score)
          && (Ordered[j].Deaths == Ordered[Max].Deaths)
          && (Ordered[j].PlayerID < Ordered[Max].Score))
          Max = j;
      }
      TempPRI = Ordered[Max];
      Ordered[Max] = Ordered[i];
      Ordered[i] = TempPRI;
    }
}

//____________________________________________________________________
function DrawTeamScore( Canvas C )
{
    local float W,H, w2;
    local int XP, Loop;
    local string score;

    C.Font = BigFont;
    C.SpaceX = 1;
    YP += 4;

    C.StrLen(100, W, H);

    for( Loop=0;Loop< 2; Loop++ )
    {
        if( Loop == 0)
            XP = C.CLipX/2 - W - 2*(H-4) -2;
        else
            XP = C.CLipX/2 +2;

        // BackGround Icon + Text

        C.bUseBorder = false;
        C.Style = ERenderStyle.STY_Alpha;
        C.DrawColor = TeamColor[Loop]*0.3;
        C.DrawColor.A = 90;

        C.SetPos(XP,YP);
        OwnerHud.DrawStdBackGround(C, H-4, W);

        C.Style = ERenderStyle.STY_Translucent;

        C.DrawColor = Teamcolor[Loop];
        C.DrawColor.A = 200;

        C.SetPos(XP,YP);
        OwnerHud.DrawStdBackGround(C, H-4, W);

        // Text
        score = string( int( OwnerHUD.PlayerOwner.GameReplicationInfo.Teams[loop].Score ) );
//        score = string( int( HUD(Owner).PlayerOwner.GameReplicationInfo.Teams[loop].Score ) );
        C.StrLen(score, W2, H);

        C.Style=ERenderStyle.STY_Normal;

        C.DrawColor = HudBasicColor*0.1;
        C.SetPos(XP+H-4+w/2-w2/2+2,YP);
        C.DrawText(score, false);

        C.DrawColor = HudBasicColor;
        C.SetPos(XP+H-4+w/2-w2/2,YP-2);
        C.DrawText(score, false);
    }

    C.SpaceX = 0;
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

    UpdatePlayerList();

    GetUpMargin( C , ViewPortId , PlayerNumber );

    // Header

    DrawInfoLine( C,PlayerString,FragsString,DeathsString,HudBasicColor,HudBasicColor,false , PlayerNumber );
    YP += 8;

    //Players ...

    for ( Loop=0; Loop<PlayerCount; Loop++ )
    {
        IsMe = ( Ordered[Loop] == PlayerOwner.PlayerReplicationInfo );
        BgColor = Teamcolor[Ordered[Loop].Team.TeamIndex];

        PName = Ordered[Loop].PlayerName;
        PFrag = string( int(Ordered[Loop].Score));
        PDeath = string( int(Ordered[Loop].Deaths));

        DrawInfoLine2( C, PName,PFrag,PDeath,HudBasicColor,BgColor,IsMe , PlayerNumber, Ordered[Loop].bWaitingPlayer, !Ordered[Loop].bReadyToPlay  );
    }

    if (TGRI.iGameState==3)
        DrawTeamScore(C);

    // Trail

    GetDownMargin( C , ViewPortId , PlayerNumber );

    DrawTrailer(C);
}
//____________________________________________________________________
function DrawInfoLine2(Canvas C, string Info1, string Info2, string Info3, color LineColor, color BgColor , bool AddBg, int ViewPortNumber, optional bool bDrawReadyToPlay, optional bool bNotReadyToPlay  )
{
    local float W,H, IconSize, Temp;
    local int XP;

    if( ViewPortNumber == 1 )
        C.Font = BigFont;
    else
        C.Font = SmallFont;

    C.SpaceX = 1;
    C.StrLen(Info1, W, H);
//    IconSize = (H) / SkullTex.VSize;
    XP = C.CLipX*0.15;

    // BackGround Icon + Text
    C.bUseBorder = false;
    C.Style = ERenderStyle.STY_Alpha;
    C.DrawColor = BgColor*0.3;
    C.DrawColor.A = 60;

    C.SetPos(XP,YP);
    OwnerHud.DrawStdBackGround(C, H-4, C.CLipX*0.7 - 2*(H-4));

    C.Style = ERenderStyle.STY_Translucent;

    C.DrawColor = BgColor;
    C.DrawColor.A = 200;

    C.SetPos(XP,YP);
    OwnerHud.DrawStdBackGround(C, H-4, C.CLipX*0.7 - 2*(H-4));

    // Text
    C.Style=ERenderStyle.STY_Normal;

    C.DrawColor = LineColor*0.3;
    C.SetPos(XP+H+4+1,YP-1);
    C.DrawText(Info1, false);

    C.DrawColor = LineColor;
    C.SetPos(XP+H+4,YP-2);
    C.DrawText(Info1, false);

    C.StrLen(Info2, W, H);

    C.DrawColor = LineColor*0.3;
    C.SetPos(C.ClipX*0.58 + 1 - W/2,YP-1);
    C.DrawText(Info2, false);

    C.DrawColor = LineColor;
    C.SetPos(C.ClipX*0.58 - W/2,YP-2);
    C.DrawText(Info2, false);

    C.StrLen(Info3, W, H);

    C.DrawColor = LineColor*0.3;
    C.SetPos(C.ClipX*0.75 + 1 - W/2,YP-1);
    C.DrawText(Info3, false);

    C.DrawColor = LineColor;
    C.SetPos(C.ClipX*0.75 - W/2,YP-2);
    C.DrawText(Info3, false);

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

    if( AddBg )
    {
        C.Style=ERenderStyle.STY_Normal;
        C.DrawColor = HudBasicColor;
        C.DrawColor.A = 255;

        IconSize = H;
        IconSize *= sin((Level.TimeSeconds*0.9-int(Level.TimeSeconds*0.9))*3.14);

        if ( bDrawReadyToPlay )
          C.SetPos(XP-(IconSize)/2+(h-4)/2-H-3,YP-2);
        else
          C.SetPos(XP-(IconSize)/2+(h-4)/2,YP-2);
        C.DrawTile( PlayerTex,IconSize,H,0,0,PlayerTex.USize,PlayerTex.VSize);
        C.bUseBorder = false;
    }

    YP += H;

    C.SpaceX = 0;
}

//____________________________________________________________________
//    SkullTex=texture'XIIIMenu.6sense'


defaultproperties
{
     TeamColor(0)=(R=200,A=255)
     TeamColor(1)=(B=255,G=159,R=64,A=255)
     PlayerTex=Texture'XIIIMenu.HUD.6sense'
}
