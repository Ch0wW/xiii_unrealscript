//============================================================================
// this is the main window and is accessible from any window
// It handles the drawing of the background, the basic scaling ratio
// and the drawing of the side bars (if used)
//============================================================================
class XIIIRootWindow extends GUIController;

var texture tLoadTex, tFondNoir, FondMenu;
var string sFondMenu, sFondNoir;
var color BlackColor, FilterColor;

var XBoxLiveManager xboxLive;
var XIIILiveMsgBox MsgBox;

var float myJoyX, myJoyY, myCrossX, myCrossY;     // value of the pad axis/keyboard arrows
var bool  bFired, bClosed;//, bCanceled;             // confirm, quit and save, quit
var bool  bIamInGame, bIamInMulti, bProfileMenu, bXboxStartup; // which menu is active ?
var bool  bUpOrDown, bLeftOrRight, bUpOrDown2, bLeftOrRight2;    // Is a key/button being pressed
var bool  bFirstTime, bCinematic, bPressEsc, bBriefing, bOnline, bSkinMenuDone, bSkinMenuDisplayed;
var bool  bBriefingDone, bMapMenu, bCloseAfterLoading;

var float XS;//, _DT, _SH, fMaxSH, fadeAccum;//, _SN; //WinScale;
var float GUIScale;
var float fTextureScaleFactorForConsole;

var int CurrentPF, ScreenHeight;
var int JoyUP, JoyDOWN, JoyLEFT, JoyRIGHT;
var bool bMusicPlay, bShowFX;

var string SelectedProfileName;
var bool bPerformMemoryCardReDetection;

var config bool be3Version;
var int DefaultUserConfig;

var XIIISaveMenuStack SaveMenuStack;

var bool bStatsAlreadyDisplayed;


//var sound hMenuMuzik;

event InitializeController()
{
     log("CREATING ROOT WINDOW: "$self);
//     bFirstTime = true;
     super.InitializeController();
     FondMenu = texture(DynamicLoadObject(sFondMenu, class'Texture'));
     tFondNoir = texture(DynamicLoadObject(sFondNoir, class'Texture'));
     
     CableDisconnected = false;
}


event Tick(float DeltaTime)
{
  local int Status;
  local string ErrorMsg;
//    bSavingPossible=IsSavingMediaAvailable();
// bSaving always possible since save are done on DD
// but since bSavingPossible is used to display save
// menu option, bSavingPossible is bContinueWithoutSaving
// complement so save menu does'not appear when bContinueWithoutSaving
// is true
  bSavingPossible=!bContinueWithoutSaving;
  
  Status = GetConnectionStatus(ErrorMsg);
  if ((Status != 0) && !bStatsAlreadyDisplayed)
  {
    OpenMenu("XIDInterf.XIIIMenuLiveStatsWritePage", false, "netfailure");
    bStatsAlreadyDisplayed = true;
  }
}



event SetMenuStackBackup(string MenuStackAsText)
{
    local int i, Pos, NextPos, LastMenuStackTextLength;
    local string MenuStackText;

    if (MenuStackAsText != "")
    {
        if (SaveMenuStack == none)
        {
            SaveMenuStack = new(none) class'XIIISaveMenuStack';
        }
        else
        {
            SaveMenuStack.Menu.Length = 0;
        }

        i = 0;
        MenuStackText = "MenuStack"$i$"=";
        Pos = InStr(MenuStackAsText, MenuStackText);

        while (Pos != -1)
        {
            i++;
            LastMenuStackTextLength = Len(MenuStackText);
            MenuStackText = "MenuStack"$i$"=";
            NextPos = InStr(MenuStackAsText, MenuStackText);

            if (NextPos != -1)
            {
                SaveMenuStack.AddMenu(Mid(MenuStackAsText, LastMenuStackTextLength, NextPos-LastMenuStackTextLength));
                MenuStackAsText = Mid(MenuStackAsText, NextPos);
            }
            else
            {
                SaveMenuStack.AddMenu(Mid(MenuStackAsText, LastMenuStackTextLength));
            }

            Pos = NextPos;
        }
    }
}

event string GetMenuStackBackup()
{
    local string str;
    local int i;

    str = "";

    for (i=0;i<SaveMenuStack.Menu.Length;i++)
    {
        str = str $ "MenuStack"$i$"="$SaveMenuStack.Menu[i];
    }

    return str;
}

