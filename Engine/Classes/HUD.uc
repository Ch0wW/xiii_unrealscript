//=============================================================================
// HUD: Superclass of the heads-up display.
//=============================================================================
class HUD extends Actor
	native
	config(user);

//=============================================================================
// Variables.

#exec Texture Import File=Textures\Border.pcx COMPRESS=DXT1

//#exec new TrueTypeFontFactory PACKAGE="Engine" Name=MediumFont FontName="Arial Bold" Height=16 AntiAlias=1 CharactersPerPage=128
//#exec new TrueTypeFontFactory PACKAGE="Engine" Name=SmallFont FontName="Terminal" Height=10 AntiAlias=0 CharactersPerPage=256

// Stock fonts.
var font SmallFont;             // Small system font.
var font MedFont;               // Medium system font.
var font BigFont;               // Big system font.
var font LargeFont;             // Largest system font.

var string HUDConfigWindowType;
var HUD nextHUD;                // list of huds which render to the canvas
var PlayerController PlayerOwner; // always the actual owner

var ScoreBoard Scoring;
var bool bShowScores;
var bool bShowDebugInfo;        // if true, show properties of current ViewTarget
var bool bHideCenterMessages;   // don't draw centered messages (screen center being used)
var bool bBadConnectionAlert;   // display warning about bad connection
var() config bool bMessageBeep;
var bool bViewPlayer;           // if the viewtarget is the player (used to prevent some drawing while viewing another actor)
var bool bDrawChrono; // To display time left
var bool bDrawSixSense;           // To display SixSense SFX
var bool bDrawChronoWithWarningColors; // To display time left with warning colors

var localized string LoadingMessage;
var localized string SavingMessage;
var localized string ConnectingMessage;
var localized string PausedMessage;
var localized string PrecachingMessage;

var bool bHideHUD;              // Should the hud display itself.

struct HUDLocalizedMessage
{
	var Class<LocalMessage> Message;
	var int Switch;
	var PlayerReplicationInfo RelatedPRI;
	var Object OptionalObject;
	var float EndOfLife;
	var float LifeTime;
	var bool bDrawing;
	var int numLines;
	var string StringMessage;
	var color DrawColor;
	var font StringFont;
	var float XL, YL;
	var float YPos;
};
var string TextMessages[4];
var float MessageLife[4];

var Pawn PawnOwner;               // XIIIPawn of the PlayerOwner controller
var texture RoundBackGroundTex;   // Icon for backGroung
var texture FondMsg;              // to be used by HUDMsg(s) & HUDDlg(s)
var color HudWarningColor;
var color HudBasicColor;
var color HudBackGroundColor;
var float XP, YP;                 // Floats to track the current ScreenPosition.
var float IconSize;
var int LifeDisplayWidth, LifeDisplayHeight;  // used to memorize some StrLen params

var color OrangeColor,BlackColor,WhiteColor,GoldColor,RedColor,BlueColor,GreenColor,
  TurqColor,GrayColor,CyanColor,PurpleColor,LightGreenColor,LightBlueColor,LightPurpleColor;
var float fDrawSixSenseTimer[5];  // timer used w/ the bool bDrawSixSense
var vector vSixSensePos[5];       // on-screen Position to draw SixSense SFX
var texture SixSenseTex;          // texture used to 'display' sounds
var texture SixSenseDisplayTex;   // texture used to show the SixSense is active
var texture BulletIconTex;        // Background ammo

var float LeftMargin, RightMargin, UpMargin, DownMargin;  // for TV security draw, in %

var texture HudIcons;             // one-texture for player info display
var texture HudWIcons;            // one-texture Icons for weapon list display
var float fDrawChronoTimer;       // timer used w/ the bool above.
var string sChronoString;         // string to display (time left)

var Weapon DrawnWeapon;           // Weapon to draw info on screen
var float fDrawWeaponsTimer;      // timer used w/ the bool above.
var string sAmmoRef;              // string for drawing clips left in weapon
var bool HelpDisplay;

/* Draw3DLine()
draw line in world space. Should be used when engine calls RenderWorldOverlays() event.
*/
native final function Draw3DLine(vector Start, vector End, color LineColor);
native function DrawStdBackground(Canvas C, float Height, float CenterWidth);
native function DrawPlayerInfo(Canvas C);
native function DrawAmmo(Canvas C, String ItemText);
native function DrawWeaponsList(canvas C);

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayerOwner = PlayerController(Owner);
}

