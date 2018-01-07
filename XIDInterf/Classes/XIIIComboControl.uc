class XIIIComboControl extends XIIIGUIBaseButton;

var array <string> Items, Items2;
//var XIIIArrowButton leftArrow, rightArrow;
var bool bDisplayBg, bSelected, bArrows, bGlassLook, bAlwaysFocus;
var texture tHighlight, tArrow;
var int CaptionX, ItemX, TextY;
var bool bCalculateSize, bShowRightArrow, bShowLeftArrow, bShowBordersOnlyWhenFocused;
var float FirstBoxWidth, SecondBoxWidth, BoxHeight, CanvasClipX, OldRatioX, OldRatioY, fSplitX, fSpaceX;

var int Index;

var bool bSplitScreenMode;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	OnKeyEvent = InternalOnKeyEvent;
}

FUNCTION Update()
{
	if ( OldRatioX!=fRatioX || OldRatioY!=fRatioY )
	{
		if ( Text=="" )
		{
			FirstBoxWidth = 0;
			SecondBoxWidth = (WinWidth*640)*fRatioX;
		}
		else
		{
			if ( bCalculateSize )
			{
				FirstBoxWidth = (WinWidth*320)*fRatioX;
				SecondBoxWidth= (WinWidth*320)*fRatioX;
				bCalculateSize=false;
			}
			else
			{
				SecondBoxWidth=WinWidth*640*fRatioX - FirstBoxWidth;
			}
		}
		BoxHeight = WinHeight*480*fRatioY;

		if ( !bSplitScreenMode )
			fSplitX = fRatioX;
		else
			fSplitX = 1.0;

		OldRatioX = fRatioX;
		OldRatioY = fRatioY;
	}
}


function Created()
{
    super.Created();
    TextAlign = TXTA_Center;
}

function SetArrows()
{
     bArrows = true;
}

function AlignLeft()
{
    TextAlign = TXTA_Left;
}

function int GetSelectedIndex()
{
     return Index;
}

function SetSelectedIndex(int ind)
{
	if (ind > -1) 
		Index = ind;

	bShowLeftArrow = ( Index!=0 );
	bShowRightArrow = ( Items.Length!=0 )&&( Index!=Items.Length-1 );
}

function AddItem(string newItem, optional string newItem2)
{
     Items[Items.Length] = newItem;
     if (newItem2 != "") 
         Items2[Items2.Length] = newItem2;
}

function string GetValue()
{
     return Items[Index];
}

function string GetValue2()
{
     return Items2[Index];
}

function Clear()
{
     Index = 0;
     Items.Length=0;
}

function int FindItemIndex(string Value, optional bool bIgnoreCase)
{
     local int Count;

     Count = 0;
     while(Count < Items.Length)
     {
          if(bIgnoreCase && Items[Count] ~= Value) 
              return Count;
          if(Items[Count] == Value) 
              return Count;

          Count++;
     }

     return -1;
}

// Important
// fRatioX has no influence on arrows sizes calculation in split screen mode
// Arrows will be the same size in 2 or 4 viewports

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, CW;

	C.SpaceX=0;
	Update();

	if (Items.Length>0)
		C.TextSize( Items[index], W, H);

	if (Text == "")
		ItemX = (WinWidth*640*fRatioX - W)*0.5;
	else
	{
		ItemX = FirstBoxWidth - 16*fSplitX + ( SecondBoxWidth - W ) * 0.5;

		C.TextSize( Text, CW, H);
		CaptionX = (FirstBoxWidth - CW - 32*fSplitX)/2;
	}
	TextY = (WinHeight*480*fRatioY - H)/2 + 1;

	if ( SecondBoxWidth<W )
	{
		fSpaceX= int((SecondBoxWidth-W)/(len(Text)-1)-0.9);
		C.SpaceX = fSpaceX;
		C.StrLen( Items[index], W, H);
		ItemX= FirstBoxWidth - 16*fSplitX + ( SecondBoxWidth - W ) * 0.5;
		C.SpaceX = 0;
	}
	else
	{
		fSpaceX= 0;
	}
}