function RestoreMenuStack()
{
    local int i, FirstQuestionMarkPos;
    local string str;

    if (SaveMenuStack == none)
        return;

    for (i=0; i<SaveMenuStack.Menu.Length; i++)
    {
        str = SaveMenuStack.Menu[i];
        FirstQuestionMarkPos = InStr(str, "?");
        if (FirstQuestionMarkPos == -1)
        {
            OpenMenu(str, false);
        }
        else
        {
            OpenMenu(Left(str, FirstQuestionMarkPos), false);
            ActivePage.SetPageParameters(Mid(str, FirstQuestionMarkPos));
        }
    }
}


state UWindows
{
     function BeginState()
     {
          local int index;

          Super.BeginState();
          XIIIPlayerController(GetPlayerOwner()).bMenuIsActive = true;
          //log("BEGIN STATE: "$self);
          //log("-BeginState PO: "$GetPlayerOwner());

          bMapMenu = XIIIConsole(Master.GlobalInteractions[0]).bMapMenu;
          if (bMapMenu && ViewportOwner.Actor.Level.bLonePlayer) 
          {
               ViewportOwner.Actor.SetPause( false );
          }
          else
          {
    			  if ( ( GetLevel().Game.NumPlayers == 1 ) && ( GetLevel().NetMode == 0) )
                    ViewportOwner.Actor.SetPause( true );
                else
                    ViewportOwner.Actor.bIsInMenu=true;
          }
          if ( ViewportOwner.Actor.Level.Pauser!=none )
              GetPlayerOwner().PauseAllSounds();

          CurrentPF = 2;//int(XIIIGameInfo(ViewportOwner.Actor.Level.Game).PlateForme);
          ScreenHeight = 448;
          fTextureScaleFactorForConsole = ScreenHeight / 480.0;

          log("Loneplayer: "$ViewportOwner.Actor.Level.bLonePlayer);
          log("bSkinMenuDone :"$bSkinMenuDone);

          if (bMapMenu)
          {
			  bMusicPlay = true;
              
			  LoadMainMenu();
              InitController();

            if (SaveMenuStack != none)
            {
                RestoreMenuStack();
                SaveMenuStack = none;
            }
            else
            {
            if (xboxLive == none) // SouthEnd
              xboxLive = new class'xboxlivemanager';
            if (xboxLive.IsLoggedIn(xboxLive.GetCurrentUser()) )
            {
              OpenMenu("XIDInterf.XIIIMenu");

              xboxLive.SessionDelete();
            }
            else
            {
				OpenMenu("XIDInterf.XIIIMenuPressStart");
            }
           }
        }
        else
        {
          // MLK: Tests wether we're in SOLO mode or not
          if (ViewportOwner.Actor.Level.bLonePlayer)
          {
                        OpenMenu("XIDInterf.XIIIMenuInGame");
          }
          else
          {
              if (xboxLive == none) // SouthEnd
                xboxLive = new class'xboxlivemanager';
              // MLK add profile-menu here, then "Else if"
              if (bXboxStartup && xboxLive.IsLoggedIn(xboxLive.GetCurrentUser()))
              {
                OpenMenu("XIDInterf.XIIIMenuLiveStartup");
                bXboxStartup = false;
              }
              //else if (bProfileMenu)
              //  OpenMenu("XIDInterf.XIIIMenuProfileClient");
              else if (bIamInMulti)
              {
                if (xboxLive.IsLoggedIn(xboxLive.GetCurrentUser()) )
                  OpenMenu("XIDInterf.XIIIMenuInGameXboxLive");
                else
                  OpenMenu("XIDInterf.XIIIMenuInGameMulti");
              }
          }
        }
    }
    

    event CloseAll(bool bCancel)
    {
        local int i;

        if (bMapMenu)           // only save the menu stack in the main menu !
        {
            SaveMenuStack = new(none) class'XIIISaveMenuStack';
            
            for (i=0;i<MenuStack.Length;i++)
            {
                if (MenuStack[i].bDoStoreInSaveMenuStack)
                {
                    SaveMenuStack.AddMenu(MenuStack[i].GetPageParameters());
                }
            }
          }

        Super.CloseAll(bCancel);
     }


     function EndState()
     {
         log("END STATE: "$self);
          //CloseAll(true);
          XIIIPlayerController(GetPlayerOwner()).bMenuIsActive = false;
          if (bMapMenu)
          {
            XIIIConsole(Master.GlobalInteractions[0]).bMapMenu = false;
            bMapMenu = false;
          }
          bIamInGame = false;
          bIamInMulti = false;
          if ( ViewportOwner.Actor.Level.Pauser!=none )
              GetPlayerOwner().ResumeAllSounds();
          if ( ( GetLevel().Game.NumPlayers == 1 ) && ( GetLevel().NetMode == 0) )
              ViewportOwner.Actor.SetPause( false );
          else
              ViewportOwner.Actor.bIsInMenu=false;
          Super.EndState();
     }

}


