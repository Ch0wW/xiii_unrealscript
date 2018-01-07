class XIIICheckBoxControl extends XIIIGUIBaseButton;

var bool bChecked, bMouseOnYes, bMouseOnNo;
var float TextY, W, H, WYes, WNo;
var localized string sYes, sNo;
var bool bCalculateSize;
var float FirstBoxWidth, SecondBoxWidth;
var bool bWhiteColorOnlyWhenFocused;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
    OnKeyEvent=InternalOnKeyEvent;
}

function BeforePaint(Canvas C, float X, float Y)
{
	if ( bCalculateSize )
	{
		// no resize, we use default values for boxes
		FirstBoxWidth = WinWidth*640*fRatioX/2;
		SecondBoxWidth = WinWidth*640*fRatioX/5;
	}
	else
	{
		// boxes sizes are defined differently
		SecondBoxWidth = (WinWidth*640*fRatioX - FirstBoxWidth - 32*fRatioX)/2;
	}
    
	C.TextSize(/*Caps*/(Text), W, H);
    C.TextSize(/*Caps*/(sYes), WYes, H);
    C.TextSize(/*Caps*/(sNo), WNo, H);

	if ((W > FirstBoxWidth) || bSmallFont)
	{
		C.Font = font'XIIIFonts.XIIIConsoleFont';
		C.TextSize(/*Caps*/(Text), W, H);
		bSmallFont = true;
	}

    TextY = (WinHeight*480*fRatioY-H)/2;
	
	if ( (Controller.MouseX >= Bounds[0]) && (Controller.MouseX<=Bounds[2]) )
	{
		if ((Controller.MouseX-Bounds[0] >= (FirstBoxWidth + 16*fRatioX)) && (Controller.MouseX-Bounds[0] <= (FirstBoxWidth + SecondBoxWidth + 16*fRatioX)))
		{
			bMouseOnYes = true;
		}
		else if ((Controller.MouseX-Bounds[0] >= (FirstBoxWidth + SecondBoxWidth + 32*fRatioX)) && (Controller.MouseX-Bounds[0] <= WinWidth*640*fRatioX))
		{
			bMouseOnNo = true;
		}
		else
		{
			bMouseOnNo = false;
			bMouseOnYes = false;
		}
	}
}


function Paint(Canvas C, float X, float Y)
{
    local float XPos;

	C.Style = 5;
	
	if ((bVisible && bNeverFocus) || (bVisible && bWhiteColorOnlyWhenFocused))
		BackColor.A = 128;
	else
		BackColor.A = 255;

	if (bHasFocus)
		BackColor.A = 255;

	Super.Paint(C, X, Y);

	C.bUseBorder = true;
	C.DrawColor = BackColor;
	DrawStretchedTexture(C, 0, 0, FirstBoxWidth, WinHeight, myRoot.FondMenu);
	C.DrawColor = DarkColor;
	if (bSmallFont)
		C.Font = font'XIIIFonts.XIIIConsoleFont';
	C.SetPos((FirstBoxWidth - W)/2,TextY);
	C.DrawText(/*Caps*/(Text), false);

	C.DrawColor = BackColor;
	if (!bChecked)
		C.DrawColor.A = 127;
	else
		if (!bNeverFocus)
			C.DrawColor.A = 255;
	DrawStretchedTexture(C, FirstBoxWidth + 16*fRatioX, 0, SecondBoxWidth, WinHeight, myRoot.FondMenu);
	if (bChecked)
		C.DrawColor.A = 127;
	else
		if (!bNeverFocus)
			C.DrawColor.A = 255;
	DrawStretchedTexture(C, FirstBoxWidth + SecondBoxWidth + 32*fRatioX, 0, SecondBoxWidth, WinHeight, myRoot.FondMenu);
	C.DrawColor = DarkColor;
	C.Font = font'XIIIFonts.PoliceF16';
	if (bSmallFont)
	{
		C.TextSize(/*Caps*/(sNo), W, H);
		TextY = (WinHeight*480*fRatioY-H)/2;
	}
	C.SetPos(FirstBoxWidth + 16*fRatioX + (SecondBoxWidth - WYes)/2,TextY);
	C.DrawText(/*Caps*/(sYes), false);
	C.SetPos(FirstBoxWidth + SecondBoxWidth + 32*fRatioX + (SecondBoxWidth - WNo)/2,TextY);
	C.DrawText(/*Caps*/(sNo), false);
	C.bUseBorder = false;
	C.Style = 1;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (Key == 0x01)
	{
		if (bMouseOnNo)
			bChecked = false;
		if (bMouseOnYes)
			bChecked = true;
    }
    return false;
}



defaultproperties
{
     sYes="Yes"
     sNo="No"
     bCalculateSize=True
}
