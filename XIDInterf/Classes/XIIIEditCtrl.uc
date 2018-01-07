//----------------------------------------------------------------------
//----------------------------------------------------------------------
//class XIIIEditCtrl extends XIIIButton;
class XIIIEditCtrl extends XIIIGUIBaseButton;

var		string		TextStr;			// Holds the current string
var		string		TextStrBeforeEdit;	// Holds the previous string
var		string		DisplayedTextStr;	// Holds the displayed string (the last char is not valid yet)
var		string		AllowedCharSet;		// Only Allow these characters
var		int			MaxWidth;			// Holds the maximum width (in chars) of the string - 0 = No Max

var		bool		bMaskText, bNoMaskWhenEdit;	// Displays the text as a *
//var		bool		bIntOnly;			// Only Allow Interger Numeric entry
var		bool		bCapsOnly;
var		bool		bReadOnly;			// Can't actually edit this box
//var     bool        bUpperCase;         // want upper case letters

var bool bInEditMode; // true if entering text, false otherwise

var int IdxInCharList; // idx in the AllowedCharSet string

var bool bCalculateSize; // to modify size of two boxes

// keyboard can be used for PC (PS2 ?), only allow these characters
var string AllowedKeyBoardCharSet[102];

var string TitleText;

var int TextX1, TextX2, TextY;

var float FirstBoxWidth;
var bool bAllowTypeIn, bLTrimmed, bRTrimmed;

//----------------------------------------------------------------------
function Created()
{
    OnKeyEvent=InternalOnKeyEvent;
	OnKeyType=InternalOnKeyType;
    bInEditMode=false;
    IdxInCharList=-1;

    TextStrBeforeEdit = Text;
    SetText(TextStrBeforeEdit);
}

event SetText(string NewText)
{
	TextStr = NewText;
    Text = TextStr;
	OnChange(self);
}

function DeleteChar()
{
	if (Len(TextStr)!=0)
	{
		TextStr = Left(TextStr,Len(TextStr) - 1);
	}
	SetText(TextStr);
	OnChange(Self);
}

FUNCTION string ConvertToStars(string S)
{
	LOCAL int i, l;
	LOCAL string T; 

	if ( bMaskText )
	{
		l = len(s);
		for ( i=0; i<l; i++ )
			T = T$"*";
		return T;
	}
	else
		return S;
}

EVENT bool InternalOnKeyType(out byte Key)
{
    local int i;

	if ( InStr( AllowedCharSet, Chr(Key) )!=-1 )
	{
		bInEditMode=true;
        if (( bAllowTypeIn ) )//|| ( MaxWidth!=default.MaxWidth && ( Len(TextStr) < MaxWidth )))
		{
			if ( bCapsOnly )
				TextStr = TextStr$Caps(Chr(Key));
			else
    			TextStr = TextStr$Chr(Key);
			SetText(TextStr);
			IdxInCharList=-1;
		}
		return true;
	}

	return false;
}

Delegate OnReturnPressed( )
{
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	LOCAL XIIIMenuVirtualKeyboard msgbox;
	
	if ((State==1) || (State==2))// IST_Press 
    {
        if (bInEditMode) // Can be true only on PC
        {

	        if ((Key==0x25) || (Key==0x08)) // IK_Left ou IK_Backspace
            {
                DeleteChar();
                return true;
            }
            if ( (Key==0x0D) || (Key==0x26) || (Key==0x28)/*|| ((Key==0x01))*/)//IK_Enter IK_LeftMouse
	        {
		        bInEditMode=false;
                SetText(TextStr);
				IdxInCharList=-1;
				if ( Key == 0x0D )
					OnReturnPressed( );
		        return (Key==0x0D);
	        }
	        if ((Key==0x1B))    // IK_Escape
	        {
		        bInEditMode=false;
                SetText(TextStrBeforeEdit);
		        return false;
	        }

        }
        else
        {
            if ((Key==0x0D) || ((Key==0x01)))//IK_Enter IK_LeftMouse
	        {
				if ( myRoot.CurrentPF!=0 )
				{
					myRoot.OpenMenu("XIDInterf.XIIIMenuVirtualKeyboard");
					msgbox = XIIIMenuVirtualKeyboard(myRoot.ActivePage);
					msgbox.InitVK( self );
				}
				else
				{
					bInEditMode=true;
					TextStrBeforeEdit = Text;
					SetText(Text);
					if ( Key == 0x0D )
						OnReturnPressed( );
				}
		        return true;
	        }
	        if ( ((Key==0x25) || (Key==0x08)) && myRoot.CurrentPF==0) // IK_Left ou IK_Backspace
            {
                DeleteChar();
				bInEditMode=true;
                return true;
            }
        }
	}
	return false;
}

