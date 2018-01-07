class XIIIValueControl extends XIIIGUIBaseButton;

//var XIIIArrowButton leftArrow, rightArrow;

var int Value, minValue, maxValue;
var float TextX, ValX, TextY;
var texture tArrow;
var string sValue;
var bool bCalculateSize, bShowLeftArrow, bShowRightArrow;
var float FirstBoxWidth, CanvasClipX;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	OnKeyEvent = InternalOnKeyEvent;
}

/*
function Created()
{
    super.Created();
//    tArrow = texture(DynamicLoadObject("XIIIMenuStart.Load_game.fleches", class'Texture'));
}
*/
function SetArrows()
{
/*     leftArrow = XIIIArrowbutton(NotifyWindow.CreateControl(class'XIIIArrowbutton', Winleft + 200, WinTop + 4, 12, 12));
     leftArrow.OwnerWindow = self;
     leftArrow.bLeftOrient = true;
     rightArrow = XIIIArrowbutton(NotifyWindow.CreateControl(class'XIIIArrowbutton', WinLeft + 204, WinTop + 4, 12, 12));
     rightArrow.OwnerWindow = self;*/
}

FUNCTION SetRange( int Vmin, int Vmax )
{
	minValue = Vmin;
	maxValue = Vmax;
}

function BeforePaint(Canvas C, float X, float Y)
{
    local float W, H;
	
	if ( bCalculateSize )
	{
		C.TextSize(/*/Caps*/(Text), W, H);
		TextX = ((2*WinWidth*640*fRatioX)/3 - W)/2;
		TextY = (WinHeight*480*fRatioY - H)/2;
		C.TextSize(sValue, W, H);
		ValX = (2*WinWidth*640*fRatioX)/3 + ((WinWidth*640*fRatioX)/3 - W + 16)/2;
	}
	else
	{
		C.TextSize(/*Caps*/(Text), W, H);
		TextX = (FirstBoxWidth - W)/2;
		TextY = (WinHeight*480*fRatioY - H)/2;
		C.TextSize(sValue, W, H);
		ValX = FirstBoxWidth + (WinWidth*640*fRatioX - FirstBoxWidth - W + 16)/2;
	}
}

function Paint(Canvas C, float X, float Y)
{
	local float W,H;

//     C.SetPos(X, Y);
	CanvasClipX = C.ClipX;

	C.Style = 5;
	if ( bCalculateSize )
	{
		if (bHasFocus)
            BackColor.A = 255;
        else 
            BackColor.A = 128;
		C.DrawColor = BackColor;
		C.bUseBorder = true;
		DrawStretchedTexture(C, 0, 0, (2*WinWidth*640*fRatioX)/3, WinHeight*480*fRatioY, myRoot.FondMenu);
		DrawStretchedTexture(C, (2*WinWidth*640*fRatioX)/3 + 40, 6, (WinWidth*640*fRatioX)/3 - 64, WinHeight*480*fRatioY - 12, myRoot.FondMenu);
		C.bUseBorder = false;
		
		if ( bShowLeftArrow )
		{
			C.SetPos((2*WinWidth*640*fRatioX)/3 + 16, 4);
			C.DrawTile( tArrow, 16, WinHeight*480*fRatioY - 8, tArrow.USize, 0, -tArrow.USize, tArrow.VSize );
		}
		if ( bShowRightArrow )
		{
			C.SetPos(WinWidth*640*fRatioX - 16, 4);
			C.DrawTile( tArrow, 16, WinHeight*480*fRatioY - 8, 0, 0, tArrow.USize, tArrow.VSize );
		}
		
		C.DrawColor = TextColor;
		C.SetPos(TextX,TextY);
		C.DrawText(/*Caps*/(Text), false);
		C.SetPos(ValX,TextY);
		C.DrawText(sValue, false);
	}
	else
	{
		if (bHasFocus)
			BackColor.A = 255;
		else
			BackColor.A = 128;
		C.DrawColor = BackColor;
		C.bUseBorder = true;
		DrawStretchedTexture(C, 0, 0, FirstBoxWidth, WinHeight*480*fRatioY, myRoot.FondMenu);
		DrawStretchedTexture(C, FirstBoxWidth + 40, 6, WinWidth*640*fRatioX - FirstBoxWidth - 64, WinHeight*480*fRatioY - 12, myRoot.FondMenu);
		C.bUseBorder = false;
		
		if ( bShowLeftArrow )
		{
			C.SetPos(FirstBoxWidth + 16, 4);
			C.DrawTile( tArrow, 16, WinHeight*480*fRatioY - 8, tArrow.USize, 0, -tArrow.USize, tArrow.VSize );
		}
		if ( bShowRightArrow )
		{
			C.SetPos(WinWidth*640*fRatioX - 16, 4);
			C.DrawTile( tArrow, 16, WinHeight*480*fRatioY - 8, 0, 0, tArrow.USize, tArrow.VSize );
		}
		
		C.DrawColor = TextColor;
		C.SetPos(TextX,TextY);
		C.DrawText(/*Caps*/(Text), false);
		C.SetPos(ValX,TextY);
		C.DrawText(sValue, false);
	}
	C.Style = 1;
}

function SetValue(int v)
{
     Value = v; //Clamp( v, minValue, maxValue );
	 bShowLeftArrow =  (v!=minValue);
	 bShowRightArrow =  (v!=maxValue);
     sValue = string(Value);
}

function int GetValue()
{
     return Value;
}

function bool InternalOnClick( out byte Key )
{
	LOCAL float RelativeX, LeftArrowLeft, RightArrowLeft;

    if ( (myRoot.bMapMenu || XIIIWindow(MenuOwner).bCenterInGame) && (CanvasClipX > 800) )
		RelativeX = ((Controller.MouseX-(CanvasClipX-800)*0.5)/fRatioX-WinLeft*640);
	else
		RelativeX = (Controller.MouseX/fRatioX-WinLeft*640);

	
//	RelativeX = Controller.MouseX - WinLeft*640;

//	LOG ( "POS:"@RelativeX );
//	LOG ( "LEFT"@(2*WinWidth*640*fRatioX)/3 + 16-4 );
//	LOG ( "RIGHT"@WinWidth*640*fRatioX - 16 );

	if ( bCalculateSize )
	{
		RightArrowLeft = WinWidth*640 - 16-4;
		LeftArrowLeft = (2*WinWidth*640)/3 + 16-4;
	}
	else
	{
		RightArrowLeft = WinWidth*640 - 16-4;
		LeftArrowLeft = FirstBoxWidth/fRatioX + 16-4;
	}

	if ( bShowRightArrow  )
	{
		if ( RelativeX>=RightArrowLeft && RelativeX<RightArrowLeft+24)
		{
			Key = 0x27;
		}
	}
	if ( bShowLeftArrow )
	{
		if ( RelativeX>=LeftArrowLeft && RelativeX<LeftArrowLeft+24 )
		{
			Key = 0x25;
		}
	}

	return false;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ( ( bShowRightArrow || bShowLeftArrow ) && Key==0x01 && State==1 )
	{
		return InternalOnClick( Key );
	}
	return false;
}



defaultproperties
{
     tArrow=Texture'XIIIMenuStart.Interface_LoadGame.fleches'
     bCalculateSize=True
     bShowLeftArrow=True
     bShowRightArrow=True
}