function Paint(Canvas C, float X, float Y)
{
	CanvasClipX = C.ClipX;

    C.DrawColor = BackColor;
    C.Style = 5;
    if (bVisible && bNeverFocus) 
        BackColor.A = 128;
    else 
        BackColor.A = 255;

    if (bGlassLook) 
    {
        if ((bHasFocus) || (bAlwaysFocus))
            C.DrawColor.A = 255;
        else 
            C.DrawColor.A = 128;
    }
    if (bSelected && tHighLight != none)
        DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, tHighLight);

    C.bUseBorder = !bShowBordersOnlyWhenFocused || bHasFocus;

	if (Text=="")
	{
		DrawStretchedTexture(C, (int(bArrows)*20)*fSplitX, (int(bArrows)*6)*fRatioY, WinWidth*640*fRatioX - int(bArrows)*36*fSplitX, (WinHeight*480 - int(bArrows)*12)*fRatioY, myRoot.FondMenu);
	}
	else 
	{
		DrawStretchedTexture(C, 0, 0, FirstBoxWidth - 32*fSplitX, BoxHeight, myRoot.FondMenu);
		DrawStretchedTexture(C, FirstBoxWidth - 16*fSplitX, 0, SecondBoxWidth, BoxHeight, myRoot.FondMenu);
	}

    C.bUseBorder = false;

    if (bArrows && (!bShowBordersOnlyWhenFocused || bHasFocus) && ( bShowLeftArrow || bShowRightArrow ) )
    {
		if (Text!="")
		{
			C.SetPos(FirstBoxWidth - 36*fSplitX,4*fRatioY);
		}
		else 
			C.SetPos(0 ,4*fRatioY);

		if ( bShowLeftArrow )
			C.DrawTile( tArrow, 16*fSplitX, BoxHeight - 8*fRatioY, tArrow.USize, 0, -tArrow.USize, tArrow.VSize );
		if ( bShowRightArrow )
		{
			C.SetPos(WinWidth*640*fRatioX - 12*fSplitX, 4*fRatioY);
			C.DrawTile( tArrow, 16*fSplitX, BoxHeight - 8*fRatioY, 0, 0, tArrow.USize, tArrow.VSize );
		}
    }
    C.DrawColor = TextColor;

	C.SetPos(ItemX + 1,TextY);

	C.SpaceX = fSpaceX;
    if(Text!="")
    {
        if (Items.Length>0)
        {
            C.DrawText( Items[Index], false);
        }
        C.Font = font'XIIIFonts.PoliceF16';
        C.SetPos(CaptionX, TextY);
		C.SpaceX=0;
		C.DrawText( Text, false);
    }
    else
        C.DrawText( Items[Index], false);
    C.Style = 1;
	C.SpaceX=0;
}

function bool InternalOnClick( out byte Key )
{
	LOCAL float RelativeX;

    if ( (myRoot.bMapMenu || XIIIWindow(MenuOwner).bCenterInGame) && (CanvasClipX > 800) )
		RelativeX = ((Controller.MouseX-(CanvasClipX-800)*0.5)/fRatioX-WinLeft*640);
	else
		RelativeX = (Controller.MouseX/fRatioX-WinLeft*640);

	if ( bArrows  )
	{
		if (Text!="")
		{
			if ( bCalculateSize )
			{
				if ( RelativeX<WinWidth*640/2-34 )
				{
					return true;
				}
				else if ( RelativeX>WinWidth*640 - 16 )
				{
					Key = 0x27;
				}
				else if ( RelativeX<WinWidth*640/2 - 18 )
				{
					Key = 0x25;
				}
			}
			else
			{
				if ( RelativeX<FirstBoxWidth/fRatioX - 34 )
				{
					return true;
				}
				else if ( RelativeX>WinWidth*640 - 16 )
				{
					Key = 0x27;
				}
				else if ( RelativeX<FirstBoxWidth/fRatioX - 18 )
				{
					Key = 0x25;
				}
			}
		}
		else
		{
			 if ( RelativeX>WinWidth*640 - 16 )
			{
				Key = 0x27;
			}
			else if ( RelativeX<18 )
			{
				Key = 0x25;
			}
		}
	}

	return false;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ( bArrows && Key==0x01 && State==1 )
	{
		return InternalOnClick( Key );
	}
	return false;
}




defaultproperties
{
     bGlassLook=True
     tArrow=Texture'XIIIMenuStart.Interface_LoadGame.fleches'
     bCalculateSize=True
}