function BeforePaint(Canvas C,float X, float Y)
{
	local float W, H;

	if ( bCalculateSize )
	{
		// no resize, we use default values for boxes
		FirstBoxWidth = (WinWidth*640*fRatioX - 16*fRatioX)/2;
	}

	if ((myRoot.bIamInMulti) && (myRoot.GetLevel().NetMode == 0))
		C.Font = font'XIIIFonts.XIIIConsoleFont';
	else 
		C.Font = font'XIIIFonts.PoliceF16';

	C.TextSize(TitleText, W, H);

	TextX1 = (FirstBoxWidth - W)/2;
	TextX2 = FirstBoxWidth + 32*fRatioX;

	TextY = (WinHeight*480*fRatioY - H)/2;

	DisplayedTextStr = ConvertToStars(TextStr);
    C.TextSize(DisplayedTextStr, W, H);
	bAllowTypeIn = /*(W < (FirstBoxWidth-40*fRatioX)) && (( MaxWidth==default.MaxWidth ) ||*/ (Len(TextStr)<MaxWidth) /*)*/;

	bLTrimmed = false;
	bRTrimmed = false;
	if ( bHasFocus )
	{
		while( W >= (WinWidth*640 - FirstBoxWidth)*fRatioX-48 ) //(FirstBoxWidth-64*fRatioX) )
		{
			DisplayedTextStr = Mid( DisplayedTextStr, 1 );
		    C.TextSize(DisplayedTextStr, W, H);
			bLTrimmed = true;
		}
	}
	else
	{
		while( W >= (WinWidth*640 - FirstBoxWidth)*fRatioX-48 ) //(FirstBoxWidth-64*fRatioX) )
		{
			DisplayedTextStr = Left( DisplayedTextStr, Len(DisplayedTextStr)-1 );
		    C.TextSize(DisplayedTextStr, W, H);
			bRTrimmed = true;
		}
	}
}

function Paint(Canvas C, float X, float Y)
{
	LOCAL float W,H;

	C.Style = 5;

	C.DrawColor = BackColor;

	if (bHasFocus) 
		C.DrawColor.A = 255;
	else 
		C.DrawColor.A = 128;

	C.bUseBorder = true;
	DrawStretchedTexture(C, 0, 0, FirstBoxWidth, WinHeight*480*fRatioY, myRoot.FondMenu);

	C.DrawColor.A = 128; // in edit mode, second box is colored in grey
	DrawStretchedTexture(C, FirstBoxWidth + 16*fRatioX, 0, (WinWidth*640 - FirstBoxWidth)*fRatioX, WinHeight*480*fRatioY, myRoot.FondMenu);
	C.bUseBorder = false;

	C.DrawColor = TextColor;
	C.SetPos(TextX1, TextY);
	C.DrawText(TitleText, false);
	C.SetPos(TextX2, TextY);
	C.DrawText( DisplayedTextStr, false);

	if ( DisplayedTextStr=="" )
	{
		C.TextSize( "M", W, H);
		W = 0;
	}
	else
		C.TextSize( DisplayedTextStr, W, H);
	if ( bHasFocus && (myRoot.GetPlayerOwner().Level.TimeSeconds-int(myRoot.GetPlayerOwner().Level.TimeSeconds)) < 0.5 )
		DrawStretchedTexture(C, TextX2+W, TextY-2+H*0.75, 8, 2, myRoot.FondMenu);
	if ( bLTrimmed )
	{
		DrawStretchedTexture(C, TextX2-12, TextY-2+H*0.75, 2, 2, myRoot.FondMenu);
		DrawStretchedTexture(C, TextX2-8, TextY-2+H*0.75, 2, 2, myRoot.FondMenu);
		DrawStretchedTexture(C, TextX2-4, TextY-2+H*0.75, 2, 2, myRoot.FondMenu);
	}
	else if ( bRTrimmed )
	{
		DrawStretchedTexture(C, TextX2+W, TextY-2+H*0.75, 2, 2, myRoot.FondMenu);
		DrawStretchedTexture(C, TextX2+W+4, TextY-2+H*0.75, 2, 2, myRoot.FondMenu);
		DrawStretchedTexture(C, TextX2+W+8, TextY-2+H*0.75, 2, 2, myRoot.FondMenu);
	}


	C.Style = 1;
}

event LoseFocus(GUIComponent Sender)
{
	super.LoseFocus(Sender);
	bInEditMode=false;
    SetText(TextStr);
	IdxInCharList=-1;
}



defaultproperties
{
     AllowedCharSet="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'-._+"
     MaxWidth=16
     bCalculateSize=True
}
