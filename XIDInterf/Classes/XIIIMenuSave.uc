//============================================================================
// Save Game menu.
//
//============================================================================
class XIIIMenuSave extends XIIIWindow;

var localized string TitleText;
var localized string SaveOk;
var localized string SaveFailed;
var localized string EmptySlotText;
var localized string FullSlotErrorTitle;
var localized string FullSlotErrorMsg;
var localized string SaveGameResultTile;

var array<XIIIbutton> SaveSlots;
var array<byte> bSaveSlotEmpty;
var XIIIArrowButton LeftArrow, RightArrow;

var XIIIMsgBox msgbox, msgbox2;

var int  MaxMenu, onPage, MaxSlots, MaxViewable, NbPages, oldPage, CurSlot;
var string DisplayedText;

var int ReturnCode;       // to be used with save game device
var int IsEmpty;
var int i;
var int SlotNumberToSaveIn;

var int Year;
var byte Month, Day, Hour, Min;
var localized string PageText;

function Created()
{
    local int i;

    OnMenu = 0; 
    oldPage = 0;
    OnPage = 0;
    NbPages = 0;
    CurSlot = 0;

    Super.Created();

    MaxSlots = myRoot.GetMaxNumberOfSavingSlots();
    if (MaxSlots>0)
    {
        // total number of slots for a player
        MaxMenu = MaxSlots; 
        // displayed per page
        NbPages = (MaxSlots-1)/MaxViewable+1;
        if (NbPages>0)
            OnPage = 1;
    
        LeftArrow = XIIIArrowButton(CreateControl(class'XIIIArrowButton', (320-100), 134, 16, 16));
        LeftArrow.bLeftOrient = true;
        RightArrow = XIIIArrowButton(CreateControl(class'XIIIArrowButton', (320+100), 134, 16, 16));
        Controls[0] = LeftArrow; 
        Controls[1] = RightArrow;
        // arrows don't gain focus
        LeftArrow.bNeverFocus = true;
        RightArrow.bNeverFocus = true;

        for(i=0; i<MaxSlots; i++)
        {
            //SaveSlots[i] = XIIIbutton(CreateControl(class'XIIIbutton', 230, 160 + (i%MaxViewable)*40*fScaleTo, 200, 30*fScaleTo));
            SaveSlots[i] = XIIIbutton(CreateControl(class'XIIIbutton', 120, (160 + (i%MaxViewable)*40)*fScaleTo, 400, 30*fScaleTo));
            SaveSlots[i].bUseBorder = false;
            SaveSlots[i].bNeverFocus = true;
            SaveSlots[i].text = EmptySlotText;
            bSaveSlotEmpty[i] = 1;
            // add a page control
            Controls[i+2] = SaveSlots[i];
            Controls[i+2].bVisible = false;
        }

        PageSwitch();
    }

    bShowBCK = true;
    bShowSEL = true;

    GotoState('GetSlotDescription');
}
event Tick(float deltatime)
{
    if (!myRoot.bSavingPossible)
        myRoot.CloseMenu(true);
}

function OnTickMsgBox(float deltatime)
{
    if (!myRoot.bSavingPossible)
        myRoot.CloseMenu(true);
}

