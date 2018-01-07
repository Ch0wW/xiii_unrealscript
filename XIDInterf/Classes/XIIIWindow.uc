class XIIIWindow extends GUIPage;

var XIIIRootWindow myRoot;
var float fScaleTo, fRatioX, fRatioY;

var color HighlightColor, DefaultColor;
var color RedColor,BlueColor, WhiteColor, BlackColor, GoldColor, Grey3Color;

var  int       OnMenu;   // position of the cursor (for pad/key)
var bool bForceHelp, bShowRTN, bShowCCL, bShowACC, bShowSEL, bShowRUN, bShowBCK, bShowNXT, bShowSCH, bShowEDT, bShowCHO, bShowDEL, bShowSAV, bSaving, bSHowUPDATE;
var localized string HelpBarText;
var bool bDoQuitGame, bDoRestartGame, bCenterInGame;
var localized string ReturnText, CancelText, AcceptText, SelectText, CurrentText, StartText, BackText, NextText, SearchText, UpdateText;
var localized string EnterText, EscapeText, EditText, DeleteText, ChooseText, SaveText;

var texture tCancel, tAccept, tButton[8], tUpdate;

var sound hMenuOff, hMenuOn;
var bool bPlayingVideo;

var int ReturnCode;       // to be used with save game device
var bool bDisplayBar;
var config float SafeScreenPourcentageX, SafeScreenPourcentageY;
var localized string MyFailureMessage[14];
var string SaveName[73], DisplayedSaveName[73];

struct XIIIStringList
{
     var string Title;
     var array <localized string> slList;
     var int curSel;     // current selected item
     var float slWidth, slLeft, slTop;
};

struct XIIILabel
{
    var float XPos, YPos, XSize, YSize;
    var string sLabel;
};



//===================== Utility function to parse a list of options =========================
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//      taken from Gameinfo.uc
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

//
// Grab the next option from a string.
//
function bool localGrabOption( out string Options, out string Result )
{
  if( Left(Options,1)=="?" )
  {
    // Get result.
    Result = Mid(Options,1);
    if( InStr(Result,"?")>=0 )
      Result = Left( Result, InStr(Result,"?") );

    // Update options.
    Options = Mid(Options,1);
    if( InStr(Options,"?")>=0 )
      Options = Mid( Options, InStr(Options,"?") );
    else
      Options = "";

    return true;
  }
  else return false;
}

//
// Break up a key=value pair into its key and value.
//
function localGetKeyValue( string Pair, out string Key, out string Value )
{
  if( InStr(Pair,"=")>=0 )
  {
    Key   = Left(Pair,InStr(Pair,"="));
    Value = Mid(Pair,InStr(Pair,"=")+1);
  }
  else
  {
    Key   = Pair;
    Value = "";
  }
}

/* ParseOption()
 Find an option in the options string and return it.
*/
function string localParseOption( string Options, string InKey, string DefaultVal )
{
	local string Pair, Key, Value,s ;
	s="";
	while( localGrabOption( Options, Pair ) )
	{
		localGetKeyValue( Pair, Key, Value );
		if( Key ~= InKey )
			s = Value;
	}
	if (s=="")
		return DefaultVal;
	else
		return s;
}


function string ReturnFailureMessage(int ReturnCode)
{
	if ( ReturnCode >= 200 )
	{
		switch(ReturnCode)
		{
		case 200 : // name already exists
			return MyFailureMessage[0];
			break;
		case 201 : // name does not match the format rules
			return MyFailureMessage[9];
			break;
		case 202 : // name contains forbidden substrings
			return MyFailureMessage[4];
			break;
		case 203 : // name is reserved
			return MyFailureMessage[5];
			break;
		case 204 : // password does not match the format rules
			return MyFailureMessage[10];
			break;
		case 205 : // password contains username
			return MyFailureMessage[7];
			break;
		case 206 : // problem with the database
			return MyFailureMessage[8];
			break;
		case 207 : // account is banned
			return MyFailureMessage[11];
			break;
		case 208 : // account is temporarily closed
			return MyFailureMessage[12];
			break;
		case 209 : // account is closed
			return MyFailureMessage[13];
			break;
		}
	}
	else
	{
		if (( ReturnCode < 106 ) // array length
			&& ( ReturnCode >= 0 ))
			return class'MatchMakingManager'.Default.FailureMessages[ReturnCode];
		else
			return class'MatchMakingManager'.Default.FailureMessages[105];
	}
}





