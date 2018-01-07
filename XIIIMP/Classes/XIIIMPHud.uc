//-----------------------------------------------------------
// XIIIMJHud || For XIIIDMGameInfo
//-----------------------------------------------------------
class XIIIMPHud extends XIIIBaseHud;

#exec OBJ LOAD FILE=XIIIXboxPacket.utx

var color TeamColor[2];
var localized string sPosition[4]; //s1st,s2nd,s3rd,s4th;
var localized string sKicked;
var float  ScoreWidth , ScoreHeight;
var color PlayerColor;
var bool bInit,bSplitt;
var int MarioBonus;
var array<texture> MarioBonusTex[11];

// Xbox live stuff
var XboxLiveManager xboxlive; // SouthEnd
var texture inviteReceivedIcon;
var texture HudMPWIcons;

var int OldScore;
var sound SndFrag;
var int FragCount;
var texture texFrag;
var float LastFragTime, LastBonusTime;
var int BonusOn[12],OldBonusOn[12];
var int OldMarioBonus;
var sound soundBonusOn[12];
var sound soundBonusOff[12];
var bool bDrawBonusText;
var int DrawBonusTextID;
var localized string BonusText[12];
var float BonusLifeTime[12];
var float BonusActivationLifeTime[12];
var float BonusTrans[12];

var texture WaitInitTex;
var texture BadConnectTex;

//____________________________________________________________________
simulated function DrawWaitForMPInit(Canvas C)
{
    local float W,H;

    C.SetPos(C.ClipX/2.0 - WaitInitTex.USize/2.0, C.ClipY/2.0 - WaitInitTex.VSize/2.0);
    C.Style = ERenderStyle.STY_Alpha;
    C.DrawColor = OrangeColor;
    C.DrawIcon(WaitInitTex, 1.0);
    C.DrawColor = WhiteColor;
    C.SpaceX = 0;
    UseHugeFont(C);
    if ( (PlayerOwner != none) && PlayerOwner.IsInState('Kicked') )
      C.StrLen(sKicked, W, H );
    else
      C.StrLen(class'XIIIMPScoreBoard'.default.strPleaseWait, W, H );
    C.SetPos((C.ClipX -W)/2.0, C.ClipY/2 + WaitInitTex.VSize/2.0 - H*2);
    C.bTextShadow = true;
    if ( (PlayerOwner != none) && PlayerOwner.IsInState('Kicked') )
      C.DrawText(sKicked);
    else
      C.DrawText(class'XIIIMPScoreBoard'.default.strPleaseWait);
    C.bTextShadow = false;
}

//____________________________________________________________________
simulated event PostRender( canvas C )
{
    if ( (PlayerOwner == none) || (PlayerOwner.GameReplicationInfo == none) || (PlayerOwner.PlayerReplicationInfo == none) )
    {
      DrawWaitForMPInit(C);
      return; // wait for game initialization/replications
    }
    Super.PostRender(C);
}

//____________________________________________________________________
function DisplayBadConnectionAlert(Canvas C)
{
    C.Style = ERenderStyle.STY_Alpha;
    C.DrawColor = WhiteColor;
    if ((Level.TimeSeconds*2.0 - int(Level.TimeSeconds*2.0)) > 0.5 )
    {
      C.SetPos(C.ClipX/2.0 - BadConnectTex.USize, C.ClipY*UpMargin );
      C.DrawIcon(BadConnectTex, 1.0);
    }
    else
    {
      C.SetPos(C.ClipX/2.0, C.ClipY*UpMargin );
      C.DrawTile(BadConnectTex, BadConnectTex.USize, BadConnectTex.VSize, 0, 0, -BadConnectTex.USize, BadConnectTex.VSize);
    }
}

//____________________________________________________________________
function DrawBonusText(Canvas C)
{
    local string TmpTxt;
    local float W,H;
    local float AlfaTrans;

    TmpTxt=BonusText[ DrawBonusTextID ];

    if( (Level.NetMode == NM_StandAlone) && ( Level.Game.NumPlayers > 2 ) )
       C.Font = SmallFont;
    else
       C.Font = BigFont;

    C.SpaceX = 1;
    C.bUseBorder = false;
    C.Style = ERenderStyle.STY_Alpha;
    C.StrLen(TmpTxt, W, H );

    C.DrawColor = WhiteColor;

    AlfaTrans= (2.5+LastBonusTime-Level.TimeSeconds)*102;

    if( AlfaTrans < 0.0 )
    {
       AlfaTrans = 0.0;
       bDrawBonusText=false;
    }

    C.DrawColor.A = int(AlfaTrans);

    C.SetPos( C.ClipX/2-W/2, C.ClipY/3+C.ClipX*0.06+2);
    C.DrawText(TmpTxt,false);
}