function SpawnScoreBoard(class<Scoreboard> ScoringType)
{
	if ( ScoringType != None )
	{
		Scoring = Spawn(ScoringType, PlayerOwner);
		Scoring.OwnerHUD = self;
	}
}

simulated event Destroyed()
{
	Super.Destroyed();
	if ( Scoring != None )
		Scoring.Destroy();
}

//=============================================================================
// Execs

/* toggles displaying scoreboard
*/
exec function ShowScores()
{
	bShowScores = !bShowScores;
	HelpDisplay = !HelpDisplay;
}

exec function HideScores()
{
	bShowScores = false;
	HelpDisplay = true;
}

/* toggles displaying properties of player's current viewtarget
*/
exec function ShowDebug()
{
	bShowDebugInfo = !bShowDebugInfo;
}

/* ShowUpgradeMenu()
Event called when the engine version is less than the MinNetVer of the server you are trying
to connect with.
*/
event ShowUpgradeMenu();

function PlayStartupMessage(byte Stage);

//=============================================================================
// Message manipulation

function ClearMessage(out HUDLocalizedMessage M)
{
	M.Message = None;
	M.Switch = 0;
	M.RelatedPRI = None;
	M.OptionalObject = None;
	M.EndOfLife = 0;
	M.StringMessage = "";
	M.DrawColor = class'Canvas'.Static.MakeColor(255,255,255);
	M.XL = 0;
	M.bDrawing = false;
}

function CopyMessage(out HUDLocalizedMessage M1, HUDLocalizedMessage M2)
{
	M1.Message = M2.Message;
	M1.Switch = M2.Switch;
	M1.RelatedPRI = M2.RelatedPRI;
	M1.OptionalObject = M2.OptionalObject;
	M1.EndOfLife = M2.EndOfLife;
	M1.StringMessage = M2.StringMessage;
	M1.DrawColor = M2.DrawColor;
	M1.XL = M2.XL;
	M1.YL = M2.YL;
	M1.YPos = M2.YPos;
	M1.bDrawing = M2.bDrawing;
	M1.LifeTime = M2.LifeTime;
	M1.numLines = M2.numLines;
}

//=============================================================================
// Status drawing.

simulated event WorldSpaceOverlays()
{
	if ( bShowDebugInfo && Pawn(PlayerOwner.ViewTarget) != None )
		DrawRoute();
}

simulated event PostRender( canvas Canvas )
{
	local HUD H;
	local float YL,YPos;
	local Pawn P;

	if ( !PlayerOwner.bBehindView )
	{
		P = Pawn(PlayerOwner.ViewTarget);
		if ( (P != None) && (P.Weapon != None) )
			P.Weapon.RenderOverlays(Canvas);
	}

//FIXMEJOE
/*
	if ( PlayerConsole.bNoDrawWorld )
	{
		Canvas.SetPos(0,0);
		Canvas.DrawPattern( Texture'Border', Canvas.ClipX, Canvas.ClipY, 1.0 );
	}
*/
	DisplayMessages(Canvas);
	bHideCenterMessages = DrawLevelAction(Canvas);

	if ( !bHideCenterMessages && (PlayerOwner.ProgressTimeOut > Level.TimeSeconds) )
		DisplayProgressMessage(Canvas);

	if ( bBadConnectionAlert )
		DisplayBadConnectionAlert(Canvas);

	if ( bShowDebugInfo )
	{
		YPos = 5;
		UseSmallFont(Canvas);
		PlayerOwner.ViewTarget.DisplayDebug(Canvas,YL,YPos);
	}
	else for ( H=self; H!=None; H=H.NextHUD )
		H.DrawHUD(Canvas);
}