function Paint(Canvas C, float X, float Y)
{
    local float W, H;
    local int i;
	 LOCAL string strTemp;

    Super.Paint(C,X,Y);

    // main design
    if (!myRoot.GetLevel().bCineFrame)
	{
		C.DrawMsgboxBackground(false, 110*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 420*fRatioX, 250*fRatioY*fScaleTo);
	}
    else
    {
		C.DrawMsgboxBackground(false, 0.09*C.ClipX*fRatioX, 0.2*C.ClipY*fRatioY*fScaleTo, 10, 10, 0.82*C.ClipX*fRatioX, 0.6*C.ClipY*fRatioY*fScaleTo);
    }

    // slots for save game
    C.DrawColor = WhiteColor;
    // if not on first page, display arrows
    if (OnPage > 1)     Controls[0].bVisible = true;
    else                Controls[0].bVisible = false;

    if (OnPage < NbPages)     Controls[1].bVisible = true;
    else                        Controls[1].bVisible = false;

    // only selected control has a border
    for (i=(onPage-1)*MaxViewable; i < onPage*MaxViewable; i++)
        XIIIbutton(Controls[2+i]).bUseBorder = false; 
    if (FindComponentIndex(FocusedControl)!= -1)
        XIIIbutton(Controls[FindComponentIndex(FocusedControl)]).bUseBorder = true;

    CurSlot = FindComponentIndex(FocusedControl)-2;

    // page title
    C.bUseBorder = true;
    C.TextSize(/*Caps(*/TitleText/*)*/, W, H);
    DrawStretchedTexture(C, (640-W-64)*0.5*fRatioX, 70*fRatioY, (W+64)*fRatioX, 40*fScaleTo*fRatioY, myRoot.FondMenu);
    C.DrawColor = BlackColor;
    C.SetPos((320-W/2)*fRatioX, (90*fScaleTo*fRatioY)-H/2);
    C.DrawText( TitleText, false);
    
    // restore old param
	C.DrawColor = WhiteColor;
    C.DrawColor.A = 255; C.Style = 1; C.bUseBorder = false;

    C.DrawColor = BlackColor;
	strTemp = PageText@OnPage$"/"$NbPages;
	C.TextSize( strTemp, W, H );
	C.SetPos( 320*fRatioX-W*0.5, 130*fScaleTo );
	C.DrawText( strTemp );
	C.DrawColor = WhiteColor;
}

function ReturnMsgBox(byte bButton)
{
    if ((bButton & QBTN_Ok) != 0)       // ok to overwrite
    {
        GotoState('SaveInSlot');
    }
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (State==1)// IST_Press // to avoid auto-repeat
    {
        if ((Key==0x0D/*IK_Enter*/) || (Key==0x01)/*IK_LeftMouse*/)
	    {
	        if (FindComponentIndex(FocusedControl) > 1)
	        {   // slot
                CurSlot = FindComponentIndex(FocusedControl)-2;

                // Whether empty of not, memorize that it is this slot that we should save !
                SlotNumberToSaveIn = CurSlot;

                // if selected slot empty, save
                if (bSaveSlotEmpty[CurSlot]==1)
                {
                    GotoState('SaveInSlot');
                }
                else
                {   // confirm erase
                    myRoot.OpenMenu("XIDInterf.XIIIMsgBox");
                    msgbox = XIIIMsgBox(myRoot.ActivePage);
                    msgbox.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);
                    DisplayedText = msgbox.Replace(FullSlotErrorMsg, "NbSlot", string(CurSlot));
                    msgbox.SetupQuestion(DisplayedText, QBTN_Ok | QBTN_Cancel, QBTN_Cancel,FullSlotErrorTitle);
                    msgbox.OnButtonClick=ReturnMsgBox;
                    msgbox.OnTick=OnTickMsgBox;
                }

                return true;
            }
            else 
            {   // arrow
                OldPage = OnPage;
                if (FindComponentIndex(FocusedControl)==0) OnPage--;
                if (FindComponentIndex(FocusedControl)==1) OnPage++;
                PageSwitch();
            }
	    }
	    else if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B) /*IK_Escape*/)
	    {
	        myRoot.CloseMenu(true);
    	    return true;
	    }
        if (Key==0x26/*IK_Up*/)
	    {
            PrevControl(FocusedControl);
    	    return true;
	    }
	    if (Key==0x28/*IK_Down*/)
	    {
            NextControl(FocusedControl);
    	    return true;
	    }
	    if ((Key==0x25/*IK_Left*/) || (Key==0x27/*IK_Right*/))
	    {
	        if (NbPages > 1)
            {
                OldPage = OnPage;
                if (Key==0x25) OnPage--;
                if (Key==0x27) OnPage++;
                PageSwitch();
            }
            return true;
        }
    }
    return super.InternalOnKeyEvent(Key, state, delta);
}

