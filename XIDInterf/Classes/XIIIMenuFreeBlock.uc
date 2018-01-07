//============================================================================
// Press start page.
//
//============================================================================
class XIIIMenuFreeBlock extends XIIIWindow;

var localized string TitleText;		// message "Free block"
var string sBackGround[4];
var texture tBackGround[4];
var int iNbBlocks;

function string Replace(string Src, string Tag, string Value)
{
local string retval;
local int p, tsz;

	Tag="%"$Tag$"%";
	tsz = Len(Tag);
	p = InStr(Src, Tag);
	while (p != -1)
	{
		retval = retval$Left(Src, p)$Value;
		Src=Mid(Src, p+tsz);
		p = InStr(Src, Tag);
	}
    return retval$Src;
}

function Created()
{
    local int i;

    Super.Created();

    for (i=0; i<4; i++)
        tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));

	bForceHelp = false;
	  
	bDisplayBar	= false;
}

event HandleParameters(String Param1,String Param2)
{
	iNbBlocks = int(Param1);
	TitleText = Replace(TitleText, "nbblocks", Param1);
}

function Paint(Canvas C, float X, float Y)
{
	local array<string> MsgArray;
	local float W, H;
	local int i;
	local int Length;
	local int TextWith;
	
	TextWith = 400;
	C.WrapStringToArray(TitleText, MsgArray, TextWith, "|");

	Super.Paint(C,X,Y);

	// draw background texture
    // background
    // 293 is (640-27*2)/2
    DrawStretchedTexture(C, 32*fRatioX, 24*fRatioY*fScaleTo, 288*fRatioX, 216*fRatioY*fScaleTo, tBackGround[0]);
    DrawStretchedTexture(C, 320*fRatioX, 24*fRatioY*fScaleTo, 288*fRatioX, 216*fRatioY*fScaleTo, tBackGround[1]);
    DrawStretchedTexture(C, 32*fRatioX, 240*fRatioY*fScaleTo, 288*fRatioX, 216*fRatioY*fScaleTo, tBackGround[2]);
    DrawStretchedTexture(C, 320*fRatioX, 240*fRatioY*fScaleTo, 288*fRatioX, 216*fRatioY*fScaleTo, tBackGround[3]);

	// draw page title
	C.bUseBorder = true;
	Length = MsgArray.Length;
	C.DrawColor = WhiteColor;
	C.TextSize(TitleText, W, H);
	DrawStretchedTexture(C, 50, 110, 540, (2*H*Length*fRatioY), myRoot.FondMenu);	
	C.DrawColor = BlackColor;
	for(i=0;i<Length;i++)
	{
		C.TextSize(MsgArray[i], W, H);
		C.SetPos((C.SizeX/2)-W/2, 110 + (2*H*i*fRatioY));
		C.DrawText(MsgArray[i], false);
	}

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
		if ( (Key==13) /*A button*/ )
		{
			myRoot.bContinueWithoutSaving=true;
			myRoot.bSavingPossible=false;
			myRoot.bProfileSelected=true;
			myRoot.OpenMenu("XIDInterf.XIIIMenu");
			return true;
		}
		
		if ( (Key==8) /*B button*/ )		
		{
			//GetPlayerOwner().ConsoleCommand("QUIT");
			// 2 is XLD_LAUNCH_DASHBOARD_MEMORY see Xbox.h
			// 85 is 'U'
			myRoot.RebootToDashboardFromScripts(2, 85, iNbBlocks);
			
			return true;
		}
    }

    return super.InternalOnKeyEvent(Key, state, delta);
}

event Tick(float fDeltatime)
{
}


