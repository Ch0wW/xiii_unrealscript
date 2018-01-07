class XIIIVideoComboControl extends XIIIGUIBaseButton;

var array <string> Items, Items2;
var bool bSelected;
var texture tBackGround;
var string sBackGround;
var int TextX, TextX2, TextY, TextY2;
var int Index;
var int BorderInX;


function Created()
{
    super.Created();
    TextAlign = TXTA_Center;
    tBackGround = texture(DynamicLoadObject(sBackGround, class'Texture'));
   OnKeyEvent=InternalOnKeyEvent;
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
     if (ind >= Items.Length) 
         Index = Items.Length-1;
}

function AddItem(string newItem, optional string newItem2)
{
     Items[Items.Length] = newItem;
     if (newItem2 != "") Items2[Items2.Length] = newItem2;
}

function string GetValue()
{
     return Items[Index];
}

function int GetIdx()
{
     return Index;
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
          if(bIgnoreCase && Items[Count] ~= Value) return Count;
          if(Items[Count] == Value) return Count;

          Count++;
     }

     return -1;
}

function BeforePaint(Canvas C, float X, float Y)
{
    local float W, H;

    if (bSmallFont) C.Font = font'XIIIFonts.XIIIConsoleFont';
    else C.Font = font'XIIIFonts.PoliceF16';
    C.TextSize(Caps(Text), W, H);
//    TextX = (50 + (WinWidth*640 - 100)/2)*fRatioX - W/2;
    TextX = WinWidth*320*fRatioX - W/2;
    TextY = (WinHeight*480*fRatioY)/7;
    C.TextSize(Caps(Items[index]), W, H);
    TextX2 = WinWidth*320*fRatioX - W/2;
    TextY2 = 2*(WinHeight*480*fRatioY)/5;
}


function Paint(Canvas C, float X, float Y)
{
    super.Paint(C, X, Y);
    C.DrawColor = BackColor;
    DrawStretchedTexture(C, 0, 0, WinWidth*640*fRatioX, WinHeight*480*fRatioY, tBackGround);

    C.DrawColor = TextColor;
    C.Style = 5;
    C.DrawColor.A = Clamp(int(bHasFocus)*255 + 128, 0, 255);

    C.SetPos(TextX, TextY); C.DrawText(Caps(text), false);
    C.SetPos(TextX2, TextY2); C.DrawText(Caps(Items[index]), false);
    C.Style = 1;
    C.DrawColor = BackColor;
}


function MouseEnter()
{
    super.MouseEnter();
}

function MouseLeave()
{
    super.MouseLeave();
}

function bool InternalCapturedMouseMove(float deltaX, float deltaY)
{
	if (Controller.MouseX < (Bounds[0]+BorderInX))
            SetSelectedIndex(Index-1);
	else if (Controller.MouseX > (Bounds[2]-BorderInX))
            SetSelectedIndex(Index+1);
	else if ( (Controller.MouseX >= Bounds[0]) && (Controller.MouseX<=Bounds[2]) )
	{
	}

	return true;
}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (Key == 0x01)   InternalCapturedMouseMove(0,0);


	if ( (Key==0x25 || Key==0x64 || Key==0xEC) && ((State==1) || (State==2)))	// Left
	{
		SetSelectedIndex(Index-1);//-
	}

	if ( (Key==0x27 || Key==0x66 || Key==0xED) && ((State==1) || (State==2))) // Right
	{
		SetSelectedIndex(Index+1);//+
	}
	return false;
}






defaultproperties
{
     sBackground="XIIIMenuStart.Boutonvideo"
     BorderInX=15
}
