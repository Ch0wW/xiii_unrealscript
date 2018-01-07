class XIIIGUIButton extends GUIButton;

var XIIIRootWindow myRoot;
var sound hMenuCurseur;
var bool bMouseEntered;

var float fRatioX,fRatioY;
var Color WhiteColor;
var Texture tArrow;
var bool bDrawArrows;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
    OnActivate = MouseEnter;
    OnDeActivate = MouseLeave;
  if (XIIIWindow(MenuOwner) != none)
	  myRoot = XIIIWindow(MenuOwner).myRoot;
	  
	OnDraw = InternalOnDraw;
  if (WinWidth<1)
  {
    WinWidth *= 640;
    WinHeight *= 480;
    WinTop *= 480;
    WinLeft *= 640;
  }
}

function MouseEnter()
{
  if (myRoot == none && XIIIWindow(MenuOwner) != none)
	  myRoot = XIIIWindow(MenuOwner).myRoot;
  bMouseEntered = true;
  if (myRoot != none)
    myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
  SetFocus(Self);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if (key==0x0D && State==1)	// ENTER Pressed
	{
    if (myRoot == none && XIIIWindow(MenuOwner) != none)
  	  myRoot = XIIIWindow(MenuOwner).myRoot;
    myRoot.GetPlayerOwner().PlayMenu(hMenuCurseur);
	}
  return super.InternalOnKeyEvent(Key, State, delta);
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
	//C.SetClip(WinWidth*ClipX, WinHeight*ClipY);
	log("Test "$Tex.USize);
	C.SetPos(X, Y);
    C.DrawTileClipped( Tex, W, H, 0, 0, Tex.USize, Tex.VSize);
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
}

function bool InternalOnDraw(Canvas C)
{
  /*
  local int X,Y;
  fRatioX = XIIIWindow(MenuOwner).fRatioX;
  fRatioY = XIIIWindow(MenuOwner).fRatioY;
  X = 10;
  Y = 10;
  if (myRoot == none && XIIIWindow(MenuOwner) != none)
	  myRoot = XIIIWindow(MenuOwner).myRoot;
	  
	log("Test "$fRatioY$" "$WinWidth$" "$WinHeight$" "$Tex.USize);
	//DrawStretchedTexture(C, 0, 0, FirstBoxWidth - 32*fRatioX, WinHeight*480*fRatioY, myRoot.FondMenu);
	DrawStretchedTexture(C, X - 16*fRatioX, Y, 16*fRatioX, WinHeight*480*fRatioY, myRoot.FondMenu);
	DrawStretchedTexture(C, 0, 0, 64, 64, myRoot.FondMenu);
	return true;
	*/
	local float OrgX, OrgY, ClipX, ClipY, nx, ny;

  if (!bDrawArrows)
    return false;
    
  if (MenuState != MSAT_Focused)
    return false;
    
  fRatioX = 1;//XIIIWindow(MenuOwner).fRatioX;
  fRatioY = 1;//XIIIWindow(MenuOwner).fRatioY;

	OrgX = C.OrgX; OrgY = C.OrgY;
	ClipX = C.ClipX; ClipY = C.ClipY;
  nx = WinLeft*640*fRatioX; 
  ny = WinTop*480*fRatioY;
  
  C.SetOrigin(0/*WinLeft*fRatioX*/, 0/*WinTop*fRatioY*/);

  //C.BorderColor = DarkColor;
  C.DrawColor = WhiteColor;

  //C.DrawLine( 0,0,500,500, WhiteColor );
  C.SetPos(WinLeft*fRatioX-28, WinTop*fRatioY+2);
  C.DrawTile( tArrow, 24, WinHeight*fRatioY-4, 0, 0, -tArrow.USize, tArrow.VSize);

  C.SetPos((WinLeft+WinWidth)*fRatioX+4, WinTop*fRatioY+2);
  C.DrawTile( tArrow, 24, WinHeight*fRatioY-4, 0, 0, tArrow.USize, tArrow.VSize);
	//DrawStretchedTexture(C, 0, 0, 64, 64, myRoot.FondMenu);
	//DrawStretchedTexture(C, nx - 16*fRatioX, ny, 16*fRatioX, WinHeight*480*fRatioY, myRoot.FondMenu);

  C.SetOrigin(OrgX, OrgY);
  return true;
}

function MouseLeave()
{
    bMouseEntered = false;
}



defaultproperties
{
     hMenuCurseur=Sound'XIIIsound.Interface.MnCurseur'
     WhiteColor=(B=255,G=255,R=255,A=255)
     tArrow=Texture'XIIIMenuStart.Interface_LoadGame.fleches'
     StyleName="SquareButton"
}
