//-----------------------------------------------------------
//
//-----------------------------------------------------------
class XIIIMPBotInteraction extends XIIIPlayerInteraction;

var Array<BotController> BotControllerList;
var bool IsInBotMnu,KeyIsRelease;
var localized string strTeamRole[3],strAllBot,strResetOrder;
var localized string strCTFRole[3],strBombDefendRole[3],strBombAttackRole[3];
var int CurrentBot,CurrentOrder,OrderPhase,InitialOrder[16];
var bool Up,Down,Left,Right;
var bool InputUp,InputDown,InputLeft,InputRight,InitInitialOrder;
var bool RepeatInputUp,RepeatInputDown,RepeatInputLeft,RepeatInputRight;
var texture Fond1,Fond2;
var color HudBasicColor,BgkColor;
var float InfoX,InfoY,InfoW,InfoH;
var sound MnuValid,MnuCancel,MnuSelect;
var bool InitParams;
var int GameType;

var enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
	STY_Alpha,
	STY_Particle
} Style;

//_____________________________________________________________________________
// EndMap - Prevent actor references before to change of map.
event EndMap()
{
    local int i;

    Super.EndMap();
    Master.RemoveInteraction(self);
    for( i=0 ; i<BotControllerList.Length ; i++)
    {
      BotControllerList[i] = none;
    }
}

//_________________________________________________________________________________

function InitCtrlParams()
{
    local int Loop;

    InitParams = true;

    if( GameType == 0 )
    {
        // CTF

        for( Loop=0 ; Loop < 3 ; Loop++ )
             strTeamRole[ Loop ] = strCTFRole[ Loop ];
    }
    else if( GameType == 1 )
    {
        // Bomb Defend

        for( Loop=0 ; Loop < 3 ; Loop++ )
             strTeamRole[ Loop ] = strBombDefendRole[ Loop ];
    }
    else if( GameType == 2 )
    {
        // Bomb Attack

        for( Loop=0 ; Loop < 3 ; Loop++ )
             strTeamRole[ Loop ] = strBombAttackRole[ Loop ];
    }
}