simulated function DrawRoute()
{
	local int i;
	local Controller C;
	local vector Start, End;
	local bool bPath;

	C = Pawn(PlayerOwner.ViewTarget).Controller;
	if ( C == None )
		return;
	Start = PlayerOwner.ViewTarget.Location;

	// show where pawn is going
	if ( (C == PlayerOwner)
		|| (C.MoveTarget == C.RouteCache[0]) && (C.MoveTarget != None) )
	{
		if ( (C == PlayerOwner) && (C.Destination != vect(0,0,0)) )
		{
			if ( C.PointReachable(C.Destination) )
			{
				Draw3DLine(C.Pawn.Location, C.Destination, class'Canvas'.Static.MakeColor(255,255,255));
				return;
			}
			C.FindPathTo(C.Destination);
		}
		for ( i=0; i<16; i++ )
		{
			if ( C.RouteCache[i] == None )
				break;
			bPath = true;
			Draw3DLine(Start,C.RouteCache[i].Location,class'Canvas'.Static.MakeColor(0,255,0));
			Start = C.RouteCache[i].Location;
		}
		if ( bPath )
			Draw3DLine(Start,C.Destination,class'Canvas'.Static.MakeColor(255,255,255));
	}
	else if ( PlayerOwner.ViewTarget.Velocity != vect(0,0,0) )
		Draw3DLine(Start,C.Destination,class'Canvas'.Static.MakeColor(255,255,255));

	if ( C == PlayerOwner )
		return;

	// show where pawn is looking
	if ( C.Focus != None )
		End = C.Focus.Location;
	else
		End = C.FocalPoint;
	Draw3DLine(PlayerOwner.ViewTarget.Location + Pawn(PlayerOwner.ViewTarget).BaseEyeHeight * vect(0,0,1),End,class'Canvas'.Static.MakeColor(255,0,0));
}

/* DrawHUD() Draw HUD elements on canvas.
*/
function DrawHUD(canvas Canvas);

//____________________________________________________________________
function DrawWeaponIconsList(canvas C)
{
    DrawWeaponsList(C);
/*
    local string ItemText;
    local int Loop, NbWeapon, MaxWeaponIndex,AmmoPerCharger, Ammo;
    local float WeaponPos;
    local Weapon W,TW[22];
    local inventory I;

    NbWeapon = 0;
    I = PawnOwner.Inventory;
    // Add weapons in array TW
    while ( I != none )
    {
      W = Weapon(I);

//      if ( (W != none) && !((W.default.ReLoadCount==0) && !W.HasAmmo()) && (DecoWeapon(W) == none) && !W.bIsSlave )
      if ( (W != none) && !((W.default.ReLoadCount==0) && !W.HasAmmo()) && !W.IsA('DecoWeapon') && !W.bIsSlave )
      {
        TW[W.InventoryGroup] = W;
        MaxWeaponIndex = Max(MaxWeaponIndex, W.InventoryGroup);
        NbWeapon++;
      }
      I = I.Inventory;
    }

    // global pre draw init
    YP = C.ClipY * ( 1 - DownMargin ) - LifeDisplayHeight;
    WeaponPos = C.ClipX * ( 1 - RightMargin ) - (NbWeapon)*(2*LifeDisplayHeight+4) - LifeDisplayHeight;
    C.bUseBorder = false;
    C.Style = ERenderStyle.STY_Alpha;

    for( Loop=0; Loop<MaxWeaponIndex+1; Loop++)
    {
      if ( TW[Loop] != none )
      {
        W = TW[loop];
        // Draw Weapon
        if ( !W.HasAmmo() && !W.HasAltAmmo() )
          C.DrawColor = RedColor;
        else if ( ( W.WHand==WHA_2HShot ) && PawnOwner.bHaveOnlyOneHandFree )
          C.DrawColor = OrangeColor;
        else
          C.DrawColor = HudBasicColor*0.1;

        if ( W == DrawnWeapon )
          C.DrawColor.A= 140 ;
        else
          C.DrawColor.A= 70 ;

        C.SetPos( WeaponPos,YP);
        C.DrawRect(FondMsg, 2*LifeDisplayHeight,LifeDisplayHeight);
//        C.DrawTile(FondMsg, 2*LifeDisplayHeight,LifeDisplayHeight, 0, 0, FondMsg.USize, FondMsg.VSize);

        C.DrawColor= WhiteColor;
        if ( W == DrawnWeapon )
        {
          C.bUseBorder = true;
          C.BorderColor= HudBasicColor;
          C.BorderColor.A= 255;
        }

        C.SetPos(WeaponPos,C.CurY);
        C.DrawRect(W.Icon, 2*LifeDisplayHeight,LifeDisplayHeight);
//        C.DrawTile(W.Icon, 2*LifeDisplayHeight,LifeDisplayHeight, 0, 0, W.Icon.USize, W.Icon.VSize);
        C.bUseBorder = false;

        // Draw Ammo
        C.DrawColor = HudBasicColor;
        if ( W == DrawnWeapon )
          C.DrawColor.A = 255;
        else
          C.DrawColor.A = 150;

        if( W.default.ReLoadCount > 0 )
        {
          Ammo = W.Ammotype.AmmoAmount;
          AmmoPerCharger = W.default.ReLoadCount;
          Ammo /= AmmoPerCharger;
        }
        else
        {
          if ( (W.WHand == WHA_Fist) || (W.WHand == WHA_Deco) )
            Ammo = -1;
          else
            Ammo = W.Ammotype.AmmoAmount;
        }

        if( Ammo > 0 )
        {
          if( Ammo > 6 )
            Ammo = 6 ;
          ItemText = Left(sAmmoRef, Ammo);
          C.SetPos( WeaponPos,YP-LifeDisplayHeight/2-6 );
          C.DrawText(ItemText, false);
        }
        WeaponPos += 2*LifeDisplayHeight + 4;
      }
    }

    C.DrawColor = HudBasicColor*0.1;
    C.DrawColor.A= 70 ;

    C.SetPos( WeaponPos,YP);
    C.DrawTile(RoundBackGroundTex, LifeDisplayHeight,LifeDisplayHeight, 0, 0, -RoundBackGroundTex.USize, RoundBackGroundTex.VSize);

    WeaponPos= C.ClipX * ( 1 - RightMargin ) - (NbWeapon)*(2*LifeDisplayHeight+4) - 2*LifeDisplayHeight - 4;

    C.SetPos( WeaponPos,C.CurY);
    C.DrawTile(RoundBackGroundTex, LifeDisplayHeight,LifeDisplayHeight, 0, 0, RoundBackGroundTex.USize, RoundBackGroundTex.VSize);
*/
}

