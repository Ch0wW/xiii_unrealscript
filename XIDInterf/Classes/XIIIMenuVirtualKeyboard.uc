class XIIIMenuVirtualKeyboard extends XIIIWindow;

VAR XIIIEditCtrl myEditCtrl;
var  XIIIButton LettersButton[40], OkButton;
VAR XIIIPadButton CapsButton, CancelButton, DelButton;
var  localized string OkText, CancelText, CapsText, DelText/*, PasswordText, EnterPasswordTitleText*/;

var int ButtonWidth, ButtonHeight, ButtonYPos, EditBoxWidth, EditBoxHeight, EditBoxYPos;
var int BackgroundPosX, BackgroundPosY, BackgroundWidth, BackgroundHeight;

VAR string CharSet, CapsCharSet;
VAR	string TextStr;			// Holds the current string
VAR	string TextStrBeforeEdit;	// Holds the previous string
VAR bool bCaps, bAllowTypeIn, bGrey;
VAR float WidestCharWidth;

delegate OnButtonClick(byte bButton);

FUNCTION Created()
{
    LOCAL int y, i, j, l, SpaceBetweenButtons;

    Super.Created();

	l=0;
	y=190;

	// init values
	BackgroundPosX = 110; //220;
	BackgroundPosY = 140;
	BackgroundWidth = 400; //220;
	BackgroundHeight = 220;

	ButtonWidth = 70;
	ButtonHeight = 30;
	ButtonYPos = 180;

    EditBoxWidth = 350;
    EditBoxHeight = 35;
    EditBoxYPos = 100;

	for (j=0;j<4;j++)
	{
		for (i=0;i<10;i++)
		{
//			if (l==26) continue;
			LettersButton[l] = XIIIButton(CreateControl(class'XIIIButton', BackgroundPosX+44+i*32, y,24,24));
			LettersButton[l].Text= Mid(CharSet,l,1); //Chr(Asc("a")+l-10);
			LettersButton[l].bUseBorder=false;
			Controls[Controls.Length]=LettersButton[l];
			l++;
		}
		y+=32;
	}

	OkButton = XIIIButton(CreateControl(class'XIIIButton', BackgroundPosX+44-1*32, y, 56+8,24));
	OkButton.Text= OkText;
	OkButton.bUseBorder=false;
	Controls[Controls.Length]=OkButton;

	CapsButton = XIIIPadButton(CreateControl(class'XIIIPadButton', 8+BackgroundPosX+44+1*32, y, 56+32+32,24));
	CapsButton.Text= CapsText;
	CapsButton.bUseBorder=false;
	CapsButton.PadButtonIndex = 0;
	Controls[Controls.Length]=CapsButton;

	DelButton = XIIIPadButton(CreateControl(class'XIIIPadButton', BackgroundPosX+44+5*32, y, 56+32+8,24));
	DelButton.Text= DelText;
	DelButton.bUseBorder=false;
	DelButton.PadButtonIndex = 2;
	Controls[Controls.Length]=DelButton;

	CancelButton = XIIIPadButton(CreateControl(class'XIIIPadButton', BackgroundPosX+44+8*32, y, 56+32+8,24));
	CancelButton.Text= CancelText;
	CancelButton.bUseBorder=true;
	CancelButton.PadButtonIndex = 1;
	Controls[Controls.Length]=CancelButton;


//	OkButton.PadButtonIndex = 2;

}

FUNCTION InitVK( XIIIEditCtrl EditCtrl)
{
	myEditCtrl = EditCtrl;
	TextStr = myEditCtrl.TextStr;
//	bShowDEL = (Len(TextStr)>0);
//	DelButton.bNeverFocus = (Len(TextStr)==0);
	if ( myEditCtrl.bCapsOnly )
	{
		CapsButton.bVisible = false;
		CapsButton.bNeverFocus = true;
	}
}

function ShowWindow()
{
    super.ShowWindow();
    CancelButton.SetFocus(none);
//    bShowBCK = true;
    bShowCHO = true;
}