function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    OnOpen=ShowWindow;
	OnPreDraw = InternalOnPreDraw;
    OnDraw = InternalOnDraw;
    OnRender = InternalOnRender;
    OnKeyEvent=InternalOnKeyEvent;
	myRoot = XIIIRootWindow(MyController);
    Created();
    Super.Initcomponent(MyController, MyOwner);
}


function Created()
{
    fScaleTo = myRoot.fTextureScaleFactorForConsole;
    tAccept = tButton[myRoot.CurrentPF*2];
    tCancel = tButton[myRoot.CurrentPF*2 + 1];
}

function GUIComponent CreateControl(class<GUIComponent> CtrlClass, float X, float Y, float W, float H)
{
    local GUIComponent myChild;

    myChild = new(none) CtrlClass;
    myChild.WinLeft = X / 640.0;
    myChild.WinTop = Y / 480.0;//myRoot.ScreenHeight;
    myChild.WinWidth = W / 640.0;
    myChild.WinHeight = H / 480.0;//myRoot.ScreenHeight;

    return myChild;
}


function ShowWindow()
{
    if (!myRoot.bMapMenu) {
        defaultColor = Grey3Color;
        HighlightColor = BlackColor;
    }
    else {
        DefaultColor = default.DefaultColor;
        HighLightColor = default.HighLightColor;
    }
}

function BeforePaint(Canvas C, float X, float Y)
{
	fRatioX = C.ClipX / 640;
	fRatioY = C.ClipY / 480;

    if (myRoot.bMapMenu || bCenterInGame) {
        fRatioX = FClamp(fRatioX, 0.0, 800/640);
        fRatioY = FClamp(fRatioY, 0.0, 600/480);
    }

    if (myRoot.GetLevel().LevelAction == LEVACT_Loading)
    {
        myRoot.CloseAll(true);
        myRoot.GotoState('');
    }
}


function bool InternalOnPreDraw(Canvas C)
{
    local float nx, ny;

    if (XIIIPlayerController(GetPlayerOwner()) != none && XIIIPlayerController(GetPlayerOwner()).bRenderPortal)
      return true;

    nx = 0; ny = 0;
    if (myRoot.bMapMenu || bCenterInGame)
    {
        if (C.ClipX > 800) nx = WinLeft*C.ClipX + (C.ClipX-800)/2;
        if (C.ClipY > 600) ny = WinTop*C.ClipY + (C.ClipY-600)/2;
        C.SetOrigin(nx, ny);
    }

    //C.Font = font'XIIIFonts.PoliceF16';
    //if ((myRoot.bIamInMulti) && (myRoot.GetLevel().NetMode == 0) && (C.SizeX<640)&&(C.SizeY<448))
    //   C.Font = font'XIIIFonts.XIIIConsoleFont';

    BeforePaint(C, 0, 0);

    return true;
}

function bool InternalOnDraw(Canvas C)
{
    local float nx, ny;

    if (XIIIPlayerController(GetPlayerOwner()) != none && XIIIPlayerController(GetPlayerOwner()).bRenderPortal)
      return true;

    nx = 0; ny = 0;
    if (myRoot.bMapMenu || bCenterInGame)
    {
        if (C.ClipX > 800) nx = WinLeft*C.ClipX + (C.ClipX-800)/2;
        if (C.ClipY > 600) ny = WinTop*C.ClipY + (C.ClipY-600)/2;
        C.SetOrigin(nx, ny);
    }

    //C.Font = font'XIIIFonts.PoliceF16';
    //if ((myRoot.bIamInMulti) && (myRoot.GetLevel().NetMode == 0) && (C.SizeX<640)&&(C.SizeY<448))
    //   C.Font = font'XIIIFonts.XIIIConsoleFont';

    C.BorderColor = BlackColor;
    Paint(C, 0, 0);
    return true;
}