//____________________________________________________________________

function UpdateBonusSound()
{
    local int Loop,BonusIndex,BonusValue;


    for( Loop =0 ; Loop < 12 ; Loop++ )
         OldBonusOn[Loop]=BonusOn[Loop];

    BonusValue = 1;

    For( Loop = 0 ; Loop < 12 ; Loop ++ )
    {
        if( ( MarioBonus & BonusValue ) != 0 )
            BonusOn[Loop]=1;
        else
            BonusOn[Loop]=0;

        if( ( BonusOn[Loop] == 1 ) && ( OldBonusOn[Loop] == 0 ) )
        {
//            PlayerOwner.PlayMenu( soundBonusOn[Loop] );
            PlayerOwner.PlaySound( soundBonusOn[Loop] );
            //log("--- SOund="@soundBonusOn[Loop]@"sur"@PlayerOwner);
            DrawBonusTextID=Loop;
            LastBonusTime = Level.TimeSeconds;
            bDrawBonusText=true;
            BonusActivationLifeTime[Loop] = Level.TimeSeconds;
            BonusTrans[Loop] = 255;
        }
        else if( ( BonusOn[Loop] == 0 ) && ( OldBonusOn[Loop] == 1 ) )
        {
            //log("--- SOund="@soundBonusOff[Loop]@"sur"@PlayerOwner);
//            PlayerOwner.PlayMenu( soundBonusOff[Loop] );
            PlayerOwner.PlaySound( soundBonusOff[Loop] );
        }

        BonusValue *= 2;
    }
}

//____________________________________________________________________

event Timer2()
{
    FragCount = 0;
    SetTimer2( 0.0, false );
}

//____________________________________________________________________

function DrawFrag( Canvas C )
{
    local int Loop;
    local float TextSize;
    local float AlfaTrans;

    if( FragCount > 5 )
	FragCount = 5;

    TextSize = C.ClipX*0.06;

    C.bUseBorder = false;
    C.Style = ERenderStyle.STY_Alpha;

    C.DrawColor = WhiteColor;
    AlfaTrans= (2+LastFragTime-Level.TimeSeconds)*127;

    if( AlfaTrans < 0.0 )
    {
       AlfaTrans = 0.0;
       Timer2();
    }

    C.DrawColor.A = int(AlfaTrans);

    C.SetPos( C.ClipX/2 - FragCount*TextSize*0.5, C.ClipY*0.3);

    for( Loop=0; Loop < FragCount ; Loop++ )
    {
        C.DrawRect(texFrag, TextSize,TextSize);
    }
}

//____________________________________________________________________

function MarioBonusDisplay(Canvas C)
{
    local string  strMarioBonus;
    local float W,H, TmpTime ;
    local int Loop,BonusIndex,BonusValue;
    local texture BonusTex;

    if ( (PlayerOwner == none) || (PlayerOwner.Pawn == none) )
      return;

    if ( Level.NetMode != NM_Standalone )
    {
	MarioBonus = XIIIMPPlayerPawn(PlayerOwner.Pawn).MarioBonusLAN;
    }

    if( MarioBonus != OldMarioBonus )
	UpdateBonusSound();

    OldMarioBonus = MarioBonus;

    if( MarioBonus < 0 )
    {
        MarioBonus = 0;
        bDrawBonusText= false;
    }

    if( bDrawBonusText )
        DrawBonusText(C);


    if( MarioBonus != 0 )
    {
        UseHugeFont(C);
        C.SpaceX = 0;
        C.bUseBorder = true;
        C.Style = ERenderStyle.STY_Alpha;
        C.BorderColor = WhiteColor;
        C.StrLen("A", W, H );
        C.DrawColor = WhiteColor;
        C.DrawColor.A = 255;

        YP = YP + H + 4;

        BonusValue = 1;

        BonusIndex = 0;

        For( Loop = 0 ; Loop < 11 ; Loop ++ )
        {
            if( ( MarioBonus & BonusValue ) != 0 )
            {
		TmpTime = Level.TimeSeconds - BonusActivationLifeTime[Loop];

		if( TmpTime < BonusLifeTime[Loop] - 3 )
		{
        	     C.DrawColor.A = 255;
		}
		else
		{
        	     C.DrawColor.A = BonusTrans[Loop];
                     BonusTrans[Loop] -= 5;
		     if( BonusTrans[Loop] <= 0.0 ) BonusTrans[Loop] = 255;
		}

                BonusTex = MarioBonusTex[Loop];
                C.SetPos( XP+BonusIndex*(H+4),YP);
                C.DrawTile(BonusTex, H,H, 0, 0, BonusTex.USize, BonusTex.VSize);

                BonusIndex ++;
            }

            BonusValue *= 2;
        }

        C.bUseBorder = false;
    }
}


