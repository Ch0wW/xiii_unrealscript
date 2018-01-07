//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIBombHud extends XIIITeamHud;

var array<MPBombingBase> Objectives;
var array<float> OXL,OYL;
var MPBombingBase ActiveBombBase;
var texture texBomb1, texBomb2, texBomb3, texBombOut, texChrono;
var float BlinkTime, BotBlinkTime;
var float ClientBombTime[3];
var int ClientBombTimeInit[3];
var int SoundBomb[3],BotBlink[3];
var sound sndTicTac1,sndTicTac2,sndTicTacOff;

//_____________________________________________________________________________
function string TwoDigitString(int Num)
{
    if ( Num < 10 )
      return "0"$Num;
    else
      return string(Num);
}
//____________________________________________________________________
simulated function InitObjectives(Canvas C)
{
    Local MPBombingBase OB;
    Local int Loop;
    local MPBombingBase TmpOB[3];


    if ( Objectives.Length == 0 )
    {
      UseLargeFont(C);
//      i = 0;
      foreach allactors(class'MPBombingBase', OB)
      {
        TmpOB[ OB.BombPointID-1 ] = OB;
//        Objectives[i] = OB; // auto incrment array
//        // init text length as they will not change later
//        OXL.Length = OXL.Length + 1;
//        OYL.Length = OYL.Length + 1;
//
//        C.StrLen(Objectives[i].sBaseName, OXL[i], OYL[i]); // may not auto increment OXL & OYL so inc before
//
//        i++;
      }
    }

    for( loop=0; loop<3; loop++ )
    {
        Objectives.Length = Objectives.Length+1;
        Objectives[ Objectives.Length-1 ] = TmpOB[ Loop ];
    }
}

