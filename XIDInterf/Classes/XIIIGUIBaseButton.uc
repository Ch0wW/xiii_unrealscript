class XIIIGUIBaseButton extends GUILabel;

var XIIIRootWindow myRoot;
var string Text;
var color     TextCol, TextHighlightCol, DarkColor, BackColor;
var bool bMouseEntered, bSmallFont;
var float fRatioX, fRatioY;
var sound hMenuCurseur;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Created();
	Super.InitComponent(MyController, MyOwner);
    OnActivate = MouseEnter;
    OnDeActivate = MouseLeave;
    OnPreDraw = InternalOnPreDraw;
	OnDraw = internalOnDraw;
	myRoot = XIIIWindow(MenuOwner).myRoot;
//    Caption = Text; // temporary ?
}


function Created();


function bool InternalOnPreDraw(Canvas C)
{
	local float OrgX, OrgY, nx, ny;

  if (XIIIPlayerController(XIIIWindow(MenuOwner).GetPlayerOwner()) != none && XIIIPlayerController(XIIIWindow(MenuOwner).GetPlayerOwner()).bRenderPortal)
    return true;

    fRatioX = XIIIWindow(MenuOwner).fRatioX;
    fRatioY = XIIIWindow(MenuOwner).fRatioY;

	OrgX = C.OrgX; 
    OrgY = C.OrgY;
    nx = WinLeft*640*fRatioX; 
    ny = WinTop*480*fRatioY;
    if (myRoot.bMapMenu || XIIIWindow(MenuOwner).bCenterInGame)
    {
        if (C.ClipX > 800) 
            nx = WinLeft*640*fRatioX + (C.ClipX-800)/2;
        if (C.ClipY > 600) 
            ny = WinTop*480*fRatioY + (C.ClipY-600)/2;
        C.SetOrigin(nx, ny);
        Bounds[0] = nx; 
        Bounds[1] = ny;
        Bounds[2] = WinWidth*640*fRatioX + Bounds[0]; 
        Bounds[3] = WinHeight*480*fRatioY + Bounds[1];
    }
	else
        C.SetOrigin(WinLeft*640*fRatioX, WinTop*480*fRatioY);
    C.Font = font'XIIIFonts.PoliceF16';
    //if ((myRoot.bIamInMulti) && (myRoot.GetLevel().NetMode == 0))
    //{
    //    C.Font = font'XIIIFonts.XIIIConsoleFont';
    //    Text = caps(Text);
    //}
    BeforePaint(C, 0, 0);

	C.SetOrigin(OrgX, OrgY);
    return true;
}


function bool InternalOnDraw(Canvas C)
{
	local float OrgX, OrgY, ClipX, ClipY, nx, ny;
  if (XIIIPlayerController(XIIIWindow(MenuOwner).GetPlayerOwner()) != none && XIIIPlayerController(XIIIWindow(MenuOwner).GetPlayerOwner()).bRenderPortal)
    return true;

    fRatioX = XIIIWindow(MenuOwner).fRatioX;
    fRatioY = XIIIWindow(MenuOwner).fRatioY;

	OrgX = C.OrgX; OrgY = C.OrgY;
	ClipX = C.ClipX; ClipY = C.ClipY;
    nx = WinLeft*640*fRatioX; 
    ny = WinTop*480*fRatioY;
    if (myRoot.bMapMenu || XIIIWindow(MenuOwner).bCenterInGame)
    {
        if (C.ClipX > 800) 
            nx = WinLeft*640*fRatioX + (C.ClipX-800)/2;
        if (C.ClipY > 600) 
            ny = WinTop*480*fRatioY + (C.ClipY-600)/2;
        C.SetOrigin(nx, ny);
    }
    else
        C.SetOrigin(WinLeft*640*fRatioX, WinTop*480*fRatioY);

    C.Font = font'XIIIFonts.PoliceF16';
    //if ((myRoot.bIamInMulti) && (myRoot.GetLevel().NetMode == 0))
    //    C.Font = font'XIIIFonts.XIIIConsoleFont';
    C.BorderColor = DarkColor;
    Paint(C, 0, 0);
    AfterPaint(C, 0, 0);

    C.SetOrigin(OrgX, OrgY);
    return true;
}


function BeforePaint(Canvas C, float X, float Y);

function Paint(Canvas C, float X, float Y)
{
}

function AfterPaint(Canvas C, float X, float Y);

function MouseEnter()
{
    bMouseEntered = true;
    myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
    SetFocus(Self);
}

function MouseLeave()
{
    bMouseEntered = false;
}


function SetTextColor(color NewCol)
{
    TextColor = NewCol;
}

final function DrawStretchedTexture( Canvas C, float X, float Y, float W, float H, texture Tex)
{
	local float OrgX, OrgY, ClipX, ClipY, nx, ny;

	if (W <= 1) W = W*640*fRatioX;
    if (H <= 1) H = H*480*fRatioY;
	OrgX = C.OrgX; OrgY = C.OrgY;
	ClipX = C.ClipX; ClipY = C.ClipY;
    nx = WinLeft*640*fRatioX; 
    ny = WinTop*480*fRatioY;
    if (myRoot.bMapMenu || XIIIWindow(MenuOwner).bCenterInGame)
    {
        if (C.ClipX > 800) 
            nx = WinLeft*640*fRatioX + (C.ClipX-800)/2;
        if (C.ClipY > 600) 
            ny = WinTop*480*fRatioY + (C.ClipY-600)/2;
        C.SetOrigin(nx, ny);
    }
    else
        C.SetOrigin(WinLeft*640*fRatioX, WinTop*480*fRatioY);
	C.SetClip(WinWidth*ClipX, WinHeight*ClipY);
	C.SetPos(X, Y);
    C.DrawTileClipped( Tex, W, H, 0, 0, Tex.USize, Tex.VSize);
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
}



defaultproperties
{
     TextCol=(B=50,G=160,R=255,A=255)
     TextHighlightCol=(A=255)
     DarkColor=(A=255)
     BackColor=(B=255,G=255,R=255,A=255)
     hMenuCurseur=Sound'XIIIsound.Interface.MnCurseur'
     bAcceptsInput=True
     bCaptureMouse=True
     bTabStop=True
     bFocusOnWatch=True
}