//____________________________________________________________________
//
function DrawViewPortSeparator(Canvas C)
{
    local float H,W,H2,W2;


    if ( (Level.Game == none) || (Level.NetMode != NM_StandAlone) )
      return;
    if( Level.Game.NumPlayers == 2 )
    {
        H = C.ClipY*0.01;
        W = C.ClipX;

        if( ViewPortId == 0 )
        {
            C.bUseBorder = false;

//            C.DrawColor = WhiteColor;
//            C.DrawColor.A = 255;
//
//            C.SetPos( 0, C.ClipY-H-1);
//            C.DrawTile(WhiteTex, W,H+1, 0, 0, WhiteTex.USize, WhiteTex.VSize);

            C.DrawColor = BlackColor;
            C.DrawColor.A = 255;

            C.SetPos( 0, C.ClipY-H);
            C.DrawTile(BlackTex, W,H, 0, 0, BlackTex.USize, BlackTex.VSize);
        }
        else if( ViewPortId == 1 )
        {
            C.bUseBorder = false;

//            C.DrawColor = WhiteColor;
//            C.DrawColor.A = 255;
//
//            C.SetPos( 0, 0);
//            C.DrawTile(WhiteTex, W,H+1, 0, 0, WhiteTex.USize, WhiteTex.VSize);

            C.DrawColor = BlackColor;
            C.DrawColor.A = 255;

            C.SetPos( 0, 0);
            C.DrawTile(BlackTex, W,H, 0, 0, BlackTex.USize, BlackTex.VSize);
        }
    }
    else if( Level.Game.NumPlayers > 2 )
    {
        H = C.ClipY*0.01;
        W = C.ClipX;
        H2 = C.ClipY;
        W2 = C.ClipX*0.0075;

        if( ViewPortId == 0 )
        {
            C.bUseBorder = false;

//            C.DrawColor = WhiteColor;
//            C.DrawColor.A = 255;
//
//            C.SetPos( 0, C.ClipY-H-1);
//            C.DrawTile(WhiteTex, W,H+1, 0, 0, WhiteTex.USize, WhiteTex.VSize);
//
//            C.SetPos( C.ClipX - W2-1, 0);
//            C.DrawTile(WhiteTex, W2+1,H2, 0, 0, WhiteTex.USize, WhiteTex.VSize);

            C.DrawColor = BlackColor;
            C.DrawColor.A = 255;

            C.SetPos( 0, C.ClipY-H);
            C.DrawTile(BlackTex, W,H, 0, 0, BlackTex.USize, BlackTex.VSize);

            C.SetPos( C.ClipX - W2, 0);
            C.DrawTile(BlackTex, W2,H2, 0, 0, BlackTex.USize, BlackTex.VSize);
        }
        else if( ViewPortId == 1 )
        {
            C.bUseBorder = false;

//            C.DrawColor = WhiteColor;
//            C.DrawColor.A = 255;
//
//            C.SetPos( 0, C.ClipY-H-1);
//            C.DrawTile(WhiteTex, W,H+1, 0, 0, WhiteTex.USize, WhiteTex.VSize);
//
//            C.SetPos( 0, 0);
//            C.DrawTile(WhiteTex, W2+1,H2, 0, 0, WhiteTex.USize, WhiteTex.VSize);

            C.DrawColor = BlackColor;
            C.DrawColor.A = 255;

            C.SetPos( 0, C.ClipY-H);
            C.DrawTile(BlackTex, W,H, 0, 0, BlackTex.USize, BlackTex.VSize);

            C.SetPos( 0, 0);
            C.DrawTile(BlackTex, W2,H2, 0, 0, BlackTex.USize, BlackTex.VSize);
        }
        else if( ViewPortId == 2 )
        {
            C.bUseBorder = false;

//            C.DrawColor = WhiteColor;
//            C.DrawColor.A = 255;
//
//            C.SetPos( 0, 0);
//            C.DrawTile(WhiteTex, W,H+1, 0, 0, WhiteTex.USize, WhiteTex.VSize);
//
//            C.SetPos( C.ClipX - W2-1, 0);
//            C.DrawTile(WhiteTex, W2+1,H2, 0, 0, WhiteTex.USize, WhiteTex.VSize);

            C.DrawColor = BlackColor;
            C.DrawColor.A = 255;

            C.SetPos( 0, 0);
            C.DrawTile(BlackTex, W,H, 0, 0, BlackTex.USize, BlackTex.VSize);

            C.SetPos( C.ClipX - W2, 0);
            C.DrawTile(BlackTex, W2,H2, 0, 0, BlackTex.USize, BlackTex.VSize);
        }
        else if( ViewPortId == 3 )
        {
            C.bUseBorder = false;

//            C.DrawColor = WhiteColor;
//            C.DrawColor.A = 255;
//
//            C.SetPos( 0, 0);
//            C.DrawTile(WhiteTex, W,H+1, 0, 0, WhiteTex.USize, WhiteTex.VSize);
//
//            C.SetPos( 0, 0);
//            C.DrawTile(WhiteTex, W2+1,H2, 0, 0, WhiteTex.USize, WhiteTex.VSize);

            C.DrawColor = BlackColor;
            C.DrawColor.A = 255;

            C.SetPos( 0, 0);
            C.DrawTile(BlackTex, W,H, 0, 0, BlackTex.USize, BlackTex.VSize);

            C.SetPos( 0, 0);
            C.DrawTile(BlackTex, W2,H2, 0, 0, BlackTex.USize, BlackTex.VSize);
        }
    }
}

