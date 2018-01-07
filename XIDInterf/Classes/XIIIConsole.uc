//============================================================================
// The brain of the windowed system
// Handles the opening/closing of UWindow, the input events, etc...
//============================================================================
class XIIIConsole extends Console;

var bool bMapMenu; // MLK: True means no menu escape

var color GoldColor, BlackColor, DarkGoldColor;
var font ConsoleFont;
var texture ConsoleBk;
VAR XIIIQuickSLManager qsManager;
const ConsoleYOffset=4.0;


//____________________________________________________________________
// MLK    Launch/Close the Info Menu
exec function ShowTheMenu(XIIIPlayerController myC)
{
     local XIIIRootWindow myRoot; // XIIIRootWindow
     local controller P;
     local int i, j;

// DEBUG LOGGING
     log("VPO: "$ViewportOwner);
     log("myC: "$myC.Player);   // Replaces ViewportOwner in MP-Split games
// END

     myRoot = XIIIRootWindow(myC.Player.LocalInteractions[0]);
     if (Left(ViewportOwner.Actor.Level.GetLocalURL(), 7) ~= "mapmenu")
     {
         bMapMenu = true;
         myRoot.bIamInGame = false;
         myRoot.bIamInMulti = false;
        //ConsoleCommand("ExtendViewPortBeforeMenu");
		 if ( myRoot.IsInState( 'UWindows' ) )
			 myRoot.BeginState( );
		 else
	         myRoot.gotostate('UWindows');
         return;
     }
     else
     {
         bMapMenu = false;
         myRoot.gotostate('');
         myRoot.bIamInGame = false;
     }


     if (!bMapMenu)
     {
          if (myC.Player.Actor.Level.bLonePlayer)
          {
               log("IN ShowInfo");
               if (myRoot.bBriefing == false && XIIIGameInfo(myC.Player.Actor.Level.Game).MapInfo != none )
               {
                    log("NO BRIEFING");
                    if (!myRoot.bIamInGame)//if (!myRoot.IsInState('UWindows'))
                    {
                        log("INGAME");
                        myRoot.bIamInGame = true;
                        myRoot.gotostate('UWindows');
                    }
                    else
                    {
                        myRoot.CloseAll(true);
                        myRoot.gotostate('');
                        myRoot.bIamInGame = false;
                    }
               }
          }
          else
          {
               if (!myRoot.IsInState('UWindows'))
               {
                    log("INMULTI");
                    myRoot.bIamInMulti = true;
                    if (XIIIRootWindow(ViewportOwner.LocalInteractions[0]).bProfileMenu)
                        myRoot.bProfileMenu = true;
//                ConsoleCommand("ExtendViewPortBeforeMenu");
                    myRoot.gotostate('UWindows');
               }
               else
               {
                    if (!myRoot.bProfileMenu)
                    {
                        myRoot.CloseAll(true);
                        myRoot.gotostate('');
                        myRoot.bIamInMulti = false;
                        for ( P=myRoot.GetLevel().ControllerList; P!=None; P=P.NextController )
                        {
                            if (XIIIRootWindow(PlayerController(P).Player.LocalInteractions[0]).bIamInMulti == true)
                            myC.Player.Actor.SetPause( true );
                        }
//                 ConsoleCommand("RestoreViewPortAfterMenu");
                   }
               }
          }
     }
}


//____________________________________________________________________
// MLK    Launch/Close the Briefing screen
exec function ShowBriefing()
{
     local XIIIRootWindow myRoot;

     myRoot = XIIIRootWindow(ViewportOwner.LocalInteractions[0]);
     if (!myRoot.bBriefingDone)
     {
          myRoot.bBriefing = true;
          myRoot.gotostate('UWindows');
     }
}

exec function RestoreBriefing()
{
     local XIIIRootWindow myRoot;

     myRoot = XIIIRootWindow(ViewportOwner.LocalInteractions[0]);
     myRoot.bBriefingDone = false;
}


// ========================
// To be deleted
// ========================
exec function ShowMainMenu(XIIIPlayerController myC)
{
     local XIIIRootWindow myRoot;

     myRoot = XIIIRootWindow(myC.Player.LocalInteractions[0]);
     if (Left(myRoot.GetLevel().GetLocalURL(), 7) != "mapmenu")
     {
     log("SHOWGAMEMENU");
        myRoot.bIamInMulti = true;
        myRoot.GotoState('UWindows');
     }
}

state Typing
{
    function PostRender(Canvas C)
    {
      local float X,Y;
      local string OutStr;

      // Blank out a space

      C.Font = ConsoleFont;
      C.Style = 5; //ERenderStyle.STY_Alpha;
      C.bCenter = true;
      C.BorderColor = GoldColor;
      C.BorderColor.A = 128;
      C.bUseBorder = true;
      OutStr = "[("@caps(TypedStr)$"_ )]";
      C.Strlen(OutStr,X,Y);

      C.SetPos( (C.ClipX-X)/2-4, C.ClipY - ConsoleYOffset - 4 - Y);
      C.DrawColor = DarkGoldColor;
      C.DrawColor.A = 180;
      C.DrawTile( ConsoleBk, X+10, Y+4,0,0,ConsoleBk.USize,ConsoleBk.VSize);

/*      C.SetPos(0,C.ClipY-8-yl);
      C.SetDrawColor(0,255,0);
      C.DrawTile( texture'ConsoleBdr', C.ClipX, 2,0,0,32,32); */

//      C.SetPos( (C.ClipX-X)/2+2, C.ClipY - ConsoleYOffset - 3 - Y+2);
      C.SetPos( 1, C.ClipY - ConsoleYOffset - 3 - Y+1);
      C.DrawColor = BlackColor;
      C.DrawText( OutStr, false );
//      C.SetPos( (C.ClipX-X)/2, C.ClipY - ConsoleYOffset - 3 - Y);
      C.SetPos( 0, C.ClipY - ConsoleYOffset - 3 - Y);
      C.DrawColor = GoldColor;
      C.DrawColor.A = 200;
      C.DrawText( OutStr, false );
      C.BorderColor = BlackColor;
      C.bUseBorder = false;
    }
}

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	if (Action==1)
	{
		if ( ViewportOwner.Actor.Level.bLonePlayer && !(ViewportOwner.Actor.Level.Title~="mapmenu") )
		{
			if ( Key==0x74/*IK_F5*/ )
			{
                if ( ( qsManager==none || qsManager.bDeleteMe ) )
                {
                    qsManager = ViewportOwner.Actor.spawn( class'XIIIQuickSLManager', none );
                    if ( qsManager != none )
                    {
                        ViewportOwner.Actor.ClientMessage(ViewportOwner.Actor.QuickSaveString);
						qsManager.MyConsole = self;
                        qsManager.RequestQuickSave( );
                    }
                }
 				return true;
			}
			else if (  Key==0x78/*IK_F9*/ && ( qsManager==none || qsManager.bDeleteMe ) )
			{
                qsManager = ViewportOwner.Actor.spawn( class'XIIIQuickSLManager', none );
                if ( qsManager != none )
				{
					qsManager.MyConsole = self;
                    qsManager.RequestQuickLoad( );
				}
 				return true;
			}
		}
	}
	return Super.KeyEvent( Key, Action, Delta );
} 



defaultproperties
{
     GoldColor=(B=200,G=255,R=255,A=255)
     BlackColor=(A=255)
     DarkGoldColor=(B=100,G=128,R=128,A=255)
     ConsoleFont=Font'XIIIFonts.XIIIConsoleFont'
     ConsoleBK=Texture'XIIIMenu.HUD.FondMsg'
}
