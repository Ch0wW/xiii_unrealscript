class XIIITextureButton extends XIIIGUIBaseButton;

var  int    TextX, TextY;
var texture tFirstTex[2], tSecondTex[2], tThirdTex[2], tFourthTex[2], tAdjustTex[2];
var float   xoff, yoff, zoom;
var float fXStretch, fYStretch;
var float fPS2XPatch, fPS2YPatch;
var bool bDisplayTex, bZoomIn, bUseBorder;


function Created()
{
    super.Created();
    fPS2XPatch = 1.0; fPS2YPatch = 1.0;
}


function BeforePaint(Canvas C, float X, float Y)
{
     local float W, H;

     super.BeforePaint(C, X, Y);

     if (bZoomIn) 
	 {
       zoom+=0.067; 
	   if (zoom > 1.0) 
	   {
            bZoomIn = false; 
            zoom = 1.0;
       }
     }

     if (tFirstTex[1] != none)
     {
        if (tFirstTex[1].USize < xoff) fPS2XPatch = xoff/tFirstTex[1].USize;
        if (tFirstTex[1].VSize < yoff) fPS2YPatch = yoff/tFirstTex[1].VSize;
     }
     if (tFourthTex[1] != none)
     {
        fXStretch = WinWidth*640*fRatioX / (tSecondTex[1].USize + xoff);
        fYStretch = WinHeight*480*fRatioY / (tThirdTex[1].VSize + yoff);
     }
     else if (tSecondTex[1] != none)
     {
        fXStretch = WinWidth*640*fRatioX / (tSecondTex[1].USize*fPS2XPatch + xoff);
        fYStretch = WinHeight*480*fRatioY / (tSecondTex[1].VSize*fPS2YPatch + yoff);
     }
}


//____________________________________________________________________
// MLK    Print the text clipped to the dimensions of the button
function Paint(Canvas C,float X,float Y)
{
     local byte Bank;

//     if (C.Viewport != myRoot.ViewportOwner) return;

     super.Paint(C,X,Y);

     C.bUseBorder = bUseBorder;
     DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, myRoot.FondMenu);
     C.bUseBorder = false;

     Bank = byte(bDisplayTex);
        if (tFourthTex[Bank] != none)
        {
            DrawStretchedTexture(C, 0, 0, tFirstTex[Bank].USize*fPS2XPatch*fXStretch, tFirstTex[Bank].VSize*fPS2YPatch*fYStretch, tFirstTex[Bank]); // X-YPad
            DrawStretchedTexture(C, xoff*fXStretch, 0, tSecondTex[Bank].USize*fXStretch, tSecondTex[Bank].VSize*fYStretch, tSecondTex[Bank]);
            DrawStretchedTexture(C, 0, yoff*fYStretch, tThirdTex[Bank].USize*fPS2XPatch*fXStretch, tThirdTex[Bank].VSize*fPS2YPatch*fYStretch, tThirdTex[Bank]); // X/Y Pad
            DrawStretchedTexture(C, xoff*fXStretch, yoff*fYStretch, tFourthTex[Bank].USize*fPS2XPatch*fXStretch, tFourthTex[Bank].VSize*fYStretch, tFourthTex[Bank]);
            if (tAdjustTex[Bank] != none)
                DrawStretchedTexture(C, xoff*fXStretch, tSecondTex[Bank].VSize*fYStretch, tAdjustTex[Bank].USize*fPS2XPatch*fXStretch, tAdjustTex[Bank].VSize*fYStretch, tAdjustTex[Bank]);
        }
        else if (tSecondTex[Bank] != none)
        {
            DrawStretchedTexture(C, 0, 0, tFirstTex[Bank].USize*fPS2XPatch*fXStretch, tFirstTex[Bank].VSize*fPS2YPatch*fYStretch, tFirstTex[Bank]);
            DrawStretchedTexture(C, xoff*fXStretch, yoff*fYStretch, tSecondTex[Bank].USize*fPS2XPatch*fXStretch, tSecondTex[Bank].VSize*fPS2YPatch*fYStretch, tSecondTex[Bank]);
        }
        else if (tFirstTex[Bank] != none)
            DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, tFirstTex[Bank]);
}


//____________________________________________________________________
// MLK    the button is darkened when no mouse on
function MouseLeave()
{
     bDisplayTex = false;
// NL1106     zoom = 0;
     Super.MouseLeave();
}

//____________________________________________________________________
// MLK    Highlights the text
function MouseEnter()
{
// NL1106     
    zoom = 0;
// LN
     bZoomIn = true;
     bDisplayTex = true;
/*
     if (tFourthTex[1] != none)
     {
        fXStretch = WinWidth*640 / (tSecondTex[1].USize + xoff);
        fYStretch = WinHeight*480 / (tThirdTex[1].VSize + yoff);
     }
     else if (tSecondTex[1] != none)
     {
        fXStretch = WinWidth*640 / (tSecondTex[1].USize + xoff);
        fYStretch = WinHeight*480 / (tSecondTex[1].VSize + yoff);
     }
*/
     Super.MouseEnter();
}



defaultproperties
{
     bUseBorder=True
}