//____________________________________________________________________
//
function PlayerNameDisplay(Canvas C)
{
    local float W,H ;
    local string strRank, strScore;
    local int Loop, Rank, Score ;

    UseHugeFont(C);
    C.SpaceX = 0;

    if( ! bInit )
    { // can't be in postbeginplay because need canvas
      bInit = true;
      PlayerColor = HudBasicColor;
      ScoreWidth = 0;
      for( Loop=0 ; Loop < 4 ;Loop++)
      {
        C.StrLen(sPosition[Loop], W, H );
        if( ScoreWidth < W )
          ScoreWidth = W;
      }
      C.StrLen("999", W, H );
      if( ScoreWidth < W )
        ScoreWidth = W;
      ScoreHeight = H;
      ScoreHeight -= 4;
      ScoreWidth += 4;
      if ( (Level.NetMode != NM_Standalone) || (Level.bLonePlayer) )
        bSplitt = false;
      else
        bSplitt = true;
    }

    Scoring.UpdateScores();

    for( Loop = 0 ; Loop < 32 ; Loop++ )
    {
        if(  XIIIMPScoreBoard(Scoring).Ordered[ Loop ] == PlayerOwner.PlayerReplicationInfo )
        {
            Rank = Loop+1;
            break;
        }
    }

    Score = XIIIMPScoreBoard(Scoring).Ordered[ Loop ].Score;
    strRank = string( Rank );
    if( Rank > 3 )
      Rank = 4;

    strRank = strRank$sPosition[ Rank -1 ];
    strScore = string( Score );

    C.Style = ERenderStyle.STY_Alpha;
    C.DrawColor = PlayerColor*0.1;
    C.DrawColor.A = 90;
    C.bUseBorder = false;
    // 1rst part of background, display rank
    C.SetPos( XP, YP);
    C.DrawRect(RoundBackGroundTex, ScoreHeight,ScoreHeight);
    C.DrawRect(FondMsg, ScoreWidth,ScoreHeight);
    // 2nd part of background, display score
    C.SetPos(C.CurX + 4 , C.CurY);
    C.DrawRect(FondMsg, ScoreWidth,ScoreHeight);
    C.DrawTile(RoundBackGroundTex, ScoreHeight,ScoreHeight, 0, 0, -RoundBackGroundTex.USize, RoundBackGroundTex.VSize);

    C.bTextShadow = true;
    C.DrawColor = PlayerColor;
    C.DrawColor.A = 255;

    C.StrLen(StrRank, W, H );
    C.SetPos( XP + ScoreHeight + ScoreWidth/2- W/2-2, YP-1);
    C.DrawText(strRank, false);

    C.StrLen(strScore, W, H );
    C.SetPos( XP + ScoreHeight + ScoreWidth+4 + ScoreWidth/2- W/2 +4 -2, YP-1);
    C.DrawText(strScore, false);

    C.bTextShadow = false;

    if( OldScore != XIIIPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).MyDeathScore )
    {
        FragCount=XIIIPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).MyDeathScore-OldScore;