final function PlayerController GetPlayerOwner()
{
        return ViewportOwner.Actor;
}

final function LevelInfo GetLevel()
{
        return ViewportOwner.Actor.Level;
}


function Printf(canvas C, string text, float x, float y, int maxlen)
{
     local string temp;
     local float XS, YS;
     local int maxchar, i;
//     local color blackcolor, oldcolor;

//     blackcolor.R = 0; blackcolor.G = 0; blackcolor.B = 0; blackcolor.A = 255;
//temp     C.Font = Fonts[F_Normal];
     C.StrLen("A", XS, YS);
     maxchar = (maxlen/XS) + 12;//14
     text = Caps(Text);
     while (text != "")
     {
          C.SetPos(x,y);
          temp = left(text, maxchar); y += YS;
          text = mid(text, maxchar);

          // MLK: draw full line if a blank char encountered -- empty line quits
          if ((text == "") || (left(text, 1) == " ") || (right(temp, 1) == " "))
          {
//               oldcolor = C.DrawColor; C.SetPos(x+1,y+1);
               C.DrawText(temp, false);
//               C.DrawColor = blackcolor; C.DrawText(temp, false); C.DrawColor = oldcolor;
          }
          else
          {
               i = maxchar;
               // MLK: Cut the last word and paste to the processed text
               while( left(mid(temp, i), 1) != " ")
                    i--;
               text = right(temp, maxchar-i-1)$text;
               temp = left(temp, i);
               C.DrawText(temp, false);
          }
     }
}


final function DrawStretchedTexture( Canvas C, float X, float Y, float W, float H, texture Tex )
{
        local float OrgX, OrgY, ClipX, ClipY, tW, tH;

    tW = Tex.USize; tH = Tex.VSize;
        OrgX = C.OrgX;
        OrgY = C.OrgY;
        ClipX = C.ClipX;
        ClipY = C.ClipY;

//      C.SetOrigin(OrgX + ClipX*GUIScale, OrgY + ClippingRegion.Y*GUIScale);
//      C.SetClip(ClippingRegion.W*GUIScale, ClippingRegion.H*GUIScale);

        C.SetPos(X, Y);//(X - ClippingRegion.X)*GUIScale, (Y - ClippingRegion.Y)*GUIScale);
        C.DrawTileClipped( Tex, W*GUIScale, H*GUIScale, 0, 0, tW, tH);

        C.SetClip(ClipX, ClipY);
        C.SetOrigin(OrgX, OrgY);
}

function SetControllerStatus(bool On)
{	// idem GUIController.uc but the requiresTick variable is set to true all the time

	bActive = On;
	bVisible = On;
//	bRequiresTick=On;
	bRequiresTick=true;

	// Attempt to Pause as well as show the windows mouse cursor.
	ViewportOwner.bShowWindowsMouse=On;

	// Add code to pause/unpause/hide/etc the game here.
	if (On)
		bIgnoreUntilPress = true;
	else
		ViewportOwner.Actor.ConsoleCommand("toggleime 0");
}




defaultproperties
{
     sFondMenu="XIIIMenuStart.menublanc"
     sFondNoir="XIIIMenuStart.menunoir"
     BlackColor=(A=255)
     FilterColor=(B=255,G=255,R=255)
     bFirstTime=True
     GUIScale=1.000000
     FontStack(0)=GUISmallFont'GUI.GUIController.GUI_SmallFont'
     FontStack(1)=GUIBigFont'GUI.GUIController.GUI_BigFont'
     StyleNames(0)="GUI.STY_SquareButton"
     StyleNames(1)="GUI.STY_Listbox"
     StyleNames(2)="GUI.STY_NoAlphaButton"
     StyleNames(3)="GUI.STY_ScaleButton"
     StyleNames(4)="GUI.STY_Label"
     StyleNames(5)="GUI.STY_LabelWhite"
     StyleNames(6)="GUI.STY_MsgBoxButton"
     MouseCursors(0)=Texture'XIIIMenuStart.MouseCursorM'
}
