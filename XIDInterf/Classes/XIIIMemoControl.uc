class XIIIMemoControl extends XIIIGUIBaseButton;


var string Text;
var int OffsetY;
var array<string> MsgArray;
var float BoxInfoWidth, BoxInfoHeight, BoxSliderWidth, BoxSliderHeight, SliderWidth, SliderHeight;
var float ArrowWidth, OffsetSlider, Margin;
var int MaxLines, IndexSlider;
var color CursorColor;
var texture tArrowTop, tArrowDown;

VAR bool bBold;


//----------------------------------------------
function Created()
{
	BoxInfoWidth = WinWidth*640 - BoxSliderWidth - 10;
	BoxInfoHeight = WinHeight*480;
	BoxSliderHeight = BoxInfoHeight - 2*ArrowWidth - 2*Margin;
	SliderWidth = BoxSliderWidth - 2*Margin;
}

FUNCTION Gribouille( Canvas C, string T, optional bool bFake)
{
	LOCAL int i;
	LOCAL float mX, mY, W, H;

	i=InStr( T, "\\" );

	if (i!=-1)
	{
		if (i!=0)
			Gribouille( C, Left(T, i), bFake );
		switch( Mid(T, i+1,1))
		{
		case "B":
		case "b":
			bBold=!bBold;
			break;
		}
		Gribouille( C, Mid( T, i+2 ), bFake );
	}
	else
	{
		if ( !bFake )
		{
			mX = C.CurX;
			mY = C.CurY;
			C.StrLen( T, W, H );

			C.DrawText( T );
			if ( bBold )
			{
				C.SetPos( mX+1, mY );
				C.DrawText( T );
			}
			C.SetPos( mX+W, mY );
		}
	}

}

function Paint(Canvas C, float X, float Y)
{
    local float W, H;
	local int i,j;

	Super.Paint(C,X,Y);
	bBold=false;
	if ( MsgArray.Length == 0 )
	{
		C.WrapStringToArray(Text,MsgArray,(BoxInfoWidth - 10)*fRatioX,"|");
		OffsetSlider = (BoxSliderHeight - 2*SliderHeight - 2*Margin)/(MsgArray.Length - 1 - MaxLines);
	}
	
	C.bUseBorder = true;
	DrawStretchedTexture(C, 0, 0, BoxInfoWidth*fRatioX, BoxInfoHeight*fRatioY, myRoot.FondMenu);
	DrawStretchedTexture(C, (BoxInfoWidth + 10)*fRatioX, (ArrowWidth + Margin)*fRatioX, BoxSliderWidth*fRatioX, BoxSliderHeight*fRatioY, myRoot.FondMenu);
	C.bUseBorder = false;
    DrawStretchedTexture(C, (BoxInfoWidth + 10 + Margin)*fRatioX, 0, ArrowWidth*fRatioX, ArrowWidth*fRatioY, tArrowTop);
    DrawStretchedTexture(C, (BoxInfoWidth + 10 + Margin)*fRatioX, (ArrowWidth + 2*Margin + BoxSliderHeight)*fRatioY, ArrowWidth*fRatioX, ArrowWidth*fRatioY, tArrowDown);

	C.bUseBorder = true;
	C.DrawColor = CursorColor;
	DrawStretchedTexture(C, (BoxInfoWidth + 10 + Margin)*fRatioX, (ArrowWidth + Margin + IndexSlider*OffsetSlider + Margin)*fRatioY, (SliderWidth)*fRatioX, SliderHeight*fRatioY, myRoot.FondMenu);
	C.bUseBorder = false;

	C.DrawColor = TextColor;
	for (i=0;i<IndexSlider;i++)
	{
		Gribouille( C, MsgArray[i], true );
	}
	for(i=0;i<MaxLines;i++)
	{
		C.SetPos(5*fRatioX,i*OffsetY*fRatioY);
		if( i + IndexSlider>=MsgArray.Length )
			break;
		Gribouille( C, MsgArray[i + IndexSlider] );
	}
	C.DrawColor = BackColor;
}


function ChangeStep(int IndSlider)
{
	IndexSlider += IndSlider;
	IndexSlider = Clamp(IndexSlider,0,MsgArray.Length - MaxLines);
}




defaultproperties
{
     OffsetY=23
     BoxSliderWidth=20.000000
     SliderHeight=10.000000
     ArrowWidth=16.000000
     Margin=3.000000
     MaxLines=10
     CursorColor=(B=224,G=224,R=224,A=255)
     tArrowTop=Texture'XIIIMenuStart.Control_Console.fleche_top'
     tArrowDown=Texture'XIIIMenuStart.Control_Console.fleche_down'
     bNeverFocus=True
}