//      Log("FRAG new FragCount="$FragCount);

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

function DrawVersion( canvas C )
{
    local float W,H ;
    local string strVersion;

    UseHugeFont(C);
    C.SpaceX = 0;

    strVersion = "--- 6.3  ---";
    C.StrLen(strVersion, W, H );

    C.Style = ERenderStyle.STY_Alpha;
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 100;
    C.bUseBorder = false;

    C.SetPos( C.ClipX/2 - W/2, C.ClipY*0.07);
    C.DrawText(strVersion, false);
}

//____________________________________________________________________
// ELR Draw HUD
function DrawHUD( canvas C )
{
  local float alphavalue;

    if ( (PlayerOwner == none) || (PlayerOwner.GameReplicationInfo == none) )
      return; // wait for game initialization/replications

    HUDSetup( C );


  // Draw the gameinvite icon
  if (xboxlive == none)
    xboxlive=New Class'XboxLiveManager';
  if (!PlayerOwner.Player.LocalInteractions[0].IsInState('UWindows') && xboxlive.IsLoggedIn(xboxlive.GetCurrentUser()) && xboxlive.ShouldRenderInvite())
  {
    alphavalue      = abs(sin(Level.TimeSeconds*4.0))*255.0;

    // render a blinking invite icon
    C.SetPos(540, 100);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = alphavalue;
    C.Style = 5; // ERenderStyle.STY_Alpha;
    C.DrawTile(inviteReceivedIcon, inviteReceivedIcon.USize, inviteReceivedIcon.VSize, 0, 0, inviteReceivedIcon.USize, inviteReceivedIcon.VSize);
    C.Style = 1; // ERenderStyle.STY_Normal;
  }

    // ELR Do show scores if needed.
    if ( (PlayerOwner.Pawn == none) || (XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo).iGameState != 2) )
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

    if ( bShowScores && (Scoring != None) ) // Clean Frags Icon if displaying  scores
      OldScore = XIIIPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).MyDeathScore;

    Super.DrawHud(C);

    if ( bHideHud && (PawnOwner != none) && !PawnOwner.bIsDead )
        bHideHud = false;

    DrawViewPortSeparator(C);



    //DrawVersion( C );
}

//____________________________________________________________________
simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional string CriticalString )
{
    if( ( Level.NetMode == NM_StandAlone) && ( ( Level.Game == none ) || ( Level.Game.NumPlayers > 2 ) ) )
       return;

    if ( Message == class'XIIIEndGameMessage' )
    {
      AddHudEndMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
      bHideHud = true;
    }
//    else if ( ( Message == class'XIIIDeathMessage' ) && ( PawnOwner.bIsDead )  )
//    {
//      AddHudEndMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
//      bHideHud = true;
//    }
//    else
    if( ( ( ( Message == class'XIIIDeathMessage' ) || ( Message == class'XIIIMPCTFMessage') ) || ( Message == class'XIIIMultiMessage' ) ) || ( Message == class'XIIIMPDuckMessage' ) )
      AddHudMPMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
    else
      AddHudMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
}

//____________________________________________________________________

