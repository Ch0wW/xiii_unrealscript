//============================================================================
// Load saved games
//============================================================================
class XIIIMenuLoadGameWindow extends XIIIWindowMainMenu;

var localized string TitleText;
var localized string EmptySlotText;
var localized string EmptySlotErrorTitle;
var localized string EmptySlotErrorMsg;
var localized string LoadGameResultTile;
var localized string PageText;

var int  MaxMenu, onPage, MaxSlots, MaxViewable, NbPages, OldPage, CurSlot;
var string DisplayedText;

var array<XIIIbutton> SaveSlots;
//var array<string> SaveSlotsInfo;
var string SaveSlotsInfo[10];
var array<byte> bSaveSlotEmpty;

var XIIIArrowButton LeftArrow, RightArrow;

var XIIIMsgBox msgbox, msgbox2;

var texture tBackGround[3];
var string sBackground[3];

var int ReturnCode;       // to be used with save game device
var int IsEmpty;
var int i;
var int SlotNumberToLoadFrom;

var int Year;
var byte Month, Day, Hour, Min;

var string SlotDesc;

var bool bRunning;
var bool bMemoryCardDetected;
var bool bIgnoreKeys;



//============================================================================
function Created()
{
    local int i;

    CurSlot = 0;

    Super.Created();

    for (i=0; i<3; i++)
        tBackGround[i] = texture(DynamicLoadObject(sBackGround[i], class'Texture'));

    MaxSlots = myRoot.GetMaxNumberOfSavingSlots();
    if (MaxSlots > 0)
    {
        // displayed per page
        NbPages = ( MaxSlots - 1 )/MaxViewable + 1;
        if (NbPages > 0)
		{
            OnPage = 1;
			OldPage = 1;
		}

        LeftArrow = XIIIArrowButton(CreateControl(class'XIIIArrowButton', 50/*264*/, 134*fScaleTo, 16, 16));
        LeftArrow.bLeftOrient = true;
        RightArrow = XIIIArrowButton(CreateControl(class'XIIIArrowButton', 50+320/*420*/, 134*fScaleTo, 16, 16));

        // arrows don't gain focus
        LeftArrow.bNeverFocus = true;
        RightArrow.bNeverFocus = true;

		Controls[0] = LeftArrow; 
        Controls[1] = RightArrow;

        for(i=0; i<MaxViewable; i++)
        {
            SaveSlots[i] = XIIIbutton(CreateControl(class'XIIIbutton', 50, 160 + (i%MaxViewable)*40*fScaleTo, 320, 30*fScaleTo));
            SaveSlots[i].text = EmptySlotText;
 			SaveSlots[i].bNeverFocus = true;
			SaveSlots[i].bVisible = false;
            bSaveSlotEmpty[i] = 1;
            // add a page control
            Controls[i+2] = SaveSlots[i];
        }

        //PageSwitch();
    }

    bShowBCK = true;
    bShowSEL = true;

	OnReOpen = InternalOnOpen;

	GetPlayerOwner().PlayMenu(hSoundLoadMenu);

    bMemoryCardDetected = myRoot.bSavingPossible;
    GotoState('GetSlotDescription');
}


function InternalOnOpen()
{
	GetPlayerOwner().PlayMenu(hSoundLoadMenu);
}


event Tick(float deltatime)
{
    if ( !bRunning )
	{
		if ( bMemoryCardDetected )
		{
			if (!myRoot.bSavingPossible)
			{
				log("LOAD : no memory card detected");
				bMemoryCardDetected = false;
				for(i=0; i<MaxViewable; i++)
				{				
					SaveSlots[i].text = EmptySlotText;
					SaveSlots[i].bNeverFocus = false;
					SaveSlots[i].bVisible = true;
					bSaveSlotEmpty[i] = 1;
				}
			}
		}
		else
		{
			if ( myRoot.bSavingPossible )
			{
				log("LOAD : memory card detected");
				bMemoryCardDetected = true;
				for(i=0; i<MaxViewable; i++)
				{				
					SaveSlots[i].bNeverFocus = true;
					SaveSlots[i].bVisible = false;
				}
				GotoState('GetSlotDescription');
			}
		}
	}
}


function Paint(Canvas C, float X, float Y)
{
     local int i;//, oldpage;
     local float W, H;
	 LOCAL string strTemp;

     Super.Paint(C, X, Y);

     C.bUseBorder = true;
	 DrawStretchedTexture(C, 36*fRatioX, 33*fScaleTo*fRatioY, 348*fRatioX, 393*fScaleTo*fRatioY, tBackGround[0]);
     C.bUseBorder = false;
	 DrawStretchedTexture(C, 342*fRatioX, 49*fScaleTo*fRatioY, 256*fRatioX, 128*fScaleTo*fRatioY, tBackGround[1]);
     DrawStretchedTexture(C, 342*fRatioX, 177*fScaleTo*fRatioY, 256*fRatioX, 256*fScaleTo*fRatioY, tBackGround[2]);

    // slots for save game
    C.DrawColor = WhiteColor;
    // if not on first page, display arrows
    if (OnPage > 1)     Controls[0].bVisible = true;
    else                Controls[0].bVisible = false;

    if (OnPage < NbPages)     Controls[1].bVisible = true;
    else                        Controls[1].bVisible = false;

    C.bUseBorder = true;
    DrawStretchedTexture(C, 0, 40*fRatioY, 170*fRatioX, 40*fRatioY, myRoot.FondMenu);
    C.TextSize(TitleText, W, H);
    C.DrawColor = BlackColor;
    C.SetPos((160-W)*fRatioX, (60-H/2)*fRatioY);
	C.DrawText(TitleText, false);
    C.bUseBorder = false;
    C.DrawColor = WhiteColor;

	// only selected control has a border
	if ( !bRunning )
	{
    for (i=0; i<MaxViewable; i++)
        XIIIbutton(Controls[i + 2]).bUseBorder = false;    
    if (( FindComponentIndex(FocusedControl) != 0 ) || ( FindComponentIndex(FocusedControl) != 1 ))
        XIIIbutton(Controls[FindComponentIndex(FocusedControl)]).bUseBorder = true;
	}

    C.DrawColor = BlackColor;
	strTemp = PageText@OnPage$"/"$NbPages;
	C.TextSize( strTemp, W, H );
	C.SetPos( 210-W*0.5, 134*fScaleTo );
	C.DrawText( strTemp );
    C.DrawColor = WhiteColor;
	C.SetPos( 209-W*0.5, 133*fScaleTo );
	C.DrawText( strTemp );

}