function InternalOnRender(Canvas C)
{
    local float nx, ny;

    if (XIIIPlayerController(GetPlayerOwner()) != none && XIIIPlayerController(GetPlayerOwner()).bRenderPortal)
      return;

    nx = 0; ny = 0;
    if (myRoot.bMapMenu || bCenterInGame)
    {
        if (C.ClipX > 800) nx = WinLeft*C.ClipX + (C.ClipX-800)/2;
        if (C.ClipY > 600) ny = WinTop*C.clipY + (C.ClipY-600)/2;
        C.SetOrigin(nx, ny);
    }

    //C.Font = font'XIIIFonts.PoliceF16';
    //if ((myRoot.bIamInMulti) && (myRoot.GetLevel().NetMode == 0) && (C.SizeX<640)&&(C.SizeY<448))
    //   C.Font = font'XIIIFonts.XIIIConsoleFont';

    AfterPaint(C, 0, 0);
    if (bDisplayBar)
       DisplayHelpBar(C);

	C.Style=1;
	if ( SafeScreenPourcentageX!=0 || SafeScreenPourcentageY!=0 )
	{
		C.DrawLine( C.ClipX*SafeScreenPourcentageX, C.ClipY*SafeScreenPourcentageY, C.ClipX*SafeScreenPourcentageX, C.ClipY*(1-SafeScreenPourcentageY), C.Static.MakeColor(255,0,0) );
		C.DrawLine( C.ClipX*(1-SafeScreenPourcentageX), C.ClipY*(1-SafeScreenPourcentageY), C.ClipX*SafeScreenPourcentageX, C.ClipY*(1-SafeScreenPourcentageY), C.Static.MakeColor(255,0,0) );
		C.DrawLine( C.ClipX*SafeScreenPourcentageX, C.ClipY*SafeScreenPourcentageY, C.ClipX*(1-SafeScreenPourcentageX), C.ClipY*SafeScreenPourcentageY, C.Static.MakeColor(255,0,0) );
		C.DrawLine( C.ClipX*(1-SafeScreenPourcentageX), C.ClipY*(1-SafeScreenPourcentageY), C.ClipX*(1-SafeScreenPourcentageX), C.ClipY*SafeScreenPourcentageY, C.Static.MakeColor(255,0,0) );
	}
}