function DrawWeaponIconsList(canvas C)
{
    local string ItemText;
    local int Loop, NbWeapon, MaxWeaponIndex,AmmoPerCharger, Ammo, Loop2, CurrentId , PrevId, NextID;
    local float WeaponPos;
    local Weapon W,TW[22],TW2[7];
    local inventory I;
    local int XCoords, YCoords;

    if ( !bSplitt || (Level.Game.NumPlayers <= 2) )
    {
      super.DrawWeaponIconsList(C);
      return;
    }

    NbWeapon = 0;
    I = PawnOwner.Inventory;
    // Add weapons in array TW
    while ( I != none )
    {
      W = Weapon(I);
      if ( (W != none) && !((W.default.ReLoadCount==0) && !W.HasAmmo()) && (DecoWeapon(W) == none) && !XIIIWeapon(W).bIsSlave )
      {
        TW[W.InventoryGroup] = W;
        MaxWeaponIndex = Max(MaxWeaponIndex, W.InventoryGroup);
        NbWeapon++;
      }
      I = I.Inventory;
    }

    if( NbWeapon <= 3 )
    {
      super.DrawWeaponIconsList(C);
      return;
    }

    NbWeapon = 0;

    for( Loop=0;Loop<22;Loop++)
    { // 2nd pass to have prior & next weapons
      if( TW[Loop] != none )
      {
        W = TW[ Loop ];
        if( NbWeapon < 7 )
        {
          TW2[ NbWeapon ] = W;
          if( W == DrawnWeapon )
            CurrentId = NbWeapon;
          NbWeapon++;
        }
      }
    }

    PrevId = CurrentId-1;
    if ( PrevId == -1 )
      PrevId = NbWeapon-1;
    NextId = CurrentId+1;
    if( NextId == NbWeapon )
      NextId = 0;

    YP = C.ClipY * (1 - downMargin) - LifeDisplayHeight;
    WeaponPos = C.ClipX * (1 - RightMargin) - (3)*(2*LifeDisplayHeight+4) - LifeDisplayHeight;
    C.bUseBorder = false;
    C.Style = ERenderStyle.STY_Alpha;

    for( Loop=0;Loop<3;Loop++)
    {
      Switch( Loop )
      {
        case 0 : W = TW2[PrevId]; break ;
        case 1 : W = TW2[CurrentId]; break ;
        case 2 : W = TW2[NextId]; break ;
      }

      if ( !W.HasAmmo() && !XIIIWeapon(W).HasAltAmmo() )
        C.DrawColor = RedColor;
      else if ( ( XIIIWeapon(W).WHand==WHA_2HShot ) && PawnOwner.bHaveOnlyOneHandFree )
        C.DrawColor = OrangeColor;
      else
        C.DrawColor = HudBasicColor*0.1;

      if ( W == DrawnWeapon )
        C.DrawColor.A=140 ;
      else
        C.DrawColor.A=70 ;

      C.SetPos( WeaponPos,YP);
      C.DrawRect(FondMsg, 2*LifeDisplayHeight,LifeDisplayHeight);

      C.DrawColor= WhiteColor;
      if ( W == DrawnWeapon )
      {
        C.bUseBorder = true;
        C.BorderColor= HudBasicColor;
        C.BorderColor.A= 255 ;
      }
      C.SetPos(WeaponPos,YP);

      //C.DrawRect(W.Icon, 2*LifeDisplayHeight,LifeDisplayHeight);

      YCoords = W.InventoryGroup / 4;
      XCoords = W.InventoryGroup - YCoords * 4;
      C.DrawTile(HudMPWIcons, 2*LifeDisplayHeight, LifeDisplayHeight, 64*XCoords, 32*YCoords, 64, 32);


      C.bUseBorder = false;

      // Draw Ammo
      C.DrawColor = HudBasicColor;
      if ( W == DrawnWeapon )
        C.DrawColor.A = 255;
      else
        C.DrawColor.A = 150;

      if( XIIIWeapon(W).default.ReLoadCount > 0 )
      {
        Ammo = W.Ammotype.AmmoAmount;
        AmmoPerCharger = W.default.ReLoadCount;
        Ammo /= AmmoPerCharger;
      }
      else
      {
        if ( (XIIIWeapon(W).WHand == WHA_Fist) || (XIIIWeapon(W).WHand == WHA_Deco) )
          Ammo = -1;
        else
          Ammo = W.Ammotype.AmmoAmount;
      }

      if( Ammo > 0 )
      {
        if( Ammo > 6 ) Ammo = 6 ;
        ItemText = Left(sAmmoRef, Ammo);
        C.SetPos( WeaponPos,YP-LifeDisplayHeight/2-7 );
        C.DrawText(ItemText, false);
      }
      WeaponPos += 2*LifeDisplayHeight + 4;
    }

    C.DrawColor = HudBasicColor*0.1;
    C.DrawColor.A= 70 ;

    C.SetPos( WeaponPos,YP);
    C.DrawTile(RoundBackGroundTex, LifeDisplayHeight,LifeDisplayHeight, 0, 0, -RoundBackGroundTex.USize, RoundBackGroundTex.VSize);

    WeaponPos= C.ClipX * ( 1 - RightMargin ) - (3)*(2*LifeDisplayHeight+4) - 2*LifeDisplayHeight - 4;
    C.SetPos( WeaponPos,C.CurY);
    C.DrawTile(RoundBackGroundTex, LifeDisplayHeight,LifeDisplayHeight, 0, 0, RoundBackGroundTex.USize, RoundBackGroundTex.VSize);
}