//____________________________________________________________________
function PlayerNameDisplay(Canvas C)
{
//    local float W,H;
    local float W2,H2;
//    local string TmpCountDown;
    local int Score[2], PlayerId, loop;
//    local int TmpTime ;
//    local float TmpRest;
    local int Minutes, Seconds;
    local XIIIGameReplicationInfo TGRI;
    local int iSec, iMillisec;
    local bool blink;

    if( BotBlinkTime == -1 )
    {
        BotBlinkTime = Level.TimeSeconds;
        blink = true;
    }

    if( Level.TimeSeconds - BotBlinkTime > 1.0 )
    {
        BotBlinkTime = Level.TimeSeconds;
        blink = true;
    }
    else if( Level.TimeSeconds - BotBlinkTime > 0.5 )
    {
        blink = false;
    }
    else
    {
        blink = true;
    }



    UseHugeFont(C);
    C.SpaceX = 0;
    C.StrLen("00:00", W2, H2 );

    if ( Objectives.Length == 0 )
      InitObjectives(C);

    if( ! bInit )
    {
      bInit = true;
      C.StrLen("999", ScoreWidth, ScoreHeight );
      ScoreHeight += 4;
      Scoring.UpdateScores();
      if ( (Level.NetMode != NM_Standalone) || (Level.bLonePlayer) )
        bSplitt = false;
      else
        bSplitt = true;
    }

    PlayerId = PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;

    C.bUseBorder = false;
    C.Style = ERenderStyle.STY_Alpha;

    // ________________
    // List of bombing point states
    C.DrawColor = TeamColor[PlayerId];
    C.DrawColor.A = 200;
    C.SetPos( XP, YP);
    DrawStdBackGround(C, ScoreHeight, ScoreHeight*3);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255;

    C.SetPos( XP + ScoreHeight, YP-1);

    if( ( ( BotBlink[0]==1 ) && ( Objectives[0].CurrentTeam == 1 ) ) && blink )
    {
        C.DrawColor = C.Static.MakeColor(253,191,68);
        C.DrawColor.A = 255;
    }
    else
    {
        C.DrawColor = WhiteColor;
        C.DrawColor.A = 255;
    }

    if( Objectives[0].CurrentTeam == 1 )
      C.DrawTile(texBomb1, ScoreHeight,ScoreHeight, 0, 0, texBomb1.USize, texBomb1.VSize);
    else
      C.DrawTile(texBombOut, ScoreHeight,ScoreHeight, 0, 0, texBombOut.USize, texBombOut.VSize);


    if( ( ( BotBlink[1]==1 ) && ( Objectives[1].CurrentTeam == 1 ) ) && blink )
    {
        C.DrawColor = C.Static.MakeColor(253,191,68);
        C.DrawColor.A = 255;
    }
    else
    {
        C.DrawColor = WhiteColor;
        C.DrawColor.A = 255;
    }

    if( Objectives[1].CurrentTeam == 1 )
      C.DrawTile(texBomb2, ScoreHeight,ScoreHeight, 0, 0, texBomb2.USize, texBomb2.VSize);
    else
      C.DrawTile(texBombOut, ScoreHeight,ScoreHeight, 0, 0, texBombOut.USize, texBombOut.VSize);


    if( ( ( BotBlink[2]==1 ) && ( Objectives[2].CurrentTeam == 1 ) ) && blink )
    {
        C.DrawColor = C.Static.MakeColor(253,191,68);
        C.DrawColor.A = 255;
    }
    else
    {
        C.DrawColor = WhiteColor;
        C.DrawColor.A = 255;
    }

    if( Objectives[2].CurrentTeam == 1 )
      C.DrawTile(texBomb3, ScoreHeight,ScoreHeight, 0, 0, texBomb3.USize, texBomb3.VSize);
    else
      C.DrawTile(texBombOut, ScoreHeight,ScoreHeight, 0, 0, texBombOut.USize, texBombOut.VSize);

    C.DrawColor.A = 255;

    // ________________
    // Timer display if a bomb is being activated
    for (loop=0; loop<Objectives.Length; loop++)
    {
      if( Objectives[loop].BombTime != -1 )
      {
        if( Objectives[loop].Role == ROLE_Authority )
        {
          iSec = 12 + Objectives[loop].BombTime - Level.TimeSeconds;
          iMilliSec = (120.0 + Objectives[loop].BombTime*10.0 - Level.TimeSeconds*10.0 - iSec*10.0);
        }
        else
        {
          iSec = 12 + ClientBombTime[Loop] - Level.TimeSeconds;
          iMilliSec = (120.0 + ClientBombTime[Loop]*10.0 - Level.TimeSeconds*10.0 - iSec*10.0);
        }

        if( ( iSec >= 0 ) && ( iMilliSec >= 0 ) )
        {
          if( SoundBomb[Loop] != 1 )
            PlayerOwner.PlayMenu( sndTicTac1 );
          SoundBomb[Loop] = 1;

          C.DrawColor = WhiteColor;
          C.DrawColor.A = 128;
          C.SetPos( C.ClipX/2 - (ScoreHeight+W2)/2, C.ClipY/3);

          switch( Loop )
          {
            case 0:
              C.DrawTile(texBomb1, ScoreHeight,ScoreHeight, 0, 0, texBomb1.USize, texBomb1.VSize);
              break;
            case 1:
              C.DrawTile(texBomb2, ScoreHeight,ScoreHeight, 0, 0, texBomb2.USize, texBomb2.VSize);
              break;
            case 2:
              C.DrawTile(texBomb3, ScoreHeight,ScoreHeight, 0, 0, texBomb3.USize, texBomb3.VSize);
              break;
          }
          C.SetPos( C.ClipX/2 - (ScoreHeight+W2)/2 + ScoreHeight, C.ClipY/3);
          C.DrawText( iSec$":"$iMilliSec$"0" , false);
        }
        else
        {
          if ( SoundBomb[Loop] != 2 )
            PlayerOwner.PlayMenu( sndTicTac2 );
          SoundBomb[Loop] = 2;

          if( ( iSec < -6 ) && ( SoundBomb[Loop] != 0 ) ) // antibug si arrive a lacher la bombe a l'exterieure de la zone
          {
              log("ANTIBUG");
              Objectives[loop].BombTime = -1;
          }
        }
      }
      else
      {
//        ClientBombTimeInit[Loop]=0;
        if( SoundBomb[Loop] != 0 )
        {
          //Log("---- TicTac OFF ----");
          PlayerOwner.PlayMenu( sndTicTacOff );
        }
        SoundBomb[Loop] = 0;
      }
    }

    // ________________
    // Left time
    C.DrawColor = TeamColor[PlayerId];
    C.DrawColor.A = 200;
    C.SetPos( XP, YP+ScoreHeight+4);
    DrawStdBackGround(C, ScoreHeight, W2+8);
    C.SetPos( XP, YP+ScoreHeight);
    C.DrawColor = WhiteColor;
    C.DrawColor.A = 255;
    C.DrawTile(texChrono, ScoreHeight+8, ScoreHeight+8, 64, 32, 32, 32);
    C.SetPos( XP+ ScoreHeight+ 8, YP+ScoreHeight+4);
    TGRI = XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo);
    Minutes = TGRI.XIIIRemainingTime/60;
    Seconds = TGRI.XIIIRemainingTime % 60;
    C.bTextShadow = true;
    C.DrawText(TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), false);
    C.bTextShadow = false;

    // ________________
    // Frag made.
    if ( OldScore != XIIIPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).MyDeathScore )
    {
      FragCount = XIIIPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).MyDeathScore-OldScore;

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

function UpDatePlayerReplicationInfoForLAN()
{
    local weapon MyBomb;
    local controller TmpC;

    for (TmpC=Level.ControllerList; TmpC!=None; TmpC=TmpC.NextController )
    {
      if( ( TmpC.Pawn == none ) || ( TmpC.Pawn.Health == 0 ) )
        XIIIPlayerReplicationInfo(TmpC.PlayerReplicationInfo).bHasTheBomb=false;
      else
      {
        MyBomb = weapon(TmpC.Pawn.FindInventoryType(class'MPBomb'));
        if( ( MyBomb != none ) && (  MyBomb.AmmoType.AmmoAmount != 0 ) )
          XIIIPlayerReplicationInfo(TmpC.PlayerReplicationInfo).bHasTheBomb=true;
        else
          XIIIPlayerReplicationInfo(TmpC.PlayerReplicationInfo).bHasTheBomb=false;
      }
    }
}