function DisplayHelpBar(Canvas C)
{
    LOCAL float W, H, XPos, YPos, BarWidth, XOffset;
//    local float temp;
    LOCAL string myText;
	LOCAL int id;

	CONST BarHeight=32;

    // if many players
    if ( (myRoot.bIamInMulti) && (myRoot.GetLevel().NetMode == 0) && GetPlayerowner().Level.Game.NumPlayers!=1
		&& (myRoot.CurrentPF > 0)) //NetMode != 0 means 1 player on the local machine on LAN or Internet
    {
		XIIIBaseHud(GetPlayerowner().myHUD).InitViewPortId( C, false );
		id = XIIIBaseHud(GetPlayerowner().myHUD).ViewPortId;
		if ( GetPlayerowner().Level.Game.NumPlayers==2 )
		{
			switch ( id )
			{
			case 0: // en haut
				XPos = 30;
				BarWidth = C.ClipX-60;
				YPos = C.ClipY-BarHeight-10;
				break;
			case 1: // en bas
				XPos = 30;
				BarWidth = C.ClipX-60;
				YPos = C.ClipY-BarHeight-30;
				break;
			}
		}
		else
		{
			switch ( id )
			{
			case 0: // haut à gauche
				XPos = 30;
				BarWidth = C.ClipX-XPos-10;
				YPos = C.ClipY-BarHeight-10;
				break;
			case 1: // haut à droite
				XPos = 10;
				BarWidth = C.ClipX-XPos-30;
				YPos = C.ClipY-BarHeight-10;
				break;
			case 2: // bas à gauche
				XPos = 30;
				BarWidth = C.ClipX-XPos-10;
				YPos = C.ClipY-BarHeight-30;
				break;
			case 3: // bas à droite
				XPos = 10;
				BarWidth = C.ClipX-XPos-30;
				YPos = C.ClipY-BarHeight-30;
				break;
			}
		}
	}
	else
	{
		id = 0;
		XPos = 30;
		BarWidth = C.ClipX-XPos-30;
		if ( myRoot.CurrentPF==0 ) // PC
		{
			if ( ( C.ClipX > 800 ) && !(myRoot.bIamInGame) && !(myRoot.bIamInMulti) )
			{
				YPos = 600 - BarHeight - 6;
				BarWidth = 800 - XPos - 30;
			}
			else
				YPos = C.ClipY-BarHeight-6;
		}
		else // PS2, XBox, Cube
			YPos = C.ClipY-BarHeight-30;
	}

	if ((myRoot.bMapMenu || bForceHelp))
    {
        C.bUseBorder = true;
        DrawStretchedTexture(C, XPos, YPos, BarWidth, BarHeight, myRoot.FondMenu);
        C.bUseBorder = false;

        if (bShowSEL || bShowRUN || bShowNXT || bShowACC || bShowSCH || bShowEDT || bShowCHO )
        {
            if (myRoot.CurrentPF!=0)
            {
                DrawStretchedTexture(C, XPos+BarWidth-32+2, YPos + 2, 28, 28, tAccept);
                XOffset = 32;
            }
            else
            {
                if ( myRoot.CurrentPF == 0 )
					C.DrawColor = Grey3Color;
				else
					C.DrawColor = BlueColor;
                C.TextSize( EnterText, W, H);
                C.SetPos( XPos+BarWidth-W, YPos + (BarHeight-H)*0.5 );
                C.DrawText( EnterText, false);
                XOffset = W+3;
            }
            if (bShowSEL) myText = SelectText;
            if (bShowRUN) myText = StartText;
            if (bShowNXT) myText = NextText;
            if (bShowACC) myText = AcceptText;
            if (bShowSCH) myText = SearchText;
			if (bShowEDT) myText = EditText;
			if (bShowCHO) myText = ChooseText;

            C.Textsize(myText, W, H);
			C.SetPos( XPos+BarWidth-XOffset-W, YPos + (BarHeight-H)*0.5 );
            if ( myRoot.CurrentPF == 0 )
				C.DrawColor = Grey3Color;
			else
				C.DrawColor = BlackColor;
            C.DrawText(myText, false);
        }
        if (bShowRTN || bShowCCL || bShowBCK || bShowDEL || bShowSAV)
        {
            C.DrawColor = WhiteColor;
            if (myRoot.CurrentPF!=0)
            {
                DrawStretchedTexture(C, XPos+2, YPos+2, 28, 28, tCancel);
                XOffset = 32;
            }
            else
            {
                if ( myRoot.CurrentPF == 0 )
					C.DrawColor = Grey3Color;
				else
					C.DrawColor = RedColor;
                C.TextSize( EscapeText, W, H);
                C.SetPos( XPos, YPos + (BarHeight-H)*0.5 );
                C.DrawText( EscapeText, false);
                XOffset = W+3;
            }
            if (bShowRTN) myText = returnText;
            if (bShowCCL) myText = CancelText;
            if (bShowBCK) myText = BackText;
			if (bShowDEL) myText = DeleteText;
			if (bShowSAV) myText = SaveText;

            C.Textsize(myText, W, H);
			C.SetPos( XPos+XOffset, YPos + (BarHeight-H)*0.5 );
            if ( myRoot.CurrentPF == 0 )
				C.DrawColor = Grey3Color;
			else
				C.DrawColor = BlackColor;
            C.DrawText(myText, false);
        }
        if ( bSHowUPDATE )
        {
            myText = UpdateText;
            C.Textsize(myText, W, H);

			XPos = 0.5*C.ClipX-W/2;
            C.DrawColor = WhiteColor;
            DrawStretchedTexture(C, XPos, YPos+2, 28, 28, tUpdate);
            XOffset = 32;
            C.SetPos(XPos+XOffset, YPos + (BarHeight-H)*0.5 );
            if ( myRoot.CurrentPF == 0 )
				C.DrawColor = Grey3Color;
			else
				C.DrawColor = BlackColor;
            C.DrawText(myText, false);
        }
        if ( ( FocusedControl != none ) && ( HelpBarText == "" ) )
        {
            //C.Font = font'XIIIFonts.XIIIConsoleFont';
            C.Textsize( FocusedControl.Hint, W, H);
			if (( C.ClipX > 800 ) && ( myRoot.CurrentPF == 0 ))
				C.SetPos( (800-W)*0.5, YPos + (BarHeight-H)*0.5 );
			else
				C.SetPos( (C.ClipX-W)*0.5, YPos + (BarHeight-H)*0.5 );
            if ( myRoot.CurrentPF == 0 )
				C.DrawColor = Grey3Color;
			else
				C.DrawColor = BlackColor; //Grey3Color;
			C.DrawText( FocusedControl.Hint, false);
            //C.Font = font'XIIIFonts.PoliceF16';
        }
        else if ( HelpBarText != "" )
        {
            //C.Font = font'XIIIFonts.XIIIConsoleFont';
            C.Textsize( HelpBarText, W, H );
            C.SetPos( (C.ClipX-W)*0.5, YPos + (BarHeight-H)*0.5 );
            C.DrawColor = Grey3Color;
			C.DrawText( HelpBarText, false );
            //C.Font = font'XIIIFonts.PoliceF16';
        }
        C.DrawColor = WhiteColor;
    }
}