defaultproperties
{
     TeamColor(0)=(R=200,A=255)
     TeamColor(1)=(B=255,G=159,R=64,A=255)
     sPosition(0)=" st"
     sPosition(1)=" nd"
     sPosition(2)=" rd"
     sPosition(3)=" th"
     sKicked="KICKED"
     MarioBonusTex(0)=Texture'XIIIMenu.HUD.mul_invulnerability'
     MarioBonusTex(1)=Texture'XIIIMenu.HUD.mul_invisibility'
     MarioBonusTex(2)=Texture'XIIIMenu.HUD.mul_quad'
     MarioBonusTex(3)=Texture'XIIIMenu.HUD.mul_regen'
     MarioBonusTex(4)=Texture'XIIIMenu.HUD.mul_teleport'
     MarioBonusTex(5)=Texture'XIIIMenu.HUD.mul_boost'
     MarioBonusTex(6)=Texture'XIIIMenu.HUD.mul_moinsdarmure'
     MarioBonusTex(7)=Texture'XIIIMenu.HUD.mul_moinsdevie'
     MarioBonusTex(8)=Texture'XIIIMenu.HUD.mul_mouette'
     MarioBonusTex(9)=Texture'XIIIMenu.HUD.mul_flag'
     MarioBonusTex(10)=Texture'XIIIMenu.HUD.mul_bombe'
     HudMPWIcons=Texture'XIIIMenu.HUD.Weapon1Icons'
     SndFrag=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hScoreUp'
     texFrag=Texture'XIIIMenu.HUD.mul_fright'
     soundBonusOn(0)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hInvulnOn'
     soundBonusOn(1)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hInvisibOn'
     soundBonusOn(2)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hSuperDamOn'
     soundBonusOn(3)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hRegenAct'
     soundBonusOn(4)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hTeleportable'
     soundBonusOn(5)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hBoostOn'
     soundBonusOn(6)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hLoosArmurOn'
     soundBonusOn(7)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hLoosLifeOn'
     soundBonusOn(11)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hSuperArmor'
     soundBonusOff(0)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hInvulnOff'
     soundBonusOff(1)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hInvisibOff'
     soundBonusOff(2)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hSuperDamOff'
     soundBonusOff(3)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hRegenOff'
     soundBonusOff(4)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hTeleportAct'
     soundBonusOff(5)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hBoostOff'
     soundBonusOff(6)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hLoosArmurOff'
     soundBonusOff(7)=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hLoosLifeOff'
     BonusText(0)="Invulnerability"
     BonusText(1)="Invisibility"
     BonusText(2)="Super Damage"
     BonusText(3)="Regeneration"
     BonusText(4)="Teleport"
     BonusText(5)="Super Boost"
     BonusText(6)="Lose Armor"
     BonusText(7)="Lose Life"
     BonusText(8)="Super Armor"
     BonusText(9)="You Got The Flag"
     BonusText(10)="You Got The Bomb"
     BonusText(11)="Super Armor"
     BonusLifeTime(0)=15.000000
     BonusLifeTime(1)=15.000000
     BonusLifeTime(2)=15.000000
     BonusLifeTime(3)=15.000000
     BonusLifeTime(4)=60.000000
     BonusLifeTime(5)=15.000000
     BonusLifeTime(6)=20.000000
     BonusLifeTime(7)=20.000000
     BonusLifeTime(8)=20000.000000
     BonusLifeTime(9)=20000.000000
     BonusLifeTime(10)=20000.000000
     BonusLifeTime(11)=20000.000000
     WaitInitTex=Texture'XIIICine.effets.Baommm'
     BadConnectTex=Texture'XIIIMenu.HUD.badconnection'
     fTranspWarningDamage=0.500000
}