/*  Print a centered level action message with a drop shadow.
*/
function PrintActionMessage( Canvas C, string BigMessage )
{
	local float XL, YL;

	if ( Len(BigMessage) > 10 )
		UseLargeFont(C);
	else
		UseHugeFont(C);
	C.bCenter = false;
	C.StrLen( BigMessage, XL, YL );
	C.SetPos(0.5 * (C.ClipX - XL) + 1, 0.66 * C.ClipY - YL * 0.5 + 1);
	C.SetDrawColor(0,0,0);
	C.DrawText( BigMessage, false );
	C.SetPos(0.5 * (C.ClipX - XL), 0.66 * C.ClipY - YL * 0.5);
	C.SetDrawColor(0,0,255);;
	C.DrawText( BigMessage, false );
}

/* Display Progress Messages
display progress messages in center of screen
*/
simulated function DisplayProgressMessage( canvas Canvas )
{
	local int i;
	local float XL, YL, YOffset;
	local GameReplicationInfo GRI;

	PlayerOwner.ProgressTimeOut = FMin(PlayerOwner.ProgressTimeOut, Level.TimeSeconds + 8);
	Canvas.Style = ERenderStyle.STY_Normal;
	UseLargeFont(Canvas);
	YOffset = 0.3 * Canvas.ClipY;

	for (i=0; i<4; i++)
	{
		Canvas.DrawColor = PlayerOwner.ProgressColor[i];
		Canvas.StrLen(PlayerOwner.ProgressMessage[i], XL, YL);
		Canvas.SetPos(0.5 * (Canvas.ClipX - XL), YOffset);
		Canvas.DrawText(PlayerOwner.ProgressMessage[i], false);
		YOffset += YL + 1;
	}
	Canvas.SetDrawColor(255,255,255);
}

/* Draw the Level Action
*/
function bool DrawLevelAction( canvas C )
{
	local string BigMessage;

	if (Level.LevelAction == LEVACT_None )
	{
		if ( Level.Pauser != None )
			BigMessage = PausedMessage; // Add pauser name?
		else
		{
			BigMessage = "";
			return false;
		}
	}
	else if ( Level.LevelAction == LEVACT_Loading )
		BigMessage = LoadingMessage;
	else if ( Level.LevelAction == LEVACT_Saving )
		BigMessage = SavingMessage;
	else if ( Level.LevelAction == LEVACT_Connecting )
		BigMessage = ConnectingMessage;
	else if ( Level.LevelAction == LEVACT_Precaching )
		BigMessage = PrecachingMessage;

	if ( BigMessage != "" )
	{
		C.Style = ERenderStyle.STY_Normal;
		UseLargeFont(C);
		PrintActionMessage(C, BigMessage);
		return true;
	}
	return false;
}

