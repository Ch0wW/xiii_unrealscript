//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPCTFScoreBoard extends XIIIMPTeamScoreBoard;

var localized string strFlag;

function ShowScores( Canvas C , int ViewPortId , int PlayerNumber )
{
    local color BgColor;
    local int Loop;
    local string PName,PFrag,PDeath;
    local bool IsMe, HasTheFlag;
    local XIIIMPFlag Flag;
    local XIIIGameReplicationInfo TGRI;

    if ( (PlayerOwner == none) || (PlayerOwner.GameReplicationInfo == none) )
      return; // wait for init

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
    DrawInfoLine( C,PlayerString,FragsString,DeathsString,HudBasicColor,HudBasicColor,false,PlayerNumber );
    YP += 8;

    //Players ...
    for ( Loop=0; Loop<PlayerCount; Loop++ )
    {
        IsMe = ( Ordered[Loop] == PlayerOwner.PlayerReplicationInfo );
        BgColor = Teamcolor[Ordered[Loop].Team.TeamIndex];

        PName = Ordered[Loop].PlayerName;
        PFrag = string( int(Ordered[Loop].Score));
        PDeath = string( int(Ordered[Loop].Deaths));

        Flag = XIIIMPFlag(PlayerOwner.GameReplicationInfo.Teams[0].Flag);
        HasTheFlag = false;
        if ( (Flag != none) && (Flag.Holder != none) && (Flag.Holder.Controller.PlayerReplicationInfo == Ordered[Loop]) )
          HasTheFlag = true;
        if( !HasTheFlag )
        {
          Flag = XIIIMPFlag(PlayerOwner.GameReplicationInfo.Teams[1].Flag);
          if ( (Flag != none) && (Flag.Holder != none) && (Flag.Holder.Controller.PlayerReplicationInfo == Ordered[Loop]) )
            HasTheFlag = true;
        }
        DrawInfoLine3( C, PName,PFrag,PDeath,HudBasicColor,BgColor,IsMe, HasTheFlag,PlayerNumber, Ordered[Loop].bWaitingPlayer, !Ordered[Loop].bReadyToPlay  );
    }

    if (TGRI.iGameState==3)
        DrawTeamScore(C);

    // Trail
    GetDownMargin( C , ViewPortId , PlayerNumber );
    DrawTrailer(C);
}

function DrawInfoLine3(Canvas C, string Info1, string Info2, string Info3, color LineColor, color BgColor , bool AddBg, bool bFlag, int ViewPortNumber, optional bool bDrawReadyToPlay, optional bool bNotReadyToPlay)
{
    local float W,H, IconSize, Temp;
    local int XP;

    if( bFlag )
        Info1 = Info1@strFlag;

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



defaultproperties
{
     strFlag="(Flag)"
     FragsString="Points"
}
