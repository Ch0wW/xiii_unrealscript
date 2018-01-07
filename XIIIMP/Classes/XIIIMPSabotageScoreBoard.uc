//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPSabotageScoreBoard extends XIIIMPCTFScoreBoard;

function ShowScores( Canvas C , int ViewPortId , int PlayerNumber )
{
    local color BgColor;
    local int Loop;
    local string PName,PFrag,PDeath;
    local bool IsMe, HasTheBomb;
    local weapon MyBomb;
    local controller BombHolder,TmpC;
    local XIIIGameReplicationInfo TGRI;

    if ( PlayerOwner == none )
      return;

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

    DrawInfoLine( C,PlayerString,FragsString,DeathsString,HudBasicColor,HudBasicColor,false,PlayerNumber );
    YP += 8;

    //Players ...


    if ( Level.NetMode == NM_Standalone )
    {
        BombHolder = none;

        for (TmpC=Level.ControllerList; TmpC!=None; TmpC=TmpC.NextController )
        {
            if( TmpC.Pawn != none )
            {
                MyBomb = weapon(TmpC.Pawn.FindInventoryType(class'MPBomb'));

                if( ( MyBomb != none ) && (  MyBomb.AmmoType.AmmoAmount != 0 ) )
                {
                    BombHolder = TmpC;
                    break;
                }
            }
        }

        for ( Loop=0; Loop<PlayerCount; Loop++ )
        {
            IsMe = ( Ordered[Loop] == PlayerOwner.PlayerReplicationInfo );
            BgColor = Teamcolor[Ordered[Loop].Team.TeamIndex];

            PName = Ordered[Loop].PlayerName;
            PFrag = string( int(Ordered[Loop].Score));
            PDeath = string( int(Ordered[Loop].Deaths));

            if( ( BombHolder == none ) || ( BombHolder.PlayerReplicationInfo != Ordered[Loop] ) )
                HasTheBomb = false;
            else
                HasTheBomb = true;

            DrawInfoLine3( C, PName,PFrag,PDeath,HudBasicColor,BgColor,IsMe, HasTheBomb,PlayerNumber, Ordered[Loop].bWaitingPlayer, !Ordered[Loop].bReadyToPlay  );
        }
    }
    else
    {
        for (TmpC=Level.ControllerList; TmpC!=None; TmpC=TmpC.NextController )
        {
            if( ( TmpC.Pawn == none ) || ( TmpC.Pawn.Health == 0 ) )
            {
                XIIIPlayerReplicationInfo(TmpC.PlayerReplicationInfo).bHasTheBomb=false;
            }
            else
            {
                MyBomb = weapon(TmpC.Pawn.FindInventoryType(class'MPBomb'));

                if( ( MyBomb != none ) && (  MyBomb.AmmoType.AmmoAmount != 0 ) )
                {
                    XIIIPlayerReplicationInfo(TmpC.PlayerReplicationInfo).bHasTheBomb=true;
                }
                else
                    XIIIPlayerReplicationInfo(TmpC.PlayerReplicationInfo).bHasTheBomb=false;
            }
        }

        for ( Loop=0; Loop<PlayerCount; Loop++ )
        {
            IsMe = ( Ordered[Loop] == PlayerOwner.PlayerReplicationInfo );
            BgColor = Teamcolor[Ordered[Loop].Team.TeamIndex];

            PName = Ordered[Loop].PlayerName;
            PFrag = string( int(Ordered[Loop].Score));
            PDeath = string( int(Ordered[Loop].Deaths));

            if( ! XIIIPlayerReplicationInfo(Ordered[Loop]).bHasTheBomb )
                HasTheBomb = false;
            else
                HasTheBomb = true;

            DrawInfoLine3( C, PName,PFrag,PDeath,HudBasicColor,BgColor,IsMe, HasTheBomb,PlayerNumber, Ordered[Loop].bWaitingPlayer, !Ordered[Loop].bReadyToPlay  );
        }
    }


    if (TGRI.iGameState==3)
    {
        DrawTeamScore(C);
        PlayerOwner.MyHud.PlayMenu( XIIIBombHud(PlayerOwner.MyHud).sndTicTacOff );
    }

    // Trail

    GetDownMargin( C , ViewPortId , PlayerNumber );

    DrawTrailer(C);
}



defaultproperties
{
     strFlag="(Bomb)"
}