function PageSwitch()
{
    local int i, j;

    if (OnPage < 1) 
        OnPage = 1;
    else if (OnPage > NbPages) 
        OnPage = NbPages;
    if (OnPage != OldPage)
    {
        if (0 != OldPage)
        {   // hide oldpage's controls
            for (i=(OldPage-1)*MaxViewable;i<OldPage*MaxViewable; i++)
            {
                Controls[2+i].bVisible = false;
                XIIIbutton(Controls[2+i]).bNeverFocus = true;
                XIIIbutton(Controls[2+i]).bUseBorder = false;    
            }
        }
        // show current page controls
        for (i=(onPage-1)*MaxViewable; i < onPage*MaxViewable; i++)
        {
            Controls[2+i].bVisible = true;
            XIIIbutton(Controls[2+i]).bNeverFocus = false;
            XIIIbutton(Controls[2+i]).bUseBorder = false; 
        }
        CurSlot = FindComponentIndex(Controls[(onPage-1)*MaxViewable+2])-2;
        SetFocus(Controls[CurSlot+2]);
    }
}



State GetSlotDescription
{
Begin:
    for (i=0; i<MaxSlots; i++)
    {
      if (!myRoot.RequestIsSlotEmpty(i))
      {
          log("Slot "$i$": Error: unable to access");
      }
      else
      {
          while (!myRoot.IsSlotEmptyFinished(ReturnCode, IsEmpty))
          {
              Sleep(0.01);
          }
          if (ReturnCode < 0)
          {
              log("Slot "$i$": Error2: access failed");
          }
          else
          {
              if (!bool(IsEmpty))
              {
                  bSaveSlotEmpty[i] = 0;
                  if (!myRoot.RequestGetSlotContentDescription(i))
                  {
                      log("Slot "$i$": Error3: not empty, but unable to get the description");
                  }
                  else
                  {
                      while (!myRoot.IsGetSlotContentDescriptionFinished(ReturnCode, SaveSlots[i].text))
                      {
                          Sleep(0.01);
                      }
                      if (ReturnCode < 0)
                      {
                          log("Slot "$i$": Error4: get description failed");
                      }
                      else
                      {
                          if (!myRoot.RequestGetSlotContentDateAndTime(i))
                          {
                              log("Slot "$i$": Error5: not empty, but unable to get the date and time");
                          }
                          else
                          {
                              while (!myRoot.IsGetSlotContentDateAndTimeFinished(ReturnCode, Year, Month, Day, Hour, Min))
                              {
                                  Sleep(0.01);
                              }
                              if (ReturnCode < 0)
                              {
                                  log("Slot "$i$": Error6: get date and time failed");
                              }
                              else
                              {
                                  SaveSlots[i].text = SaveSlots[i].text$"  "$Hour$":";
                                  if (Min<10) SaveSlots[i].text = SaveSlots[i].text$"0";
                                  SaveSlots[i].text = SaveSlots[i].text$Min$" "$Month$"/"$Day$"/"$Year;
                              }
                          }
                      }
                  }
              }
          }
      }
  }
  GotoState('');
}

State SaveInSlot        // slot to use is in SlotNumberToSaveIn
{
Begin:
    if (!myRoot.RequestWriteSlot(SlotNumberToSaveIn))
    {
        log("Unable to save in slot "$SlotNumberToSaveIn);
    }
    else
    {
        while (!myRoot.IsWriteSlotFinished(ReturnCode))
        {
            Sleep(0.01);
        }

        myRoot.OpenMenu("XIDInterf.XIIIMsgBox",true);
        msgbox2 = XIIIMsgBox(myRoot.ActivePage);
        msgbox2.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);
        if (ReturnCode < 0)
        {
            DisplayedText = SaveFailed;
        }
        else
        {
            DisplayedText = saveok;
        }
        msgbox2.SetupQuestion(DisplayedText, QBTN_Ok, QBTN_Ok, SaveGameResultTile);

    }
    GotoState('');
}




defaultproperties
{
     TitleText="Save game"
     EmptySlotText="-- empty slot --"
     FullSlotErrorTitle="Slot Full"
     FullSlotErrorMsg="Slot %NbSlot% already exists|Do you want to overwrite it ?"
     SaveGameResultTile="Save Game"
     QuickSavePrefix="QS :"
     MaxViewable=5
     PageText="Page"
     bForceHelp=True
     Background=None
}
