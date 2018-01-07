//============================================================================
// Press start page.
//
//============================================================================
class XIIIMenuPressStart extends XIIIWindow;

var localized string TitleXBoxText;		// message "Please press START to begin"
var string sBackground[4];				// texture filename
var texture tBackGround[4];			// texture handle
var texture tBackGroundBack;		// texture handle
var texture tBackGroundWhite;		// texture handle
var texture tBackGroundArrow;		// texture handle
var string sVideo;					// video filename
var VideoPlayer VP;                 // to play video
var string Copyright;

var int iPlaying;
var float fTimer;
var float fBlinkTimer;
var bool bDisplayTitle;

function Created()
{
    local int i;

    Super.Created();

	tBackGround[0] = texture(DynamicLoadObject(sBackGround[0], class'Texture'));
	tBackGround[1] = texture(DynamicLoadObject(sBackGround[1], class'Texture'));
	tBackGround[2] = texture(DynamicLoadObject(sBackGround[2], class'Texture'));
	tBackGround[3] = texture(DynamicLoadObject(sBackGround[3], class'Texture'));

//    bShowBCK = true;
//    bShowSEL = true;
	  bForceHelp = false;
	  
	  fTimer=0;
	  fBlinkTimer=0;
	  bDisplayTitle = false;
	  bDisplayBar = false;
}