//_________________________________________________________________________________
/*
event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
    local int Loop;
    local int OldOrder;

    if( MyPC.IsInState('GameEnded') )
    {
        OrderPhase = -1;
        return false;
    }

    if ( (Level.NetMode != NM_StandAlone) || (BotControllerList.Length == 0) )
      return false;

    InputLeft = false;
    InputRight = false;
    InputUp = false;
    InputDown = false;

    Left = false;
    Right = false;
    Up = false;
    Down = false;

    switch( XIIIGameInfo(Level.Game).Plateforme )
    {
        case PF_PC :
                if( Key == IK_Joy13 ) Up = true;
                if( Key == IK_Joy15 ) Down = true;
                if( Key == IK_Joy16 ) Left = true;
                if( Key == IK_Joy14 ) Right = true;

                if( OrderPhase == -1 )
                {
                    if( Key == 222 ) Left = true;
                }
                else
                {
                    if( Key == 222 ) Left = true;
                    if( Key == 27 ) Left = true;
                }

                if( Key == 38 ) Up = true;
                if( Key == 40 ) Down = true;

                if( Key == 13 ) Right = true;

                break;
        case PF_PS2 :
                if( Key == IK_Joy13 ) Up = true;
                if( Key == IK_Joy15 ) Down = true;
                if( Key == IK_Joy16 ) Left = true;
                if( Key == IK_Joy14 ) Right = true;
                break;
        case PF_GC :
                if( Key == IK_Joy10 ) Up = true;
                if( Key == IK_Joy11 ) Down = true;
                if( Key == IK_Joy8  ) Left = true;
                if( Key == IK_Joy9  ) Right = true;
                break;
        case PF_XBOX :
                if( Key == IK_Joy9  ) Up = true;
                if( Key == IK_Joy10 ) Down = true;
                if( Key == IK_Joy11 ) Left = true;
                if( Key == IK_Joy12 ) Right = true;
                break;
    }

    if( Action==IST_Press )
    {
        if( Left )
        {
            if( !RepeatInputLeft )
            {
                InputLeft = true;
                RepeatInputLeft = true;
            }
        }
        else if( Right )
        {
            if( !RepeatInputRight )
            {
                InputRight = true;
                RepeatInputRight = true;
            }
        }
        else if( Up )
        {
            if( !RepeatInputUp )
            {
                InputUp = true;
                RepeatInputUp = true;
            }
        }
        else if( Down )
        {
            if( !RepeatInputDown )
            {
                InputDown = true;
                RepeatInputDown = true;
            }
        }
    }
    else if( Action==IST_Release )
    {
        if( Left )
        {
            RepeatInputLeft = false;
        }
        else if( Right )
        {
            RepeatInputRight = false;
        }
        else if( Up )
        {
            RepeatInputUp = false;
        }
        else if( Down )
        {
            RepeatInputDown = false;
        }
    }

    if( OrderPhase == -1 )
    {
        if( InputLeft )
        {
            if( ! InitInitialOrder )
            {
                InitInitialOrder = true;

                for( Loop=0;Loop<BotControllerList.Length;Loop++)
                     InitialOrder[Loop] = BotControllerList[ Loop ].TeamRole;

                if( ! InitParams )
                    InitCtrlParams();
            }

            OrderPhase = 0;

            MyPC.Pawn.PlaySound( MnuValid );
        }
    }
    else if( OrderPhase == 0 )
    {
        if( InputLeft )
        {
            OrderPhase = -1;
            MyPC.Pawn.PlaySound( MnuCancel );
        }
        else if( InputRight )
        {
            OrderPhase = 1;
            MyPC.Pawn.PlaySound( MnuValid );
        }
        else if( InputDown )
        {
            CurrentBot++;

            MyPC.Pawn.PlaySound( MnuSelect );

            if( CurrentBot == BotControllerList.Length)
                CurrentBot = -1;
        }
        else if( InputUp )
        {
            CurrentBot--;

            MyPC.Pawn.PlaySound( MnuSelect );

            if( CurrentBot == -2)
                CurrentBot = BotControllerList.Length-1;
        }
    }
    else if( OrderPhase == 1 )
    {
        if( InputLeft )
        {
            OrderPhase = 0;
            MyPC.Pawn.PlaySound( MnuCancel );
        }
        else if( InputRight )
        {
            if( CurrentOrder != -1 )
            {
                MyPC.Pawn.PlaySound( MnuValid );

                if( CurrentBot == -1 )
                {
                    for( Loop=0;Loop<BotControllerList.Length;Loop++)
                    {
                         OldOrder = BotControllerList[ Loop ].TeamRole;
                         BotControllerList[ Loop ].UpDateOrder( OldOrder,CurrentOrder );
                    }
                }
                else
                {
                     OldOrder = BotControllerList[ CurrentBot ].TeamRole;
                     BotControllerList[ CurrentBot ].UpDateOrder( OldOrder,CurrentOrder );
                }
            }
            else
            {
                MyPC.Pawn.PlaySound( MnuValid );

                if( CurrentBot == -1 )
                {
                    for( Loop=0;Loop<BotControllerList.Length;Loop++)
                    {
                        OldOrder = BotControllerList[ Loop ].TeamRole;
                        BotControllerList[ Loop ].UpDateOrder( OldOrder,InitialOrder[Loop] );
                    }
                }
                else
                {
                    OldOrder = BotControllerList[ CurrentBot ].TeamRole;
                    BotControllerList[ CurrentBot ].UpDateOrder( OldOrder,InitialOrder[CurrentBot] );
                }
            }

            OrderPhase = -1;
        }
        else if( InputDown )
        {
            CurrentOrder++;

            MyPC.Pawn.PlaySound( MnuSelect );

            if( CurrentOrder == 3)
                CurrentOrder = -1;

            if( ( GameType == 0 ) && ( CurrentOrder == 2 ) )
                CurrentOrder = -1;
        }
        else if( InputUp )
        {
            CurrentOrder--;

            MyPC.Pawn.PlaySound( MnuSelect );

            if( CurrentOrder == -2)
            {
                if( GameType == 0 )
                    CurrentOrder = 1;
                else
                    CurrentOrder = 2;
            }
        }
    }

    return false;
}
*/
//_________________________________________________________________________________

function AddIfoLine( Canvas C, string InfoTxt , bool AddBg )
{
    local color MsgColor;

    if( AddBg )
        MsgColor = HudBasicColor;
    else
        MsgColor = BgkColor;

    C.SpaceX = 0;

    // BackGround Icon + Text

    C.bUseBorder = false;
    C.Style = ERenderStyle.STY_Alpha;
    C.DrawColor = MsgColor;

    // BackGround Part 1

    C.SetPos(InfoX,InfoY);

    C.DrawTile(Fond2, InfoH-4,InfoH-4, 1, 0, Fond2.USize-1, Fond2.VSize);

    // BackGround Part 2

    C.DrawTile(Fond1, InfoW,InfoH-4, 0, 0, Fond1.USize, Fond1.VSize);

    // BackGround Part 3

    C.DrawTile(Fond2, InfoH-4,InfoH-4, -1, 0, -(Fond2.USize-1), Fond2.VSize );

    if( AddBg )
    {
        C.Style = ERenderStyle.STY_Translucent;

        C.DrawColor = MsgColor;
        C.DrawColor.A = 200;

        // BackGround Part 1

        C.SetPos(InfoX,InfoY);
        C.DrawTile(Fond2, InfoH-4,InfoH-4, 1, 0, Fond2.USize-1, Fond2.VSize);

        // BackGround Part 2

        C.DrawTile(Fond1, InfoW,InfoH-4, 0, 0, Fond1.USize, Fond1.VSize);

        // BackGround Part 3

        C.DrawTile(Fond2, InfoH-4,InfoH-4, -1, 0, -(Fond2.USize-1), Fond2.VSize );
    }

    // Text

    C.SpaceX = 1;

    C.Style=ERenderStyle.STY_Normal;

    C.DrawColor = BgkColor;
    C.DrawColor.R *= 0.3;
    C.DrawColor.G *= 0.3;
    C.DrawColor.B *= 0.3;
    C.SetPos(InfoX+InfoH-4+1,InfoY-1);
    C.DrawText(InfoTxt, false);

    C.DrawColor = HudBasicColor;
    C.SetPos(InfoX+InfoH-4,InfoY-2);
    C.DrawText(InfoTxt, false);

    InfoY += InfoH;
}