//____________________________________________________________________
function DrawHUD( canvas C )
{
    local int loop;
//    Log("BOMBHUD DrawHud PlayerOwner="$PlayerOwner@"GRI="$PlayerOwner.GameReplicationInfo);
    if ( (PlayerOwner == none) || (PlayerOwner.GameReplicationInfo == none) )
      return; // wait for game initialization/replications

    if ( Level.NetMode != NM_Standalone )
       UpDatePlayerReplicationInfoForLAN();

    // ________________
    // Timer display if a bomb is being activated, SetUp initial time for on-line
    for (loop=0; loop<Objectives.Length; loop++)
    {
      if( Objectives[loop].BombTime != -1 )
      {
        if( Objectives[loop].Role != ROLE_Authority )
        {
          if( ClientBombTimeInit[Loop] != Objectives[loop].BombingCount )
          { // initialized new count on clients
//            Log("Client NewBombActivated BombingCount="$Objectives[loop].BombingCount);
            ClientBombTimeInit[Loop] = Objectives[loop].BombingCount;
            ClientBombTime[Loop] = Level.TimeSeconds;
          }
        }
      }
    }
/* // Useless multiple call
    HUDSetup( C );

    // ELR do show scores if needed.
    if ( XIIIGameReplicationInfo(PlayerOwner.GameReplicationInfo).iGameState != 2 )
    {
      if ( Scoring != None )
      {
        Scoring.OwnerHUD = self;
        Scoring.ShowScores(C, ViewPortId, Level.Game.NumPlayers);
        DrawViewPortSeparator(C);
        return;
      }
    }
*/
    Super.DrawHud(C);
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
    else if( ( ( ( ( ( Message == class'XIIIDeathMessage' ) || ( Message == class'XIIIMPCTFMessage') ) || ( Message == class'XIIIMultiMessage' ) ) || ( Message == class'XIIIMPSabotageMessage' ) ) || ( Message == class'XIIIMPBlueDeathMessage' ) ) || ( Message == class'XIIIMPRedDeathMessage' ) )
      AddHudMPMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
    else
      AddHudMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
}

//____________________________________________________________________
function MarioBonusDisplay(Canvas C)
{
    local string  strMarioBonus;
    local float W,H ;
    local int Loop,BonusIndex,BonusValue;
    local texture BonusTex;
    local string TmpBaseName;
    local bool blink;

    if( PlayerOwner == none )
        return;

    if( PlayerOwner.Pawn == none )
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

    if( MarioBonus == 1024 )
    {
        if ( PlayerOwner.Pawn != none )
            foreach PlayerOwner.Pawn.TouchingActors(class'MPBombingBase', ActiveBombBase)
                break;

        if( ( ActiveBombBase != none ) && ( ActiveBombBase.CurrentTeam == 1 ) )
        {
            if( BlinkTime == -1 )
                BlinkTime = Level.TimeSeconds;

            blink = true;
        }
        else
        {
            blink = false;
        }

        if( blink )
        {
            if( Level.TimeSeconds - BlinkTime > 1.0 )
                BlinkTime = -1;
            else if( Level.TimeSeconds - BlinkTime > 0.5 )
                blink = false;
        }

        UseHugeFont(C);
        C.SpaceX = 0;
        C.bUseBorder = true;
        C.Style = ERenderStyle.STY_Alpha;
        C.StrLen("A", W, H );

        if( blink )
        {
            C.BorderColor = C.Static.MakeColor(253,191,68);
            C.DrawColor = C.Static.MakeColor(253,191,68);
        }
        else
        {
            C.BorderColor = WhiteColor;
            C.DrawColor = WhiteColor;
        }

        C.DrawColor.A = 255;

        BonusTex = MarioBonusTex[10];
        C.SetPos( XP,YP+2*(H+4));
        C.DrawTile(BonusTex, H,H, 0, 0, BonusTex.USize, BonusTex.VSize);

        C.bUseBorder = false;
    }
}

//____________________________________________________________________



defaultproperties
{
     texBomb1=Texture'XIIIMenu.HUD.iconebomb1'
     texBomb2=Texture'XIIIMenu.HUD.iconebomb2'
     texBomb3=Texture'XIIIMenu.HUD.iconebomb3'
     texBombOut=Texture'XIIIMenu.HUD.iconebombout'
     texChrono=Texture'XIIIMenu.HUD.HudIcons'
     BlinkTime=-1.000000
     BotBlinkTime=-1.000000
     sndTicTac1=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hBomBing'
     sndTicTac2=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hBombArmored'
     sndTicTacOff=Sound'XIIIsound.Multi__SFXMulti.SFXMulti__hBombOut'
}
