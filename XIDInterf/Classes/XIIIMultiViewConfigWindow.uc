class XIIIMultiViewConfigWindow extends XIIIWindow;

//var XIIIMultiControlsWindow PWin;

//_____________________________________________________________________________
function ShowWindow()
{
    //PWin = XIIIMultiControlsWindow(ParentPage);
    Super.ShowWindow();
    bShowBCK = true;
}


function Paint(Canvas C, float X, float Y)
{
    super.Paint(C, X, Y);
    PaintControls(C, 20*fRatioX, 60*fRatioY);
}


//_____________________________________________________________________________
function PaintControls(Canvas C, float X, float Y)
{
    local int i;

    C.SetPos(X, Y);
    C.DrawColor = BlackColor;

/*    for (i=0; i<8; i++)
    {
      C.SetPos(X, Y + i*12);
      if (myRoot.CurrentPF < 2) // PC & PS2
        C.DrawText(PWin.sButtonsP[i]@"="@PWin.Buttons[i]);
      else if ( MyRoot.CurrentPF == 2 ) //XBOX
        C.DrawText(PWin.sButtonsX[i]@"="@PWin.Buttons[i]);
      else if ( MyRoot.CurrentPF == 3 ) // GC
        C.DrawText(PWin.sButtonsG[i]@"="@PWin.Buttons[i]);
    }
    for (i=8; i<16; i++)
    {
      C.SetPos(X + 280*fRatioX, Y + (i-8)*12);
      if (myRoot.CurrentPF < 2) // PC & PS2
        C.DrawText(PWin.sButtonsP[i]@"="@PWin.Buttons[i]);
      else if ( MyRoot.CurrentPF == 2 ) //XBOX
        C.DrawText(PWin.sButtonsX[i]@"="@PWin.Buttons[i]);
      else if ( MyRoot.CurrentPF == 3 ) // GC
        C.DrawText(PWin.sButtonsG[i]@"="@PWin.Buttons[i]);
    }
    for (i=16; i<18; i++)
    {
      C.SetPos(X , Y + (i-7)*12);
      if (myRoot.CurrentPF < 2) // PC & PS2
        C.DrawText(PWin.sButtonsP[i]@"="@PWin.Buttons[i]);
      else if ( MyRoot.CurrentPF == 2 ) //XBOX
        C.DrawText(PWin.sButtonsX[i]@"="@PWin.Buttons[i]);
      else if ( MyRoot.CurrentPF == 3 ) // GC
        C.DrawText(PWin.sButtonsG[i]@"="@PWin.Buttons[i]);
    }*/
    C.DrawColor = WhiteColor;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int i;

    if (State==1) // IST_Press // to avoid auto-repeat
    {
        if (Key==0x08/*IK_Backspace*/)
	    {
            myRoot.CloseMenu(true);
            return true;
	    }
	}
    return super.InternalOnKeyEvent(Key, state, delta);
}




defaultproperties
{
     bForceHelp=True
}