function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if ( !bIgnoreKeys )
	{
		if (State==1)// IST_Press // to avoid auto-repeat
		{
			if ((Key==0x0D/*IK_Enter*/) || (Key==0x01))
			{
			   if (FindComponentIndex(FocusedControl) > 1)
				{   // slot
					CurSlot = FindComponentIndex(FocusedControl) - 2;

					// if selected slot empty, error
					if (bSaveSlotEmpty[CurSlot]==1)
					{
						myRoot.OpenMenu("XIDInterf.XIIIMsgBox");
						msgbox = XIIIMsgBox(myRoot.ActivePage);
						msgbox.InitBox(220*fRatioX, 130*fRatioY*fScaleTo, 10, 10, 220*fRatioX, 230*fRatioY*fScaleTo);
						DisplayedText = msgbox.Replace(EmptySlotErrorMsg, "NbSlot", string(CurSlot + (OnPage - 1)*MaxViewable));
						msgbox.SetupQuestion(DisplayedText, QBTN_Ok, QBTN_Ok,EmptySlotErrorTitle);
					}
					else
					{   // Load
						SlotNumberToLoadFrom = CurSlot + (OnPage - 1)*MaxViewable;
						GotoState('LoadFromSlot');
					}

					return true;
				}
				else 
				{   // arrow
					OldPage = OnPage;
					if (FindComponentIndex(FocusedControl)==0) OnPage--;
					if (FindComponentIndex(FocusedControl)==1) OnPage++;
					OnPage = Clamp(OnPage,1,NbPages);
					if (OnPage != OldPage)
						PageSwitch();
				}
			}
			if ((Key==0x08/*IK_Backspace*/)|| (Key==0x1B))
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
					OnPage = Clamp(OnPage,1,NbPages);
					if (OnPage != OldPage)
						PageSwitch();
				}
				return true;
			}
		}
	}
    return super.InternalOnKeyEvent(Key, state, delta);
}


function PageSwitch()
{
    local int i;

	for(i=0; i<MaxViewable; i++)
	{
		SaveSlots[i].text = EmptySlotText;
		bSaveSlotEmpty[i] = 1;
		if ( SaveSlotsInfo[i + (OnPage - 1)*MaxViewable] != "" )
		{
			SaveSlots[i].text = SaveSlotsInfo[i + (OnPage - 1)*MaxViewable];
			bSaveSlotEmpty[i] = 0;
		}
	}
}

State GetSlotDescription
{
Begin:
	bRunning = true;

	if ( myRoot.bSavingPossible )
	{
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
                      while (!myRoot.IsGetSlotContentDescriptionFinished(ReturnCode, SlotDesc))
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
								SlotDesc = SlotDesc$"  "$Hour$":";
								if (Min<10) SlotDesc = SlotDesc$"0";
								SlotDesc = SlotDesc$Min$" "$Month$"/"$Day$"/"$Year;
								SaveSlotsInfo[i] = SlotDesc;
                              }
                          }
                      }
                  }
              }
          }
      }
  }
	}

	bRunning = false;
	for(i=0; i<MaxViewable; i++)
	{
		SaveSlots[i].bNeverFocus = false;
		SaveSlots[i].bVisible = true;
	}
	SaveSlots[0].FocusFirst(self,true);
  PageSwitch();
  GotoState('');
}


State LoadFromSlot        // slot to use is in SlotNumberToLoadFrom
{
Begin:
    bIgnoreKeys = true;
	if (!myRoot.RequestReadSlot(SlotNumberToLoadFrom))
    {
        log("Unable to load from slot "$SlotNumberToLoadFrom);
    }
    else
    {
        while (!myRoot.IsReadSlotFinished(ReturnCode))
        {
            Sleep(0.01);
        }

		if ( ReturnCode >= 0 )
		{
			myRoot.CloseAll(true);
			myRoot.gotostate('');
		}
    }
	bIgnoreKeys = false;
    GotoState('');
}




defaultproperties
{
     TitleText="Load Game"
     EmptySlotText="-- empty slot --"
     EmptySlotErrorTitle="Slot Empty"
     EmptySlotErrorMsg="Slot %NbSlot% Empty"
     LoadGameResultTile="Save Game"
     PageText="Page"
     MaxViewable=5
     sBackground(0)="XIIIMenuStart.vignette_fond"
     sBackground(1)="XIIIMenuStart.XIII_Buste"
     sBackground(2)="XIIIMenuStart.XIII_Jambes"
     bDoStoreInSaveMenuStack=False
}