function Paint(Canvas C, float X, float Y)
{
	local float W, H;
	local int i;
	local int iBoxLeft, iBoxTop;
	local int iArrowLeft;

	Super.Paint(C,X,Y);

	// draw black background
	C.bUseBorder = false;
	C.DrawColor = C.Static.MakeColor(0,0,0);
	C.SetPos(0,0);
	C.DrawTile(tBackGroundBack, C.SizeX, C.SizeY, 0, 0, tBackgroundBack.USize, tBackgroundBack.VSize );


	// draw background texture
	C.bUseBorder = false;
	C.BorderColor = BlackColor;
	C.DrawColor = WhiteColor;
	C.SetPos(C.SizeX/2-tBackGround[0].USize, 39 );
	C.DrawTile(tBackGround[0], tBackGround[0].USize,tBackGround[0].VSize, 0, 0, tBackGround[0].USize, tBackGround[0].VSize );
	C.SetPos(C.SizeX/2, 39 );
	C.DrawTile(tBackGround[1], tBackGround[1].USize,tBackGround[1].VSize, 0, 0, tBackGround[1].USize, tBackGround[1].VSize );
	C.SetPos(C.SizeX/2-tBackGround[0].USize, 39+tBackGround[0].VSize );
	C.DrawTile(tBackGround[2], tBackGround[2].USize,tBackGround[2].VSize, 0, 0, tBackGround[2].USize, tBackGround[2].VSize );
	C.SetPos(C.SizeX/2, 39+tBackGround[0].VSize );
	C.DrawTile(tBackGround[3], tBackGround[3].USize,tBackGround[3].VSize, 0, 0, tBackGround[3].USize, tBackGround[3].VSize );

	if ( bDisplayTitle )
	{
		// draw page title
		C.bUseBorder = false;
		C.BorderColor = C.Static.MakeColor(0,0,0);
		C.DrawColor = C.Static.MakeColor(255,196,175);

		C.TextSize(TitleXBoxText, W, H);
		
		iBoxLeft = 70;
		iBoxTop  = 70;

	    C.DrawColor.A = 92;
		C.Style = 5; // ERenderStyle.STY_Alpha;

		C.SetPos(iBoxLeft, iBoxTop);
		C.DrawTile(tBackGroundWhite, W+40,H+10, 0, 0, tBackGroundWhite.USize, tBackGroundWhite.VSize );
		
		// draw arrow
		iArrowLeft = iBoxLeft+110;
		C.bUseBorder = false;
		C.SetPos(iBoxLeft+iArrowLeft, iBoxTop-3+H+10);
		C.DrawTile(tBackGroundArrow, tBackGroundArrow.USize, tBackGroundArrow.VSize, 0, 0, tBackGroundArrow.USize, tBackGroundArrow.VSize );

		C.Style = 1; // ERenderStyle.STY_Normal;
		
		C.DrawColor = C.Static.MakeColor(0,0,0); // (248,211,108);
		C.SetPos(iBoxLeft+20, iBoxTop+5);
		C.DrawText(TitleXBoxText, false);

		C.DrawLine(iBoxLeft+iArrowLeft+8, iBoxTop+H+10, iBoxLeft+iArrowLeft+22, iBoxTop+H+10+22, C.Static.MakeColor(0,0,0) );
		C.DrawLine(iBoxLeft+iArrowLeft+22, iBoxTop+H+10, iBoxLeft+iArrowLeft+22, iBoxTop+H+10+22, C.Static.MakeColor(0,0,0) );
		
		C.DrawLine(iBoxLeft, iBoxTop+H+10, iBoxLeft+iArrowLeft+8, iBoxTop+H+10, C.Static.MakeColor(0,0,0) );
		C.DrawLine(iBoxLeft+iArrowLeft+22, iBoxTop+H+10, iBoxLeft+W+40, iBoxTop+H+10, C.Static.MakeColor(0,0,0) );
		C.DrawLine(iBoxLeft, iBoxTop, iBoxLeft+W+40, iBoxTop, C.Static.MakeColor(0,0,0) );
		C.DrawLine(iBoxLeft, iBoxTop, iBoxLeft, iBoxTop+H+10, C.Static.MakeColor(0,0,0) );
		C.DrawLine(iBoxLeft+W+40, iBoxTop, iBoxLeft+W+40, iBoxTop+H+10, C.Static.MakeColor(0,0,0) );
	}

	// copyright
	C.DrawColor = C.Static.MakeColor(248,211,108);
	C.SetPos(90, 400);
	C.DrawText(Copyright, false);
	// restore old param
	C.DrawColor = WhiteColor;
	C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	local int  iStatus;
	local bool bPlayingVideo;
	
    if (State==1) // IST_Press // to avoid auto-repeat
    {
		bPlayingVideo = false;

		if ( VP != none )
		{
			iStatus = VP.GetStatus();
			
			if ( iStatus == 1/*playing*/ )
			{
				bPlayingVideo = true;
				
				if ((Key==0x0F) || (Key==0xD4))/*IK_Enter or A button*/
				{
					VP.Stop();
					fTimer=0;
					fBlinkTimer=0;
					return true;
				}
			}
		}
		
		if ( !bPlayingVideo )
		{
			if (Key==0xD4) /*IK_Joy13 -> start*/
			{
				if (myroot.EndOfPressStartPage())
				{
					/* tell the engine we're not in the press start menu page anymore */
					myRoot.OpenMenu("XIDInterf.XIIIMenuSelectProfile");
				}
				else
				{
					myRoot.OpenMenu("XIDInterf.XIIIMenuFreeBlock");				
				}
				return true;
			}
		}
    }

    return super.InternalOnKeyEvent(Key, state, delta);
}

event Tick(float fDeltatime)
{
	local int i;
	
	fTimer = fTimer + fDeltatime;
	fBlinkTimer = fBlinkTimer  + fDeltatime;
	
	// blink title: on: 1sec, off: 0.5sec
	
	if ( !bDisplayTitle && (fBlinkTimer>0.5) )
	{
		bDisplayTitle = true;
		fBlinkTimer = fBlinkTimer - 0.5;
	}
	else if ( bDisplayTitle && (fBlinkTimer>1.0) )
	{
		bDisplayTitle = false;
		fBlinkTimer = fBlinkTimer - 1.0;
	}

	if ( (iPlaying==1) && (VP!=none) && (VP.GetStatus()==0) )
	{
		// end of video
		fTimer=0;
		iPlaying=0;
	}

	if ( VP!=none) iPlaying=VP.GetStatus();

	// display video
	if ( fTimer > 70 )
	{
		fTimer=-300;

        if ( VP == none )
          VP = new class'VideoPlayer';
        if ( (VP!=none) && (iPlaying==0) )
        {
          VP.Open(sVideo);
          VP.Play();
        }
	}
}


