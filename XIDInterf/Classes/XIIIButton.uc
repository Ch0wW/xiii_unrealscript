class XIIIButton extends XIIIGUIBaseButton;

var  int       TextX, TextY;
var int fadevalue, speed;
var bool bGlassLook, bUseBorder, bNoBg, bfadein, bflash;
var int NbMultiSplit;
var color BoxColor;


function created()
{
    super.created();
    TextAlign = TXTA_Center;
}


function ResetTextColor()
{
     if (myRoot.bIamInGame || myRoot.bIamInMulti) 
         SetTextColor(BackColor);
     else 
         SetTextColor(TextCol);
}


//____________________________________________________________________
// MLK    Set the text font and position
function BeforePaint(Canvas C,float X, float Y)
{
	local float W, H;

    //if ((myRoot.bIamInMulti) && (myRoot.GetLevel().NetMode == 0))
    //    C.Font = font'XIIIFonts.XIIIConsoleFont';
    //else 
	C.Font = font'XIIIFonts.PoliceF16';
	C.TextSize(/*CAPS*/(Text), W, H);

	if ( NbMultiSplit >= 2 )
	{
		if ( NbMultiSplit == 2 )
		{
			// split screen mode with two viewports
			if (TextAlign == TXTA_Center) 
				TextX = (WinWidth*640 - W)/2;
			TextY = (WinHeight*480 - H)/8;
		}
		else
		{
			// split screen mode with four viewports
			if (TextAlign == TXTA_Center) 
				TextX = (WinWidth*640/2 - W)/2;
			TextY = (WinHeight*480 - H)/8;
		}
	}
	else
	{
		if (TextAlign == TXTA_Center) 
			TextX = Max(0,(WinWidth*640*fRatioX - W)/2);
		TextY = (WinHeight*480*fRatioY - H)/2;
	}

	if (bfadein) 
	{
		fadevalue+=speed; 
		if (fadevalue > 255) 
		{
			bfadein = false; 
			fadevalue = 255;
		}
	}
	if (bflash) 
	{
		fadevalue+=speed; 
		if (fadevalue > 254) 
		{
			fadevalue = 255; 
			speed = -speed/2;
		}
		if (fadevalue < 0) 
		{
			bflash = false; 
			speed = 8; 
		}
	}
}


//____________________________________________________________________
// MLK    Print the text clipped to the dimensions of the button
function Paint(Canvas C, float X, float Y)
{
	LOCAL int OldClipX;
//    if (C.Viewport != myRoot.ViewportOwner) return;
    super.Paint(C,X,Y);

    //if ((myRoot.bIamInMulti) && (myRoot.GetLevel().NetMode == 0))
    //    C.Font = font'XIIIFonts.XIIISmallFont';
    //else 
        C.Font = font'XIIIFonts.PoliceF16';

    C.Style = 5;
    if (!bNoBg) 
    {
        if ( BoxColor != BackColor )
		{
			C.DrawColor = BoxColor;
			if (bGlassLook) 
			{
				if (bHasFocus) 
					C.DrawColor.A = 240;
				else 
					C.DrawColor.A = 208;
			}
		}
		else
		{
			C.DrawColor = BackColor;
			if (bGlassLook) 
			{
				if (bHasFocus) 
					C.DrawColor.A = 255;
				else 
					C.DrawColor.A = 128;
			}
		}
        C.bUseBorder = bUseBorder;
        DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, myRoot.FondMenu);
        C.bUseBorder = false;
    }
    else 
    {
        if (bHasFocus) 
            TextColor.A = 255;
        else 
            TextColor.A = 128;
    }
    if(Text!= "")
    {
        C.DrawColor = TextColor;
        if (bfadein || bflash) 
        {
            C.Style = 5; 
            C.DrawColor.A = fadevalue;
        }
        else 
            C.Style = 1;
        C.SetPos(TextX, TextY);
		OldClipX = C.ClipX;
		C.ClipX = WinWidth*640*fRatioX-2;
        C.DrawTextClipped(Text, false);
		C.ClipX = OldClipX;
    }
    C.Style = 1;
}




defaultproperties
{
     Speed=4
     bGlassLook=True
     bUseBorder=True
     BoxColor=(B=255,G=255,R=255,A=255)
}