function Paint(Canvas C, float X, float Y)
{
    C.DrawColor = WhiteColor;
}


function AfterPaint(Canvas C, float X, float Y)
{
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if ( !bPlayingVideo)
	{
		if (Key==0x0D) {
			if (bShowSEL || bShowRUN || bShowNXT || bShowACC || bShowSCH || bShowEDT || bShowCHO || bShowSAV)
				GetPlayerOwner().PlayMenu(hMenuOn);
		}
		if (Key==0x08) {
			if (bShowRTN || bShowCCL || bShowBCK || bShowDEL)
				GetPlayerOwner().PlayMenu(hMenuOff);
		}
		return (Key != 0x73/*IK_F4*/); // as soon as a page is active, eat all the key event, except F4 !
	}
	return false;
}



final function DrawStretchedTexture( Canvas C, float X, float Y, float W, float H, texture Tex, optional float PosTexX, optional float PosTexY, optional float FactorX, optional float FactorY )
{   // NL - warning the same function exists in XIIIRootWindow (why ??)
    local float OrgX, OrgY, ClipX, ClipY, tW, tH;//, tx, ty;

    tW = Tex.USize; tH = Tex.VSize;
    OrgX = C.OrgX;
    OrgY = C.OrgY;
    ClipX = C.ClipX;
    ClipY = C.ClipY;

    C.SetPos(X, Y);
	if ( FactorY != 0 )
		C.DrawTileClipped( Tex, W*myRoot.GUIScale, H*myRoot.GUIScale, PosTexX, PosTexY, FactorX*(tW - 2*PosTexX), FactorY*(tH - 2*PosTexY));
	else
		C.DrawTileClipped( Tex, W*myRoot.GUIScale, H*myRoot.GUIScale, 0, 0, tW, tH);

    C.SetClip(ClipX, ClipY);
    C.SetOrigin(OrgX, OrgY);
}


//___________________________________________________________________________
// MLK: XIIILabel functions (init & display)

function InitLabel(out XIIILabel myL, float xp, float yp, float xs, float ys, string t)
{
    myL.XPos = xp; myL.YPos = yp; myL.XSize = xs; myL.YSize = ys;
    myL.sLabel = t;
}

