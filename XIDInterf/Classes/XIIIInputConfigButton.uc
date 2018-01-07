class XIIIInputConfigButton extends XIIIGUIBaseButton;

var  int TextX, TextY;
var bool bDisabled;


function created()
{
    super.created();
    TextAlign = TXTA_Center;
}

//____________________________________________________________________
// MLK    Print the text clipped to the dimensions of the button
function Paint(Canvas C, float X, float Y)
{
     local float W, H;

//    if (C.Viewport != myRoot.ViewportOwner) return;
	 if ( Text=="" )
	 {
		 C.TextSize( "M", W, H);
		 W=0;
		 TextX = WinWidth*640*fRatioX*0.5;
		 TextY = WinHeight*480*fRatioY*0.5;
	 }
	 else
	 {
     C.TextSize( Text, W, H);
    if ((W > WinWidth*640*fRatioX) || bSmallFont)
    {
        C.Font = font'XIIIFonts.XIIIConsoleFont';
        C.TextSize( Text, W, H);
        bSmallFont = true;
    }
		 if (TextAlign == TXTA_Center)
			 TextX = (WinWidth*640*fRatioX - W)/2;
     TextY = (WinHeight*480*fRatioY - H)/2;
}
    super.Paint(C,X,Y);

    C.Style = 5;
    if (bDisabled) C.DrawColor.A = 255;
    else {
        if (bHasFocus) C.DrawColor.A = 192;
        else C.DrawColor.A = 128;
    }
    C.bUseBorder = true;
    DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, myRoot.FondMenu);
    C.bUseBorder = false;

    C.DrawColor = TextColor;
    if(Text!= "")
    {
        if (bSmallFont)
        C.Font = font'XIIIFonts.XIIIConsoleFont';
        else C.Font = font'XIIIFonts.PoliceF16';
         C.SetPos(TextX, TextY);
         C.DrawText( Text, false);
    }
	if ( bDisabled && (myRoot.GetPlayerOwner().Level.TimeSeconds-int(myRoot.GetPlayerOwner().Level.TimeSeconds)<0.5) )
	{
		DrawStretchedTexture(C, TextX+W, TextY-2+H*0.75, 8, 2, myRoot.FondMenu);
	}
    C.Style = 1;
}


defaultproperties
{
}