/* DisplayBadConnectionAlert()
Warn user that net connection is bad
*/
function DisplayBadConnectionAlert(Canvas C);
//=============================================================================
// Messaging.

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	if ( bMessageBeep )
		PlayerOwner.PlayBeepSound();
	AddTextMessage(Msg,class'LocalMessage');
}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional string CriticalString );

simulated function PlayReceivedMessage( string S, string PName, ZoneInfo PZone )
{
	PlayerOwner.ClientMessage(S);
	if ( bMessageBeep )
		PlayerOwner.PlayBeepSound();
}

function bool ProcessKeyEvent( int Key, int Action, FLOAT Delta )
{
	if ( NextHud != None )
		return NextHud.ProcessKeyEvent(Key,Action,Delta);
	return false;
}

/* DisplayMessages() - display current messages
*/
function DisplayMessages(canvas Canvas)
{
	local int i, j, YPos;
	local float XL, YL;

	// first, clean up messages
	for ( i=0; i<4; i++ )
	{
		if ( TextMessages[i] == "" )
			break;
		else if ( MessageLife[i] < Level.TimeSeconds )
		{
			TextMessages[i] = "";
			if ( i < 3 )
			{
				for ( j=i; j<3; j++ )
				{
					TextMessages[j] = TextMessages[j+1];
					MessageLife[j] = MessageLife[j+1];
				}
			}
			TextMessages[3] = "";
			break;
		}
	}

	YPos = 0;
	UseSmallFont(Canvas);
	Canvas.SetDrawColor(0,255,255);
	for ( i=0; i<4; i++ )
	{
		if ( TextMessages[i] == "" )
			break;
		else
		{
			Canvas.StrLen( TextMessages[i], XL, YL );
			Canvas.SetPos(4, YPos);
			Canvas.DrawText( TextMessages[i], false );
			YPos += YL * (1 + int(XL/Canvas.ClipX));
		}
	}
}

function AddTextMessage(string M, class<LocalMessage> MessageClass)
{
	local int i;

	// look for empty spot
	for ( i=0; i<4; i++ )
		if ( TextMessages[i] == "" )
		{
			TextMessages[i] = M;
			MessageLife[i] = Level.TimeSeconds + MessageClass.Default.LifeTime;
			return;
		}

	// force add message
	for ( i=0; i<3; i++ )
	{
		TextMessages[i] = TextMessages[i+1];
		MessageLife[i] = MessageLife[i+1];
	}

	TextMessages[3] = M;
	MessageLife[3] = Level.TimeSeconds + MessageClass.Default.LifeTime;
}

//=============================================================================
// Font Selection.

function UseSmallFont(Canvas Canvas)
{
	Canvas.Font = Canvas.SmallFont;
    /* to prevent crash
    if ( Canvas.ClipX <= 640 )
		Canvas.Font = SmallFont;
	else
		Canvas.Font = MedFont;
    */
}

function UseMediumFont(Canvas Canvas)
{
	Canvas.Font = Canvas.SmallFont;
    /* to prevent crash
	if ( Canvas.ClipX <= 640 )
		Canvas.Font = MedFont;
	else
		Canvas.Font = BigFont;
    */
}

function UseLargeFont(Canvas Canvas)
{
	Canvas.Font = Canvas.SmallFont;
    /* to prevent crash
	if ( Canvas.ClipX <= 640 )
		Canvas.Font = BigFont;
	else
		Canvas.Font = LargeFont;
    */
}

function UseHugeFont(Canvas Canvas)
{
	Canvas.Font = Canvas.SmallFont;
    /* to prevent crash
	Canvas.Font = LargeFont;
    */
}

defaultproperties
{
     bMessageBeep=True
     LoadingMessage="LOADING"
     SavingMessage="SAVING"
     ConnectingMessage="CONNECTING"
     PausedMessage="PAUSED"
     HudWarningColor=(B=80,G=80,R=255,A=255)
     HudBasicColor=(B=210,G=252,R=255,A=230)
     HudBackGroundColor=(B=21,G=25,R=25,A=90)
     WhiteColor=(B=255,G=255,R=255,A=255)
     HelpDisplay=True
     bHidden=True
     bInteractive=False
     RemoteRole=ROLE_None
}