//_________________________________________________________________________________

simulated event MyPCPostRender(Canvas C)
{
    local string Txt;
    local int Loop;
    local float H,W,TmpW,TmpH;

    super.MyPCPostRender(C);

    if( BotControllerList.Length == 0 )
        return;

    if( OrderPhase == 0 )
    {
        C.Font = C.SmallFont;
        C.SpaceX = 1;

        C.strLen( strAllBot,InfoW,InfoH);

        for( Loop=0;Loop<BotControllerList.Length;Loop++)
        {
            Txt = BotControllerList[ Loop ].MyName@"-"@strTeamRole[BotControllerList[ Loop ].TeamRole];

            C.strLen( Txt,TmpW,InfoH);

            if( TmpW > InfoW )
                InfoW=TmpW;
        }

        InfoX = C.ClipX/2-InfoW/2-InfoH+4;
        InfoY = C.ClipY/2-InfoH*(BotControllerList.Length+1)/2;

        if( CurrentBot == -1 )
            AddIfoLine( C, strAllBot , true );
        else
            AddIfoLine( C, strAllBot , false );

        for( Loop=0;Loop<BotControllerList.Length;Loop++)
        {
            Txt = BotControllerList[ Loop ].MyName@"-"@strTeamRole[BotControllerList[ Loop ].TeamRole];

            if( Loop == CurrentBot )
                AddIfoLine( C, Txt , true );
            else
                AddIfoLine( C, Txt , false );
        }
    }
    if( OrderPhase == 1 )
    {
        C.Font = C.SmallFont;
        C.SpaceX = 1;

        C.strLen( strResetOrder,InfoW,InfoH);

        if( GameType == 0 )
        {
            for( Loop=0;Loop<2;Loop++)
            {
                C.strLen( strTeamRole[Loop],TmpW,InfoH);

                if( TmpW > InfoW )
                    InfoW=TmpW;
            }
        }
        else
        {
            for( Loop=0;Loop<3;Loop++)
            {
                C.strLen( strTeamRole[Loop],TmpW,InfoH);

                if( TmpW > InfoW )
                    InfoW=TmpW;
            }
        }

        InfoX = C.ClipX/2-InfoW/2-InfoH+4;
        InfoY = C.ClipY/2-InfoH*3/2;

        if( CurrentOrder == -1 )
            AddIfoLine( C , strResetOrder , true );
        else
            AddIfoLine( C , strResetOrder , false );

        if( GameType == 0 )
        {
            for( Loop=0;Loop<2;Loop++)
            {
                if( Loop == CurrentOrder )
                    AddIfoLine( C , strTeamRole[Loop] , true );
                else
                    AddIfoLine( C , strTeamRole[Loop] , false );
            }
        }
        else
        {
            for( Loop=0;Loop<3;Loop++)
            {
                if( Loop == CurrentOrder )
                    AddIfoLine( C , strTeamRole[Loop] , true );
                else
                    AddIfoLine( C , strTeamRole[Loop] , false );
            }
        }
    }
}



defaultproperties
{
     KeyIsRelease=True
     strAllBot="All"
     strResetOrder="Reset"
     strCTFRole(0)="Attack"
     strCTFRole(1)="Defense"
     strCTFRole(2)="Support"
     strBombDefendRole(0)="Defend Point 1"
     strBombDefendRole(1)="Defend Point 2"
     strBombDefendRole(2)="Defend Point 3"
     strBombAttackRole(0)="Attack Point 1"
     strBombAttackRole(1)="Attack Point 2"
     strBombAttackRole(2)="Attack Point 3"
     CurrentBot=-1
     CurrentOrder=-1
     OrderPhase=-1
     //Fond1=Texture'XIIIMenu.HUD.FondMsg'
     //Fond2=Texture'XIIIMenu.HUD.fondmsg2'
     HudBasicColor=(B=210,G=252,R=255,A=230)
     BgkColor=(B=63,G=76,R=77,A=90)
     //MnuValid=Sound'XIIIsound.Interface.MnValid'
     //MnuCancel=Sound'XIIIsound.Interface.MnAnnul'
     //MnuSelect=Sound'XIIIsound.Interface.MnCurseur'
}