function Paint(Canvas C, float X, float Y)
{
    local int i;
    local float W, H, EditBoxWidth;
	LOCAL string DisplayedText;

	if ( WidestCharWidth==0 )
	{
		C.TextSize("W", WidestCharWidth, H);
	}
    if ( TextStr=="" )
	{
		C.TextSize("M", W, H);
		W=0;
		DisplayedText = "";
	}
	else
	{
		if ( !myEditCtrl.bMaskText || myEditCtrl.bNoMaskWhenEdit )
			DisplayedText = TextStr;
		else
			DisplayedText = myEditCtrl.ConvertToStars( TextStr );

		C.TextSize(DisplayedText, W, H);
	}
	bAllowTypeIn = Len(TextStr)<myEditCtrl.MaxWidth;

	if ( bGrey )
	{
		if ( bAllowTypeIn )
		{
			for (i=0;i<40;i++)
			{
//				LettersButton[i].bNeverFocus=false;
				LettersButton[i].TextColor=BlackColor;
			}
			bGrey = false;
		}
	}
	else
	{
		if ( !bAllowTypeIn )
		{
			for (i=0;i<40;i++)
			{
//				LettersButton[i].bNeverFocus=true;
				LettersButton[i].TextColor=Grey3Color;
			}
/*			if ( FocusedControl!=OkButton && FocusedControl!=CancelButton && FocusedControl!=CapsButton )
			{
				XIIIButton(FocusedControl).bUseBorder = false;
				CapsButton.FocusFirst( self, false );
				CapsButton.bUseBorder = true;
			}*/
			bGrey = true;
		}
	}

    Super.Paint(C,X,Y);

    C.bUseBorder = true;
	C.DrawColor = WhiteColor;
	C.DrawColor.A = 240;
	C.Style = 5;

    DrawStretchedTexture(C, BackgroundPosX*fRatioX, BackgroundPosY*fRatioY, BackgroundWidth*fRatioX, BackgroundHeight*fRatioY, myRoot.FondMenu);
//    C.DrawColor = BlackColor;
	C.Style = 1;

	EditBoxWidth = myEditCtrl.MaxWidth * WidestCharWidth+16;
    DrawStretchedTexture(C, (BackgroundPosX+(BackgroundWidth-EditBoxWidth)*0.5)*fRatioX, (BackgroundPosY+6)*fRatioY, EditBoxWidth*fRatioX, 32*fRatioY, myRoot.FondMenu);
    C.bUseBorder = false;

	C.DrawColor = BlackColor;
	C.SetPos((BackgroundPosX+(BackgroundWidth-W)*0.5)*fRatioX, (BackgroundPosY+10)*fRatioY);
    C.DrawText(DisplayedText, false);

	if ( bAllowTypeIn && (myRoot.GetPlayerOwner().Level.TimeSeconds-int(myRoot.GetPlayerOwner().Level.TimeSeconds)) < 0.5 )
		DrawStretchedTexture(C, (BackgroundPosX+(BackgroundWidth+W)*0.5)*fRatioX, (BackgroundPosY+10)*fRatioY-2+H*0.75, 8, 2, myRoot.FondMenu);

    C.DrawColor = WhiteColor;
}

FUNCTION SwitchCaps()
{
	LOCAL int c;
	bCaps=!bCaps;
	if ( bCaps )
	{
		for (c=0;c<40;c++)
			LettersButton[c].Text=Mid(CapsCharSet,c,1);
	}
	else
	{
		for (c=0;c<40;c++)
			LettersButton[c].Text=Mid(CharSet,c,1);
	}
}