function DrawLabel(Canvas C, XIIILabel myL, optional bool bNoCaps, optional bool bTransparency, optional bool bFixWidth )
{
    local float W, H, TextX, TextY;
	local float Offset;

	C.StrLen(MyL.sLabel, W, H);

	if ( !bFixWidth )
	{
		if ((W + 16*fRatioX) > myL.XSize)
		{
			Offset = W + 16*fRatioX - myL.XSize;
			myL.XSize += OffSet;
			if ( ( ( myL.XPos - OffSet/2 ) > 30 ) )
			{
				if ( myL.XPos + myL.XSize > 610 )
					myL.XPos -= Offset;
				else
					myL.XPos -= Offset/2;
			}
		}
	}
    TextX = (myL.Xsize*fRatioX - W) / 2;
	TextY = (myL.YSize*fRatioY - H) / 2;

    C.bUseBorder=true;
/*	if ( bTransparency )
	{
		C.Style = 5;
		C.DrawColor.A = 208;
	}*/
	C.Style = 1;
    DrawStretchedTexture(C, (myL.XPos+2)*fRatioX, (myL.YPos+2)*fRatioY, (myL.XSize-4)*fRatioX, (myL.YSize-4)*fRatioY, myRoot.FondMenu);
    C.bUseBorder=false;
	if(myL.sLabel != "")
	{
		C.DrawColor = HighlightColor;
        C.SetPos(myL.XPos*fRatioX + TextX, myL.YPos*fRatioY + TextY); C.DrawText(myL.sLabel, false);
		C.SetDrawColor(255,255,255);
	}
	C.Style = 1;
}


final function PlayerController GetPlayerOwner()
{
	return myRoot.GetPlayerOwner();
}




function SaveConfigs()
{
	if ( bSaving )
		return;
	bSaving=true;
    SaveConfig();
    if (GetPlayerOwner() != none)
    {
        GetPlayerOwner().SaveConfig();
        if (GetPlayerOwner().PlayerReplicationInfo != none) GetPlayerOwner().PlayerReplicationInfo.SaveConfig();
    }
    GotoState('WriteUserConfig');
}


State WriteUserConfig
{
Begin:
  if (!MyRoot.RequestWriteUserConfig())
  {
      log("Unable to write use config !");
  }
  else
  {
      while (!MyRoot.IsWriteUserConfigFinished(ReturnCode))
      {
          Sleep(0.1);
      }
      if (ReturnCode < 0)
      {
          log("Failed to write user config !");
      }
      else
      {
          log("user config successfull written");
      }
  }
  GotoState('CloseMenu');
}



State CloseMenu
{
Begin:
  myRoot.CloseMenu(true);
}