FUNCTION Delete()
{
	LOCAL bool bMustShowDel;

	TextStr=Mid(TextStr,0,Len(TextStr)-1);
/*	DelButton.bNeverFocus = (Len(TextStr)==0);
	if ( DelButton.bNeverFocus && DelButton==FocusedControl )
	{
		DelButton.bUseBorder = false;
		CapsButton.FocusFirst(Self,false);
		CapsButton.bUseBorder = true;
	}*/
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	local int index, c, l;
	local bool bUp, bDown, bLeft, bRight;
	
	if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ( Key==0x0D/*IK_Enter*/) 
	    {
			if ( FocusedControl==OkButton )
			{
				myEditCtrl.SetText( TextStr );
		        myRoot.CloseMenu(true);
				myEditCtrl.FocusFirst(Self,false);
			    return true;
			}
			else if ( FocusedControl==CancelButton )
			{
		        myRoot.CloseMenu(true);
				myEditCtrl.FocusFirst(Self,false);
			    return true;
			}
			else if ( FocusedControl==DelButton )
			{
				Delete();		       
			    return true;
			}
			else if ( FocusedControl==CapsButton )
			{
				SwitchCaps();
			    return true;
			}
			else
			{
				if ( bAllowTypeIn )
				{
					TextStr=TextStr$XIIIButton(FocusedControl).Text;
//					DelButton.bNeverFocus=false;
				}
				return true;
			}
			//			return InternalOnClick(FocusedControl);
			
	    }
		if ( !myEditCtrl.bCapsOnly && CapsButton.IsRightKeyPressed( Key ) )
		{
			SwitchCaps();
			return true;
		}
		if ( DelButton.IsRightKeyPressed( Key ) )
		{
			Delete();
			return true;
		}
	    if ( CancelButton.IsRightKeyPressed( Key ) )
	    {
		    myRoot.CloseMenu(true);
			myEditCtrl.FocusFirst(Self,false);
			return true;
	    }

 		bLeft = (Key==0x25);
		bRight = (Key==0x27);
        bUp = (Key==0x26);
        bDown = (Key==0x28);

		// controls are
        //    0
		//   1 2
		if ( bLeft || bRight  || bUp || bDown )
		{
			XIIIButton(FocusedControl).bUseBorder=false;
			if ( FocusedControl==OkButton )
			{
				if ( bRight )
					NextControl(FocusedControl);
				if ( bUp )
					Controls[30].FocusFirst(Self,false);
				if ( bDown )
					Controls[0].FocusFirst(Self,false);
			}
			else if ( FocusedControl==CapsButton )
			{
				if ( bLeft )
					PrevControl(FocusedControl);
				if ( bRight )
					NextControl(FocusedControl);
				if ( bUp )
					Controls[33].FocusFirst(Self,false);
				if ( bDown )
					Controls[3].FocusFirst(Self,false);
			}
			else if ( FocusedControl==DelButton )
			{
				if ( bLeft )
					PrevControl(FocusedControl);
				if ( bRight )
					NextControl(FocusedControl);
				if ( bUp )
					Controls[36].FocusFirst(Self,false);
				if ( bDown )
					Controls[6].FocusFirst(Self,false);
			}
			else if ( FocusedControl==CancelButton )
			{
				if ( bLeft )
					PrevControl(FocusedControl);
				if ( bUp )
					Controls[39].FocusFirst(Self,false);
				if ( bDown )
					Controls[9].FocusFirst(Self,false);
			}
			else
			{
				index = FindComponentIndex(FocusedControl);
				l = index/10;
				c = index - 10*l ;

				if ( bLeft )
					c = (c+9)%10;
				if ( bRight )
					c = (c+1)%10;
				if ( bUp)
				{
					if ( /*!DelButton.bNeverFocus &&*/ l==0 && ( c==5 || c==6 || c==7 ))
					{
						l=4;
						c=2;
					}
					else if ( l==0 && ( c==0 ))
					{
						l=4;
						c=0;
					}
					else if ( l==0 && ( c==1 || c==2 || c==3 || c==4 ))
					{
						l=4;
						c=1;
					}
					else if ( l==0 && ( c==8 || c==9 ))
					{
						l=4;
						c=3;
					}
					else
						l = (l+3)%4;
				}
				if ( bDown )
				{
					if ( /*!DelButton.bNeverFocus &&*/ l==3 && ( c==5 || c==6 || c==7 ))
					{
						l=4;
						c=2;
					}
					else if ( l==3 && ( c==8 || c==9 ))
					{
						l=4;
						c=3;
					}
					else if ( l==3 && ( c==0 ))
					{
						l=4;
						c=0;
					}
					else if ( l==3 && ( c==1 || c==2 || c==3 || c==4 ))
					{
						l=4;
						c=1;
					}
					else
						l = (l+1)%4;
				}
				Controls[l*10+c].FocusFirst(Self,false);
			}
			XIIIButton(FocusedControl).bUseBorder=true;
            return true;
        }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}








defaultproperties
{
     OKText="Ok"
     CancelText="Cancel"
     CapsText="Capitals"
     DelText="Delete"
     CharSet="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'-._"
     CapsCharSet="0123456789abcdefghijklmnopqrstuvwxyz'-._"
     bForceHelp=True
     Background=None
     bCheckResolution=True
     bRequire640x480=False
     bAllowedAsLast=True
     bHidePreviousPage=False
}