defaultproperties
{
     HighlightColor=(A=255)
     DefaultColor=(B=255,G=255,R=255,A=255)
     RedColor=(R=255,A=255)
     BlueColor=(B=255,A=255)
     WhiteColor=(B=255,G=255,R=255,A=255)
     BlackColor=(A=255)
     GoldColor=(B=71,G=193,R=238,A=255)
     Grey3Color=(B=127,G=127,R=127,A=255)
     ReturnText="Previous"
     CancelText="Cancel"
     AcceptText="Accept"
     SelectText="Select"
     StartText="Start"
     BackText="Back"
     NextText="Next"
     SearchText="Search"
     UpdateText="Update"
     EnterText="Enter"
     EscapeText="Escape"
     EditText="Edit"
     DeleteText="Delete"
     ChooseText="Choose"
     SaveText="Save options"
     tButton(0)=Texture'XIIIMenuStart.SoftRules_PC.bouton_select'
     tButton(1)=Texture'XIIIMenuStart.SoftRules_PC.bouton_back'
     tButton(2)=Texture'XIIIMenuStart.boutonC4A'
     tButton(3)=Texture'XIIIMenuStart.boutonC2A'
     tButton(4)=Texture'XIIIMenuStart.bouton1A'
     tButton(5)=Texture'XIIIMenuStart.bouton2A'
     tButton(6)=Texture'XIIIMenuStart.boutonB1A'
     tButton(7)=Texture'XIIIMenuStart.boutonB2A'
     tUpdate=Texture'XIIIMenuStart.bouton4A'
     hMenuOff=Sound'XIIIsound.Interface.MnAnnul'
     hMenuOn=Sound'XIIIsound.Interface.MnValid'
     bDisplayBar=True
     MyFailureMessage(0)="The account name already exists"
     MyFailureMessage(1)="- The account name must start with a letter"
     MyFailureMessage(2)="- The account name must be at least 3 characters long"
     MyFailureMessage(3)="- The account name must only contain letters, numbers, underscores, backslashes, dots or dashes"
     MyFailureMessage(4)="The account name contains forbidden substrings"
     MyFailureMessage(5)="The account name is reserved"
     MyFailureMessage(6)="- The password must be at least 2 characters long"
     MyFailureMessage(7)="- The password must not include your login"
     MyFailureMessage(8)="There is a problem with the database"
     MyFailureMessage(9)="The account name is invalid"
     MyFailureMessage(10)="The password is invalid"
     MyFailureMessage(11)="Your account is banned"
     MyFailureMessage(12)="Your account is temporarily closed. Retry later (15 min.)"
     MyFailureMessage(13)="Your account is locked"
     MyFailureMessage(14)="Could not access the external network device. Please check all connections and reconnect."
     SaveName(0)="Brighton Beach 1"
     SaveName(1)="Brighton Beach 2"
     SaveName(2)="Brighton Beach 3"
     SaveName(3)="Winslow Bank"
     SaveName(4)="Winslow Bank 1"
     SaveName(5)="Winslow Bank 2"
     SaveName(6)="FBI"
     SaveName(7)="FBI 1"
     SaveName(8)="FBI 2"
     SaveName(9)="Major Jones"
     SaveName(10)="Major Jones 1"
     SaveName(11)="Major Jones 2"
     SaveName(12)="Major Jones 3"
     SaveName(13)="Emerald Base bridge"
     SaveName(14)="Emerald Base roof"
     SaveName(15)="Carrington's cell "
     SaveName(16)="Carrington's cell 1"
     SaveName(17)="Carrington's cell 2"
     SaveName(18)="Cable car station"
     SaveName(19)="Cable car"
     SaveName(20)="Cable car 1"
     SaveName(21)="Kellownee Lake"
     SaveName(22)="Kellownee Lake 1"
     SaveName(23)="Kellownee hideout"
     SaveName(24)="Kellownee hideout 1"
     SaveName(25)="Plain Rock 1"
     SaveName(26)="Plain Rock 2"
     SaveName(27)="Plain Rock 3"
     SaveName(28)="Plain Rock 4"
     SaveName(29)="Doc Johansson"
     SaveName(30)="Doc Johansson 1"
     SaveName(31)="Canyon 1"
     SaveName(32)="Canyon 2"
     SaveName(33)="Canyon 3"
     SaveName(34)="Canyon 4"
     SaveName(35)="Canyon 5"
     SaveName(36)="Canyon 6"
     SaveName(37)="Sewage"
     SaveName(38)="SPADS camp 1"
     SaveName(39)="SPADS camp 2"
     SaveName(40)="SPADS camp 3"
     SaveName(41)="McCall"
     SaveName(42)="McCall 1"
     SaveName(43)="Submarine base"
     SaveName(44)="Submarine base 1"
     SaveName(45)="Submarine 1"
     SaveName(46)="Submarine 2"
     SaveName(47)="Submarine 3"
     SaveName(48)="Submarine 4"
     SaveName(49)="Sabotage"
     SaveName(50)="Sabotage 1"
     SaveName(51)="Quay 33"
     SaveName(52)="Quay 33-1"
     SaveName(53)="Bristol Suites Hotel"
     SaveName(54)="Bristol Suites Hotel 1"
     SaveName(55)="Sanctuary garden"
     SaveName(56)="Sanctuary garden 1"
     SaveName(57)="Sanctuary hall"
     SaveName(58)="Sanctuary hall 1"
     SaveName(59)="Sanctuary crypt"
     SaveName(60)="Sanctuary crypt 1"
     SaveName(61)="Sanctuary cliff"
     SaveName(62)="Sanctuary cliff 1"
     SaveName(63)="SSH1 base admission"
     SaveName(64)="SSH1 base admission 1"
     SaveName(65)="SSH1 base admission 2"
     SaveName(66)="SSH1 trap"
     SaveName(67)="SSH1 trap 1"
     SaveName(68)="Total Red"
     SaveName(69)="SSH1 final"
     SaveName(70)="SSH1 final 1"
     SaveName(71)="Lady Bee"
     SaveName(72)="Carrington's cell 3"
     DisplayedSaveName(0)="Brighton 1"
     DisplayedSaveName(1)="Brighton 2"
     DisplayedSaveName(2)="Brighton 3"
     DisplayedSaveName(3)="Winslow 1"
     DisplayedSaveName(4)="Winslow 2"
     DisplayedSaveName(5)="Winslow 3"
     DisplayedSaveName(6)="FBI 1"
     DisplayedSaveName(7)="FBI 2"
     DisplayedSaveName(8)="FBI 3"
     DisplayedSaveName(9)="Jones 1"
     DisplayedSaveName(10)="Jones 2"
     DisplayedSaveName(11)="Jones 3"
     DisplayedSaveName(12)="Jones 4"
     DisplayedSaveName(13)="Emerald 1"
     DisplayedSaveName(14)="Emerald 2"
     DisplayedSaveName(15)="Ben Carrington 1"
     DisplayedSaveName(16)="Ben Carrington 2"
     DisplayedSaveName(17)="Ben Carrington 3"
     DisplayedSaveName(18)="Emerald 3"
     DisplayedSaveName(19)="Emerald 4"
     DisplayedSaveName(20)="Emerald 5"
     DisplayedSaveName(21)="Kellownee 1"
     DisplayedSaveName(22)="Kellownee 2"
     DisplayedSaveName(23)="Kim Rowland 1"
     DisplayedSaveName(24)="Kim Rowland 2"
     DisplayedSaveName(25)="Plain Rock 1"
     DisplayedSaveName(26)="Plain Rock 2"
     DisplayedSaveName(27)="Plain Rock 3"
     DisplayedSaveName(28)="Plain Rock 4"
     DisplayedSaveName(29)="Edward Johansson 1"
     DisplayedSaveName(30)="Edward Johansson 2"
     DisplayedSaveName(31)="Arizona 1"
     DisplayedSaveName(32)="Arizona 2"
     DisplayedSaveName(33)="Arizona 3"
     DisplayedSaveName(34)="Arizona 4"
     DisplayedSaveName(35)="Arizona 5"
     DisplayedSaveName(36)="Arizona 6"
     DisplayedSaveName(37)="SPADS 1"
     DisplayedSaveName(38)="SPADS 2"
     DisplayedSaveName(39)="SPADS 3"
     DisplayedSaveName(40)="SPADS 4"
     DisplayedSaveName(41)="Seymour McCall 1"
     DisplayedSaveName(42)="Seymour McCall 2"
     DisplayedSaveName(43)="USS-Patriot 1"
     DisplayedSaveName(44)="USS-Patriot 2"
     DisplayedSaveName(45)="USS-Patriot 3"
     DisplayedSaveName(46)="USS-Patriot 4"
     DisplayedSaveName(47)="Franklin Edelbright 1"
     DisplayedSaveName(48)="Franklin Edelbright 2"
     DisplayedSaveName(49)="Resolute AFDM 1"
     DisplayedSaveName(50)="Resolute AFDM 2"
     DisplayedSaveName(51)="Maryland 1"
     DisplayedSaveName(52)="Maryland 2"
     DisplayedSaveName(53)="Bristol Hotel 1"
     DisplayedSaveName(54)="Bristol Hotel 2"
     DisplayedSaveName(55)="XX 1"
     DisplayedSaveName(56)="XX 2"
     DisplayedSaveName(57)="XX 3"
     DisplayedSaveName(58)="XX 4"
     DisplayedSaveName(59)="XX 5"
     DisplayedSaveName(60)="XX 6"
     DisplayedSaveName(61)="XX 7"
     DisplayedSaveName(62)="XX 8"
     DisplayedSaveName(63)="SSH1 - 1"
     DisplayedSaveName(64)="SSH1 - 2"
     DisplayedSaveName(65)="SSH1 - 3"
     DisplayedSaveName(66)="William Standwell"
     DisplayedSaveName(67)="Joseph Galbrain"
     DisplayedSaveName(68)="CalvinWax"
     DisplayedSaveName(69)="SSH1 - 4"
     DisplayedSaveName(70)="SSH1 - 5"
     DisplayedSaveName(71)="Lady Bee"
     DisplayedSaveName(72)="Ben Carrington 4"
     Background=Texture'XIIIMenuStart.menublanc'
     WinHeight=1.000000
}
